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

class AdvHostMemberViewController: UIViewController, TTTAttributedLabelDelegate, UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource {
    
    // Variable for classified Detail Form
    var classifiedIcon : UIButton!
    var classifiedTitle: UILabel!
    var categoryIcon : UILabel!
    var contentImage: String!
    
    var classifiedName:String!
    var hostId:Int!
    var classifiedDescription : UILabel!
    var popAfterDelay:Bool!
    var deleteclassifiedEntry:Bool!
    var classifiedInfo : TTTAttributedLabel!
    var imageScrollView: UIImageView!
    var profileFieldLabel : TTTAttributedLabel!
    var menuItems: NSDictionary = [:]
    var ownerId : Int!
    var ownerType : String!
    var gutterMenu: NSArray = []
    
    var mainSubView:UIView!
    var coverImage:UIImageView!
    var coverImageUrl : String!
    
    var ownerName: UILabel!
    var ownerImage : UIImageView!
    var  totalPic : TTTAttributedLabel!
    var topView : UIView!
    var imgUser : UIImageView!
    var descriptionShareContent:String!
    
    var categoryView : UIView!
    
    var categoryName : TTTAttributedLabel!
    var categoryImage : UIImageView!
    
   
    
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
   // var menu : UIButton!
    // var menu1 : UIButton!
    var hostResponse = [AnyObject]()
    var OwnerId : Int!
    var ownerTitle : String!
    var hostEventCount : Int!
    var tabsContainerMenu:UIScrollView!
    var eventCount : Int!
    var param: NSDictionary!
    var infourl: String!
    var userinfoTableView1:UITableView!
    var count1 : Int = 0
    var dic : NSDictionary!
    var dynamicHeight : CGFloat = 30
    var response:NSDictionary!
    var contentview : UIView!
    //For Rating
    var ratingView : UIView!
    
    var rated: Bool!
    var contentdescription: String!
    var leftBarButtonItem : UIBarButtonItem!
    // Initialize Class Object
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        searchDic.removeAll(keepingCapacity: false)
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        removeNavigationImage(controller: self)
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(AdvHostMemberViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem


        
        userinfoTableView1 = UITableView(frame: CGRect(x: 0,y: 0, width: view.bounds.width, height: view.bounds.height), style: .grouped)
        userinfoTableView1.register(UserInfoTableViewCell.self, forCellReuseIdentifier: "Cell")
        userinfoTableView1.estimatedRowHeight = 30.0
        userinfoTableView1.rowHeight = UITableView.automaticDimension
        userinfoTableView1.backgroundColor = tableViewBgColor
        userinfoTableView1.separatorStyle = UITableViewCell.SeparatorStyle.none
        userinfoTableView1.isScrollEnabled = true
        userinfoTableView1.contentInset = UIEdgeInsets(top: -TOPPADING, left: 0, bottom: 0, right: 0)
        //userinfoTableView1.backgroundColor = UIColor.blue
        view.addSubview(userinfoTableView1)
       
        
        if(UIDevice.current.userInterfaceIdiom == .pad){
            mainSubView = createView(CGRect(x: 0, y: 0, width: view.bounds.width, height: 370), borderColor: borderColorDark, shadow: false)
        }else{
            mainSubView = createView(CGRect(x: 0,y: 0, width: view.bounds.width, height: 270), borderColor: borderColorLight, shadow: false)
            mainSubView.layer.borderWidth = 0.0
        }
        //        mainSubView.isHidden = true
        mainSubView.backgroundColor = placeholderColor
        userinfoTableView1.addSubview(mainSubView)
        
        coverImage =   CoverImageViewWithGradient(frame:CGRect(x: 0, y: 0, width: mainSubView.bounds.width, height: mainSubView.bounds.height))
        
        coverImage.contentMode = UIView.ContentMode.scaleAspectFill
        coverImage.layer.masksToBounds = true
        coverImage.backgroundColor = placeholderColor
        coverImage.isUserInteractionEnabled = true
        
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(AdvHostMemberViewController.onImageViewTap))
        coverImage.addGestureRecognizer(tap1)
        
        mainSubView.addSubview(coverImage)
        
        contentview = createView(CGRect(x: 0, y: coverImage.bounds.height-45, width: view.bounds.width, height: 115), borderColor: UIColor.clear, shadow: false)
        contentview.backgroundColor = UIColor.clear
        coverImage.addSubview(contentview)
        
        
        
