//
//  PollProfileViewController.swift
//  seiosnativeapp
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

import UIKit
var pollDetailUpdate :Bool!
class PollProfileViewController: UIViewController, TTTAttributedLabelDelegate, UIScrollViewDelegate {
    var showBarGraph = false
    var pollId : Int!
    var ownerIcon : UIButton!
    var pollTitle: TTTAttributedLabel!
    var pollInfo : TTTAttributedLabel!
    var closedTitle : UILabel!
    var pollDescription : TTTAttributedLabel!
    var scrollView : UIScrollView!
    var scrollView1 : UIScrollView!
    fileprivate var popover: Popover!
    
    fileprivate var popoverOptions: [PopoverOption] = [
        .type(.down),
        .blackOverlayColor(UIColor(white: 0.0, alpha: 0.6))
    ]
    
    var pollOption : NSArray!
    var selectedOption :Int!
    var canChangeVote:Bool!
    var isClosed:Bool!
    var gutterMenu : NSArray = []
    var shareUrl : String!
    var shareParam : NSDictionary!
    var options:NSArray!
    var voted:Int!
    var moreString:String!
    var selectedMoreLess:Bool = false                           // false for moreDescription  and true for lessDescription
    var descriptionResult: String!
    var selected : Bool!
    var percent:Double!
    var fromActivityFeed = true
    var descriptionShow : String!
    var like_comment : UIView!
    var  shareTitleString:String!
    var contentImageUrls : String!
    var userId:Int!
    var contentUrl : String!
    var rightBarButtonItem : UIBarButtonItem!
    var leftBarButtonItem : UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        pollDetailUpdate = false
        view.backgroundColor = bgColor
        scrollView1 = UIScrollView(frame: view.bounds)
        scrollView1.backgroundColor = bgColor
        scrollView1.delegate = self
        // 3
        scrollView1.contentSize = view.bounds.size
        // 4
        //        scrollView.addSubview(imageView)
        
