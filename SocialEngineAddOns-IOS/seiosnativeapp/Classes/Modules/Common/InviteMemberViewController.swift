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
//  InviteMemberViewController.swift
//  seiosnativeapp

import UIKit


class InviteMemberViewController: UIViewController , UITextViewDelegate, UITextFieldDelegate, UITableViewDataSource,UITableViewDelegate{
    
    var inviteTable:UITableView!
    var checkedInfo:[Bool]!
    var selectAll:Bool!
    var allSelect:String = ""
    var headerDescription = ""
    var users: NSDictionary = [:]
    var usersKey: NSArray = []
    var userID = [AnyObject]()
    var popAfterDelay:Bool!
    var url: String!
    var param: NSDictionary!
    var contentType:String!
    var contentIcon : UILabel!
    var info:UILabel!
    var leftBarButtonItem : UIBarButtonItem!
    var invitePeople = [Int:String]()
    var toLabelText : UITextField!
    var suggestedFrnd = [AnyObject]()
    var searchResultTableView : UITableView!
    var dynamicHeight:CGFloat = 50              // Dynamic Height fort for Cell
    var displayNameLabel = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        invitePeople.removeAll(keepingCapacity: false)
        if (contentType == "group"){
            self.title = NSLocalizedString("Invite Members", comment: "")
        }
        else{
            self.title = NSLocalizedString("Invite Guests", comment: "")
        }
        
        // Do any additional setup after loading the view.
        view.backgroundColor = bgColor
        
