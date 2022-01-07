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
//  BlogDetailViewController.swift
//  seiosnativeapp
//


import UIKit
import WebKit

var blogDetailUpdate: Bool!
class BlogDetailViewController: UIViewController, UIScrollViewDelegate, TTTAttributedLabelDelegate{
    
    // Variable for Blog Detail Form
    var blogIcon : UIButton!
    var blogTitle: UILabel!
    fileprivate var popover: Popover!
    fileprivate var popoverOptions: [PopoverOption] = [
        .type(.down),
        .blackOverlayColor(UIColor(white: 0.0, alpha: 0.6))
    ]
    
    var blogName:String!
    var blogId:Int!
    var detailWebView = WKWebView()
    var popAfterDelay:Bool!
    var deleteBlogEntry:Bool!
    var blogInfo : TTTAttributedLabel!
    var gutterMenu : NSArray = []
    var lastContentOffset: CGFloat = 0
    var like_comment : UIView!
    
    var menuItems : NSDictionary = [:]
    var ownerId : Int!
    var ownerType : String!
    var shareUrl : String!
    var shareParam : NSDictionary!
    var shareTitle : String!
    var contentUrl : String!
    var rightBarButtonItem : UIBarButtonItem!
    var truncatedDescription : String!
    var contentImageUrls : String!
    var leftBarButtonItem : UIBarButtonItem!
    // Initialize Class Object
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        searchDic.removeAll(keepingCapacity: false)
        view.backgroundColor = UIColor.white
        blogUpdate = false
        popAfterDelay = false
        deleteBlogEntry = false
        blogDetailUpdate = true
        category_filterId = nil
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(BlogDetailViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        
        
        self.navigationItem.rightBarButtonItem = nil
        // Set Blog Title
        blogTitle = createLabel(CGRect(x: 4*PADING , y: TOPPADING + contentPADING, width: view.bounds.width - 5*PADING, height: 100), text: "", alignment: .left, textColor: textColorDark)
        blogTitle.numberOfLines = 0
        blogTitle.font = UIFont(name: fontBold, size: FONTSIZEMedium)
        view.addSubview(blogTitle)
        
        // Set BlogIcon
        blogIcon = createButton(CGRect(x: PADING, y: blogTitle.bounds.height + blogTitle.frame.origin.y + contentPADING, width: 0, height: ButtonHeight), title: "", border: true,bgColor: false, textColor: textColorLight)
        blogIcon.layer.cornerRadius = cornerRadiusNormal
        blogIcon.imageView?.contentMode = UIView.ContentMode.scaleAspectFill
        blogIcon.layer.masksToBounds = true
        blogIcon.isHidden = true
        // blogIcon.addTarget(self, action: Selector, forControlEvents: .normal)
        blogIcon.addTarget(self, action: #selector(BlogDetailViewController.showProfile), for: .touchUpInside)
        view.addSubview(blogIcon)
        blogIcon.isHidden = true
        
        // Set BlogInfo Detail
        blogInfo = TTTAttributedLabel(frame:CGRect(x: 4*PADING + blogIcon.bounds.width , y: blogIcon.frame.origin.y, width: view.bounds.width - (5*PADING) , height: 200) )
        blogInfo.numberOfLines = 0
        blogInfo.linkAttributes = [kCTForegroundColorAttributeName:textColorMedium]
        blogInfo.delegate = self
        blogInfo.longPressLabel()
        view.addSubview(blogInfo)
        
        
        // WebView for Blog Detail
        detailWebView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - (blogInfo.bounds.height + contentPADING + blogInfo.frame.origin.y) - tabBarHeight - 10)
        self.detailWebView.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0.0, bottom: 0.0, right: 0.0);
        self.detailWebView.scrollView.delegate = self
        detailWebView.backgroundColor = UIColor.clear
        detailWebView.isOpaque = false
        detailWebView.navigationDelegate = self
        detailWebView.scrollView.bounces = true
        detailWebView.scrollView.isScrollEnabled = true
        view.addSubview(detailWebView)
        
        
        likeCommentContent_id = "\(blogId!)"
        likeCommentContentType = "blog"
        like_CommentStyle = 1
        like_comment = Like_CommentView()
        
