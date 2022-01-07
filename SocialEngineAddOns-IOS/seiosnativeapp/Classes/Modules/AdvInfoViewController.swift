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
//  UserInfoViewController.swift
//  seiosnativeapp
//

import UIKit
class AdvInfoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,TTTAttributedLabelDelegate {
    
    var user_id : Int!
    var userinfoTableView1 : UITableView!
    var servResponse = [AnyObject]()
    var count1 : Int!
    var dic : NSDictionary!
    var dynamicHeight : CGFloat = 50
    var subjectId : Int!
    var mytitle : String!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = NSLocalizedString("Information",  comment: "")
        view.backgroundColor = bgColor
        navigationController?.navigationBar.hidden = false
        self.navigationController?.navigationBar.setBackgroundImage(imagefromColor(navColor), forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = imagefromColor(navColor)
        self.navigationController?.navigationBar.translucent = true
        self.navigationController?.navigationBar.tintColor = textColorLight
        
        
        let leftNavView = UIView(frame: CGRectMake(0, 0, 44, 44))
        leftNavView.backgroundColor = UIColor.clearColor()
        let tapView = UITapGestureRecognizer(target: self, action: Selector("goBack"))
        leftNavView.addGestureRecognizer(tapView)
        
        
        let backIconImageView = createImageView(CGRectMake(0,12,22,22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem

        
        
        
        userinfoTableView1 = UITableView(frame: CGRectMake(0,-35 , CGRectGetWidth(view.bounds), CGRectGetHeight(view.bounds)+35), style: .Grouped)
        userinfoTableView1.registerClass(UserInfoTableViewCell.self, forCellReuseIdentifier: "Cell")
        userinfoTableView1.estimatedRowHeight = 50.0
        userinfoTableView1.rowHeight = UITableViewAutomaticDimension
        userinfoTableView1.backgroundColor = tableViewBgColor
        userinfoTableView1.separatorColor = TVSeparatorColor
        view.addSubview(userinfoTableView1)
    }
    
    override func viewDidAppear(animated: Bool) {
        getUserInfo()
    }
    
    func getUserInfo(){
        if reachability.isReachable() {
            removeAlert()
            spinner.center = view.center
            spinner.hidesWhenStopped = true
            spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            view.addSubview(spinner)
            spinner.startAnimating()
            
            // Send Server Request to Explore Blog Contents with Blog_ID
            post(["subject_id":"\(subjectId)", "feed_filter": "1", "maxid": "0", "post_menus": "1"], url: "advancedevents/information/\(subjectId)", method: "GET") { (succeeded, msg) -> () in
                dispatch_async(dispatch_get_main_queue(),{
                    spinner.stopAnimating()
                    
                    if msg{
                        self.dic = succeeded["body"] as! NSDictionary
                        self.count1 = self.dic.count
                        self.userinfoTableView1.dataSource = self
                        self.userinfoTableView1.delegate = self
                        self.userinfoTableView1.reloadData()
                    }
                    
                })
            }
        }else{
            // No Internet Connection Message
            showAlertMessage(view.center , msg: network_status_msg , timer: false)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return dynamicHeight
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    // Set no. of sections in TableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // Set no. of rows in Every section of TableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return dic.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UserInfoTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        var subChild = [AnyObject]()
        var subValue = [AnyObject]()
        var array3 = [String]()
        for (key,value) in dic{
            array3.append(key as! String)
            subChild.append(key as! String)
            subValue.append(value as! String)
        }
        
        let i = subChild.count
        var b : Int
        for  b = 0 ; b < i ; b++ {
            cell.label1?.text = subChild[indexPath.row] as? String
            cell.label2.numberOfLines = 0
            cell.label2.lineBreakMode = NSLineBreakMode.ByWordWrapping
            cell.label2?.text =  subValue[indexPath.row] as? String
            cell.label2.sizeToFit()
        }
        dynamicHeight = 50
        
        if dynamicHeight < (cell.label2.frame.origin.y + CGRectGetHeight(cell.label2.bounds) + 5)
        {
            dynamicHeight = (cell.label2.frame.origin.y + CGRectGetHeight(cell.label2.bounds) + 10)
        }
        return cell
        
    }
    
    // Generate Form On View Appear
    func showAlertMessage( centerPoint: CGPoint, msg: String , timer: Bool){
        self.view .addSubview(validationMsg)
        showCustomAlert(centerPoint, msg: msg)
        if timer {
            // Initialization of Timer
            createTimer(self)
        }
    }
    
    
    func goBack()
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}