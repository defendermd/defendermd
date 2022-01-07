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

//  CategoryDetailViewController.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 03/02/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit

class CategoryDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate
{
    
    var subjectId:Int!
    var subjectType:String!
    var subcatid:Int!
    var subsubcatid:Int!
    var totalItemCount:Int!
    var tittle: String!
    let mainView = UIView()
    var eventTableView:UITableView!
    var refresher:UIRefreshControl!
    var refreshButton : UIButton!
    var contentIcon : UILabel!
    var feedFilter: UIButton!
    var feedFilter2: UIButton!
    
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var updateScrollFlag = true
    var eventResponse = [AnyObject]()
    var Subcategoryarr = [AnyObject]()
    var SubSubcategoryarr = [AnyObject]()
    var showSpinner = true
    var isPageRefresing = false
    var info:UILabel!

    var categoryType : String = ""

    var contentGutterMenu: NSArray = []
    var deleteContent : Bool!
    var contentTitle : String!
    var contentDescription : String!
    
    var shareUrl : String!
    var shareParam : NSDictionary!
    var canInviteEventOrGroup = false
    
    var subcategory: String!
    var subsubcategory: String!
  //  var imageCache = [String:UIImage]()
    var popAfterDelay : Bool!
    var leftBarButtonItem : UIBarButtonItem!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        productUpdate = false
        subcategory = ""
        subsubcategory = ""
        
        
        view.backgroundColor = bgColor
        mainView.frame = view.frame
        view.addSubview(mainView)
        mainView.removeGestureRecognizer(tapGesture)
        
        
        globFilterValue = ""
        openMenu = false
        updateAfterAlert = true
        evetUpdate = true
        
        
        let subViews = mainView.subviews
        for subview in subViews
        {
            subview.removeFromSuperview()
        }
        
        
        
        // Set tableview to show events
        eventTableView = UITableView(frame: CGRect(x: 0, y: 0, width: view.bounds.width,height: view.bounds.height), style: .grouped)
        eventTableView.register(EventViewTableViewCell.self, forCellReuseIdentifier: "CellThree")
        eventTableView.rowHeight = 260
        eventTableView.dataSource = self
        eventTableView.delegate = self
        eventTableView.isOpaque = false
        eventTableView.backgroundColor = tableViewBgColor
        eventTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        mainView.addSubview(eventTableView)
        
        
        // Set pull to referseh for eventtableview
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to Refresh", comment: ""))
        refresher.addTarget(self, action: #selector(CategoryDetailViewController.refresh), for: UIControl.Event.valueChanged)
      //  eventTableView.addSubview(refresher)
        if #available(iOS 10.0, *) {
            eventTableView.refreshControl = refresher
        } else {
            // Fallback on earlier versions
            eventTableView.addSubview(refresher)
        }
        
        contentIcon = createLabel(CGRect(x: 0,y: 0,width: 0,height: 0), text: "", alignment: .center, textColor: textColorMedium )
        mainView.addSubview(contentIcon)
        contentIcon.isHidden = true
        
        refreshButton = createButton(CGRect(x: 0,y: 0,width: 0,height: 0), title: "", border: true, bgColor: true, textColor: navColor)
        mainView.addSubview(refreshButton)
        refreshButton.isHidden = true
        
        pageNumber = 1
        updateScrollFlag = false
        
