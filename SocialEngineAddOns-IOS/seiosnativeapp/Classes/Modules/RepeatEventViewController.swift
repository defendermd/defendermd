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

//  RepeatEventViewController.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 18/02/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit

class RepeatEventViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,UITextFieldDelegate
{
    var ReapeatTableview : UITableView!
    var rsvpvalue:String!
    var index : NSInteger!
    var contentType: String!
    var url:String!
    var repeatArr:NSArray!
    var contentGutterMenu: NSArray = []
    
    var CustomView = UIView()
    var BgimageView = UIImageView()
    var innerView:UIView!
    var titlelabel:UILabel!
    var btnalender:UIButton!
    var btncalender1:UIButton!
    var txtstartdate = UITextField()
    var txtendtdate = UITextField()
    var btnfilter:UIButton!
    var btncancel:UIButton!
    var tag:Int!
    var startdate:String!
    var enddate:String!
    var eventid:String!
    var msgurl:String!
    var guid:String!
    var ownerId:Int!
    var mytitle:String!
    var rsvp:String!
    var occurrenceid:Int!
    var leftBarButtonItem : UIBarButtonItem!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barTintColor = UIColor.white
        self.title = NSLocalizedString("Occurrences",  comment: "")
        
        
        contentFeedUpdate = true
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(RepeatEventViewController.cancel))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem

        
        
        ReapeatTableview = UITableView(frame: CGRect(x: 0,y: TOPPADING, width: view.bounds.width, height: view.bounds.height-TOPPADING), style: .grouped)
        ReapeatTableview.register(RepeatEventTableViewCell.self, forCellReuseIdentifier: "Cell")
        ReapeatTableview.estimatedRowHeight = 100.0
        ReapeatTableview.separatorStyle = UITableViewCell.SeparatorStyle.none
        ReapeatTableview.contentInset = UIEdgeInsets(top: -35, left: 0, bottom: 0, right: 0)
        ReapeatTableview.backgroundColor = tableViewBgColor
        self.ReapeatTableview.isOpaque = false
        
        self.view.addSubview(ReapeatTableview)
        
        
        
        
        CustomView.frame = CGRect(x: 0, y: 0, width: (UIScreen.main.bounds.width), height: (UIScreen.main.bounds.height))
        CustomView.backgroundColor = UIColor.clear
        CustomView.isUserInteractionEnabled = true
        CustomView.isHidden = true
        self.view.addSubview(CustomView)
        
        
        BgimageView.frame = CGRect(x: 0, y: 0, width: (UIScreen.main.bounds.width), height: (UIScreen.main.bounds.height))
        BgimageView.alpha = 0.4
        BgimageView.backgroundColor = UIColor.black
        BgimageView.isUserInteractionEnabled = true
        CustomView.addSubview(BgimageView)
        
        innerView = UIView( frame: CGRect(x: (BgimageView.frame.size.width-250)/2, y: (BgimageView.frame.size.height-200)/2,width: 250,height: 200))
        innerView.backgroundColor = UIColor.white
        innerView.isUserInteractionEnabled = true
        CustomView.addSubview(innerView)
        
        
        titlelabel = createLabel(CGRect(x: 0, y: 10, width: innerView.frame.size.width, height: 20), text: "Filter by date", alignment: .left, textColor: textColorDark)
        titlelabel.font = UIFont(name: fontName, size: 16)
        titlelabel.textAlignment = NSTextAlignment.center
        titlelabel.backgroundColor = UIColor.clear
        innerView.addSubview(titlelabel)
        
        
        
        
        
        btnalender = createButton(CGRect(x: 10, y: titlelabel.frame.origin.y+titlelabel.frame.size
            .height+25, width: 25, height: 25), title: "\u{f073}", border: false,bgColor: false,textColor: textColorMedium)
        btnalender.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZELarge)
        btnalender.backgroundColor = UIColor.clear
        innerView.addSubview(btnalender)
        
        
        txtstartdate.frame = CGRect(x: btnalender.frame.origin.x + btnalender.frame.size.height+20, y: titlelabel.frame.origin.y+titlelabel.frame.size
            .height+20,width: 180, height: 40)
        
        txtstartdate.delegate = self
        txtstartdate.tag = 0
        txtstartdate.font =  UIFont(name: fontName, size: FONTSIZEMedium)
        txtstartdate.placeholder = "StartDate"
        txtstartdate.textColor = placeholderColor
        
        
        innerView.addSubview(txtstartdate)
        
        let lineView1 = UIView(frame: CGRect(x: 0,y: self.txtstartdate.frame.origin.y ,width: self.innerView.frame.size.width,height: 1))
        lineView1.layer.borderWidth = 0.5
        lineView1.layer.borderColor = textColorMedium.cgColor
        innerView.addSubview(lineView1)
        
        
        
        btncalender1 = createButton(CGRect(x: 10, y: txtstartdate.frame.origin.y+txtstartdate.frame.size
            .height+5, width: 25, height: 25), title: "\u{f073}", border: false,bgColor: false,textColor: textColorMedium)
        btncalender1.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZELarge)
        btncalender1.backgroundColor = UIColor.clear
        innerView.addSubview(btncalender1)
        
        
        txtendtdate.frame = CGRect(x: btncalender1.frame.origin.x + btncalender1.frame.size.height+20, y: txtstartdate.frame.origin.y+txtstartdate.frame.size
            .height,width: 180, height: 40)
        txtendtdate.tag = 1
        txtendtdate.placeholder = "EndDate"
        txtendtdate.font =  UIFont(name: fontName, size: FONTSIZEMedium)
        txtendtdate.textColor = placeholderColor
        txtendtdate.delegate = self
        innerView.addSubview(txtendtdate)
        
        
        let lineView2 = UIView(frame: CGRect(x: 0,y: self.txtendtdate.frame.origin.y ,width: self.innerView.frame.size.width,height: 1))
        lineView2.layer.borderWidth = 0.5
        lineView2.layer.borderColor = textColorMedium.cgColor
        innerView.addSubview(lineView2)
        
        
        let lineView3 = UIView(frame: CGRect(x: 0,y: self.txtendtdate.frame.origin.y+self.txtendtdate.frame.size.height ,width: self.innerView.frame.size.width,height: 1))
        lineView3.layer.borderWidth = 0.5
        lineView3.layer.borderColor = textColorMedium.cgColor
        innerView.addSubview(lineView3)
        
        
        
        
        btnfilter = createButton(CGRect(x: 30, y: txtendtdate.frame.origin.y+txtendtdate.frame.size
            .height+20,width: 80, height: 30), title: "Filter", border: false,bgColor: false,textColor: textColorLight)
        btnfilter.backgroundColor = navColor
        btnfilter.addTarget(self, action: #selector(RepeatEventViewController.Filter), for: .touchUpInside)
        innerView.addSubview(btnfilter)
        
        
        
        btncancel = createButton(CGRect(x: btnfilter.frame.origin.x+btnfilter.frame.size
            .width+20, y: txtendtdate.frame.origin.y+txtendtdate.frame.size
                .height+20,width: 80, height: 30), title: "cancel", border: false,bgColor: false,textColor: textColorLight)
        btncancel.backgroundColor = navColor
        btncancel.addTarget(self, action: #selector(RepeatEventViewController.SearchCancel), for: .touchUpInside)
        innerView.addSubview(btncancel)
        

        
        exploreContent()
        
        
    }
    
    @objc func cancel()
    {
        
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: UITextfeild delegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
            
            self.innerView.frame = CGRect(x: (self.BgimageView.frame.size.width-250)/2, y: self.innerView.frame.origin.y-20, width: 250, height: 200)
            
            }, completion: { finished in
                
        })
        
        let datePickerView  : UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePicker.Mode.dateAndTime
        textField.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(RepeatEventViewController.handleDatePicker(_:)), for: UIControl.Event.valueChanged)
        tag = textField.tag
        return true
    }
    
    @objc func handleDatePicker(_ sender: UIDatePicker)
    {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if tag == 0
        {
            startdate = dateFormatter.string(from: sender.date)
            let dateFormatter1 = DateFormatter()
            dateFormatter1.dateFormat = "MM/dd/yyyy"
            txtstartdate.text = "Start date : \(dateFormatter1.string(from: sender.date))"
        }
        else
        {
            enddate = dateFormatter.string(from: sender.date)
            let dateFormatter1 = DateFormatter()
            dateFormatter1.dateFormat = "MM/dd/yyyy"
            
            txtendtdate.text  = "End date : \(dateFormatter1.string(from: sender.date))"
        }
        
        
    }
    
    @objc func Filter()
    {
        self.view.endEditing(true)
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
            
            self.innerView.frame = CGRect(x: (self.BgimageView.frame.size.width-250)/2,y: (self.BgimageView.frame.size.height-200)/2, width: 250, height: 200)
            
            }, completion: { finished in
                
        })
        
        CustomView.isHidden = true
        self.exploreContent()
    }
    
    @objc func SearchCancel()
    {
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
            
            self.innerView.frame = CGRect(x: (self.BgimageView.frame.size.width-250)/2,y: (self.BgimageView.frame.size.height-200)/2, width: 250, height: 200)
            
            }, completion: { finished in
                
        })
        self.view.endEditing(true)
        CustomView.isHidden = true
    }
    
    // MARK:  UITableViewDelegate & UITableViewDataSource
    
    // Set Tabel Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        
        return 0.00001
        
    }
    
    // Set Tabel Header Height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 0.00001
    }
    
    // Set TableView Section
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return repeatArr.count
    }
    
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RepeatEventTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.backgroundColor = UIColor.clear
        cell.btnRSVP.tag = (indexPath as NSIndexPath).row
        let dic = repeatArr.object(at: (indexPath as NSIndexPath).row)
        
        let eventDic = dic as! NSDictionary
        if let eventDate = eventDic["starttime"] as? String{
            
            let dateMonth = dateDifferenceWithTime(eventDate)
            var dateArrayMonth = dateMonth.components(separatedBy: ", ")
            if dateArrayMonth.count > 1{
                
                
                cell.lbldate.numberOfLines = 0
                cell.lbldate.text = "\(dateArrayMonth[1])\n\(dateArrayMonth[0])"
                cell.lbldate.textColor = UIColor.white
                cell.lbldate.font = UIFont(name: "FontAwesome", size: 15)
            }
        }
        
        let guestlist = eventDic["totalMembers"] as! Int
        let list = "Guest List (\(guestlist))"
        
        if guestlist > 0
        {
            cell.btnguest.isHidden = false
            cell.btnRSVP.isHidden = false
            cell.lblnoguest.isHidden = true
            cell.btnguest.setTitle("\(list)", for: UIControl.State())
            cell.btnguest.addTarget(self, action: #selector(RepeatEventViewController.showGusetlist(_:)), for: .touchUpInside)
        }
        else
        {
            cell.btnguest.isHidden = true
            cell.btnRSVP.isHidden = true
            cell.lblnoguest.isHidden = false
            
        }
        
        
        if  let _ = eventDic["rsvp"] as? Int
        {
            let rsvp = eventDic["rsvp"] as! Int
            cell.btnRSVP.isHidden = false
            if rsvpvalue == nil
            {
                if rsvp == 0
                {
                    cell.btnRSVP.setTitle("Not Attending", for: UIControl.State())
                }
                else if rsvp == 1
                {
                    cell.btnRSVP.setTitle("Maybe Attending", for: UIControl.State())
                }
                else if rsvp == 2
                {
                    cell.btnRSVP.setTitle("Attending", for: UIControl.State())
                }
                else if rsvp == 3
                {
                    cell.btnRSVP.isHidden = true
                }
                
            }
            else
            {
                cell.btnRSVP.setTitle(rsvpvalue, for: UIControl.State())
            }
        }
        else
        {
            cell.btnRSVP.isHidden = true
        }
        
        
        if let menu = eventDic["menu"] as? NSArray
        {
            self.contentGutterMenu = menu
            cell.btnmenu.addTarget(self, action: #selector(RepeatEventViewController.showMainGutterMenu(_:)), for: .touchUpInside)
            
        }
        
        
        
        
        cell.btnRSVP.addTarget(self, action: #selector(RepeatEventViewController.showFeedFilterOptions(_:)), for: .touchUpInside)
        cell.btnmenu.tag = (indexPath as NSIndexPath).row
        cell.btnmenu.addTarget(self, action: #selector(RepeatEventViewController.showGutterMenuOptions(_:)), for: .touchUpInside)
        cell.btnguest.tag = (indexPath as NSIndexPath).row
        
        return cell
    }
    
    // MARK: - Show Feed Filter Options Action
    // Show Feed Filter Options Action
    @objc func showFeedFilterOptions(_ sender: UIButton)
    {
        // Generate Feed Filter Options Gutter Menu from Server as! Alert Popover
        index = sender.tag as NSInteger
        
        let dic  = repeatArr[index] as! NSDictionary
        occurrenceid = dic["occurrence_id"] as! Int
        let alertController = UIActionSheet(title: "Choose Option", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles:"Attending","maybe Attending", "Not Attending")
        
        alertController.show(in: self.view)
        searchDic.removeAll(keepingCapacity: false)
        
        
    }
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int)
    {
        
        let indexPath = IndexPath(row:index, section: 0)
        switch (buttonIndex)
        {
            
        case 0:
            
            print("cancel")
            
        case 1:
            
            rsvpvalue  = "Attending"
            rsvp = "2"
            self.ReapeatTableview.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
            self.changeRSVP()
            
        case 2:
            
            rsvpvalue  = "maybe Attending"
            rsvp = "1"
            self.ReapeatTableview.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
            self.changeRSVP()
            
            
        case 3:
            
            rsvpvalue  = "Not Attending"
            rsvp = "0"
            self.ReapeatTableview.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
            self.changeRSVP()
            
        default:
            
            print("Default")
            
        }
    }
    
    @objc func showGusetlist(_ sender: UIButton)
    {
        let presentedVC = ShowMembersViewController()
        presentedVC.canInvite = false
        presentedVC.contentType = "advancedevents"
        presentedVC.url = "advancedevents/member/list/\(eventid)"
        presentedVC.param = Dictionary<String, String>() as NSDictionary?
        presentedVC.mytitle = "\((self.mytitle)!)"
        presentedVC.id = eventid
        presentedVC.guid = self.guid
        presentedVC.ownerId = ownerId
        navigationController?.pushViewController(presentedVC, animated: true)
        
        
    }
    
    @objc func showGutterMenuOptions(_ sender: UIButton)
    {
        
    }
    
    @objc func msgGuest()
    {
        let presentedVC = AdvMsgGuestViewController()
        //msgurl = "advancedevents/member/compose/\(eventid)"
        presentedVC.url = msgurl
        presentedVC.guid = self.guid
        self.navigationController?.pushViewController(presentedVC, animated: true)
        
    }
    
    @objc func searchItem()
    {
        CustomView.isHidden = false
    }
    
    @objc func showMainGutterMenu(_ sender: UIButton)
    {
        
        var eventInfo:NSDictionary!
        eventInfo = repeatArr[sender.tag] as! NSDictionary
        if let guttermenu = eventInfo["menu"] as? NSArray
        {
            self.contentGutterMenu = guttermenu as! [Any] as NSArray
            
            var confirmationTitle = ""
            var message = ""
            var url = ""
            var param: NSDictionary = [:]
            var confirmationAlert = true
            
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
            for menu in contentGutterMenu{
                if let menuItem = menu as? NSDictionary{
                    
                    if (menuItem["name"] as! String != "share") && (menuItem["name"] as! String != "videoCreate")
                    {
                        
                        let titleString = menuItem["name"] as! String
                        
                        if ((titleString.range(of: "leave") != nil))
                        {
                            
                            alertController.addAction(UIAlertAction(title: (menuItem["label"] as! String), style: .destructive , handler:{ (UIAlertAction) -> Void in
                                let condition = menuItem["name"] as! String
                                switch(condition){
                                    
                                case "leave":
                                    
                                    confirmationAlert = true
                                    confirmationTitle = NSLocalizedString("Leave Event", comment: "")
                                    message = NSLocalizedString("Would you like to leave this event?", comment: "")
                                    
                                    url = menuItem["url"] as! String
                                    param =  (menuItem["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                    
                                    
                                default:
                                    showToast(message: unconditionalMessage, controller: self)
                                    
                                }
                                
                                if confirmationAlert == true {
                                    displayAlertWithOtherButton(confirmationTitle, message: message, otherButton: confirmationTitle) { () -> () in
                                        self.updateContentAction(param as NSDictionary,url: url)
                                    }
                                    self.present(alert, animated: true, completion: nil)
                                }
                            }))
                            
                            
                        }
                        else
                        {
                            alertController.addAction(UIAlertAction(title: (menuItem["label"] as! String), style: .default, handler:{ (UIAlertAction) -> Void in
                                let condition = menuItem["name"] as! String
                                switch(condition)
                                {
                                    
                                    
                                case "join":
                                    
                                    confirmationAlert = true
                                    confirmationTitle = NSLocalizedString("Join Event", comment: "")
                                    message = NSLocalizedString("Would you like to join this event?", comment: "")
                                    url = menuItem["url"] as! String
                                    param = Dictionary<String, String>() as NSDictionary
                                    param = (menuItem["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                    
                                    
                                case "cancel_invite":
                                    
                                    confirmationAlert = true
                                    confirmationTitle = NSLocalizedString("Cancel Invite", comment: "")
                                    message = NSLocalizedString("Would you like to cancel this event request?", comment: "")
                                    url = menuItem["url"] as! String
                                    param = Dictionary<String, String>() as NSDictionary
                                    param = (menuItem["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                    
                                    
                                case "accept_invite":
                                    
                                    confirmationAlert = true
                                    confirmationTitle = NSLocalizedString("Accept Invite", comment: "")
                                    message = NSLocalizedString("Would you like to accept this event request?", comment: "")
                                    url = menuItem["url"] as! String
                                    param = Dictionary<String, String>() as NSDictionary
                                    param = (menuItem["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                    
                                    
                                case "reject_invite":
                                    
                                    confirmationAlert = true
                                    confirmationTitle = NSLocalizedString("Reject Invite", comment: "")
                                    message = NSLocalizedString("Would you like to reject this event request?", comment: "")
                                    url = menuItem["url"] as! String
                                    param = Dictionary<String, String>() as NSDictionary
                                    param = (menuItem["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                    
                                    
                                case "request_invite":
                                    
                                    confirmationAlert = true
                                    confirmationTitle = NSLocalizedString("Request Event Membership", comment: "")
                                    message = NSLocalizedString("Would you like to request membership in this event?", comment: "")
                                    
                                    url = menuItem["url"] as! String
                                    param = Dictionary<String, String>() as NSDictionary
                                    param = (menuItem["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                    
                                    
                                    
                                case "invite":
                                    
                                    
                                    confirmationAlert = false
                                    let presentedVC = InviteMemberViewController()
                                    presentedVC.contentType = ""
                                    presentedVC.url = menuItem["url"] as! String
                                    presentedVC.param = Dictionary<String, String>() as NSDictionary? //menuItem["urlParams"] as! NSDictionary
                                    self.navigationController?.pushViewController(presentedVC, animated: false)
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                default:
                                    showToast(message: unconditionalMessage, controller: self)
                                }
                                
                                if confirmationAlert == true {
                                    displayAlertWithOtherButton(confirmationTitle, message: message, otherButton: confirmationTitle) { () -> () in
                                        self.updateContentAction(param as NSDictionary,url: url)
                                    }
                                    self.present(alert, animated: true, completion: nil)
                                }
                            }))
                        }
                        
                        
                        
                        
                    }}
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
    }
    
    func updateContentAction(_ parameter: NSDictionary , url : String){
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
            
            
            var method = "POST"
            
            if (url.range(of: "delete") != nil){
                method = "DELETE"
            }
            
            // Send Server Request to Explore Blog Contents with Blog_ID
            post(dic, url: "\(url)", method: method) { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    
                    if msg{
                        // On Success Update Blog Detail
                        // Update Blog Detail
                        
                        //                        if(\(url).)
                        
                        //                        \(url).range(of:"Swift") != nil{
                        
                        
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                            
                        }
                        
                        self.exploreContent()
                        
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
    
    // Sevice Calling
    func changeRSVP()
    {
        if Reachabable.isConnectedToNetwork()
        {
            removeAlert()
//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            self.view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            var parameters: NSDictionary = [:]
            let url1 = "advancedevents/member/join/" + String(eventid)
            parameters = ["rsvp": rsvp,"occurrence_id": String(occurrenceid)]
            // Send Server Request to Explore Group Contents with Group_ID
            post(parameters as! Dictionary<String, String>, url: url1, method: "POST") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    
                    if msg
                    {
                        
                        if succeeded["message"] != nil
                        {
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                        }
                        if succeeded["body"] != nil
                        {
                            
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
    
    func exploreContent()
    {
        
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork()
        {
            removeAlert()
//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            self.view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            var parameters: NSDictionary = [:]
            if startdate != nil && enddate != nil
            {
                
                parameters = ["firstStartDate":startdate,"lastStartDate":enddate]
                
            }
            
            // Send Server Request to Explore Group Contents with Group_ID
            post(parameters as! Dictionary<String, String>, url: url, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    
                    if msg
                    {
                        
                        if succeeded["message"] != nil
                        {
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                        }
                        if succeeded["body"] != nil
                        {
                            
                            if let contentInfo = succeeded["body"] as? NSDictionary
                            {
                                
                                // Update Content Gutter Menu
                                if let response = contentInfo["response"] as? NSArray
                                {
                                    self.repeatArr = response
                                    self.ReapeatTableview.dataSource = self
                                    self.ReapeatTableview.delegate = self
                                    self.ReapeatTableview.isOpaque = false
                                    self.ReapeatTableview.isHidden = false
                                }else{
                                    self.repeatArr = []
                                    self.ReapeatTableview.dataSource = self
                                    self.ReapeatTableview.delegate = self
                                    self.ReapeatTableview.isOpaque = true
                                    self.ReapeatTableview.isHidden = true
                                    showToast(message: String(format: NSLocalizedString("There are no any matching events", comment: ""), self.contentType), controller: self, onView: false, time: 5.0)
                                    
                                    
                                }
                                
                               
                                self.ReapeatTableview.reloadData()
                                
                                if let msg = contentInfo["messageGuest"] as? NSDictionary
                                {
                                    
                                    self.msgurl = msg["url"] as! String
                                    
                                    let msgItem = UIBarButtonItem(title: "\(messageIcon)", style: UIBarButtonItem.Style.plain, target: self, action: #selector(RepeatEventViewController.msgGuest))
                                    
                                    let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(RepeatEventViewController.searchItem))
                                    searchItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "FontAwesome", size: FONTSIZEExtraLarge)!],for: UIControl.State())
                                    msgItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "FontAwesome", size: FONTSIZEExtraLarge)!],for: UIControl.State())
                                    
                                    self.navigationItem.setRightBarButtonItems([searchItem,msgItem], animated: true)
                                    searchItem.tintColor = textColorPrime
                                    msgItem.tintColor = textColorPrime
                                    
                                    
                                }
                                else
                                {
                                    let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(RepeatEventViewController.searchItem))
                                    self.navigationItem.rightBarButtonItem = searchItem
                                    searchItem.tintColor = textColorPrime
                                    
                                }
                            }else{
                                self.ReapeatTableview.reloadData()
                            }
                            
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
    @objc func stopTimer() {
        stop()
       // if popAfterDelay == true{
            _ = self.navigationController?.popViewController(animated: true)
            
       // }
    }
    
}
