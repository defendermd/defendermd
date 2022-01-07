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
//  TaggingViewController.swift
//  seiosnativeapp
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}


var addfrndTag = false
class TaggingViewController: UIViewController , UISearchBarDelegate ,UITableViewDataSource,UITableViewDelegate{
    var searchBar = UISearchBar()
    var suggestedFrnd = [AnyObject]()
    var searchResultTableView : UITableView!
    var dynamicHeight:CGFloat = 50              // Dynamic Height fort for Cell
    var leftBarButtonItem : UIBarButtonItem!
    var contentType : String = ""
    var photoTagId : Int = 0
    var guid : String!
    var id : Int!
    var Userlabel : String!
    var collect = [NSDictionary]()
    var showType = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addfrndTag = false
        if showType != "Preview"{
        frndTag.removeAll()
        }
        // Do any additional setup after loading the view.
        view.backgroundColor = bgColor
        if contentType == "album_photo"{
            self.title = NSLocalizedString("Tag This Photo",  comment: "")
        }else{
            self.title = NSLocalizedString("Who're you with?",  comment: "")
        }
        
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(TaggingViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        
        searchBar.frame = CGRect(x: 0, y: TOPPADING, width: view.bounds.width, height: 50)
        searchBar.delegate = self
        searchBar.placeholder = NSLocalizedString("Start typing a name...",  comment: "")
        searchBar.backgroundColor = UIColor.clear
        view.addSubview(searchBar)
        for subView in searchBar.subviews  {
            for subsubView in subView.subviews  {
                if let textField = subsubView as? UITextField {
                    textField.textColor = textColorDark
                    textField.font = UIFont(name: fontBold, size: FONTSIZENormal)
                }
            }
        }
        
        
        searchResultTableView = UITableView(frame: CGRect(x: 0, y: getBottomEdgeY(inputView: searchBar), width: view.bounds.width, height: view.bounds.height-(getBottomEdgeY(inputView: searchBar))), style: UITableView.Style.grouped)
        searchResultTableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "Cell")
        searchResultTableView.dataSource = self
        searchResultTableView.delegate = self
        searchResultTableView.rowHeight = 50
        searchResultTableView.backgroundColor = tableViewBgColor
        searchResultTableView.separatorColor = TVSeparatorColor
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            searchResultTableView.estimatedSectionHeaderHeight = 0
            
        }
        view.addSubview(searchResultTableView)
 
        self.edgesForExtendedLayout = UIRectEdge.all;
        self.automaticallyAdjustsScrollViewInsets = false;
        if contentType == "album_photo"{
            friendSearch("")
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        if contentType != "album_photo"{
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
    
    override func viewDidAppear(_ animated: Bool) {
        if contentType == "album_photo"{
            friendSearch("")
        }
        
    }
    
    
    func addFriendTag(){
        if frndTag.count>0{
            
            for (key, _) in frndTag{
                for ob in view.subviews {
                    if ob.tag == key{
                        ob.removeFromSuperview()
                      }
                }
            }
            
            var origin_x:CGFloat = 10
            var origin_y:CGFloat = TOPPADING + 60
            
            let addBlog = UIBarButtonItem(title: "Add", style:.plain , target:self , action: #selector(TaggingViewController.addTag))
            self.navigationItem.rightBarButtonItem = addBlog
            searchResultTableView.frame = CGRect(x: 0, y: 180, width: view.bounds.width, height: (view.bounds.height-180))
            for (key, value) in frndTag{
                // origin_x += 5
                if origin_x + (findWidthByText(value) + 15)  > view.bounds.width{
                    origin_y += 40
                    origin_x = 10
                    searchResultTableView.frame.origin.y += 100
                }
                
                let frndTag = createLabel(CGRect(x: origin_x, y: origin_y, width: (findWidthByText(value) + 15), height: 30), text: " \(value)", alignment: .left, textColor: textColorLight)
                frndTag.backgroundColor = buttonBgColor
                frndTag.tag = key
                view.addSubview(frndTag)
                
                origin_x += frndTag.bounds.width
                
                let cancel = createButton(CGRect( x: origin_x, y: origin_y, width: 30, height: 30), title: "\(cancelFriendIcon)", border: false,bgColor: false, textColor: textColorLight)
                cancel.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
                cancel.tag = key
                cancel.addTarget(self, action: #selector(TaggingViewController.removeFriend(_:)), for: .touchUpInside)
                cancel.backgroundColor = navColor
                view.addSubview(cancel)
                
//                if showType == "Preview"{
//                    cancel.frame.size.width = 0
//                    cancel.frame.size.height = 0
//                    cancel.backgroundColor = UIColor.clear
//                }
//
                origin_x += (cancel.bounds.width+10)
            }
            
        }
    }
    
    
    // MARK:  UISearchBarDelegates

    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.length > 0{
            friendSearch(searchBar.text!)
        }
        self.suggestedFrnd.removeAll(keepingCapacity: false)
        self.searchResultTableView.reloadData()
    }
    
    
    // Handle Simple Search on Search Click
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        // Add search text to searchDic
        if searchBar.text?.length > 0{
            friendSearch(searchBar.text!)
        }
        self.suggestedFrnd.removeAll(keepingCapacity: false)
        self.searchResultTableView.reloadData()
    }
    
    //    // MARK: - Orientation
    //
    //    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
    //        layOutControl()
    //    }
    //
    //
    //    // Reset View Frames On Change Orientation
    //    func layOutControl(){
    //
    //        searchBar.frame.size.width = view.bounds.width - 10
    //        searchResultTableView.frame.size.width = view.bounds.width
    //        searchResultTableView.frame.size.height = (view.bounds.height - searchResultTableView.frame.origin.y)
    //
    //    }
    
    // MARK:  Make server Request
    func friendSearch(_ searchText:String){
        
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
            activityIndicatorView.center = CGPoint(x: view.center.x, y: 140)
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
        //    activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            userInteractionOff = false
            // Send Server Request to Share Content
            post(["search":"\(searchText)", "limit": "10"], url: "/advancedactivity/friends/suggest", method: "GET") { (succeeded, msg) -> () in
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
            showToast(message: network_status_msg, controller: self)
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
        // popViewController After Delay
        //        if popAfterDelay == true {
        //            feedUpdate = true
        //            _ = self.navigationController?.popViewController(animated: true)
        //        }
    }
    
    // MARK:  UITableViewDelegate & UITableViewDataSource
    
    // Set Blog Tabel Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    // Set Blog Tabel Header Height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return dynamicHeight
    }
    
    // Set Blog Section
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
            // Set Feed Owner Image
            if let imgUrl = response["image_icon"] as? String{
                let url = URL(string:imgUrl)
                if url != nil
                {
                    cell.imgUser.image = nil
                    cell.imgUser.kf.indicatorType = .activity
                    (cell.imgUser.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    cell.imgUser.kf.setImage(with: url as URL?, placeholder: UIImage(named : "user_profile_image.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        
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
    
    
    // Handle Blog Table Cell Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        searchBar.resignFirstResponder()
        //self.resignFirstResponder()
        if contentType == "album_photo"{
            if let response = suggestedFrnd[(indexPath as NSIndexPath).row] as? NSDictionary {
                Userlabel = response["label"] as? String
                guid = response["guid"] as? String
                id = response["id"] as? Int
                
                
            }
            self.view.endEditing(true)
            photoTag()
        }
        else{
            if let response = suggestedFrnd[(indexPath as NSIndexPath).row] as? NSDictionary {
                frndTag[(response["id"] as? Int)!] = response["label"] as? String
            }
            
            addFriendTag()
            self.suggestedFrnd.removeAll(keepingCapacity: false)
            self.searchResultTableView.reloadData()
            
        }
        
        
    }
    
    func photoTag(){
        
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
            activityIndicatorView.center = CGPoint(x: view.center.x, y: 140)
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
        //    activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            _ = [String:Int]()
            
            let dictionaryA = [
                "x": 10,
                "y": 20,
                "w": 50,
                "h": 50
                ] as [String : Any]
            
            collect.append(dictionaryA as NSDictionary)
            
            var dic = [String:String]()
            var locationString  = ""
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: dictionaryA, options:  [])
                let  finalString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
                
                
                var tempDic = [String:AnyObject]()
                tempDic.updateValue(finalString as AnyObject, forKey: "tag")
                let Replacefinal = finalString.replacingOccurrences(of: "{", with: "")
                let finalReplace = Replacefinal.replacingOccurrences(of: "}", with: "")
                let finalValue = "\(finalReplace)"
                let templocationString = "{"
                locationString = templocationString + finalValue + "}"
                dic["extra"] = locationString
                
                // success ...
            } catch _ as NSError {
                // failure
                //print("Fetch failed: \(error.localizedDescription)")
            }
             userInteractionOff = false
            
            var params = [String:String]()
            // params.update(dic)
            
            params = ["subject_type":"album_photo" , "subject_id": "\(photoTagId)","guid" : "\(guid!)","id" : String(id),"label" : "\(Userlabel!)","extra":"\(locationString)"]
            // Send Server Request to Share Content
            post(params, url: "tags/add", method: "POST") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    userInteractionOff = true
                    activityIndicatorView.stopAnimating()
                    if msg{
                        // On Success Update
                        if succeeded["message"] != nil{
                            showToast(message: String(format: NSLocalizedString("%@ has been tagged successfully", comment: ""),self.Userlabel!), controller: self)
                        }
                        let triggerTime = (Int64(NSEC_PER_SEC) * 5)
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(triggerTime) / Double(NSEC_PER_SEC), execute: { () -> Void in
                            self.dismiss(animated: true, completion: nil)
                        })
                        
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
    
    
    @objc func removeFriend(_ sender: UIButton){
        frndTag.removeValue(forKey: sender.tag)
        
        for ob in view.subviews{
            if ob.tag == sender.tag{
                ob.removeFromSuperview()
            }
        }
        
        if frndTag.count == 0{
            searchResultTableView.frame = CGRect(x: 0, y: TOPPADING + 50, width: view.bounds.width, height: (view.bounds.height-(TOPPADING + 50)))
            let addBlog = UIBarButtonItem(title: "", style:.plain , target:self , action: #selector(TaggingViewController.addTag))
            self.navigationItem.rightBarButtonItem = addBlog
        }
    }
    @objc func goBack()
    {
        _ = self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: false, completion: nil)
    }
    
    @objc func addTag(){
        addfrndTag = true
        _ = navigationController?.popViewController(animated: true)
        self.dismiss(animated: false, completion: nil)
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
