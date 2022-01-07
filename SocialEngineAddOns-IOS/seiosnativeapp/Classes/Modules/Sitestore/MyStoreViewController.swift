//
//  MyStoreViewController.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 22/09/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class MyStoreViewController: UIViewController, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate{
    
    let scrollView = UIScrollView()
    var menuOption:UIButton!
    var orderOrDownloads:Bool!
    var myorderTableView:UITableView!
    var orderArr = [AnyObject]()
    var info:UILabel!
    var viewOptionArr = NSArray()
    var CurrencySymbol = String()
    var responseCache = [String:AnyObject]()
    var pageNumber:Int = 1
    let limit:Int = 20
    var updateScrollFlag = true
    var showSpinner = true 
    var isPageRefresing = false
    var totalItems:Int = 0
    var tag:Int = 0
    // MARK: Load view
    override func viewDidLoad()
    {
        super.viewDidLoad()
        removeMarqueFroMNavigaTion(controller: self)
        orderOrDownloads = true
        view.backgroundColor = bgColor
        createScrollableStoreMenu()
        setupView()

        BrowseOrders()
        // Do any additional setup after loading the view.
    }
   
    func setupView()
    {
        
        myorderTableView = UITableView(frame: CGRect(x:0, y:ButtonHeight+TOPPADING, width:view.bounds.width, height:view.bounds.height-(ButtonHeight+TOPPADING) - tabBarHeight), style:.grouped)
        myorderTableView.register(MyOrderTableViewCell.self, forCellReuseIdentifier: "Cell")
        myorderTableView.rowHeight = 70
        myorderTableView.dataSource = self
        myorderTableView.delegate = self
        myorderTableView.isOpaque = false
        myorderTableView.backgroundColor = UIColor.white//tableViewBgColor
        myorderTableView.separatorColor = TVSeparatorColorClear
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            myorderTableView.estimatedRowHeight = 0
            myorderTableView.estimatedSectionHeaderHeight = 0
            myorderTableView.estimatedSectionFooterHeight = 0
        }
        self.view.addSubview(myorderTableView)
        
        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        myorderTableView.tableFooterView = footerView
        myorderTableView.tableFooterView?.isHidden = true
        
        // Message when records not available
        self.info = createLabel(CGRect(x:10,y:UIScreen.main.bounds.height/2,width:self.view.bounds.width-20 , height:42), text: NSLocalizedString("You do not have any product in order.",  comment: "") , alignment: .center, textColor: textColorMedium)
        self.info.numberOfLines = 0
        self.info.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.info.backgroundColor = bgColor
        self.info.tag = 1000
        self.info.isHidden = true
        self.view.addSubview(self.info)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
       // super.viewWillDisappear(true)
        myorderTableView.tableFooterView?.isHidden = true
    }
    override func viewWillAppear(_ animated: Bool)
    {
        removeNavigationViews(controller: self)
        navigationSetUp()

    }
    @objc func goBack()
    {
         _ = self.navigationController?.popViewController(animated: false)
    }
    // MARK: Navigation setup
    func navigationSetUp()
    {
        self.navigationController?.navigationBar.isHidden = false
        setNavigationImage(controller: self)
        self.title = NSLocalizedString("My Orders", comment: "")
        if tabBarController != nil{
            baseController?.tabBar.items?[self.tabBarController!.selectedIndex].title = nil
        }

        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))

        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(MyStoreViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
    }
    // Mark: Scrolable menu
    func createScrollableStoreMenu(){
        openMenu = false
        scrollView.frame = CGRect(x:0, y:TOPPADING, width:view.bounds.width, height:ButtonHeight)
        scrollView.delegate = self
        scrollView.tag = 2;
        var menuWidth = CGFloat()
        
        
        var listingMenu = [NSLocalizedString("My Orders", comment: ""), NSLocalizedString("My Downloads", comment: "")]
        var origin_x:CGFloat = 0.0
        menuWidth = CGFloat((view.bounds.width)/2)
        for i in 100 ..< 102
        {
            menuOption =  createNavigationButton(CGRect(x:origin_x, y:ScrollframeY, width:menuWidth, height:ButtonHeight), title:String(format: NSLocalizedString("\(listingMenu[(i-100)])", comment: ""), "Stores"), border: true, selected: false)
            
            if i == 100{
                menuOption.setSelectedButton()
            }else{
                menuOption.setUnSelectedButton()
            }
            menuOption.tag = i
            menuOption.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZEMedium)
            menuOption.addTarget(self, action:#selector(MyStoreViewController.menuSelectOptions), for: .touchUpInside)
            menuOption.backgroundColor =  UIColor.clear//textColorLight
            menuOption.alpha = 1.0
            scrollView.addSubview(menuOption)
            origin_x += menuWidth
            
        }
        scrollView.contentSize = CGSize(width:menuWidth * 3,height:ScrollframeY)
        scrollView.bounces = false
        scrollView.isUserInteractionEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = UIColor.clear
        scrollView.isDirectionalLockEnabled = true;
        scrollView.backgroundColor = UIColor.clear
        self.view.addSubview(scrollView)
        
        self.scrollView.alwaysBounceHorizontal = false
        self.scrollView.alwaysBounceVertical = false
        
        
    }
 
    // Called when options from tabs are choosen.
    @objc func menuSelectOptions(sender: UIButton)
    {
        let menuBrowseType = sender.tag - 100
        scrollView.isUserInteractionEnabled = false
        if menuBrowseType == 0
        {
            orderOrDownloads = true
            orderArr.removeAll(keepingCapacity: false)
            pageNumber = 1
            showSpinner = true
            
        }
        else if menuBrowseType == 1
        {
            orderOrDownloads = false
            orderArr.removeAll(keepingCapacity: false)
            pageNumber = 1
            showSpinner = true
        }
        myorderTableView.reloadData()
        for ob in scrollView.subviews{
           
            if ob.isKind(of:UIButton.self){
                if ob.tag >= 100 && ob.tag <= 104
                {
                    (ob as! UIButton).setUnSelectedButton()
                    
                    if ob.tag == sender.tag
                    {
                        (ob as! UIButton).setSelectedButton()
                    }
                }
                
            }
        }
        BrowseOrders()
        
    }
    // MARK: Tableview Delegates
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        
        return 70
        
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return orderArr.count
    }
    
    // Set Cell of TabelView
    func tableView( _ _tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let dic = orderArr[indexPath.row]
        let cell = myorderTableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath)as! MyOrderTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.backgroundColor = UIColor.white//tableViewBgColor
        cell.btnView.tag = indexPath.row
        cell.labremaings.isHidden = true
        cell.labdownloads.isHidden = true
        cell.btnView.isHidden = false
        cell.labstatus.isHidden = false
        cell.labdate.isHidden = false
        cell.labstatus.isHidden = false
        
        cell.btnView.setTitle(NSLocalizedString("View", comment: ""), for: UIControl.State.normal)
        if orderOrDownloads == true
        {
            let orderid = dic["order_id"] as! Int
            cell.labOrderID.text = String(format: NSLocalizedString("Order No #%@", comment: ""),"\(orderid)")
            if let orderDate = dic["creation_date"] as? String
            {
                
                let date = dateDifferenceWithEventTime(orderDate)
                var DateC = date.components(separatedBy: ",")
                var tempInfo = "\(DateC[1]) \(DateC[0]) \(DateC[2])"
                if DateC.count > 3{
                    tempInfo += " at \(DateC[3])"
                    cell.labdate.text = "\(tempInfo)"
                }
            }
            
            if let order_status = dic["order_status"] as? String
            {
                cell.labstatus.text = "\(order_status)"
            }
            if let orderprice = dic["order_total"] as? Double
            {
                let value = "\(self.CurrencySymbol)" + "\(orderprice)"
                if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
                    let defaults = UserDefaults.standard
                    if let name = defaults.object(forKey: "Currency")
                    {
                        let price = gettwoFractionDigits(FractionDigit: "\(orderprice)")
                        let changePrice = (defaults.object(forKey: "PriceRate") as! Float) * Float(price)!
                        let showPrice = (String(format:"%.2f", changePrice))
                        
                        cell.labPrice.text =  "\(getCurrencySymbol(name as! String)) \(showPrice)"
                        
                    }
                }
                else{
                    cell.labPrice.text = "\(value)"
                }
               // cell.labPrice.text = "\(value)"
            }
            if let _ = dic["options"] as? NSMutableArray{
                
                
                cell.btnView.alpha = 1.0
                cell.btnView.addTarget(self, action: #selector(MyStoreViewController.showViewOptions), for: .touchUpInside)
            }
            else
            {
                
                cell.btnView.alpha = 0.5
            }
        }
        else
        {
            cell.labdate.isHidden = true
            cell.labremaings.isHidden = false
            cell.labdownloads.isHidden = false
            cell.btnView.isHidden = true
            cell.labstatus.isHidden = true
            
            let orderid = dic["order_id"] as! Int
            cell.labPrice.text = String(format: NSLocalizedString("Order No #%@", comment: ""),"\(orderid)")
            if let title = dic["title"] as? String
            {
                
                cell.labOrderID.text = "\(title)"
                
            }
            if let downloads = dic["downloads"] as? Int
            {
                cell.labdownloads.text = String(format: NSLocalizedString("%@ Downloads", comment: ""),"\(downloads)")
                cell.labdownloads.sizeToFit()
            }
            if let remainingDownloads = dic["remainingDownloads"] as? Int
            {
                cell.labremaings.frame = CGRect(x:cell.labdownloads.frame.origin.x+10+cell.labdownloads.frame.size.width,y:cell.labdownloads.frame.origin.y,width:(UIScreen.main.bounds.width-100) , height:cell.labdownloads.frame.size.height)
                cell.labremaings.text = String(format: NSLocalizedString("%@ Remaining Downloads", comment: ""),"\(remainingDownloads)")
                cell.labdownloads.sizeToFit()
            }
            if let str = dic["option"] as? String{
                
                let isurl = verifyUrl(str)
                if isurl == true
                {
                    cell.btnView.isHidden = false
                    cell.labstatus.isHidden = true
                    cell.btnView.setTitle(NSLocalizedString("Download", comment: ""), for: UIControl.State.normal)
                    cell.btnView.addTarget(self, action: #selector(MyStoreViewController.downloadAction), for: .touchUpInside)
                }
                else
                {
                    cell.btnView.isHidden = true
                    cell.labstatus.isHidden = false
                    cell.labstatus.text = "\(str)"
                }
                
            }
            else
            {
                
                cell.btnView.isHidden = false
                cell.labstatus.isHidden = true
                cell.btnView.setTitle(NSLocalizedString("Download", comment: ""), for: UIControl.State.normal)
                cell.btnView.addTarget(self, action: #selector(MyStoreViewController.downloadAction), for: .touchUpInside)
                
            }
        }
        
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 0.0001
        
    }
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
    
    // MARK: - View options
    @objc func showViewOptions(sender: UIButton)
    {
        var optionDic:NSDictionary!
        optionDic = orderArr[sender.tag] as! NSDictionary
        let oderId = optionDic["order_id"] as! Int
        let oderid = "#"+"\(oderId)"
        if let guttermenu = optionDic["options"] as? NSArray
        {
            self.viewOptionArr = guttermenu
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
            for menu in viewOptionArr{
                if let dic = menu as? NSDictionary{
                    alertController.addAction(UIAlertAction(title: (dic["label"] as! String), style: .default, handler:{ (UIAlertAction) -> Void in
                        let condition = dic["name"] as! String
                        switch(condition)
                        {
                            
                        case "view":
                            
                            let VC = OrderReviewViewController()
                            VC.iscomingFrom = "MYorders"
                            VC.orderId = oderid
                            iscomingfrom = "MYorders"
                            if let url =  dic["url"] as? String
                            {
                                VC.url = "\(url)"
                            }
                            self.navigationController?.pushViewController(VC, animated: true)
                            break
                        case "reorder":
//                            let VC = ManageCartViewController()
//                            VC.iscomingFrom = "MYorders"
//                            iscomingfrom = "MYorders"
                            if let url =  dic["url"] as? String
                            {
                                //VC.url = "\(url)"
                                self.reorderCalling(url: url)
                            }
                            
                            break
                        case "cancel":
                            if let url =  dic["url"] as? String
                            {
                                self.cancelAction(url: "\(url)")
                            }
                        case "shipping":
                            
                            let VC = ContentDetailViewController()
                            if let url =  dic["url"] as? String
                            {
                                VC.url = "\(url)"
                            }
                            self.navigationController?.pushViewController(VC, animated: true)
                            break
                        case "make-payment":
                            if let url =  dic["url"] as? String
                            {
                                let presentedVC = ExternalWebViewController()
                                presentedVC.url = url
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let navigationController = UINavigationController(rootViewController: presentedVC)
                                self.present(navigationController, animated: true, completion: nil)
                            }
                        default:
                            break
                        }
                        
                        
                        
                    }))
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
    }
    
    // MARK: - Server call
    func BrowseOrders()
    {
        if Reachabable.isConnectedToNetwork()
        {
          if (showSpinner){
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            if updateScrollFlag == false
            {
                
                activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height-85 - (tabBarHeight / 4))
            }
            if (self.pageNumber == 1)
            {
                activityIndicatorView.center = view.center
                updateScrollFlag = false
            }
            }
            self.info.isHidden = true
            //Set Parameters & path for Sign Up Form
            var parameters = [String:String]()
            var path = ""
            if orderOrDownloads == true
            {
                path = "sitestore/orders"
            }
            else
            {
                path = "sitestore/orders/downloadable-files"
            }
            parameters = ["page":"\(pageNumber)" , "limit": "\(limit)"]
            if (self.pageNumber == 1)
            {
                if let responseCacheArray = self.responseCache["\(path)"]
                {
                    
                    self.orderArr = responseCacheArray as! [AnyObject]
                    self.myorderTableView.reloadData()
                }
            }
            // Send Server Request for Sign Up Form
            post(parameters, url: path, method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    if self.showSpinner{
                        activityIndicatorView.stopAnimating()
                    }
                    self.showSpinner = false
                    self.updateScrollFlag = true
                    self.scrollView.isUserInteractionEnabled = true
                    //self.refresher.endRefreshing()
                    if msg
                    {
                        
                        if self.pageNumber == 1
                        {
                            self.orderArr.removeAll(keepingCapacity: false)
                        }
                        if let dic = succeeded["body"] as? NSMutableDictionary
                        {
                            if self.orderOrDownloads == true
                            {
                                if let arr = dic["orders"] as? NSMutableArray
                                {
                                    self.orderArr = self.orderArr + (arr as [AnyObject])
                                    
                                }
                                if let StrCurrency = dic["currency"] as? String
                                {
                                    self.CurrencySymbol = getCurrencySymbol(StrCurrency)
                                }
                                if dic["totalItemCount"] != nil
                                {
                                    self.totalItems = dic["totalItemCount"] as! Int
                                }
                                
                            }
                            else
                            {
                                if let arr = dic["downloadablefiles"] as? NSMutableArray
                                {
                                    self.orderArr = arr as [AnyObject] 

                                }
                                
                            }
                            if (self.pageNumber == 1)
                            {
                                self.responseCache["\(path)"] = self.orderArr as AnyObject?
                            }
                            if self.orderArr.count == 0
                            {
                                self.info.isHidden = false
                                if self.orderOrDownloads == false
                                {
                                    self.info.text = NSLocalizedString("You do not have any downloadable products.",  comment: "")
                                }
                                else
                                {
                                    self.info.text = NSLocalizedString("You do not have any product in order.",  comment: "")
                                }
                                
                            }
                            self.isPageRefresing = false
                            self.myorderTableView.reloadData()
                        }
                    }
                    else
                    {
                        if succeeded["message"] != nil
                        {
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                    }
                })
            }
            
        }
        
    }
    // Handle Scroll For Pagination
//    func scrollViewDidScroll(_ scrollView: UIScrollView)
//    {
//        if updateScrollFlag
//        {
//            if myorderTableView.contentOffset.y >= myorderTableView.contentSize.height - myorderTableView.bounds.size.height{
//                if (!isPageRefresing  && limit*pageNumber < totalItems){
//                    if Reachabable.isConnectedToNetwork() {
//                        updateScrollFlag = false
//                        pageNumber += 1
//                        isPageRefresing = true
//                        BrowseOrders()
//                    }
//                }
//
//            }
//
//        }
//
//    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if maximumOffset - currentOffset <= 10
        {
            if updateScrollFlag{
//                if myorderTableView.contentOffset.y >= myorderTableView.contentSize.height - myorderTableView.bounds.size.height{
                    if (!isPageRefresing  && limit*pageNumber < totalItems){
                        if Reachabable.isConnectedToNetwork() {
                            updateScrollFlag = false
                            pageNumber += 1
                            isPageRefresing = true
                            myorderTableView.tableFooterView?.isHidden = false
                            BrowseOrders()
                        }
                    }
                else
                    {
                    myorderTableView.tableFooterView?.isHidden = true
                }
                    
            //    }
                
            }
            
        }
        
    }
    
    // MARK: Action Metod
    func cancelAction(url : String)
    {
        // Check Internet Connection
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
            
            let parameter = [String:String]()
            let method = "POST"
            post(parameter, url: "\(url)", method: method) { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: 
                    {
                        activityIndicatorView.stopAnimating()
                        if msg
                        {
                            if succeeded["message"] != nil
                            {
                                showToast(message: succeeded["message"] as! String, controller: self)
                                
                            }
                            self.BrowseOrders()
                        }
                        else
                        {
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
            showAlertMessage(centerPoint: view.center , msg: network_status_msg , timer: false)
        }
        
    }
    @objc func downloadAction(sender: UIButton)
    {
        var optionDic:NSDictionary!
        optionDic = orderArr[sender.tag] as! NSDictionary
        tag = sender.tag
        if let paramarr = optionDic["option"] as? NSArray
        {
            let dic = paramarr[0] as! NSDictionary
            let url = dic["url"] as! String
            let paramDic = dic["urlparams"] as! NSDictionary
            createUrl(params: paramDic as! Dictionary<String, String>, url: url)
            
        }


    }
    // Generate Custom Alert Messages
    func showAlertMessage( centerPoint: CGPoint, msg: String, timer:Bool)
    {
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
    @objc func stopTimer() {
        stop()
       // if popAfterDelay == true{
            _ = self.navigationController?.popViewController(animated: true)
            
       // }
    }
    func createUrl(params : Dictionary<String, String>, url : String)
    {
        var dic = Dictionary<String, String>()
        if(logoutUser == false)
        {
            dic["oauth_token"] = "\(oauth_token)"
            dic["oauth_secret"] = "\(oauth_secret)"
        }
        dic["oauth_consumer_secret"] = "\(oauth_consumer_secret)"
        dic["oauth_consumer_key"] = "\(oauth_consumer_key)"
        if ios_version != nil && ios_version != "" {
            dic["_IOS_VERSION"] = "\(ios_version)"
        }
        dic["ios"] = "1"
        
        dic["language"] = "\(String(describing: NSLocale.current.languageCode))"
        dic.update(params)
        // Create Request URL
        var finalurl = String()
        finalurl = baseUrl+url+buildQueryString(fromDictionary:dic)
        UIApplication.shared.openURL(NSURL(string: finalurl)! as URL)
        
        // For Downlaod file in document directory
//        let option = orderArr[tag] as! NSDictionary
//        if let audioUrl = NSURL(string: finalurl)
//        {
//            
//            // then lets create your document folder url
////            let  documentsDirectoryURL =  NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
//            let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
//            let documentsDirectory: AnyObject = paths[0]
//            let dataPath = documentsDirectory.stringByAppendingPathComponent("MyFolder")
//            do
//            {
//                try NSFileManager.defaultManager().createDirectoryAtPath(dataPath, withIntermediateDirectories: true, attributes: nil)
//            }
//            catch let error as NSError
//            {
//                //print(error.localizedDescription);
//            }
//            // lets create your destination file url
//            var destinationUrl = NSURL()
//            let documentsDirectoryURL = NSURL(string: dataPath)
//            if let  filename  = option["filename"] as? String
//            {
//                destinationUrl = documentsDirectoryURL!.URLByAppendingPathComponent(filename)
//            }
//            else
//            {
//                destinationUrl = documentsDirectoryURL!.URLByAppendingPathComponent(audioUrl.lastPathComponent!)
//            }
//            //print(destinationUrl)
//            
//            // to check if it exists before downloading it
//            if NSFileManager().fileExistsAtPath(destinationUrl.path!) {
//                //print("The file already exists at path")
//            }
//            else
//            {
//                
//                // you can use NSURLSession.sharedSession to download the data asynchronously
//                NSURLSession.sharedSession().downloadTaskWithURL(audioUrl, completionHandler: { (location, response, error) -> Void in
//                    guard let location = location where error == nil else { return }
//                    do {
//                        // after downloading your file you need to move it to your destination url
//                        try NSFileManager().moveItemAtURL(location, toURL: destinationUrl)
//                        //print("File moved to documents folder")
//                    } catch let error as NSError {
//                        //print(error.localizedDescription)
//                    }
//                }).resume()
//            }
//        }
    }
    func reorderCalling(url : String)
    {
        
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork()
        {
         
//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            var parameter = [String:String]()
            var path = ""
            parameter = ["":""]
            var method = ""
            
            path = "\(url)"
            method = "POST"
            // Send Server Request for Sign Up Form
            post(parameter, url: path, method: "\(method)") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg
                    {
                        let VC = ManageCartViewController()
                        VC.iscomingFrom = "MYorders"
                        iscomingfrom = "MYorders"
                        self.navigationController?.pushViewController(VC, animated: true)
                    }
                    else
                    {
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
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        
    }
    
    
}
