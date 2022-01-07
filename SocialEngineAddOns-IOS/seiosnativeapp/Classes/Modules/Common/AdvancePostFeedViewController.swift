//
//  AdvancedPostFeedViewController.swift
//  seiosnativeapp
//
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
import AVFoundation
import MobileCoreServices
import Photos
// Intialise delegate
protocol RedirectionMethod
{
    func redirectionAfterSelect(sender : Int)
    func resign()
}
//Quick Content Delegate
protocol QuickContentProtocol {  //These protocols are used to pass data back to advanceactivitycontroller for quick content posting
    func postVideoQuickPosting(parameters : Dictionary<String, AnyObject>, path : String)
    func postImageQuickPosting(parameters : Dictionary<String, AnyObject>, path : String, singlePhoto : Bool)
    func postTextWithImageQuickPosting(parameters : Dictionary<String, AnyObject>, path : String, passTempDic : [String : String])
    func postSellSomethingQuickPosting(parameters : Dictionary<String, AnyObject>, path : String, type : Int)
}

var videoredirection : Bool = true // When we upload video from my device it should be false

var sellUpdate : Bool = false
var greetingsCheck : Bool = false
var scheduleAllow : Int = 1
var targetAllow : Int = 1

class AdvancePostFeedViewController: UIViewController, TTTAttributedLabelDelegate, UIScrollViewDelegate, UITextViewDelegate,ELCImagePickerControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate,UITableViewDataSource,UITableViewDelegate,RedirectionMethod  {
    var videoPickedBlock: ((NSURL) -> Void)?
    var delegateQuickContent : QuickContentProtocol?
    var userImage : UIImageView!
    var userDetails : TTTAttributedLabel!
    var scrollView : UIScrollView!
    var option : UIButton!
    var feedPostOptions : UIView!
    var feedTextView = UITextView()
    var openfeedStyle:Int! = 0
    var postButton : UIBarButtonItem!
    //  var imageCache = [String:UIImage]()
    var privacyButton : UIButton!
    var auth_View:String!
    var taggedFriendsString = ""
    var locationInfoString = ""
    var allPhotos = [UIImage]()
    var imageView = UIImageView()
    var lastContentOffset: CGFloat = 0
    var photoAttachmentMode = false
    var linkAttachmentMode = false
    var videoAttachmentMode = false
    var attachmentMode = false
    var attachvideofromDevice = false
    var linkField: UITextField!
    var linkUrl : String!
    var photoView: UIView!
    var photoViewOriginY: CGFloat!
    var videoUrl : String!
    var popAfterDelay = false
    var imagePost:Bool!
    var videoId : String!
    var sampleImage:UIImageView!
    var videoOption:UIButton!
    var videoAttachmentKey = ""
    var linkTextField = UITextField()
    var attachFile : UIButton!
    var isFromHome = true
    var leftBarButtonItem : UIBarButtonItem!
    var subjectId:String!
    var subjectType:String!
    var postPermissionForcheckin = NSDictionary()
    var btnCheckin : UIButton!
    var showCheckinView: UIView!
    var selectedDate : String = ""
    let bottomSheetVC = BottomSheetForPostViewController() // Initialise object of bottom sheet view
    var popoverTableView:UITableView!
    var EventSelectionView : UIView!
    var EventNameLabel: UITextField!
    var crossBtn: UIButton!
    var EventTable: UITableView!
    var EventArray : NSArray = []
    var frndTags = UILabel()
    var selectedString = ""
    var CheckParameters = [String:AnyObject]()
    var tempParameters = [String:AnyObject]()
    var Modify_composer1 : AnyObject!
    var Modify_composer2 : String = ""
    var bannerComposer : String = ""
    var tagwithcheckin : Int = 0
    var thumbImage : UIImage?
    var orientedImage : UIImage?
    
    var tabsContainerMenu:UIScrollView!
    // var tabMenuItem = [AnyObject]()
    var bannerImageView = UIImageView()
    var buttonTextView  = VerticallyCenteredTextView()
    var extraMenuLeft:UIButton!
    var whiteBoxButton : UIButton!
    var imageCovert : Bool = false
    var backupImageView = UIImageView()
    var bannerTextLimit : Int = 100
    var backupTextView = UITextView()
    var whiteBoxSelected : Bool = true
    var BannerJsonValue = [String:String]()
    var postTextColor = UIColor()
    var TargetButton = UIButton()
    var ScheduleButton = UIButton()
    
    var sellView = UIView()
    var allSellPhotos = [UIImage]()
    var sellImageView = UIImageView()
    var sellAttachmentMode = false
    var ProductTitle = UILabel()
    var ProductPrice = UILabel()
    var ProductLoc = UILabel()
    var editFeedDict = NSDictionary()
    var editBody : String! = ""
    var editId : Int!
    var activityfeedIndex : Int!
    var isEditFeed : Bool = false
    var editPrivacy = ""
    var attachmentCount : Int = 0
    var imgBorderBackground = UIImageView()
    var checkfrom = ""
    var titleGetAttachement = ""
    var descriptionGetAttachement = ""
    var imageStringGetAttachement = ""
    var linkContent = NSDictionary()
    var messageShow : Bool = true
    weak var postFeedDelegate : PostFeedDelegate?
    var userId : Int = 0
    var isCheckIn = false
    var isAAFPost : Bool = false
    // function for redirection after click on particular cell
    func redirectionAfterSelect(sender : Int) {
        if isEditFeed == false {
            //            if photoAttachmentMode == true || linkAttachmentMode == true || videoAttachmentMode == true
            //            {
            //                if sender == 6 || sender == 2 || sender == 5
            //                {
            //                    return
            //                }
            //                else if sender == 9
            //                {
            //                    showDatepicker()
            //                }
            //
            //            }
            
            switch(sender)
            {
            case 0:
                
                let presentedVC = TaggingViewController()
                let nativationController = UINavigationController(rootViewController: presentedVC)
                self.present(nativationController, animated:false, completion: nil)
                CFRunLoopWakeUp(CFRunLoopGetCurrent())
                //   navigationController?.pushViewController(presentedVC, animated: true)
                
            case 1:
                openCheckIn()
            case 2:
                if bannerImageView.image != nil || sellAttachmentMode == true || bannerImageView.tag == 100{
                    
                    resign()
                }
                else{
                    photoOptions()
                }
            case 5 :
                if bannerImageView.image != nil || sellAttachmentMode == true || bannerImageView.tag == 100{
                    
                    resign()
                }
                else{
                    openVideoPicker()
                }
            case 6:
                if bannerImageView.image != nil || sellAttachmentMode == true || bannerImageView.tag == 100{
                    
                    resign()
                }
                else{
                    attachLink()
                }
            case 7:
                //facebooktick = 1
                resign()
                if bannerImageView.image == nil {
                    let presentedVC = TargetScheduledPostViewController()
                    presentedVC.contentType = "Sell"
                    // presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                    let nativationController = UINavigationController(rootViewController: presentedVC)
                    nativationController.modalPresentationStyle = .fullScreen
                    self.present(nativationController, animated:false, completion: nil)
                    CFRunLoopWakeUp(CFRunLoopGetCurrent())
                    // navigationController?.pushViewController(presentedVC, animated: true)
                }
                else{
                    resign()
                }
                
                
                //            case 8:
                //                //self.twittertick = 1
                //                if bannerImageView.image == nil || sellAttachmentMode == false{
                //                    //print("2 sell")
                //                }
                //                else{
                //                    resign()
                //                }
                //
            //                //print("2 sell")
            case 9:
                showDatepicker()
                break
                
            default:
                break
            }
        }
        
    }
    
    
    // Remove keyboard if open
    func resign(){
        
        feedTextView.resignFirstResponder()
        linkTextField.resignFirstResponder()
        buttonTextView.resignFirstResponder()
    }
    
