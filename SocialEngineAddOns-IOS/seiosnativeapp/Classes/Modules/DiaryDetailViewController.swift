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

//  DiaryDetailViewController.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 29/01/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class DiaryDetailViewController: UIViewController,UITableViewDataSource,UITableViewDelegate
{
    
    var subjectId:Int!
    var subjectType:String!
    var descriptiondiary:String!
    var totalItemCount:Int!
    var diaryName: String!
    let mainView = UIView()
    var eventTableView:UITableView!
    var refresher:UIRefreshControl!
    var refreshButton : UIButton!
    var contentIcon : UILabel!
    
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var updateScrollFlag = true
    var eventResponse = [AnyObject]()
    var showSpinner = true
    var isPageRefresing = false
    var info:UILabel!
    
    
    var contentGutterMenu: NSArray = []
    var deleteContent : Bool!
    var contentTitle : String!
    var contentDescription : String!
    
    
    var shareUrl : String!
    var shareParam : NSDictionary!
    var canInviteEventOrGroup = false
    var IScomingfrom : String!
    var CalenderDate : String!
    var Navtitle : String!
  //  var imageCache = [String:UIImage]()
    var descriptionTextview:UITextView!
    var coverImage:UIImageView!
    var coverImageUrl : String!
    
    var popAfterDelay : Bool! = false
    var leftBarButtonItem : UIBarButtonItem!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        
        view.backgroundColor = bgColor
        mainView.frame = view.frame
        view.addSubview(mainView)
        mainView.removeGestureRecognizer(tapGesture)
        
        
        if IScomingfrom == "Calendar"
        {
            navigationController?.navigationBar.isHidden = false
            setNavigationImage(controller: self)
            self.title = NSLocalizedString("Events: " + Navtitle,  comment: "")
            
            let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            leftNavView.backgroundColor = UIColor.clear
            let tapView = UITapGestureRecognizer(target: self, action: #selector(DiaryDetailViewController.goBack))
            leftNavView.addGestureRecognizer(tapView)
            let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
            backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
            leftNavView.addSubview(backIconImageView)
            
            let barButtonItem = UIBarButtonItem(customView: leftNavView)
            self.navigationItem.leftBarButtonItem = barButtonItem

            
            
        }
        else
        {
            
            navigationController?.navigationBar.isHidden = false
            setNavigationImage(controller: self)
            
            let myString = String(totalItemCount)
            let first = diaryName + ": " + myString
            self.title = NSLocalizedString(first,  comment: "")
            
            let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            leftNavView.backgroundColor = UIColor.clear
            let tapView = UITapGestureRecognizer(target: self, action: #selector(DiaryDetailViewController.goBack))
            leftNavView.addGestureRecognizer(tapView)
            let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
            backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
            leftNavView.addSubview(backIconImageView)
            
            let barButtonItem = UIBarButtonItem(customView: leftNavView)
            self.navigationItem.leftBarButtonItem = barButtonItem

            
        }
        
        
        
        globFilterValue = ""
        openMenu = false
        updateAfterAlert = true
        evetUpdate = true

            
        eventTableView = UITableView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - tabBarHeight), style: .grouped)
        eventTableView.register(EventViewTableViewCell.self, forCellReuseIdentifier: "CellThree")
        // eventTableView.rowHeight = 250
        eventTableView.estimatedRowHeight = 260
        eventTableView.dataSource = self
        eventTableView.delegate = self
        eventTableView.isOpaque = false
        eventTableView.backgroundColor = tableViewBgColor
        eventTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        mainView.addSubview(eventTableView)
        
        // Set tableview to show events
        if IScomingfrom != "Calendar"
        {
            self.descriptionTextview = createTextView(CGRect(x: PADING, y: 0, width: self.view.bounds.width - (2*PADING) , height: 20), borderColor: borderColorClear, corner: false )
            self.descriptionTextview.text = NSLocalizedString("\(descriptiondiary)",  comment: "")
            self.descriptionTextview.font = UIFont(name: fontName, size: FONTSIZEMedium)
            self.descriptionTextview.textColor = UIColor.black
            self.descriptionTextview.backgroundColor = bgColor
            self.descriptionTextview.sizeToFit()
            self.descriptionTextview.setNeedsDisplay()
            self.descriptionTextview.isHidden = true
            self.descriptionTextview.autocorrectionType = UITextAutocorrectionType.no
            eventTableView.addSubview(self.descriptionTextview)
            
        }
        
        
        
        // Set pull to referseh for eventtableview
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(DiaryDetailViewController.refresh), for: UIControl.Event.valueChanged)
        eventTableView.addSubview(refresher)

        
        contentIcon = createLabel(CGRect(x: 0,y: 0,width: 0,height: 0), text: "", alignment: .center, textColor: textColorMedium )
        mainView.addSubview(contentIcon)
        contentIcon.isHidden = true
        
        refreshButton = createButton(CGRect(x: 0,y: 0,width: 0,height: 0), title: "", border: true, bgColor: true, textColor: navColor)
        mainView.addSubview(refreshButton)
        refreshButton.isHidden = true
        
        pageNumber = 1
        updateScrollFlag = false
  
        
        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        eventTableView.tableFooterView = footerView
        eventTableView.tableFooterView?.isHidden = true
        
        browseEntries()
        
    }
    override func viewWillDisappear(_ animated: Bool)
    {
        eventTableView.tableFooterView?.isHidden = true
        navigationController?.navigationBar.isHidden = false
        setNavigationImage(controller: self)
        
    }
    override func viewWillAppear(_ animated: Bool)
    {
        if IScomingfrom == "Calendar"
        {
            
            navigationController?.navigationBar.isHidden = false
            setNavigationImage(controller: self)
            self.title = NSLocalizedString("Events: " + Navtitle,  comment: "")
            
            let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            leftNavView.backgroundColor = UIColor.clear
            let tapView = UITapGestureRecognizer(target: self, action: #selector(DiaryDetailViewController.goBack))
            leftNavView.addGestureRecognizer(tapView)
            
            
            let backIconImageView = createImageView(CGRect(x: 0,y: 12,width: 22,height: 22), border: false)
            backIconImageView.image = UIImage(named: "back_icon")
            leftNavView.addSubview(backIconImageView)
 
        }
        else
        {
            
            navigationController?.navigationBar.isHidden = false
            setNavigationImage(controller: self)
            
            let myString = String(totalItemCount)
            let first = diaryName + ": " + myString
            self.title = NSLocalizedString(first,  comment: "")
            
            
            let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            leftNavView.backgroundColor = UIColor.clear
            let tapView = UITapGestureRecognizer(target: self, action: #selector(DiaryDetailViewController.goBack))
            leftNavView.addGestureRecognizer(tapView)
            
            
            let backIconImageView = createImageView(CGRect(x: 0,y: 12,width: 22,height: 22), border: false)
            backIconImageView.image = UIImage(named: "back_icon")
            leftNavView.addSubview(backIconImageView)
            browseEntries()
            
        }
        
        
    }
    
    // MARK:Back Action
    @objc func goBack()
    {
        
        if conditionalProfileForm == "BrowsePage"
        {
            eventUpdate = true
            _ = self.navigationController?.popToRootViewController(animated: true)
            
        }
        else
        {
            _ = self.navigationController?.popViewController(animated: false)
        }
        
    }    // Stop Timer
    @objc func stopTimer() {
        stop()
        if popAfterDelay == true
        {
            _ = self.navigationController?.popViewController(animated: false)
        }
        
    }
    // MARK: - Cover Image Selection
    @objc func showEvent(_ sender:UIButton)
    {
        
        var eventInfo:NSDictionary!
        eventInfo = eventResponse[sender.tag] as! NSDictionary
        
        
        let presentedVC = ContentFeedViewController()
        presentedVC.subjectId = "\(eventInfo["event_id"]!)"
        presentedVC.subjectType = "advancedevents"
        navigationController?.pushViewController(presentedVC, animated: true)
        
    }
    // MARK: - Host Profile Selection
    @objc func hostProfile(_ sender:UIButton)
    {
        if openMenu
        {
            openMenu = false
            openMenuSlideOnView(mainView)
            return
        }
        var eventInfo:NSDictionary!
        eventInfo = eventResponse[sender.tag] as! NSDictionary
        
        if let _ = eventInfo["hosted_by"]
        {
            let hostInfo = eventInfo["hosted_by"] as! NSDictionary
            if let hostId = hostInfo["host_id"] as? Int
            {
                if hostId != 0
                {
                    let  hostType = hostInfo["host_type"] as? String
                    
                    
                    if hostType == "user"
                    {
                        
                        
                        let presentedVC = ContentActivityFeedViewController()
                        
                        presentedVC.subjectType = "user"
                        presentedVC.subjectId = "\(hostId)"
                        navigationController?.pushViewController(presentedVC, animated: true)
                    }
                    else
                    {
                        
                        let presentedVC = AdvHostMemberViewController()
                        presentedVC.hostId = hostId
                        navigationController?.pushViewController(presentedVC, animated: true)
                    }
                    
                    
                }
            }
            else
            {
                showToast(message: "You do not have permission to view this private page.", controller: self)
            }
            
        }
        
    }
    // MARK: - addNewEvent Selection
    @objc func addNewEvent()
    {
        for menu in contentGutterMenu
        {
            if let menuItem = menu as? NSDictionary
            {
                if (menuItem["name"] as! String == "create")
                {
                    isCreateOrEdit = true
                    let presentedVC = FormGenerationViewController()
                    presentedVC.formTitle = NSLocalizedString("Create New Diary", comment: "")
                    presentedVC.contentType = "Diary"
                    presentedVC.param = [ : ]
                    presentedVC.url = "advancedevents/diaries/create"
                    presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                    let nativationController = UINavigationController(rootViewController: presentedVC)
                    self.present(nativationController, animated:false, completion: nil)
                }
            }
        }
    }
    
    // MARK:Pull to refreash
    // MARK: -  Pull to Request Action
    @objc func refresh()
    {
        
        if Reachabable.isConnectedToNetwork()
        {
            
            searchDic.removeAll(keepingCapacity: false)
            
            showSpinner = false
            pageNumber = 1
            updateAfterAlert = false
            browseEntries()
        }
        else
        {
            // No Internet Connection Message
            refresher.endRefreshing()
            showToast(message: network_status_msg, controller: self)
        }
        
    }
    
    // MARK:  UITableViewDelegate & UITableViewDataSource
    
    // Set Tabel Footer Height
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
    
    // Set Tabel Header Height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        
        if IScomingfrom == "Calendar"
        {
            return 0.00001
        }
        else
        {
            return descriptionTextview.frame.size.height
        }
    }
    
    // Set TableView Section
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 265.0
    }
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            return Int(ceil(Float(eventResponse.count)/2))
        }
        else
        {
            return eventResponse.count
        }
    }
    
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        
        let cell = eventTableView.dequeueReusableCell(withIdentifier: "CellThree", for: indexPath) as! EventViewTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.lineView.isHidden = false
        cell.dateView.frame.size.height = 80
        cell.dateView.backgroundColor = navColor
        cell.titleView.frame.size.height = 80
        cell.backgroundColor = tableViewBgColor
        
        var eventInfo:NSDictionary!
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            if(eventResponse.count > ((indexPath as NSIndexPath).row)*2 ){
                eventInfo = eventResponse[((indexPath as NSIndexPath).row)*2] as! NSDictionary
                cell.contentSelection.tag = ((indexPath as NSIndexPath).row)*2
                cell.hostSelection.tag = ((indexPath as NSIndexPath).row)*2
                cell.menu.tag = ((indexPath as NSIndexPath).row)*2
            }
        }
        else
        {
            eventInfo = eventResponse[(indexPath as NSIndexPath).row] as! NSDictionary
            cell.contentSelection.tag = (indexPath as NSIndexPath).row
            cell.hostSelection.tag = (indexPath as NSIndexPath).row
            
            cell.menuButton.tag = (indexPath as NSIndexPath).row
        }
        
        
        cell.hostImage.isHidden = false
        cell.hostSelection.isHidden = false
        cell.hostSelection.isUserInteractionEnabled = true
        
        //Select Event Action
        cell.contentSelection.addTarget(self, action: #selector(DiaryDetailViewController.showEvent(_:)), for: .touchUpInside)
        
        
        
        cell.hostSelection.addTarget(self, action:#selector(DiaryDetailViewController.hostProfile(_:)), for: .touchUpInside)
        
        cell.contentImage.frame.size.height = 260
        cell.lineView.frame.origin.y = cell.contentImage.frame.size.height
        cell.contentSelection.frame.size.height = 180
        
        // Set Event Image
        
        
        
        cell.contentImage.image = nil
        cell.contentImage.backgroundColor = placeholderColor
        let url = URL(string: eventInfo["image"] as! NSString as String)
        if url != nil {
            cell.contentImage.image = nil
            cell.contentImage.image =  imageWithImage( UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: cell.contentImage.bounds.width)
            cell.contentImage.kf.indicatorType = .activity
            (cell.contentImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
            cell.contentImage.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
            })

        }

        //Set Profile Image
        cell.hostImage.image = nil
        cell.hostImage.backgroundColor = placeholderColor
        var hostInfo:NSDictionary!
        if let _ = eventInfo["hosted_by"] as? NSDictionary
        {
            hostInfo = eventInfo["hosted_by"] as! NSDictionary
            let url = URL(string: hostInfo["image"] as! NSString as String)
            if url != nil {

                cell.hostImage.kf.indicatorType = .activity
                (cell.hostImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                cell.hostImage.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                    
                })

            }
            
        }
        else
        {
            cell.hostImage.isHidden = true
            cell.hostSelection.isHidden = true
//            cell.hostImage.image = nil
//            cell.hostImage.image =  imageWithImage( UIImage(named: "")!, scaletoWidth: CGRectGetWidth(cell.hostImage.bounds))
        }
        
        
        
        let name = eventInfo["title"] as? String
        var tempInfo = ""
        
        if let eventDate = eventInfo["starttime"] as? String
        {
            
            let dateMonth = dateDifferenceWithTime(eventDate)
            var dateArrayMonth = dateMonth.components(separatedBy: ", ")
            if dateArrayMonth.count > 1{
                cell.dateLabel1.frame = CGRect(x: 10, y: 5, width: 50, height: 60)
                
                cell.dateLabel1.numberOfLines = 0
                cell.dateLabel1.text = "\(dateArrayMonth[1])\n\(dateArrayMonth[0])"
                cell.dateLabel1.textColor = UIColor.white
                cell.dateLabel1.font = UIFont(name: "FontAwesome", size: 18)
            }
            
            let date = dateDifferenceWithEventTime(eventDate)
            var DateC = date.components(separatedBy: ", ")
            tempInfo += "\(DateC[1]) \(DateC[0]) \(DateC[2])"
            if DateC.count > 3{
                tempInfo += " at \(DateC[3])"
            }
            if eventInfo["hasMultipleDates"] as? Int == 1
            {
                tempInfo += "(Multiple Dates Available)"
            }
            
        }
        
        cell.titleLabel.frame = CGRect(x: 10, y: 0, width: (cell.contentImage.bounds.width-110), height: 30)
        cell.titleLabel.text = "\(name!)"
        cell.titleLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        // cell.contentName.font = UIFont(name: "FontAwesome", size: 18)
        //cell.titleLabel.sizeToFit()
        cell.titleLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
        
        let location = eventInfo["location"] as? String
        if location != "" && location != nil{
            
            cell.locLabel.isHidden = false
            
            cell.locLabel.frame = CGRect(x: 10, y: 25, width: (cell.contentImage.bounds.width-110), height: 20)
            cell.locLabel.text = "\u{f041}   \(location!)"
            // cell.locLabel.textColor = textColorLight
            cell.locLabel.font = UIFont(name: "FontAwesome", size: 14)
            cell.locLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
            
            if eventInfo["hasMultipleDates"] as? Int == 1
            {
                cell.dateLabel.frame = CGRect(x: 10, y: 40, width: (cell.contentImage.bounds.width-110), height: 40)
            }
            else
            {
                cell.dateLabel.frame = CGRect(x: 10, y: 45, width: (cell.contentImage.bounds.width-110), height: 20)
            }
            
            
            cell.dateLabel.text = "\u{f073}  \(tempInfo)"
            cell.dateLabel.textAlignment = NSTextAlignment.left
            // cell.dateLabel.textColor = textColorLight
            cell.dateLabel.numberOfLines = 0
            cell.dateLabel.font = UIFont(name: "FontAwesome", size: 14)
            
        }
        
        if location == "" || location == nil{
            
            cell.locLabel.isHidden = true
            
            if eventInfo["hasMultipleDates"] as? Int == 1
            {
                cell.dateLabel.frame = CGRect(x: 10, y: 30, width: (cell.contentImage.bounds.width-110), height: 40)
            }
            else
            {
                cell.dateLabel.frame = CGRect(x: 10, y: 35, width: (cell.contentImage.bounds.width-110), height: 20)
            }
            
            
            cell.dateLabel.text = "\u{f073}  \(tempInfo)"
            cell.dateLabel.textAlignment = NSTextAlignment.left
            //cell.dateLabel.textColor = textColorLight
            
            cell.dateLabel.numberOfLines = 0
            
            //cell.dateLabel.sizeToFit()
            cell.dateLabel.font = UIFont(name: "FontAwesome", size: 14)
            
        }
        
        
        
        
        cell.menuButton.isHidden = true
        
        
        
        // RHS
        if(UIDevice.current.userInterfaceIdiom == .pad){
            
            cell.dateView2.isHidden = false
            cell.dateView2.frame.size.height = 80
            cell.dateView2.backgroundColor = navColor
            cell.titleView2.frame.size.height = 80
            
            var eventInfo2:NSDictionary!
            if(eventResponse.count > (((indexPath as NSIndexPath).row)*2+1) ){
                eventInfo2 = eventResponse[(((indexPath as NSIndexPath).row)*2+1)] as! NSDictionary
                cell.cellView2.isHidden = false
                cell.contentSelection2.isHidden = false
                cell.hostImage2.isHidden = false
                cell.hostSelection2.isHidden = false
                cell.lineView2.isHidden = false
                cell.titleView2.isHidden = false
                cell.contentSelection2.tag = (((indexPath as NSIndexPath).row)*2+1)
                cell.menuButton2.tag = (((indexPath as NSIndexPath).row)*2+1)
                cell.hostSelection2.tag = (((indexPath as NSIndexPath).row)*2+1)
            }else{
                cell.cellView2.isHidden = true
                cell.contentSelection2.isHidden = true
                cell.dateView2.isHidden = true
                cell.lineView2.isHidden = true
                cell.titleView2.isHidden = true
                cell.hostSelection2.isHidden = true
                return cell
            }
            
            // Select Event Action
            cell.contentSelection2.addTarget(self, action: #selector(DiaryDetailViewController.showEvent(_:)), for: .touchUpInside)
            // Set MenuAction
            cell.menuButton2.addTarget(self, action:Selector(("showEventMenu:")) , for: .touchUpInside)
            cell.hostSelection2.addTarget(self, action: #selector(DiaryDetailViewController.hostProfile(_:)), for: .touchUpInside)
            
            cell.contentImage2.frame.size.height = 260
            cell.lineView2.frame.origin.y = cell.contentImage2.frame.size.height
            cell.contentSelection2.frame.size.height = 180
            
            
            // Set Event Image
            cell.contentImage2.image = nil
            cell.contentImage2.backgroundColor = placeholderColor
            let url = URL(string: eventInfo2["image"] as! NSString as String)
            if url != nil {
                cell.contentImage2.image = nil
                cell.contentImage2.image =  imageWithImage( UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: cell.contentImage2.bounds.width)
                cell.contentImage2.kf.indicatorType = .activity
                (cell.contentImage2.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                cell.contentImage2.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                    
                })
 
            }
            
            //Set Profile Image
            cell.hostImage2.image = nil
            cell.hostImage2.backgroundColor = placeholderColor
            var hostInfo2:NSDictionary!
            if let _ = eventInfo2["hosted_by"] as? NSDictionary
            {
                hostInfo2 = eventInfo2["hosted_by"] as! NSDictionary
                let url = URL(string: hostInfo2["image"] as! NSString as String)
                if url != nil {

                    cell.hostImage2.kf.indicatorType = .activity
                     (cell.hostImage2.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    cell.hostImage2.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        
                    })

                }
                
            }
            else
            {
                cell.hostImage2.isHidden = true
                cell.hostSelection2.isHidden = true

            }
            let name = eventInfo2["title"] as? String
            var tempInfo = ""
            if let eventDate = eventInfo2["starttime"] as? String{
                
                let dateMonth = dateDifferenceWithTime(eventDate)
                var dateArrayMonth = dateMonth.components(separatedBy: ", ")
                if dateArrayMonth.count > 1{
                    cell.dateLabel3.frame = CGRect(x: 10, y: 5, width: 50, height: 60)
                    
                    cell.dateLabel3.numberOfLines = 0
                    cell.dateLabel3.text = "\(dateArrayMonth[1])\n\(dateArrayMonth[0])"
                    cell.dateLabel3.textColor = UIColor.white
                    cell.dateLabel3.font = UIFont(name: "FontAwesome", size: 18)
                }
                
                let date = dateDifferenceWithEventTime(eventDate)
                var DateC = date.components(separatedBy: ", ")
                tempInfo += "\(DateC[1]) \(DateC[0]) \(DateC[2])"
                if DateC.count > 3{
                    tempInfo += " at \(DateC[3])"
                }
                if eventInfo2["hasMultipleDates"] as? Int == 1
                {
                    tempInfo += "(Multiple Dates Available)"
                }
                
            }
            else{
                cell.dateView2.isHidden = true
            }
            
            cell.titleLabel2.frame = CGRect(x: 10, y: 0, width: (cell.contentImage2.bounds.width-110), height: 30)
            
            cell.titleLabel2.text = "\(name!)"
            cell.titleLabel2.lineBreakMode = NSLineBreakMode.byWordWrapping
            // cell.contentName.font = UIFont(name: "FontAwesome", size: 18)
            //cell.titleLabel2.sizeToFit()
            cell.titleLabel2.lineBreakMode = NSLineBreakMode.byTruncatingTail
            
            let location = eventInfo2["location"] as? String
            if location != "" && location != nil{
                
                cell.locLabel2.isHidden = false
                
                cell.locLabel2.frame = CGRect(x: 10, y: 25, width: (cell.contentImage2.bounds.width-110), height: 20)
                cell.locLabel2.text = "\u{f041}   \(location!)"
                // cell.locLabel.textColor = textColorLight
                cell.locLabel2.font = UIFont(name: "FontAwesome", size: 14)
                
                if eventInfo2["hasMultipleDates"] as? Int == 1
                {
                    cell.dateLabel2.frame = CGRect(x: 10, y: 40, width: (cell.contentImage2.bounds.width-110), height: 40)
                }
                else
                {
                    cell.dateLabel2.frame = CGRect(x: 10, y: 45, width: (cell.contentImage2.bounds.width-110), height: 20)
                }
                
                
                cell.dateLabel2.text = "\u{f073}  \(tempInfo)"
                cell.dateLabel2.textAlignment = NSTextAlignment.left
                // cell.dateLabel.textColor = textColorLight
                cell.dateLabel2.numberOfLines = 0
                cell.dateLabel2.font = UIFont(name: "FontAwesome", size: 14)
                
            }
            
            if location == "" || location == nil{
                
                cell.locLabel2.isHidden = true
                
                if eventInfo2["hasMultipleDates"] as? Int == 1
                {
                    cell.dateLabel2.frame = CGRect(x: 10, y: 30, width: (cell.contentImage2.bounds.width-110), height: 40)
                }
                else
                {
                    cell.dateLabel2.frame = CGRect(x: 10, y: 35, width: (cell.contentImage2.bounds.width-110), height: 20)
                }
                
                
                cell.dateLabel2.text = "\u{f073}  \(tempInfo)"
                cell.dateLabel2.textAlignment = NSTextAlignment.left
                //cell.dateLabel.textColor = textColorLight
                cell.dateLabel2.numberOfLines = 0
                
                cell.dateLabel2.font = UIFont(name: "FontAwesome", size: 14)
                
            }
            
            
            
            cell.menuButton2.isHidden = true
            
            
            return cell
        }
        return cell
        
        
        
    }
    
    // Handle Blog Table Cell Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView)
