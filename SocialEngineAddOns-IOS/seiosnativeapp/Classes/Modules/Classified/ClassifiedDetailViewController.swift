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
//  ClassifiedDetailViewController.swift
//  seiosnativeapp

import UIKit
import WebKit
var update = false
var classifiedDetailUpdate :Bool!

class ClassifiedDetailViewController: UIViewController, TTTAttributedLabelDelegate, UIScrollViewDelegate, WKNavigationDelegate{
    
    fileprivate var popover: Popover!
    fileprivate var popoverOptions: [PopoverOption] = [
        .type(.down),
        .blackOverlayColor(UIColor(white: 0.0, alpha: 0.6))
    ]
    
    var marqueeHeader : MarqueeLabel!
    var shareContentUrl : String!
    var shareContentUrlParam : NSDictionary!
    
    // Variable for classified Detail Form
    var classifiedIcon : UIButton!
    var classifiedTitle: UILabel!
    var categoryIcon : UILabel!
    var contentImage: String!
    
    var classifiedName:String!
    var classifiedId:Int!
    var classifiedDescription : UILabel!
    var popAfterDelay:Bool!
    var deleteclassifiedEntry:Bool!
    var classifiedInfo : TTTAttributedLabel!
    var imageScrollView: UIScrollView!
    var profileFieldLabel : TTTAttributedLabel!
    var menuItems : NSDictionary = [:]
    var ownerId : Int!
    var ownerType : String!
    var gutterMenu : NSArray = []
    
    var mainSubView:UIView!
    var coverImage:UIImageView!
    var totalClassifiedImage : NSArray!
    
    var ownerName: UILabel!
    var ownerImage : UIImageView!
    var  totalPic : TTTAttributedLabel!
    var topView : UIView!
    var imgUser : UIImageView!
    var descriptionShareContent:String!
    
    var categoryView : UIView!
    
    var categoryName : TTTAttributedLabel!
    var categoryImage : UIImageView!
    
    var scrollView : UIScrollView!
    
    var classifiedDetailTableView : UITableView!
    var shareLimit : Int = 35
    var like_comment : UIView!
    var userImage : URL!
    var photos:[PhotoViewer] = []
    var Id : Int!
    var cId : Int!
    var totalPhoto : Int!
    var count:Int = 0
    var contentUrl : String!
    var ownername : String = ""
    var lastContentOffset: CGFloat = 0
    var rightBarButtonItem : UIBarButtonItem!
    var detailWebView = WKWebView()
    var leftBarButtonItem : UIBarButtonItem!
    // Initialize Class Object
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        searchDic.removeAll(keepingCapacity: false)
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        setNavigationImage(controller: self)
        
        classifiedUpdate = false
        popAfterDelay = false
        deleteclassifiedEntry = false
        classifiedDetailUpdate = true
        category_filterId = nil
        
        // 2
        scrollView = UIScrollView(frame: view.bounds)
        scrollView.backgroundColor = bgColor
        scrollView.delegate = self
        scrollView.bounces = false
        // 3
        scrollView.contentSize = view.bounds.size
        // 4
        //        scrollView.addSubview(imageView)
        
