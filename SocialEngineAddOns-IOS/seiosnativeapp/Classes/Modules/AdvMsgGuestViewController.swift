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
//  AdvMsgGuestViewController.swift
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



class AdvMsgGuestViewController: UIViewController , UISearchBarDelegate ,UITableViewDataSource,UITableViewDelegate, UITextViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate{
    var searchBar = UISearchBar()
    var suggestedFrnd = [AnyObject]()
    var searchResultTableView : UITableView!
    var dynamicHeight:CGFloat = 50              // Dynamic Height fort for Cell
    var subjectLabelText : UITextField!
    var contentLabelText : UITextView!
    var submitButton : UIButton!
    var toLabelText : UITextField!
    
    var sendMsg : UIBarButtonItem!
    
    var friendListView : UIScrollView!
    var border = CALayer()
    var reportType : UIButton!
    var reportTypeDictionary: NSDictionary = [:]
    var eventOccurrence : UIButton!
    var eventOccurrenceDictionary: NSDictionary = [:]
    var url : String!
    var guid : String!
    var param: NSDictionary = [:]
    var guestSelect = ""
    var checkfrndsTag = ""
    var allMembers = [AnyObject]()
    var cancel = UIButton()
    var frndTags = UILabel()
    var isoccurrening = "no"
    var occurrence_id = ""
    var addfrndTags1 = false
    var leftBarButtonItem : UIBarButtonItem!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        addfrndTags1 = false
        // Do any additional setup after loading the view.
        view.backgroundColor = bgColor
        