        browseEntries()
        
    }

    override func viewWillAppear(_ animated: Bool)
    {
        navigationController?.navigationBar.isHidden = false
        setNavigationImage(controller: self)
        self.title = NSLocalizedString(tittle!,comment: "")
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(CategoryDetailViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
    }

    override func viewWillDisappear(_ animated: Bool)
    {
        categoryType = ""
        navigationController?.navigationBar.isHidden = false
        setNavigationImage(controller: self)
    }
    
    
    // MARK:Back Action
    @objc func goBack()
    {
        _ = self.navigationController?.popViewController(animated: false)

    }
    
    // Stop Timer
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
        
        if let _ = eventInfo["host"]
        {
            let hostInfo = eventInfo["host"] as! NSDictionary
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
    func addNewEvent()
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
                    _ = UINavigationController(rootViewController: presentedVC)

                }
            }
        }
    }
    
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
        return 0.00001
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
        cell.titleView.backgroundColor = tableViewBgColor
        cell.backgroundColor = tableViewBgColor
        
        var eventInfo:NSDictionary!
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            if(eventResponse.count > ((indexPath as NSIndexPath).row)*2 )
            {
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
        cell.contentSelection.addTarget(self, action: #selector(CategoryDetailViewController.showEvent(_:)), for: .touchUpInside)
        
        
        
        cell.hostSelection.addTarget(self, action:#selector(CategoryDetailViewController.hostProfile(_:)), for: .touchUpInside)
        
        cell.contentImage.frame.size.height = 260
        cell.lineView.frame.origin.y = cell.contentImage.frame.size.height
        cell.contentSelection.frame.size.height = 180
        
        // Set Event Image

        cell.contentImage.image = nil
        cell.contentImage.backgroundColor = placeholderColor
        if eventInfo["imageSrc"] != nil
        {
            
            if let imgdic = eventInfo["imageSrc"]as? NSDictionary
            {
                let url = URL(string: imgdic["image"] as! NSString as String)
                if url != nil {
                    cell.contentImage.kf.indicatorType = .activity
                    (cell.contentImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    cell.contentImage.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                    })
                    
                }
                else
                {
                    cell.contentImage.image = nil
                    cell.contentImage.image =  imageWithImage( UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: cell.contentImage.bounds.width)
                }
                
            }
            else
            {
                cell.hostImage.isHidden = true
                cell.hostSelection.isHidden = true
            }
            
        }
        
        
        
        
        
        //Set Profile Image
        cell.hostImage.image = nil
        cell.hostImage.backgroundColor = placeholderColor
        if eventInfo["host"] != nil
        {
            
            let imgdic = eventInfo["host"]as? NSDictionary
            
            
            if imgdic!["image_icon"] != nil
            {
                
                if let img = imgdic!["image_icon"]as? NSDictionary
                {
                    
                    let url1 = URL(string: img["image"] as! NSString as String)
                    if url1 != nil {
                        cell.hostImage.kf.indicatorType = .activity
                        (cell.hostImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                        cell.hostImage.kf.setImage(with: url1 as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in

                        })
 
                    }
                    else
                    {
                        cell.hostImage.image = nil
                        cell.hostImage.image =  imageWithImage( UIImage(named: "")!, scaletoWidth: cell.hostImage.bounds.width)
                    }
                    
                }
            }
        }
        
        let name = eventInfo["title"] as! String ?? eventInfo["event_title"] as! String
        var tempInfo = ""
        
        if let eventDate = eventInfo["starttime"] as? String
        {

            let dateMonth = dateDifferenceWithTime(eventDate)

            var dateArrayMonth = dateMonth.components(separatedBy: ", ")
            if dateArrayMonth.count > 1{
                cell.dateLabel1.frame = CGRect(x: 10, y: 5, width: 50, height: 60)
                
                cell.dateLabel1.numberOfLines = 0
                cell.dateLabel1.text = "\(dateArrayMonth[1])\n\(dateArrayMonth[0])"
                cell.dateLabel1.textColor = textColorPrime//UIColor.white
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
        
        cell.titleLabel.frame = CGRect(x: 10, y: 0, width: (cell.contentImage.bounds.width-120), height: 30)
        
        cell.titleLabel.text = name
        cell.titleLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
        
        let location = eventInfo["location"] as? String
        if location != "" && location != nil{
            
            cell.locLabel.isHidden = false
            
            cell.locLabel.frame = CGRect(x: 10, y: 25, width: (cell.contentImage.bounds.width-110), height: 20)
            cell.locLabel.text = "\u{f041}   \(location!)"
            // cell.locLabel.textColor = textColorLight
            cell.locLabel.font = UIFont(name: "FontAwesome", size: 14)
            
            
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
            cell.dateLabel.numberOfLines = 0
            //cell.dateLabel.textColor = textColorLight
            cell.dateLabel.font = UIFont(name: "FontAwesome", size: 14)
            
        }
        
        cell.menuButton.isHidden = true

        
        // RHS
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            
            cell.dateView2.isHidden = false
            cell.dateView2.frame.size.height = 80
            cell.dateView2.backgroundColor = navColor
            cell.titleView2.frame.size.height = 80
            cell.titleView2.backgroundColor = tableViewBgColor
            var eventInfo2:NSDictionary!
            if(eventResponse.count > (((indexPath as NSIndexPath).row)*2+1))
            {
                eventInfo2 = eventResponse[(((indexPath as NSIndexPath).row)*2+1)] as! NSDictionary
                cell.cellView2.isHidden = false
                cell.contentSelection2.isHidden = false
                cell.titleView2.isHidden = false
                cell.dateView2.isHidden = false
                cell.contentSelection2.tag = (((indexPath as NSIndexPath).row)*2+1)
                
                cell.hostSelection2.isHidden = false
                cell.hostSelection2.tag = (((indexPath as NSIndexPath).row)*2+1)
                
                cell.menuButton2.tag = (((indexPath as NSIndexPath).row)*2+1)
            }
            else
            {
                cell.cellView2.isHidden = true
                cell.contentSelection2.isHidden = true
                cell.hostSelection2.isHidden = true
                cell.titleView2.isHidden = true
                cell.dateView2.isHidden = true
                return cell
            }
            
            // Select Event Action
            cell.contentSelection2.addTarget(self, action: #selector(CategoryDetailViewController.showEvent(_:)), for: .touchUpInside)
            // Set MenuAction
            cell.menuButton2.addTarget(self, action:Selector(("showEventMenu:")) , for: .touchUpInside)
            cell.hostSelection2.addTarget(self, action:#selector(CategoryDetailViewController.hostProfile(_:)), for: .touchUpInside)
            
            cell.hostImage2.isHidden = false
            cell.hostSelection2.isHidden = false
            cell.hostSelection2.isUserInteractionEnabled = true
            

            
            cell.contentImage2.frame.size.height = 260
            cell.lineView2.frame.origin.y = cell.contentImage2.frame.size.height
            cell.contentSelection2.frame.size.height = 180
            
            
            
            
            if eventInfo2["imageSrc"] != nil
            {
                
                let imgdic2 = eventInfo2["imageSrc"]as? NSDictionary
                let url = URL(string: imgdic2!["image"] as! NSString as String)
                if url != nil {
                    cell.contentImage2.kf.indicatorType = .activity
                    (cell.contentImage2.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    cell.contentImage2.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        
                    })
   
                }
                else
                {
                    cell.contentImage2.image = nil
                    cell.contentImage2.image =  imageWithImage( UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: cell.contentImage2.bounds.width)
                }
                
            }
            
            
            //Set Profile Image
            cell.hostImage2.image = nil
            cell.hostImage2.backgroundColor = placeholderColor
            if eventInfo2["host"] != nil
            {
                
                if let imgdic2 = eventInfo2["host"]as? NSDictionary
                {
                    if imgdic2["image_icon"] != nil
                    {

                        if let img2 = imgdic2["image_icon"]as? NSDictionary
                        {

                            
                            let url1 = URL(string: img2["image"] as! NSString as String)
                            if url1 != nil {
                                cell.hostImage2.kf.indicatorType = .activity
                                (cell.hostImage2.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                cell.hostImage2.kf.setImage(with: url1 as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                    
                                })

                            }
                            else
                            {
                                cell.hostImage2.image = nil
                                cell.hostImage2.image =  imageWithImage( UIImage(named: "")!, scaletoWidth: cell.hostImage.bounds.width)
                            }
                        }

                    }
                }
                else
                {
                    cell.hostImage2.isHidden = true
                    cell.hostSelection2.isHidden = true

                }
            }
            
            
            // Set Event Name
            
            let name = eventInfo2["title"] as! String ?? eventInfo["event_title"] as! String
            var tempInfo = ""
            if let eventDate = eventInfo2["starttime"] as? String
            {
                
                let dateMonth = dateDifferenceWithTime(eventDate)
                var dateArrayMonth = dateMonth.components(separatedBy: ", ")
                if dateArrayMonth.count > 1{
                    cell.dateLabel3.frame = CGRect(x: 10, y: 5, width: 50, height: 60)
                    
                    cell.dateLabel3.numberOfLines = 0
                    cell.dateLabel3.text = "\(dateArrayMonth[1])\n\(dateArrayMonth[0])"
                    cell.dateLabel3.textColor = textColorPrime//UIColor.white
                    cell.dateLabel3.font = UIFont(name: "FontAwesome", size: 18)
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
            else
            {
                cell.dateView2.isHidden = true
            }
            
            
            
            cell.titleLabel2.frame = CGRect(x: 10, y: 0, width: (cell.contentImage2.bounds.width-120), height: 30)
            
            cell.titleLabel2.text = name
            cell.titleLabel2.lineBreakMode = NSLineBreakMode.byTruncatingTail
            let location = eventInfo2["location"] as? String
            if location != "" && location != nil{
                
                cell.locLabel2.isHidden = false
                
                cell.locLabel2.frame = CGRect(x: 10, y: 25, width: (cell.contentImage2.bounds.width-120), height: 20)
                cell.locLabel2.text = "\u{f041}   \(location!)"
                // cell.locLabel.textColor = textColorLight
                cell.locLabel2.lineBreakMode = NSLineBreakMode.byTruncatingTail
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
                cell.dateLabel2.lineBreakMode = NSLineBreakMode.byWordWrapping
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
                cell.dateLabel2.numberOfLines = 0
                
                
                //cell.dateLabel.textColor = textColorLight
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
    
    //MARK: Category filter
    @objc func showFeedFilterOptions(_ sender: UIButton)
    {
        // Generate Feed Filter Options Gutter Menu from Server as! Alert Popover
        let alertController = UIActionSheet(title:"Choose sub category", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil)
        alertController.tag = 0
        for menu in Subcategoryarr
        {
            
            if let menuItem = menu as? NSDictionary
            {
                let titleString = menuItem["sub_cat_name"] as! String
                alertController.addButton(withTitle: titleString)

            }
        }
        
        alertController.show(in: self.view)
        searchDic.removeAll(keepingCapacity: false)
        
        
    }

    @objc func showFeedFilterOptions1(_ sender: UIButton)
    {
        // Generate Feed Filter Options Gutter Menu from Server as! Alert Popover
        
        
        let alertController = UIActionSheet(title:"Choose Subsub category", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil)
        alertController.tag = 1
        for menu in SubSubcategoryarr
        {
            if let menuItem = menu as? NSDictionary
            {
                
                let titleString = menuItem["tree_sub_cat_name"] as! String

                alertController.addButton(withTitle: titleString)
            }
        }
        
        alertController.show(in: self.view)
        searchDic.removeAll(keepingCapacity: false)
        
        
    }
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int)
    {
        
        
        if actionSheet.tag==0
        {
            
            if buttonIndex != 0
            {
                
                let subcat = Subcategoryarr[buttonIndex-1] as! NSDictionary
                subcatid = subcat["sub_cat_id"] as! Int
                feedFilter.setTitle(subcat["sub_cat_name"] as? String, for: UIControl.State())
                subcategory = subcat["sub_cat_name"] as? String
                subsubcategory = ""
                subsubcatid = nil
                self.showSpinner = true
                browseEntries()
                
            }
            
        }
        else
        {
            if buttonIndex != 0
            {
                let subcat = SubSubcategoryarr[buttonIndex-1] as! NSDictionary
                subsubcatid = subcat["tree_sub_cat_id"] as! Int
                feedFilter2.setTitle(subcat["tree_sub_cat_name"] as? String, for: UIControl.State())
                subsubcategory = subcat["tree_sub_cat_name"] as? String
                self.showSpinner = true
                browseEntries()
                
            }
            
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
//                self.eventResponse.removeAll(keepingCapacity: false)
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
                activityIndicatorView.center = view.center
                
                if (self.pageNumber == 1)
                {
                    //spinner.center = mainView.center
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.center.y-50)
                    updateScrollFlag = false
                }
//                spinner.hidesWhenStopped = true
//                spinner.style = UIstyle.gray
//                view.addSubview(spinner)
                self.view.addSubview(activityIndicatorView)
           //     activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
            }
            var path = ""
            var parameters = [String:String]()
            if categoryType == "products"{
                  path = "sitestore/product/category"
            }
            else{
                path = "advancedevents/categories"
            }
            
            if Locationdic != nil
            {
                let defaults = UserDefaults.standard
                if let loc = defaults.string(forKey: "Location")
                {
                    if subcatid != nil && subsubcatid != nil
                    {
                        parameters = ["page":"\(pageNumber)","limit": "\(limit)","showEvents":"1","category_id":String(subjectId!),"subCategory_id":String(subcatid!),"subsubcategory_id":String(subsubcatid!),"restapilocation":"\(loc)"]
                    }
                    else if subcatid != nil
                    {
                        parameters = ["page":"\(pageNumber)","limit": "\(limit)","showEvents":"1","category_id":String(subjectId!),"subCategory_id":String(subcatid!),"restapilocation":"\(loc)"]
                        
                    }
                    else
                    {
                        parameters = ["page":"\(pageNumber)","limit": "\(limit)","showEvents":"1","category_id":String(subjectId!),"restapilocation":"\(loc)"]
                    }
                    
                }
                else
                {
                    if subcatid != nil && subsubcatid != nil
                    {
                        parameters = ["page":"\(pageNumber)","limit": "\(limit)","showEvents":"1","category_id":String(subjectId!),"subCategory_id":String(subcatid!),"subsubcategory_id":String(subsubcatid!),"restapilocation":"\(defaultlocation)"]
                    }
                    else if subcatid != nil
                    {
                        parameters = ["page":"\(pageNumber)","limit": "\(limit)","showEvents":"1","category_id":String(subjectId!),"subCategory_id":String(subcatid!),"restapilocation":"\(defaultlocation)"]
                        
                    }
                    else
                    {
                        parameters = ["page":"\(pageNumber)","limit": "\(limit)","showEvents":"1","category_id":String(subjectId!),"restapilocation":"\(defaultlocation)"]
                    }
                    
                    
                }
            }
            else
            {
                if subcatid != nil && subsubcatid != nil
                {
                    parameters = ["page":"\(pageNumber)","limit": "\(limit)","showEvents":"1","category_id":String(subjectId!),"subCategory_id":String(subcatid!),"subsubcategory_id":String(subsubcatid!)]
                }
                else if subcatid != nil
                {
                    parameters = ["page":"\(pageNumber)","limit": "\(limit)","showEvents":"1","category_id":String(subjectId!),"subCategory_id":String(subcatid!)]
                    
                }
                else
                {
                    parameters = ["page":"\(pageNumber)","limit": "\(limit)","showEvents":"1","category_id":String(subjectId!)]
                }
                
            }

            
            // Send Server Request to Browse Blog Entries
            post(parameters, url: path, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {

                    
                    if self.showSpinner
                    {
                        activityIndicatorView.stopAnimating()
                    }
                    if (self.pageNumber == 1)
                    {
                    self.eventResponse.removeAll(keepingCapacity: false)
                    }
                    self.refresher.endRefreshing()
                    self.showSpinner = true
                    self.updateScrollFlag = true
                    let subviews : NSArray = self.mainView.subviews as NSArray
                    for filterview : Any in subviews
                    {
                        if filterview is UIButton {
                            if (filterview as AnyObject).tag == 240
                            {
                                self.feedFilter2.removeFromSuperview()
                                self.eventTableView.frame = CGRect(x: 0, y: ButtonHeight, width: self.view.bounds.width,height: self.view.bounds.height-ButtonHeight)
                            }
                        }
                    }
                    
                    if msg
                    {
                        if self.pageNumber == 1
                        {
                            self.eventResponse.removeAll(keepingCapacity: false)
                            self.Subcategoryarr.removeAll(keepingCapacity: false)
                            self.SubSubcategoryarr.removeAll(keepingCapacity: false)
                            
                        }

                        
                        if succeeded["message"] != nil
                        {
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        
                        
                        if let response = succeeded["body"] as? NSDictionary
                        {
                            if response["events"] != nil
                            {
                                
                                if let blog = response["events"]as? NSArray
                                {
                                    self.eventResponse = self.eventResponse + (blog as [AnyObject])

                                }
                            }
                            
                        }
                        
                        if let response = succeeded["body"] as? NSDictionary
                        {
                            if response["subCategories"] != nil

                            {
                                
                                if let blog = response["subCategories"]as? NSArray
                                {
                                    if blog.count > 0
                                    {
                                        
                                        if self.subcategory == ""
                                        {
                                            self.feedFilter = createButton(CGRect(x: 0,y: TOPPADING ,width: self.view.bounds.width,height: ButtonHeight),title: NSLocalizedString("Choose sub category",  comment: "") , border: false, bgColor: false,textColor: textColorMedium )
                                        }
                                        else
                                        {
                                            self.feedFilter = createButton(CGRect(x: 0,y: TOPPADING ,width: self.view.bounds.width,height: ButtonHeight),title: NSLocalizedString(self.subcategory,  comment: "") , border: false, bgColor: false,textColor: textColorMedium )
                                        }
                                        
                                        self.feedFilter.isEnabled = true
                                        self.feedFilter.backgroundColor = lightBgColor
                                        self.feedFilter.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
                                        self.feedFilter.addTarget(self, action: #selector(CategoryDetailViewController.showFeedFilterOptions(_:)), for: .touchUpInside)
                                        self.mainView.addSubview(self.feedFilter)
                                        
                                        // Filter Icon on Left site
                                        let filterIcon = createLabel(CGRect(x: self.feedFilter.bounds.width - self.feedFilter.bounds.height, y: 0 , width: self.feedFilter.bounds.height , height: self.feedFilter.bounds.height), text: "\u{f107}", alignment: .center, textColor: textColorMedium)
                                        filterIcon.font = UIFont(name: "fontAwesome", size: FONTSIZELarge)
                                        self.feedFilter.addSubview(filterIcon)
                                        
                                        self.eventTableView.frame = CGRect(x: 0,y: ButtonHeight, width: self.view.bounds.width, height: self.view.bounds.height-ButtonHeight)
                                        self.Subcategoryarr  =  self.Subcategoryarr + (blog as [AnyObject])
                                        
                                        
                                    }

                                }
                            }

                        }
                        
                        
                        if let response1 = succeeded["body"] as? NSDictionary
                        {
                            if response1["subsubCategories"] != nil
                            {
                                
                                if let blog1 = response1["subsubCategories"]as? NSArray
                                {
                                    if blog1.count > 0
                                    {
                                        self.SubSubcategoryarr = self.SubSubcategoryarr + (blog1 as [AnyObject])
                                        
                                        if self.subsubcategory == ""
                                        {
                                            self.feedFilter2 = createButton(CGRect(x: 0,y: ButtonHeight + TOPPADING, width: self.view.bounds.width, height: ButtonHeight),title: NSLocalizedString("Choose 3rd level category",  comment: "") , border: false, bgColor: false,textColor: textColorMedium )

                                        }
                                        else
                                        {
                                            self.feedFilter2 = createButton(CGRect(x: 0,y: ButtonHeight + TOPPADING, width: self.view.bounds.width, height: ButtonHeight),title: NSLocalizedString(self.subsubcategory,  comment: "") , border: false, bgColor: false,textColor: textColorMedium )
                                        }
                                        
                                        self.feedFilter2.isEnabled = true
                                        self.feedFilter2.tag = 240
                                        self.feedFilter2.backgroundColor = lightBgColor
                                        self.feedFilter2.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
                                        self.feedFilter2.addTarget(self, action: #selector(CategoryDetailViewController.showFeedFilterOptions1(_:)), for: .touchUpInside)
                                        self.mainView.addSubview(self.feedFilter2)
                                        
                                        // Filter Icon on Left site
                                        let filterIcon1 = createLabel(CGRect(x: self.feedFilter2.bounds.width - self.feedFilter2.bounds.height, y: 0 ,width: self.feedFilter2.bounds.height ,height: self.feedFilter2.bounds.height), text: "\u{f107}", alignment: .center, textColor: textColorMedium)
                                        filterIcon1.font = UIFont(name: "fontAwesome", size: FONTSIZELarge)
                                        self.feedFilter2.addSubview(filterIcon1)
                                        
                                        self.eventTableView.frame = CGRect(x: 0, y: ButtonHeight+ButtonHeight, width: self.view.bounds.width,height: self.view.bounds.height-(2*ButtonHeight))
                                        
                                        
                                    }
                                }

                            }
                            
                        }
                        
                        self.isPageRefresing = false
                        // Reload Event Tabel
                        self.eventTableView.reloadData()
                        //    if succeeded["message"] != nil{
                        if self.eventResponse.count == 0
                        {
                            
                            self.contentIcon = createLabel(CGRect(x: self.view.bounds.width/2 - 30,y: self.view.bounds.height/2-80,width: 60 , height: 60), text: NSLocalizedString("\(eventIcon)",  comment: "") , alignment: .center, textColor: textColorMedium)
                            self.contentIcon.font = UIFont(name: "FontAwesome", size: 50)
                            self.mainView.addSubview(self.contentIcon)
                            self.info = createLabel(CGRect(x: self.view.bounds.width * 0.1, y: self.contentIcon.frame.origin.y+self.contentIcon.frame.size.height,width: self.view.bounds.width * 0.8 , height: 50), text: NSLocalizedString("You do not have any events matching this criteria.",  comment: "") , alignment: .center, textColor: textColorMedium)
                            self.info.numberOfLines = 0
                            self.info.lineBreakMode = NSLineBreakMode.byWordWrapping
                            //self.info.center = self.view.center
                            self.info.backgroundColor = bgColor
                            self.info.tag = 1000
                            self.mainView.addSubview(self.info)


                            self.refreshButton = createButton(CGRect(x: self.view.bounds.width/2-40, y: self.info.bounds.height + self.info.frame.origin.y, width: 80, height: 40), title: NSLocalizedString("Try Again",  comment: ""), border: true, bgColor: true, textColor: navColor)
                            self.refreshButton.backgroundColor = bgColor
                            self.refreshButton.layer.borderColor = navColor.cgColor
                            self.refreshButton.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
                            self.refreshButton.addTarget(self, action: #selector(CategoryDetailViewController.browseEntries), for: UIControl.Event.touchUpInside)
                            self.refreshButton.layer.cornerRadius = 5.0
                            self.refreshButton.layer.masksToBounds = true
                            self.mainView.addSubview(self.refreshButton)
                            self.refreshButton.isHidden = false
                            self.contentIcon.isHidden = false
                            
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
    func createTimer(_ target: AnyObject){
        timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  #selector(stopTimer), userInfo: nil, repeats: false)
    }
}