    override func viewDidLoad()
    {
        
        super.viewDidLoad()
        self.view.backgroundColor = bgColor
        mediaType = "image"
        //        if checkfrom != "" {
        //            greetingsCheck = true
        //        }
        //        else{
        //            greetingsCheck = false
        //        }
        bannerTextLimit = bannerFeedLength
        frndTagValue.removeAll()
        scrollView = UIScrollView(frame: view.bounds)
        scrollView.backgroundColor = bgColor
        scrollView.bounces = false
        scrollView.delegate = self
        buttonTextView.delegate = self
        self.view.addSubview(scrollView)
        popAfterDelay = false
        advGroupDetailUpdate = false
        sellUpdate = true
        Formbackup.removeAllObjects()
        
        postTextColor = textColorDark
        if feedTextColor != "" {
            var check = feedTextColor
            let _ = check.remove(at: (check.startIndex))
            postTextColor = UIColor(hex: "\(check)")
        }
        
        buttonTextView = createTextViewVerticleContent(CGRect(x: 10,y: 0 ,width: view.bounds.width - 20 , height: 300 ), borderColor: UIColor.clear, corner: false)
        buttonTextView.text = NSLocalizedString("What's on your mind?",  comment: "")
        buttonTextView.font = UIFont(name: fontBold, size: CGFloat(feedFontSize))
        buttonTextView.backgroundColor = UIColor.clear
        buttonTextView.autocorrectionType = .no
        
        //self.navigationController!.interactivePopGestureRecognizer!.delegate = self
        let cancel = UIBarButtonItem(title: NSLocalizedString("Cancel",  comment: ""), style:.plain , target:self , action: #selector(AdvancePostFeedViewController.goBack))
        cancel.tintColor = textColorPrime
        self.navigationItem.leftBarButtonItem = cancel
        
        postButton = UIBarButtonItem(title:NSLocalizedString("Post", comment: "") , style:.plain , target:self , action: #selector(AdvancePostFeedViewController.postFeed))
        if isEditFeed == true {
            postButton.isEnabled = true
        }
        else{
            postButton.isEnabled = false
        }
        self.navigationItem.rightBarButtonItem = postButton
        
        userImage = createImageView(CGRect(x: 10, y: 10 , width: 50, height: 50), border: true)
        scrollView.addSubview(userImage)
        userImage.tag = 9999
        userImage.contentMode = UIView.ContentMode.scaleAspectFill
        userImage.clipsToBounds = true
        userImage.image = UIImage(named: "user_profile_image.png")
        frndTag.removeAll(keepingCapacity: false)
        
        let profile = createButton(CGRect( x: PADING,y: TOPPADING , width: 60, height: 60), title: "", border: false, bgColor: false, textColor: textColorLight)
        profile.addTarget(self, action: #selector(AdvancePostFeedViewController.showProfile), for: .touchUpInside)
        view.addSubview(profile)
        
        if coverPhotoImage != nil
        {
            self.userImage.image = coverPhotoImage
        }
        else
        {
            if let url = URL(string: coverImage as String)
            {
                self.userImage.kf.indicatorType = .activity
                (self.userImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                self.userImage.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                    
                })
            }
        }
        
        userDetails = TTTAttributedLabel(frame:CGRect(x: 20 + userImage.bounds.width , y: 10, width: view.bounds.width - (4*10) - userImage.bounds.width - 25  , height: 40) )
        userDetails.numberOfLines = 0
        userDetails.delegate = self
        userDetails.font = UIFont(name: fontName, size: FONTSIZENormal)
        userDetails.sizeToFit()
        scrollView.addSubview(userDetails)
        
        let userDetailHeight =  userDetails.frame.size.height + userDetails.frame.origin.y
        privacyButton = createButton(CGRect(x: 20 + userImage.bounds.width , y: userDetailHeight ,width: 50 , height: 25), title: "", border: true,bgColor: false, textColor: textColorDark)
        privacyButton.layer.borderColor = textColorMedium.cgColor
        privacyButton.layer.borderWidth = 1.0
        let bounds = UIScreen.main.bounds
        let height = bounds.size.height
        switch height
        {
        case 568.0:
            // spalshName = "Splash-640x960"
            privacyButton.titleLabel?.font = UIFont(name: "FontAwesome", size: 10)
            
            
        default:
            
            privacyButton.titleLabel?.font = UIFont(name: "FontAwesome", size: 15)
            
        }
        // privacyButton.titleLabel?.font = UIFont(name: "FontAwesome", size: 15)
        privacyButton.layer.cornerRadius = 5.0
        privacyButton.layer.masksToBounds = true
        
        
        privacyButton.titleLabel?.lineBreakMode = NSLineBreakMode.byClipping
        privacyButton.addTarget(self, action: #selector(AdvancePostFeedViewController.showPostPrivacy(_:)), for: .touchUpInside)
        scrollView.addSubview(privacyButton)
        
        TargetButton = createButton(CGRect(x: 20 + userImage.bounds.width + privacyButton.frame.size.width , y: privacyButton.frame.origin.y  ,width: 30 , height: 25), title: "\u{f05b}", border: false,bgColor: false, textColor: textColorDark)
        TargetButton.layer.borderColor = textColorMedium.cgColor
        TargetButton.layer.borderWidth = 1.0
        
        switch height
        {
        case 568.0:
            // spalshName = "Splash-640x960"
            TargetButton.titleLabel?.font = UIFont(name: "FontAwesome", size: 10)
            
            
        default:
            
            TargetButton.titleLabel?.font = UIFont(name: "FontAwesome", size: 15)
            
        }
        //  TargetButton.titleLabel?.font = UIFont(name: "fontAwesome", size: 15)
        TargetButton.layer.cornerRadius = 5.0
        TargetButton.layer.masksToBounds = true
        TargetButton.isHidden = false
        TargetButton.titleLabel?.lineBreakMode = NSLineBreakMode.byClipping
        TargetButton.addTarget(self, action: #selector(AdvancePostFeedViewController.showTarget), for: .touchUpInside)
        scrollView.addSubview(TargetButton)
        
        if targetAllow == 0 ||  isEditFeed{
            TargetButton.isHidden = true
            TargetButton.frame.size.width = 0.0
        }
        
        ScheduleButton = createButton(CGRect(x: 20 + userImage.bounds.width + privacyButton.frame.size.width , y: privacyButton.frame.origin.y  ,width: 30 , height: 25), title: "\(eventIcon)", border: false,bgColor: false, textColor: textColorDark)
        ScheduleButton.layer.borderColor = textColorMedium.cgColor
        ScheduleButton.layer.borderWidth = 1.0
        switch height
        {
        case 568.0:
            // spalshName = "Splash-640x960"
            ScheduleButton.titleLabel?.font = UIFont(name: "FontAwesome", size: 10)
            
            
        default:
            
            ScheduleButton.titleLabel?.font = UIFont(name: "FontAwesome", size: 15)
            
        }
        // ScheduleButton.titleLabel?.font = UIFont(name: "fontAwesome", size: 15)
        ScheduleButton.layer.cornerRadius = 5.0
        ScheduleButton.layer.masksToBounds = true
        ScheduleButton.isHidden = false
        ScheduleButton.titleLabel?.lineBreakMode = NSLineBreakMode.byClipping
        ScheduleButton.addTarget(self, action: #selector(AdvancePostFeedViewController.showSchedule), for: .touchUpInside)
        scrollView.addSubview(ScheduleButton)
        
        if scheduleAllow == 0 ||  isEditFeed {
            ScheduleButton.isHidden = true
            
        }
        
        
        btnCheckin = createButton(CGRect(x:getRightEdgeX(inputView: privacyButton)+10, y:privacyButton.frame.origin.y, width:100,height:20),  title: NSLocalizedString("",  comment: ""), border: false,bgColor: false, textColor: textColorMedium)
        btnCheckin.isHidden = false
        btnCheckin.tag = 5
        btnCheckin.titleLabel?.font = UIFont(name: "FontAwesome", size: 10)
        btnCheckin.titleLabel?.lineBreakMode = NSLineBreakMode.byClipping
        btnCheckin.layer.cornerRadius = 5.0
        btnCheckin.layer.borderWidth = 0.5
        btnCheckin.layer.borderColor = textColorMedium.cgColor
        btnCheckin.layer.masksToBounds = true
        btnCheckin.isHidden = true
        btnCheckin.addTarget(self, action: #selector(AdvancePostFeedViewController.cancelevent), for: .touchUpInside)
        scrollView.addSubview(btnCheckin)
        
        // For Checkin only end
        
        feedTextView = createTextView(CGRect(x: 10,y: 65 , width: view.bounds.width-20, height: 200 - 60), borderColor: borderColorClear , corner: false )
        feedTextView.backgroundColor = bgColor
        feedTextView.delegate = self
        feedTextView.text = NSLocalizedString("What's on your mind?",  comment: "")
        
        feedTextView.textColor = postTextColor//textColorDark
        if openfeedStyle == 4
        {
            feedTextView.text = NSLocalizedString("I am here!",  comment: "")
            self.postButton.isEnabled = true
            feedTextView.textColor = postTextColor//textColorDark
        }
        
        feedTextView.backgroundColor = UIColor.clear
        feedTextView.isScrollEnabled = false
        feedTextView.font = UIFont(name: fontName, size: FONTSIZEExtraLarge)
       // feedTextView.autocorrectionType = UITextAutocorrectionType.no
        scrollView.addSubview(feedTextView)
        
        
        let tempGestureButton = createButton(CGRect(x:0,y:self.feedTextView.frame.size.height+self.feedTextView.frame.origin.y ,width:self.feedTextView.frame.size.width,height:self.feedTextView.frame.size.height*2),  title: NSLocalizedString("",  comment: ""), border: false,bgColor: false, textColor: textColorMedium)
        tempGestureButton.addTarget(self, action: #selector(AdvancePostFeedViewController.becomeFirstResponderTextView), for: .touchUpInside)
        scrollView.addSubview(tempGestureButton)
        
        if #available(iOS 9.0, *) {
            let item : UITextInputAssistantItem = feedTextView.inputAssistantItem
            item.leadingBarButtonGroups = []
            item.trailingBarButtonGroups = []
        }
        
        
        //print(editFeedDict)
        var body_t :  String!
        if  let body_param = editFeedDict["action_type_body_params"] as? NSArray{
            for i in 0 ..< body_param.count {
                let body1 = body_param[i] as! NSDictionary
                if body1["search"] as! String == "{body:$body}"{
                    if ( body1["label"] is String){
                        body_t =   body1["label"] as! String
                        body_t = body_t.replacingOccurrences(of: "<br />", with: "\n")
                        
                    }
                    editBody = body_t
                    
                }
                
            }
        }
        
        switch(openfeedStyle)
        {
        case 1:
            openVideoPicker()
        case 2:
            photoOptions()
        case 3:
            openCheckIn()
        default:
            print("default")
        }
        
        var postOptions = [Int:String]()
        var sequence = [Int]()
        var postOptionsName = [Int:String]()
        // if isEditFeed == false {
        if postPermission.count>0 && openfeedStyle  != 4
        {
            if let addTag = postPermission["withtags"] as? Bool
            {
                if addTag
                {
                    postOptions[0] = friendReuestIcon
                    sequence.append(0)
                    postOptionsName[0] = NSLocalizedString("Tag people",  comment: "")
                }
            }
            
            // Will be release in Version 1.4
            
            if let checkIn = postPermission["checkin"] as? Bool
            {
                if checkIn
                {
                    postOptions[1] = "\u{f041}"
                    sequence.append(1)
                    postOptionsName[1] = NSLocalizedString("Check in",  comment: "")
                }
            }
            
            if let image = postPermission["photo"] as? Bool
            {
                if image
                {
                    postOptions[2] = "\u{f030}"
                    sequence.append(2)
                    postOptionsName[2] = NSLocalizedString("Photos",  comment: "")
                }
            }
            if let video = postPermission["video"] as? Bool
            {
                if video
                {
                    for (key,_) in videoattachmentType
                    {
                        if key as! String == "3"
                        {
                            postOptions[5] = "\u{f03d}"
                            sequence.append(5)
                            postOptionsName[5] = NSLocalizedString("Videos",  comment: "")
                        }
                        
                    }
                }
            }
            if let link = postPermission["link"] as? Bool
            {
                if link
                {
                    postOptions[6] = "\u{f0c1}"
                    sequence.append(6)
                    postOptionsName[6] = NSLocalizedString("Links",  comment: "")
                }
            }
            if let sell = postPermission["allowAdvertize"] as? Bool
            {
                if sell
                {
                    postOptions[7] = "\u{f07a}"
                    sequence.append(7)
                    postOptionsName[7] = NSLocalizedString("Sell Something",  comment: "")
                }
            }
            
            //            postOptions[8] = "\u{f118}"
            //            sequence.append(8)
            //            postOptionsName[8] = NSLocalizedString("Feeling/Sticker",  comment: "")
            
            
            
            // }
        }
        if openfeedStyle == 4
        {
            GetchekinPostOption()
        }
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeDown.direction = UISwipeGestureRecognizer.Direction.down
        self.view.addGestureRecognizer(swipeDown)
        
        EventSelectionView =  createView(CGRect(x:10, y:-200, width:view.bounds.width-20, height:200), borderColor: borderColorMedium , shadow: true)
        EventSelectionView.isHidden = true
        view.addSubview(EventSelectionView)
        
        EventNameLabel = createTextField(CGRect(x:0, y:0, width:EventSelectionView.frame.size.width, height:40), borderColor: borderColorClear , placeHolderText: NSLocalizedString("Search",  comment: ""), corner: true)
        EventNameLabel.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Search",  comment: ""), attributes: [NSAttributedString.Key.foregroundColor: placeholderColor])
        EventNameLabel.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        EventNameLabel.font =  UIFont(name: fontName, size: FONTSIZENormal)
        EventNameLabel.backgroundColor  =  textColorLight
        EventNameLabel.delegate = self
        EventNameLabel.textColor = textColorMedium
        EventNameLabel.layer.masksToBounds = true
        EventSelectionView.addSubview(EventNameLabel)
        
        crossBtn = createButton(CGRect(x: getRightEdgeX(inputView: EventNameLabel) - 35, y: 10, width:20, height: 20),title:"" , border: false,bgColor: false, textColor: textColorDark)
        crossBtn.titleLabel?.font = UIFont(name: fontName , size: FONTSIZESmall)
        crossBtn.setImage(UIImage(named: "cross_icon")?.maskWithColor(color: textColorDark), for: UIControl.State())
        crossBtn.addTarget(self, action: #selector(AdvancePostFeedViewController.hideAction(_:)), for: .touchUpInside)
        EventSelectionView.addSubview(crossBtn)
        
        
        let lineView1 = UIView(frame: CGRect(x:0,y:self.EventNameLabel.frame.size.height+self.EventNameLabel.frame.origin.y ,width:self.EventNameLabel.frame.size.width,height:0.5))
        lineView1.layer.borderWidth = 0.5
        lineView1.layer.borderColor = textColorMedium.cgColor
        EventSelectionView.addSubview(lineView1)
        
        
        EventTable = UITableView(frame: (CGRect(x:EventNameLabel.bounds.origin.x,y:EventNameLabel.frame.origin.y+EventNameLabel.frame.size.height+1, width:EventNameLabel.bounds.size.width, height:158)), style: UITableView.Style.grouped)
        EventTable.register(CustomTableViewCell.self, forCellReuseIdentifier: "cell")
        EventTable.contentInset = UIEdgeInsets(top: -35, left: 0, bottom: 0, right: 0)
        EventTable.rowHeight = 60
        EventTable.isOpaque = false
        
        EventTable.backgroundColor = UIColor.clear//tableViewBgColor
        EventSelectionView.addSubview(EventTable)
        
        
        bannerImageView = createImageView(CGRect(x:10 , y: feedTextView.frame.origin.y + 10 , width: view.bounds.width - 20 , height: 300), border: false)
        
        tabsContainerMenu = UIScrollView(frame: CGRect(x:  40, y: UIScreen.main.bounds.height - (50 + 25 + ButtonHeight + iphonXBottomsafeArea),width: view.bounds.width-PADING-40 ,height: 30 ))
        tabsContainerMenu.backgroundColor = bgColor
        tabsContainerMenu.tag = 2
        view.addSubview(tabsContainerMenu)
        
        extraMenuLeft  = createButton(CGRect(x: 10,y: UIScreen.main.bounds.height - (50 + 25 + ButtonHeight + iphonXBottomsafeArea) , width: 30, height: 30), title: "", border: true,bgColor: false, textColor: textColorMedium)
        extraMenuLeft.setImage(UIImage(named: "customback")?.maskWithColor(color: textColorMedium), for: UIControl.State.normal)
        extraMenuLeft.titleLabel?.font =  UIFont(name: fontNormal, size: 10)
        extraMenuLeft.addTarget(self, action: #selector(AdvancePostFeedViewController.scrollImage), for: .touchUpInside)
        extraMenuLeft.backgroundColor = bgColor
        
        
        
        extraMenuLeft.layer.cornerRadius = 2.0
        extraMenuLeft.layer.masksToBounds = true
        
        extraMenuLeft.layer.borderWidth = 0.5
        extraMenuLeft.layer.borderColor = textColorMedium.cgColor
        extraMenuLeft.isHidden = true
        view.addSubview(extraMenuLeft)
        
        whiteBoxButton  = createButton(CGRect(x: 10,y: 0 , width: 30, height: 30), title: "\(whiteBox)", border: true,bgColor: false, textColor: textColorLight)
        whiteBoxButton.titleLabel?.font =  UIFont(name: "FontAwesome", size: 30)
        whiteBoxButton.addTarget(self, action: #selector(AdvancePostFeedViewController.removeView), for: .touchUpInside)
        
        whiteBoxButton.isHidden = true
        whiteBoxButton.layer.borderWidth = 0.3
        whiteBoxButton.layer.borderColor = borderMediumColor.cgColor
        whiteBoxButton.layer.masksToBounds = false
        whiteBoxButton.layer.shadowOffset = CGSize(width: 0, height: 5);
        whiteBoxButton.layer.shadowOpacity = 0.5
        
        tabsContainerMenu.addSubview(whiteBoxButton)
        
        
        
        //  MARK :  start work for bottom sheets
        //  if isEditFeed == false {
        if postPermission.count>0 && openfeedStyle  != 4{
            if postOptionsName.count > 0 && self.isEditFeed == false {
                addBottomSheetView(postOptions : postOptions, sequence : sequence, postOptionsName : postOptionsName)
            }
        }
        //  }
        if isEditFeed == true {
            resign()
        }
        
        if isEditFeed == true &&  attachmentCount >= 1 {
            
            tabsContainerMenu.isHidden = true
            
        }
        else{
            if bannerAllow == 1 {
                showtabMenu()
            }
            
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeSheetHeight(notification:)), name: NSNotification.Name(rawValue: "changeSheetHeight"), object: nil)
        // finish work for bottom sheet
        
    }
    
    @objc func changeSheetHeight(notification : NSNotification)
    {
        if let userInfo = notification.userInfo
        {
            let tableHeight = userInfo["height"] as? CGFloat ?? 0.0
            bottomSheetVC.fullView =  tableHeight - iphonXBottomsafeArea//320//250 - (50 + 25)//CGFloat((postOptions.count * 50) + 25)
            bottomSheetVC.view.frame = CGRect(x:0,y:UIScreen.main.bounds.height - iphonXBottomsafeArea - tableHeight, width:view.frame.width, height:tableHeight)
            
            if openfeedStyle == 1 || openfeedStyle == 2{
                bottomSheetVC.view.frame.origin.y = bottomSheetVC.partialView
                bottomSheetVC.PostFeedListObj.isHidden = true
                bottomSheetVC.postView.isHidden = false
            }
            print("Table height ---> \(tableHeight)")
        }
        
    }
    
    // Click to remove the background image
    @objc func removeView(){
        whiteBoxSelected = true
        if bannerImageView.image != nil || bannerImageView.tag == 100{
            UIView.animate(withDuration: 0.3) {
                self.imgBorderBackground.center = self.whiteBoxButton.center
            }
            var frame = scrollView.frame
            frame.origin.y = 0
            scrollView.frame = frame
            bannerImageView.image = nil
            bannerImageView.isHidden = true
            bannerImageView.tag = 0
            buttonTextView.isHidden = true
            feedTextView.isHidden = false
            feedTextView.isScrollEnabled = true
            CheckParameters.removeAll()
            // buttonTextView.resignFirstResponder()
            feedTextView.becomeFirstResponder()
            feedTextView.text = buttonTextView.text
            
        }
    }
    
    @objc func scrollImage(){
        extraMenuLeft.setImage(nil, for: UIControl.State.normal)
        if imageCovert == false{
            imageCovert = true
            
            
            tabsContainerMenu.setContentOffset(CGPoint(x:tabsContainerMenu.contentSize.width,y: 0), animated: true)
            extraMenuLeft.setImage(UIImage(named: "coloredRing"), for: UIControl.State.normal)
            extraMenuLeft.layer.borderWidth = 0.0
        }
        else{
            imageCovert = false
            extraMenuLeft.setImage(UIImage(named: "customback")?.maskWithColor(color: textColorMedium), for: UIControl.State.normal)
            tabsContainerMenu.setContentOffset(CGPoint(x:0,y: 0), animated: true)
            extraMenuLeft.layer.borderWidth = 0.5
        }
    }
    
    @objc func showTarget(){
        isCreateOrEdit = true
        let presentedVC = TargetScheduledPostViewController()
       // presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        let nativationController = UINavigationController(rootViewController: presentedVC)
        nativationController.modalPresentationStyle = .fullScreen
        self.present(nativationController, animated:false, completion: nil)
        //  self.navigationController?.pushViewController(presentedVC, animated: false)
    }
    
    @objc func showSchedule(){
        isCreateOrEdit = true
        let presentedVC = TargetScheduledPostViewController()
        presentedVC.contentType = "Schedule"
      //  presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        let nativationController = UINavigationController(rootViewController: presentedVC)
        nativationController.modalPresentationStyle = .fullScreen
        self.present(nativationController, animated:false, completion: nil)
        // self.navigationController?.pushViewController(presentedVC, animated: false)
    }
    
    func showtabMenu(){
        
        for ob in tabsContainerMenu.subviews{
            if ob.tag == 101{
                ob.removeFromSuperview()
            }
        }
        
        extraMenuLeft.isHidden = false
        whiteBoxButton.isHidden  = false
        
        var origin_x:CGFloat = PADING + 50
        
        for menu in bannerArray{
            
            if let menuItem = menu as? NSDictionary{
                let width  = CGFloat(30)
                
                let menu = createButton(CGRect(x: origin_x,y: 0 ,width: width , height: width ), title: "", border: true, bgColor: false, textColor: UIColor.clear)
                menu.layer.borderWidth = 0.5
                menu.layer.borderColor = bgColor.cgColor
                var check1 = menuItem["background-color"] as! String
                let _ = check1.remove(at: (check1.startIndex))
                menu.backgroundColor = UIColor(hex: "\(check1)")
                if let url1 = menuItem["feed_banner_url"] as? String
                {
                    let url1 = URL(string: url1)
                    menu.kf.setBackgroundImage(with: url1, for: .normal, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                        
                    })
                }
                var check = menuItem["color"] as! String
                let _ = check.remove(at: (check.startIndex))
                menu.accessibilityIdentifier = "\(menuItem["image"] as! String),\(menuItem["color"] as! String),\(menuItem["background-color"] as! String)"
                
                menu.tag = 101
                menu.addTarget(self, action: #selector(AdvancePostFeedViewController.tabMenuAction(_:)), for: .touchUpInside)
                tabsContainerMenu.addSubview(menu)
                
                origin_x += width + 10
                
            }
        }
        tabsContainerMenu.contentSize = CGSize(width: origin_x, height: tabsContainerMenu.bounds.height)
        tabsContainerMenu.showsHorizontalScrollIndicator = false
        
        imgBorderBackground = createImageView(CGRect(x: 10, y: 0 , width: 30, height: 30), border: true)
        imgBorderBackground.layer.borderColor = navColor.cgColor
        imgBorderBackground.layer.borderWidth = 2.0
        tabsContainerMenu.addSubview(imgBorderBackground)
        imgBorderBackground.image = UIImage(named: "squareclip.png")
        imgBorderBackground.isUserInteractionEnabled = true
        
    }
    
    @objc func tabMenuAction(_ sender: UIButton){
        
        //print(sender.accessibilityIdentifier!)
        let title = sender.accessibilityIdentifier!
        var titlearr = [String]()
        titlearr = title.components(separatedBy: ",")
        //print(titlearr[1])
        BannerJsonValue["image"] = titlearr[0]
        BannerJsonValue["color"] = titlearr[1]
        BannerJsonValue["background-color"] = titlearr[2]
        //print(BannerJsonValue)
        
        UIView.animate(withDuration: 0.3) {
            self.imgBorderBackground.center = sender.center
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: BannerJsonValue, options:  [])
            let  finalString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
            
            //print(finalString)
            
            let templocationString = "{\"banner\":"
            let modify = templocationString + finalString
            bannerComposer = modify
            let locationString = templocationString + finalString + "}"
            CheckParameters["composer"] = locationString as AnyObject?
            tempParameters = CheckParameters
            //print("====final===")
            //print(CheckParameters)
        }
        catch _ as NSError {
            // failure
            //print("Fetch failed: \(error.localizedDescription)")
        }
        
        whiteBoxSelected = false
        
        buttonTextView.frame.origin.y = feedTextView.frame.origin.y + 10
        buttonTextView.isHidden = false
        
        buttonTextView.becomeFirstResponder()
        buttonTextView.setNeedsLayout()
        buttonTextView.textAlignment = NSTextAlignment.center
        buttonTextView.tag = 501
        var check = titlearr[1]
        let _ = check.remove(at: (check.startIndex))
        buttonTextView.textColor = UIColor(hex: "\(check)")
        buttonTextView.delegate = self
        if backupTextView.text != "" {
            buttonTextView.text = backupTextView.text
        }
        else{
            buttonTextView.text = feedTextView.text
            
        }
        if buttonTextView.text == NSLocalizedString("What's on your mind?",comment: ""){
            buttonTextView.resignFirstResponder()
        }
        
        
        scrollView.addSubview(bannerImageView)
        scrollView.addSubview(buttonTextView)
        var check1 = titlearr[2]
        let _ = check1.remove(at: (check1.startIndex))
        bannerImageView.backgroundColor = UIColor(hex: "\(check1)")
        bannerImageView.tag = 100
        bannerImageView.image = sender.currentBackgroundImage
        
        bannerImageView.isHidden = false
        feedTextView.isHidden = true
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.buttonTextView.scrollRangeToVisible(NSMakeRange(100, 100))
        
    }
    
    
    // MARK:  UIDatepicker start
    @objc func datePickerValueChanged(_ sender: UIDatePicker)
    {
        
        // Create date formatter
        let dateFormatter: DateFormatter = DateFormatter()
        // Set date format
        dateFormatter.dateFormat = "MM/dd/yyyy"
        // Apply date format
        selectedDate = dateFormatter.string(from: sender.date)
        
        
    }
    
    @objc func donePicker (sender:UIBarButtonItem)
    {
        let subView = self.view.subviews
        for option in subView
        {
            if option.tag == 44
            {
                option.removeFromSuperview()
            }
        }
        
        if sender.title == "Done" && selectedDate != ""
        {
            btnCheckin.setTitle(NSLocalizedString(selectedDate,  comment: ""), for: .normal)
            btnCheckin.isHidden = false
        }
        else
        {
            let date = Date()
            let dateFormatter: DateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            selectedDate = dateFormatter.string(from: date)
            btnCheckin.setTitle(NSLocalizedString(selectedDate,  comment: ""), for: .normal)
            btnCheckin.isHidden = false
        }
        updateButtonText()
        
    }
    func showDatepicker()
    {
        self.view.endEditing(true)
        let datePicker: UIDatePicker = UIDatePicker()
        // Posiiton date picket within a view
        datePicker.frame = CGRect(x: 0, y: self.view.frame.height-200, width: self.view.frame.width, height: 200)
        // Set some of UIDatePicker properties
        datePicker.timeZone = NSTimeZone.local
        datePicker.backgroundColor = UIColor.white
        datePicker.datePickerMode = .date
        datePicker.tag = 44
        
        
        // Add an event to call onDidChangeDate function when value is changed.
        datePicker.addTarget(self, action: #selector(AdvancePostFeedViewController.datePickerValueChanged(_:)), for: .valueChanged)
        // Add DataPicker to the view
        self.view.addSubview(datePicker)
        let toolBar = UIToolbar()
        toolBar.frame = CGRect(x: 0, y: self.view.frame.height-250, width: self.view.frame.width, height: 50)
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = false
        toolBar.backgroundColor = UIColor.white
        toolBar.tintColor = navColor
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action:#selector(AdvancePostFeedViewController.donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action:#selector(AdvancePostFeedViewController.donePicker))
        toolBar.tag = 44
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        self.view.addSubview(toolBar)
    }
    
    // Function to show Bottom Sheet
    
    func addBottomSheetView(postOptions : [Int:String], sequence : [Int],postOptionsName : [Int:String])
    {
        
        // 1- Init bottomSheetVC
        bottomSheetVC.delegate = self
        bottomSheetVC.postFeedOptions = postOptions
        bottomSheetVC.postOptionsName = postOptionsName
        bottomSheetVC.sequences = sequence
        
        // 2- Add bottomSheetVC as a child view
        self.addChild(bottomSheetVC)
        self.view.addSubview(bottomSheetVC.view)
        bottomSheetVC.didMove(toParent: self)
        
        // 3- Adjust bottomSheet frame and initial position.
        let height  = 250//(postOptions.count * 50) + 25
        let width  = view.frame.width
        
        bottomSheetVC.fullView =  250 - iphonXBottomsafeArea//320//250 - (50 + 25)//CGFloat((postOptions.count * 50) + 25)
        bottomSheetVC.view.frame = CGRect(x:0,y:(Int(view.frame.height) - Int(iphonXBottomsafeArea) - height) , width:Int(width), height:Int(height))
        
        if openfeedStyle == 1 || openfeedStyle == 2{
            bottomSheetVC.view.frame.origin.y = bottomSheetVC.partialView
            bottomSheetVC.PostFeedListObj.isHidden = true
            bottomSheetVC.postView.isHidden = false
        }
        
        
    }
    
    func selectFileAction()
    {
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseOut, animations: {
            self.EventSelectionView.frame =  CGRect(x:10, y:120, width:self.view.bounds.width-20, height:200)
            self.EventSelectionView.isHidden = false
            self.EventNameLabel.text = ""
            self.EventNameLabel.becomeFirstResponder()
            self.EventTable.delegate = self
            self.EventTable.dataSource = self
        }, completion: { finished in
        })
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
            activityIndicatorView.center = CGPoint(x: view.center.x, y: 140)
            //            spinner.hidesWhenStopped = true
            //            spinner.style = UIstyle.gray
            //            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            // activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            userInteractionOff = false
            var str : String = EventNameLabel.text!
            while str.hasPrefix("@") {
                str.remove(at: str.startIndex)
            }
            // Send Server Request to Share Content
            post(["search":"\(str)", "limit": "10"], url: "advancedactivity/friends/suggest", method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    userInteractionOff = true
                    activityIndicatorView.stopAnimating()
                    if msg
                    {
                        
                        if let eventArr = succeeded["body"] as? NSArray
                        {
                            self.EventArray = eventArr
                            self.EventTable.reloadData()
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
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        
        return 60.0
        
        
    }
    
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        return EventArray.count
        
    }
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        tableView.separatorStyle = .none
        
        if let response = EventArray[(indexPath as NSIndexPath).row] as? NSDictionary {
            cell.labTitle.frame.size.width = (UIScreen.main.bounds.width - (cell.imgUser.bounds.width + 15))
            // Set Name People who Likes Content
            cell.labTitle.text = response["label"] as? String
            cell.labTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
            cell.labTitle.sizeToFit()
            
            // Set Frnd Image
            // Set Feed Owner Image
            if let imgUrl = response["image_icon"] as? String{
                let url = URL(string:imgUrl)
                if url != nil
                {
                    cell.imgUser.image = nil
                    cell.imgUser.kf.indicatorType = .activity
                    (cell.imgUser.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    cell.imgUser.kf.setImage(with: url as URL!, placeholder: UIImage(named : "user_profile_image.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        
                    })
                }
                
            }
            
            if let id = response["id"] as? Int{
                if frndTag[id] != nil{
                    cell.accessoryType = UITableViewCell.AccessoryType.checkmark
                }else{
                    cell.accessoryType = UITableViewCell.AccessoryType.none
                }
            }
            
        }
        return cell
    }
    
    // Handle Blog Table Cell Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        if let response = EventArray[(indexPath as NSIndexPath).row] as? NSDictionary {
            frndTagValue[(response["guid"] as? String)!] = response["label"] as? String
            selectedString = ""
            selectedString = (response["label"] as? String)!
            
        }
        addFriendTag()
        
        
    }
    
    func addFriendTag(){
        
        if bannerImageView.image != nil || bannerImageView.tag == 100{
            let myString = buttonTextView.text
            let myStringWithoutLastWord = myString?.components(separatedBy: " ").dropLast().joined(separator: " ")
            buttonTextView.text = myStringWithoutLastWord
            self.EventSelectionView.isHidden = true
            buttonTextView.text.append(" " + selectedString)
            buttonTextView.becomeFirstResponder()
        }
        else{
            
            let myString = feedTextView.text
            let myStringWithoutLastWord = myString?.components(separatedBy: " ").dropLast().joined(separator: " ")
            feedTextView.text = myStringWithoutLastWord
            self.EventSelectionView.isHidden = true
            feedTextView.text.append(" " + selectedString)
            feedTextView.becomeFirstResponder()
        }
        
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: frndTagValue, options:  [])
            let  finalString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
            
            
            var tempDic = [String:AnyObject]()
            tempDic.updateValue(finalString as AnyObject, forKey: "tagValue")
            let Replacefinal = finalString.replacingOccurrences(of: "{", with: "")
            let finalReplace = Replacefinal.replacingOccurrences(of: "}", with: "")
            let finalReplace1 = finalReplace.replacingOccurrences(of: "\"", with: "")
            let finalReplace2 = finalReplace1.replacingOccurrences(of: ",", with: "&")
            let finalReplace3 = finalReplace2.replacingOccurrences(of: ":", with: "=")
            let finalValue = "\"\(finalReplace3)\""
            let templocationString = "{\"tag\":"
            let locationString = templocationString + finalValue + "}"
            let modify = "\"tag\":"
            let modify1 = modify + finalValue + "}"
            Modify_composer1 = modify1 as AnyObject?
            CheckParameters["composer"] = locationString as AnyObject?
            // success ...
        } catch _ as NSError {
            // failure
            //print("Fetch failed: \(error.localizedDescription)")
        }
        
    }
    // MARK:  UITextViewDelegate
    func textViewDidChange(_ textView: UITextView)
    {
        
        if textView.text == NSLocalizedString("What's on your mind?",comment: "")
        {
            textView.text = nil
        }
        if textView.tag == 501
        {
            
            
            if textView.text.isEmpty
            {
                self.postButton.isEnabled = false
            }
            else
            {
                self.postButton.isEnabled = true
            }
            // textView.isScrollEnabled = true
            feedTextView.text = textView.text
            textView.becomeFirstResponder()
            if textView.text.length >= bannerTextLimit {
                //  backupImageView.image = bannerImageView.image
                backupTextView.text = textView.text
                bannerImageView.isHidden = true
                buttonTextView.isHidden  = true
                CheckParameters.removeAll()
                feedTextView.isHidden = false
                tabsContainerMenu.isHidden = true
                extraMenuLeft.isHidden = true
                let bounds = UIScreen.main.bounds
                let height = bounds.size.height
                switch height
                {
                case 568.0:
                    // spalshName = "Splash-640x960"
                    var frame = scrollView.frame
                    frame.origin.y = 0
                    scrollView.frame = frame
                    
                    
                default:
                    var frame = scrollView.frame
                    frame.origin.y = 0
                    scrollView.frame = frame
                    
                    
                }
                
                
                tabsContainerMenu.frame.origin.y = UIScreen.main.bounds.height - (50 + 25 + ButtonHeight + iphonXBottomsafeArea)
                extraMenuLeft.frame.origin.y = tabsContainerMenu.frame.origin.y
            }
            if textView.text.length < bannerTextLimit {
                
                backupTextView.text = ""
                
                bannerImageView.isHidden = false
                tabsContainerMenu.isHidden = false
                extraMenuLeft.isHidden = false
                buttonTextView.isHidden  = false
                feedTextView.isHidden = true
                CheckParameters = tempParameters
                buttonTextView.text = textView.text
                
                if !(DeviceType.IS_IPHONE_X) {
                    
                    if bannerImageView.image != nil || bannerImageView.tag == 100{
                        
                        
                        //print(( bannerImageView.frame.origin.y + bannerImageView.frame.size.height ) - bottomSheetVC.view.frame.origin.y)
                        
                        let bounds = UIScreen.main.bounds
                        let height = bounds.size.height
                        switch height
                        {
                        case 568.0:
                            
                            var frame = scrollView.frame
                            frame.origin.y = -203
                            scrollView.frame = frame
                            
                        case 736.0:
                            
                            scrollView.contentOffset = CGPoint(x: 0, y: -(tabsContainerMenu.frame.size.height - 20 ))
                        case 667.0:
                            
                            scrollView.contentOffset = CGPoint(x: 0, y: -(tabsContainerMenu.frame.size.height - 65 ))
                            
                        default:
                            let x = bannerImageView.frame.origin.y + bannerImageView.frame.size.height
                            let y = bottomSheetVC.view.frame.origin.y + 20 + ( tabsContainerMenu.frame.size.height - 10)
                            let yXis = ( x - y)
                            scrollView.contentOffset = CGPoint(x: 0, y: -yXis)
                            
                        }
                        
                        tabsContainerMenu.frame.origin.y = bottomSheetVC.view.frame.origin.y - tabsContainerMenu.frame.size.height - 5
                        extraMenuLeft.frame.origin.y = tabsContainerMenu.frame.origin.y
                        
                    }
                }
                else{
                    
                    if bannerImageView.image != nil || bannerImageView.tag == 100{
                        scrollView.contentOffset = CGPoint(x: 0, y: -(tabsContainerMenu.frame.size.height - 10 ))
                        
                        tabsContainerMenu.frame.origin.y = bottomSheetVC.view.frame.origin.y - tabsContainerMenu.frame.size.height - 5
                        extraMenuLeft.frame.origin.y = tabsContainerMenu.frame.origin.y
                        
                    }
                }
                
            }
            let strin = textView.text
            if strin != "" {
                if strin?[(strin?.startIndex)!] == "@"{
                    tagwithcheckin = 1
                    selectFileAction()
                }
                else if(strin?.range(of: " @") != nil){
                    if (strin?.components(separatedBy: " @").last) != nil {
                        tagwithcheckin = 1
                        selectFileAction()
                    }
                }
            }
            else{
                self.EventSelectionView.isHidden = true
                
                
            }
            
        }
        else{
            
            
            feedTextView.text = textView.text
            if textView.text.length <= feedCharLength{
                textView.textColor = postTextColor
                textView.font = UIFont(name : fontNormal , size : CGFloat(feedFontSize))
            }
            else{
                textView.textColor = textColorDark
            }
            textView.becomeFirstResponder()
            if whiteBoxSelected == false {
                if textView.text.length >= bannerTextLimit {
                    //  backupImageView.image = bannerImageView.image
                    backupTextView.text = textView.text
                    bannerImageView.isHidden = true
                    CheckParameters.removeAll()
                    buttonTextView.isHidden  = true
                    feedTextView.isHidden = false
                    tabsContainerMenu.isHidden = true
                    extraMenuLeft.isHidden = true
                    let bounds = UIScreen.main.bounds
                    let height = bounds.size.height
                    switch height
                    {
                    case 568.0:
                        
                        var frame = scrollView.frame
                        frame.origin.y = 0
                        scrollView.frame = frame
                        
                        
                    default:
                        var frame = scrollView.frame
                        frame.origin.y = 0
                        scrollView.frame = frame
                        
                    }
                    
                    
                    
                    tabsContainerMenu.frame.origin.y = UIScreen.main.bounds.height - (50 + 25 + ButtonHeight + iphonXBottomsafeArea)
                    extraMenuLeft.frame.origin.y = tabsContainerMenu.frame.origin.y
                }
                if textView.text.length < bannerTextLimit {
                    //    if backupImageView.image != nil {
                    bannerImageView.isHidden = false
                    tabsContainerMenu.isHidden = false
                    extraMenuLeft.isHidden = false
                    buttonTextView.isHidden  = false
                    CheckParameters = tempParameters
                    feedTextView.isHidden = true
                    buttonTextView.text = textView.text
                    backupTextView.text = ""
                    if !(DeviceType.IS_IPHONE_X) {
                        
                        if bannerImageView.image != nil || bannerImageView.tag == 100{
                            
                            
                            let bounds = UIScreen.main.bounds
                            let height = bounds.size.height
                            switch height
                            {
                            case 568.0:
                                
                                var frame = scrollView.frame
                                frame.origin.y = -203
                                scrollView.frame = frame
                                
                            case 736.0:
                                
                                scrollView.contentOffset = CGPoint(x: 0, y: -(tabsContainerMenu.frame.size.height - 20 ))
                            case 667.0:
                                
                                scrollView.contentOffset = CGPoint(x: 0, y: -(tabsContainerMenu.frame.size.height - 65 ))
                                
                            default:
                                let x =  bannerImageView.frame.origin.y + bannerImageView.frame.size.height
                                let y = bottomSheetVC.view.frame.origin.y + 20 + ( tabsContainerMenu.frame.size.height - 10)
                                scrollView.contentOffset = CGPoint(x: 0, y: -( x - y))
                                
                            }
                            
                            tabsContainerMenu.frame.origin.y = bottomSheetVC.view.frame.origin.y - tabsContainerMenu.frame.size.height - 5
                            extraMenuLeft.frame.origin.y = tabsContainerMenu.frame.origin.y
                            
                        }
                    }
                    else{
                        
                        if bannerImageView.image != nil || bannerImageView.tag == 100{
                            scrollView.contentOffset = CGPoint(x: 0, y: -(tabsContainerMenu.frame.size.height - 10 ))
                            
                            tabsContainerMenu.frame.origin.y = bottomSheetVC.view.frame.origin.y - tabsContainerMenu.frame.size.height - 5
                            extraMenuLeft.frame.origin.y = tabsContainerMenu.frame.origin.y
                            
                        }
                    }
                    
                }
            }
            
            
            let strin = textView.text
            if strin != "" {
                if strin?[(strin?.startIndex)!] == "@"{
                    tagwithcheckin = 1
                    selectFileAction()
                }
                else if(strin?.range(of: " @") != nil){
                    if (strin?.components(separatedBy: " @").last) != nil {
                        tagwithcheckin = 1
                        selectFileAction()
                    }
                }
            }
            else{
                self.EventSelectionView.isHidden = true
                
                
            }
            
            
            if textView.text.isEmpty
            {
                self.postButton.isEnabled = false
            }
            else
            {
                self.postButton.isEnabled = true
                
            }
            textView.frame.size.width = view.bounds.width-20
            
            if photoAttachmentMode == false{
                if textView.frame.size.height < 100 {
                    textView.sizeToFit()
                    textView.layoutIfNeeded()
                    UIView.animate(withDuration: 0.5, animations: {
                        
                        if self.photoView != nil{
                            self.photoView.frame.origin.y = self.feedTextView.bounds.height + self.feedTextView.frame.origin.y
                        }
                    })
                }
                else{
                    
                    textView.isScrollEnabled = true
                }
            }else{
                textView.frame.size.height = 75
                textView.isScrollEnabled = true
            }
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool
    {
        
        if textView.tag == 501{
            if textView.text == NSLocalizedString("What's on your mind?",comment: "")
            {
                textView.text = nil
            }
            
            if !(DeviceType.IS_IPHONE_X) {
                
                
                let bounds = UIScreen.main.bounds
                let height = bounds.size.height
                switch height
                {
                case 568.0:
                    
                    var frame = scrollView.frame
                    frame.origin.y = -203
                    scrollView.frame = frame
                    
                case 667.0:
                    
                    scrollView.contentOffset = CGPoint(x: 0, y: -(tabsContainerMenu.frame.size.height - 65 ))
                    
                case 736.0:
                    
                    scrollView.contentOffset = CGPoint(x: 0, y: -(tabsContainerMenu.frame.size.height - 20 ))
                    
                    
                default:
                    
                    let x = bannerImageView.frame.origin.y + bannerImageView.frame.size.height
                    let y = bottomSheetVC.view.frame.origin.y + 20 + ( tabsContainerMenu.frame.size.height - 10)
                    scrollView.contentOffset = CGPoint(x: 0, y: -( x - y))
                    
                }
                tabsContainerMenu.frame.origin.y = bottomSheetVC.view.frame.origin.y - tabsContainerMenu.frame.size.height - 5
                extraMenuLeft.frame.origin.y = tabsContainerMenu.frame.origin.y
                
                
            }
            else
            {
                
                scrollView.contentOffset = CGPoint(x: 0, y: -(tabsContainerMenu.frame.size.height - 10 ))
                
                tabsContainerMenu.frame.origin.y = bottomSheetVC.view.frame.origin.y - tabsContainerMenu.frame.size.height - 5
                extraMenuLeft.frame.origin.y = tabsContainerMenu.frame.origin.y
                
            }
            
            return true
        }
        let subView = self.view.subviews
        for option in subView
        {
            if option.tag == 44
            {
                option.removeFromSuperview()
            }
        }
        if textView.textColor == postTextColor && openfeedStyle != 4 && textView.text == NSLocalizedString("What's on your mind?",comment: "")
        {
            textView.text = nil
            textView.textColor = postTextColor
        }
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        
        return true
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let input = text
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector.matches(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count))
        
        for match in matches {
            guard let range = Range(match.range, in: input) else { continue }
            let url = input[range]
            self.linkUrl = String(url)
            attachvideofromDevice = false
            if bannerImageView.image != nil || bannerImageView.tag == 100{
            }
            else{
                getAttachmentData()
            }
        }
        return true
    }
    func updateUserText() {
        
        let userName = displayName
        
        var completeUserDetailString = displayName as NSString
        if locationInfoString != "" && taggedFriendsString == ""{
            completeUserDetailString = displayName + " is at \(locationInfoString)" as NSString
        }else if taggedFriendsString != "" && locationInfoString == "" {
            completeUserDetailString = displayName + " is with \(taggedFriendsString)" as NSString
        }else if taggedFriendsString != "" && locationInfoString != "" {
            completeUserDetailString = displayName + " is with \(taggedFriendsString) at \(locationInfoString)" as NSString
        }
        
        self.userDetails.setText(completeUserDetailString, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
            let boldFont = CTFontCreateWithName( (fontBold as CFString?)!, FONTSIZEMedium, nil)
            
            let range1 = (completeUserDetailString as NSString).range(of: userName!)
            mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range1)
            mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorDark , range: range1)
            
            if self.locationInfoString != "" {
                let range2 = (completeUserDetailString as NSString).range(of: self.locationInfoString)
                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range2)
                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorDark , range: range2)
            }
            
            if self.taggedFriendsString != "" {
                let range3 = (completeUserDetailString as NSString).range(of: self.taggedFriendsString)
                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range3)
                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorDark , range: range3)
            }
            
            return mutableAttributedString
        })
        self.userDetails.frame.size.width = view.bounds.width - 65
        self.userDetails.sizeToFit()
        
