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
class UserInfoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TTTAttributedLabelDelegate {
    
    var user_id : String! = ""
    var userinfoTableView1 : UITableView!
    var servResponse = [AnyObject]()
    var count1 : Int!
    var dic : NSDictionary!
    var dynamicHeight : CGFloat = 50
    var sectionCount : Int!
    var count : Int!
    var check = ""
    var rowCheck = ""
    var rowCount1 : Int!
    var ab = [String]()
    var scrollView  :UIScrollView!
    var contentId: String!
    var contentUrl: String!
    var mainSubView:UIView!
    var profileView = UIView()
    var label1 : TTTAttributedLabel!
    var label3 : TTTAttributedLabel!
    var label5 : TTTAttributedLabel!
    var label6 : TTTAttributedLabel!
    var leftBarButtonItem : UIBarButtonItem!
    var profileInfo : NSArray!
    var heading : String = ""
    
    var noInfoIcon : UIImageView!
    var noInfoMessage : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = NSLocalizedString("Info",  comment: "")
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(UserInfoViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        
        userinfoTableView1 = UITableView(frame: CGRect(x: 0, y: 5  , width: view.bounds.width, height: view.bounds.height-5 ), style: .grouped)
        userinfoTableView1.register(UserInfoTableViewCell.self, forCellReuseIdentifier: "Cell")
        
        userinfoTableView1.estimatedRowHeight = 50.0
        userinfoTableView1.rowHeight = UITableView.automaticDimension
        userinfoTableView1.backgroundColor = tableViewBgColor
        userinfoTableView1.separatorColor = TVSeparatorColor

        scrollView = UIScrollView(frame: UIScreen.main.bounds)
        view.addSubview(scrollView)
        profileView = createView(CGRect(x:PADING, y:0, width:view.bounds.width - 2 * PADING, height:view.bounds.height-tabBarHeight-TOPPADING), borderColor: borderColorDark, shadow: false)
        profileView.layer.borderWidth = 0.0
        profileView.isHidden = true
        
        scrollView.addSubview(profileView)
        
        
        label1 = TTTAttributedLabel(frame:CGRect(x:PADING, y:10, width:profileView.bounds.width - PADING , height:30) )
        label3 = TTTAttributedLabel(frame:CGRect(x:PADING, y:10, width:profileView.bounds.width - PADING , height:30) )
        label1.isHidden = true
        label3.isHidden = true
        
        profileView.addSubview(label1)
        profileView.addSubview(label3)
        
        
        noInfoIcon = createImageView(CGRect(x: self.profileView.bounds.width/2 - 40, y: self.profileView.bounds.height/2-(63), width: 80, height: 80), border: false)
        noInfoIcon.image = UIImage(named: "no_info_icon.png")
        noInfoIcon.isHidden = true
        noInfoIcon.contentMode = .scaleAspectFit
        profileView.addSubview(noInfoIcon)
        
        noInfoMessage = createLabel(CGRect(x: 0, y: getBottomEdgeY(inputView: noInfoIcon) + (2 * PADING),width: self.profileView.bounds.width, height: 40), text: NSLocalizedString("No profile information to display",  comment: "") , alignment: .center, textColor: buttonColor)
        noInfoMessage.numberOfLines = 0
        noInfoMessage.lineBreakMode = NSLineBreakMode.byWordWrapping
        noInfoMessage.backgroundColor = bgColor
        noInfoMessage.tag = 1000
        noInfoMessage.isHidden = true
        profileView.addSubview(noInfoMessage)
        
     

    }
    
