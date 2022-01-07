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


//  AnnouncementViewController.swift
//  seiosnativeapp
//
//  Created by bigstep on 18/02/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class AnnouncementViewController: UIViewController,TTTAttributedLabelDelegate,UITableViewDataSource, UITableViewDelegate {
    
    var subjectId : String!
    var ancmntTableView : UITableView!
    var ancmntResponse = [AnyObject]()
    var totalItem : Int = 0
    var pageNumber:Int = 1
    var showSpinner = true
    var dynamicHeight:CGFloat = 70
    var mytitle: String!
    var leftBarButtonItem :UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = bgColor
        
        // self.title = "Announcement"
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(AnnouncementViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        ancmntTableView = UITableView(frame: CGRect(x: 0, y: 0  , width: view.bounds.width, height: view.bounds.height), style: .grouped)
        ancmntTableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "Cell")
        ancmntTableView.dataSource = self
        ancmntTableView.delegate = self
        ancmntTableView.estimatedRowHeight = 70
        ancmntTableView.rowHeight = UITableView.automaticDimension
        ancmntTableView.backgroundColor = tableViewBgColor
        ancmntTableView.separatorColor = TVSeparatorColor
        view.addSubview(ancmntTableView)
        
        
        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        ancmntTableView.tableFooterView = footerView
        ancmntTableView.tableFooterView?.isHidden = true
  
        announcement()
        
        // Do any additional setup after loading the view.
    }
    override func viewWillDisappear(_ animated: Bool) {
        
         ancmntTableView.tableFooterView?.isHidden = true
    }
    func announcement(){
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            view.addSubview(spinner)
            if showSpinner
            {
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            }
            // Send Server Request to Explore Blog Contents with Blog_ID
            post([ "menu": "1","page":"\(pageNumber)" , "limit": "\(limit)"], url: "advancedevents/announcement/\(subjectId)", method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    
                    if self.showSpinner
                    {
                        activityIndicatorView.stopAnimating()
                    }
                    self.showSpinner = false
                   
                    
                    if msg{
                        // On Success Update Blog Detail
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        
                        
                        
                        if let blog = succeeded["body"] as? NSDictionary {
                            
                            
                            if let response = blog["announcements"] as? NSArray {
                                
                                self.ancmntResponse = self.ancmntResponse + (response as [AnyObject])
                                
                                
                                
                            }
                            if blog["itemCount"] != nil{
                                self.totalItem = blog["itemCount"] as! Int
                            }
                            self.title = "Announcements(\(self.totalItem)):\(self.mytitle)"
                            
                        }
                        
                        self.ancmntTableView.reloadData()
                    }
                })
                
                
            }
        }else{
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self)
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (limit*pageNumber < totalItem){
            return 0
            
        }else{
            return 0.00001
        }
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
        
        return ancmntResponse.count
    }
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        var ancmntInfo:NSDictionary
        ancmntInfo = ancmntResponse[(indexPath as NSIndexPath).row] as! NSDictionary
        
        cell.imageview.isHidden = true
        cell.imgUser.isHidden = true
        
        // Set Blog Title
        cell.labTitle.frame = CGRect( x: 10, y: 10,width: (view.bounds.width - 10) , height: 20)
        cell.labTitle.text = ancmntInfo["title"] as? String
        cell.labTitle.numberOfLines = 0
        cell.labTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        cell.labTitle.font = UIFont(name: fontName, size: FONTSIZELarge)
        cell.labTitle.sizeToFit()
        cell.labTitle.isHidden = false
        
        
        cell.labMessage.frame = CGRect( x: 10, y: cell.labTitle.frame.origin.y + cell.labTitle.bounds.height + 5,width: (view.bounds.width - 10) , height: 50)
        var labMsg = ""
        labMsg = ancmntInfo["body"] as! String
        
        cell.labMessage.setText(labMsg, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
            let boldFont = CTFontCreateWithName((fontName as CFString?)!, FONTSIZEMedium, nil)
            
            let range = (labMsg as NSString).range(of: labMsg)
            mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: (kCTFontAttributeName as NSString) as String as String), value: boldFont, range: range)
            mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: (kCTForegroundColorAttributeName as NSString) as String as String), value: textColorMedium, range: range)
            
            // TODO: Clean this up..
            return mutableAttributedString
        })
        
        
        cell.labMessage.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.labMessage.sizeToFit()
        cell.labMessage.isHidden = false
        dynamicHeight = 70
        
        if dynamicHeight < (cell.labTitle.frame.origin.y + cell.labTitle.bounds.height + cell.labMessage.bounds.height + 5)
        {
            dynamicHeight = (cell.labTitle.frame.origin.y + cell.labTitle.bounds.height + cell.labMessage.bounds.height + 5) + 10
        }
        return cell
    }
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//
//        //if updateScrollFlag{
//        // Check for Page Number for Browse Blog
//        if ancmntTableView.contentOffset.y >= ancmntTableView.contentSize.height - ancmntTableView.bounds.size.height{
//            if ( limit*pageNumber < totalItem){
//                if Reachabable.isConnectedToNetwork() {
//                    //updateScrollFlag = false
//                    pageNumber += 1
//                    // isPageRefresing = true
//                    // if searchDic.count == 0{
//                    announcement()
//                    //}
//                }
//            }
//
//        }
//
//        // }
//
//    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if maximumOffset - currentOffset <= 10
        {
            if ( limit*pageNumber < totalItem){
                if Reachabable.isConnectedToNetwork() {
                    //updateScrollFlag = false
                    pageNumber += 1
                    // isPageRefresing = true
                    // if searchDic.count == 0{
                     ancmntTableView.tableFooterView?.isHidden = false
                    announcement()
                    //}
                }
            }
            else
            {
                ancmntTableView.tableFooterView?.isHidden = true
            }
            
        }
        
    }
    
    @objc func goBack()
    {
        _ = self.navigationController?.popViewController(animated: false)
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
