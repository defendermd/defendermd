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


//  WaitingMemberViewController.swift
//  seiosnativeapp

import UIKit
class WaitingMemberViewController: UIViewController,UITableViewDataSource, UITableViewDelegate, TTTAttributedLabelDelegate {
    
    var gpMemberstableView:UITableView!
    var url1: String!
    var param: NSDictionary!
    var contentType : String = ""
    var allMembers = [AnyObject]()
    var waitingMembers = true
    var pageNumber:Int = 1
    var dynamicHeight:CGFloat = 70
    var totalItem:Int!
    var memberInfo:NSDictionary!
    var optionMenu:UIButton!
    var leftBarButtonItem : UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // self.title = NSLocalizedString("Waiting Members", comment: "")
        view.backgroundColor = bgColor
        waitingMembers = true
        navigationController?.navigationBar.isHidden = false
        
        setNavigationImage(controller: self)
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(WaitingMemberViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        
        gpMemberstableView = UITableView(frame: CGRect(x: 0, y: 0 , width: view.bounds.width, height: view.bounds.height), style: UITableView.Style.plain)
        gpMemberstableView.register(CommentTableViewCell.self, forCellReuseIdentifier: "Cell")
        gpMemberstableView.rowHeight = 65.0
        gpMemberstableView.dataSource = self
        gpMemberstableView.delegate = self
        gpMemberstableView.backgroundColor = tableViewBgColor
        gpMemberstableView.separatorColor = TVSeparatorColor
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            gpMemberstableView.estimatedRowHeight = 0
            gpMemberstableView.estimatedSectionHeaderHeight = 0
            gpMemberstableView.estimatedSectionFooterHeight = 0
        }
        gpMemberstableView.bounces = false
        view.addSubview(gpMemberstableView)
  
        
        param = [:]
        if url1 != nil{
            showMembers(url1, parameter: param)
        }
        
        
        
    }
    
    func showMembers(_ url:String, parameter: NSDictionary){
        
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
            // Set Spinner
//            spinner.center = self.view.center
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            self.view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            
            var dic = Dictionary<String, String>()
            //            for (key, value) in parameter{
            //
            //                if let id = value as? NSNumber {
            //                    dic["\(key)"] = String(id as! Int)
            //                }
            //
            //                if let receiver = value as? NSString {
            //                    dic["\(key)"] = receiver
            //                }
            //            }
            
            dic["limit"] = "\(limit)"
            dic["page"] = "\(pageNumber)"
            dic["menu"] = "1"
            
            
            
            if pageNumber == 1{
                allMembers.removeAll(keepingCapacity: false)
                gpMemberstableView.reloadData()
            }
            
            // Set Parameters for Search
            if searchDic.count > 0 {
                dic.merge(searchDic)
            }
            
            if waitingMembers {
                
                dic["waiting"] = "1"
                
                
                
                // Send Server Request to Share Content
                post(dic, url: url, method: "GET") { (succeeded, msg) -> () in
                    
                    DispatchQueue.main.async(execute: {
                        activityIndicatorView.stopAnimating()
                        if msg{
                            
                            if succeeded["message"] != nil{
                                showToast(message: succeeded["message"] as! String, controller: self)
                            }
                            
                            if succeeded["body"] != nil{
                                
                                
                                if let body = succeeded["body"] as? NSDictionary{
                                    
                                    if let members = body["members"] as? NSArray{
                                        self.allMembers = self.allMembers + (members as [AnyObject])
                                    }
                                    //self.totalItem = body["getTotalItemCount"] as! Int
                                    if self.waitingMembers{
                                        
                                        let memberCount = body["getWaitingItemCount"] as! Int
                                        self.title = NSLocalizedString("Waiting Members (\(memberCount))", comment: "")
                                    }
                                    
                                    // Reload Table on Getting Data from Server
                                    self.gpMemberstableView.reloadData()
                                }
                            }
                            
                        }else{
                            // Handle Server Side Error
                            if succeeded["message"] != nil{
                                showToast(message: succeeded["message"] as! String, controller: self)
                            }
                        }
                    })
                }
            }
            else{
                self.title = NSLocalizedString("Waiting Members (0)", comment: "")
                activityIndicatorView.stopAnimating()
                showToast(message: " No waiting member found in this group", controller: self)
                _ = self.navigationController?.popViewController(animated: false)
            }
        }else{
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self)
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return dynamicHeight
    }
    
    // Set Tabel Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (limit*pageNumber < allMembers.count){
            return 80
        }else{
            return 0.001
        }
    }
    
    // Set Table Header Height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    // Set Table Section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return allMembers.count
    }
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CommentTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        memberInfo = allMembers[(indexPath as NSIndexPath).row] as! NSDictionary
        cell.author_photo.frame = CGRect(x: 5,y: 5,width: 60,height: 60)
        
        // Set Name People who Likes Content
        if (self.contentType == "group"){
            cell.author_title.frame = CGRect(x: cell.author_photo.bounds.width+10, y: 25, width: self.view.bounds.width-(cell.author_photo.bounds.width+15), height: 100)
        }
        else{
            cell.author_title.frame = CGRect(x: cell.author_photo.bounds.width+10, y: 9, width: self.view.bounds.width-(cell.author_photo.bounds.width+15), height: 100)
        }
        cell.author_title.delegate = self
        if memberInfo["displayname"] != nil {
            cell.author_title.text = (memberInfo["displayname"] as! String)//String(describing: memberInfo["displayname"])
        }
        cell.author_title.sizeToFit()
        cell.author_title.font = UIFont(name: fontName, size: FONTSIZELarge)
        
        let length =  NSString(string: (memberInfo["displayname"] as! String)).length
        let userId = memberInfo["user_id"] as! Int
        cell.author_title.addLink(toTransitInformation: [ "type" : "user", "user_id" : userId  ], with:NSMakeRange(0,length));
        
        cell.author_title.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.author_title.sizeToFit()
        cell.imageButton.addTarget(self, action: #selector(WaitingMemberViewController.showProfile(_:)), for: UIControl.Event.touchUpInside)
        cell.imageButton.tag = userId
        
        cell.staff.isHidden = true
        
        
        cell.status.isHidden = true
        
        
        // In Case of Event Check for RSVP
        cell.comment_date.isHidden = true
        if contentType == "event" || contentType == "advancedevents"{
            
            
            
            if let rsvp = memberInfo["rsvp"] as? Int{
                switch(rsvp){
                case 0:
                    cell.comment_date.text = NSLocalizedString("Not Attending", comment: "")
                case 1:
                    cell.comment_date.text = NSLocalizedString("May be Attending", comment: "")
                case 2:
                    cell.comment_date.text = NSLocalizedString("Attending", comment: "")
                case 3:
                    cell.comment_date.text = NSLocalizedString("Awaiting Reply", comment: "")
                default:
                    print("error")
                }
                cell.comment_date.frame.origin.x = cell.author_title.frame.origin.x
                cell.comment_date.frame.origin.y = cell.status.frame.origin.y + cell.status.bounds.height + 2
                cell.comment_date.isHidden = false
                cell.comment_date.textColor = textColorMedium
            }
        }
        
        
        // cell.delete.isHidden = true
        
        
        
        cell.option1.isHidden = true
        cell.option2.isHidden = true
        
        optionMenu = createButton(CGRect(x: view.bounds.width - 40, y: 20, width: 40, height: cell.bounds.height-20), title: "\u{f141}", border: false, bgColor: false, textColor: textColorDark)
        optionMenu.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZEExtraLarge)
        optionMenu.addTarget(self, action: #selector(WaitingMemberViewController.showMenu(_:)), for: .touchUpInside)
        optionMenu.tag = (indexPath as NSIndexPath).row
        if logoutUser != true {
            
            cell.accessoryView = optionMenu
        }
        
        if (memberInfo["menu"] as? NSArray != nil){
            optionMenu.isHidden = false
        }
        else{
            optionMenu.isHidden = true
            
        }
        
        // Set Owner Image
        let url = URL(string: memberInfo["image"] as! NSString as String)
        if url != nil
        {
            cell.author_photo.kf.indicatorType = .activity
            (cell.author_photo.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
            cell.author_photo.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                
            })
        }

        return cell
    }
    
    @objc func showMenu(_ sender:UIButton){
        
        var confirmationTitle = ""
        
        var message = ""
        var url = ""
        var param: NSDictionary = [:]
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        //       let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let currentRow = sender.tag
        
        memberInfo = allMembers[currentRow] as! NSDictionary
        if (memberInfo["menu"] as? NSArray != nil){
            //            optionMenu.isHidden = false
            
            if let menu = memberInfo["menu"] as? NSArray{
                
                for i in 0 ..< menu.count {
                    if let menuOption = menu[i] as? NSDictionary{
                        alertController.addAction(UIAlertAction(title: (menuOption["label"]! as! String), style: .default, handler:{ (UIAlertAction) -> Void in
                            let condition = menuOption["name"]! as! String
                            switch(condition){
                            case "remove_member":
                                contentFeedUpdate = true
                                
                                confirmationTitle = NSLocalizedString("Remove Member", comment: "")
                                message = NSLocalizedString("Are you sure you want to remove this member from the \(self.contentType)?", comment: "")
                                url = menuOption["url"] as! String
                                param = (menuOption["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                            case "make_officer":
                                confirmationTitle = NSLocalizedString("Promote Member", comment: "")
                                message = NSLocalizedString("Are you sure you want to promote this member to officer?", comment: "")
                                url = menuOption["url"] as! String
                                param = (menuOption["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                
                            case "demote_officer":
                                confirmationTitle = NSLocalizedString("Demote Member", comment: "")
                                message = NSLocalizedString("Are you sure you want to demote this member from officer?", comment: "")
                                url = menuOption["url"] as! String
                                param = (menuOption["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                
                            case "cancel_invite":
                                if self.allMembers.count == 1{
                                    self.waitingMembers = false
                                }
                                
                                confirmationTitle = NSLocalizedString("Cancel Invite Request", comment: "")
                                 if self.contentType == "advancedevents" || self.contentType == "event"{
                                    message = NSLocalizedString("Would you like to cancel your request for an invite to this event", comment: "")
                                }
                                 else{
                                    message = NSLocalizedString("Would you like to cancel your request for an invite to this \(self.contentType)", comment: "")
                                }
                                url = menuOption["url"] as! String
                                param = (menuOption["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                            case "approved_member":
                                contentFeedUpdate = true
                                
                                if self.allMembers.count == 1{
                                    self.waitingMembers = false
                                }
                                if self.contentType == "advancedevents" || self.contentType == "event"{
                                    
                                    confirmationTitle = NSLocalizedString("Approve Event Membership Request", comment: "")
                                    message = NSLocalizedString("Would you like to approve the request for membership in this event?", comment: "")
                                }
                                else if self.contentType == "sitegroup"{
                                    
                                    confirmationTitle = NSLocalizedString("Approve Advanced Group Membership Request", comment: "")
                                    message = NSLocalizedString("Would you like to approve the request for membership in this Advanced Group?", comment: "")
                                }
                                else{
                                    confirmationTitle = NSLocalizedString("Approve Group Membership Request", comment: "")
                                    message = NSLocalizedString("Would you like to approve the request for membership in this group?", comment: "")
                                }
                                url = menuOption["url"] as! String
                                param = (menuOption["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                            case "reject_member":
                                if self.allMembers.count == 1{
                                    self.waitingMembers = false
                                }
                                if self.contentType == "advancedevents" || self.contentType == "event"{
                                    confirmationTitle = NSLocalizedString("Reject Event Invitation", comment: "")
                                    message = NSLocalizedString("Would you like to reject the invitation to this group?", comment: "")
                                }
                                else{
                                    confirmationTitle = NSLocalizedString("Reject Group Invitation", comment: "")
                                    message = NSLocalizedString("Would you like to reject the invitation to this group?", comment: "")
                                }
                                url = menuOption["url"] as! String
                                param = (menuOption["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                            default:
                                
                                print("error")
                                
                                
                            }
                            displayAlertWithOtherButton(confirmationTitle, message: message, otherButton: confirmationTitle) { () -> () in
                                self.updateMembers(param as NSDictionary,url1: url)
                            }
                            
                            self.present(alert, animated: true, completion: nil)
                            
                            
                        }))
                        
                    }
                    
                }
                
                
                
            }
            if  (UIDevice.current.userInterfaceIdiom == .phone){
                alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .cancel, handler:nil))
            }else if  (UIDevice.current.userInterfaceIdiom == .pad){
                // Present Alert as! Popover for iPad
                alertController.modalPresentationStyle = UIModalPresentationStyle.popover
                let popover = alertController.popoverPresentationController
                popover?.sourceView = UIButton()
                popover?.sourceRect = CGRect(x: view.bounds.height/2, y: view.bounds.width/2 , width: 1, height: 1)
                popover?.permittedArrowDirections = UIPopoverArrowDirection()
            }
            
            self.present(alertController, animated:true, completion: nil)
        }
    }
    
    func updateMembers(_ parameter: NSDictionary , url1 : String){
        
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
            
            var method:String
            
            if self.contentType == "advancedevents"{
                if url1.range(of: "remove") != nil || url1.range(of: "reject") != nil{
                    method = "DELETE"
                }else{
                    method = "POST"
                }
                
            }
            else{
                if url1.range(of: "remove") != nil{
                    method = "DELETE"
                }else{
                    method = "POST"
                }
            }
            
            
            // Send Server Request to Explore Blog Contents with Blog_ID
            post(dic, url: "\(url1)", method: method) { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        // On Success Update Blog Detail
                        // Update Blog Detail
                        
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        advGroupDetailUpdate = true
                        if self.url1 != "" {
                            self.showMembers(self.url1, parameter: self.param)
                        }
                        
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
            showToast(message: network_status_msg, controller: self)
        }
        
    }
    
    @objc func showProfile(_ sender: UIButton){
        
        let presentedVC = ContentActivityFeedViewController()
        presentedVC.subjectType = "user"
        presentedVC.subjectId = "\(sender.tag)"
        presentedVC.fromActivity = false
        searchDic.removeAll(keepingCapacity: false)
        self.navigationController?.pushViewController(presentedVC, animated: false)
        
    }
    
    @objc func goBack(){
        _ = self.navigationController?.popViewController(animated: false)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}