    override func viewDidAppear(_ animated: Bool) {
        setNavigationImage(controller: self)
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
            var url = "/members/profile/get-member-info"
            var parameters = ["user_id":"\(user_id!)","field_order": "1"]
            if contentId != nil{
                url = contentUrl
                parameters.removeAll()
                parameters = ["field_order": "1"]
            }
            // Send Server Request to Explore Blog Contents with Blog_ID
            post(parameters, url: url, method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg
                    {
                        if let info = succeeded["body"] as? NSArray
                        {
                            var originTopicY: CGFloat = 0
                            self.profileInfo = info
                            for i in stride(from: 0, to: self.profileInfo.count, by: 1){
                                if let dic = self.profileInfo[i] as? NSDictionary{
                                    
                                    for(infoHeading,v) in dic{
                                        //print(infoHeading)
                                        //  var heading : String = ""
                                        if (infoHeading as AnyObject).contains("_metaOrder_"){
                                            let token = (infoHeading as AnyObject).components(separatedBy: "_metaOrder_")
                                            if infoHeading as! String == "basic_information" {
                                                self.heading = "Basic Information"
                                            }
                                            else{
                                                self.heading = String(token[0])
                                            }
                                        }
                                        else{
                                            if infoHeading as! String == "basic_information" {
                                                self.heading = "Basic Information"
                                            }
                                            else{
                                                self.heading = String(describing: infoHeading)
                                            }
                                        }
                                        
                                        self.profileView.isHidden = false
                                        self.profileView.frame.origin.y = 0
                                        var profileFieldString = ""
                                        
                                        var labelKey : String!
                                        var labelDesc : String!
                                        
                                        
                                        var origin_labelheight_y : CGFloat = originTopicY
                                        
                                        let infoHeadingField = TTTAttributedLabel(frame:CGRect(x:2 * PADING, y:origin_labelheight_y + 5,width:self.view.bounds.width - 2 * PADING, height:30) )
                                        infoHeadingField.textColor = textColorDark
                                        infoHeadingField.delegate = self
                                        infoHeadingField.isHidden = false
                                        infoHeadingField.backgroundColor = UIColor.white
                                        infoHeadingField.font = UIFont(name: fontBold, size: FONTSIZELarge)
                                        infoHeadingField.numberOfLines = 0
                                        infoHeadingField.lineBreakMode = NSLineBreakMode.byWordWrapping
                                        infoHeadingField.isUserInteractionEnabled = true
                                        infoHeadingField.setText(self.heading, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                                            return mutableAttributedString!
                                        })
                                        
                                        infoHeadingField.sizeToFit()
                                        self.profileView.addSubview(infoHeadingField)
                                        origin_labelheight_y = origin_labelheight_y + infoHeadingField.bounds.height + 10
                                        
                                        if let  arrayof = v as? NSArray{
                                            for i in stride(from: 0, to: arrayof.count, by: 1){
                                                if let profileFields = arrayof[i] as? NSDictionary{
                                                    for(key,profileField) in profileFields{
                                                        //MARK: when profile fields is a string
                                                        if profileField is String{
                                                            
                                                            if profileFields.count > 0{
                                                                var loop : Int = 0
                                                                
                                                                if profileField is NSInteger{
                                                                    if profileField as! NSInteger == 0{
                                                                        continue
                                                                    }
                                                                }else{
                                                                    if (profileField as? String) == nil || (profileField as? String) == ""{
                                                                        continue
                                                                    }
                                                                }
                                                                
                                                                self.label5 = TTTAttributedLabel(frame:CGRect(x:2 * PADING, y:origin_labelheight_y + 5, width:self.view.bounds.width - 2 * PADING, height:30) )
                                                                self.label5.linkAttributes = [kCTForegroundColorAttributeName:textColorDark]
                                                                self.label5.textColor = textColorDark
                                                                self.label5.delegate = self
                                                                self.label5.isHidden = false
                                                                
                                                                labelKey = ((key as? String)! + ": ")
                                                                
                                                                if profileField is NSInteger {
                                                                    labelDesc = "\(profileField)"
                                                                    profileFieldString = labelKey + "\(labelDesc)" + "\n"
                                                                }else{
                                                                    labelDesc = (profileField as? String)
                                                                    profileFieldString = ((labelKey as String) + (labelDesc as String)) + "\n"
                                                                }
                                                                
                                                                
                                                                self.label5.backgroundColor = UIColor.white
                                                                self.label5.font = UIFont(name: fontName, size: FONTSIZELarge)
                                                                self.label5.numberOfLines = 0
                                                                self.label5.lineBreakMode = NSLineBreakMode.byWordWrapping
                                                                
                                                                let linkColor = UIColor.blue
                                                                let linkActiveColor = UIColor.green
                                                                
                                                                self.label5.linkAttributes = [kCTForegroundColorAttributeName as AnyHashable : linkColor.cgColor,kCTUnderlineStyleAttributeName as AnyHashable : NSNumber(value: true)]
                                                                self.label5.activeLinkAttributes = [NSAttributedString.Key.foregroundColor : linkActiveColor]
                                                                self.label5.enabledTextCheckingTypes = NSTextCheckingResult.CheckingType.link.rawValue
                                                                // self.label5.enabledTextCheckingTypes = NSTextCheckingAllTypes
                                                                self.label5.isUserInteractionEnabled = true
                                                                self.label5.text = profileFieldString
                                                                self.label5.setText(profileFieldString, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                                                                    
                                                                    let boldFont1 = CTFontCreateWithName((fontName as CFString?)!, FONTSIZELarge, nil)
                                                                    
                                                                    let range1 = (profileFieldString as NSString).range(of:labelDesc as String)
                                                                    mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont1, range: range1)
                                                                    mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorMedium , range: range1)
                                                                    
                                                                    
                                                                    return mutableAttributedString
                                                                })
                                                                
                                                                self.label5.sizeToFit()
                                                                origin_labelheight_y  = origin_labelheight_y + self.label5.bounds.height + 10
                                                                loop = loop + 1
                                                                self.profileView.addSubview(self.label5)
                                                                
                                                                
                                                            }
                                                        }
                                                        
                                                    }
                                                    
                                                    self.profileView.frame.size.height = origin_labelheight_y + 20
                                                    originTopicY = self.profileView.frame.height
                                                    self.scrollView.contentSize = CGSize(width:self.profileView.frame.size.width , height: originTopicY + 30)
                                                    
                                                }
                                            }
                                        }
                                    }
                                }
                                
                            }
                            
                        }
                        else if let info = succeeded["body"] as? String
                        {
                            if info == ""
                            {
                                self.profileView.isHidden = false
                                self.noInfoIcon.isHidden = false
                                self.noInfoMessage.isHidden = false
                            }
                        }
                       
                    }
                    
                })
            }
        }else{
            // No Internet Connection Message
            showAlertMessage(view.center , msg: network_status_msg , timer: false)
        }
        
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    // Set Height for TableView Header
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        // Set Height by Section
        if (section == 0){
            return 0.00001 // for main Info Section height is 0
        }else{
            return 30.0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return dynamicHeight
    }
    
    // Set no. of sections in TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 0
