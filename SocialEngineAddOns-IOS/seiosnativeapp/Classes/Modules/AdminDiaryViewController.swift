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

//  AdminDiaryViewController.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 01/02/16.
//  Copyright © 2016 bigstep. All rights reserved.
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


class AdminDiaryViewController: UIViewController,UITableViewDelegate,UITableViewDataSource
{
    let mainView = UIView()
    var DiaryTableView:UITableView!
    var url:String!
    var tittle:String!
    var param: NSDictionary = [:]
    
    
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var updateScrollFlag = true
    var eventResponse = [AnyObject]()
    var refresher:UIRefreshControl!
    var refreshButton : UIButton!
    var showSpinner = true
  //  var imageArr:[UIImage]=[]
   // var imageCache = [String:UIImage]()
    var leftBarButtonItem : UIBarButtonItem!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        eventUpdate = true
        view.backgroundColor = bgColor
        mainView.frame = view.frame
        mainView.backgroundColor = bgColor
        view.addSubview(mainView)
        mainView.removeGestureRecognizer(tapGesture)
        
        
        navigationController?.navigationBar.isHidden = false
        setNavigationImage(controller: self)
        
        self.title = NSLocalizedString("\(tittle)",  comment: "")
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(AdminDiaryViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem

        
        // Set tableview to show Diaries
        DiaryTableView = UITableView(frame: CGRect(x: 0, y: 0 , width: view.bounds.width, height: view.bounds.height - tabBarHeight), style: .grouped)
        DiaryTableView.register(DiaryTableViewCell.self, forCellReuseIdentifier: "Cell")
        DiaryTableView.rowHeight = 200
        DiaryTableView.dataSource = self
        DiaryTableView.delegate = self
        DiaryTableView.isOpaque = false
        DiaryTableView.backgroundColor = tableViewBgColor
        DiaryTableView.showsVerticalScrollIndicator = false
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            DiaryTableView.estimatedRowHeight = 0
            DiaryTableView.estimatedSectionHeaderHeight = 0
            DiaryTableView.estimatedSectionFooterHeight = 0
        }
        mainView.addSubview(DiaryTableView)
        
        
        // Set pull to referseh for eventtableview
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to Refresh", comment: ""))
        refresher.addTarget(self, action: Selector(("refresh")), for: UIControl.Event.valueChanged)
        DiaryTableView.addSubview(refresher)
        
    
        
    }
    
    // MARK:Back Action
    @objc func goBack()
    {
        _ = self.navigationController?.popViewController(animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        
        if eventUpdate == true
        {
            eventUpdate = false
            pageNumber = 1
            showSpinner = true
            updateScrollFlag = false
            browseEntries()
        }
        navigationController?.navigationBar.isHidden = false
        setNavigationImage(controller: self)
        
    }
    //MARK:Diary section
    
    @objc func coverSelection(_ sender:UIButton)
    {
        
        if openMenu
        {
            openMenu = false
            openMenuSlideOnView(mainView)
            return
        }
        
        
        var eventInfo:NSDictionary!
        eventInfo = eventResponse[sender.tag] as! NSDictionary
        
        
        let presentedVC = DiaryDetailViewController()
        presentedVC.subjectId = eventInfo["diary_id"] as! Int
        presentedVC.totalItemCount = eventInfo["total_item"] as! Int
        presentedVC.diaryName = eventInfo["title"] as! String
        presentedVC.IScomingfrom = "Diary"
        navigationController?.pushViewController(presentedVC, animated: true)
        
        
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
        return 202.0
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
        let cell = DiaryTableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! DiaryTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        var eventInfo:NSDictionary!
        
        
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            if(eventResponse.count > ((indexPath as NSIndexPath).row)*2)
            {
                eventInfo = eventResponse[((indexPath as NSIndexPath).row)*2] as! NSDictionary
                cell.coverSelection.tag = ((indexPath as NSIndexPath).row)*2
                cell.coverImage.tag = ((indexPath as NSIndexPath).row)*2
                
            }
        }
        else
        {
            eventInfo = eventResponse[(indexPath as NSIndexPath).row] as! NSDictionary
            cell.coverSelection.tag = (indexPath as NSIndexPath).row
            cell.coverImage.tag = (indexPath as NSIndexPath).row
            
        }
        
        cell.coverSelection.addTarget(self, action: #selector(AdminDiaryViewController.coverSelection(_:)), for: .touchUpInside)
        let name = eventInfo["title"] as? String
        cell.titleLabel.text = "\(name!)"
        
        
        let count = eventInfo["total_item"] as? Int
        if count != nil
        {
            cell.countLabel.text = "\(count!)"
        }
        
        
        if count>0
        {
            if count==1
            {
                
                cell.coverImage.isHidden = false
                cell.coverImage1.isHidden = true
                cell.coverImage2.isHidden = true
                cell.coverImage3.isHidden = true
                cell.coverImage4.isHidden = true
                cell.coverImage5.isHidden = true
                cell.coverImage.image = UIImage(named: "nophoto_diary_thumb_profile.png")
             //   imageArr.removeAll()
                let imagedic = eventInfo["images_1"] as! NSDictionary
                let url = URL(string: imagedic["image"] as! NSString as String)
                
                if url != nil {
                    cell.coverImage.kf.indicatorType = .activity
                    (cell.coverImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    cell.coverImage.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        
                    })
                    
                }
                
            }
            else if count==2
            {
                cell.coverImage.isHidden = true
                cell.coverImage1.isHidden = true
                cell.coverImage2.isHidden = true
                cell.coverImage3.isHidden = true
                cell.coverImage4.isHidden = false
                cell.coverImage5.isHidden = false
                
                cell.coverImage4.setImage(UIImage(named: "nophoto_diary_thumb_profile.png"), for: UIControl.State())
                cell.coverImage5.setImage(UIImage(named: "nophoto_diary_thumb_profile.png"), for: UIControl.State())
                
                let imagedic1 = eventInfo["images_1"] as! NSDictionary
                let imagedic2 = eventInfo["images_2"] as! NSDictionary
                
                let url1 = URL(string: imagedic1["image"] as! NSString as String)
                if url1 != nil {

                    cell.coverImage4.kf.setImage(with: url1, for: .normal, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                        
                    })
                    
                }
                
                let url2 = URL(string: imagedic2["image"] as! NSString as String)
                if url2 != nil {

                    cell.coverImage5.kf.setImage(with: url2, for: .normal, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                        
                    })
                    
                }
                
                
            }
            else if count==3 || count > 3
            {
                cell.coverImage.isHidden = true
                cell.coverImage4.isHidden = true
                cell.coverImage5.isHidden = true
                
                cell.coverImage1.isHidden = false
                cell.coverImage2.isHidden = false
                cell.coverImage3.isHidden = false
                
                cell.coverImage1.image = UIImage(named: "nophoto_diary_thumb_profile.png")
                cell.coverImage2.image = UIImage(named: "nophoto_diary_thumb_profile.png")
                cell.coverImage2.image = UIImage(named: "nophoto_diary_thumb_profile.png")
                let imagedic3 = eventInfo["images_1"] as! NSDictionary
                let imagedic4 = eventInfo["images_2"] as! NSDictionary
                let imagedic5 = eventInfo["images_3"] as! NSDictionary
                
                let url3 = URL(string: imagedic3["image"] as! NSString as String)
                if url3 != nil {

                    cell.coverImage1.kf.setImage(with: url3, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                        
                    })
                }
                
                let url4 = URL(string: imagedic4["image"] as! NSString as String)
                if url4 != nil {
                    cell.coverImage2.kf.setImage(with: url4, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                        
                    })
                    
                }
                
                let url5 = URL(string: imagedic5["image"] as! NSString as String)
                if url5 != nil {
                    cell.coverImage3.kf.setImage(with: url5, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                        
                    })
                }
                
            }
        }
        else
        {
            if count != nil
            {
             //   imageArr.removeAll()
                cell.coverImage.isHidden = false
                cell.coverImage1.isHidden = true
                cell.coverImage2.isHidden = true
                cell.coverImage3.isHidden = true
                cell.coverImage4.isHidden = true
                cell.coverImage5.isHidden = true
                cell.coverImage.image = UIImage(named: "nophoto_diary_thumb_profile.png")
                
                let imagedic = eventInfo["images_0"] as! NSDictionary
                let url = URL(string: imagedic["image"] as! NSString as String)
                if url != nil {
                    cell.coverImage.kf.indicatorType = .activity
                    (cell.coverImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    cell.coverImage.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        
                    })
                }
            }
        }
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            
            
            cell.lineView2.isHidden = false
            var eventInfo2:NSDictionary!
            if(eventResponse.count > (((indexPath as NSIndexPath).row)*2+1))
            {
                eventInfo2 = eventResponse[(((indexPath as NSIndexPath).row)*2+1)] as! NSDictionary
                
                
                cell.cellView2.isHidden = false
                cell.lineView2.isHidden = false
                cell.coverSelection2.isHidden = false
                cell.coverSelection2.tag = (((indexPath as NSIndexPath).row)*2+1)
            }
            else
            {
                cell.cellView2.isHidden = true
                cell.lineView2.isHidden = true
                
            }
            cell.coverSelection2.addTarget(self, action: #selector(AdminDiaryViewController.coverSelection(_:)), for: .touchUpInside)
            let name = eventInfo2["title"] as? String
            cell.titleLabel2.text = "\(name!)"
            
            
            let count = eventInfo2["total_item"] as? Int
            if count != nil
            {
                cell.countLabel2.text = "\(count!)"
            }
            
            
            if count>0
            {
                if count==1
                {
                    cell.coverImage6.isHidden = false
                    cell.coverImage7.isHidden = true
                    cell.coverImage8.isHidden = true
                    cell.coverImage9.isHidden = true
                    cell.coverImage10.isHidden = true
                    cell.coverImage11.isHidden = true
                    
                    
                    let imagedic6 = eventInfo2["images_1"] as! NSDictionary
                    let url6 = URL(string: imagedic6["image"] as! NSString as String)
                    if url6 != nil {
                        cell.coverImage6.kf.setImage(with: url6, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                            
                        })
                    }
                    
                }
                else if count==2
                {
                    cell.coverImage6.isHidden = true
                    cell.coverImage7.isHidden = true
                    cell.coverImage8.isHidden = true
                    cell.coverImage9.isHidden = true
                    cell.coverImage10.isHidden = false
                    cell.coverImage11.isHidden = false
                    
                    
                    
                    let imagedic7 = eventInfo2["images_1"] as! NSDictionary
                    let imagedic8 = eventInfo2["images_2"] as! NSDictionary
                    let url7 = URL(string: imagedic7["image"] as! NSString as String)
                    if url7 != nil {
                        cell.coverImage10.kf.setImage(with: url7, for: .normal, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                            
                        })
                        
                    }
                    
                    let url8 = URL(string: imagedic8["image"] as! NSString as String)
                    if url8 != nil {

                        cell.coverImage11.kf.setImage(with: url8, for: .normal, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                            
                        })
                        
                    }
                    
                }
                else if count==3 || count > 3
                {
                    cell.coverImage6.isHidden = true
                    cell.coverImage10.isHidden = true
                    cell.coverImage11.isHidden = true
                    
                    cell.coverImage7.isHidden = false
                    cell.coverImage8.isHidden = false
                    cell.coverImage9.isHidden = false
                    
                    let imagedic9 = eventInfo2["images_1"] as! NSDictionary
                    let imagedic10 = eventInfo2["images_2"] as! NSDictionary
                    let imagedic11 = eventInfo2["images_3"] as! NSDictionary
                    
                    let url9 = URL(string: imagedic9["image"] as! NSString as String)
                    if url9 != nil {

                        cell.coverImage7.kf.setImage(with: url9, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                            
                        })
                    }
                    
                    let url10 = URL(string: imagedic10["image"] as! NSString as String)
                    if url10 != nil {
                        cell.coverImage8.kf.setImage(with: url10, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                            
                        })
                        
                    }
                    
                    let url11 = URL(string: imagedic11["image"] as! NSString as String)
                    if url11 != nil {
                        cell.coverImage9.kf.setImage(with: url11, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                            
                        })
                    }
                }
            }
            else
            {
                if count != nil
                {
                    
                    cell.coverImage6.isHidden = false
                    cell.coverImage7.isHidden = true
                    cell.coverImage8.isHidden = true
                    cell.coverImage9.isHidden = true
                    cell.coverImage10.isHidden = true
                    cell.coverImage11.isHidden = true
                    
                    let imagedic = eventInfo2["images_0"] as! NSDictionary
                    let url = URL(string: imagedic["image"] as! NSString as String)
                    if url != nil {
                        cell.coverImage6.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                            
                        })
                    }
                }
                
                
                
            }
            return cell
        }
        
        return cell
    }
    
    // Handle Blog Table Cell Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    //MARK:Collage image creator
    func collageImage (_ rect:CGRect, images:[UIImage]) -> UIImage
    {
        
        let maxSide = max(rect.width / CGFloat(images.count), rect.height / CGFloat(images.count)) //* 0.80
        //let rowHeight = rect.height / CGFloat(images.count) * 0.8
        let maxImagesPerRow = 3
        var index = 0
        var currentRow = 1
        var xtransform:CGFloat = 0.0
        var ytransform:CGFloat = 0.0
        var smallRect:CGRect = CGRect.zero
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
        
        for img in images {
            
            index = index + 1
            
            let x = index % maxImagesPerRow //row should change when modulus is 0
            
            //row changes when modulus of counter returns zero @ maxImagesPerRow
            if x == 0 {
                //last column of current row
                //xtransform += CGFloat(maxSide)
                smallRect = CGRect(x: xtransform, y: ytransform, width: maxSide, height: 250)
                
                //reset for new row
                currentRow += 1
                xtransform = 0.0
                ytransform = (maxSide * CGFloat(currentRow - 1))
                
            }
            else
            {
                //not a new row
                if xtransform == 0
                {
                    //this is first column
                    //draw rect at 0,ytransform
                    smallRect = CGRect(x: xtransform, y: ytransform, width: maxSide, height: 250)
                    xtransform += CGFloat(maxSide)
                }
                else
                {
                    //not the first column so translate x, ytransform to be reset for new rows only
                    smallRect = CGRect(x: xtransform, y: ytransform, width: maxSide, height: 250)
                    xtransform += CGFloat(maxSide)
                }
                
            }
            
            //draw in rect
            img.draw(in: smallRect)
            
        }
        
        let outputImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        return outputImage!
    }
    
    // MARK: - Server Connection For Event Updation
    func browseEntries()
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
            //
            if (self.pageNumber == 1)
            {
                self.eventResponse.removeAll(keepingCapacity: false)
                if updateAfterAlert == true
                {
                    removeAlert()
                    self.DiaryTableView.reloadData()
                }
                else
                {
                    updateAfterAlert = true
                }
            }
            
            
            
            if (showSpinner)
            {
 //               spinner.center = view.center
                if updateScrollFlag == false
                {
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height)
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
             //   activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
            }
            var path = ""
            var parameters = [String:String]()
            let member = param["member"] as! String
            
            
            path = url
            parameters = ["page":"\(pageNumber)", "limit": "\(limit)","member":"\(member)"]
            self.title = NSLocalizedString((tittle),  comment: "")
            
            
            
            
            
            // Send Server Request to Browse Blog Entries
            post(parameters, url: path, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    
                    if self.showSpinner
                    {
                        activityIndicatorView.stopAnimating()
                    }
                    self.refresher.endRefreshing()
                    self.showSpinner = true
                    self.updateScrollFlag = true
                    
                    
                    if msg
                    {
                        if let response = succeeded["body"] as? NSDictionary
                        {
                            if response["response"] != nil
                            {
                                if let blog = response["response"] as? NSArray
                                {
                                    self.eventResponse = self.eventResponse + (blog as [AnyObject])
                                }
                                
                            }
                            
                        }
                        self.DiaryTableView.reloadData()
                        
                        
                    }
                    else
                    {
                        // Handle Server Error
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
    
    
}