        scrollView.sizeToFit()
        view.addSubview(scrollView)
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            mainSubView = createView(CGRect(x: PADING, y: 0, width: view.bounds.width-(2*PADING), height: 350), borderColor: borderColorDark, shadow: false)
        }
        else
        {
            mainSubView = createView(CGRect(x: PADING,y: 0, width: view.bounds.width-(2*PADING), height: 250), borderColor: borderColorLight, shadow: false)
        }
        mainSubView.isHidden = false
        mainSubView.backgroundColor = lightBgColor
        scrollView.addSubview(mainSubView)
        
        self.navigationItem.rightBarButtonItem = nil
        
        topView = createView(CGRect(x: 0, y: mainSubView.bounds.height - TOPPADING, width: view.bounds.width, height: 70), borderColor: UIColor.clear, shadow: false)
        topView.backgroundColor = lightBgColor
        scrollView.addSubview(topView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ClassifiedDetailViewController.openProfile))
        topView.addGestureRecognizer(tap)
        
        
        ownerName = createLabel(CGRect(x: 65, y: 20, width: view.bounds.width, height: 30), text: "", alignment: .left, textColor: textColorDark)
        ownerName.font = UIFont(name: fontName, size: FONTSIZEMedium)
        ownerName.longPressLabel()
        topView.addSubview(ownerName)
        
        imgUser = createImageView(CGRect(x: 10, y: 10, width: 50, height: 50), border: true)
        imgUser.layer.borderWidth = 1
        imgUser.layer.masksToBounds = false
        imgUser.layer.borderColor = UIColor.clear.cgColor
        imgUser.layer.cornerRadius = imgUser.frame.height/2
        imgUser.image = UIImage(named: "user_profile_image.png")
        imgUser.clipsToBounds = true
        topView.addSubview(imgUser)
        
        
        categoryView = createView(CGRect(x: 0, y: mainSubView.bounds.height - TOPPADING + topView.bounds.height , width: view.bounds.width, height: 30), borderColor: UIColor.clear , shadow: false)
        categoryView.backgroundColor = bgColor
        scrollView.addSubview(categoryView)
        
        
        categoryName = TTTAttributedLabel(frame: CGRect(x: contentPADING + PADING + 10, y: 20, width: view.bounds.width - 65, height: 30))
        categoryName.numberOfLines = 0
        categoryName.font = UIFont(name: fontName , size: FONTSIZEMedium)
        categoryName.linkAttributes = [kCTForegroundColorAttributeName:textColorMedium]
        categoryName.textColor = textColorMedium
        categoryName.longPressLabel()
        categoryName.delegate = self
        categoryView.addSubview(categoryName)
        
        
        profileFieldLabel = TTTAttributedLabel(frame:CGRect(x: PADING + contentPADING + 10 , y: categoryView.frame.origin.y + categoryView.bounds.height + 8  , width: view.bounds.width - (2*(PADING + contentPADING + 10)) , height: 1000) )
        profileFieldLabel.numberOfLines = 0
        profileFieldLabel.textColor = textColorMedium
        profileFieldLabel.layer.borderColor = navColor.cgColor
        profileFieldLabel.delegate = self
        profileFieldLabel.longPressLabel()
        scrollView.addSubview(profileFieldLabel)
        profileFieldLabel.isHidden = true
        
        
        detailWebView.frame = CGRect(x: 0, y: 0, width: view.bounds.width,height: 50)
        self.detailWebView.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0.0, bottom: 0.0, right: 0.0);
        self.detailWebView.scrollView.delegate = self
        detailWebView.backgroundColor = UIColor.clear
        detailWebView.isOpaque = false
        detailWebView.isHidden = true
        detailWebView.navigationDelegate = self
        //        detailWebView.scalesPageToFit = true
        detailWebView.scrollView.bounces = false
        scrollView.addSubview(detailWebView)
        
        
        
        // WebView for classified Detail
        //        classifiedDescription = createLabel(CGRect(x:0, CGRectGetHeight(profileFieldLabel.bounds)+profileFieldLabel.frame.origin.y, view.bounds.width,view.bounds.height ), "", .left, textColorDark)
        //        classifiedDescription.numberOfLines = 0
        //        classifiedDescription.font = UIFont(name: fontName, size: FONTSIZENormal)
        //        classifiedDetailTableView.addSubview(classifiedDescription)
        
        imageScrollView = UIScrollView(frame: CGRect(x: 0, y: -TOPPADING, width: view.bounds.width, height: mainSubView.bounds.height))
        imageScrollView.delegate = self
        imageScrollView.backgroundColor = placeholderColor
        
        imageScrollView.showsHorizontalScrollIndicator = false
        scrollView.addSubview(imageScrollView)
        //
        //                let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:Selector("imageTapped:"))
        //                imageScrollView.isUserInteractionEnabled = true
        //                imageScrollView.addGestureRecognizer(tapGestureRecognizer)
        //
        
        classifiedTitle = createLabel(CGRect(x: contentPADING,y: 145, width: view.bounds.width - (2 * contentPADING), height: 60), text: "", alignment: .left, textColor: textColorLight)
        
        classifiedTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
        classifiedTitle.numberOfLines = 3
        classifiedTitle.font  = UIFont(name: fontName, size: 30.0)
        classifiedTitle.longPressLabel()
        scrollView.addSubview(classifiedTitle)
        
        totalPic = TTTAttributedLabel(frame:CGRect(x: view.bounds.width-45, y: 60 ,width: 45, height: 50) )
        totalPic.numberOfLines = 0
        totalPic.textColor = textColorLight
        totalPic.backgroundColor = UIColor.clear
        totalPic.delegate = self
        totalPic.font = UIFont(name: "FontAwesome", size:FONTSIZEMedium)
        totalPic.longPressLabel()
        scrollView.addSubview(totalPic)
        totalPic.isHidden = true

        removeNavigationImage(controller: self)
        
        
        likeCommentContent_id = "\(classifiedId!)"
        likeCommentContentType = "classified"
        like_CommentStyle = 1
        
        like_comment = Like_CommentView()
        like_comment.alpha = 1
        like_comment.layer.shadowColor = shadowColor.cgColor
        like_comment.layer.shadowOffset = shadowOffset
        like_comment.layer.shadowRadius = shadowRadius
        like_comment.layer.shadowOpacity = shadowOpacity
        view.addSubview(like_comment)
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(ClassifiedDetailViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem

        
}
    
    // Explore classified Detail On View Appear
    override func viewDidAppear(_ animated: Bool) {
        _ = CGRect( x: ImageViewPading , y: 0, width: self.view.bounds.width, height: 250  )
        
        if classifiedDetailUpdate == true{
            classifiedDetailUpdate = false
            exploreClassified()
        }
        if update == true{
            update = false
            exploreClassified()
        }
    }
    
    /*
     func perFormBackAction(){
     dismissViewControllerAnimated(true, completion: nil)
     }*/
    
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
            _ = navigationController?.popViewController(animated: true)
        }
    }
    
    // Handle Menu Action
    @objc func showMenu(){
        // Generate classified Menu Come From Server as! Alert Popover
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        searchDic.removeAll(keepingCapacity: false)
        
        _ = ""
        for menu in gutterMenu{
            if let dic = menu as? NSDictionary{
                if dic["name"] as! String == "share"{
                }else{
                    
                    alertController.addAction(UIAlertAction(title: (dic["label"] as! String), style: .default, handler:{ (UIAlertAction) -> Void in
                        // Write For Edit Album Entry
                        let condition = dic["name"] as! String
                        switch(condition){
                            
                            
                        case "close" :
                            self.updateclassified(dic["url"] as! String)
                            
                        case "photo" :
                            
                            let presentedVC = UploadPhotosViewController()
                            presentedVC.directUpload = false
                            presentedVC.url = "classifieds/photo/upload/\(self.classifiedId!)"
                            presentedVC.param = ["classified_id":"\(self.classifiedId!)"]
                            presentedVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                            self.navigationController?.pushViewController(presentedVC, animated: true)
                            
                        case "report":
                            let presentedVC = ReportContentViewController()
                            presentedVC.param = (dic["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                            
                            presentedVC.url = dic["url"] as! String
                            self.navigationController?.pushViewController(presentedVC, animated: false)
                            
                        case "delete":
                            
                            // Confirmation Alert
                            displayAlertWithOtherButton(NSLocalizedString("Delete Entry", comment: ""),message: NSLocalizedString("Are you sure you want to delete this classified entry?",comment: "") , otherButton: NSLocalizedString("Delete Entry", comment: "")) { () -> () in
                                self.deleteclassifiedEntry = true
                                self.updateclassified(dic["url"] as! String)
                            }
                            self.present(alert, animated: true, completion: nil)
                            
                            
                        case "create":
                            isCreateOrEdit = true
                            let presentedVC = FormGenerationViewController()
                            presentedVC.formTitle = NSLocalizedString("Write New Entry", comment: "")
                            presentedVC.contentType = "classified"
                            presentedVC.url = dic["url"] as! String
                            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                            let nativationController = UINavigationController(rootViewController: presentedVC)
                            self.present(nativationController, animated:false, completion: nil)

                            
                        case "edit":
                            isCreateOrEdit = false
                            let presentedVC = FormGenerationViewController()
                            presentedVC.formTitle = NSLocalizedString("Edit Classified Listing", comment: "")
                            presentedVC.contentType = "classified"
                            presentedVC.param = [ : ]
                            //                    presentedVC.param = menuItem["urlParams"] as! NSDictionary
                            presentedVC.url = dic["url"] as! String
                            presentedVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                            let nativationController = UINavigationController(rootViewController: presentedVC)
                            self.present(nativationController, animated:false, completion: nil)
                            
                        default:
                            
                            print("error")

                        }
                        
                        
                    }))
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

    func updateclassified(_ url : String){
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
            
            var method = ""
            if url.range(of: "delete") != nil{
                method = "DELETE"
            }else{
                method = "POST"
            }
            
            
            let dic = Dictionary<String, String>()
            
            // Send Server Request to Explore classified Contents with classified_ID
            post(dic, url: "\(url)", method: method) { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        // On Success Update classified Detail
                        // Update classified Detail
                        
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                        }
                        if self.deleteclassifiedEntry == true{
                            classifiedUpdate = true
                            self.popAfterDelay = true
                            self.createTimer(self)
                            return
                        }
                        
                        self.exploreClassified()
                        
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
    
    // MARK: - Server Connection For classified Updation
    
    // Explore classified Detail
    func exploreClassified(){
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            removeAlert()

            // Checkin calling
    
//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()

            
            // Send Server Request to Explore classified Contents with classified_ID
            post(["classified_id":String(classifiedId), "gutter_menu": "1"], url: "classifieds/view/" + String(classifiedId), method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                 //   activityIndicatorView.stopAnimating()
                    if msg{
                        // On Success Update classified Detail
                        
                        if let classified = succeeded["body"] as? NSDictionary {

                            
                            // Update classified Menu
                            if let menu = classified["gutterMenu"] as? NSArray{
                                self.gutterMenu = menu
                                
                                if logoutUser == false{
                                    let rightNavView = UIView(frame: CGRect(x: 0, y: 0, width: 66, height: 44))
                                    rightNavView.backgroundColor = UIColor.clear
                                    
                                    let shareButton = createButton(CGRect(x: 0,y: 12,width: 22,height: 22), title: "", border: false, bgColor: false, textColor: UIColor.clear)
                                    shareButton.setImage(UIImage(named: "upload")?.maskWithColor(color: textColorPrime), for: UIControl.State())
                                    shareButton.addTarget(self, action: #selector(ClassifiedDetailViewController.shareItem), for: .touchUpInside)
                                    rightNavView.addSubview(shareButton)
                                    

                                    
                                    let optionButton = createButton(CGRect(x: 44,y: 12,width: 22,height: 22), title: "", border: false, bgColor: false, textColor: UIColor.clear)
                                    optionButton.setImage(UIImage(named: "option")?.maskWithColor(color: textColorPrime), for: UIControl.State())
                                    optionButton.addTarget(self, action: #selector(ClassifiedDetailViewController.showMenu), for: .touchUpInside)
                                    rightNavView.addSubview(optionButton)

                                    
                                    self.rightBarButtonItem = UIBarButtonItem(customView: rightNavView)
                                    
                                    self.navigationItem.rightBarButtonItem = self.rightBarButtonItem
                                }
                                
                            }
                            
                            if let response = classified["response"] as? NSDictionary {
                                
                                if let id = response["owner_id"] as? Int{
                                    self.ownerId = id
                                }
                                


                                if let type = response["owner_type"] as? String{
                                    self.ownerType = type
                                }
                                self.contentUrl = response["content_url"] as? String
                                if (response["title"] as? String) != nil{
                                    let classifiedtitle: String = (response["title"] as? String)!
                                    
                                    if classifiedtitle.length > 22{
                                        self.classifiedTitle.frame.origin.y = 110
                                    }
                                    if classifiedtitle.length > 45{
                                        self.classifiedTitle.frame.origin.y = 75
                                    }
                                    
                                }
                                self.classifiedTitle.text = response["title"] as? String
                                self.classifiedName = response["title"] as? String
                                self.classifiedTitle.numberOfLines = 3
                                self.classifiedTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
                                self.classifiedTitle.sizeToFit()
                                var descriptionText = ""
                                var profileFieldString = ""
                                if let tags = response["tags"] as? NSDictionary{
                                    var str = NSLocalizedString("Keywords:", comment: "")
                                    for tag in tags{
                                        str += " #\(tag.value), "
                                    }

                                    
                                    if str != "" {
                                        //str = str.substring(to: str.index(str.startIndex, offsetBy: str.length - 2))
                                        str = String(str[..<str.index(str.startIndex, offsetBy: str.length - 2)])
                                        profileFieldString += "\(str)"
                                        profileFieldString += "\n"
                                    }
                                    
                                }
                                
                                
                                
                                if let profileField = response["profile_fields"] as? NSDictionary {
                                    for(k,v) in profileField{
                                        profileFieldString += k as! String
                                        profileFieldString += ": "
                                        
                                        var tempValue = ""
                                        if (v is String){
                                            tempValue = (v as! String).html2String
                                        }else{
                                            tempValue = "\(v)"

                                        }
                                        profileFieldString += tempValue
                                        profileFieldString += "\n"
                                    }
                                    
                                    profileFieldString += "\n"
                                }
                                descriptionText = profileFieldString
                                if let bodyHtml = response["body"] as? String{
                                    
                                   // self.detailWebView.loadHTMLString(bodyHtml, baseURL: nil)
                                    let htmlStart = "<HTML><HEAD><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, shrink-to-fit=no\"></HEAD><BODY>"
                                    let htmlEnd = "</BODY></HTML>"
                                    let htmlString = "\(htmlStart)\(bodyHtml)\(htmlEnd)"
                                    
                                    self.detailWebView.loadHTMLString("\(htmlString)", baseURL: nil)
                                    profileFieldString += ""//bodyContent as String
                                    self.descriptionShareContent = ""//bodyContent as String
                                }
                                
                                self.profileFieldLabel.isHidden = false
                                
                                let linkColor = UIColor.blue
                                let linkActiveColor = UIColor.green
                                
                                //  profileFieldLabel.delegate = self
                                
                                self.profileFieldLabel.linkAttributes = [kCTForegroundColorAttributeName as AnyHashable : linkColor.cgColor,kCTUnderlineStyleAttributeName as AnyHashable : NSNumber(value: true as Bool)]
                                self.profileFieldLabel.activeLinkAttributes = [NSAttributedString.Key.foregroundColor : linkActiveColor]
                                self.profileFieldLabel.enabledTextCheckingTypes = NSTextCheckingResult.CheckingType.link.rawValue
                                self.profileFieldLabel.enabledTextCheckingTypes = NSTextCheckingAllTypes
                                self.profileFieldLabel.isUserInteractionEnabled = true
                                
                                
                                //self.profileFieldLabel.text = profileFieldString
                                
                                self.profileFieldLabel.setText(profileFieldString, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                                    let boldFont1 = CTFontCreateWithName((fontName as CFString?)!, FONTSIZENormal, nil)
                                    
                                    let range1 = (profileFieldString as NSString).range(of: descriptionText)
                                    mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont1, range: range1)
                                    mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorMedium , range: range1)
                                    
                                    let boldFont = CTFontCreateWithName((fontName as CFString?)!, FONTSIZENormal, nil)

                                    
                                    let range = (profileFieldString as NSString).range(of: self.descriptionShareContent)
                                    mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range)
                                    mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorDark , range: range)
                                    

                                    
                                    // TODO: Clean this up...
                                    
                                    return mutableAttributedString
                                })
                                
                                self.profileFieldLabel.sizeToFit()
                                // For Showing Check-in Button and count
                                let Pading : CGFloat = getBottomEdgeY(inputView: self.profileFieldLabel)

                                self.detailWebView.isHidden = false
                                self.detailWebView.frame.origin.y = Pading + 10
                                self.detailWebView.frame.size.height = self.detailWebView.scrollView.contentSize.height
                                self.scrollView.contentSize.height =  Pading + 10 + self.detailWebView.bounds.height + 50
                                self.scrollView.sizeToFit()
                                
                                
                                // Set classifiedInfo
                                var description = ""
                                var category = ""
                                var category_title = ""
                                if let ownerName = response["owner_title"] as? String {
                                    description = "\(ownerName)\n"
                                    self.ownerName.text = ownerName
                                    self.ownername = ownerName
                                    if let categoryTitle = response["category_title"] as? String{
                                        category_title = response["category_title"] as! String
                                        globalCatg = categoryTitle
                            category = String(format: NSLocalizedString("Category: %@", comment: ""), (categoryTitle))
                                        
                                        description += " - \(categoryTitle)"
                                        
                                        self.categoryName.setText(category, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                                            let boldFont = CTFontCreateWithName( (fontBold as CFString?)!, FONTSIZEMedium, nil)
                                            let range = (category as NSString).range(of: category_title)
                                            mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range)
                                            mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorDark , range: range)
                                            return mutableAttributedString
                                        })
                                        
                                        
                                        self.categoryName.sizeToFit()

                                        
                                        let range = (category as NSString).range(of: categoryTitle)
                                        
                                        self.categoryName.addLink(toTransitInformation: ["id" : (response["category_id"] as? Int)!, "type" : "category_id"], with:range)
                                        

                                    }
                                }
                                let url1 = URL(string:response["owner_image_profile"] as! String)!
                                self.imgUser.kf.indicatorType = .activity
                                (self.imgUser.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                self.imgUser.kf.setImage(with: url1 as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                    
                                })
                                self.userImage = url1

                                if let classifiedImages = response["images"] as? NSArray{
                                    self.totalClassifiedImage = classifiedImages
                                    self.totalPhoto = classifiedImages.count
                                    if classifiedImages.count > 1{
                                        
                                        let message = String(format: NSLocalizedString(" \(forwordIcon) \n\n \(classifiedImages.count) \(cameraIcon)", comment: ""), classifiedImages.count)
                                        self.totalPic.isHidden = false
                                        self.totalPic.setText(message, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString:NSMutableAttributedString?) -> NSMutableAttributedString? in
                                            return mutableAttributedString
                                        })
                                    }else{
                                        self.totalPic.isHidden = true
                                    }
                                    
                                    if classifiedImages.count > 0 {
                                        
                                        if let tempClassifiedImagesDic = classifiedImages[0] as? NSDictionary{
                                            if let tempImageString = tempClassifiedImagesDic["image"] as? String {
                                                self.contentImage = tempImageString
                                            }
                                        }
                                        
                                        self.imageScrollView.isHidden = false
                                        var originX = ImageViewPading
                                        for images in classifiedImages {
                                            if let dic = images as? NSDictionary {
                                                let frame = CGRect( x: originX , y: 0, width: self.view.bounds.width, height: 250  )
                                                
                                                var welcomeImageView = ClassifiedCoverImageViewWithGradient(frame: frame)
                                                
                                                welcomeImageView.tag = self.count
                                                self.count += 1
                                                welcomeImageView.isUserInteractionEnabled = true
                                                
                                                self.Id = dic["photo_id"] as! Int
                                                self.cId = dic["classified_id"] as! Int
                                                if (dic["image"] as! String) != ""{
                                                let url = URL(string:dic["image"] as! String)!
          
                                                   welcomeImageView.kf.indicatorType = .activity
                                                   (welcomeImageView.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                                   welcomeImageView.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                                        
                                                    })
                                                welcomeImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ClassifiedDetailViewController.onImageViewTap(_:))))
                                                self.imageScrollView.addSubview(welcomeImageView)
                                                }
                                            }
                                            originX += self.view.bounds.width

                                        }
                                        //self.imageScrollView.addSubview(self.classifiedTitle)
                                        self.imageScrollView.contentSize = CGSize(width: originX , height: 250)
                                        self.imageScrollView.isPagingEnabled = true
                                        self.imageScrollView.bounces = true
                                        self.imageScrollView.isUserInteractionEnabled = true
                                        
                                    }

                                }
                                
                            }
                            
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
            showAlertMessage(view.center , msg: network_status_msg , timer: false)
        }
        
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
       
        
        webView.evaluateJavaScript("document.documentElement.scrollHeight", completionHandler: { (height, error) in
            webView.frame.size.height = height as! CGFloat
            if webView.frame.size.height > 0 {
                activityIndicatorView.stopAnimating()
            }
            self.detailWebView.frame.size.height = height as! CGFloat
            self.detailWebView.frame.size.width = self.view.frame.size.width
            self.scrollView.contentSize.height =  self.detailWebView.frame.origin.y + 10 +  self.detailWebView.frame.size.height + 50
            self.scrollView.sizeToFit()
            
        })
    }

    
    // MARK:  TTTAttributedLabelDelegate
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWithPhoneNumber phoneNumber: String!) {
        //print("\(phoneNumber)")
        if let url = URL(string: "tel://\(phoneNumber)") {
            UIApplication.shared.openURL(url)
        }
    }
    

    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        
        //UIApplication.shared.openURL(url!)
        let presentedVC = ExternalWebViewController()
        presentedVC.url = url.absoluteString
        presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        let navigationController = UINavigationController(rootViewController: presentedVC)
        self.present(navigationController, animated: true, completion: nil)

    }

    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWithTransitInformation components: [AnyHashable: Any]!) {
        //print(components)
        
        
        let type = components["type"] as! String
        
        switch(type){
        case "category_id":
            classifiedUpdate = true
            searchDic.removeAll(keepingCapacity: false)
            let id = components["id"] as! Int
            searchDic["category"] = "\(id)"
            
            // _ = self.navigationController?.popViewController(animated: true)
            let presentedVC = ClassifiedSearchViewController()
            presentedVC.categ_id = id
            self.navigationController?.pushViewController(presentedVC, animated: false)
            let url : String = "classifieds/search-form"
            loadFilter(url)
            
        case "less":
            print("less")
            
        case "user":
            showProfile()
            //print("user")
        default:
            print("default")
        }
        
        
    }

    override func viewWillAppear(_ animated: Bool) {
        
        if let navigationBar = self.navigationController?.navigationBar {
            let firstFrame = CGRect(x: 68, y: 0, width: navigationBar.frame.width - 148, height: navigationBar.frame.height)
            marqueeHeader = MarqueeLabel(frame: firstFrame)
            marqueeHeader.tag = 101
            marqueeHeader.setDefault()
            navigationBar.addSubview(marqueeHeader)
        }
        
        self.navigationItem.rightBarButtonItem = self.rightBarButtonItem
        removeNavigationImage(controller: self)
    }
   func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    print("webView:\(webView) decidePolicyForNavigationAction:\(navigationAction) decisionHandler:\(String(describing: decisionHandler))")
        switch navigationAction.navigationType {
        case .linkActivated:
            if let url = navigationAction.request.url{
                
                let presentedVC = ExternalWebViewController()
                presentedVC.url = url.absoluteString
                let navigationController = UINavigationController(rootViewController: presentedVC)
                self.present(navigationController, animated: true, completion: nil)
                decisionHandler(.cancel)
                return
            }
            
//            if navigationAction.targetFrame == nil {
//                self.detailWebView.load(navigationAction.request)
//            }
//
//            if let url = navigationAction.request.url, !url.absoluteString.hasPrefix("\(baseUrl)") {
//                UIApplication.shared.open(url, options: [:], completionHandler: nil)
//                print(url.absoluteString)
//                decisionHandler(.cancel)
//                return
//            }
        default:
            break
        }
        
        if let url = navigationAction.request.url {
            print(url.absoluteString)
        }
        decisionHandler(.allow)
    }
    

    override func viewWillDisappear(_ animated: Bool) {
        

        self.marqueeHeader.text = ""
        removeMarqueFroMNavigaTion(controller: self)

        self.navigationItem.rightBarButtonItem = nil
        setNavigationImage(controller: self)
        
    }
    
    
    @objc func onImageViewTap(_ sender:UITapGestureRecognizer)
    {
        var imageString = ""
        if let tempTotalClassifiedImage = self.totalClassifiedImage[sender.view!.tag] as? NSDictionary{
            imageString = (tempTotalClassifiedImage["image"] as? String)!
        }
        let presentedVC = AdvancePhotoViewController()
        presentedVC.allphotos = allPhotos
        presentedVC.photoID = sender.view!.tag
        presentedVC.imageUrl = imageString
        presentedVC.photoType = "photo"
        presentedVC.photoForViewer = photos
        presentedVC.total_items = self.totalPhoto
        presentedVC.notShowComment = true
        presentedVC.attachmentID = "\(cId!)"
        presentedVC.albumTitle = classifiedName
        presentedVC.ownerTitle = ownername
        presentedVC.url = "/classifieds/photo/list/" + String(cId)
        self.navigationController?.pushViewController(presentedVC, animated: false)
    }
    
    func showProfile(){
        let presentedVC = ContentActivityFeedViewController()
        presentedVC.subjectType = "user"//ownerType
        presentedVC.subjectId = "\(ownerId!)"
        searchDic.removeAll(keepingCapacity: false)
        
        var navigationVC:[UIViewController] = (self.navigationController?.viewControllers)! as [UIViewController]
        let newVC = [ navigationVC[0] , presentedVC]
        self.navigationController?.setViewControllers(newVC, animated: false)
        
    }
    
    
    func imageTapped(_ img: AnyObject)
    {
        let presentedVC = AdvancePhotoViewController()
        presentedVC.allphotos = allPhotos
        presentedVC.photoID = 0
        presentedVC.photoType = "photo"
        presentedVC.photoForViewer = photos
        presentedVC.total_items = self.totalPhoto
        presentedVC.notShowComment = true
        presentedVC.attachmentID = "\(cId!)"
        presentedVC.url = "/classifieds/photo/list/" + String(cId)
        presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        let nativationController = UINavigationController(rootViewController: presentedVC)
        present(nativationController, animated:true, completion: nil)
    }
    
    @objc func goBack()
        
    {
        if conditionalProfileForm == "BrowsePage"
        {
            classifiedUpdate = true
            _ = self.navigationController?.popToRootViewController(animated: false)
        }
        else
        {
            _ = self.navigationController?.popViewController(animated: false)
        }
        
        
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        arrowView.isHidden = true
        scrollViewEmoji.isHidden = true
        scrollviewEmojiLikeView.isHidden = true
        let scrollOffset = scrollView.contentOffset.y
        
        if (scrollOffset > 60.0){
            let barAlpha = max(0, min(1, (scrollOffset/155)))
            setNavigationImage(controller: self)
            self.navigationController?.navigationBar.alpha = barAlpha
            self.classifiedTitle.alpha = 1-barAlpha
            self.marqueeHeader.text = self.classifiedName
            self.marqueeHeader.alpha = barAlpha
            if (self.lastContentOffset > scrollView.contentOffset.y) {
                // move up
                self.like_comment.fadeIn()
            }
            else if (self.lastContentOffset < scrollView.contentOffset.y){
                // move down
                self.like_comment.fadeOut()
            }
            // update the new position acquired
            self.lastContentOffset = scrollView.contentOffset.y
        }else{
            let barAlpha = max(0, min(1, (scrollOffset/155)))
            
            self.title = ""
            removeNavigationImage(controller: self)
            self.marqueeHeader.alpha = 1
            self.classifiedTitle.alpha = 1-barAlpha
            self.like_comment.alpha = 1
            if (scrollOffset < 10.0){
                self.classifiedTitle.alpha = 1
                self.title = ""
                self.like_comment.alpha = 1
            }
        }
        //        }
    }
    
    @objc func openProfile(){
        if (self.ownerId != nil){
            let presentedVC = ContentActivityFeedViewController()
            presentedVC.subjectType = "user"
            presentedVC.subjectId = "\(self.ownerId!)"
            searchDic.removeAll(keepingCapacity: false)
            self.navigationController?.pushViewController(presentedVC, animated: false)
        }
    }
    
    @objc func shareItem(){
        
        let startPoint = CGPoint(x: self.view.frame.width - 72, y: 50)
        self.popover = Popover(options: self.popoverOptions, showHandler: nil, dismissHandler: nil)
        let ShareOptionHeightCount:CGFloat = CGFloat(44*ShareOption.count)
        let tableView = UITableView(frame: CGRect(x: 0, y: TOPPADING, width: self.view.frame.width, height: ShareOptionHeightCount))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.tag = 11
        tableView.estimatedRowHeight = 34.0
        popover.show(tableView, point: startPoint)
        tableView.reloadData()
        
        for menu in gutterMenu{
            if let dic = menu as? NSDictionary{
                if dic["name"] as! String == "share"{
                    self.shareContentUrl = dic["url"] as! String
                    self.shareContentUrlParam = dic["urlParams"] as! NSDictionary
                }
            }
        }
    }

    // MARK: - Checkin wideget server calling
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