//        self.sectionCount = self.dic.count
//        for a in stride(from: 0, to: self.dic.count, by: 1){
//            
//            self.check = ""
//            var subChild = [AnyObject]()
//            var subValue = [AnyObject]()
//            var array1 = [String]()
//            
//            for (key,_) in self.dic{
//                array1.append(key as! String)
//            }
//            
//            let sectionName = self.dic["\(array1[a])"] as! NSDictionary
//            
//            for (key,value) in sectionName {
//                subChild.append(key as AnyObject )
//                subValue.append(value as AnyObject )
//            }
//            
//            for (_,value) in sectionName{
//                if self.check == ""{
//                    self.count = sectionName.count
//                }
//                
//                if value is NSNull{
//                    self.count = self.count - 1
//                    if self.count == 0{
//                        self.sectionCount = self.sectionCount - 1
//                    }
//                }else if value is NSInteger {
//                    
//                    //print(value)
//                    
//                }
//                else{
//                    
//                    if value as! String == ""{
//                        self.count = self.count - 1
//                        self.check = "abc"
//                        if self.count == 0{
//                            ab.append(array1[a])
//                            self.sectionCount = self.sectionCount - 1
//                        }
//                        
//                    }
//                }
//                
//            }
//        }
//        
//        return self.sectionCount
    }
    
    // Set Title of Header in Section
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        var array1 = [String]()
        for (key,_) in dic
        {
            //print(value)
            if ab.count == 0{
                array1.append(key as! String)
            }
            else{
                
                for i in stride(from: 0, to: ab.count, by: 1){
                    
                    if  key as! String == ab[i] {
                        //print("not append")
                    }else{
                        array1.append(key as! String)
                    }
                }
                
                
            }
        }
        return array1[section]
        
    }
    
    // Set no. of rows in Every section of TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        var array2 = [String]()
        
        for (key,_) in dic{
            //print(value)
            if ab.count == 0{
                array2.append(key as! String)
            }
            else{
                
                for i in stride(from: 0, to: ab.count, by: 1){
                    
                    if  key as! String == ab[i] {
                        //print("not append")
                    }else{
                        array2.append(key as! String)
                    }
                }
            }
        }
        let rowCount = dic["\(array2[section])"] as! NSDictionary
        rowCheck = ""
        for (_,value) in rowCount{
            
            if value is NSNull{
                if rowCheck == ""{
                    rowCheck = "row"
                    rowCount1 = rowCount.count
                    rowCount1 = rowCount1 - 1
                }
                else{
                    rowCount1 = rowCount1 - 1
                }
            }
                
            else if value is NSInteger{
                
                if rowCheck == ""{
                    rowCheck = "row"
                    rowCount1 = rowCount.count
                    
                }
                else{
                    rowCount1 = rowCount1 + 0
                }
            }
                
                
            else if value as! String == ""{
                
                if rowCheck == ""{
                    rowCheck = "row"
                    rowCount1 = rowCount.count
                    rowCount1 = rowCount1 - 1
                }
                else{
                    rowCount1 = rowCount1 - 1
                }
            }
            else{
                
                if rowCheck == ""{
                    rowCheck = "row"
                    rowCount1 = rowCount.count
                    
                }
                else{
                    rowCount1 = rowCount1 + 0
                }
                
            }
            
            
        }
        return rowCount1
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UserInfoTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        var subChild = [AnyObject]()
        var subValue = [AnyObject]()
        
        
        var array3 = [String]()
        for (key,_) in dic{
            if ab.count == 0{
                array3.append(key as! String)
            }
            else{
                
                for i in stride(from: 0, to: ab.count, by: 1){
                    
                    if  key as! String == ab[i] {
                        //print("not append")
                    }else{
                        array3.append(key as! String)
                    }
                    
                }
            }
        }
        
        subChild.removeAll(keepingCapacity: true)
        subChild.removeAll(keepingCapacity: true)
        let sectionName = dic["\(array3[(indexPath as NSIndexPath).section])"] as! NSDictionary
        for (key,value) in sectionName {
            
            if value is NSNull{
                if rowCheck == ""{
                    rowCheck = "row"
                    rowCount1 = sectionName.count
                    rowCount1 = rowCount1 - 1
                }
                else{
                    rowCount1 = rowCount1 - 1
                }
            }
            else if value is NSInteger{
                
                if rowCheck == ""{
                    rowCheck = "row"
                    rowCount1 = sectionName.count
                    subChild.append(key as AnyObject )
                    subValue.append(value as AnyObject )
                    
                }
                else{
                    subChild.append(key as AnyObject )
                    subValue.append(value as AnyObject )
                    rowCount1 = rowCount1 + 0
                }
            }
                
            else if value as! String == ""{
                
                if rowCheck == ""{
                    rowCheck = "row"
                    rowCount1 = sectionName.count
                    rowCount1 = rowCount1 - 1
                }
                else{
                    rowCount1 = rowCount1 - 1
                }
            }
                
            else{
                
                if rowCheck == ""{
                    rowCheck = "row"
                    rowCount1 = sectionName.count
                    subChild.append(key as AnyObject )
                    
                    subValue.append(value as AnyObject )
                    
                }
                else{
                    rowCount1 = rowCount1 + 0
                    subChild.append(key as AnyObject )
                    
                    subValue.append(value as AnyObject )
                }
                
            }
        }
        
        let i = subChild.count
        
        for _ in stride(from: 0, to: i, by: 1){
            cell.label1?.text = subChild[(indexPath as NSIndexPath).row] as? String
            cell.label2.numberOfLines = 0
            cell.label2.lineBreakMode = NSLineBreakMode.byWordWrapping
            cell.label2?.text =  String(describing: subValue[(indexPath as NSIndexPath).row])
            cell.label2.sizeToFit()
            cell.label2.frame.size.width = view.bounds.width - cell.label2.frame.origin.x
        }
        
        dynamicHeight = 50
        
        if dynamicHeight < (cell.label2.frame.origin.y + cell.label2.bounds.height + 5){
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
       // if popAfterDelay == true{
            _ = self.navigationController?.popViewController(animated: true)
            
      //  }
    }
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWithPhoneNumber phoneNumber: String!) {
        //print("\(phoneNumber)")
        if let url = NSURL(string: "tel://\(phoneNumber)") {
            UIApplication.shared.openURL(url as URL)
        }
    }
    
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        
        UIApplication.shared.openURL(NSURL(string: "\(url!)")! as URL)
        //print("\(url!)")
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