        scrollView1.sizeToFit()
        view.addSubview(scrollView1)
        //Set Back Button
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(PollProfileViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        self.navigationItem.rightBarButtonItem = nil
        
        //        // Set Poll Title
        pollTitle = TTTAttributedLabel(frame:CGRect(x: 2*PADING, y: 10, width: view.bounds.width - (4*PADING+45), height: 100))
        pollTitle.numberOfLines = 0
        pollTitle.font = UIFont(name: fontName, size: FONTSIZEMedium)
        pollTitle.delegate = self
        pollTitle.longPressLabel()
        scrollView1.addSubview(pollTitle)
        closedTitle = createLabel(CGRect(x: view.bounds.width - (4*PADING+45), y: 5, width: 45, height: 35), text: "", alignment: .left, textColor: textColorMedium)
        closedTitle.font = UIFont(name: "FontAwesome", size: FONTSIZESmall)
        
        scrollView1.addSubview(closedTitle)
        
        
        // Set pollInfo Detail (viwes, votes, Owner Info)
        pollInfo = TTTAttributedLabel(frame:CGRect(x: 2*PADING , y: pollTitle.bounds.height + pollTitle.frame.origin.y, width: view.bounds.width - PADING*2 , height: 100))
        pollInfo.font = UIFont(name: fontName, size: FONTSIZESmall)
        pollInfo.numberOfLines = 0
        pollInfo.delegate = self
        pollInfo.linkAttributes = [kCTForegroundColorAttributeName:textColorMedium]
        pollInfo.longPressLabel()
        scrollView1.addSubview(pollInfo)
        
        // Set Poll Description
        pollDescription = TTTAttributedLabel(frame:CGRect(x: 2*PADING , y: TOPPADING, width: view.bounds.width - PADING*2 , height: 100))
        pollDescription.numberOfLines = 0
        pollDescription.delegate = self
        pollDescription.linkAttributes = [kCTForegroundColorAttributeName:textColorMedium]
        pollDescription.longPressLabel()
        scrollView1.addSubview(pollDescription)
        
        // Like,Comment for Poll
        likeCommentContent_id = "\(pollId!)"
        likeCommentContentType = "poll"
        like_CommentStyle = 1
        like_comment = Like_CommentView()
        like_comment.layer.shadowColor = shadowColor.cgColor
        like_comment.layer.shadowOffset = shadowOffset
        like_comment.layer.shadowRadius = shadowRadius
        like_comment.layer.shadowOpacity = shadowOpacity
        view.addSubview(like_comment)
  
        
        explorePoll()
    }
    override func viewWillAppear(_ animated: Bool)
    {
        if pollDetailUpdate == true
        {
            pollDetailUpdate = false
            explorePoll()
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        self.navigationItem.rightBarButtonItem = self.rightBarButtonItem
    }
    
    //MARK: - Generate Custom Alert Messages
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
    
    //MARK: - Show Gutter Menus
    @objc func showGutterMenu(){
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        searchDic.removeAll(keepingCapacity: false)
        var title = ""
        if showBarGraph == true {
            title = NSLocalizedString("Show Question", comment: "")
        }else{
            title = NSLocalizedString("Show Result", comment: "")
        }
        alertController.addAction(UIAlertAction(title: title, style: .default, handler:{ (UIAlertAction) -> Void in
            if self.showBarGraph == true {
                self.showBarGraph = false
            }else{
                self.showBarGraph = true
            }
            self.showPollOptions()
        }))
        for menu in gutterMenu{
            if let dic = menu as? NSDictionary{
                if dic["name"] as! String == "share"{
                }else{
                    alertController.addAction(UIAlertAction(title: (dic["label"] as! String), style: .default, handler:{ (UIAlertAction) -> Void in
                        let condition = dic["name"] as! String
                        switch(condition){
                            
                        case "report":
                            let presentedVC = ReportContentViewController()
                            presentedVC.param = (dic["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                            presentedVC.url = dic["url"] as! String
                            self.navigationController?.pushViewController(presentedVC, animated: true)
                            
                        default:
                            fatalError("init(coder:) has not been implemented")
                        }
                    }))
                }
            }
        }
        if (UIDevice.current.userInterfaceIdiom == .phone){
            alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .cancel, handler:nil))
        }else{
            // Present Alert as! Popover for iPad
            alertController.modalPresentationStyle = UIModalPresentationStyle.popover
            let popover = alertController.popoverPresentationController
            popover?.sourceView = UIButton()
            popover?.sourceRect = CGRect(x: view.bounds.height-50, y: view.bounds.width, width: 0, height: 0)
            popover?.permittedArrowDirections = UIPopoverArrowDirection.up
        }
        self.present(alertController, animated:true, completion: nil)
    }
    
    //MARK: - Show Poll Options
    func showPollOptions(){
        let origin_Y = self.pollDescription.frame.origin.y + self.pollDescription.bounds.height + PADING
        if scrollView == nil
        {
            scrollView = UIScrollView(frame : CGRect(x: 0, y: origin_Y+10, width: view.bounds.width,height: (view.bounds.height - (origin_Y + 40))))
        }
        else
        {
            for ob in scrollView.subviews{
                ob.removeFromSuperview()
            }
            if showBarGraph == false{
                for layer in scrollView.layer.sublayers!{
                    layer.removeFromSuperlayer()
                }
            }
        }
        scrollView.delegate = self
        var i = 0
        var originY =  PADING
        let viewBorder = UIView(frame:CGRect(x: 0, y: 0, width: view.bounds.width, height: 1))
        viewBorder.backgroundColor = UIColor.lightGray
        scrollView.addSubview(viewBorder)
        if showBarGraph == false{
            let optionLabel = createLabel(CGRect(x: 2*PADING ,y: originY,width: view.bounds.width-5*PADING, height: 20), text: "tap on any option to vote", alignment: .center , textColor: textColorMedium)
            optionLabel.font = UIFont(name: fontName, size: FONTSIZENormal)
            scrollView.addSubview(optionLabel)
        }
        for option in (self.pollOption as! [[String:Any]]) {
            let options = option
            
                if showBarGraph == false
                {
                    let optionButton = createButton(CGRect(x: 2*PADING ,y: originY+21 ,width: view.bounds.width-(2*PADING + 24), height: 35), title: String(describing: options["poll_option"]!), border: true, bgColor: false, textColor: textColorMedium)
                    let viewBorder = UIView(frame:CGRect(x: 0, y: optionButton.bounds.height-2, width: view.bounds.width-5*PADING, height: 1))
                    viewBorder.backgroundColor = UIColor.lightGray
                    optionButton.layer.borderColor = UIColor.clear.cgColor
                    optionButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
                    optionButton.addSubview(viewBorder)
                    optionButton.titleLabel?.font = UIFont(name: fontName, size: FONTSIZESmall)
                    optionButton.tag = options["poll_option_id"] as! Int
                    if(canChangeVote == true && isClosed == false)
                    {
                        optionButton.addTarget(self, action: #selector(PollProfileViewController.optionSelected(_:)), for: .touchUpInside)
                    }
                    if (options["poll_option_id"] as? Int == self.voted)
                    {
                        let checked = createLabel(CGRect(x: view.bounds.width-28, y: 2, width: 24 ,height: optionButton.bounds.height-4), text: " ", alignment: .left, textColor: textColorDark)
                        
                        checked.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
                        checked.text = "\(checkedIcon)"
                        
                        optionButton.addSubview(checked)
                    }
                    scrollView.addSubview(optionButton)
                    originY += optionButton.bounds.height + PADING
                }
                else
                {
                    var pollOption: String = ""
                    if (option["poll_option"] is NSNumber)
                    {
                        let pollOption1 = option["poll_option"]!
                        pollOption = String(describing: pollOption1)
                    }
                    else
                    {
                        pollOption = (option["poll_option"] as? String)!
                    }
                    drawlines(lineNumber: i, percent: option["percentage"] as! Double, linename: pollOption, value: option["votes"] as! Int)
                    i += 1
                    originY += 35
                    
                }
            
        }

        scrollView.frame.size.height = view.bounds.height + originY
        scrollView.isPagingEnabled = true
        scrollView.bounces = true
        scrollView.isUserInteractionEnabled = true
        scrollView1.addSubview(scrollView)
        
        self.scrollView1.contentSize.height =  scrollView.bounds.height + 10
        self.scrollView1.sizeToFit()
        
        
    }
    
    // MARK: - For Generating Random Color
    func getRandom() -> UIColor
    {
        let randomRed:CGFloat = CGFloat(drand48())
        let randomGreen:CGFloat = CGFloat(drand48())
        let randomBlue:CGFloat = CGFloat(drand48())
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
    
    // MARK: - Bar Graph for Poll Result
    func drawlines (lineNumber num:Int , percent val:Double,linename name:String, value :Int ){
        var end:CGPoint!
        let startpoint=40
        let distance=35
        let onePart = Double((Int(self.view.frame.width)/2 )) / Double(100)
        let start = CGPoint(x:20,y:Int(num*distance)+startpoint)
        if(val == 0.0)
        {
            let number = 3.0
            end = CGPoint(x:Int(number*onePart)+20,y:Int(num*distance)+startpoint)
            //end = CGPoint(x:Int(number*onePart)+20,y:40)
        }
        else
        {
            end = CGPoint(x:Int(val*onePart)+20,y:Int(num*distance)+startpoint)
        }
        //first label settings
        let lbl = UILabel()
        lbl.frame = CGRect(x: start.x, y: start.y - 25, width: view.bounds.width-start.x, height: 15)
        lbl.font = UIFont(name: fontName, size: FONTSIZENormal)
        lbl.text = name
        scrollView.addSubview(lbl)
        let tempRandomColor = getRandom
        //red part of line
        if(val == 0.0){
            let tempColorCode = getRandom
            // var tempColorCode =  UIColor(red: 228, green: 225, blue: 225, alpha: 1.0)
            drawLine(startpoint: start, endpint: end,linecolor: tempColorCode().cgColor,linewidth:11.0)
        }
        else{
            drawLine(startpoint: start, endpint: end,linecolor: tempRandomColor().cgColor,linewidth:11.0)
        }
        //black vertical line
        let vline = CGPoint(x:end.x,y:end.y+5)
        //value label
        let lbl2 = UILabel()
        //check distance
        if ((vline.x + 100 ) > self.view.frame.width ){
            lbl2.frame = CGRect(x: vline.x-60, y: start.y - 10, width: 60, height: 15)
        }
        else{
            lbl2.frame = CGRect(x: view.bounds.width-60, y: start.y - 10, width: 60, height: 15)
        }
        lbl2.font = UIFont(name: fontName, size: FONTSIZENormal) //lbl2.font.fontWithSize(15)
        lbl2.text = singlePluralCheck( NSLocalizedString(" vote", comment: ""),  plural: NSLocalizedString(" votes", comment: ""), count: value)
        scrollView.addSubview(lbl2)
    }
    
    //MARK: -  Draw Bar Graph Line
    func drawLine(startpoint start:CGPoint, endpint end:CGPoint, linecolor color: CGColor , linewidth widthline:CGFloat){
        let path = UIBezierPath()
        path.move(to: start)
        path.addLine(to: end)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = color
        shapeLayer.lineWidth = widthline
        shapeLayer.borderColor = textColorMedium.cgColor
        scrollView.layer.addSublayer(shapeLayer)
    }
    
    // MARK: - Server Connection For poll Detail
    @objc func optionSelected(_ sender: UIButton){
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {
//            spinner.center = view.center
//            spinner.style = UIstyle.gray
//            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            // Send Server Request to Browse poll Entries
            post(["poll_id" : String(pollId), "option_id" :"\(sender.tag)"], url: "polls/poll/vote" , method: "POST") { (succeeded, msg) -> () in

                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        self.voted = sender.tag
                        if let response = succeeded["body"] as? NSArray{
                            self.pollOption = response
                        }
                        self.showBarGraph = true
                        self.showPollOptions()
                        self.selected = true
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                    }else{
                        // Handle Server Error
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
    
    //MARK: - Explore poll
    func explorePoll(){
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork()
        {

            // Checkin calling
//            if enabledModules.contains("sitetagcheckin")
//            {
//                self.ischekin()
//            }

//            spinner.center = view.center
//            spinner.style = UIstyle.gray
//            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()

            // Send Server Request to Browse poll Entries
            post(["gutter_menu" :"1"], url: "polls/view/" + String(pollId), method: "GET") { (succeeded, msg) -> () in

                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        if let response = succeeded["body"] as? NSDictionary{
                            // Update Gutter Menu
                            if let menu = response["gutterMenu"] as? NSArray{
                                self.gutterMenu  = menu
                                 var isCancel = false
                                for tempMenu in self.gutterMenu{
                                    if let tempDic = tempMenu as? NSDictionary{
                                        if tempDic["name"] as! String == "share" {
                                            
                                            self.shareUrl = tempDic["url"] as! String
                                            self.shareParam = tempDic["urlParams"] as! NSDictionary
                                        }
                                        else
                                        {
                                            isCancel = true
                                        }
                                    }
                                }
                                
                                if logoutUser == false{
                                    let rightNavView = UIView(frame: CGRect(x: 0, y: 0, width: 66, height: 44))
                                    rightNavView.backgroundColor = UIColor.clear
                                    
                                    let shareButton = createButton(CGRect(x: 0,y: 12,width: 22,height: 22), title: "", border: false, bgColor: false, textColor: UIColor.clear)
                                    shareButton.setImage(UIImage(named: "upload")?.maskWithColor(color: textColorPrime), for: UIControl.State())
                                    shareButton.addTarget(self, action: #selector(PollProfileViewController.shareItem), for: .touchUpInside)
                                    rightNavView.addSubview(shareButton)
                                    
                                    let optionButton = createButton(CGRect(x: 44,y: 12,width: 22,height: 22), title: "", border: false, bgColor: false, textColor: UIColor.clear)
                                    optionButton.setImage(UIImage(named: "option")?.maskWithColor(color: textColorPrime), for: UIControl.State())
                                    optionButton.addTarget(self, action: #selector(PollProfileViewController.showGutterMenu), for: .touchUpInside)
                                   // rightNavView.addSubview(optionButton)
                                    if isCancel == false
                                    {
                                        shareButton.frame.origin.x = 44
                                    }
                                    else
                                    {
                                        rightNavView.addSubview(optionButton)
                                    }
                                    self.rightBarButtonItem = UIBarButtonItem(customView: rightNavView)
                                    
                                    self.navigationItem.rightBarButtonItem = self.rightBarButtonItem
                                }
                                
                                
                            }
                            if let response = response["response"] as? NSDictionary {
                                self.shareTitleString = response["title"] as? String
                                if response["title"] != nil {
                                    self.pollTitle.text = (response["title"] as! String)
                                }
                                self.pollTitle.numberOfLines = 0
                                self.pollTitle.lineBreakMode = NSLineBreakMode.byTruncatingTail
                                self.pollTitle.sizeToFit()
                                self.pollInfo.frame.origin.y = self.pollTitle.bounds.height + contentPADING*2 + self.pollTitle.frame.origin.y
                                
                                if response["closed"] as! Int == 1{
                                    self.closedTitle.text =  "\(closedIcon) Closed"
                                    //                                    self.closedTitle.text =  String(format: NSLocalizedString("                                           \(closedIcon) Closed", comment: ""),locale: nil)
                                }
                                
                                
                                // Set pollInfo
                                var description = ""
                                let ownerName = response["owner_title"] as? String
                                if ownerName != ""{
                                    description = "by \(ownerName!)"
                                }
                                self.contentUrl = response["content_url"] as? String
                                
                                
                                if let  postedDate = response["creation_date"] as? String{
                                    let postedOn = dateDifference(postedDate)
                                    description += String(format: NSLocalizedString(" - %@", comment: ""), postedOn)
                                }
                                description += "\n"
                                description += "\n"
                                let voteCount = response["vote_count"] as? Int
                                description +=  String(format: NSLocalizedString(" \(voteCount!) \(barIcon)", comment: ""), voteCount!)
                                let viewCount = response["view_count"] as? Int
                                description +=  String(format: NSLocalizedString("  \(viewCount!) \(viewIcon)", comment: ""), viewCount!)
                                self.pollInfo.textColor = textColorMedium
                                self.pollInfo.font = UIFont(name: "FontAwesome", size:FONTSIZESmall)
                                
                                self.pollInfo.setText(description, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                                    let boldFont =  CTFontCreateWithName((fontBold as CFString?)!, FONTSIZESmall, nil)
                                    
                                    let range1 = (description as NSString).range(of: ownerName!)
                                    mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range1)
                                    mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorDark , range: range1)
                                    
                                    
                                    // TODO: Clean this up...
                                    return mutableAttributedString
                                })
                                
                                self.userId =  response["user_id"] as! Int
                                let range = (description as NSString).range(of: NSLocalizedString("\(ownerName!)",  comment: ""))
                                self.pollInfo.addLink(toTransitInformation: ["id": "\(self.userId)", "type" : "user"], with:range)
                                self.pollInfo.lineBreakMode = NSLineBreakMode.byWordWrapping
                                self.pollInfo.sizeToFit()
                                
                                // For Showing Check-in Button and count
                                let Pading : CGFloat = getBottomEdgeY(inputView: self.pollInfo) + 10
                                if let _ = response["description"] as? String {
                                    self.pollDescription.frame.origin.y = self.pollInfo.bounds.height +
                                        self.pollInfo.frame.origin.y + PADING + 10
                                    self.descriptionResult = response["description"] as? String
                                }
                                self.pollDescription.text = self.descriptionResult
                                self.pollDescription.frame.origin.y = Pading
                                self.pollDescription.sizeToFit()
                                self.pollDescription.numberOfLines = 0
                                self.contentImageUrls = response["owner_image"] as! String
                                
                                //update voted option
                                if response["hasVoted"] is Bool
                                {
                                    let boolVote = response["hasVoted"] as! Bool
                                    if boolVote
                                    {
                                        self.voted = 1
                                    }
                                    else
                                    {
                                        self.voted = 0
                                    }
                                }
                                else
                                {
                                    self.voted = response["hasVoted"] as! Int
                                }
                                if response["hasVoted"] as! Bool == false && response["canVote"] as! Bool == true && response["closed"] as! Bool == false{
                                    self.showBarGraph = false
                                }
                                else
                                {
                                    self.showBarGraph = true
                                }
                                if let changeVote = response["canVote"] as? Bool{
                                    self.canChangeVote = changeVote
                                }
                                if let close = response["closed"] as? Bool{
                                    self.isClosed = close
                                }
                                if let pollOptions = response["options"] as? NSArray
                                {
                                    self.pollOption = pollOptions
                                    self.showPollOptions()
                                }
                            }
                        }
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                    }else{
                        // Handle Server Error
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
    
    //MARK:- For Whether Show MoreDescription or for Show LessDescription
    func moreOrLess(){
        if let description = descriptionResult{
            var tempInfo = ""
            if description != ""  {
                let tempTextLimit = 2 * descriptionTextLimit
                if description.length > tempTextLimit{
                    if self.selectedMoreLess == false{
                        tempInfo += (description as NSString).substring(to: tempTextLimit-3)
                        tempInfo += NSLocalizedString("... more >>",  comment: "")
                    }else{
                        tempInfo += description
                        tempInfo += NSLocalizedString("  << less",  comment: "")
                    }
                }else{
                    tempInfo += description
                }
            }
            self.pollDescription.numberOfLines = 0
            self.pollDescription.delegate = self
            self.pollDescription.font = UIFont(name: fontName, size: FONTSIZENormal)
            self.pollDescription.setText(tempInfo, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                let boldFont = CTFontCreateWithName( (fontBold as CFString?)!, FONTSIZESmall, nil)
                let range2 = (tempInfo as NSString).range(of: NSLocalizedString("more",  comment: ""))
                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range2)
                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorDark , range: range2)
                let range1 = (tempInfo as NSString).range(of: NSLocalizedString("<< less",  comment: ""))
                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range1)
                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorDark , range: range1)
                // TODO: Clean this up...
                return mutableAttributedString
            })
            let range = (tempInfo as NSString).range(of: NSLocalizedString("more >>",  comment: ""))
            self.pollDescription.addLink(toTransitInformation: [ "type" : "moreContentInfo"], with:range)
            let range1 = (tempInfo as NSString).range(of: NSLocalizedString("less",  comment: ""))
            self.pollDescription.addLink(toTransitInformation: ["type" : "lessContentInfo"], with:range1)
            self.pollDescription.lineBreakMode = NSLineBreakMode.byWordWrapping
            self.pollDescription.sizeToFit()
        }
    }
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWithTransitInformation components: [AnyHashable: Any]!) {
        let type = components["type"] as! String
        switch(type){
        case "moreContentInfo":
            selectedMoreLess = true
            self.moreOrLess()
        case "lessContentInfo":
            selectedMoreLess = false
            self.moreOrLess()
        case "user":
            let presentedVC = ContentActivityFeedViewController()
            presentedVC.subjectType = "user"
            presentedVC.subjectId = "\(self.userId)"
            searchDic.removeAll(keepingCapacity: false)
            self.navigationController?.pushViewController(presentedVC, animated: false)
        default:
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationItem.rightBarButtonItem = nil
    }
    
    //MARK: - For share
    @objc func shareItem(){
        let startPoint = CGPoint(x: self.view.frame.width - 72, y: 50)
        self.popover = Popover(options: self.popoverOptions, showHandler: nil, dismissHandler: nil)
        let ShareOptionHeightCount:CGFloat = CGFloat(44*ShareOption.count)
        let tableView = UITableView(frame: CGRect(x: 0, y: TOPPADING, width: self.view.frame.width, height: ShareOptionHeightCount))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.tag = 11
        tableView.estimatedRowHeight = 34.0
        popover.show(tableView, point: startPoint)
    }

    //MARK: - For Checking Condition and going back to pollViewController or AdvanceActivityFeedViewController
    @objc func goBack()
    {
        if conditionalProfileForm == "BrowsePage"
        {
            pollUpdate = true
            _ = self.navigationController?.popToRootViewController(animated: false)
        }
            
        else if fromActivityFeed == false
        {
            let presentedVC = AdvanceActivityFeedViewController()
            self.navigationController?.pushViewController(presentedVC, animated: true)
        }
        else
        {
            removeAlert()
            _ = self.navigationController?.popViewController(animated: true)
        }
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


extension PollProfileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.popover.dismiss()
        if (indexPath as NSIndexPath).row == 0{
            var sharingItems = [AnyObject]()
            
            if let text = self.shareTitleString {
                sharingItems.append(text as AnyObject)
            }
            
            
            if let url = self.contentUrl {
                let finalUrl = URL(string: url)!
                sharingItems.append(finalUrl as AnyObject)
            }
            
            let activityViewController = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
            activityViewController.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
            if  (UIDevice.current.userInterfaceIdiom == .phone){
                
                if(activityViewController.popoverPresentationController != nil) {
                    activityViewController.popoverPresentationController?.sourceView = self.view;
                    let frame = UIScreen.main.bounds
                    activityViewController.popoverPresentationController?.sourceRect = frame;
                }
                
            }
            else
            {
                
                let presentationController = activityViewController.popoverPresentationController
                presentationController?.sourceView = self.view
                presentationController?.sourceRect = CGRect(x: self.view.bounds.width/2 , y: self.view.bounds.width/2, width: 0, height: 0)
                presentationController?.permittedArrowDirections = UIPopoverArrowDirection()
                
            }
            
            self.present(activityViewController, animated: true, completion: nil)
            
            
        }else if (indexPath as NSIndexPath).row == 1{
            
            let pv = AdvanceShareViewController()
            pv.url = self.shareUrl
            pv.param = self.shareParam as! [AnyHashable : Any] as NSDictionary
            pv.Sharetitle = self.shareTitleString
            pv.imageString = self.contentImageUrls
            pv.ShareDescription = self.descriptionResult
            pv.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            let nativationController = UINavigationController(rootViewController: pv)
            self.present(nativationController, animated:true, completion: nil)
            
        }else if (indexPath as NSIndexPath).row == 2{
            UIPasteboard.general.url = URL(string: self.contentUrl)
            showToast(message: NSLocalizedString("Link copied.",comment: ""), controller: self)
        }
        
    }
    
}

extension PollProfileViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return ShareOption.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.font = UIFont(name: "FontAwesome", size: 16.0)
        cell.textLabel?.textColor = UIColor.darkGray
        cell.textLabel?.text = ShareOption[(indexPath as NSIndexPath).row]
        return cell
        
    }
}