        popAfterDelay = false
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(InviteMemberViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        let menu = UIBarButtonItem(title: "Send", style:.plain , target:self , action: #selector(InviteMemberViewController.preSendInvitation))
        self.navigationItem.rightBarButtonItem = menu
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        contentIcon = createLabel(CGRect(x: 0,y: 0,width: 0,height: 0), text: "", alignment: .center, textColor: textColorMedium )
        view.addSubview(contentIcon)
        contentIcon.isHidden = true
        
        toLabelText = createTextField(CGRect(x: PADING, y: TOPPADING, width: view.bounds.width - (2 * PADING ), height: 40), borderColor: borderColorClear , placeHolderText: "Invite Members", corner: true)
        toLabelText.attributedPlaceholder = NSAttributedString(string: "Invite Members", attributes: [NSAttributedString.Key.foregroundColor: placeholderColor])
        toLabelText.becomeFirstResponder()
        toLabelText.addTarget(self, action: #selector(InviteMemberViewController.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        toLabelText.font =  UIFont(name: fontName, size: FONTSIZELarge)
        toLabelText.backgroundColor = bgColor
        toLabelText.delegate = self
        toLabelText.layer.masksToBounds = true
        view.addSubview(toLabelText)
        
        searchResultTableView = UITableView(frame: CGRect(x: PADING, y: TOPPADING + 40, width: view.bounds.width - PADING, height: view.bounds.height-120), style: UITableView.Style.grouped)
        searchResultTableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "Cell")
        searchResultTableView.dataSource = self
        searchResultTableView.delegate = self
        searchResultTableView.rowHeight = 50
        searchResultTableView.backgroundColor = tableViewBgColor
        view.addSubview(searchResultTableView)
        
        self.edgesForExtendedLayout = UIRectEdge.all;
        self.automaticallyAdjustsScrollViewInsets = false;
     
    }
    
    
    
    @objc func preSendInvitation(){
        if url != nil{
            var dic = Dictionary<String, String>()
            for (key, value) in param{
                if let id = value as? NSNumber {
                    dic["\(key)"] = String(id as! Int)
                }
                
                if let receiver = value as? NSString {
                    dic["\(key)"] = receiver as String
                }
            }
            var myDynamicArray:[Int] = []
            for (key, _) in invitePeople{
                myDynamicArray.append(key)
            }
            var str : String = ""
            for i in stride(from: 0, through: (myDynamicArray.count - 1), by: 1){
                if i == (myDynamicArray.count - 1){
                    str += "\(myDynamicArray[i])"
                }
                else {
                    str += "\(myDynamicArray[i]),"
                }
            }
            dic ["user_ids"] = "\(str)"
            sendInvition(url, parameter: dic)
        }
    }
    
    func sendInvition(_ url:String, parameter: Dictionary<String, String>){
        
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
            toLabelText.resignFirstResponder()
            // Send Server Request to Explore Group Contents with Group_ID
            post(parameter, url: url, method: "POST") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    
                    if msg{
                        
                        if succeeded["message"] != nil{
                            self.view.endEditing(true)
                            showToast(message: succeeded["message"] as! String, controller: self)
                            let triggerTime = (Int64(NSEC_PER_SEC) * 4)
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(triggerTime) / Double(NSEC_PER_SEC), execute: { () -> Void in
                            self.popAfterDelay = true
                            _ = self.navigationController?.popViewController(animated: true)
                            })
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
    
    
    @objc func removeFriend(_ sender: UIButton){
        invitePeople.removeValue(forKey: sender.tag)
        for ob in view.subviews{
            if ob.tag == sender.tag{
                ob.removeFromSuperview()
            }
        }
        if(invitePeople.count == 0){
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    // MARK:  UITableViewDelegate & UITableViewDataSource
    
    // Set Message Recipients Tabel Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    // Set Message Recipients Tabel Header Height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return dynamicHeight
    }
    
    // Set Message Recipients Section
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
            // Set Message Owner Image
            if let imgUrl = response["image_icon"] as? String{
                let url = URL(string:imgUrl)
                if url != nil
                {
                    cell.imgUser.image = nil
                    cell.imgUser.kf.indicatorType = .activity
                    (cell.imgUser.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    cell.imgUser.kf.setImage(with: url as URL?, placeholder: UIImage(named : "default_blog_image.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        
                    })
                }
            }
            
            if let id = response["id"] as? Int{
                if invitePeople[id] != nil{
                    cell.accessoryType = UITableViewCell.AccessoryType.checkmark
                }else{
                    cell.accessoryType = UITableViewCell.AccessoryType.none
                }
            }
            
        }
        return cell
    }
    
    
    // Handle Message Recipients Table Cell Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let response = suggestedFrnd[(indexPath as NSIndexPath).row] as? NSDictionary {
            invitePeople[(response["id"] as? Int)!] = response["label"] as? String
            displayNameLabel = (response["label"] as? String)!
        }
        addFriendTag()
        self.toLabelText.text = ""
        self.suggestedFrnd.removeAll(keepingCapacity: false)
        self.searchResultTableView.reloadData()
        
    }
    // MARK: Add Tag Of Contacts
    func addFriendTag(){
        if invitePeople.count>0{
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            for (key, _) in invitePeople{
                for ob in view.subviews {
                    if ob.tag == key{
                        ob.removeFromSuperview()
                    }
                }
            }
            var origin_x:CGFloat = PADING
            var origin_y:CGFloat = TOPPADING+35
            searchResultTableView.frame = CGRect(x: 0, y: 140 , width: view.bounds.width, height: (view.bounds.height - 140))
            for (key, value) in invitePeople{
                if origin_x + (findWidthByText(value) + 15)  > view.bounds.width{
                    origin_y += 25
                    origin_x = PADING
                    searchResultTableView.frame.origin.y += 50
                }
                let frndTags = createLabel(CGRect(x: origin_x , y: origin_y, width: (findWidthByText(value) + 5), height: 20), text: " \(value)", alignment: .left, textColor: textColorLight)
                frndTags.backgroundColor = navColor
                frndTags.font = UIFont(name: fontName, size: FONTSIZESmall)
                frndTags.tag = key
                view.addSubview(frndTags)
                origin_x += frndTags.bounds.width
                let cancel = createButton(CGRect( x: origin_x, y: origin_y, width: 20, height: 20), title: "\(cancelFriendIcon)", border: false,bgColor: false, textColor: textColorLight)
                cancel.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
                cancel.tag = key
                cancel.addTarget(self, action: #selector(InviteMemberViewController.removeFriend(_:)), for: .touchUpInside)
                cancel.backgroundColor = buttonBgColor
                view.addSubview(cancel)
                origin_x += (cancel.bounds.width+5)
            }
        }
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        
        if(self.toLabelText.text != ""){
            friendSearch(self.toLabelText.text!)
        }
        else{
            self.searchResultTableView.isHidden = true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true;
        
    }
    
    func friendSearch(_ searchText:String){
        
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
            activityIndicatorView.center = CGPoint(x: view.center.x, y: view.center.y/3)
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
        //    activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            userInteractionOff = false
            var parameters = [String:String]()
            var urlList = ""
            
            parameters = ["search":"\(searchText)", "limit": "5"]
            urlList = "advancedactivity/friends/suggest"
            
            
            // Send Server Request to Share Content
            post(parameters, url: urlList, method: "GET") { (succeeded, msg) -> () in
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
                                
                                if (self.suggestedFrnd.count > 0){
                                    
                                    self.searchResultTableView.isHidden = false
                                }
                                else{
                                    
                                    self.searchResultTableView.isHidden = true
                                }
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
            showAlertMessage(view.center , msg: network_status_msg, timer:false )
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
        if popAfterDelay == true {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func goBack()
    {
        _ = self.navigationController?.popViewController(animated: true)
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