        like_comment.alpha = 1
        like_comment.layer.shadowColor = shadowColor.cgColor
        like_comment.layer.shadowOffset = shadowOffset
        like_comment.layer.shadowRadius = shadowRadius
        like_comment.layer.shadowOpacity = shadowOpacity
        view.addSubview(like_comment)
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = blogName
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationItem.rightBarButtonItem = nil
    }
    // Explore Blog Detail On View Appear
    override func viewDidAppear(_ animated: Bool)
    {
        self.navigationItem.rightBarButtonItem = self.rightBarButtonItem
        if blogDetailUpdate == true{
            blogDetailUpdate = false
            exploreBlog()
        }
    }
    /*
     func perFormBackAction(){
     dismissViewControllerAnimated(true, completion: nil)
     }*/
    
    // Generate Custom Alert Messages
    func showAlertMessage( _ centerPoint: CGPoint, msg: String , timer: Bool){
        self.view .addSubview(validationMsg)
        showCustomAlert(centerPoint, msg: msg)
        if timer
        {
            // Initialization of Timer
            self.createTimer(self)
        }
    }
    func createTimer(_ target: AnyObject){
        timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  #selector(stopTimer), userInfo: nil, repeats: false)
    }
    // Stop Timer
    @objc func stopTimer()
    {
        stop()
        if popAfterDelay == true
        {
            _ = navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func shareItem()
    {
        let startPoint = CGPoint(x: self.view.frame.width - 66, y: 50)
        self.popover = Popover(options: self.popoverOptions, showHandler: nil, dismissHandler: nil)
        let tableView = UITableView(frame: CGRect(x: 0, y: TOPPADING, width: self.view.frame.width, height: 132))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.tag = 11
        popover.show(tableView, point: startPoint)
        
    }
    
    func shareTextImageAndURL(sharingText: String?, sharingImage: UIImage?)
    {
        var shareText = ""
        var shareImage : UIImage?
        var shareURL = "none"
        
        if let text = sharingText
        {
            shareText = text
        }
        if let image = sharingImage
        {
            shareImage = image
        }
        
        let activityItems = ActivityShareItemSources(text: shareText, image: shareImage!, url: URL(string: shareURL)!)
        
        let activityViewController = UIActivityViewController(activityItems: [activityItems], applicationActivities: nil)
        
        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
        
        
        if(activityViewController.popoverPresentationController != nil) {
            activityViewController.popoverPresentationController?.sourceView = self.view;
            let frame = UIScreen.main.bounds
            
            activityViewController.popoverPresentationController?.sourceRect = frame;
        }
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    // Show Gutter Menus
    @objc func showGutterMenu(){
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        searchDic.removeAll(keepingCapacity: false)
        for menu in gutterMenu{
            if let dic = menu as? NSDictionary{
                if dic["name"] as! String == "share"{
                }else{
                    let titleString = dic["name"] as! String
                    if titleString.range(of: "delete") != nil{
                        alertController.addAction(UIAlertAction(title: (dic["label"] as! String), style: UIAlertAction.Style.destructive, handler:{ (UIAlertAction) -> Void in
                            // Write For Edit Album Entry
                            let condition = dic["name"] as! String
                            switch(condition){
                                
                            case "delete":
                                
                                displayAlertWithOtherButton(NSLocalizedString("Delete Entry", comment: ""),message: NSLocalizedString("Are you sure you want to delete this blog entry?",comment: "") , otherButton: NSLocalizedString("Delete Entry", comment: "")) { () -> () in
                                    self.deleteBlogEntry = true
                                    self.updateBlog(dic["url"] as! String)
                                }
                                self.present(alert, animated: true, completion: nil)
                            default:
                                showToast(message: unconditionalMessage, controller: self)
                                
                            }
                            
                        }))}
                    else{
                        
                        
                        alertController.addAction(UIAlertAction(title: (dic["label"] as! String), style: UIAlertAction.Style.default, handler:{ (UIAlertAction) -> Void in
                            // Write For Edit Album Entry
                            let condition = dic["name"] as! String
                            switch(condition){
                                
                            case "report":
                                let presentedVC = ReportContentViewController()
                                presentedVC.param = (dic["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                presentedVC.url = dic["url"] as! String
                                self.navigationController?.pushViewController(presentedVC, animated: false)
                                
                            case "subscribe":
                                
                                var message = ""
                                let title = dic["label"] as! String
                                message = String(format: NSLocalizedString("Would you like to %@ to this member's blog?", comment: ""), title)
                                
                                displayAlertWithOtherButton(title, message: message, otherButton: title) { () -> () in
                                    self.updateBlog(dic["url"] as! String)
                                }
                                self.present(alert, animated: true, completion: nil)
                                
                                
                            case "unsubscribe":
                                
                                var message = ""
                                let title = dic["label"] as! String
                                message = String(format: NSLocalizedString("Would you like to %@ from this member's blog?", comment: ""), title)
                                displayAlertWithOtherButton(title, message: message, otherButton: title) { () -> () in
                                    self.updateBlog(dic["url"] as! String)
                                }
                                self.present(alert, animated: true, completion: nil)
                                
                            case "create":
                                
                                let presentedVC = FormGenerationViewController()
                                isCreateOrEdit = true
                                presentedVC.formTitle = NSLocalizedString("Write New Entry", comment: "")
                                presentedVC.contentType = "blog"
                                presentedVC.url = dic["url"] as! String
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:false, completion: nil)
                                
                            case "edit":
                                
                                let presentedVC = FormGenerationViewController()
                                presentedVC.contentType = "blog"
                                isCreateOrEdit = false
                                //presentedVC.param = dic["urlParams"] as! NSDictionary
                                presentedVC.formTitle = NSLocalizedString("Edit Blog Entry", comment: "")
                                presentedVC.url = dic["url"] as! String
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:false, completion: nil)
                                
                            default:
                                showToast(message: unconditionalMessage, controller: self)
                                
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
    
    func updateBlog(_ url: String){
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
            var method:String
            
            if url.range(of: "delete") != nil{
                method = "DELETE"
            }else{
                method = "POST"
            }
            
            if url.range(of: "subscribe") != nil{
                dic["owner_id"] = "\(ownerId)"
            }
            
            
            // Send Server Request to Explore Blog Contents with Blog_ID
            post(dic, url: "\(url)", method: method) { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        // On Success Update Blog Detail
                        // Update Blog Detail
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                        }
                        if self.deleteBlogEntry == true{
                            blogUpdate = true
                            for controller in self.navigationController!.viewControllers as Array {
                                if controller.isKind(of: BlogViewController.self) {
                                    _ = self.navigationController?.popToViewController(controller as UIViewController, animated: true)
                                    break
                                }
                            }
                            //self.popAfterDelay = true
                            self.createTimer(self)
                            return
                        }
                        self.exploreBlog()
                        
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
    
    // MARK: - Server Connection For Blog Updation
    
    // Explore Blog Detail
    func exploreBlog(){
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            // Send Server Request to Explore Blog Contents with Blog_ID
            post(["blog_id":String(blogId), "gutter_menu": "1"], url: "blogs/view/" + String(blogId), method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        // On Success Update Blog Detail
                        
                        if let blog = succeeded["body"] as? NSDictionary {
                            
                            if let menu = blog["gutterMenu"] as? NSArray{
                                self.gutterMenu  = menu
                                
                                
                                var isCancel = false
                                for tempMenu in self.gutterMenu{
                                    if let tempDic = tempMenu as? NSDictionary{
                                        
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
                                    
                                    
                                    let rightNavView = UIView(frame: CGRect(x: 0, y: 0, width: 66, height: 44))
                                    rightNavView.backgroundColor = UIColor.clear
                                    
                                    let shareButton = createButton(CGRect(x: 0,y: 12,width: 22,height: 22), title: "", border: false, bgColor: false, textColor: UIColor.clear)
                                    shareButton.setImage(UIImage(named: "upload")?.maskWithColor(color: textColorPrime), for: UIControl.State())
                                    shareButton.addTarget(self, action: #selector(BlogDetailViewController.shareItem), for: .touchUpInside)
                                    rightNavView.addSubview(shareButton)
                                    
                                    let optionButton = createButton(CGRect(x: 44,y: 12,width: 22,height: 22), title: "", border: false, bgColor: false, textColor: UIColor.clear)
                                    optionButton.setImage(UIImage(named: "option")?.maskWithColor(color: textColorPrime), for: UIControl.State())
                                    optionButton.addTarget(self, action: #selector(BlogDetailViewController.showGutterMenu), for: .touchUpInside)
                                    // rightNavView.addSubview(optionButton)
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
                            
                            if let response = blog["response"] as? NSDictionary {
                                
                                // set Blog Title
                                self.shareTitle = response["title"] as? String
                                
                                if let id = response["owner_id"] as? Int{
                                    self.ownerId = id
                                }
                                
                                if let type = response["owner_type"] as? String{
                                    self.ownerType = type
                                }
                                
                                
                                
                                if let tempString = response["title"] as? NSString{
                                    var value : String
                                    value = "\(tempString)"
                                    self.blogTitle.text = value
                                    self.blogName = value
                                }
                                
                                self.blogTitle.numberOfLines = 0
                                self.blogTitle.lineBreakMode = NSLineBreakMode.byCharWrapping
                                self.blogTitle.sizeToFit()
                                
                                self.blogInfo.frame.origin.y = self.blogTitle.bounds.height + contentPADING + self.blogTitle.frame.origin.y
                                
                                self.contentUrl =  response["content_url"] as! String
                                
                                // dispatch_async(dispatch_get_main_queue(),{
                                let url = URL(string: response["owner_image"] as! String)
                                
                                self.contentImageUrls = response["owner_image"] as! String
                                
                                
                                if  url != nil {
                                    self.blogIcon.kf.setImage(with: url as URL?, for: .normal, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                        DispatchQueue.main.async {
                                            self.blogIcon.frame.origin.y = self.blogInfo.frame.origin.y
                                            self.blogIcon.isHidden = true
                                        }
                                    })
                                }
                                
                                self.blogIcon.addTarget(self, action: #selector(BlogDetailViewController.showProfile), for: .touchUpInside)
                                // Set BlogInfo
                                var description = ""
                                let ownerName = response["owner_title"] as? String
                                
                                let categoryTitle = response["category_title"] as? String
                                if categoryTitle != "" && categoryTitle != nil{
                                    globalCatg = categoryTitle!
                                    description = "in \(categoryTitle!)"
                                }
                                
                                if ownerName != ""{
                                    description += " - by \(ownerName!)"
                                }
                                let postedDate = response["creation_date"] as? String
                                if postedDate != ""{
                                    let postedOn = dateDifference(postedDate!)
                                    description += " - \(postedOn)"
                                }
                                
                                self.blogInfo.textColor = textColorMedium
                                self.blogInfo.font = UIFont(name: fontName, size: FONTSIZESmall)
                                
                                self.blogInfo.setText(description, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                                    var boldFont = CTFontCreateWithName( (fontBold as CFString?)!, FONTSIZESmall, nil)
                                    if(categoryTitle != nil && categoryTitle != ""){
                                        let range = (description as NSString).range(of: categoryTitle!)
                                        mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range)
                                        mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorDark , range: range)
                                        
                                    }
                                    boldFont =  CTFontCreateWithName( (fontBold as CFString?)!, FONTSIZESmall, nil)
                                    
                                    let range1 = (description as NSString).range(of: ownerName!)
                                    mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range1)
                                    mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorDark , range: range1)
                                    
                                    // TODO: Clean this up...
                                    
                                    return mutableAttributedString
                                })
                                
                                if(categoryTitle != nil && categoryTitle != ""){
                                    let range = (description as NSString).range(of: categoryTitle!)
                                    self.blogInfo.addLink(toTransitInformation: ["id" : (response["category_id"] as? Int)!, "type" : "category_id"], with:range)
                                    
                                }
                                
                                let range1 = (description as NSString).range(of: ownerName!)
                                self.blogInfo.addLink(toTransitInformation: ["type" : "user"], with:range1)
                                self.blogInfo.lineBreakMode = NSLineBreakMode.byWordWrapping
                                self.blogInfo.sizeToFit()
                                
                                // For Showing Check-in Button and count
                                let Pading : CGFloat = getBottomEdgeY(inputView: self.blogInfo) + 10
                                let topicDescription = (response["body"] as! String) 
                                
//                                let headerString = "<header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'></header>"
//                                self.detailWebView.loadHTMLString(headerString + topicDescription, baseURL: nil)
//                                activityIndicatorView.center = self.detailWebView.center
                                
                                let htmlStart = "<HTML><HEAD><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, shrink-to-fit=no\"></HEAD><BODY>"
                                let htmlEnd = "</BODY></HTML>"
                                let htmlString = "\(htmlStart)\(topicDescription)\(htmlEnd)"
                                
                                self.detailWebView.loadHTMLString("\(htmlString)", baseURL: nil)
                                
                                self.detailWebView.addSubview(activityIndicatorView)
                                activityIndicatorView.startAnimating()
                                
                                DispatchQueue.main.async {
                                    self.truncatedDescription = topicDescription.html2String
                                }
                                
                                self.detailWebView.frame.origin.y = Pading + contentPADING
                                self.detailWebView.frame.size.height = self.view.bounds.height - (self.detailWebView.frame.origin.y ) - tabBarHeight
                                
                                DispatchQueue.main.async {
                                    self.truncatedDescription = topicDescription.html2String
                                }
                              
                                
                            }
                            
                        }
                        if succeeded["message"] != nil
                        {
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        
                    }
                    else
                    {
                        // Handle Server Error
                        if succeeded["message"] != nil
                        {
                            showToast(message: succeeded["message"] as! String, controller: self)
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
    
    // MARK:  TTTAttributedLabelDelegate
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!)
    {
        //UIApplication.shared.openURL(url!)
        let presentedVC = ExternalWebViewController()
        presentedVC.url = url.absoluteString
        presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        let navigationController = UINavigationController(rootViewController: presentedVC)
        self.present(navigationController, animated: true, completion: nil)
        
    }
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWithTransitInformation components: [AnyHashable: Any]!)
    {
        //print(components)
        
        
        let type = components["type"] as! String
        
        switch(type)
        {
        case "category_id":
            blogUpdate = true
            searchDic.removeAll(keepingCapacity: false)
            let id = components["id"] as! Int
            searchDic["category"] = "\(id)"
            let presentedVC = BlogSearchViewController()
            presentedVC.categ_id = id
            self.navigationController?.pushViewController(presentedVC, animated: false)
            let url : String = "blogs/search-form"
            loadFilter(url)
            
        case "less":
            print("less")
            
        case "user":
            //print("user")
            showProfile()
        default:
            print("default")
        }
        
    }
    
    
   

    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        arrowView.isHidden = true
        scrollViewEmoji.isHidden = true
        scrollviewEmojiLikeView.isHidden = true
        let scrollOffset = scrollView.contentOffset.y
        
        if (scrollOffset > 60.0){
            
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
            self.like_comment.alpha = 1
            if (scrollOffset < 10.0){
                self.like_comment.alpha = 1
            }
        }
        
    }
    
    
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func showProfile(){
        let presentedVC = ContentActivityFeedViewController()
        presentedVC.subjectType = ownerType
        presentedVC.subjectId = "\(ownerId!)"
        searchDic.removeAll(keepingCapacity: false)
        self.navigationController?.pushViewController(presentedVC, animated: true)
    }
    
    @objc func goBack(){
        if conditionalProfileForm == "BrowsePage"
        {
            blogUpdate = true
            _ = self.navigationController?.popToRootViewController(animated: false)
        }
        else
        {
            _ = self.navigationController?.popViewController(animated: false)
            
        }
        
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


extension BlogDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.popover.dismiss()
        if (indexPath as NSIndexPath).row == 0{
            
            var sharingItems = [AnyObject]()
            if let text = self.shareTitle {
                sharingItems.append(text as AnyObject)
                
            }
            
            if let url = self.contentUrl {
                let finalUrl = URL(string: url)!
                sharingItems.append(finalUrl as AnyObject)
            }
            
            let activityViewController = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
            activityViewController.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
            if(activityViewController.popoverPresentationController != nil) {
                activityViewController.popoverPresentationController?.sourceView = self.view;
                let frame = UIScreen.main.bounds
                activityViewController.popoverPresentationController?.sourceRect = frame;
            }
            
            self.present(activityViewController, animated: true, completion: nil)
        }else if (indexPath as NSIndexPath).row == 1{
            
            let pv = AdvanceShareViewController()
            pv.url = self.shareUrl
            pv.param = self.shareParam as! [AnyHashable : Any] as NSDictionary
            pv.Sharetitle = self.shareTitle
            pv.imageString = self.contentImageUrls
            pv.ShareDescription = self.truncatedDescription
            pv.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            let nativationController = UINavigationController(rootViewController: pv)
            self.present(nativationController, animated:true, completion: nil)
            
        }else if (indexPath as NSIndexPath).row == 2{
            UIPasteboard.general.url = URL(string: self.contentUrl)
            showToast(message: NSLocalizedString("Link copied.",comment: ""), controller: self)
        }
        
    }
}

extension BlogDetailViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
        cell.textLabel?.textColor = UIColor.darkGray
        cell.textLabel?.text = ShareOption[(indexPath as NSIndexPath).row]
        return cell
    }
}

extension BlogDetailViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicatorView.stopAnimating()
        self.detailWebView.isHidden = false
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
            
        default:
            break
        }
        
        
        decisionHandler(.allow)
    }
}