        classifiedTitle = createLabel(CGRect(x: contentPADING, y: 0, width: mainSubView.bounds.width - (2 * contentPADING), height: 40), text: "", alignment: .left, textColor: textColorLight)
        classifiedTitle.font = UIFont(name: fontBold, size: 30)
        classifiedTitle.numberOfLines = 3
        classifiedTitle.layer.shadowColor = shadowColor.cgColor
        classifiedTitle.layer.shadowOpacity = shadowOpacity
        classifiedTitle.layer.shadowRadius = shadowRadius
        classifiedTitle.layer.shadowOffset = shadowOffset
        contentview.addSubview(classifiedTitle)

        
        tabsContainerMenu = UIScrollView(frame: CGRect(x: 0, y: coverImage.frame.origin.y + coverImage.bounds.height,width: view.bounds.width ,height: ButtonHeight ))
        tabsContainerMenu.delegate = self
        tabsContainerMenu.backgroundColor = TabMenubgColor
        tabsContainerMenu.isHidden = true
        userinfoTableView1.addSubview(tabsContainerMenu)
        
        
        exploreHost()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        removeNavigationImage(controller: self)
        userinfoTableView1.reloadData()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
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
            _ = navigationController?.popViewController(animated: true)
        }
    }
    func showtabMenu(){
        var origin_x:CGFloat = 0
        for menu in tabMenu{
            if let menuItem = menu as? NSDictionary{
                
                var button_title = menuItem["label"] as! String
                if let totalItem = menuItem["totalItemCount"] as? Int{
                    if totalItem > 0{
                        button_title += " (\(totalItem))"
                    }
                }
                let width = findWidthByText(button_title) + 10
                let menu = createNavigationButton(CGRect(x: origin_x,y: 0 ,width: width , height: tabsContainerMenu.bounds.height) , title: button_title, border: true, selected: false)
                
                if origin_x == 0 {
                    menu.setSelectedButton()
                }
                else{
                    menu.setUnSelectedButton()
                }
                
                menu.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZENormal)
                menu.tag = 101
                menu.addTarget(self, action: #selector(AdvHostMemberViewController.tabMenuAction(_:)), for: .touchUpInside)
                menu.backgroundColor = textColorclear
                tabsContainerMenu.addSubview(menu)
                origin_x += width
                
            }
        }
        
        tabsContainerMenu.contentSize = CGSize(width: origin_x, height: tabsContainerMenu.bounds.height)
        
    }
    
    @objc func tabMenuAction(_ sender:UIButton){
        for menu in tabMenu{
            if let menuItem = menu as? NSDictionary{
                var button_title = menuItem["label"] as! String
                if let totalItem = menuItem["totalItemCount"] as? Int{
                    if totalItem > 0{
                        button_title += " (\(totalItem))"
                    }
                }
                if sender.titleLabel?.text == button_title{
                    
                    
                    
                    if menuItem["name"] as! String == "organizer_events"{
                        let presentedVC = AdvancedEventViewController()
                        presentedVC.showOnlyMyContent = true
                        
                        let a = menuItem["urlParams"] as! NSDictionary
                       // presentedVC.param = menuItem["urlParams"] as! NSDictionary
                        
                        var host_type : String!
                        var host_id : Int
                        host_type = a["host_type"] as! String
                        host_id = a["host_id"] as! Int
                        presentedVC.hostCheckType = host_type
                        presentedVC.hostCheckId = host_id
                       // presentedVC.user_id = subjectId
                        presentedVC.fromTab = true
                        navigationController?.pushViewController(presentedVC, animated: true)
                        
                    }
                    
                    
                }
            }
        }
    }
    
  
    // Handle Menu Action
    
    
    // MARK: - Server Connection For classified Updation
    
    // Explore classified Detail
    func exploreHost(){
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
            
            // Send Server Request to Explore classified Contents with classified_ID
    
              post ([ : ], url: "advancedevents/organizer/\(hostId!)", method: "GET") { (succeeded, msg) -> () in
                    
                    DispatchQueue.main.async(execute: {
                        activityIndicatorView.stopAnimating()
                        if msg{
                            
                            
                            if let classified = succeeded["body"] as? NSDictionary
                            {
                                self.response = classified
                                // self.hostEventCount = classified["getTotalItemCount"] as! Int
                                if let menu = classified["profileTabs"] as? NSArray
                                {
                                    tabMenu = menu
                                    self.tabsContainerMenu.isHidden = false
                                    self.showtabMenu()
                                }
                                
                                for tempMenu in self.hostResponse{
                                    
                                    if let tempDic = tempMenu as? NSDictionary{
                                        self.ownerId = tempDic["owner_id"] as! Int
                                        self.ownerTitle = tempDic["owner_title"] as! String

                                    }
                                    
                                }
                                
                                for menu in tabMenu
                                {
                                    if let menuItem = menu as? NSDictionary
                                    {
                                        if menuItem["name"] as! String == "organizer_info"
                                        {
                                            self.infourl = menuItem["url"] as! String
                                            self.param = menuItem["urlParams"] as! NSDictionary
                                            self.GetInfo()

                                        }
                                    }
                                }
                                
                                self.classifiedTitle.text = classified["title"] as? String
                                let url1 = URL(string:classified["image_profile"] as! String)!
                                self.coverImageUrl = classified["image_profile"] as! String
                                self.userImage = url1
                                self.coverImage.kf.indicatorType = .activity
                                (self.coverImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                self.coverImage.kf.setImage(with: url1, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                    
                                })
                                self.coverImage.isHidden = false
                                
                            }
                        }
                })
                
            }
        }
        else
        {
            // No Internet Connection Message
            showAlertMessage(view.center , msg: network_status_msg , timer: false)
        }
        
    }
    
    func GetInfo()
    {
        if Reachabable.isConnectedToNetwork()
        {
            removeAlert()
//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            // Send Server Request to Explore Blog Contents with Blog_ID
            post(["getInfo":"1"], url: infourl, method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg
                    {
                        self.dic = succeeded["body"] as! NSDictionary
                        self.count1 = self.dic.count
                        self.userinfoTableView1.dataSource = self
                        self.userinfoTableView1.delegate = self
                        self.userinfoTableView1.reloadData()

                    }
                })
                
            }
        }
        else
        {
            // No Internet Connection Message
            showAlertMessage(view.center , msg: network_status_msg , timer: false)
        }

    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {

      return (tabsContainerMenu.bounds.height + tabsContainerMenu.frame.origin.y - 20)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        

        return dynamicHeight
    }
    
    // Set no. of sections in TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Set Title of Header in Section
    
    // Set no. of rows in Every section of TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return count1
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UserInfoTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.label2.backgroundColor = UIColor.clear
        cell.backgroundColor =  UIColor.clear
        var subChild = [AnyObject]()
        var subValue = [AnyObject]()
        var array3 = [String]()
        for (key,value) in dic
        {
           
            if key as! String  != "description"
            {
                let keyString = key as! String + " : "
                array3.append(keyString)
                subChild.append(keyString as AnyObject)
                subValue.append(value as AnyObject )
            }
            else
            {
               contentdescription = String(describing: value)
            }
 
        }
        if contentdescription != nil
        {
            array3.append("Description :")
            subChild.append("Description :" as AnyObject)
            subValue.append(contentdescription as AnyObject)
        }

        let value = subChild[(indexPath as NSIndexPath).row] as? String
        if value == "total_rating"
        {
            cell.label1?.text = "Total Rating"
            ratingView = createView(CGRect(x: cell.label2.frame.origin.x, y: cell.label2.frame.origin.y+5, width: 75, height: 10), borderColor: UIColor.clear, shadow: false)
            ratingView.backgroundColor = UIColor.clear
            cell.addSubview(ratingView)
            if let rating = subValue[(indexPath as NSIndexPath).row] as? Int
            {
                self.rated = true
                self.updateRating(rating, ratingCount: (subValue[(indexPath as NSIndexPath).row] as? Int)!)
                
            }
            
        }
        else
        {
            
            cell.label1?.text = subChild[(indexPath as NSIndexPath).row] as? String
            cell.label2.numberOfLines = 0
            cell.label2.lineBreakMode = NSLineBreakMode.byWordWrapping
            cell.label2?.text =  String(describing: subValue[(indexPath as NSIndexPath).row])
            cell.label2.sizeToFit()
            
            }
        dynamicHeight = 30
        if dynamicHeight < (cell.label2.frame.origin.y + cell.label2.bounds.height + 5)
        {
            dynamicHeight = (cell.label2.frame.origin.y + cell.label2.bounds.height + 10)
        }
        return cell
        
    }
    // MARK:Rating Function
    func updateRating(_ rating:Int, ratingCount:Int)
    {
        
        
        for ob in ratingView.subviews
        {
            ob.removeFromSuperview()
        }
        
        var origin_x = 0 as CGFloat
        
        for i in stride(from: 1, through: 5, by: 1){
            let rate = createButton(CGRect(x: origin_x, y: 0, width: 10, height: 10), title: "", border: false, bgColor: false, textColor: textColorLight)
            rate.backgroundColor = UIColor.clear
            rate.setImage(UIImage(named: "graystar.png"), for: UIControl.State() )
            
            if rated == false
            {
                rate.tag = i
                rate.addTarget(self, action: Selector(("rateAction:")), for: .touchUpInside)
            }
            else
            {
                if i <= rating
                {
                    rate.setImage(UIImage(named: "yellowStar.png"), for: UIControl.State() )
                }
                
            }
            origin_x += 12
            ratingView.addSubview(rate)
        }
        
        
        var totalRated = ""
        totalRated = singlePluralCheck( NSLocalizedString(" rating", comment: ""),  plural: NSLocalizedString(" ratings", comment: ""), count: ratingCount)
        
        let ratedInfo = createLabel(CGRect(x: (ratingView.center.x - 50), y: 30,width: 75 , height: 17),text: totalRated, alignment: .center, textColor: textColorMedium)
        ratedInfo.font = UIFont(name: fontName, size:FONTSIZESmall)
        ratedInfo.isHidden = true
        ratingView.addSubview(ratedInfo)
    }

    // MARK:  TTTAttributedLabelDelegate
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        //UIApplication.shared.openURL(url!)
        let presentedVC = ExternalWebViewController()
        presentedVC.url = url.absoluteString
        presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        let navigationController = UINavigationController(rootViewController: presentedVC)
        self.present(navigationController, animated: true, completion: nil)

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
    
    
    
     
    @objc func onImageViewTap()
    {
        if self.coverImageUrl != nil && self.coverImageUrl != "" {
            let presentedVC = SinglePhotoLightBoxController()
            presentedVC.imageUrl = self.coverImageUrl
            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            let nativationController = UINavigationController(rootViewController: presentedVC)
            present(nativationController, animated:false, completion: nil)
        }
    }
    
    
    @objc func goBack()
        
    {
        
        _ = self.navigationController?.popViewController(animated: false)
        
    }
    
    func openProfile(){
        if (self.ownerId != nil){
            let presentedVC = ContentActivityFeedViewController()
            presentedVC.subjectType = "user"
            presentedVC.subjectId = "\(self.ownerId!)"
            searchDic.removeAll(keepingCapacity: false)
            self.navigationController?.pushViewController(presentedVC, animated: false)
        }
    }
    func shareItem(){
        for menu in gutterMenu{
            if let dic = menu as? NSDictionary{
                if dic["name"] as! String == "share"{
                    
                    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
                    alertController.addAction(UIAlertAction(title:  NSLocalizedString("Share in App",comment: ""), style: .default) { action -> Void in
                        
                        let pv = AdvanceShareViewController()
                        pv.url = dic["url"] as! String
                        pv.param = (dic["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                        pv.Sharetitle = self.classifiedName
                        pv.ShareDescription = ""
                        if (self.descriptionShareContent != nil) {
                            pv.ShareDescription = self.descriptionShareContent!
                        }
                        pv.imageString = self.contentImage
                        pv.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                        let nativationController = UINavigationController(rootViewController: pv)
                        self.present(nativationController, animated:true, completion: nil)

                        
                        })
                    
                    if (self.contentUrl != nil && self.contentUrl != ""){
                        
                        alertController.addAction(UIAlertAction(title:  NSLocalizedString("Share External",comment: ""), style: UIAlertAction.Style.default) { action -> Void in
                            
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
                            
                            
                            if(activityViewController.popoverPresentationController != nil) {
                                activityViewController.popoverPresentationController?.sourceView = self.view;
                                let frame = UIScreen.main.bounds
                                activityViewController.popoverPresentationController?.sourceRect = frame;
                            }
                            
                            self.present(activityViewController, animated: true, completion: nil)
                            
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
                    
                }}}
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