extension ClassifiedDetailViewController: UITableViewDelegate {
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.popover.dismiss()
        if (indexPath as NSIndexPath).row == 0{
            
            var sharingItems = [AnyObject]()
            
            if let text = self.classifiedName {
                sharingItems.append(text as AnyObject)
            }
            
            
            if let url = self.contentUrl {
                let finalUrl = URL(string: url)!
                sharingItems.append(finalUrl as AnyObject)
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
                presentationController?.sourceRect = CGRect(x: self.view.bounds.width/2 , y: self.view.bounds.width/2, width: 0, height: 0)
                presentationController?.permittedArrowDirections = UIPopoverArrowDirection()
                
            }
            
            self.present(activityViewController, animated: true, completion: nil)
            
            
        }else if (indexPath as NSIndexPath).row == 1{
            
            let pv = AdvanceShareViewController()
            pv.url = shareContentUrl
            pv.param = shareContentUrlParam as! [AnyHashable : Any] as NSDictionary
            pv.Sharetitle = self.classifiedName
            pv.imageString = self.contentImage
            if (self.descriptionShareContent != nil) {
                pv.ShareDescription = self.descriptionShareContent!
            }
            pv.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            let nativationController = UINavigationController(rootViewController: pv)
            self.present(nativationController, animated:true, completion: nil)
            
        }else if (indexPath as NSIndexPath).row == 2{
            UIPasteboard.general.url = URL(string: self.contentUrl)
            showToast(message: NSLocalizedString("Link copied.",comment: ""), controller: self)
        }
        
    }
}

extension ClassifiedDetailViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return ShareOption.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
        cell.textLabel?.textColor = UIColor.darkGray
        cell.textLabel?.text = ShareOption[(indexPath as NSIndexPath).row]
        return cell
        
    }
}


