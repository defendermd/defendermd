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
//  AddRemoveStickersViewController.swift
//  seiosnativeapp
//

import UIKit
class AddRemoveStickersViewController: UIViewController,TTTAttributedLabelDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var stickersTableView : UITableView!   // To Show Stickers
    var dic : NSDictionary!
    var dynamicHeight : CGFloat = 75
    var url:String!
    var stickerImageView : UIImageView!
    var stictersArray :  NSArray = []
    var totalItems : Int = 0
    var imageCache = [String:UIImage]()
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
        
        stickerImageView = createImageView(CGRect(x: 0, y: TOPPADING - 6, width: view.bounds.width, height: 100), border: true)
        stickerImageView.image = UIImage(named: "stickers_store")
        view.addSubview(stickerImageView)
        
        
        stickersTableView = UITableView(frame: CGRect(x: 0,y: stickerImageView.frame.origin.y + stickerImageView.frame.size.height, width: view.bounds.width, height: view.bounds.height - (stickerImageView.frame.origin.y + stickerImageView.frame.size.height)), style: .grouped)
        stickersTableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "Cell")
        stickersTableView.estimatedRowHeight = 75.0
        stickersTableView.dataSource = self
        stickersTableView.delegate = self
        stickersTableView.rowHeight = UITableViewAutomaticDimension
        stickersTableView.backgroundColor = tableViewBgColor
        stickersTableView.separatorColor = TVSeparatorColor
        view.addSubview(stickersTableView)
        getStickers()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if commentsUpdate == true{
            getStickers()
        }
    }
    
    //MARK: Get All Stickers and set In Table View
    func  getStickers(){
        // Check Internet Connection
        if reachability.isReachable {
            removeAlert()
            // Send Server Request for Comments
            let dic = Dictionary<String, String>()
            
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
                                    self.stictersArray = stickerArray
                                    self.totalItems = self.stictersArray.count
                                    self.stickersTableView.reloadData()
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
    
    // Set Sticker Tabel Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (totalItems > 0){
            return 80
            
        }else{
            return 0.00001
        }
    }
    
    // Set Sticker Tabel Header Height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return dynamicHeight
    }
    
    // Set Sticker Section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return stictersArray.count
    }
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let row = (indexPath as NSIndexPath).row
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.blue
        cell.backgroundColor = tableViewBgColor
        
        var stickersInfo:NSDictionary
        stickersInfo = stictersArray[(indexPath as NSIndexPath).row] as! NSDictionary
        
        cell.imgUser.contentMode = .scaleAspectFill
        cell.imgUser.frame = CGRect(x: 5, y: 7, width: 60, height: 60)
        // Set Sticker Title
        cell.labTitle.frame = CGRect(x: cell.imgUser.bounds.width + 10, y: 10,width: (UIScreen.main.bounds.width - 75) , height: 100)
        cell.labTitle.text = stickersInfo["title"] as? String
        cell.labTitle.numberOfLines = 2
        cell.labTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.labTitle.font = UIFont(name: fontName, size: FONTSIZENormal)
        cell.labTitle.sizeToFit()
        if let stickersCount = stickersInfo["sticker_count"] as? Int {
            cell.labMessage.frame = CGRect(x: cell.imgUser.bounds.width + 10, y: cell.labTitle.frame.origin.y + cell.labTitle.bounds.height + 5,width: (UIScreen.main.bounds.width - 75) , height: 100)
            var totalStickersCount = ""
            totalStickersCount = String(format: NSLocalizedString("%@ Stickers", comment: ""),"\(stickersCount)")
            cell.labMessage.setText(totalStickersCount, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                return mutableAttributedString
            })
        }
        cell.labMessage.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.labMessage.sizeToFit()
        cell.labMessage.font = UIFont(name: fontName, size: FONTSIZESmall)
        // Set Sticker Owner Image
        if stickersInfo["image_icon"] != nil{
            let icon = stickersInfo["image_icon"]
            let url = URL(string:icon as! String)
            downloadData(url!, downloadCompleted: { (downloadedData, msg) -> () in
                if msg{
                    let image: UIImage  = UIImage(data: downloadedData)!
                    cell.imgUser.image = image
                }
            })
        }
        if stickersInfo["isAdded"] != nil{
            let alredyAdded = stickersInfo["isAdded"] as? Int
            if alredyAdded == 1 {
                let optionMenu = createButton(CGRect(x: view.bounds.width - 45, y: 0, width: 45, height: cell.bounds.height), title: "\u{f068}", border: false, bgColor: false, textColor: UIColor.blue)
                optionMenu.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZESmall)
                optionMenu.addTarget(self, action: #selector(AddRemoveStickersViewController.addOrRemoveSticker(_:)), for: .touchUpInside)
                optionMenu.tag = row
                cell.accessoryView = optionMenu
            }
            else{
                let optionMenu = createButton(CGRect(x: view.bounds.width - 45, y: 0, width: 45, height: cell.bounds.height), title: "\u{f067}", border: false, bgColor: false, textColor: UIColor.blue)
                optionMenu.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZESmall)
                optionMenu.addTarget(self, action: #selector(AddRemoveStickersViewController.addOrRemoveSticker(_:)), for: .touchUpInside)
                optionMenu.tag = row
                cell.accessoryView = optionMenu
            }
        }
        return cell
    }
    
    
    // Handle Sticker Table Cell Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        var stickersInfo:NSDictionary
        var collectionIdOfParticularSticker : Int!
        stickersInfo = stictersArray[(indexPath as NSIndexPath).row] as! NSDictionary
        
        if stickersInfo["collection_id"] != nil {
            collectionIdOfParticularSticker = stickersInfo["collection_id"] as? Int
            let presentedVC = StickersDetailsViewController()
            presentedVC.collectionId = collectionIdOfParticularSticker
            navigationController?.pushViewController(presentedVC, animated: false)
        }
        
    }
    
    //MARK: Add or Remove Stickers
    func addOrRemoveSticker(_ sender: UIButton){
        var url = ""
        var dic1 = Dictionary<String, String>()
        var stickersInfo:NSDictionary
        var collectionId : Int!
        var addOrRemoveValue = false
        var order : Int = 0
        stickersInfo = stictersArray[sender.tag] as! NSDictionary
        collectionId = stickersInfo["collection_id"] as? Int
        order = (stickersInfo["order"] as? Int)!
        if let sticterMenu = stickersInfo["menu"] as? NSArray{
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
                            sticterArray.add(stickersInfo)
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