        let userDetailHeight =  userDetails.frame.size.height + userDetails.frame.origin.y
        self.privacyButton.frame.origin.y = userDetailHeight + 3
        self.TargetButton.frame.origin.y = self.privacyButton.frame.origin.y
        self.ScheduleButton.frame.origin.y = self.privacyButton.frame.origin.y
        //self.TargetButton.frame.origin.x = self.privacyButton.frame.size.width + 5
        
        self.feedTextView.frame.origin.y = self.privacyButton.frame.origin.y + self.privacyButton.frame.size.height + 3
        
    }
    
    func photoOptions(){
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        alertController.addAction(UIAlertAction(title:  NSLocalizedString("Camera",comment: ""), style: .default) { action -> Void in
            
            if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == AVAuthorizationStatus.notDetermined {
                
                AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (videoGranted: Bool) -> Void in
                    //print("You have not determined====")
                    // User clicked ok
                    if (videoGranted) {
                        //print("open camera======")
                        self.openCamera()
                        // User clicked don't allow
                    } else {
                        //print("Check not allow")
                        alertController.dismiss(animated: false, completion: nil)
                    }
                })
            }
            if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == AVAuthorizationStatus.authorized {
                //print("You have not denied====")
                self.openCamera()
            }
            if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == AVAuthorizationStatus.denied {
                let alert = UIAlertController(title: "Access Denied", message: "This app does not have access to your camera. You can enable access in privacy settings.", preferredStyle: UIAlertController.Style.alert)
                
                // add an action (button)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                
                // show the alert
                self.present(alert, animated: true, completion: nil)
                //print("You have denied")
            }
            if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == AVAuthorizationStatus.restricted {
                //print("You have not restricted====")
            }
            
        })
        
        alertController.addAction(UIAlertAction(title:  NSLocalizedString("Gallery",comment: ""), style: UIAlertAction.Style.default) { action -> Void in
            self.openGallery()
        })
        
        if  (UIDevice.current.userInterfaceIdiom == .phone){
            alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .cancel, handler:nil))
        }
        else
        {
            // Present Alert as! Popover for iPad
            alertController.modalPresentationStyle = UIModalPresentationStyle.popover
            let popover = alertController.popoverPresentationController
            popover?.sourceView = self.view
            popover?.sourceRect = CGRect(x: view.bounds.width/2, y: view.bounds.height/2 , width: 1, height: 1)
            popover?.permittedArrowDirections = UIPopoverArrowDirection()
        }
        self.present(alertController, animated:true, completion: nil)
        
    }
    
    @objc func keyboardWillBeHidden(_ sender: Foundation.Notification) {
        bottomSheetVC.view.frame.origin.y = bottomSheetVC.partialView
        scrollView.frame.size.height = view.bounds.height
        bottomSheetVC.postView.isHidden = false
        
        let bounds = UIScreen.main.bounds
        let height = bounds.size.height
        switch height
        {
        case 568.0:
            
            var frame = scrollView.frame
            frame.origin.y = 0
            scrollView.frame = frame
            
        default:
            
            let contentInsets: UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0, right: 0.0)
            scrollView?.contentInset = contentInsets
            
        }
        
        
        tabsContainerMenu.frame.origin.y = UIScreen.main.bounds.height - (50 + 25 + ButtonHeight + iphonXBottomsafeArea)
        extraMenuLeft.frame.origin.y = tabsContainerMenu.frame.origin.y
        
        
    }
    
    @objc func keyboardWillShow(_ sender: Foundation.Notification) {
        if let userInfo = (sender as NSNotification).userInfo {
            
            let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size.height
            
            if keyboardHeight > 0 {
                bottomSheetVC.view.frame.origin.y = self.view.bounds.height - keyboardHeight - (bottomSheetVC.postView.frame.origin.y + bottomSheetVC.postView.frame.size.height )
                bottomSheetVC.PostFeedListObj.isHidden = true
                bottomSheetVC.postView.isHidden = false
                tabsContainerMenu.frame.origin.y = bottomSheetVC.view.frame.origin.y - tabsContainerMenu.frame.size.height - 5
                extraMenuLeft.frame.origin.y = tabsContainerMenu.frame.origin.y
                
                
                if (!(buttonTextView.isHidden)){
                    
                    if !(DeviceType.IS_IPHONE_X) {
                        
                        if bannerImageView.image != nil || bannerImageView.tag == 100{
                            
                            let bounds = UIScreen.main.bounds
                            let height = bounds.size.height
                            let x = bannerImageView.frame.origin.y + bannerImageView.frame.size.height
                            let y = bottomSheetVC.view.frame.origin.y + 20 + ( tabsContainerMenu.frame.size.height - 10)
                            let yAxis = ( x - y)
                            switch height
                            {
                            case 568.0:
                                
                                var frame = scrollView.frame
                                frame.origin.y = -203
                                scrollView.frame = frame
                                
                            case 736.0:
                                
                                scrollView.contentOffset = CGPoint(x: 0, y: -(tabsContainerMenu.frame.size.height - 25 ))
                            case 667.0:
                                
                                scrollView.contentOffset = CGPoint(x: 0, y: -(self.tabsContainerMenu.frame.size.height - 65 ))
                                
                                
                                
                                
                                
                            default:
                                
                                scrollView.contentOffset = CGPoint(x: 0, y: -yAxis)
                                
                            }
                            
                            tabsContainerMenu.frame.origin.y = bottomSheetVC.view.frame.origin.y - tabsContainerMenu.frame.size.height - 5
                            extraMenuLeft.frame.origin.y = tabsContainerMenu.frame.origin.y
                            
                        }
                    }
                    else{
                        
                        if bannerImageView.image != nil || bannerImageView.tag == 100{
                            scrollView.contentOffset = CGPoint(x: 0, y: -(tabsContainerMenu.frame.size.height - 10 ))
                            
                            tabsContainerMenu.frame.origin.y = bottomSheetVC.view.frame.origin.y - tabsContainerMenu.frame.size.height - 5
                            extraMenuLeft.frame.origin.y = tabsContainerMenu.frame.origin.y
                            
                        }
                    }
                    
                } // if loop
            }
        }
    }
    
    func openCheckIn(){
        let presentedVC = CheckInViewController()
        if openfeedStyle != nil && openfeedStyle == 3
        {
            presentedVC.fromActivityFeed = true
            if !isFromHome
            {
                presentedVC.fromActivityFeed = false
            }
        }
        else
        {
            presentedVC.fromActivityFeed = false
        }
        presentedVC.fromPostFeedVC = true
        navigationController?.pushViewController(presentedVC, animated: false)
    }
    
    @objc func showPostPrivacy(_ sender:UIButton){
        let pv = SetPrivacyViewController()
        
       // pv.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        let navigationController = UINavigationController(rootViewController: pv)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated:true, completion: nil)
        
    }
    
    func sellingView(SellForm : NSMutableDictionary){
        
        if  Formbackup.count > 0 {
            tabsContainerMenu.isHidden = true
            extraMenuLeft.isHidden = true
            sellAttachmentMode = true
            postButton.isEnabled = true
            feedTextView.isUserInteractionEnabled = false
            if sellView.subviews.count != 0 {
                sellView.removeFromSuperview()
                allSellPhotos.removeAll()
            }
            if Formbackup["photo"] != nil {
                allSellPhotos.append(Formbackup["photo"] as! UIImage)
            }
            
            
            let originY:CGFloat =  self.feedTextView.frame.origin.y + 10
            //print(allSellPhotos.count)
            
            let cornerRadius: CGFloat = 2
            let shadowOffsetWidth: Int = 0
            let shadowOffsetHeight: Int = 3
            let shadowOpacity: Float = 0.5
            
            sellView = createView(CGRect(x: 5, y: originY, width: view.bounds.width - 10 , height: 300), borderColor: UIColor.white, shadow: false)
            
            self.scrollView.addSubview(sellView)
            var innerY = 5
            
            let sellTitle = createLabel(CGRect(x: 5, y: innerY, width: Int(view.bounds.width - 80) , height: 30), text: "\(sellIcon) "+NSLocalizedString("Sell Something",  comment: ""), alignment: .left, textColor: textColorDark)
            sellTitle.font = UIFont(name: "fontAwesome", size: 18.0)
            sellView.addSubview(sellTitle)
            
            let crossSellView =  createButton(CGRect(x: Int(view.bounds.width - 30), y: innerY + 3, width: 20, height: 20), title: "", border: false,bgColor: false, textColor: buttonColor)
            crossSellView.setTitle(solidCross, for: .normal)
            crossSellView.contentHorizontalAlignment = .left
            crossSellView.titleLabel?.font = UIFont(name: "fontAwesome", size: 17.0)
            crossSellView.addTarget(self, action: #selector(AdvancePostFeedViewController.crossSellViewButton(_:)), for: .touchUpInside)
            sellView.addSubview(crossSellView)
            
            let editSellView =  createButton(CGRect(x: Int(view.bounds.width - 70), y: innerY + 3, width: 20, height: 20), title: "", border: false,bgColor: false, textColor: buttonColor)
            editSellView.setTitle(editSellIcon, for: .normal)
            editSellView.contentHorizontalAlignment = .left
            editSellView.titleLabel?.font = UIFont(name: "fontAwesome", size: 17.0)
            editSellView.addTarget(self, action: #selector(AdvancePostFeedViewController.editSellViewButton(_:)), for: .touchUpInside)
            sellView.addSubview(editSellView)
            
            innerY = innerY + Int(sellTitle.bounds.height) + 10
            
            // sellDesc = TTTAttributedLabel(frame:CGRect(x: 5, y: innerY , width: Int(view.bounds.width - 60) , height: 30))
            
            let desc = TTTAttributedLabel(frame:CGRect(x: 5, y: innerY , width: Int(view.bounds.width - 60) , height: 40))
            desc.textAlignment = .left
            desc.textColor = textColorDark
            desc.text = ""
            desc.delegate = self
            
            desc.linkAttributes = [kCTForegroundColorAttributeName as AnyHashable : linkColor.cgColor,kCTUnderlineStyleAttributeName as AnyHashable : NSNumber(value: true)]
            desc.enabledTextCheckingTypes = NSTextCheckingResult.CheckingType.link.rawValue
            //  createLabel(CGRect(x: 5, y: innerY , width: Int(view.bounds.width - 60) , height: 30), text: "", alignment: .left, textColor: textColorDark)
            
            desc.font = UIFont(name: fontNormal, size: FONTSIZEMedium)
            desc.numberOfLines = 0
            desc.lineBreakMode = NSLineBreakMode.byWordWrapping
            if Formbackup["change_description"] != nil && Formbackup["change_description"] as? String != "" {
                desc.setText(Formbackup["change_description"] as? String, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                    return mutableAttributedString!
                })
                
                
            }
            
            desc.sizeToFit()
            
            sellView.addSubview(desc)
            
            innerY = innerY + Int(desc.bounds.height) + 10
            filePathArray.removeAll(keepingCapacity: false)
            filePathArray = saveFileInDocumentDirectory(allSellPhotos)
            //print("Filepath")
            //print(filePathArray)
            for i in 0 ..< allSellPhotos.count
            {
                sellImageView = UIImageView(frame : CGRect(x: 0, y: innerY, width: Int(view.bounds.width) - 10 , height: 250))
                sellImageView.image = allSellPhotos[i]
                sellImageView.tag = i
                sellImageView.isUserInteractionEnabled = true
                innerY += 255
                self.sellView.addSubview(sellImageView)
                
                let cross =  createButton(CGRect(x: 15, y: 10, width: 30, height: 30), title: "", border: false,bgColor: false, textColor: textColorPrime)
                cross.setImage(UIImage(named: "cross_icon")?.maskWithColor(color: buttonColor), for: UIControl.State())
                cross.tag = i
                cross.addTarget(self, action: #selector(AdvancePostFeedViewController.cancelSellImage(_:)), for: .touchUpInside)
                sellImageView.addSubview(cross)
                
            }
            
            ProductTitle = createLabel(CGRect(x: 5, y: innerY, width: Int(view.bounds.width - 10) , height: 30), text: "", alignment: .left, textColor: textColorDark)
            ProductTitle.font = UIFont(name: fontBold, size: FONTSIZEMedium)
            sellView.addSubview(ProductTitle)
            ProductTitle.lineBreakMode = .byTruncatingTail
            
            ProductTitle.text = Formbackup["title"] as? String
            innerY = innerY + Int(ProductTitle.bounds.height)
            
            ProductPrice = createLabel(CGRect(x: 5, y: innerY, width: Int(view.bounds.width - 60) , height: 30), text: "", alignment: .left, textColor: UIColor(red: 34/255.0, green: 139/255.0, blue: 34/255.0, alpha: 1.0))
            sellView.addSubview(ProductPrice)
            ProductPrice.font = UIFont(name: "fontAwesome", size: FONTSIZEMedium)
            if Formbackup["price"] != nil && Formbackup["price"] as! String != "" {
                let currency = Formbackup["currency"] as? String
                //let sign = getCurrencySymbol(currency!)
                if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
                    let defaults = UserDefaults.standard
                    if let name = defaults.object(forKey: "Currency")
                    {
                        let price = Double(Formbackup["price"] as! String)!
                        let changePrice = (defaults.object(forKey: "PriceRate") as! Float) * Float(price)
                        let showPrice = (String(format:"%.2f", changePrice))
                        
                        ProductPrice.text  =  "\(getCurrencySymbol(name as! String)) \(showPrice)"
                        
                    }
                }
                else{
                ProductPrice.text = "\(dollarIcon) \(currency!) \(Formbackup["price"] as! String)"
                }
            }
            innerY = innerY + Int(ProductPrice.bounds.height)
            
            ProductLoc = createLabel(CGRect(x: 5, y: innerY, width: Int(view.bounds.width - 60) , height: 30), text: "", alignment: .left, textColor: textColorDark)
            sellView.addSubview(ProductLoc)
            ProductLoc.font = UIFont(name: "fontAwesome", size: FONTSIZEMedium)
            if Formbackup["location"] != nil && Formbackup["location"] as! String != "" {
                let icon = "\u{f041}"
                ProductLoc.text = "\(icon) \(Formbackup["location"] as! String)"
            }
            innerY = innerY + Int(ProductLoc.bounds.height)
            
            sellView.frame.size.height = CGFloat(innerY) + 10
            
            sellView.layer.cornerRadius = cornerRadius
            sellView.layer.masksToBounds = false
            sellView.layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight);
            sellView.layer.shadowOpacity = shadowOpacity
            self.scrollView.contentSize.height =  self.feedTextView.bounds.height + self.feedTextView.frame.origin.y + CGFloat(innerY) - 5
            self.scrollView.sizeToFit()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeBottomSheet"), object: nil, userInfo: ["postType" : "sellingForm"])
            
            
        }
        else{
            if bannerAllow == 1 {
                tabsContainerMenu.isHidden = false
                extraMenuLeft.isHidden = false
            }
            sellAttachmentMode = false
            postButton.isEnabled = false
        }
    }
    
    @objc func crossSellViewButton(_ Sender : UIButton){
        //print("cross")
        Formbackup.removeAllObjects()
        sellView.removeFromSuperview()
        allSellPhotos.removeAll()
        tabsContainerMenu.isHidden = false
        extraMenuLeft.isHidden = false
        feedTextView.isUserInteractionEnabled = true
        sellAttachmentMode = false
        postButton.isEnabled = false
        bottomSheetVC.view.frame.origin.y = bottomSheetVC.partialView
        bottomSheetVC.PostFeedListObj.isHidden = true
        bottomSheetVC.postView.isHidden = false
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeBottomSheet"), object: nil, userInfo: ["postType" : "all"])
    }
    
    @objc func editSellViewButton(_ Sender : UIButton){
        
        let presentedVC = TargetScheduledPostViewController()
        presentedVC.contentType = "Sell"
        let nativationController = UINavigationController(rootViewController: presentedVC)
        nativationController.modalPresentationStyle = .fullScreen
        self.present(nativationController, animated:false, completion: nil)
    }
    
    @objc func cancelSellImage (_ Sender : UIButton){
        Formbackup.removeObject(forKey: "photo")
        sellImageView.removeFromSuperview()
        ProductTitle.frame.origin.y = ProductTitle.frame.origin.y - 250
        ProductPrice.frame.origin.y = ProductPrice.frame.origin.y - 250
        ProductLoc.frame.origin.y = ProductLoc.frame.origin.y - 250
        sellView.frame.size.height = ProductLoc.frame.origin.y + ProductLoc.bounds.height
        
        bottomSheetVC.view.frame.origin.y = bottomSheetVC.partialView
        bottomSheetVC.PostFeedListObj.isHidden = true
        bottomSheetVC.postView.isHidden = false
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeBottomSheet"), object: nil, userInfo: ["postType" : "all"])
        
        //sellingView(SellForm: Formbackup)
        
        //print("cross Image")
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        
        let notificationCenter = NotificationCenter.default
        if isEditFeed == false {
            if sellUpdate == true {
                sellUpdate = false
                feedTextView.text = ""
                
                sellingView(SellForm: Formbackup)
            }
        }
        bannerImageView.frame.origin.y = self.feedTextView.frame.origin.y + 10
        
        if TargetDictionary.count > 0 {
            TargetButton.setTitleColor(navColor, for: .normal)
            TargetButton.layer.borderColor = navColor.cgColor
        }
        if ScheduleDisctionary.count > 0{
            ScheduleButton.setTitleColor(navColor, for: .normal)
            ScheduleButton.layer.borderColor = navColor.cgColor
        }
        
        feedTextView.isUserInteractionEnabled = true
        notificationCenter.addObserver(self,selector: #selector(AdvancePostFeedViewController.keyboardWillBeHidden(_:)),name: UIResponder.keyboardWillHideNotification,object: nil)
        notificationCenter.addObserver(self, selector: #selector(AdvancePostFeedViewController.keyboardWillShow(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        if self.userId == currentUserId || self.userId == 0 {
            self.title = NSLocalizedString("Update Status", comment: "")
        }
        self.feedTextView.frame.size.width = view.bounds.width - 20
        
        
        if isEditFeed == true {
            if editFeedDict["privacy_icon"] != nil {
                if  let privacy = editFeedDict["privacy_icon"] as? String{
                    
                    auth_View = privacy
                }
            }
            else{
                if  let privacy = editFeedDict["privacy"] as? String{
                    
                    auth_View = privacy
                }
            }
        }
        else{
            if let privacy = UserDefaults.standard.string(forKey: "privacy")
            {
                auth_View = privacy
            }
            else
            {
                auth_View = "everyone"
            }
        }
        
        
        
        if isEditFeed == true {
            auth_View = ""
            arrayPrivacy.removeAll()
            if editFeedDict["privacy_icon"] != nil {
                if  let privacy = editFeedDict["privacy_icon"] as? String{
                    
                    auth_View = privacy
                }
            }
            else{
                if  let privacy = editFeedDict["privacy"] as? String{
                    
                    auth_View = privacy
                }
            }
            
            if setEditPrivacy != "" {
                auth_View = setEditPrivacy
            }
            arrayPrivacy.append(auth_View)
        }
        else{
            if let privacy = UserDefaults.standard.string(forKey: "privacy"){
                auth_View = privacy
            }
        }
        
        if arrayPrivacy.count == 0 {
            if let privacy = UserDefaults.standard.string(forKey: "privacy"){
                arrayPrivacy.append(privacy)
            }
        }
        
        updateButtonText()
        videoAttachFromAAF = ""
        if feedTextView.text == "" {
            
            self.feedTextView.textColor = postTextColor//textColorDark
            self.feedTextView.text = NSLocalizedString("What's on your mind?",comment: "")
        }
        
        if openfeedStyle == 3{
            postButton.isEnabled = true
        }
        
        if isEditFeed == true{
            if  let body_param1 = editFeedDict["params"] as? NSDictionary{
                
                if let menuItem = body_param1["feed-banner"] as? NSDictionary {
                    
                    
                    
                    var textEditColor = menuItem["color"] as! String
                    let _ = textEditColor.remove(at: (textEditColor.startIndex))
                    
                    var check1 = menuItem["background-color"] as! String
                    let _ = check1.remove(at: (check1.startIndex))
                    bannerImageView.backgroundColor = UIColor(hex: "\(check1)")
                    
                    if let url1 = menuItem["feed_banner_url"] as? String
                    {
                        let url1 = URL(string: url1)
                        bannerImageView.kf.indicatorType = .activity
                        (bannerImageView.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                        bannerImageView.kf.setImage(with: url1 as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                            
                        })
                        bannerImageView.isHidden = false
                        scrollView.addSubview(bannerImageView)
                        scrollView.addSubview(buttonTextView)
                        
                        buttonTextView.textColor = UIColor(hex: "\(textEditColor)")
                        
                        
                    }
                    if (menuItem["feed_banner_url"] as? String) != nil {
                        buttonTextView.frame.origin.y = feedTextView.frame.origin.y + 10
                        buttonTextView.isHidden = false
                        resign()
                        buttonTextView.becomeFirstResponder()
                        buttonTextView.setNeedsLayout()
                        buttonTextView.textAlignment = NSTextAlignment.center
                        feedTextView.isHidden = true
                        buttonTextView.tag = 501
                        
                        buttonTextView.delegate = self
                        buttonTextView.text = ""
                        buttonTextView.text = editBody
                        backupTextView.text = editBody
                    }
                    else{
                        buttonTextView.isHidden = true
                        feedTextView.isHidden = false
                        feedTextView.text = editBody
                        backupTextView.text = ""
                    }
                    
                }
                else
                {
                    buttonTextView.isHidden = true
                    feedTextView.isHidden = false
                    feedTextView.text = editBody
                    backupTextView.text = ""
                }
            }
            else{
                buttonTextView.isHidden = true
                feedTextView.isHidden = false
                feedTextView.text = editBody
                backupTextView.text = ""
            }
            
        }
        
        
        if frndTag.count > 0  && addfrndTag == true{
            bannerImageView.frame.origin.y = self.feedTextView.frame.origin.y + 25
            for (key, _) in frndTag{
                for ob in view.subviews {
                    if ob.tag == key{
                        ob.removeFromSuperview()
                    }
                }
            }
            var tempString = ""
            if frndTag.count == 1 {
                for (_, value) in frndTag{
                    tempString += "\(value)"
                }
            }else if frndTag.count == 2{
                
                var i = 0
                
                for (_, value) in frndTag{
                    if i == 0{
                        tempString += "\(value)"
                    }else{
                        tempString += " and \(value)"
                    }
                    i += 1
                }
                
            }else if frndTag.count > 2{
                let tempCount = frndTag.count - 1
                var i = 0
                for (_, value) in frndTag{
                    if i == 0{
                        tempString += "\(value) and \(tempCount) other"
                    }
                    i += 1
                    
                }
            }
            
            taggedFriendsString = tempString
            
        }else{
            taggedFriendsString = ""
        }
        
        if locationTag.count > 0{
            for (_, value) in locationTag{
                let location = value["label"] as! String
                locationInfoString = location
            }
            postButton.isEnabled = true
        }else{
            locationInfoString = ""
        }
        updateUserText()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        activityIndicatorView.stopAnimating()
        self.title = ""
        setEditPrivacy = ""
        frndTagValue.removeAll()
        feedTextView.resignFirstResponder()
        buttonTextView.resignFirstResponder()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "changeSheetHeight"), object: nil)
        
    }
    
    // MARK: ELCImagePickerControllerDelegate Methods
    
    func elcImagePickerControllerDidCancel(_ picker: ELCImagePickerController!) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func elcImagePickerController(_ picker: ELCImagePickerController!, didFinishPickingMediaWithInfo info: [Any]!) {
        
        dismiss(animated: true, completion: nil)
        allPhotos.removeAll(keepingCapacity: false)
        self.photoAttachmentMode = true
        tabsContainerMenu.isHidden = true
        extraMenuLeft.isHidden = true
        self.postButton.isEnabled = true
        
        let manager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.resizeMode = PHImageRequestOptionsResizeMode.exact
        requestOptions.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
        requestOptions.isSynchronous = true
        for dic in info
        {
            if let photoDic = dic as? PHAsset
            {
                if photoDic.mediaType == PHAssetMediaType.image
                {
                    manager.requestImage(for: photoDic , targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.aspectFit, options: requestOptions, resultHandler: { (pickedImage, info) in
                        if pickedImage != nil {
                        self.allPhotos.append(pickedImage!) // you can get image like this way
                        }
                    })
                }
            }
        }
        
        for dic in info{
            if let photoDic = dic as? NSDictionary{
                if photoDic.object(forKey: UIImagePickerController.InfoKey.mediaType) as! String == ALAssetTypePhoto {
                    if (photoDic.object(forKey: UIImagePickerController.InfoKey.originalImage) != nil){
                        let image = photoDic.object(forKey: UIImagePickerController.InfoKey.originalImage) as! UIImage
                        if (image.imageOrientation == UIImage.Orientation.right || image.imageOrientation == UIImage.Orientation.left || image.imageOrientation == UIImage.Orientation.down )
                        {
                            let imgageNormalize = fixOrientation(img: image)
                            allPhotos.append(imgageNormalize)
                        }
                        else{
                            allPhotos.append(image)
                        }
                        
                        
                    }
                }
                else if photoDic.object(forKey: UIImagePickerController.InfoKey.mediaType) as! String == ALAssetTypeVideo {
                    if (photoDic.object(forKey: UIImagePickerController.InfoKey.originalImage) != nil)
                    {
                        let image = photoDic.object(forKey: UIImagePickerController.InfoKey.originalImage) as! UIImage
                        allPhotos.append(image)
                    }
                }
            }
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeBottomSheet"), object: nil, userInfo: ["postType" : "photo"])
        attachmentMode = true
        adjustPhoto()
    }
    
    func updateButtonText(){
        // Update Privacy Button Frame and Size
        if let privacyDictionary = postPermission["userprivacy"] as? NSDictionary{
            var iconString = "\(notificationDefaultIcon)"
            if auth_View == "onlyme"{
                iconString = "\u{f023}"
            }else if auth_View == "networks"{
                iconString = "\(groupIcon)"
            }else if auth_View == "friends"{
                iconString = "\u{f007}"
            }else if auth_View == "network_list_custom"{
                iconString = "\(groupIcon)"
            }else if auth_View == "friend_list_custom"{
                iconString = "\(listingDefaultIcon)"
            }
            else{
                iconString = "\(notificationDefaultIcon)"
            }
            var privacyStringContent = ""
            //            if auth_View ==  "Multiple Networks" || auth_View == "Multiple Friend Lists"{
            //                privacyStringContent = auth_View
            //            }
            //            else{
            if auth_View != nil && auth_View != ""{
                if let auth = privacyDictionary[auth_View] as? String
                {
                  privacyStringContent = auth
                }
                else
                {
                    privacyStringContent = "Everyone"
                }
            }
            else{
                privacyStringContent = "Everyone"
            }
            //         }
            
            let iconFont = CTFontCreateWithName(("fontAwesome" as CFString?)!, FONTSIZENormal, nil)
            let textFont = CTFontCreateWithName((fontName as CFString?)!, FONTSIZENormal, nil)
            let iconPart = NSMutableAttributedString(string: "\(iconString)", attributes: [NSAttributedString.Key.font:iconFont ,  NSAttributedString.Key.foregroundColor : textColorDark])
            
            let textPart = NSMutableAttributedString(string: "  \(privacyStringContent)", attributes: [NSAttributedString.Key.font:textFont , NSAttributedString.Key.foregroundColor : textColorDark])
            iconPart.append(textPart)
            
            self.privacyButton.setAttributedTitle(iconPart, for: .normal)
            
            //  let completeString = "\(iconString)  \(privacyStringContent)"
            
            //  self.privacyButton.setTitle(completeString, for: UIControl.State())
            var fontSize: CGFloat = 15
            let bounds = UIScreen.main.bounds
            let height = bounds.size.height
            switch height
            {
            case 568.0:
                // spalshName = "Splash-640x960"
                fontSize = 10
                
                
            default:
                
                fontSize = 15
                
            }
            
            if let font =  UIFont(name: fontName, size: fontSize)
            {
                let fontAttributes = [NSAttributedString.Key.font: font]
                var myText = ""
                if auth_View != nil && auth_View != "" {
                    if let auth = privacyDictionary[auth_View] as? String
                    {
                        myText = auth
                    }
                    else
                    {
                        myText = "Everyone"
                    }
                    myText += "increase \(notificationDefaultIcon)"
                }
                else{
                    myText = "Everyone"
                    myText += "increase \(notificationDefaultIcon)"
                }
                let size = (myText as NSString).size(withAttributes: fontAttributes)
                self.privacyButton.frame.size = size
                self.privacyButton.frame.size.height = 25
                self.privacyButton.sizeToFit()
                self.privacyButton.frame.size.width =  self.privacyButton.frame.size.width + 10
                btnCheckin.frame = CGRect(x:getRightEdgeX(inputView: privacyButton)+10, y:privacyButton.frame.origin.y, width:100,height:20)
                self.TargetButton.frame.origin.x = self.privacyButton.frame.origin.x + self.privacyButton.frame.size.width + 10
                self.ScheduleButton.frame.origin.x = self.TargetButton.frame.origin.x + self.TargetButton.frame.size.width + 10
                
            }
            
        }
        
    }
    
    func adjustPhoto()
    {
        for ob in self.scrollView.subviews{
            if let imageView = ob as? UIImageView {
                if imageView.tag != 9999{
                    imageView.removeFromSuperview()
                }
            }
        }
        self.feedTextView.sizeToFit()
        var originY:CGFloat = self.feedTextView.bounds.height + self.feedTextView.frame.origin.y + 50
        
        feedTextView.frame.size.width = view.bounds.width-20
        //   //print(allPhotos.count)
        for i in 0 ..< allPhotos.count
        {
            imageView = AAFMultipleImageViewWithGradient(frame: CGRect(x: 0, y: originY, width: view.bounds.width, height: 300))
            //            imageView.image = cropToBounds(allPhotos[i], width: Double(view.bounds.width - 10), height: 300)
            // let resizeimage = imageWithImage1(allPhotos[i], newHeight: 300, newwidth: view.bounds.width - 10)
            imageView.image = allPhotos[i]
            imageView.contentMode = .scaleAspectFill
            imageView.layer.masksToBounds = true
            imageView.clipsToBounds = true
            imageView.tag = i
            imageView.isUserInteractionEnabled = true
            originY += 305
            self.scrollView.addSubview(imageView)
            
            let cross =  createButton(CGRect(x: view.bounds.width - 70, y: 10, width: 50, height: 50), title: "", border: false,bgColor: false, textColor: textColorLight)
            cross.setImage(UIImage(named: "cross_icon"), for: UIControl.State())
            cross.tag = i
            cross.addTarget(self, action: #selector(AdvancePostFeedViewController.cancel(_:)), for: .touchUpInside)
            cross.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            imageView.addSubview(cross)
            
        }
        let tempImageCountHeight : CGFloat = CGFloat((allPhotos.count * 305) + 60)
        self.scrollView.contentSize.height =  self.feedTextView.bounds.height + self.feedTextView.frame.origin.y + tempImageCountHeight - 5
        self.scrollView.sizeToFit()
    }
    
    @objc func cancel(_ sender:UIButton)
    {
        
        bottomSheetVC.view.frame.origin.y = bottomSheetVC.partialView
        bottomSheetVC.PostFeedListObj.isHidden = true
        bottomSheetVC.postView.isHidden = false
        
        DispatchQueue.main.async {
            
            self.allPhotos.remove(at: sender.tag)
            //print(self.allPhotos)
            self.tabsContainerMenu.isHidden = false
            self.extraMenuLeft.isHidden = false
            if self.imageView.tag == sender.tag {
                self.imageView.image = nil
                self.imageView.removeFromSuperview()
            }
            
            if self.allPhotos.count > 0 {
                self.adjustPhoto()
            }else{
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeBottomSheet"), object: nil, userInfo: ["postType" : "all"])
                self.photoAttachmentMode = false
                for ob in self.scrollView.subviews{
                    if let imageView = ob as? UIImageView {
                        if imageView.tag != 9999{
                            imageView.removeFromSuperview()
                        }
                    }
                }
            }
            
        }
        
    }
    
    func openGallery() {
        DispatchQueue.main.async{
        let imagePicker = ELCImagePickerController(imagePicker: ())
        imagePicker?.maximumImagesCount = 10
        imagePicker?.returnsOriginalImage = true
        imagePicker?.returnsImage = true
        imagePicker?.onOrder = true
        imagePicker?.modalPresentationStyle = .fullScreen
        imagePicker?.imagePickerDelegate = self
        let photoAuthorization = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorization
        {
        case .authorized:
            DispatchQueue.main.async{
            self.present(imagePicker!, animated: false, completion: nil)
            }
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ (newStatus) in
                if newStatus == PHAuthorizationStatus.authorized
                {
                     DispatchQueue.main.async{
                    self.present(imagePicker!, animated: false, completion: nil)
                    }
                }
            })
            print("It is not determined until now")
        case .denied, .restricted:
            photoPermission(controller: self)
            print("User has denied the permission.")
        }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        arrowView.isHidden = true
        scrollViewEmoji.isHidden = true
        scrollviewEmojiLikeView.isHidden = true
        let scrollOffset = scrollView.contentOffset.y
        if (scrollOffset > 60.0){
            // update the new position acquired
            self.lastContentOffset = scrollView.contentOffset.y
        }
    }
    
    func attachLink(){
        let alert = UIAlertController(title: NSLocalizedString("Attach Link",comment: ""), message: NSLocalizedString("Enter url:",comment: ""), preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Done",comment: ""), style: UIAlertAction.Style.default, handler: forgotPasswordHandler))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel",comment: ""), style: UIAlertAction.Style.default, handler: nil))
        alert.addTextField(configurationHandler: {(textField: UITextField) in
            textField.placeholder = NSLocalizedString("Enter Url",comment: "")
            textField.isSecureTextEntry = false
            self.linkField = textField
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    func forgotPasswordHandler(_ alertView: UIAlertAction!)
    {
        var error = ""
        
        if linkField.text!.range(of: "http://") != nil || linkField.text!.range(of: "https://") != nil{
            self.linkUrl = "\(self.linkField.text!)"
        }else{
            let tempUrl = "http://\(self.linkField.text!)"
            self.linkUrl = tempUrl
        }
        
        if self.linkField.text!  == "" {
            error = NSLocalizedString("Please enter url.",comment: "")
        }
        
        if error != ""{
            let alertController = UIAlertController(title: "Error", message:
                error, preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }else{
            
            
            if bannerImageView.image != nil || bannerImageView.tag == 100{
            }
            else
            {
                
                //self.getLinkBottomSheetOptions()
                getAttachmentData()
            }
        }
    }
    func getAttachmentData(){
        if Reachabable.isConnectedToNetwork() {
            var path = ""
            var parameters = [String:String]()
            path = "advancedactivity/feeds/attach-link"
            parameters = ["uri": linkUrl]
            //            spinner.center = view.center
            //            spinner.hidesWhenStopped = true
            //            spinner.style = UIstyle.gray
            //            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            attachvideofromDevice = false
            activityIndicatorView.startAnimating()
            view.isUserInteractionEnabled = false
            activityPost(parameters as Dictionary<String, AnyObject>, url: path, method: "POST") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeBottomSheet"), object: nil, userInfo: ["postType" : "link"])
                    if let response = succeeded["body"] as? NSDictionary{
                        self.linkContent = response
                        if let video_id = response["video_id"] as? Int{
                            self.videoId = String(video_id)
                            self.videoAttachmentMode = true
                        }
                        if let temp_title = response["title"] as? String{
                            self.titleGetAttachement = temp_title
                        }
                        if let temp_description = response["description"] as? String{
                            self.descriptionGetAttachement = temp_description
                        }
                        
                        // If attachment is video than single image will come otherwise array of image
                        if self.videoId != nil {
                            if let image = response["image"] as? String{
                                self.imageStringGetAttachement = image
                            }
                        }else{
                            if let imagearr = response["images"] as? NSArray{
                                if imagearr.count > 0{
                                    self.imageStringGetAttachement = imagearr[0] as! String
                                }
                            }
                        }
                        
                        if let tempImageString = response["thumb"] as? String{
                            self.imageStringGetAttachement = tempImageString
                        }
                        if (self.titleGetAttachement != "" || self.descriptionGetAttachement != ""){
                            self.view.alpha = 1
                            self.linkAttachmentMode = true
                            self.view.isUserInteractionEnabled = false
                            self.tabsContainerMenu.isHidden = true
                            self.extraMenuLeft.isHidden = true
                            self.showAttachedLink(6,image:self.imageStringGetAttachement,title:self.titleGetAttachement,description:self.descriptionGetAttachement)
                        }else{
                            self.titleGetAttachement = ""
                            self.descriptionGetAttachement = ""
                            self.imageStringGetAttachement = ""
                            self.view.alpha = 1
                            self.linkUrl = ""
                            self.linkAttachmentMode = false
                            self.tabsContainerMenu.isHidden = false
                            self.extraMenuLeft.isHidden = false
                            self.view.isUserInteractionEnabled = true
                            showToast(message: "Webpage not available.", controller: self)
                            //print("error")
                        }
                    }
                    
                })
            }
        }
        
    }
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        //UIApplication.shared.openURL(url!)
        let presentedVC = ExternalWebViewController()
        presentedVC.url = url.absoluteString
        let navigationController = UINavigationController(rootViewController: presentedVC)
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true, completion: nil)
        
    }
    
    //For Attachment only
    func showAttachedLink(_ option:Int,image:String,title:String,description:String){
        if photoView != nil{
            photoView.removeFromSuperview()
        }
        self.feedTextView.sizeToFit()
        
        let photoViewOriginY:CGFloat = self.feedTextView.bounds.height + self.feedTextView.frame.origin.y + 30
        feedTextView.frame.size.width = view.bounds.width-20
        var photoViewerFrame:CGRect?
        
        let infoTitle = NSLocalizedString("", comment: "")
        switch (option)
        {
        case 5:
            photoViewerFrame = CGRect(x: 2, y: photoViewOriginY - 25, width: view.bounds.width-4, height: 200)
        //infoTitle += NSLocalizedString("Video", comment: "")
        case 6:
            photoViewerFrame = CGRect(x: 2, y: photoViewOriginY + 25, width: view.bounds.width-4, height: 125)
        //infoTitle += NSLocalizedString("Link", comment: "")
        default:
            print("Error in Post Selection")
        }
        
        
        photoView = createView(photoViewerFrame!, borderColor: borderColorMedium  , shadow: false)
        self.scrollView.addSubview(photoView)
        let infoLabel = createLabel(CGRect( x: 5, y: 10, width: photoView.bounds.width - 10, height: 30),text: NSLocalizedString("\(infoTitle)",  comment: ""), alignment: .center, textColor: textColorDark)
        
        infoLabel.font = UIFont(name: fontBold, size: FONTSIZENormal)
        infoLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        infoLabel.sizeToFit()
        photoView.addSubview(infoLabel)
        
        let cancle = createButton(CGRect(x: photoView.bounds.width-20, y: 2,width: 20, height: 30), title: "\(cancelFriendIcon)", border: false,bgColor: false, textColor: textColorDark)
        cancle.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
        cancle.tag = option
        cancle.addTarget(self, action: #selector(AdvancePostFeedViewController.cancleSelection(_:)), for: .touchUpInside)
        photoView.addSubview(cancle)
        
        view.isUserInteractionEnabled = true
        if option == 5
        {
            
            var coverimageView = ContentImageViewWithGradient(frame: CGRect(x: 10, y: 30, width: (photoViewerFrame?.width)! - 20, height: 160))
            let coverImageUrl = URL(string: image)
            if coverImageUrl != nil{
                coverimageView.kf.indicatorType = .activity
                (coverimageView.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                coverimageView.kf.setImage(with: coverImageUrl as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                    
                })
                
            }
            photoView.addSubview(coverimageView)
            let titleLabel = createLabel(CGRect(x: 5, y: 130, width: (photoViewerFrame?.width)! - 30, height: 20) , text: "\(title)", alignment: .left, textColor: textColorLight)
            titleLabel.text = "\(title)"
            titleLabel.font = UIFont(name: fontBold, size: FONTSIZENormal)
            imageView.contentMode = .scaleAspectFill
            imageView.addSubview(titleLabel)
            
        }
        else if option == 6
        {
            
            linkAttachmentMode = true
            postButton.isEnabled = true
            let linkView = createView(CGRect(x: 10, y: 30, width: (photoViewerFrame?.width)! - 20, height: 70), borderColor: borderColorMedium  , shadow: false)
            photoView.addSubview(linkView)
            
            var coverimageView = createImageView(CGRect(x: 5, y: 10, width: 50, height: 50), border: true)
            linkView.addSubview(coverimageView)
            let coverImageUrl = URL(string: image)
            
            if coverImageUrl != nil{
                coverimageView.kf.indicatorType = .activity
                (coverimageView.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                coverimageView.kf.setImage(with: coverImageUrl as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                    
                })
                
            }
            let titleLabel = createLabel(CGRect(x: 60,y: 10 , width: (photoViewerFrame?.width)! - 80, height: 15), text: "\(title)", alignment: .left, textColor: textColorDark)
            titleLabel.font = UIFont(name: fontBold, size: FONTSIZENormal)
            titleLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
            linkView.addSubview(titleLabel)
            
            let descriptionLabel = createLabel(CGRect(x: 60,y: 20 , width: (photoViewerFrame?.width)! - 80, height: 50), text: "\(description)", alignment: .left, textColor: textColorDark)
            descriptionLabel.font = UIFont(name: fontName, size: FONTSIZEMedium)
            descriptionLabel.numberOfLines = 2
            linkView.addSubview(descriptionLabel)
        }
        feedTextView.resignFirstResponder()
    }
    // For Video only
    func showAttachedLink1(_ option:Int,image:UIImage?,title:String,description:String){
        if photoView != nil{
            photoView.removeFromSuperview()
        }
        self.feedTextView.sizeToFit()
        view.isUserInteractionEnabled = true
        
        let photoViewOriginY:CGFloat = self.feedTextView.bounds.height + self.feedTextView.frame.origin.y + 30
        feedTextView.frame.size.width = view.bounds.width-20
        var photoViewerFrame:CGRect?
        
        var infoTitle = NSLocalizedString("", comment: "")
        photoViewerFrame = CGRect(x: 0, y: photoViewOriginY + 25, width: view.bounds.width, height: 300)
        infoTitle += NSLocalizedString("", comment: "")
        
        photoView = createView(photoViewerFrame!, borderColor: borderColorMedium  , shadow: false)
        photoView.layer.borderWidth = 0.0
        self.scrollView.addSubview(photoView)
        
        
        let infoLabel = createLabel(CGRect(x: 5, y: 10, width: photoView.bounds.width - 10, height: 30),text: NSLocalizedString("\(infoTitle)",  comment: ""), alignment: .center, textColor: textColorDark)
        infoLabel.font = UIFont(name: fontBold, size: FONTSIZENormal)
        infoLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        infoLabel.sizeToFit()
        photoView.addSubview(infoLabel)
        
        let coverimageView = ContentImageViewWithGradient(frame: CGRect(x: 0, y: 0, width: (photoViewerFrame?.width)!, height: 300))
        coverimageView.backgroundColor = UIColor.red
        if let thumbImage = image{
            coverimageView.image = thumbImage
            coverimageView.image = cropToBounds(thumbImage, width: Double((photoViewerFrame?.width)!), height: 300)
            coverimageView.clipsToBounds = true
        }
        photoView.addSubview(coverimageView)
        let cross =  createButton(CGRect(x: view.bounds.width - 70, y: 10, width: 50, height: 50), title: "", border: false,bgColor: false, textColor: textColorLight)
        cross.setImage(UIImage(named: "cross_icon"), for: UIControl.State())
        //cross.tag = i
        cross.addTarget(self, action: #selector(AdvancePostFeedViewController.cancleSelection(_:)), for: .touchUpInside)
        cross.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        photoView.addSubview(cross)
        feedTextView.resignFirstResponder()
        //        let titleLabel = createLabel(CGRect(x: 5, y: 130, width: (photoViewerFrame?.width)! - 30, height: 20) , text: "\(title)", alignment: .left, textColor: textColorLight)
        //        titleLabel.text = "\(title)"
        //        titleLabel.font = UIFont(name: fontBold, size: FONTSIZENormal)
        //        imageView.addSubview(titleLabel)
        
    }
    func verifyUrl (_ urlString: String?) -> Bool {
        //Check for nil
        if let urlString = urlString {
            // create NSURL instance
            if let url = URL(string: urlString) {
                // check if your application can open the NSURL instance
                return UIApplication.shared.canOpenURL(url)
            }
        }
        return false
    }
    
    @objc func cancleSelection(_ sender:UIButton){
        linkUrl = ""
        videoUrl = ""
        linkAttachmentMode = false
        videoAttachmentMode = false
        photoAttachmentMode = false
        tabsContainerMenu.isHidden = false
        extraMenuLeft.isHidden = false
        attachmentMode = false
        bottomSheetVC.view.isUserInteractionEnabled = true
        bottomSheetVC.view.alpha = 1.0
        bottomSheetVC.view.frame.origin.y = bottomSheetVC.partialView
        bottomSheetVC.PostFeedListObj.isHidden = true
        bottomSheetVC.postView.isHidden = false
        if (self.feedTextView.text == ""){
            self.postButton.isEnabled = false
        }
        allPhotos.removeAll(keepingCapacity: false)
        photoView.removeFromSuperview()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeBottomSheet"), object: nil, userInfo: ["postType" : "all"])
        
    }
    
    @objc func postFeed(){
        if Reachabable.isConnectedToNetwork()
        {
        removeAlert()
        postFeedDelegate?.didPostFeed()
        if attachvideofromDevice == true{
            // Create video calling
            createVideo(image: thumbImage)
            
            return
        }
        // Share Content Validaion
        feedTextView.resignFirstResponder()
        buttonTextView.resignFirstResponder()
        feedTextView.text = feedTextView.text.trimString(feedTextView.text)
        
        if isEditFeed == false {
            if openfeedStyle != 3
            {
                if openfeedStyle == 4 || buttonTextView.text != ""{
                    //print("Page Check In ")
                }
                else{
                    if self.videoAttachmentMode != true
                    {
                        
                        if ((photoAttachmentMode == false && linkAttachmentMode == false && locationTag.count == 0 && sellAttachmentMode == false) &&  ( feedTextView.text == "" || feedTextView.text.length == 0)){
                            self.view.makeToast("Please enter status.", duration: 5, position: CSToastPositionCenter)
                            feedTextView.becomeFirstResponder()
                            return
                        }
                        
                    }
                }
            }
         }
        if openfeedStyle == 3{
            if feedTextView.text.length == 0{
                feedTextView.becomeFirstResponder()
            }
        }
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            self.postButton.isEnabled = false
            view.isUserInteractionEnabled = true
            
            var bodyStatus = feedTextView.text as String
            
            
            if bannerImageView.image != nil || bannerImageView.tag == 100{
                if buttonTextView.text != "" {
                    bodyStatus = buttonTextView.text as String
                }
            }
            if feedTextView.text != NSLocalizedString("What's on your mind?",  comment: "") {
                if feedTextView.text.length > buttonTextView.text.length{
                    bodyStatus = feedTextView.text as String
                }
            }
            if bodyStatus != "" {
                
                bodyStatus = Emoticonizer.emoticonizeString(bodyStatus as NSString) as String
            }
            if !(isEditFeed) {
                if feedTextView.text == NSLocalizedString("What's on your mind?",  comment: "") {
                    bodyStatus = ""
                }
            }
            
            if sellAttachmentMode == true
            {
                bodyStatus = ""
            }
            
            var parameters = [String:AnyObject]()
            
            var checkKey = ""
            var checkBoxValue = ""
            
            for a in arrayPrivacy{
                
                checkKey = a
                
                if checkBoxValue  != "" {
                    checkBoxValue = "\(checkBoxValue),\(checkKey)"
                }
                else{
                    checkBoxValue = "\(checkKey)"
                }
            }
            
            parameters = ["body": "\(bodyStatus)" as AnyObject,"auth_view": "\(checkBoxValue)" as AnyObject]
            
            parameters.update(TargetDictionary)
            parameters.update(ScheduleDisctionary)
            
            if frndTag.count > 0 && addfrndTag == true{
                var tagString = ""
                for (key, _) in frndTag{
                    tagString += (String(key) + ",")
                }
                //tagString = tagString.substring(to: tagString.index(tagString.startIndex, offsetBy: tagString.length-1))
                tagString = String(tagString[..<tagString.index(tagString.startIndex, offsetBy: tagString.length-1)])
                parameters["toValues"] = tagString as AnyObject?
                
            }
            
            if locationTag.count > 0{
                let dic = (locationTag["location"])!
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: dic, options:  [])
                    let  finalString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
                    
                    
                    var tempDic = [String:AnyObject]()
                    tempDic.updateValue(finalString as AnyObject, forKey: "checkin")
                    var templocationString = "{\"checkin\":"
                    var locationString = templocationString + finalString + "}"
                    var modify = templocationString + finalString
                    
                    if (bannerImageView.image != nil || bannerImageView.tag == 100){
                        templocationString = "\"checkin\":"
                        locationString = templocationString + finalString + "}"
                        modify = templocationString + finalString + "}"
                    }
                    Modify_composer2 = modify
                    parameters["composer"] = locationString as AnyObject?
                    parameters["locationLibrary"] = "client" as AnyObject?
                    // success ...
                } catch _ {
                    // failure
                    //print("Fetch failed: \(error.localizedDescription)")
                }
            }
            if allPhotos.count>0{
                imagePost = true
                filePathArray.removeAll(keepingCapacity: false)
                filePathArray = saveFileInDocumentDirectory(allPhotos)
                
            }
            else if allSellPhotos.count > 0 {
                imagePost = true
                filePathArray.removeAll(keepingCapacity: false)
                filePathArray = saveFileInDocumentDirectory(allSellPhotos)
            }
            else
            {
                imagePost = false
            }
            if linkAttachmentMode == true && (linkUrl != nil && linkUrl != "")
            {
                parameters["post_attach"] = "1" as AnyObject?
                parameters["uri"] = linkUrl as AnyObject?
                parameters["type"] = "link" as AnyObject?
                
            }
            
            if photoAttachmentMode == true
            {
                parameters["post_attach"] = "1" as AnyObject?
                parameters["type"] = "photo" as AnyObject?
                
            }
            if sellAttachmentMode == true
            {
                //parameters["post_attach"] = "1" as AnyObject?
                parameters["type"] = "sell" as AnyObject?
                Formbackup.removeObject(forKey: "photo")
                
                if Formbackup["change_description"] != nil && Formbackup["change_description"] as? String != "" {
                    Formbackup["description"] = Formbackup["change_description"] as! String
                    Formbackup.removeObject(forKey: "change_description")
                }
                
                parameters.update(Formbackup as! Dictionary<String, AnyObject>)
                
            }
            
            if videoAttachmentMode == true && (videoId != nil && videoId != "")
            {
                parameters["video_id"] = videoId as AnyObject?
                parameters["type"] = "video" as AnyObject?
                parameters["post_attach"] = "1" as AnyObject?
            }
            
            if subject_unique_id != nil && subject_unique_type != nil
            {
                parameters["subject_id"] = String(subject_unique_id) as AnyObject?
                parameters["subject_type"] = subject_unique_type as AnyObject?
            }
            var path = ""
            if isEditFeed == true {
                path = "advancedactivity/edit-feed"
                feedUpdate = true
                parameters["action_id"] = String(editId) as AnyObject
                parameters["body"] = "\(bodyStatus)" as AnyObject
                // parameters = ["action_id":String(editId) as AnyObject,"body": "\(bodyStatus)" as AnyObject]
            }
            else{
                path = "advancedactivity/feeds/post"
            }
            channelUpdate = true
            channelProfileUpdate = true
            // For Checkin only
            if openfeedStyle == 4
            {
                storeDetailUpdate = true
                contentFeedUpdate = true
                pageDetailUpdate = true
                videoProfileUpdate = true
                updateFromAlbum = true
                listingDetailUpdate = true
                musicUpdate = true
                classifiedDetailUpdate = true
                pollDetailUpdate = true
                blogDetailUpdate = true
                channelProfileUpdate = true
                path = "sitetagcheckin/content-checkin"
                if selectedDate != ""
                {
                    let arrdate = selectedDate.components(separatedBy: "/")
                    parameters["day"] = arrdate[1] as AnyObject?
                    parameters["month"] = arrdate[0] as AnyObject?
                    parameters["year"] = arrdate[2] as AnyObject?
                }
                else
                {
                    let date = Date()
                    let dateFormatter: DateFormatter = DateFormatter()
                    // Set date format
                    dateFormatter.dateFormat = "MM/dd/yyyy"
                    selectedDate = dateFormatter.string(from: date)
                    let arrdate = selectedDate.components(separatedBy: "/")
                    parameters["day"] = arrdate[1] as AnyObject?
                    parameters["month"] = arrdate[0] as AnyObject?
                    parameters["year"] = arrdate[2] as AnyObject?
                }
                parameters["subject_id"] = String(subjectId) as AnyObject?
                parameters["subject_type"] = subjectType as AnyObject?
                
                
            }
            if self.postButton.isEnabled
            {
                //print("error")
            }
            
            // Send Server Request to Share Content
            if imagePost == true
            {
                
                var sinPhoto = true
                if allPhotos.count>1
                {
                    sinPhoto = false
                }
                if isAAFPost
                {
                    if isViewWillAppearCall != 7
                    {
                        isViewWillAppearCall = 4
                        
                    }
                    if sellAttachmentMode
                    {
                        delegateQuickContent?.postSellSomethingQuickPosting(parameters: parameters, path: path, type : 1)
                    }
                    else
                    {
                        delegateQuickContent?.postImageQuickPosting(parameters: parameters, path: path, singlePhoto: sinPhoto)
                    }
                    returnBack()
                }
                else
                {                    
                    postActivityForm(parameters, url: path, filePath: filePathArray, filePathKey: "photo", SinglePhoto: sinPhoto){ (succeeded, msg) -> () in
                        DispatchQueue.main.async(execute: {
                            activityIndicatorView.stopAnimating()
                            self.view.alpha = 1.0
                            self.postButton.isEnabled = true
                            self.view.isUserInteractionEnabled = true
                            if msg{
                                for path in filePathArray{
                                    removeFileFromDocumentDirectoryAtPath(path)
                                }
                                Formbackup.removeAllObjects()
                                ScheduleDisctionary.removeAll()
                                TargetDictionary.removeAll()
                                filePathArray.removeAll(keepingCapacity: false)
                                if self.isEditFeed == true {
                                    
                                    showToast(message: "Content Edited Successfully.", controller: self, onView: false, time: 3)
                                }
                                else{
                                    showToast(message: NSLocalizedString("Posted Successfully.",  comment: ""), controller: self, onView: false, time: 3)
                                    
                                }
                                //self.createTimer(self)
                                
                                
                                advGroupDetailUpdate = true
                                self.popAfterDelay = true
                                self.returnBack()
                            }else{
                                // Handle Server Side Error
                                if succeeded["message"] != nil{
                                    self.view.alpha = 1.0
                                    self.postButton.isEnabled = true
                                    self.view.isUserInteractionEnabled = true
                                    showToast(message: succeeded["message"] as! String, controller: self)
                                }
                            }
                        })
                        
                    }
                }

            }
            else
            {
                if frndTagValue.count > 0 && frndTagValue.count > 1 && Modify_composer2 == ""{
                    if bannerImageView.image != nil || bannerImageView.tag == 100{
                        _ = "\(bannerComposer) ,\(Modify_composer1!)"
                        parameters.update(CheckParameters as Dictionary<String, AnyObject>)
                        
                    }
                    else{
                        parameters.update(CheckParameters as Dictionary<String, AnyObject>)
                    }

                    activityPostTag(parameters, url: path, method: "POST") { (succeeded, msg) -> () in
                        DispatchQueue.main.async(execute: {
                            activityIndicatorView.stopAnimating()
                            if msg{
                                if self.isEditFeed == true {
                                    
                                    showToast(message: "Content Edited Successfully.", controller: self, onView: false, time: 3)
                                }
                                else{
                                    showToast(message: NSLocalizedString("Posted Successfully.",  comment: ""), controller: self, onView: false, time: 3)
                                    
                                }
                                advGroupDetailUpdate = true
                                ScheduleDisctionary.removeAll()
                                TargetDictionary.removeAll()
                                //createTimer(self)
                                
                                self.popAfterDelay = true
                                self.returnBack()
                                
                            }
                            else
                            {
                                // Handle Server Side Error
                                if succeeded["message"] != nil{
                                    self.view.alpha = 1.0
                                    self.postButton.isEnabled = true
                                    self.view.isUserInteractionEnabled = true
                                    showToast(message: succeeded["message"] as! String, controller: self)
                                }
                            }
                        })
                    }
                }
                else
                {
                    //For @tag with checkin
                    if tagwithcheckin != 0  && Modify_composer2 != "" {
                        if bannerImageView.image != nil || bannerImageView.tag == 100{
                            let Modify_composer3 = "\(Modify_composer2) ,\(Modify_composer1!) , \(bannerComposer)"
                            parameters.update(CheckParameters as Dictionary<String, AnyObject>)
                            parameters["composer"] = Modify_composer3 as AnyObject
                        }
                        else{
                            let Modify_composer3 = "\(Modify_composer2) ,\(Modify_composer1!)"
                            parameters.update(CheckParameters as Dictionary<String, AnyObject>)
                            parameters["composer"] = Modify_composer3 as AnyObject
                        }
                        activityPostTag(parameters, url: path, method: "POST") { (succeeded, msg) -> () in
                            DispatchQueue.main.async(execute: {
                                activityIndicatorView.stopAnimating()
                                if msg{
                                    
                                    if self.isEditFeed == true {
                                        
                                        showToast(message: "Content Edited Successfully.", controller: self, onView: false, time: 3)
                                    }
                                    else{
                                        showToast(message: NSLocalizedString("Posted Successfully.",  comment: ""), controller: self, onView: false, time: 3)
                                        
                                    }
                                    advGroupDetailUpdate = true
                                    ScheduleDisctionary.removeAll()
                                    TargetDictionary.removeAll()
                                    //self.createTimer(self)
                                    
                                    self.popAfterDelay = true
                                    self.returnBack()
                                    
                                }
                                else
                                {
                                    // Handle Server Side Error
                                    if succeeded["message"] != nil{
                                        self.view.alpha = 1.0
                                        self.postButton.isEnabled = true
                                        self.view.isUserInteractionEnabled = true
                                        showToast(message: succeeded["message"] as! String, controller: self)
                                    }
                                }
                            })
                        }
                    }
                    else
                    {
                        if tagwithcheckin == 0  && Modify_composer2 != "" && (bannerImageView.image != nil || bannerImageView.tag == 100){
                            
                            let Modify_composer3 = "\(bannerComposer) , \(Modify_composer2)"
                            print(Modify_composer3)
                            parameters.update(CheckParameters as Dictionary<String, AnyObject>)
                            parameters["composer"] = Modify_composer3 as AnyObject
                            
                        }
                            
                        else if tagwithcheckin != 0  && (bannerImageView.image != nil || bannerImageView.tag == 100){
                            let Modify_composer3 = "\(bannerComposer) ,\(Modify_composer1!)"
                            parameters.update(CheckParameters as Dictionary<String, AnyObject>)
                            parameters["composer"] = Modify_composer3 as AnyObject
                            
                        }
                        else{
                            parameters.update(CheckParameters as Dictionary<String, AnyObject>)
                        }
                        if isAAFPost
                        {
                            if isViewWillAppearCall != 7
                            {
                                isViewWillAppearCall = 4
                            }
                            if sellAttachmentMode
                            {
                                delegateQuickContent?.postSellSomethingQuickPosting(parameters: parameters, path: path, type : 2)
                            }
                            else
                            {
                                let linkDic = ["title" : self.titleGetAttachement, "description" : self.descriptionGetAttachement, "image" : self.imageStringGetAttachement]
                                delegateQuickContent?.postTextWithImageQuickPosting(parameters: parameters, path: path, passTempDic : linkDic)
                            }
                            returnBack()
                        }
                        else
                        {
                            
                            let dic = self.linkContent
                            do {
                                let jsonData = try JSONSerialization.data(withJSONObject: dic, options:  [])
                                let  finalString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
                                parameters["linkInfo"] = finalString as AnyObject?
                                
                                // success ...
                            } catch _ {
                                // failure
                                //print("Fetch failed: \(error.localizedDescription)")
                            }
                            
                            parameters.removeValue(forKey: "body")
                            postFromBody(parameters, paramUrl:"\(bodyStatus)",keyName:"body",url: path, method: "POST", postCompleted: { (succeeded, msg) -> () in
                                DispatchQueue.main.async(execute: {
                                    activityIndicatorView.stopAnimating()
                                    if msg{
                                        
                                        if self.isEditFeed == true {
                                            
                                            showToast(message: "Content Edited Successfully.", controller: self, onView: false, time: 3)
                                        }
                                        else{
                                            showToast(message: NSLocalizedString("Posted Successfully.",  comment: ""), controller: self, onView: false, time: 3)
                                            
                                        }
                                        advGroupDetailUpdate = true
                                        ScheduleDisctionary.removeAll()
                                        TargetDictionary.removeAll()
                                        //self.createTimer(self)
                                        
                                        self.popAfterDelay = true
                                        self.returnBack()
                                        
                                    }
                                    else
                                    {
                                        // Handle Server Side Error
                                        if succeeded["message"] != nil{
                                            self.view.alpha = 1.0
                                            self.postButton.isEnabled = true
                                            self.view.isUserInteractionEnabled = true
                                            showToast(message: succeeded["message"] as! String, controller: self)
                                        }
                                    }
                                })
                            })
                        }
                    }
                }
            }
//            feedTextView.text = nil
        }
        else
        {
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self)
        }
        }
        else
        {
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self)
        }
        
    }
    
    func openCamera(){
        DispatchQueue.main.async{
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
        {
            let image = UIImagePickerController()
            image.delegate = self
            image.sourceType = UIImagePickerController.SourceType.camera
            if UIDevice.current.userInterfaceIdiom != .pad{
                image.allowsEditing = false
            }
            DispatchQueue.main.async{
            self.present(image, animated: true, completion: nil)
            }
        }
        }
    }
    
    func openVideoCamera(){
        DispatchQueue.main.async{
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
        {
            let image = UIImagePickerController()
            image.delegate = self
            image.sourceType = UIImagePickerController.SourceType.camera
            image.mediaTypes = [kUTTypeMovie as String]
            if UIDevice.current.userInterfaceIdiom != .pad{
                image.allowsEditing = true
            }
            DispatchQueue.main.async{
            self.present(image, animated: true, completion: nil)
            }
        }
        }
    }
    func openVideoGallary()
    {
        DispatchQueue.main.async{
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.mediaTypes = [String(kUTTypeMovie)]
        imagePicker.allowsEditing = false
        imagePicker.modalPresentationStyle = .fullScreen
        if #available(iOS 11.0, *) {
            imagePicker.videoExportPreset = AVAssetExportPresetPassthrough
        }
            DispatchQueue.main.async{
        self.present(imagePicker, animated: false, completion: nil)
            }
    }
    }
    // MARK:  UIImagePickerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        
        allPhotos.removeAll(keepingCapacity: false)
        if "public.image" != info[UIImagePickerController.InfoKey.mediaType] as? String
        {
            let  videoUrl : NSURL = info[UIImagePickerController.InfoKey.mediaURL] as! NSURL
            let str : String = videoUrl.absoluteString!
            //print("videourl: ", videoUrl)
            //trying compression of video
            if str.contains("mp4") || str.contains("mov") || str.contains("MOV") || str.contains("MP4"){
                messageShow = false
            }
            else{
                messageShow = true
            }
            let data = NSData(contentsOf: videoUrl as URL)!
            //print("File size before compression: \(Double(data.length / 1048576)) mb")
            if let videoSize = UserDefaults.standard.object(forKey: "videoSize") as? String, let v = Double(videoSize), v < Double(data.length / 1048576)
            {
                
                self.dismiss(animated: true, completion:
                    {
                        
                        let alertController = UIAlertController(title: "\(NSLocalizedString("Maximum allowed size for Media is", comment: "")) \(videoSize)\(NSLocalizedString("MB. Please try uploading a smaller size file.", comment: ""))", message: nil, preferredStyle: UIAlertController.Style.alert)
                        
                        alertController.addAction(UIAlertAction(title: NSLocalizedString("Ok",  comment: ""), style: .default, handler:nil))
                        self.present(alertController, animated:true, completion: nil)
                })
                
            }
            else
            {
                self.videoAttachmentMode = true
                self.attachmentMode = true
                attachvideofromDevice = true
                postButton.isEnabled = true
                tabsContainerMenu.isHidden = true
                extraMenuLeft.isHidden = true
                self.dismiss(animated: true, completion: nil)
                filePathArray.removeAll(keepingCapacity: false)
                mediaType = "video"
                let imageArray = info[UIImagePickerController.InfoKey.mediaURL]
                //   filePathArray.removeAll(keepingCapacity: false)
                
                // get the asset
                let asset = AVURLAsset(url: imageArray as! URL)
                // get the time in seconds
                videoDurationInSeconds = asset.duration.seconds
                var arryVideo = [AnyObject]()
                
                thumbImage = getThumbnailFrom(path: videoUrl as URL)
                //  arryVideo.append(thumbImage as AnyObject)
                if thumbImage != nil
                {
                    let imgageNormalize = fixOrientation(img: thumbImage!)
                    orientedImage = imgageNormalize
                    arryVideo.append(imageArray as AnyObject)
                    arryVideo.append(orientedImage as AnyObject)
                    filePathArray = saveFileInDocumentDirectory(arryVideo)
                    self.showAttachedLink1(5, image: imgageNormalize, title: "", description: "")
                    bottomSheetVC.view.isUserInteractionEnabled = true
                    bottomSheetVC.view.alpha = 1.0
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeBottomSheet"), object: nil, userInfo: ["postType" : "video"])
                }
            }
        }
        else
        {
            //let  image = (info[UIImagePickerControllerEditedImage] as? UIImage)!
            let cameraImage = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage)!
            let image = fixOrientation(img: cameraImage)
            self.dismiss(animated: true, completion: nil)
            postButton.isEnabled = true
            photoAttachmentMode = true
            attachmentMode = true
            tabsContainerMenu.isHidden = true
            extraMenuLeft.isHidden = true
            adjustCameraPhoto(image)
            allPhotos.append((image))
            let imageArray = [image as UIImage]
            filePathArray.removeAll(keepingCapacity: false)
            filePathArray = saveFileInDocumentDirectory(imageArray)
        }
        
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker .dismiss(animated: true, completion: nil)
    }
    
    // Create video calling
    func createVideo(image : UIImage?){
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.center = self.view.center
        //activityIndicatorView.startAnimating()
        self.postButton.isEnabled = false
        view.isUserInteractionEnabled = false
        var bodyStatus = feedTextView.text as String
        if feedTextView.text == NSLocalizedString("What's on your mind?",comment: ""){
            bodyStatus = ""
        }
        if bodyStatus != "" {
            
            bodyStatus = Emoticonizer.emoticonizeString(bodyStatus as NSString) as String
        }
        
        var parameters = [String:AnyObject]()
        parameters = ["body": "\(bodyStatus)" as AnyObject,"auth_view": auth_View as AnyObject,"type" : "3" as AnyObject , "post_attach" : "1" as AnyObject ,"subject_type": likeCommentContentType as AnyObject, "subject_id": "\(likeCommentContent_id!)" as AnyObject]
        
        if frndTag.count > 0 && addfrndTag == true{
            var tagString = ""
            for (key, _) in frndTag{
                tagString += (String(key) + ",")
            }
            //tagString = tagString.substring(to: tagString.index(tagString.startIndex, offsetBy: tagString.length-1))
            tagString = String(tagString[..<tagString.index(tagString.startIndex, offsetBy: tagString.length-1)])
            parameters["toValues"] = tagString as AnyObject?
            
        }
        
        if locationTag.count > 0{
            let dic = (locationTag["location"])!
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: dic, options:  [])
                let  finalString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
                
                
                var tempDic = [String:AnyObject]()
                tempDic.updateValue(finalString as AnyObject, forKey: "checkin")
                var templocationString = "{\"checkin\":"
                var locationString = templocationString + finalString + "}"
                var modify = templocationString + finalString
                
                if (bannerImageView.image != nil || bannerImageView.tag == 100){
                    templocationString = "\"checkin\":"
                    locationString = templocationString + finalString + "}"
                    modify = templocationString + finalString + "}"
                }
                Modify_composer2 = modify
                parameters["composer"] = locationString as AnyObject?
                parameters["locationLibrary"] = "client" as AnyObject?
                // success ...
            } catch _ {
                // failure
                //print("Fetch failed: \(error.localizedDescription)")
            }
        }
        
        
        var path = ""
        if enabledModules.contains("sitevideo"){
            path = "advancedvideos/create"
        }
        else{
            path = "videos/create"
        }
        if isAAFPost
        {
            if isViewWillAppearCall != 7
            {
                isViewWillAppearCall = 4
            }
            delegateQuickContent?.postVideoQuickPosting(parameters: parameters, path: path)
            returnBack()
        }
        else
        {
            activityIndicatorView.startAnimating()
            postActivityForm(parameters as Dictionary<String, AnyObject>, url: path, filePath: filePathArray, filePathKey: "filedata", SinglePhoto: true){ (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    self.bottomSheetVC.view.isUserInteractionEnabled = true
                    self.bottomSheetVC.view.alpha = 1.0
                    self.view.alpha = 1.0
                    self.postButton.isEnabled = true
                    self.view.isUserInteractionEnabled = true
                    self.feedTextView.resignFirstResponder()
                    self.linkTextField.resignFirstResponder()
                    if msg{
                        for path in filePathArray{
                            removeFileFromDocumentDirectoryAtPath(path)
                        }
                        self.attachvideofromDevice = false
                        filePathArray.removeAll(keepingCapacity: false)
                        
                        self.videoAttachmentMode = true
                        self.attachmentMode = true
                        if self.messageShow == true {
                            
                            showToast(message:  NSLocalizedString("Your video is in queue to be processed - you will be notified when it is ready to be viewed.", comment: ""), controller: self, onView: false, time: 5)
                        }
                        
                        
                        advGroupDetailUpdate = true
                        //self.createTimer(self)
                        self.popAfterDelay = true
                        self.returnBack()
                        
                    }else{
                        // Handle Server Side Error
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                    }
                })
                
            }
        }
}
    
    func adjustCameraPhoto(_ image: UIImage!){
        
        for ob in self.scrollView.subviews{
            if let imageView = ob as? UIImageView {
                if imageView.tag != 9999{
                    imageView.removeFromSuperview()
                }
            }
        }
        
        self.feedTextView.sizeToFit()
        let originY:CGFloat = self.feedTextView.bounds.height + self.feedTextView.frame.origin.y + 50
        self.feedTextView.frame.size.width = view.bounds.width - 20
        
        sampleImage = AAFMultipleImageViewWithGradient(frame: CGRect(x: 0, y: originY, width: view.bounds.width, height: 300))
        sampleImage.isUserInteractionEnabled = true
        
        //        sampleImage.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleBottomMargin, .flexibleRightMargin, .flexibleLeftMargin, .flexibleTopMargin]
        sampleImage.contentMode = .scaleAspectFill // OR .scaleAspectFill
        sampleImage.layer.masksToBounds = true
        sampleImage.clipsToBounds = true
        sampleImage.image = image
        self.scrollView.addSubview(sampleImage)
        
        
        
        let cross =  createButton(CGRect(x: view.bounds.width - 70, y: 10, width: 50, height: 50), title: "", border: false,bgColor: false, textColor: textColorLight)
        cross.setImage(UIImage(named: "cross_icon"), for: UIControl.State())
        cross.addTarget(self, action: #selector(AdvancePostFeedViewController.cancelCameraImage), for: .touchUpInside)
        cross.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        sampleImage.addSubview(cross)
        
        let tempImageCountHeight : CGFloat = CGFloat((1 * 305) + 60)
        self.scrollView.contentSize.height =  self.feedTextView.bounds.height + self.feedTextView.frame.origin.y + tempImageCountHeight - 5
        self.scrollView.sizeToFit()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeBottomSheet"), object: nil, userInfo: ["postType" : "photo"])
        
        
        
    }
    
    @objc func cancelCameraImage(){
        
        bottomSheetVC.view.frame.origin.y = bottomSheetVC.partialView
        bottomSheetVC.PostFeedListObj.isHidden = true
        bottomSheetVC.postView.isHidden = false
        
        linkUrl = ""
        videoUrl = ""
        tabsContainerMenu.isHidden = false
        extraMenuLeft.isHidden = false
        linkAttachmentMode = false
        videoAttachmentMode = false
        photoAttachmentMode = false
        attachmentMode = false
        sampleImage.image = nil
        sampleImage.removeFromSuperview()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeBottomSheet"), object: nil, userInfo: ["postType" : "all"])
        
    }
    
    
    //Open video picker while clicking video option
    func openVideoPicker(){
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        alertController.addAction(UIAlertAction(title:  NSLocalizedString("Upload Video",comment: ""), style: UIAlertAction.Style.default) { action -> Void in
            self.openVideoGallary()
        })
        
        alertController.addAction(UIAlertAction(title:  NSLocalizedString("Shoot Video",comment: ""), style: .default) { action -> Void in
            
            if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == AVAuthorizationStatus.notDetermined {
                
                AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (videoGranted: Bool) -> Void in
                    //print("You have not determined====")
                    // User clicked ok
                    if (videoGranted) {
                        //print("open camera======")
                        self.openVideoCamera()
                        // User clicked don't allow
                    } else {
                        //print("Check not allow")
                        alertController.dismiss(animated: false, completion: nil)
                    }
                })
            }
            if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == AVAuthorizationStatus.authorized {
                //print("You have not denied====")
                self.openVideoCamera()
            }
            if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == AVAuthorizationStatus.denied {
                let alert = UIAlertController(title: "Access Denied", message: "This app does not have access to your camera. You can enable access in privacy settings.", preferredStyle: UIAlertController.Style.alert)
                
                // add an action (button)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                
                // show the alert
                self.present(alert, animated: true, completion: nil)
                //print("You have denied")
            }
            if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == AVAuthorizationStatus.restricted {
                //print("You have not restricted====")
            }
            
        })
        if  (UIDevice.current.userInterfaceIdiom == .phone){
            alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .cancel, handler:nil))
        }
        else
        {
            // Present Alert as! Popover for iPad
            alertController.modalPresentationStyle = UIModalPresentationStyle.popover
            let popover = alertController.popoverPresentationController
            popover?.sourceView = self.view
            popover?.sourceRect = CGRect(x: view.bounds.width/2, y: view.bounds.height/2 , width: 1, height: 1)
            popover?.permittedArrowDirections = UIPopoverArrowDirection()
        }
      self.present(alertController, animated:true, completion: nil)
    }
    // For displaing stickers
    func openStickers(){
        let vc = StickerViewController()
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @objc func hideAction(_ sender:UIButton)
    {
        let myString = feedTextView.text
        let myStringWithoutLastWord = myString?.components(separatedBy: " ").dropLast().joined(separator: " ")
        feedTextView.text = myStringWithoutLastWord
        //feedTextView.text.append(" " + selectedString)
        feedTextView.becomeFirstResponder()
        self.EventSelectionView.isHidden = true
    }
    
    func videoOptionList(_ sender:UIButton)
    {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.mediaTypes = [String(kUTTypeMovie)]
        imagePicker.allowsEditing = false
        // imagePicker.showsCameraControls = false
        imagePicker.modalPresentationStyle = .custom
        self.present(imagePicker, animated: true, completion: nil)
        //print("Select video====")
        
        
    }
    
    func attachFileAction(_ sender:UIButton){
        linkTextField.resignFirstResponder()
        attachVideo()
    }
    
    func attachVideo()
    {
        
        if linkTextField.text!.range(of: "http://") != nil || linkTextField.text!.range(of: "https://") != nil{
            self.videoUrl = "\(self.linkTextField.text!)"
        }else{
            let tempUrl = "http://\(self.linkTextField.text!)"
            self.videoUrl = tempUrl
        }
        
        if Reachabable.isConnectedToNetwork() {
            var path = ""
            if enabledModules.contains("sitevideo")
            {
                addvideo_click = 1
                videoredirection = false
                path = "advancedvideos/create"
            }
            else
            {
                path = "videos/create"
            }
            var parameters = [String:String]()
            parameters = ["post_attach":"1","type":"\(videoAttachmentKey)","url":"\(videoUrl!)","subject_type": likeCommentContentType, "subject_id": "\(likeCommentContent_id)"]
            //            spinner.center = view.center
            //            spinner.hidesWhenStopped = true
            //            spinner.style = UIstyle.gray
            //            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            view.isUserInteractionEnabled = false
            post(parameters, url: path, method: "POST") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg
                    {
                        if let response = succeeded["body"] as? NSDictionary
                        {
                            if let result = response["response"] as? NSDictionary{
                                var title = ""
                                var video_id = ""
                                var imageString = ""
                                
                                if let temp_title = result["title"] as? String{
                                    title = temp_title
                                }
                                if let temp_description = result["video_id"] as? Int{
                                    video_id = String(temp_description)
                                }
                                
                                if let tempImageString = result["image"] as? String{
                                    imageString = tempImageString
                                }
                                if ((title != "" || video_id != "") && (imageString != ""))
                                {
                                    self.videoAttachmentMode = true
                                    self.attachmentMode = true
                                    self.videoId = video_id
                                    self.showAttachedLink(5,image:imageString,title:title,description:video_id)
                                    self.postButton.isEnabled = true
                                }
                                else
                                {
                                    self.videoId = ""
                                    self.videoAttachmentMode = false
                                    self.view.isUserInteractionEnabled = true
                                    showToast(message: "Video Not Available", controller: self)
                                    //print("error")
                                }
                                
                            }
                            
                        }
                    }else{
                        activityIndicatorView.stopAnimating()
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        self.view.isUserInteractionEnabled = true
                    }
                    
                })
            }
        }
    }
    
    // Stop Timer
    @objc func stopTimer() {
        stop()
        // popViewController After Delay
        if popAfterDelay == true {
            feedUpdate = true
            afterPost = true
            contentFeedUpdate = true
            listingDetailUpdate = true
            pageDetailUpdate = true
            Formbackup.removeAllObjects()
            locationTag.removeAll(keepingCapacity: false)
            self.dismiss(animated: true, completion: nil)
            
        }
    }
    
    func returnBack(){
        // if popAfterDelay == true {
        feedUpdate = true
        afterPost = true
        contentFeedUpdate = true
        listingDetailUpdate = true
        pageDetailUpdate = true
        Formbackup.removeAllObjects()
        locationTag.removeAll(keepingCapacity: false)
        self.dismiss(animated: true, completion: nil)
        
        // }
    }
    
    @objc func goBack(){
        postFeedDelegate?.didCancelPost()
        locationTag.removeAll(keepingCapacity: false)
        videoAttachFromAAF = ""
        
        if isEditFeed == true{
            isViewWillAppearCall = 4
            self.dismiss(animated: true, completion: nil)
        }
        else{
            
            if feedTextView.text != "" {
                
                if  (UIDevice.current.userInterfaceIdiom == .phone){
                    
                    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
                    
                    
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("Discard Post",  comment: ""), style: UIAlertAction.Style.destructive, handler:{ (UIAlertAction) -> Void in
                        Formbackup.removeAllObjects()
                        self.dismiss(animated: true, completion: nil)
                        
                    }))
                    
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("Keep Posting",  comment: ""), style: .default, handler:nil))
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel",  comment: ""), style: .cancel, handler:nil))
                    self.present(alertController, animated:true, completion: nil)
                }
                else{
                    let alertController = UIAlertController(title: "Discard", message:
                        "If you cancel, your post will be discarded. ", preferredStyle: UIAlertController.Style.alert)
                    
                    alertController.addAction(UIAlertAction(title: "Discard Post", style: UIAlertAction.Style.destructive ,handler: { (action) in
                        
                        Formbackup.removeAllObjects()
                        self.dismiss(animated: true, completion: nil)
                        
                    }))
                    
                    alertController.addAction(UIAlertAction(title: "Keep", style: UIAlertAction.Style.default,handler: nil))
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }else{
                Formbackup.removeAllObjects()
                self.dismiss(animated: true, completion: nil)
                
            }
            
        }
    }
    
    @objc func showProfile()
    {
        isViewWillAppearCall = 7
        let presentedVC = ContentActivityFeedViewController()
        presentedVC.subjectType = "user"
        presentedVC.subjectId = "\(currentUserId)"
        presentedVC.fromActivity = false
        searchDic.removeAll(keepingCapacity: false)
        self.navigationController?.pushViewController(presentedVC, animated: true)
        
    }
    
    func cancelPost(){
        self.dismiss(animated: false, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        let myString = feedTextView.text
        
        let myStringWithoutLastWord = myString?.components(separatedBy: " ").dropLast().joined(separator: " ")
        feedTextView.text = myStringWithoutLastWord
        
        self.view.endEditing(true)
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseOut, animations: {
            self.EventSelectionView.frame =  CGRect(x:10, y:-200, width:self.view.bounds.width-40, height:200)
            self.EventSelectionView.isHidden = false
        }, completion: { finished in
            
        })
        
        return true
    }
    
    @objc func cancelevent()
    {
        btnCheckin.setTitle(NSLocalizedString("",  comment: ""), for: .normal)
        btnCheckin.isHidden = true
        
    }
    @objc func becomeFirstResponderTextView()
    {
        feedTextView.becomeFirstResponder()
    }
    
    func GetchekinPostOption()
    {
        
        if Reachabable.isConnectedToNetwork()
        {
            let path = "sitetagcheckin/content-checkin"
            var parameters = [String:String]()
            
            parameters = ["subject_id":String(subjectId),"subject_type":subjectType]
            //            spinner.center = view.center
            //            spinner.hidesWhenStopped = true
            //            spinner.style = UIstyle.gray
            //            view.addSubview(spinner)
            //
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            view.isUserInteractionEnabled = false
            post(parameters, url: path, method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    if msg
                    {
                        if let response = succeeded["body"] as? NSDictionary
                        {
                            
                            self.postPermissionForcheckin = response["feed_post_menu"] as! NSDictionary
                            
                            if self.postPermissionForcheckin.count>0
                            {
                                var postOptions = [Int:String]()
                                var sequence = [Int]()
                                var postOptionsName = [Int:String]()
                                if let addTag = self.postPermissionForcheckin["withtags"] as? Bool
                                {
                                    if addTag
                                    {
                                        postOptions[0] = friendReuestIcon
                                        sequence.append(0)
                                        postOptionsName[0] = NSLocalizedString("Tag people",  comment: "")
                                    }
                                }
                                
                                // Will be release in Version 1.4
                                
                                if let checkIn = self.postPermissionForcheckin["checkin"] as? Bool
                                {
                                    if checkIn
                                    {
                                        postOptions[1] = "\u{f041}"
                                        sequence.append(1)
                                        postOptionsName[1] = NSLocalizedString("Check in",  comment: "")
                                    }
                                }
                                
                                if let image = self.postPermissionForcheckin["photo"] as? Bool
                                {
                                    if image
                                    {
                                        postOptions[2] = "\u{f030}"
                                        sequence.append(2)
                                        postOptionsName[2] = NSLocalizedString("Photos",  comment: "")
                                    }
                                }
                                if let video = self.postPermissionForcheckin["video"] as? Bool
                                {
                                    if video
                                    {
                                        postOptions[5] = "\u{f03d}"
                                        sequence.append(5)
                                        postOptionsName[5] = NSLocalizedString("Videos",  comment: "")
                                    }
                                }
                                if let link = self.postPermissionForcheckin["link"] as? Bool
                                {
                                    if link
                                    {
                                        postOptions[6] = "\u{f0c1}"
                                        sequence.append(6)
                                        postOptionsName[6] = NSLocalizedString("Links",  comment: "")
                                    }
                                }
                                if let date = self.postPermissionForcheckin["date"] as? Bool
                                {
                                    if date
                                    {
                                        postOptions[9] = eventIcon
                                        sequence.append(9)
                                        postOptionsName[9] = NSLocalizedString("Date",  comment: "")
                                    }
                                }
                                if postOptionsName.count > 0 && self.isEditFeed == false {
                                    self.addBottomSheetView(postOptions : postOptions, sequence : sequence, postOptionsName : postOptionsName)
                                }
                            }
                            
                            
                        }
                    }
                    else
                    {
                        activityIndicatorView.stopAnimating()
                        
                        if succeeded["message"] != nil
                        {
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        
                    }
                    
                })
            }
        }
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        //        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
        //            switch swipeGesture.direction {
        //            case UISwipeGestureRecognizer.Direction.right:
        //                //print("Swiped right")
        //            case UISwipeGestureRecognizer.Direction.down:
        //                //print("Swiped down")
        //                self.view.endEditing(false)
        //            case UISwipeGestureRecognizer.Direction.left:
        //                //print("Swiped left")
        //            case UISwipeGestureRecognizer.Direction.up:
        //                //print("Swiped up")
        //            default:
        //                break
        //            }
        //        }
    }
    
}

protocol PostFeedDelegate: class {
    func didPostFeed()
    func didCancelPost()
}






