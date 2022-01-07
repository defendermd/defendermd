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
class InfoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,TTTAttributedLabelDelegate {
    
    var user_id : Int!
    var userinfoTableView1 : UITableView!
    var servResponse = [AnyObject]()
    var count1 : Int!
    var dic : NSDictionary!
    var dynamicHeight : CGFloat = 50
    var subjectId : String!
    var mytitle : String!
    var url:String!
    var leftBarButtonItem : UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = NSLocalizedString("Information",  comment: "")
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        setNavigationImage(controller: self)
        
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(InfoViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem


        userinfoTableView1 = UITableView(frame: CGRect(x: 0,y: -35 , width: view.bounds.width, height: view.bounds.height+35), style: .grouped)
        userinfoTableView1.register(UserInfoTableViewCell.self, forCellReuseIdentifier: "Cell")
        userinfoTableView1.estimatedRowHeight = 50.0
        userinfoTableView1.rowHeight = UITableView.automaticDimension
        userinfoTableView1.backgroundColor = tableViewBgColor
        userinfoTableView1.separatorColor = TVSeparatorColor
        view.addSubview(userinfoTableView1)
  
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getUserInfo()
    }
    
    func getUserInfo(){
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            if url == nil
            {
                url = "advancedevents/information/\(subjectId!)"
            }

           
            // Send Server Request to Explore Blog Contents with Blog_ID
            post(["subject_id":"\(subjectId)", "feed_filter": "1", "maxid": "0", "post_menus": "1"], url: url, method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return dynamicHeight
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    // Set no. of sections in TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Set no. of rows in Every section of TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return dic.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UserInfoTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        var subChild = [AnyObject]()
        var subValue = [AnyObject]()
        var array3 = [String]()
        for (key,value) in dic{
            array3.append(key as! String)
            subChild.append(key as! String as AnyObject)
            if value is String
            {
                subValue.append(value as! String as AnyObject)
            }
            else if value is CGFloat
            {
                let floatValue = String(describing: value)
                subValue.append(floatValue as AnyObject)
            }
            else if value is Int
            {
                let intValue = String(describing: value)
                subValue.append(intValue as AnyObject)
            }
            //subValue.append(value as! String as AnyObject)
        }
        
        let i = subChild.count
        
        for _ in stride(from: 0, to: i, by: 1){

            cell.label1?.text = subChild[(indexPath as NSIndexPath).row] as? String
            cell.label2.numberOfLines = 0
            cell.label2.lineBreakMode = NSLineBreakMode.byWordWrapping
            cell.label2?.text =  subValue[(indexPath as NSIndexPath).row] as? String
            cell.label2.sizeToFit()
        }
        
        dynamicHeight = 50
        
        if dynamicHeight < (cell.label2.frame.origin.y + cell.label2.bounds.height + 5)
        {
            dynamicHeight = (cell.label2.frame.origin.y + cell.label2.bounds.height + 10)
        }
        return cell
        
    }
    
    // Generate Form On View Appear
    func showAlertMessage( _ centerPoint: CGPoint, msg: String , timer: Bool){
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
        _ = navigationController?.popViewController(animated: true)
    }
    @objc func goBack()
    {
        _ = self.navigationController?.popViewController(animated: true)

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}