        navigationController?.navigationBar.isHidden = false
        setNavigationImage(controller: self)
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(AdvMsgGuestViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem

        
        self.title = NSLocalizedString("Compose Message",  comment: "")
        
        
        reportType = createButton(CGRect(x: 0, y: 69, width: view.bounds.width, height: 30),title: "All Guests", border: false,bgColor: false, textColor: textColorMedium)
        
        reportType.addTarget(self, action: #selector(AdvMsgGuestViewController.reportTypeAction), for: .touchUpInside)
        reportType.backgroundColor = lightBgColor
        reportType.isHidden = true
        
        reportType.titleLabel?.font = UIFont(name: fontName, size: FONTSIZENormal)
        
        view.addSubview(reportType)

        let filterIcon = createLabel(CGRect(x: reportType.bounds.width - reportType.bounds.height, y: 0 ,width: reportType.bounds.height ,height: reportType.bounds.height), text: "\u{f107}", alignment: .center, textColor: textColorMedium)
        filterIcon.font = UIFont(name: "fontAwesome", size: FONTSIZELarge)
        reportType.addSubview(filterIcon)
        
        
        toLabelText = createTextField(CGRect(x: PADING, y: reportType.frame.origin.y + reportType.frame.size.height+10, width: view.bounds.width - (2 * PADING ), height: 40), borderColor: borderColorClear , placeHolderText: "Send To", corner: true)
        toLabelText.attributedPlaceholder = NSAttributedString(string: "Send To ", attributes: [NSAttributedString.Key.foregroundColor: placeholderColor])
        toLabelText.addTarget(self, action: #selector(AdvMsgGuestViewController.toLabelTextChange(_:)), for: UIControl.Event.editingChanged)

        toLabelText.font =  UIFont(name: fontName, size: FONTSIZELarge)
        toLabelText.backgroundColor = bgColor
        toLabelText.delegate = self
        toLabelText.isHidden = true
        toLabelText.layer.masksToBounds = true
        view.addSubview(toLabelText)
        
        
        for subView in searchBar.subviews  {
            for subsubView in subView.subviews  {
                if let textField = subsubView as? UITextField {
                    textField.textColor = textColorDark
                    textField.font = UIFont(name: fontBold, size: FONTSIZENormal)
                }
            }
        }
        
        
        searchResultTableView = UITableView(frame: CGRect(x: PADING, y: toLabelText.frame.origin.y + toLabelText.frame.size.height, width: view.bounds.width - PADING, height: view.bounds.height-120), style: UITableView.Style.grouped)
        searchResultTableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "Cell")
        searchResultTableView.dataSource = self
        searchResultTableView.delegate = self
        searchResultTableView.rowHeight = 50
        searchResultTableView.backgroundColor = tableViewBgColor
        //        searchResultTableView.separatorColor = TVSeparatorColor
        view.addSubview(searchResultTableView)
        
        self.edgesForExtendedLayout = UIRectEdge.all;
        self.automaticallyAdjustsScrollViewInsets = false;
        
        
        //        CGRectGetHeight(subjectLabelText.bounds) + subjectLabelText.frame.origin.y
        
        subjectLabelText = createTextField(CGRect(x: PADING, y: reportType.frame.origin.y+reportType.frame.size.height+40, width: view.bounds.width - (2 * PADING ), height: 40), borderColor: borderColorClear , placeHolderText: "Subject", corner: true)
        subjectLabelText.attributedPlaceholder = NSAttributedString(string: "Subject", attributes: [NSAttributedString.Key.foregroundColor: placeholderColor])
        subjectLabelText.font =  UIFont(name: fontName, size: FONTSIZELarge)
        subjectLabelText.delegate = self
        subjectLabelText.backgroundColor = bgColor
        
        let border1 = CALayer()
        let width1 = CGFloat(1.0)
        border1.borderColor = borderColorMedium.cgColor
        border1.frame = CGRect(x: 0, y: width1 + 2, width:  subjectLabelText.frame.size.width, height: 1.0)
        
        border1.borderWidth = width1
        subjectLabelText.layer.addSublayer(border1)
        subjectLabelText.layer.masksToBounds = true
        view.addSubview(subjectLabelText)
        
        
        contentLabelText = createTextView(CGRect(x: PADING, y: subjectLabelText.bounds.height + subjectLabelText.frame.origin.y + 5, width: view.bounds.width - (2*PADING) , height: 100), borderColor: borderColorClear, corner: false )
        contentLabelText.delegate = self
        contentLabelText.isHidden = false
        applyPlaceholderStyle(contentLabelText, placeholderText: "Compose Message")
        // contentLabelText.text = NSLocalizedString("Compose Message",  comment: "")
        contentLabelText.font = UIFont(name: fontName, size: FONTSIZELarge)
        contentLabelText.textColor = placeholderColor
        contentLabelText.backgroundColor = bgColor
        
        contentLabelText.autocorrectionType = UITextAutocorrectionType.no
        
        let border4 = CALayer()
        border4.borderColor = borderColorMedium.cgColor
        border4.frame = CGRect(x: 0, y: width1 + 2, width:  contentLabelText.frame.size.width, height: 1.0)
        border4.borderWidth = width1
        contentLabelText.layer.addSublayer(border4)
        view.addSubview(contentLabelText)
        
        sendMsg = UIBarButtonItem(title: "\u{f1d8}", style: UIBarButtonItem.Style.done , target:self , action: #selector(AdvMsgGuestViewController.send))
        
        
        sendMsg.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "FontAwesome", size: FONTSIZELarge)!], for: UIControl.State())
        self.navigationItem.rightBarButtonItem = sendMsg
        
        
        
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AdvMsgGuestViewController.resignKeyboard))
        tap.delegate = self
        tap.cancelsTouchesInView = false;
        view.addGestureRecognizer(tap)
    
    }

    override func viewDidAppear(_ animated: Bool) {
        reportForm(param as NSDictionary,url: url)
    }
    
    func applyPlaceholderStyle(_ contentLabelText: UITextView, placeholderText: String)
    {
        // make it look (initially) like a placeholder
        contentLabelText.backgroundColor = bgColor
        contentLabelText.text = "Compose Message"
    }
    
    @objc func reportTypeAction(){
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)

        for (_,value) in reportTypeDictionary{

            
            alertController.addAction(UIAlertAction(title: (value as! String), style: .default, handler:{ (UIAlertAction) -> Void in
                self.reportType.setTitle((value as! String), for: UIControl.State())
                
                if value as! String == self.guestSelect{
                    self.frameChange()
                    self.checkfrndsTag = self.guestSelect
                }
                else{
                    self.frameRemain()
                    self.checkfrndsTag = ""
                }
                
                
            }))
        }
        if  (UIDevice.current.userInterfaceIdiom == .phone){
            alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .cancel, handler:nil))
        }else if  (UIDevice.current.userInterfaceIdiom == .pad){
            // Present Alert as! Popover for iPad
            alertController.modalPresentationStyle = UIModalPresentationStyle.popover
            let popover = alertController.popoverPresentationController
            popover?.sourceView = UIButton()
            popover?.sourceRect = CGRect(x: view.bounds.height/2, y: view.bounds.width/2 , width: 1, height: 1)
        }
        self.present(alertController, animated:true, completion: nil)
        
    }
    
    @objc func eventOccurrenceAction(){
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        for (_,value) in eventOccurrenceDictionary{

            
            alertController.addAction(UIAlertAction(title: (value as! String), style: .default, handler:{ (UIAlertAction) -> Void in
                self.eventOccurrence.setTitle((value as! String), for: UIControl.State())
                
            }))
        }
        if  (UIDevice.current.userInterfaceIdiom == .phone){
            alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .cancel, handler:nil))
        }else if  (UIDevice.current.userInterfaceIdiom == .pad){
            // Present Alert as! Popover for iPad
            alertController.modalPresentationStyle = UIModalPresentationStyle.popover
            let popover = alertController.popoverPresentationController
            popover?.sourceView = UIButton()
            popover?.sourceRect = CGRect(x: view.bounds.height/2, y: view.bounds.width/2 , width: 1, height: 1)
        }
        self.present(alertController, animated:true, completion: nil)
        
    }
    
    
    func reportForm(_ parameter: NSDictionary , url : String){
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
            for (key, value) in parameter{
                
                if let id = value as? NSNumber {
                    dic["\(key)"] = String(id as! Int)
                }
                
                if let receiver = value as? NSString {
                    dic["\(key)"] = receiver as String
                }
            }
            
            // Send Server Request to Report Form with content Type & content ID
            post(dic, url: url, method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    
                    if msg{
                        // On Success Update Report Form
                        
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        
                        if succeeded["body"] != nil{
                            if let response = succeeded["body"] as? NSArray{
                                
                                for formResponseDicElement in response
                                {
                                    let dic = formResponseDicElement as! NSDictionary
                                    let form = dic
                                    for (key, value) in form
                                    {
                                        if key as! String == "type"
                                        {
                                            if value as! String == "Select"{
                                                
                                                if dic["name"] as! String == "guests"
                                                {
                                                    if let menu = dic["multiOptions"] as? NSDictionary
                                                    {
                                                        self.reportTypeDictionary = menu
                                                        
                                                        self.reportType.setTitle(menu["3"] as? String, for: UIControl.State())
                                                        self.guestSelect = (menu["4"] as? String)!
                                                        self.reportType.isHidden = false

                                                    }
                                                }
                                                
                                                if dic["name"] as! String == "occurrence_id"
                                                {
                                                    if let menu = dic["multiOptions"] as? NSDictionary
                                                    {

                                                        self.isoccurrening = "yes"
                                                        self.eventOccurrence = createButton(CGRect(x: 0, y: TOPPADING + 5, width: self.view.bounds.width, height: 30),title: "All Guests", border: false,bgColor: false, textColor: textColorMedium)
                                                        
                                                        self.eventOccurrence.addTarget(self, action: #selector(AdvMsgGuestViewController.eventOccurrenceAction), for: .touchUpInside)
                                                        self.eventOccurrence.backgroundColor = lightBgColor
                                                        self.eventOccurrence.isHidden = true
                                                        
                                                        self.eventOccurrence.titleLabel?.font = UIFont(name: fontName, size: FONTSIZENormal)
                                                        self.view.addSubview(self.eventOccurrence)
                                                        
                                                        
                                                        let filterIcon1 = createLabel(CGRect(x: self.eventOccurrence.bounds.width - self.eventOccurrence.bounds.height, y: 0 ,width: self.eventOccurrence.bounds.height ,height: self.eventOccurrence.bounds.height), text: "\u{f107}", alignment: .center, textColor: textColorMedium)
                                                        filterIcon1.font = UIFont(name: "fontAwesome", size: FONTSIZELarge)
                                                        self.eventOccurrence.addSubview(filterIcon1)

                                                        self.reportType = createButton(CGRect(x: 0,y: self.eventOccurrence.frame.origin.y + self.eventOccurrence.frame.size.height+5 , width: self.view.bounds.width, height: 30),title: "All Guests", border: false,bgColor: false, textColor: textColorMedium)
                                                        
                                                        self.reportType.addTarget(self, action: #selector(AdvMsgGuestViewController.reportTypeAction), for: .touchUpInside)
                                                        self.reportType.backgroundColor = lightBgColor
                                                        self.reportType.isHidden = true
                                                        
                                                        
                                                        let filterIcon = createLabel(CGRect(x: self.reportType.bounds.width - self.reportType.bounds.height, y: 0 ,width: self.reportType.bounds.height ,height: self.reportType.bounds.height), text: "\u{f107}", alignment: .center, textColor: textColorMedium)
                                                        filterIcon.font = UIFont(name: "fontAwesome", size: FONTSIZELarge)
                                                        self.reportType.addSubview(filterIcon)
                                                        
                                                        
                                                        self.reportType.titleLabel?.font = UIFont(name: fontName, size: FONTSIZENormal)

                                                        
                                                        self.view.addSubview(self.reportType)
                                                        
                                                        self.searchResultTableView.frame = CGRect(x: PADING, y: self.toLabelText.frame.origin.y + self.toLabelText.frame.size.height, width: self.view.bounds.width - PADING, height: self.view.bounds.height-120)
                                                        
                                                        self.eventOccurrenceDictionary = menu
                                                        
                                                        self.eventOccurrence.setTitle(menu["all"] as? String, for: UIControl.State())
                                                        self.eventOccurrence.isHidden = false
                                                        //self.frameChange()
                                                    }
                                                    
                                                }
                                                
                                            }
                                            
                                        }
                                    }
                                    
                                }
                            }
                        }
                    }else{
                        // Handle Server Side Error
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            // self.popAfterDelay = true
                            
                        }
                        
                    }
                })
            }
        }else{
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self)
        }
        
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool{
        // test if our control subview is on-screen
        if (touch.view == self.sendMsg) {
            return false
        }
        return true // handle the touch
    }

    override func viewWillAppear(_ animated: Bool) {
        addFriendTag()
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
            
            var origin_x:CGFloat = PADING
            var origin_y:CGFloat = reportType.frame.origin.y + reportType.frame.size.height+50
            searchResultTableView.frame = CGRect(x: 0, y: 190, width: view.bounds.width, height: (view.bounds.height-170))
            for (key, value) in frndTag{
                // origin_x += 5
                if origin_x + (findWidthByText2(value) + 15)  > view.bounds.width{
                    origin_y += 35
                    origin_x = 10
                    searchResultTableView.frame.origin.y += 50
                }
                
                frndTags = createLabel(CGRect(x: origin_x , y: origin_y, width: (findWidthByText2(value) + 15), height: 20), text: " \(value)", alignment: .left, textColor: textColorDark)
                
                //frndTags.layer.borderColor = UIColor.clear.cgColor
                frndTags.backgroundColor = buttonBgColor
                frndTags.tag = key
                frndTags.isHidden = false
                view.addSubview(frndTags)
                
                origin_x += frndTags.bounds.width
                
                cancel = createButton(CGRect( x: origin_x, y: origin_y, width: 20, height: 20), title: "\(cancelFriendIcon)", border: false,bgColor: false, textColor: textColorLight)
                cancel.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
                
                //                cancel.setImage(UIImage(named: "icon-remove.png"), forState: .normal)
                cancel.tag = key
                cancel.addTarget(self, action: #selector(AdvMsgGuestViewController.removeFriend(_:)), for: .touchUpInside)
                cancel.backgroundColor = buttonBgColor
                cancel.isHidden = false
                view.addSubview(cancel)
                
                origin_x += (cancel.bounds.width+10)
                
                
                self.subjectLabelText.frame = CGRect(x: PADING, y: origin_y + 20 , width: view.bounds.width - (2 * PADING ), height: 40)
                self.contentLabelText.frame = CGRect(x: PADING, y: subjectLabelText.bounds.height + subjectLabelText.frame.origin.y + 5, width: view.bounds.width - (2*PADING) , height: 100)
                
                //                CGRectGetHeight(subjectLabelText.bounds) + subjectLabelText.frame.origin.y
                
                
                self.contentLabelText.isHidden = false
                self.subjectLabelText.isHidden = false
                
            }
            
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.length > 0{
            friendSearch(searchBar.text!)
        }
        self.suggestedFrnd.removeAll(keepingCapacity: false)
        self.searchResultTableView.reloadData()
    }
    
    // Handle Simple Search on Search Click
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        self.subjectLabelText.isHidden = true
        
        // Add search text to searchDic
        if searchBar.text?.length > 0{
            friendSearch(searchBar.text!)
        }
        self.suggestedFrnd.removeAll(keepingCapacity: false)
        self.searchResultTableView.reloadData()
    }
    // MARK:  Make server Request
    
    func friendSearch(_ searchText:String){
        
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
//            spinner.center = CGPoint(x: view.center.x, y: view.center.y/3)
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            userInteractionOff = false
            // Send Server Request to Share Content
            post(["value" : "\(searchText)","limit": "10","subject" : "\(guid)"], url: "advancedevents/member-suggest", method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    userInteractionOff = true
                    activityIndicatorView.stopAnimating()
                    if msg{
                        // On Success Update
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            //   self.popAfterDelay = true
                        }
                        
                        if succeeded["body"] != nil{
                            
                            //                          let body = succeeded["body"] as? NSDictionary
                            //
                            //                            if let members = body!["members"] as? NSArray{
                            //                                self.allMembers += members
                            
                            
                            //
                            if let response = succeeded["body"] as? NSArray{
                                self.suggestedFrnd = response as [AnyObject]
                                
                                
                                if ( self.suggestedFrnd.count > 0){
                                    self.contentLabelText.isHidden = true
                                    self.subjectLabelText.isHidden = true
                                    self.searchResultTableView.isHidden = false
                                    //                                    self.contentLabelText.isHidden = true
                                    //                                    self.subjectLabelText.isHidden = true
                                }
                                else{
                                    self.contentLabelText.isHidden = false
                                    self.subjectLabelText.isHidden = false
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
                    cell.imgUser.kf.indicatorType = .activity
                    (cell.imgUser.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    cell.imgUser.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        
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
        
        if let response = suggestedFrnd[(indexPath as NSIndexPath).row] as? NSDictionary {
            frndTag[(response["id"] as? Int)!] = response["label"] as? String
        }
        self.toLabelText.text = ""
        addFriendTag()
        
        
        
        self.suggestedFrnd.removeAll(keepingCapacity: false)
        self.searchResultTableView.reloadData()
        
    }
    
    
    @objc func removeFriend(_ sender: UIButton){
        
        
        frndTag.removeValue(forKey: sender.tag)
        
        for ob in view.subviews{
            if ob.tag == sender.tag{
                ob.removeFromSuperview()
            }
        }
        
        if(frndTag.count == 0){
            subjectLabelText.frame.origin.y = TOPPADING+80
            contentLabelText.frame.origin.y =  subjectLabelText.bounds.height + subjectLabelText.frame.origin.y + 5
            frameChange()
        }
        
    }
    
    
    func addTag(){
        addfrndTags1 = true
        _ = navigationController?.popViewController(animated: true)

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func send(){
        
        var errorMsg = ""
        var parameters = [String:String]()
        
        var guest_id = ""
        for (key,_) in reportTypeDictionary{

            
            if reportTypeDictionary["\(key)"] as? String == reportType.titleLabel?.text{
                guest_id = key as! String
            }
        }
        
        if isoccurrening == "yes"
        {
            
            for (key,_) in eventOccurrenceDictionary{
                if eventOccurrenceDictionary["\(key)"] as? String == eventOccurrence.titleLabel?.text{
                    occurrence_id = key as! String
                }
            }
        }
        
        if self.checkfrndsTag == ""{
            if(contentLabelText.text == "" || contentLabelText.text == "Compose Message") {
                errorMsg =  NSLocalizedString("Content can't be empty",  comment: "")
            }
            
        }
        else
        {
            if(contentLabelText.text == ""){
                errorMsg =  NSLocalizedString("Content can't be empty",  comment: "")
                
            }else if frndTag.count == 0{
                errorMsg = NSLocalizedString("No Recipients",  comment: "")
            }
        }
        
        if(errorMsg == ""){
            
            let finalString = "\(loadingIcon)"
            sendMsg.title = finalString
            
            if checkfrndsTag != ""{
                var myDynamicArray:[Int] = []
                
                for (key, _) in frndTag{
                    myDynamicArray.append(key)
                }
                
                var str : String = ""
                for (key, _) in frndTag {
                    str += "\(key)"
                    if key < frndTag.count-1 {
                        str += ","
                    }
                }
                if isoccurrening == "yes"
                {
                    parameters = ["title":"\(subjectLabelText.text!)","body":"\(contentLabelText.text)!","guests":"\(guest_id)","searchGuests": "\(myDynamicArray)","occurrence_id":"\(occurrence_id)"]
                }
                else
                {
                    parameters = ["title":"\(subjectLabelText.text!)","body":"\(contentLabelText.text)!","guests":"\(guest_id)","searchGuests": "\(myDynamicArray)"]
                }
                
                
            }
            else{
                
                if isoccurrening == "yes"
                {
                    parameters = ["title":"\(subjectLabelText.text!)","body":"\(contentLabelText.text)","guests":"\(guest_id)"]
                }
                else
                {
                    parameters = ["title":"\(subjectLabelText.text!)","body":"\(contentLabelText.text)","guests":"\(guest_id)","occurrence_id":"\(occurrence_id)"]
                }
                
            }
            post(parameters, url: url, method: "POST") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    
                    if msg{
                        // On Success Update
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)

                            _ = self.navigationController?.popViewController(animated: true)

                            //self.createTimer(self)
                        }
                        
                        
                    }else{
                        // Handle Server Side Error
                        if succeeded["message"] != nil{
                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: CSToastPositionCenter)
                        }
                    }
                })
            }
        }
        else{
            let alertController = UIAlertController(title: NSLocalizedString("Error",  comment: ""), message:
                errorMsg, preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Dismiss",  comment: ""), style: UIAlertAction.Style.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @objc func toLabelTextChange(_ textField: UITextField){

        
        if(self.toLabelText.text != ""){
            
            friendSearch(textField.text!)
        }
        else{
            self.searchResultTableView.isHidden = true
            self.contentLabelText.isHidden = false
            self.subjectLabelText.isHidden = false
        }
        
    }
    
    
    
    
    ////    extension Array {
    //        func combine(separator: String) -> String{
    //            var str : String = ""
    //            for (idx, item) in enumerate(self) {
    //                str += "\(item)"
    //                if idx < self.count-1 {
    //                    str += separator
    //                }
    //            }
    //            return str
    //        }
    //    }
    
    override func viewWillDisappear(_ animated: Bool) {
        frndTag.removeAll(keepingCapacity: true)
        // searchDic.removeAll(keepingCapacity: false)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //        textField.resignFirstResponder()
        self.view.endEditing(true)
        return true;
        
    }
    
    @objc func resignKeyboard(){
        contentLabelText.resignFirstResponder()
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        if textView.textColor == placeholderColor {
            textView.text = nil
            textView.textColor = textColorDark
        }
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        
        if textView.text.isEmpty{
            self.contentLabelText.text = NSLocalizedString("Compose Message",  comment: "")
            self.contentLabelText.textColor = placeholderColor
        }
        return true
    }
    
    func frameChange(){
        
        
        
        toLabelText = createTextField(CGRect(x: PADING, y: reportType.frame.origin.y + reportType.frame.size.height+10, width: view.bounds.width - (2 * PADING ), height: 40), borderColor: borderColorClear , placeHolderText: "Send To", corner: true)
        toLabelText.attributedPlaceholder = NSAttributedString(string: "Send To ", attributes: [NSAttributedString.Key.foregroundColor: placeholderColor])
        toLabelText.addTarget(self, action: #selector(AdvMsgGuestViewController.toLabelTextChange(_:)), for: UIControl.Event.editingChanged)

        toLabelText.font =  UIFont(name: fontName, size: FONTSIZELarge)
        toLabelText.backgroundColor = bgColor
        toLabelText.delegate = self
        toLabelText.layer.masksToBounds = true
        view.addSubview(toLabelText)
        self.searchResultTableView.frame = CGRect(x: PADING, y: self.toLabelText.frame.origin.y + self.toLabelText.frame.size.height, width: self.view.bounds.width - PADING, height: self.view.bounds.height-120)
        subjectLabelText.frame.origin.y = toLabelText.frame.origin.y+toLabelText.frame.size.height
        
        contentLabelText.frame.origin.y = subjectLabelText.bounds.height + subjectLabelText.frame.origin.y + 5
        
        
    }
    
    func frameRemain(){

        cancel.isHidden = true
        frndTags.isHidden = true
        toLabelText.isHidden = true
        subjectLabelText.frame.origin.y = reportType.frame.origin.y+reportType.frame.size.height+20
        contentLabelText.frame.origin.y = subjectLabelText.bounds.height + subjectLabelText.frame.origin.y + 5

    }
    
    @objc func goBack()
    {
        _ = self.navigationController?.popViewController(animated: false)

        
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