//    {
//
//
//        if updateScrollFlag
//        {
//            // Check for Page Number for Browse Blog
//
//            if eventTableView.contentOffset.y >= eventTableView.contentSize.height - eventTableView.bounds.size.height{
//                if (!isPageRefresing  && limit*pageNumber < totalItems)
//                {
//                    if Reachabable.isConnectedToNetwork()
//                    {
//                        updateScrollFlag = false
//                        pageNumber += 1
//                        isPageRefresing = true
//                        if searchDic.count == 0{
//                            browseEntries()
//                        }
//                    }
//                }
//
//            }
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
                // Check for Page Number for Browse Blog
                
//                if eventTableView.contentOffset.y >= eventTableView.contentSize.height - eventTableView.bounds.size.height{
                    if (!isPageRefresing  && limit*pageNumber < totalItems)
                    {
                        if Reachabable.isConnectedToNetwork()
                        {
                            updateScrollFlag = false
                            pageNumber += 1
                            isPageRefresing = true
                            eventTableView.tableFooterView?.isHidden = false
                         //   if searchDic.count == 0{
                                browseEntries()
                           // }
                        }
                    }
                    else
                    {
                        eventTableView.tableFooterView?.isHidden = true
                }
                    
               // }
            }
            
        }
        
    }
    
    //MARK:Gutter Menu
    @objc func showMainGutterMenu()
    {
        
        
        // Generate Group Menu Come From Server as! Alert Popover
        
        deleteContent = false
        var confirmationTitle = ""
        var message = ""
        var url = ""
        var param: NSDictionary = [:]
        var confirmationAlert = true
        
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        for menu in contentGutterMenu
        {
            if let menuItem = menu as? NSDictionary
            {
                
                if (menuItem["name"] as! String != "create")
                {
                    
                    let titleString = menuItem["name"] as! String
                    
                    if ((titleString.range(of: "delete") != nil))
                    {
                        
                        alertController.addAction(UIAlertAction(title: (menuItem["label"] as! String), style: .destructive , handler:{ (UIAlertAction) -> Void in
                            let condition = menuItem["name"] as! String
                            switch(condition){
                                
                                
                            case "delete":
                                
                                self.deleteContent = true
                                confirmationTitle = NSLocalizedString("Delete Diary", comment: "")
                                
                                message = NSLocalizedString("Are you sure you want to delete this diary?", comment: "")
                                url = menuItem["url"] as! String
                                param = Dictionary<String, String>() as NSDictionary //menuItem["urlParams"] as! NSDictionary
                                
                                
                                
                            default:
                                showToast(message: unconditionalMessage, controller: self)
                                
                            }
                            
                            if confirmationAlert == true
                            {
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
                            case "edit":
                                
                                confirmationAlert = false
                                isCreateOrEdit = false
                                let presentedVC = FormGenerationViewController()
                                presentedVC.formTitle = NSLocalizedString("Edit", comment: "")
                                presentedVC.contentType = "DiaryDetail"
                                presentedVC.url = menuItem["url"] as! String
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:false, completion: nil)

                                
                            case "share":
                                
                                confirmationAlert = false
                                let pv = AdvanceShareViewController()
                                pv.url =  menuItem["url"] as! String
                                pv.param = (menuItem["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                pv.Sharetitle = self.contentTitle
                                if (self.contentDescription != nil) {
                                    pv.ShareDescription = self.contentDescription
                                }
                                pv.imageString = self.coverImageUrl
                                pv.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: pv)
                                self.present(nativationController, animated:true, completion: nil)
 
                         
                            case "invite":
                                confirmationAlert = false
                                let presentedVC = InviteMemberViewController()
                                presentedVC.contentType = "\(self.subjectType)"
                                presentedVC.url = menuItem["url"] as! String
                                presentedVC.param = Dictionary<String, String>() as NSDictionary? //menuItem["urlParams"] as! NSDictionary
                                self.navigationController?.pushViewController(presentedVC, animated: false)
                                
                            case "join_group":
                                confirmationTitle = NSLocalizedString("Join Group", comment: "")
                                message = NSLocalizedString("Would you like to join this group?", comment: "")
                                url = menuItem["url"] as! String
                                param = Dictionary<String, String>() as NSDictionary
                                
                                
                            case "request_member":
                                if self.subjectType == "group"{
                                    confirmationTitle = NSLocalizedString("Request Group Membership", comment: "")
                                    message = NSLocalizedString("Would you like to request membership in this group?", comment: "")
                                }else if self.subjectType == "event"{
                                    confirmationTitle = NSLocalizedString("Request Event Membership", comment: "")
                                    message = NSLocalizedString("Would you like to request membership in this event?", comment: "")
                                }
                                url = menuItem["url"] as! String
                                param = Dictionary<String, String>() as NSDictionary //menuItem["urlParams"] as! NSDictionary
                                
                                
                                
                                
                                
                            case "request_invite":
                                
                                confirmationAlert = true
                                confirmationTitle = NSLocalizedString("Request Event Membership", comment: "")
                                message = NSLocalizedString("Would you like to request membership in this event?", comment: "")
                                
                                
                                url = menuItem["url"] as! String
                                param = Dictionary<String, String>() as NSDictionary //menuItem["urlParams"] as! NSDictionary
                                
                                
                                
                                
                            case "tellafriend":
                                
                                
                                
                                confirmationAlert = false
                                let presentedVC = TellAFriendViewController();
                                url = menuItem["url"] as! String
                                presentedVC.url = url
                                presentedVC.param = menuItem["urlParams"] as! NSDictionary
                                self.navigationController?.pushViewController(presentedVC, animated: true)
                                
                                
                            case "report":
                                
                                confirmationAlert = false
                                let presentedVC = ReportContentViewController()
                                presentedVC.param = (menuItem["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                presentedVC.url = menuItem["url"] as! String
                                self.navigationController?.pushViewController(presentedVC, animated: false)
                                
                            case "notification_settings":
                                
                                
                                confirmationAlert = false
                                let presentedVC = NotificationsSettingsViewController();
                                url = menuItem["url"] as! String
                                presentedVC.url = url
                                presentedVC.contentType = "advancedeventsview"
                                self.navigationController?.pushViewController(presentedVC, animated: true)
                                
                            case "accept_invite":
                                
                                confirmationAlert = true
                                confirmationTitle = NSLocalizedString("Accept Event Invitation", comment: "")
                                
                                
                                message = NSLocalizedString("Would you like to join this \(self.subjectType)?", comment: "")
                                url = menuItem["url"] as! String
                                param = Dictionary<String, String>() as NSDictionary
                                
                                
                            case "create":
                                
                                confirmationAlert = false
                                isCreateOrEdit = false
                                let presentedVC = FormGenerationViewController()
                                presentedVC.formTitle = NSLocalizedString("Create New Event in Diary", comment: "")
                                presentedVC.contentType = "Diary"
                                presentedVC.param = [ : ]
                                presentedVC.url = "advancedevents/diaries/add"
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:false, completion: nil)

                                
                            case "memberDiaries":
                                
                                confirmationAlert = false
                                let presentedVC = AdminDiaryViewController();
                                presentedVC.param = (menuItem["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                url = menuItem["url"] as! String
                                presentedVC.url = url
                                presentedVC.tittle = menuItem["label"] as! String
                                self.navigationController?.pushViewController(presentedVC, animated: true)
                                
                                
                            case "messageOwner":
                                
                                confirmationAlert = false
                                let presentedVC = MessageOwnerViewController();
                                url = menuItem["url"] as! String
                                presentedVC.url = url
                                presentedVC.param = (menuItem["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                self.navigationController?.pushViewController(presentedVC, animated: true)
                                
                            default:
                                showToast(message: unconditionalMessage, controller: self)
                            }
                            
                            if confirmationAlert == true
                            {
                                displayAlertWithOtherButton(confirmationTitle, message: message, otherButton: confirmationTitle) { () -> () in
                                    self.updateContentAction(param as NSDictionary,url: url)
                                }
                                self.present(alert, animated: true, completion: nil)
                            }
                        }))
                    }
                    
                    
                    
                    
                }}
        }
        if  (UIDevice.current.userInterfaceIdiom == .phone)
        {
            alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .cancel, handler:nil))
        }
        else
        {
            // Present Alert as! Popover for iPad
            alertController.modalPresentationStyle = UIModalPresentationStyle.popover
            let popover = alertController.popoverPresentationController
            popover?.sourceView = UIButton()
            popover?.sourceRect = CGRect(x: view.bounds.width/2, y: view.bounds.height/2 , width: 1, height: 1)
            popover?.permittedArrowDirections = UIPopoverArrowDirection()
        }
        self.present(alertController, animated:true, completion: nil)
        
    }
    
    func updateContentAction(_ parameter: NSDictionary , url : String)
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
            
            if (url.range(of: "delete") != nil)
            {
                method = "DELETE"
            }
            
            // Send Server Request to Explore Blog Contents with Blog_ID
            post(dic, url: "\(url)", method: method) { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                        activityIndicatorView.stopAnimating()
                        
                        if msg
                        {
                            
                            
                            if succeeded["message"] != nil
                            {
                                showToast(message: succeeded["message"] as! String, controller: self)
                                
                                
                            }
                            if self.deleteContent == true
                            {
                                groupUpdate = true
                                eventUpdate = true
                                wishlistUpdate = true
                                self.popAfterDelay = true
                                self.createTimer(self)
                                if conditionalProfileForm == "BrowsePage"
                                {
                                    _ = self.navigationController?.popToRootViewController(animated: true)
                                    
                                }
                                else
                                {
                                    _ = self.navigationController?.popViewController(animated: false)
                                }
                                
                                
                            }
                            self.browseEntries()
                            
                        }
                            
                        else
                        {
                            // Handle Server Side Error
                            if succeeded["message"] != nil{
                                showToast(message: succeeded["message"] as! String, controller: self)
                                
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
    func createTimer(_ target: AnyObject){
        timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  #selector(stopTimer), userInfo: nil, repeats: false)
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
    
    
    // MARK: - Server Connection For Event Updation
    @objc func browseEntries()
    {
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork()
        {
            
            
            //info.removeFromSuperview()
            let subViews = mainView.subviews
            for ob in subViews{
                if ob.tag == 1000{
                    ob.removeFromSuperview()
                }
            }
            
            if (self.pageNumber == 1)
            {
                //self.eventResponse.removeAll(keepingCapacity: false)
                if updateAfterAlert == true
                {
                    removeAlert()
                    self.eventTableView.reloadData()
                }
                else
                {
                    updateAfterAlert = true
                }
            }
            refreshButton.isHidden = true
            contentIcon.isHidden = true
            
            if (showSpinner)
            {
       //         spinner.center = view.center
                if updateScrollFlag == false
                {
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height-85 - (tabBarHeight / 4))
                }
                if (self.pageNumber == 1)
                {
                    activityIndicatorView.center = mainView.center
                    updateScrollFlag = false
                }
//                spinner.hidesWhenStopped = true
//                spinner.style = UIstyle.gray
//                view.addSubview(spinner)
                self.view.addSubview(activityIndicatorView)
              //  activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
            }
            var path = ""
            var parameters = [String:String]()
            
            
            if IScomingfrom == "Calendar"
            {
                path = "advancedevents/calender"
                parameters = ["page":"\(pageNumber)","limit": "\(limit)","viewtype":"list","date_current":String(self.CalenderDate)]
            }
            else
            {
                path = "advancedevents/diary/" + String(self.subjectId!)
                parameters = ["page":"\(pageNumber)","limit": "\(limit)"]
                
            }
            // Send Server Request to Browse Blog Entries
            post(parameters, url: path, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                        
                        if self.showSpinner
                        {
                            activityIndicatorView.stopAnimating()
                        }
                        self.refresher.endRefreshing()
                        self.showSpinner = false
                        self.updateScrollFlag = true
                        
                        
                        if msg
                        {
                            if self.IScomingfrom == "Calendar"
                            {
                                if self.pageNumber == 1
                                {
                                    self.eventResponse.removeAll(keepingCapacity: false)
                                }
                                
                                if succeeded["message"] != nil
                                {
                                    showToast(message: succeeded["message"] as! String, controller: self)
                                }
                                
                                
                                if let response = succeeded["body"] as? NSDictionary
                                {
                                    if response["totalItemCount"] != nil
                                    {
                                        self.totalItems = response["totalItemCount"] as! Int
                                    }
                                    
                                    if response["response"] != nil
                                    {
                                        if let event = response["response"] as? NSArray
                                        {
                                            self.eventResponse = self.eventResponse + (event as [AnyObject])
                                        }
                                    }
                                }
                                self.isPageRefresing = false
                                self.eventTableView.reloadData()
                                
                            }
                            else
                            {
                                if self.pageNumber == 1
                                {
                                    self.eventResponse.removeAll(keepingCapacity: false)
                                }
                                
                                if succeeded["message"] != nil
                                {
                                    showToast(message: succeeded["message"] as! String, controller: self)
                                }
                                
                                
                                if let response = succeeded["body"] as? NSDictionary
                                {
                                    if response["response"] != nil
                                    {
                                        if let event = response["response"] as? NSDictionary
                                        {
                                            if let blog = event["event"]as? NSArray
                                            {
                                                self.eventResponse = self.eventResponse + (blog as [AnyObject])
                                            }
                                            if self.eventResponse.count>0
                                            {
                                                
                                                let dic = self.eventResponse[0]
                                                self.coverImageUrl = dic["image"] as! String
                                            }
                                            
                                            self.contentTitle =  "\(event["title"]!)"
                                            self.contentDescription =  "\(event["body"]!)"
                                            self.descriptionTextview.text = self.contentDescription
                                            self.descriptionTextview.sizeToFit()
                                            self.descriptionTextview.setNeedsDisplay()
                                        }
                                    }
                                    
                                    if logoutUser != true
                                    {
                                        
                                        
                                        let addBlog = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(DiaryDetailViewController.addNewEvent))
                                        let menuItem = UIBarButtonItem(title: "\(optionIcon)", style: UIBarButtonItem.Style.plain, target: self, action: #selector(DiaryDetailViewController.showMainGutterMenu))
                                        
                                        
                                        menuItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "FontAwesome", size: FONTSIZEExtraLarge)!],for: UIControl.State())
                                        
                                        self.navigationItem.setRightBarButtonItems([addBlog,menuItem], animated: true)
                                        
                                    }
                                }
                                
                                
                                // Update Content Gutter Menu
                                if let contentInfo = succeeded["body"] as? NSDictionary
                                {
                                    if let menu = contentInfo["gutterMenus"] as? NSArray
                                    {
                                        self.contentGutterMenu = menu  as NSArray
                                        
                                        
                                        
                                        for tempMenu in self.contentGutterMenu
                                        {
                                            if let tempDic = tempMenu as? NSDictionary
                                            {
                                                
                                                if tempDic["name"] as! String == "share"
                                                {
                                                    
                                                    self.shareUrl = tempDic["url"] as! String
                                                    self.shareParam = tempDic["urlParams"] as! NSDictionary
                                                }
                                            }
                                        }
                                        
                                        for tempMenu in self.contentGutterMenu
                                        {
                                            if let tempDic = tempMenu as? NSDictionary
                                            {
                                                
                                                if tempDic["name"] as! String == "invite"
                                                {
                                                    self.canInviteEventOrGroup = true
                                                    
                                                }
                                                
                                                
                                            }
                                        }
                                        
                                        
                                        
                                    }
                                }
                                
                                self.descriptionTextview.isHidden = false
                                self.isPageRefresing = false
                                self.eventTableView.reloadData()
                                if self.eventResponse.count == 0
                                {
                                    
                                    self.contentIcon = createLabel(CGRect(x: self.view.bounds.width/2 - 30,y: self.view.bounds.height/2-80,width: 60 , height: 60), text: NSLocalizedString("\(eventIcon)",  comment: "") , alignment: .center, textColor: textColorMedium)
                                    self.contentIcon.font = UIFont(name: "FontAwesome", size: 50)
                                    self.mainView.addSubview(self.contentIcon)
                                    
                                    self.info = createLabel(CGRect(x: 0, y: 0,width: self.view.bounds.width * 0.8 , height: 50), text: NSLocalizedString("There are currently no events in this diary.",  comment: "") , alignment: .center, textColor: textColorMedium)
                                    self.info.sizeToFit()
                                    self.info.numberOfLines = 0
                                    self.info.lineBreakMode = NSLineBreakMode.byWordWrapping
                                    self.info.center = self.view.center
                                    self.info.backgroundColor = bgColor
                                    self.info.tag = 1000
                                    self.mainView.addSubview(self.info)
                                    
                                    self.refreshButton = createButton(CGRect(x: self.view.bounds.width/2-40, y: self.info.bounds.height + self.info.frame.origin.y + (2 * contentPADING), width: 80, height: 40), title: NSLocalizedString("Try Again",  comment: ""), border: true, bgColor: true, textColor: navColor)
                                    self.refreshButton.backgroundColor = bgColor
                                    self.refreshButton.layer.borderColor = navColor.cgColor
                                    self.refreshButton.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
                                    self.refreshButton.addTarget(self, action: #selector(DiaryDetailViewController.browseEntries), for: UIControl.Event.touchUpInside)
                                    self.refreshButton.layer.cornerRadius = 5.0
                                    self.refreshButton.layer.masksToBounds = true
                                    self.mainView.addSubview(self.refreshButton)
                                    self.refreshButton.isHidden = false
                                    self.contentIcon.isHidden = false
                                    
                                }
                                
                            }
                        }
                        else
                        {
                            // Handle Server Error
                            if succeeded["message"] != nil
                            {
                                showToast(message: succeeded["message"] as! String, controller: self)
                                let message = succeeded["message"] as? String
                                if message == "You do not have the access of this page."
                                {
                                    self.popAfterDelay = true
                                    self.createTimer(self)
                                    
                                }

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
    
    
}
