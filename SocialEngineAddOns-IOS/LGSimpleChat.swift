//
//  SimpleChatController.swift
//  SimpleChat
//
//  Created by Logan Wright on 10/16/14.
//  Copyright (c) 2014 Logan Wright. All rights reserved.
//
/*
 Mozilla Public License
 Version 2.0
 https://tldrlegal.com/license/mozilla-public-license-2.0-(mpl-2)
 */

import UIKit
import Photos

// MARK: Message
var transparentView :UIView!
var transparentView1 :UIView!
var imageCacheShow = [String:UIImage]()
var attachmentMessageFlag = false
var scrollingToBottom : Bool = true

class LGChatMessage : NSObject {
    
    enum SentBy : String {
        case User = "LGChatMessageSentByUser"
        case Opponent = "LGChatMessageSentByOpponent"
    }
    
    // MARK: ObjC Compatibility
    
    /*
     ObjC can't interact w/ enums properly, so this is used for converting compatible values.
     */
    
    class func SentByUserString() -> String {
        return LGChatMessage.SentBy.User.rawValue
    }
    
    class func SentByOpponentString() -> String {
        return LGChatMessage.SentBy.Opponent.rawValue
    }
    
    var sentByString: String {
        get {
            return sentBy.rawValue
        }
        set {
            if let sentBy = SentBy(rawValue: newValue) {
                self.sentBy = sentBy
            } else {
                //print("LGChatMessage.Error : Property Set : Incompatible string set to SentByString!")
            }
        }
    }
    
    // MARK: Public Properties
    
    var sentBy: SentBy
    var content: String
    var timeStamp: TimeInterval?
    var date: String
    var imageUrl : String
    var userId : Int
    var attachment : NSDictionary
    
    required init (content: String, sentBy: SentBy, timeStamp: TimeInterval? = nil, date: String, imageUrl: String,userId :Int,attachment: NSDictionary){
        self.sentBy = sentBy
        self.timeStamp = timeStamp
        self.content = content
        self.date = date
        self.imageUrl = imageUrl
        self.userId = userId
        self.attachment = attachment
    }
    
    // MARK: ObjC Compatibility
    
    convenience init (content: String, sentByString: String, date:String, imageUrl: String,userId: Int,attachment: NSDictionary) {
        if let sentBy = SentBy(rawValue: sentByString) {
            self.init(content: content, sentBy: sentBy, timeStamp: nil, date:date, imageUrl: imageUrl,userId:userId,attachment:attachment)
        } else {
            fatalError("LGChatMessage.FatalError : Initialization : Incompatible string set to SentByString!")
        }
    }
    
    convenience init (content: String, sentByString: String, timeStamp: TimeInterval, date:String, imageUrl: String,userId: Int,attachment:NSDictionary) {
        if let sentBy = SentBy(rawValue: sentByString) {
            self.init(content: content, sentBy: sentBy, timeStamp: timeStamp, date: date, imageUrl: imageUrl,userId:userId,attachment:attachment)
        } else {
            fatalError("LGChatMessage.FatalError : Initialization : Incompatible string set to SentByString!")
        }
    }
}

// MARK: Message Cell
class LGChatMessageCell : UITableViewCell {
    
    // MARK: Global MessageCell Appearance Modifier
    var popAfterDelay:Bool = false
    struct Appearance {
        static var opponentColor = UIColor(red: 0.142954, green: 0.60323, blue: 0.862548, alpha: 0.88)
        static var userColor = UIColor(red: 0.14726, green: 0.838161, blue: 0.533935, alpha: 1)
        static var font: UIFont = UIFont.systemFont(ofSize: FONTSIZENormal)
    }
    
    /*
     These methods are included for ObjC compatibility.  If using Swift, you can set the Appearance variables directly.
     */
    
    class func setAppearanceOpponentColor(_ opponentColor: UIColor) {
        Appearance.opponentColor = opponentColor
    }
    
    class func setAppearanceUserColor(_ userColor: UIColor) {
        Appearance.userColor = userColor
    }
    
    class  func setAppearanceFont(_ font: UIFont) {
        Appearance.font = font
    }
    
    // MARK: Message Bubble TextView
    
    fileprivate lazy var textView: MessageBubbleTextView = {
        let textView = MessageBubbleTextView(frame: CGRect.zero, textContainer: nil)
        self.contentView.addSubview(textView)
        return textView
    }()
    
    fileprivate lazy var textView1: UILabel = {
        let textView1 = UILabel()
        textView1.font =  UIFont(name: fontName, size: FONTSIZENormal)
        textView1.textColor = UIColor.gray
        textView1.textAlignment = .right
        self.textView.addSubview(textView1)
        return textView1
    }()
    
    fileprivate lazy var photoView: UIView = {
        
        let photoView = UIView()
        
        photoView.backgroundColor = aafBgColor
        self.textView.addSubview(photoView)
        
        return photoView
        
    }()
    fileprivate lazy var photoViewButton: UIButton = {
        
        let photoViewButton = UIButton()
        
        photoViewButton.backgroundColor = UIColor.clear
        
        photoViewButton.isHidden = true
        self.textView.addSubview(photoViewButton)
        
        return photoViewButton
        
    }()
    
    fileprivate lazy var photoImageView: UIImageView = {
        
        //  photoImageView.contentMode = UIView.ContentMode.scaleAspectFit
        let photoImageView = UIImageView()
       // photoImageView.contentMode = UIView.ContentMode.scaleAspectFit
        photoImageView.backgroundColor = UIColor.clear
        photoImageView.image = nil
        photoImageView.layer.cornerRadius = 5.0
        photoImageView.clipsToBounds = true
        
        
        self.photoView.addSubview(photoImageView)
        
        return photoImageView
        
    }()
    
    fileprivate lazy var linkDescription: TTTAttributedLabel = {
        
        let linkDescription = TTTAttributedLabel(frame: CGRect.zero)
        linkDescription.font = UIFont(name: fontName, size: FONTSIZESmall)
        linkDescription.numberOfLines = 0
        self.photoView.addSubview(linkDescription)
        return linkDescription
        
    }()
    
    
    fileprivate class MessageBubbleTextView : UITextView {
        
        override init(frame: CGRect = CGRect.zero, textContainer: NSTextContainer? = nil) {
            super.init(frame: frame, textContainer: textContainer)
            self.font = Appearance.font
            self.isScrollEnabled = false
            self.isEditable = false
            self.textContainerInset = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
            self.layer.cornerRadius = 15
            self.layer.borderWidth = 0.0
        }
        
        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    // MARK: ImageView
    
    fileprivate lazy var opponentImageView: UIImageView = {
        let opponentImageView = UIImageView()
        opponentImageView.isHidden = true
        opponentImageView.bounds.size = CGSize(width: self.minimumHeight * 1.5, height: self.minimumHeight * 1.5)
        let halfWidth = opponentImageView.bounds.width / 2.0
        let halfHeight = opponentImageView.bounds.height / 2.0
        
        // Center the imageview vertically to the textView when it is singleLine
        let textViewSingleLineCenter = self.textView.textContainerInset.top + (Appearance.font.lineHeight / 2.0)
        opponentImageView.center = CGPoint(x: self.padding + halfWidth, y: textViewSingleLineCenter)
        opponentImageView.backgroundColor = UIColor.lightText
        opponentImageView.layer.rasterizationScale = UIScreen.main.scale
        opponentImageView.layer.shouldRasterize = true
        opponentImageView.layer.cornerRadius = halfHeight
        opponentImageView.layer.masksToBounds = true
        self.contentView.addSubview(opponentImageView)
        return opponentImageView
    }()
    
    fileprivate lazy var opponentImageViewButton: UIButton = {
        let opponentImageViewButton = UIButton()
        opponentImageViewButton.isHidden = true
        opponentImageViewButton.bounds.size = CGSize(width: self.minimumHeight * 1.5, height: self.minimumHeight * 1.5)
        let halfWidth = opponentImageViewButton.bounds.width / 2.0
        let halfHeight = opponentImageViewButton.bounds.height / 2.0
        
        // Center the imageview vertically to the textView when it is singleLine
        let textViewSingleLineCenter = self.textView.textContainerInset.top + (Appearance.font.lineHeight / 2.0)
        opponentImageViewButton.center = CGPoint(x: self.padding + halfWidth, y: textViewSingleLineCenter)
        opponentImageViewButton.layer.rasterizationScale = UIScreen.main.scale
        opponentImageViewButton.layer.shouldRasterize = true
        opponentImageViewButton.layer.cornerRadius = halfHeight
        opponentImageViewButton.layer.masksToBounds = true
        self.contentView.addSubview(opponentImageViewButton)
        return opponentImageViewButton
    }()
    
    
    // MARK: Sizing
    
    fileprivate let padding: CGFloat = 5.0
    
    fileprivate let minimumHeight: CGFloat = 20.0 // arbitrary minimum height
    fileprivate let minimumWidth: CGFloat = 100.0 // arbitrary minimum height
    fileprivate var size = CGSize.zero
    
    fileprivate var maxSize: CGSize {
        get {
            let maxWidth = self.bounds.width * 0.75 // Cells can take up to 3/4 of screen
            let maxHeight = CGFloat.greatestFiniteMagnitude
            return CGSize(width: maxWidth, height: maxHeight)
        }
    }
    
    // MARK: Setup Call
    
    /*!
     Use this in cellForRowAtIndexPath to setup the cell.
     */
    func setupWithMessage(_ message: LGChatMessage) -> CGSize {
        
        textView.text = "\(message.content)\n"
        textView.dataDetectorTypes = UIDataDetectorTypes.link
        textView.font = UIFont(name: fontName, size: FONTSIZENormal)
        textView.isUserInteractionEnabled = true
        size = textView.sizeThatFits(maxSize)
        if size.height < minimumHeight {
            size.height = minimumHeight
        }
        if size.width < minimumWidth {
            if UIDevice.current.userInterfaceIdiom == .phone {
               size.width = minimumWidth
            }
            else {
                size.width = minimumWidth + 15
            }
            
        }
        
        photoView.bounds.size = CGSize(width: 0.0, height:0.0)
        linkDescription.bounds.size = CGSize(width: 0.0, height:0.0)
        if message.attachment.count > 0 {
            if message.attachment["image"] !=  nil{
                if message.attachment["title"] as! String == "" && message.attachment["description"] as! String == "" {
                    photoView.frame.origin.x = 0.0
                    photoView.frame.origin.y = size.height
                    photoImageView.frame.origin.x = 5.0
                    photoImageView.frame.origin.y = 10.0
                    
                    photoImageView.contentMode = UIView.ContentMode.scaleAspectFit
                    if let img = imageCacheShow[message.attachment["image"] as! String]
                    {
                        self.photoImageView.image = img
                    }
                    else{
                        self.photoImageView.image = nil
                        let url1 = URL(string: message.attachment["image"] as! String)
                        if url1 != nil
                        {
                            self.photoImageView.kf.indicatorType = .activity
                            (self.photoImageView.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                            self.photoImageView.kf.setImage(with: url1 as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                
                            })
                        }
                    }
                    
                    let imageWidth = UIScreen.main.bounds.width * 0.6
                    let imageHeight = imageWidth * 0.8
                    photoView.backgroundColor = UIColor.clear
                    photoView.bounds.size =  CGSize(width: imageWidth , height:imageHeight)
                    photoViewButton.isHidden = false
                    photoViewButton.frame = photoView.frame
                    photoImageView.bounds.size = CGSize(width: imageWidth - 10.0 , height:imageHeight - 20.0)
                    photoImageView.bounds.size = CGSize(width: imageWidth - 10.0 , height:imageHeight - 20.0)
                    if photoView.bounds.size.height != 0.0 {
                        size.height = size.height + photoView.bounds.size.height
                    }
                    if size.width > imageWidth{
                        
                    }
                    else{
                        size.width  = imageWidth
                    }
                    
                }
                
                
                if message.attachment["title"] as! String != "" && message.attachment["description"] as! String != "" {
                    photoView.frame.origin.x = 0.0
                    photoView.frame.origin.y = size.height
                    
                    photoImageView.frame.origin.x = 5.0
                    photoImageView.frame.origin.y = 10.0
                    
                    photoImageView.contentMode = UIView.ContentMode.scaleAspectFit
                    photoImageView.clipsToBounds = true
                    if let img = imageCacheShow[message.attachment["image"] as! String]
                    {
                        self.photoImageView.image = img
                    }
                    else{
                        self.photoImageView.image = nil
                        let url1 = URL(string: message.attachment["image"] as! String)
                        if url1 != nil
                        {
                            self.photoImageView.kf.indicatorType = .activity
                            (self.photoImageView.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                            self.photoImageView.kf.setImage(with: url1 as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                
                            })
                        }
                    }
                    
                    let imageWidth = UIScreen.main.bounds.width * 0.6
                    
                    photoView.bounds.size =  CGSize(width: imageWidth , height:70.0)
                    photoView.backgroundColor = aafBgColor
                    photoImageView.bounds.size = CGSize(width: 50.0 , height: 50.0)
                    var messagelinkDescription = ""
                    var messagelinkTitle = ""
                    let titleString = message.attachment["title"] as! String
                    if titleString.length < 10{
                        messagelinkTitle = titleString
                    }else{
                        messagelinkTitle = (titleString as NSString).substring(to: 10-3)
                        
                    }
                    
                    messagelinkDescription = "\(messagelinkTitle)  \n \( message.attachment["description"] as! String)"
                    
                    
                    
                    linkDescription.setText(messagelinkDescription, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                        let boldFont = CTFontCreateWithName( (fontBold as CFString?)!, FONTSIZESmall, nil)
                        let range1 = (messagelinkDescription as NSString).range(of: message.attachment["title"] as! String)
                        mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range1)
                        mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorDark , range: range1)
                        
                        return mutableAttributedString!
                    })
                    linkDescription.lineBreakMode = NSLineBreakMode.byWordWrapping
                    linkDescription.sizeToFit()
                    
                    linkDescription.frame.origin.x =  photoImageView.bounds.size.width + photoImageView.frame.origin.x + 2.0
                    linkDescription.frame.origin.y = 10.0
                    linkDescription.bounds.size = CGSize(width: imageWidth - (photoImageView.bounds.size.width + 12.0) , height: 50.0)
                    photoViewButton.isHidden = false
                    photoViewButton.frame = photoView.frame
                    photoViewButton.frame = photoView.frame
                    if photoView.bounds.size.height != 0.0 {
                        size.height = size.height + photoView.bounds.size.height
                    }
                    if size.width > imageWidth{
                        
                    }
                    else{
                        size.width  = imageWidth
                    }
                    
                }
                
            }
            if message.attachment["imageAttachment"] !=  nil{
                if message.attachment["title"] as! String == "" && message.attachment["description"] as! String == "" {
                    photoView.frame.origin.x = 0.0
                    photoView.frame.origin.y = size.height
                    photoImageView.frame.origin.x = 5.0
                    photoImageView.frame.origin.y = 10.0
                    
                    if var a =  message.attachment["imageAttachment"]! as? [UIImage]{
                        
                        photoImageView.contentMode = UIView.ContentMode.scaleAspectFit
                        if (message.attachment["imageAttachment"]! as AnyObject).count > 0{
                            a = message.attachment["imageAttachment"]! as! [UIImage]
                            self.photoImageView.image = a[0]
                        }
                        
                    }
                    let imageWidth = UIScreen.main.bounds.width * 0.6
                    let imageHeight = imageWidth * 0.8
                    photoView.bounds.size =  CGSize(width: imageWidth , height:imageHeight)
                    photoView.backgroundColor = UIColor.clear
                    photoViewButton.isHidden = true
                    photoViewButton.frame = photoView.frame
                    photoImageView.bounds.size = CGSize(width: imageWidth - 10.0 , height:imageHeight - 20.0)
                    photoImageView.bounds.size = CGSize(width: imageWidth - 10.0 , height:imageHeight - 20.0)
                    if photoView.bounds.size.height != 0.0 {
                        size.height = size.height + photoView.bounds.size.height
                    }
                    if size.width > imageWidth{
                        
                    }
                    else{
                        size.width  = imageWidth
                    }
                    
                }
                
                if message.attachment["title"] as! String != "" && message.attachment["description"] as! String != "" {
                    photoView.frame.origin.x = 0.0
                    photoView.frame.origin.y = size.height
                    
                    photoImageView.frame.origin.x = 5.0
                    photoImageView.frame.origin.y = 10.0
                    
                    photoImageView.contentMode = UIView.ContentMode.scaleAspectFit
                    photoImageView.clipsToBounds = true
                    if let img = imageCacheShow[message.attachment["imageAttachment"] as! String]
                    {
                        self.photoImageView.image = img
                    }
                    else{
                        self.photoImageView.image = nil
                        let url1 = URL(string: message.attachment["imageAttachment"] as! String)
                        if url1 != nil
                        {
                            self.photoImageView.kf.indicatorType = .activity
                            (self.photoImageView.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                            self.photoImageView.kf.setImage(with: url1 as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                
                            })
                        }
                    }
                    let imageWidth = UIScreen.main.bounds.width * 0.6
                    
                    photoView.bounds.size =  CGSize(width: imageWidth , height:70.0)
                    photoView.backgroundColor = aafBgColor
                    photoImageView.bounds.size = CGSize(width: 50.0 , height: 50.0)
                    var messagelinkDescription = ""
                    var messagelinkTitle = ""
                    let titleString = message.attachment["title"] as! String
                    if titleString.length < 10{
                        messagelinkTitle = titleString
                    }else{
                        messagelinkTitle = (titleString as NSString).substring(to: 10-3)
                        
                    }
                    messagelinkDescription = "\(messagelinkTitle)  \n \( message.attachment["description"] as! String)"
                    
                    linkDescription.setText(messagelinkDescription, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                        let boldFont = CTFontCreateWithName( (fontBold as CFString?)!, FONTSIZENormal, nil)
                        let range1 = (messagelinkDescription as NSString).range(of: message.attachment["title"] as! String)
                        mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range1)
                        mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorDark , range: range1)
                        
                        return mutableAttributedString
                    })
                    linkDescription.lineBreakMode = NSLineBreakMode.byWordWrapping
                    linkDescription.sizeToFit()
                    
                    linkDescription.frame.origin.x =  photoImageView.bounds.size.width + photoImageView.frame.origin.x + 2.0
                    linkDescription.frame.origin.y = 10.0
                    linkDescription.bounds.size = CGSize(width: imageWidth - (photoImageView.bounds.size.width + 12.0) , height: 50.0)
                    photoViewButton.isHidden = true
                    photoViewButton.frame = photoView.frame
                    if photoView.bounds.size.height != 0.0 {
                        size.height = size.height + photoView.bounds.size.height
                    }
                    if size.width > imageWidth{
                        
                    }
                    else{
                        size.width  = imageWidth
                    }
                    
                    
                }
                
            }
            
        }
        textView.bounds.size = size
        textView1.frame.origin.x = textView.bounds.width - 110
        textView1.frame.origin.y = textView.bounds.height - 20
        textView1.bounds.size = CGSize(width: 100, height:20)
        textView1.text = message.date
        self.styleTextViewForSentBy(message.sentBy)
        return size
    }
    
    // MARK: TextBubble Styling
    fileprivate func styleTextViewForSentBy(_ sentBy: LGChatMessage.SentBy) {
        let halfTextViewWidth = self.textView.bounds.width / 2.0
        let targetX = halfTextViewWidth + padding
        let halfTextViewHeight = self.textView.bounds.height / 2.0
        switch sentBy {
        case .Opponent:
            self.textView.center.x = targetX
            self.textView.center.y = halfTextViewHeight
            self.textView.layer.backgroundColor = UIColor(red: 241/255.0, green: 241/255.0, blue: 241/255.0, alpha: 1.0).cgColor
            self.textView.layer.borderColor = UIColor(red: 241/255.0, green: 241/255.0, blue: 241/255.0, alpha: 1.0).cgColor
            
            self.opponentImageView.isHidden = false
            self.opponentImageViewButton.isHidden = false
            self.opponentImageView.image = UIImage(named: "user_profile_image.png")
            
            self.textView.center.x += self.opponentImageView.bounds.width + padding
            textView1.frame.origin.x = textView.bounds.width - 110
            textView1.frame.origin.y = textView.bounds.height - 20
            photoViewButton.frame.origin.x = 0.0
            if (photoView.frame.size.height != 0.0){
                photoView.frame.origin.x = 0.0
                photoImageView.frame.origin.x = 5.0
                photoView.frame.origin.y = size.height - (photoView.frame.size.height  + 20)
                photoViewButton.frame.origin.y = photoView.frame.origin.y
                photoImageView.frame.origin.y = 10//size.height - (photoView.frame.size.height  + 30 )
            }
            if (linkDescription.frame.size.height != 0.0){
                linkDescription.frame.origin.x =  photoImageView.bounds.size.width + photoImageView.frame.origin.x + 2.0
                
               // linkDescription.frame.origin.y  = size.height - (photoView.frame.size.height  + 30 )
            }
            
        case .User:
            self.opponentImageView.isHidden = true
            self.opponentImageViewButton.isHidden = true
            self.textView.center.x = self.bounds.width - targetX
            self.textView.center.y = halfTextViewHeight
            self.textView.layer.borderColor = UIColor(red: 41/255 , green: 121/255 , blue: 255/255 , alpha: 0.1).cgColor
            self.textView.layer.backgroundColor = UIColor(red: 41/255 , green: 121/255 , blue: 255/255 , alpha: 0.1).cgColor
            textView1.frame.origin.x = textView.bounds.width - 110
            textView1.frame.origin.y = textView.bounds.height - 20
            
            
            
            if (photoView.frame.size.height != 0.0){
                photoView.frame.origin.x = 0.0
                photoImageView.frame.origin.x = 5.0
                photoViewButton.frame.origin.x = 0.0
                photoView.frame.origin.y = size.height - (photoView.frame.size.height  + 20)
                photoImageView.frame.origin.y = 10 //size.height - (photoView.frame.size.height  + 30 )
                
                photoViewButton.frame.origin.y = photoView.frame.origin.y
            }
            if (linkDescription.frame.size.height != 0.0){
                linkDescription.frame.origin.x =  photoImageView.bounds.size.width + photoImageView.frame.origin.x + 2.0
               // linkDescription.frame.origin.y  = size.height - (photoView.frame.size.height  + 30 )
            }
        }
    }
}

// MARK: Chat Controller
@objc protocol LGChatControllerDelegate {
    @objc optional func shouldChatController(_ chatController: LGChatController, addMessage message: LGChatMessage) -> Bool
    @objc optional func chatController(_ chatController: LGChatController, didAddNewMessage message: LGChatMessage)
}

class LGChatController : UIViewController, UITableViewDelegate, UITableViewDataSource, LGChatInputDelegate,ELCImagePickerControllerDelegate,UIGestureRecognizerDelegate, UITextFieldDelegate{
    
    
    
    var conversation_id : Int!
    var attachmentarray =  [String:AnyObject]()
    var linkField: UITextField!
    var subView : UIView!
    var subView1 : UIView!
    var titleofLink : String = ""
    var descriptionofLink : String = ""
    var imageofLink: String = ""
    var transparentViewVideo :UIView!
    var subViewVideo : UIView!
    var cancelAttachFile : UIButton!
    // MARK: Constants
    fileprivate struct Constants {
        static let MessagesSection: Int = 0;
        static let MessageCellIdentifier: String = "LGChatController.Constants.MessageCellIdentifier"
    }
    
    // MARK: Public Properties
    
    /*!
     Use this to set the messages to be displayed
     */
    var messages: [LGChatMessage] = []
    var opponentImage: UIImage?
    weak var delegate: LGChatControllerDelegate?
    var deleteButton : UIButton!
    var optionButton : UIButton!
    var rightNavView : UIView!
    var countLabel: UILabel!
    var linkTextField : UITextField!
    var attachMessageLink : Bool = false
    var videoAttachmentKey = ""
    var attachFile : UIButton!
    
    // MARK: Private Properties
    
    fileprivate let sizingCell = LGChatMessageCell()
    
    fileprivate let tableView: UITableView = UITableView()
    
    fileprivate let chatInput = LGChatInput(frame: CGRect.zero)
    
    fileprivate var bottomChatInputConstraint: NSLayoutConstraint!
    
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        scrollingToBottom = true
        view.backgroundColor = bgColor
        self.setup()
        let attachmentCount = 1
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(LGChatController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        
        let backIconImageView = createImageView(CGRect(x: 0,y: 12,width: 22,height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")
        leftNavView.addSubview(backIconImageView)
        let barButtonItem1 = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem1

        rightNavView = UIView(frame: CGRect(x: 0, y: 0, width: 66, height: 44))
        rightNavView.backgroundColor = UIColor.clear
        
        deleteButton = createButton(CGRect(x: 44,y: 12,width: 22,height: 22), title: "\u{f014}", border: false, bgColor: false, textColor: textColorPrime)
        deleteButton.titleLabel!.font = UIFont(name: "FontAwesome", size:FONTSIZEExtraLarge)
        deleteButton.addTarget(self, action: #selector(LGChatController.delete as (LGChatController) -> () -> ()), for: .touchUpInside)
        rightNavView.addSubview(deleteButton)
        
        optionButton = createButton(CGRect(x: 0,y: 12,width: 22,height: 22), title: "\u{f0c6}", border: false, bgColor: false, textColor: textColorPrime)
        optionButton.titleLabel!.font = UIFont(name: "FontAwesome", size:FONTSIZEExtraLarge)
        optionButton.addTarget(self, action: #selector(LGChatController.showOptionEvent(_:)), for: .touchUpInside)
        optionButton.tag = 11
        rightNavView.addSubview(optionButton)
        
        countLabel = createLabel(CGRect(x: 0,y: 0,width: 14,height: 14), text: "\(attachmentCount)", alignment: .center, textColor: textColorLight)
        countLabel.backgroundColor = UIColor.red
        countLabel.layer.cornerRadius = countLabel.frame.size.width / 2;
        countLabel.layer.masksToBounds = true
        
        countLabel.font = UIFont(name: "fontAwesome", size: FONTSIZENormal)
        countLabel.isHidden = true
        rightNavView.addSubview(countLabel)
        
        let barButtonItem = UIBarButtonItem(customView: rightNavView)
        
        self.navigationItem.rightBarButtonItem = barButtonItem
        
        let recognizer = UITapGestureRecognizer(target: self, action:#selector(LGChatController.handleTap(_:)))
        recognizer.delegate = self
        view.addGestureRecognizer(recognizer)
        

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.listenForKeyboardChanges()
//        spinner.center = view.center
//        spinner.hidesWhenStopped = true
//        spinner.style = UIstyle.gray
//        view.addSubview(spinner)
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.center = self.view.center
        activityIndicatorView.startAnimating()
        
    }
    
    @objc func userprofile(_ sender:UIButton){
        if sender.tag > 0 {
            let presentedVC = ContentActivityFeedViewController()
            presentedVC.subjectType = "user"
            presentedVC.subjectId = "\(sender.tag)"
            presentedVC.fromActivity = false
            searchDic.removeAll(keepingCapacity: false)
            
            navigationController?.pushViewController(presentedVC, animated: false)
        }
        
    }
    
    @objc func actionafterClick(_ sender:UIButton){
        let message = self.messages[sender.tag]
        
        if(message.attachment["uri"] != nil){
            let presentedVC = ExternalWebViewController()
            presentedVC.url = message.attachment["uri"] as! String
            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            let navigationController = UINavigationController(rootViewController: presentedVC)
            self.present(navigationController, animated: true, completion: nil)
        }
            
        else  if(message.attachment["video_id"] != nil && message.attachment["content_url"] != nil && message.attachment["type"] != nil){
            let presentedVC = VideoProfileViewController()
            presentedVC.videoId = message.attachment["video_id"] as! Int
            presentedVC.videoType = message.attachment["type"] as? Int
            presentedVC.videoUrl = message.attachment["content_url"] as! String
            navigationController?.pushViewController(presentedVC, animated: true)
            
        }
        else if(message.attachment["album_id"] != nil && message.attachment["image"] != nil){
            let presentedVC = SinglePhotoLightBoxController()
            presentedVC.imageUrl = message.attachment["image"] as! String
            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            let nativationController = UINavigationController(rootViewController: presentedVC)
            present(nativationController, animated:false, completion: nil)
            
            
            
        }
    }
    
    @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
        if transparentView != nil{
            for ob in transparentView.subviews{
                ob.removeFromSuperview()
            }
            transparentView.removeFromSuperview()
            //subView.hidden = true
            transparentView = nil
            
        }
        if transparentView1 != nil{
            for ob in transparentView1.subviews{
                ob.removeFromSuperview()
            }
            transparentView1.removeFromSuperview()
            transparentView1 = nil
        }
        
        
    }
    
    @objc func showOptionEvent(_ sender:UIButton)
    {
        self.view.endEditing(true)
        if attachmentMessageFlag == false
        {
            attachment()
        }
        else
        {
            if sender.tag == 11{
                attachment()
            }
            else if sender.tag == 22{
                showCustomJoinAlert()
            }
            else if sender.tag == 33{
                showAttachedLink()
            }
        }
        
    }
    
    func attachment()
    {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Attach Image",  comment: ""), style: .default, handler:{ (UIAlertAction) -> Void in
            let imagePicker = ELCImagePickerController(imagePicker: ())
            imagePicker?.maximumImagesCount = 1
            imagePicker?.returnsOriginalImage = true
            imagePicker?.returnsImage = true
            imagePicker?.onOrder = true
            imagePicker?.imagePickerDelegate = self
            
            let photoAuthorization = PHPhotoLibrary.authorizationStatus()
            switch photoAuthorization
            {
            case .authorized:
                self.present(imagePicker!, animated: false, completion: nil)
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization({ (newStatus) in
                    if newStatus == PHAuthorizationStatus.authorized
                    {
                        self.present(imagePicker!, animated: false, completion: nil)
                    }
                })
                print("It is not determined until now")
            case .denied, .restricted:
                photoPermission(controller: self)
                print("User has denied the permission.")
            }
            
            //self.present(imagePicker!, animated: false, completion: nil)
            
        }))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Attach Link",  comment: ""), style: .default, handler:{ (UIAlertAction) -> Void in
            self.attachmentLink()
        }))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Attach Video",  comment: ""), style: .default, handler:{ (UIAlertAction) -> Void in
            self.upDateFeedOptions(5)
        }))
        if  (!isIpad()){
            alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .cancel, handler:nil))
        }else if  (UIDevice.current.userInterfaceIdiom == .pad){
            // Present Alert as! Popover for iPad
            alertController.modalPresentationStyle = UIModalPresentationStyle.popover
            let popover = alertController.popoverPresentationController
            popover?.sourceView = UIButton()
            popover?.sourceRect = CGRect(x: view.bounds.height/2, y: view.bounds.width/2 , width: 1, height: 1)
            popover?.permittedArrowDirections = UIPopoverArrowDirection()
        }
        self.present(alertController, animated:true, completion: nil)
        
        
    }
    
    func upDateFeedOptions(_ option:Int){
        
        
        if transparentViewVideo == nil
            
        {
            transparentViewVideo = UIView(frame: view.frame)
            transparentViewVideo.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
            view.addSubview(transparentViewVideo)
        }
        
        for ob in transparentViewVideo.subviews{
            ob.removeFromSuperview()
        }
        
        
        
        subViewVideo = UIView(frame: CGRect(x: 0, y: 0, width: 250, height: 110))
        subViewVideo.backgroundColor = UIColor.white
        subViewVideo.center = transparentViewVideo.center
        subViewVideo.layer.borderWidth = 1;
        subViewVideo.layer.cornerRadius = 10.0
        transparentViewVideo.addSubview(subViewVideo)
        
        
        
        let cancle = createButton(CGRect(x: subViewVideo.bounds.width-20, y: 2,width: 20, height: 30), title: "\(cancelFriendIcon)", border: false,bgColor: false, textColor: textColorDark)
        cancle.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
        cancle.tag = option
        cancle.addTarget(self, action: #selector(LGChatController.cancleSelection(_:)), for: .touchUpInside)
        subViewVideo.addSubview(cancle)
        
        
        let videoOption = createButton(CGRect(x: 5, y: 35, width: subViewVideo.bounds.width - 10, height: 40),title: NSLocalizedString("Choose Source",  comment: "") , border: true,bgColor: false, textColor: textColorDark)
        videoOption.titleLabel?.font = UIFont(name: fontName , size: FONTSIZESmall)
        videoOption.contentHorizontalAlignment = .left
        videoOption.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        videoOption.addTarget(self, action: #selector(LGChatController.videoOptionList(_:)), for: .touchUpInside)
        subViewVideo.addSubview(videoOption)
        
        self.linkTextField =  createTextField(CGRect(x: 5, y: 80, width: subViewVideo.bounds.width - 10, height: 40), borderColor: borderColorDark, placeHolderText: NSLocalizedString("Link",  comment: "" ),corner: false )
        self.linkTextField.isHidden = true
        self.linkTextField.delegate = self
        subViewVideo.addSubview(linkTextField)
        self.linkTextField.returnKeyType = UIReturnKeyType.done
        
        self.linkTextField.autocorrectionType = UITextAutocorrectionType.no
        self.linkTextField.autocapitalizationType = .none
        self.linkTextField.keyboardType = UIKeyboardType.URL
        
        
        self.view.isUserInteractionEnabled = true
        
        self.attachFile = createButton(CGRect(x: 2 * contentPADING, y: 125, width: 110, height: ButtonHeight - 5),  title: NSLocalizedString("Attach",  comment: ""), border: true,bgColor: false, textColor: textColorLight)
        self.attachFile.isHidden = true
        self.attachFile.layer.cornerRadius = 5.0
        self.attachFile.tag = 5
        self.attachFile.backgroundColor = navColor
        self.attachFile.layer.borderColor = navColor.cgColor
        self.attachFile.addTarget(self, action: #selector(LGChatController.attachFileAction(_:)), for: .touchUpInside)
        subViewVideo.addSubview(self.attachFile)
        
        
        cancelAttachFile = createButton(CGRect(x: (4 * contentPADING) + 110, y: 125, width: 110, height: ButtonHeight - 5),  title: NSLocalizedString("Cancel",  comment: ""), border: true,bgColor: false, textColor: navColor)
        cancelAttachFile.layer.cornerRadius = 5.0
        cancelAttachFile.isHidden = true
        cancelAttachFile.tag = 5
        cancelAttachFile.layer.borderColor = navColor.cgColor
        cancelAttachFile.backgroundColor = textColorLight
        cancelAttachFile.addTarget(self, action: #selector(LGChatController.cancleSelection(_:)), for: .touchUpInside)
        subViewVideo.addSubview(cancelAttachFile)
        
    }
    
    @objc func videoOptionList(_ sender:UIButton){
        
        
        var videoDictionary = Dictionary<String, String>()
        videoDictionary["0"] = "Choose Source"
        videoDictionary["1"] = "YouTube"
        videoDictionary["2"] = "Vimeo"
        if videoDictionary.count > 0 {
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
            
            for (key,value) in videoDictionary {
                
                alertController.addAction(UIAlertAction(title:  NSLocalizedString("\(value)",comment: ""), style: .default) { action -> Void in
                    
                    sender.setTitle(videoDictionary["\(key)"], for: UIControl.State())
                    if key != "0"{
                        self.subViewVideo.frame.size.height = self.cancelAttachFile.frame.origin.y + self.cancelAttachFile.frame.size.height + 10
                        self.subViewVideo.center = self.transparentViewVideo.center
                        self.videoAttachmentKey = key
                        self.cancelAttachFile.isHidden = false
                        self.attachFile.isHidden = false
                        self.linkTextField.isHidden = false
                    }
                    
                })
            }
            
            if  (UIDevice.current.userInterfaceIdiom == .phone){
                alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .cancel, handler:nil))
            }else{
                // Present Alert as! Popover for iPad
                alertController.modalPresentationStyle = UIModalPresentationStyle.popover
                let popover = alertController.popoverPresentationController
                popover?.sourceView = UIButton()
                popover?.sourceRect = CGRect(x: view.bounds.height/2, y: view.bounds.width/2, width: 0, height: 0)
                popover?.permittedArrowDirections = UIPopoverArrowDirection()
            }
            self.present(alertController, animated:true, completion: nil)
            
            
        }
        
    }
    
    @objc func attachFileAction(_ sender:UIButton){
        for ob in transparentViewVideo.subviews{
            
            ob.removeFromSuperview()
        }
        transparentViewVideo.removeFromSuperview()
        transparentViewVideo = nil
        linkTextField.resignFirstResponder()
        attachVideo()
    }
    
    func attachVideo(){
        
        if linkTextField.text!.range(of: "http://") != nil || linkTextField.text!.range(of: "https://") != nil{
            
            videoUrl = self.linkTextField.text!
            
        }else{
            let tempUrl = "http://\(self.linkTextField.text!)"
            videoUrl = tempUrl
        }
        
        if Reachabable.isConnectedToNetwork() {
            var path = ""
            var parameters = [String:String]()
            path = "videos/create"
            
            parameters = ["post_attach":"1","type":"\(videoAttachmentKey)", "url" : videoUrl]
//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            self.view.alpha = 1.0

            activityIndicatorView.startAnimating()
            view.isUserInteractionEnabled = false
            post(parameters, url: path, method: "POST") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    
                    if msg{
                        if let response = succeeded["body"] as? NSDictionary{
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
                                if ((title != "" || video_id != "") && (imageString != "")){
                                    videoId = video_id
                                    self.view.alpha = 1
                                    self.titleofLink = title
                                    self.descriptionofLink = video_id
                                    self.imageofLink = imageString
                                    self.view.isUserInteractionEnabled = true
                                    
                                    self.showAttachedVideoLink()
                                }else{
                                    videoId = ""
                                    self.view.alpha = 1
                                    self.view.isUserInteractionEnabled = true
                                    showToast(message: "Video Not Available", controller: self)
                                }
                                
                                
                                
                            }
                            
                        }
                    }else{
                        activityIndicatorView.stopAnimating()
                        self.view.alpha = 1
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        self.view.isUserInteractionEnabled = true
                    }
                    
                })
            }
        }
        
        
    }
    
    @objc func cancleSelection(_ sender:UIButton){
        
        
        videoUrl = ""
        transparentViewVideo.removeFromSuperview()
        transparentViewVideo = nil
        
    }
    
    func showCustomJoinAlert(){
        
        if transparentView == nil
            
        {
            transparentView = UIView(frame: view.frame)
            transparentView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
            view.addSubview(transparentView)
        }
        
        for ob in transparentView.subviews{
            ob.removeFromSuperview()
        }
        
        subView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width * 0.8, height: view.bounds.height * 0.6))
        subView.backgroundColor = UIColor.white
        subView.center = transparentView.center
        subView.layer.borderWidth = 1;
        subView.layer.cornerRadius = 10.0
        transparentView.addSubview(subView)
        let imageAttach = createImageView(CGRect(x: 2 * contentPADING,y: 2 * contentPADING, width: subView.bounds.width -  (4*contentPADING) , height: subView.bounds.height  - (ButtonHeight + 4 * contentPADING)), border: true)
        if attachPhotoImage.count > 0{
            imageAttach.image = attachPhotoImage[0]
        }
        
        subView.addSubview(imageAttach)
        let originY:CGFloat = imageAttach.bounds.height
        
        let done = createButton(CGRect(x: 2 * contentPADING , y: originY + 3 * contentPADING, width: 110, height: ButtonHeight - 5), title: NSLocalizedString("Remove Attach", comment: ""), border: true,bgColor: true , textColor: textColorLight)
        done.addTarget(self , action:#selector(LGChatController.removeImage) , for: .touchUpInside)
        done.layer.cornerRadius = 5.0
        done.backgroundColor =  navColor
        done.layer.borderColor = navColor.cgColor
        done.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
        done.setTitleColor(textColorLight, for: UIControl.State())
        subView.addSubview(done)
        
        let cancel = createButton(CGRect(x: (4 * contentPADING) + 110 , y: originY + 3 * contentPADING, width: 110, height: ButtonHeight - 5),  title: NSLocalizedString("Cancel",comment: ""), border: true,bgColor: false , textColor: navColor)
        cancel.layer.cornerRadius = 5.0
        cancel.addTarget(self , action:#selector(LGChatController.hideCustomAlert) , for: .touchUpInside)
        cancel.layer.borderColor = navColor.cgColor
        cancel.backgroundColor = textColorLight
        cancel.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
        subView.addSubview(cancel)
        subView.frame.size.height = originY + (4 * contentPADING) + ButtonHeight - 5
    }
    
    func elcImagePickerControllerDidCancel(_ picker: ELCImagePickerController!) {
        dismiss(animated: true, completion: nil)
    }
    
    func elcImagePickerController(_ picker: ELCImagePickerController!, didFinishPickingMediaWithInfo info: [Any]!) {
        
        dismiss(animated: true, completion: nil)
        
        attachPhotoImage.removeAll(keepingCapacity: false)
        linkUrl = ""
        
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
                        
                        attachPhotoImage.append(pickedImage!) // you can get image like this way
                        
                    })
                }
            }
        }
        
        for dic in info{
            if let photoDic = dic as? NSDictionary{
                if photoDic.object(forKey: UIImagePickerController.InfoKey.mediaType) as? String == ALAssetTypePhoto {
                    if (photoDic.object(forKey: UIImagePickerController.InfoKey.originalImage) != nil){
                        let image = photoDic.object(forKey: UIImagePickerController.InfoKey.originalImage) as! UIImage
                        attachPhotoImage.append(image)
                    }
                }
            }
        }
        if attachPhotoImage.count > 0 {
            attachmentMessageFlag = true
            optionButton.tag = 22
            countLabel.isHidden = false
            attachmentMessageLink = true
        }
    }
    
    @objc func removeImage(){
        attachPhotoImage.removeAll(keepingCapacity: false)
        countLabel.isHidden = true
        attachMessageLink = false
        for ob in transparentView.subviews{
            ob.removeFromSuperview()
        }
        
        transparentView.removeFromSuperview()
        transparentView = nil
        attachmentMessageFlag = false
        optionButton.tag = 11
        
    }
    
    @objc func goBack()
    {
        var flag : Bool = false
        
        if fromFriendlist == true
        {
            fromFriendlist = false
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers
            for aViewController in viewControllers {
                if aViewController is MemberViewController {
                    flag = true
                    self.navigationController!.popToViewController(aViewController, animated: true)
                }
            }
        }
        
        if flag == false {
            _ = self.navigationController?.popToRootViewController(animated: false)
        }
    }
    
    func attachmentLink(){
        let alert = UIAlertController(title: NSLocalizedString("Attach Link",comment: ""), message: NSLocalizedString("Enter url:",comment: ""), preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Done",comment: ""), style: UIAlertAction.Style.default, handler: attachmentLinks))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
        alert.addTextField(configurationHandler: {(textField: UITextField) in
            textField.placeholder = NSLocalizedString("Enter Url",comment: "")
            textField.isSecureTextEntry = false
            self.linkField = textField
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    func attachmentLinks(_ alertView: UIAlertAction!){
        var error = ""
        if linkField.text!.range(of: "http://") != nil || linkField.text!.range(of: "https://") != nil{
            linkUrl = "\(self.linkField.text!)"
        }else{
            let tempUrl = "http://\(self.linkField.text!)"
            linkUrl = tempUrl
        }
        
        if self.linkField.text!  == "" {
            error = NSLocalizedString("Please enter url.",comment: "")
        }
        
        if error != ""{
            let alertController = UIAlertController(title: "Error", message:
                error, preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
        else{
            
            if Reachabable.isConnectedToNetwork() {
                var path = ""
                var parameters = [String:String]()
                path = "advancedactivity/feeds/attach-link"
                parameters = ["uri": linkUrl]
//                spinner.center = view.center
//                spinner.hidesWhenStopped = true
//                spinner.style = UIstyle.gray
//                view.addSubview(spinner)
                self.view.addSubview(activityIndicatorView)
                activityIndicatorView.center = self.view.center
                self.view.alpha = 1.0

                activityIndicatorView.startAnimating()
                view.isUserInteractionEnabled = false
                activityPost(parameters as Dictionary<String, AnyObject>, url: path, method: "POST") { (succeeded, msg) -> () in
                    DispatchQueue.main.async(execute: {
                        activityIndicatorView.stopAnimating()
                        
                        if(msg){
                            
                            if let response = succeeded["body"] as? NSDictionary{
                                
                                var title = ""
                                var description = ""
                                var imageString = ""
                                
                                if let temp_title = response["title"] as? String{
                                    title = temp_title
                                }
                                if let temp_description = response["description"] as? String{
                                    description = temp_description
                                }
                                
                                if let tempImageString = response["thumb"] as? String{
                                    imageString = tempImageString
                                }
                                
                                if ((title != "" || description != "") && (imageString != "")){
                                    self.view.alpha = 1
                                    
                                    self.view.isUserInteractionEnabled = true
                                    
                                    self.titleofLink = title
                                    self.descriptionofLink = description
                                    self.imageofLink = imageString
                                    self.showAttachedLink()
                                }else{
                                    self.view.alpha = 1
                                    linkUrl = ""
                                    
                                    self.view.isUserInteractionEnabled = true
                                    showToast(message: "Webpage not available.", controller: self)
                                }
                            }
                        }
                        else{
                            self.view.alpha = 1
                            
                            self.view.isUserInteractionEnabled = true
                            showToast(message: "Webpage not available.", controller: self)
                        }
                    })
                }
            }
        }
        
    }
    
    func showAttachedLink(){
        
        if transparentView1 == nil
            
        {
            transparentView1 = UIView(frame: view.frame)
            transparentView1.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
            view.addSubview(transparentView1)
        }
        
        for ob in transparentView1.subviews{
            ob.removeFromSuperview()
        }
        
        subView1 = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width * 0.8, height: view.bounds.height * 0.4))
        subView1.backgroundColor = UIColor.white
        subView1.center = transparentView1.center
        subView1.layer.borderWidth = 1;
        subView1.layer.cornerRadius = 10.0
        subView1.tag = 1000
        subView1.isUserInteractionEnabled = true
        transparentView1.addSubview(subView1)
        var imageAttach = createImageView(CGRect(x: 2 * contentPADING,y: 2 * contentPADING, width: 80 , height: 80), border: true)
        let coverImageUrl = URL(string:  self.imageofLink)
        if coverImageUrl != nil
        {
            imageAttach.kf.indicatorType = .activity
            (imageAttach.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
            imageAttach.kf.setImage(with: coverImageUrl as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                
            })
        }
        
        subView1.addSubview(imageAttach)
        
        
        let titleLabel = createLabel(CGRect(x: 3 * contentPADING + 80, y: 2 * contentPADING, width: subView1.bounds.width -  (6*contentPADING + 80), height: 20) , text: "", alignment: .left, textColor: textColorDark)
        titleLabel.text = "\(self.titleofLink)"
        titleLabel.font = UIFont(name: fontBold, size: FONTSIZESmall)
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
        subView1.addSubview(titleLabel)
        
        let descriptionLabel = createLabel(CGRect(x: 3 * contentPADING + 80,y: 2 * contentPADING + 20 , width: subView1.bounds.width -  (6*contentPADING + 80), height: 50), text: "\(self.descriptionofLink)", alignment: .left, textColor: textColorDark)
        descriptionLabel.font = UIFont(name: fontName, size: FONTSIZEMedium)
        descriptionLabel.numberOfLines = 0
        subView1.addSubview(descriptionLabel)
        
        
        let originY:CGFloat = imageAttach.bounds.height
        
        let done = createButton(CGRect(x: 2 * contentPADING , y: originY + 3 * contentPADING, width: 110, height: ButtonHeight - 5), title: NSLocalizedString("Attach Link", comment: ""), border: true,bgColor: true , textColor: textColorLight)
        done.layer.cornerRadius = 5.0
        done.addTarget(self , action:#selector(LGChatController.attachLinkUrl) , for: .touchUpInside)
        done.isUserInteractionEnabled = true
        done.backgroundColor =  navColor
        done.layer.borderColor = navColor.cgColor
        done.setTitleColor(textColorLight, for: UIControl.State())
        subView1.addSubview(done)
        
        let cancel = createButton(CGRect(x: (4 * contentPADING) + 110 , y: originY + 3 * contentPADING, width: 110, height: ButtonHeight - 5),  title: NSLocalizedString("Cancel",comment: ""), border: true,bgColor: false , textColor: navColor)
        cancel.layer.cornerRadius = 5.0
        cancel.addTarget(self , action:#selector(LGChatController.hideCustomAlertt) , for: .touchUpInside)
        cancel.layer.borderColor = navColor.cgColor
        cancel.backgroundColor = textColorLight
        subView1.addSubview(cancel)
        subView1.frame.size.height = originY + (4 * contentPADING) + ButtonHeight - 5
        
    }
    
    func showAttachedVideoLink(){
        if transparentView1 == nil
            
        {
            transparentView1 = UIView(frame: view.frame)
            transparentView1.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
            view.addSubview(transparentView1)
        }
        
        for ob in transparentView1.subviews{
            ob.removeFromSuperview()
        }
        
        subView1 = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width * 0.8, height: view.bounds.height * 0.4))
        subView1.backgroundColor = UIColor.white
        subView1.center = transparentView1.center
        subView1.layer.borderWidth = 1;
        subView1.layer.cornerRadius = 10.0
        subView1.tag = 1000
        subView1.isUserInteractionEnabled = true
        transparentView1.addSubview(subView1)
        var imageAttach = createImageView(CGRect(x: 2 * contentPADING,y: 2 * contentPADING, width: 80 , height: 80), border: true)
        let coverImageUrl = URL(string:  self.imageofLink)
        if coverImageUrl != nil
        {
            imageAttach.kf.indicatorType = .activity
             (imageAttach.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
            imageAttach.kf.setImage(with: coverImageUrl as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                
            })
        }
        subView1.addSubview(imageAttach)
        
        
        let titleLabel = createLabel(CGRect(x: 3 * contentPADING + 80, y: 2 * contentPADING, width: subView1.bounds.width -  (4*contentPADING + 80), height: 20) , text: "", alignment: .left, textColor: textColorDark)
        titleLabel.text = "\(self.titleofLink)"
        titleLabel.font = UIFont(name: fontBold, size: FONTSIZENormal)
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
        subView1.addSubview(titleLabel)
        
        let descriptionLabel = createLabel(CGRect(x: 3 * contentPADING + 80,y: 2 * contentPADING + 20 , width: subView1.bounds.width -  (6*contentPADING + 80), height: 50), text: "\(self.descriptionofLink)", alignment: .left, textColor: textColorDark)
        descriptionLabel.font = UIFont(name: fontName, size: FONTSIZEMedium)
        descriptionLabel.numberOfLines = 2
        subView1.addSubview(descriptionLabel)
        
        
        let originY:CGFloat = imageAttach.bounds.height
        
        let done = createButton(CGRect(x: 2 * contentPADING , y: originY + 3 * contentPADING, width: 110, height: ButtonHeight - 5), title: NSLocalizedString("Attach Link", comment: ""), border: true,bgColor: true , textColor: textColorLight)
        done.addTarget(self , action:#selector(LGChatController.attachVideoUrl) , for: .touchUpInside)
        done.isUserInteractionEnabled = true
        done.layer.cornerRadius = 5.0
        done.backgroundColor =  navColor
        done.layer.borderColor = navColor.cgColor
        done.setTitleColor(textColorLight, for: UIControl.State())
        subView1.addSubview(done)
        let cancel = createButton(CGRect(x: (4 * contentPADING) + 110 , y: originY + 3 * contentPADING, width: 110, height: ButtonHeight - 5),  title: NSLocalizedString("Cancel",comment: ""), border: true,bgColor: false , textColor: navColor)
        cancel.layer.cornerRadius = 5.0
        cancel.addTarget(self , action:#selector(LGChatController.hideCustomAlertt) , for: .touchUpInside)
        cancel.layer.borderColor = navColor.cgColor
        cancel.backgroundColor = textColorLight
        subView1.addSubview(cancel)
        subView1.frame.size.height = originY + (4 * contentPADING) + ButtonHeight - 5
        
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
    
    @objc func attachLinkUrl(){
        countLabel.isHidden = false
        optionButton.tag = 33
        attachmentMessageLink = true
        attachmentMessageFlag = true
        attachPhotoImage.removeAll(keepingCapacity: false)
        hideCustomAlertt()
    }
    
    @objc func attachVideoUrl(){
        countLabel.isHidden = false
        optionButton.tag = 33
        attachmentMessageLink = true
        attachmentMessageFlag = true
        attachPhotoImage.removeAll(keepingCapacity: false)
        hideCustomAlertt()
    }
    
    @objc func hideCustomAlert(){
        for ob in transparentView.subviews{
            ob.removeFromSuperview()
        }
        transparentView.removeFromSuperview()
        transparentView = nil
    }
    
    @objc func hideCustomAlertt(){
        for ob in transparentView1.subviews{
            ob.removeFromSuperview()
        }
        attachmentMessageFlag = true
        transparentView1.removeFromSuperview()
        transparentView1 = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if scrollingToBottom == true{
            self.scrollToBottom()
        }
        else{
            activityIndicatorView.stopAnimating()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.unregisterKeyboardObservers()
    }
    
    deinit {
        /*
         Need to remove delegate and datasource or they will try to send scrollView messages.
         */
        self.tableView.delegate = nil
        self.tableView.dataSource = nil
    }
    
    // MARK: Setup
    
    fileprivate func setup() {
        self.setupTableView()
        self.setupChatInput()
        self.setupLayoutConstraints()
    }
    
    fileprivate func setupTableView() {
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.frame = self.view.bounds
        tableView.register(LGChatMessageCell.classForCoder(), forCellReuseIdentifier: "identifier")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        self.view.addSubview(tableView)
    }
    
    fileprivate func setupChatInput() {
        chatInput.delegate = self
        self.view.addSubview(chatInput)
    }
    
    fileprivate func setupLayoutConstraints() {
        chatInput.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints(self.chatInputConstraints())
        self.view.addConstraints(self.tableViewConstraints())
    }
    
    fileprivate func chatInputConstraints() -> [NSLayoutConstraint] {
        self.bottomChatInputConstraint = NSLayoutConstraint(item: chatInput, attribute: .bottom, relatedBy: .equal, toItem: self.bottomLayoutGuide, attribute: .top, multiplier: 1.0, constant: 0)
        let leftConstraint = NSLayoutConstraint(item: chatInput, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1.0, constant: 0.0)
        let rightConstraint = NSLayoutConstraint(item: chatInput, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1.0, constant: 0.0)
        return [leftConstraint, self.bottomChatInputConstraint, rightConstraint]
    }
    
    fileprivate func tableViewConstraints() -> [NSLayoutConstraint] {
        let leftConstraint = NSLayoutConstraint(item: tableView, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1.0, constant: 0.0)
        let rightConstraint = NSLayoutConstraint(item: tableView, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1.0, constant: 0.0)
        let topConstraint = NSLayoutConstraint(item: tableView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0.0)
        let bottomConstraint = NSLayoutConstraint(item: tableView, attribute: .bottom, relatedBy: .equal, toItem: chatInput, attribute: .top, multiplier: 1.0, constant: 0)
        return [rightConstraint, leftConstraint, topConstraint, bottomConstraint]//, rightConstraint, bottomConstraint]
    }
    
    // MARK: Keyboard Notifications
    
    fileprivate func listenForKeyboardChanges() {
        let defaultCenter = NotificationCenter.default
        defaultCenter.addObserver(self, selector: #selector(LGChatController.keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    fileprivate func unregisterKeyboardObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    @objc func stopTimer() {
        stop()
        
        _ = self.navigationController?.popToRootViewController(animated: false)
    }
    
    @objc func delete(){
        deleteMessage = true
        let alertController = UIAlertController(title: "Delete", message:
            "Do you want to delete your conversation ?", preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive ,handler: { (action) in
            var parameters = [String:String]()
            parameters = ["conversation_ids": String(self.conversation_id) ]
            post(parameters, url: "messages/delete", method: "DELETE")
            {
                (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    showToast(message: NSLocalizedString("Your message has been deleted successfully", comment: ""), controller: self)
                    self.createTimer(self)
                    
                })
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
        
    }
    func createTimer(_ target: AnyObject){
        timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  #selector(stopTimer), userInfo: nil, repeats: false)
    }
    
    @objc func keyboardWillChangeFrame(_ note: Foundation.Notification) {
        let keyboardAnimationDetail = (note as NSNotification).userInfo!
        let duration = keyboardAnimationDetail[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        var keyboardFrame = (keyboardAnimationDetail[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        if let window = self.view.window {
            keyboardFrame = window.convert(keyboardFrame, to: self.view)
        }
        let animationCurve = keyboardAnimationDetail[UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
        
        self.tableView.isScrollEnabled = false
        self.tableView.decelerationRate = UIScrollView.DecelerationRate.fast
        self.view.layoutIfNeeded()
        var chatInputOffset = -((self.view.bounds.height - self.bottomLayoutGuide.length) - keyboardFrame.minY)
        if chatInputOffset > 0 {
            chatInputOffset = 0
        }
        self.bottomChatInputConstraint.constant = chatInputOffset
        UIView.animate(withDuration: duration, delay: 0.0, options: UIView.AnimationOptions(rawValue: animationCurve), animations: { () -> Void in
            self.view.layoutIfNeeded()
            self.scrollToBottom()
            
        }, completion: {(finished) -> () in
            self.tableView.isScrollEnabled = true
            self.tableView.decelerationRate = UIScrollView.DecelerationRate.normal
            
        })
    }
    // MARK: Rotation
    func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { (_) in
            self.tableView.reloadData()
        }) { (_) in
            UIView.animate(withDuration: 0.25, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: { () -> Void in
                self.scrollToBottom()
            }, completion: nil)
        }
        
    }
    
    // MARK: Scrolling
    
    fileprivate func scrollToBottom() {
        activityIndicatorView.stopAnimating()
        if messages.count > 0 {
            var lastItemIdx = self.tableView.numberOfRows(inSection: Constants.MessagesSection) - 1
            if lastItemIdx < 0 {
                lastItemIdx = 0
            }
            let lastIndexPath = IndexPath(row: lastItemIdx, section: Constants.MessagesSection)
            self.tableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: false)
        }
    }
    
    // MARK: New messages
    
    func addNewMessage(_ message: LGChatMessage) {
        messages += [message]
        tableView.reloadData()
        countLabel.isHidden = true
        self.scrollToBottom()
        self.delegate?.chatController?(self, didAddNewMessage: message)
    }
    
    // MARK: SwiftChatInputDelegate
    
    func chatInputDidResize(_ chatInput: LGChatInput) {
        self.scrollToBottom()
    }
    
    func chatInput(_ chatInput: LGChatInput, didSendMessage message: String) {
        if titleofLink != "" && descriptionofLink != ""{
            attachmentarray["title"]  = titleofLink as AnyObject?
            attachmentarray["description"] = descriptionofLink as AnyObject?
            attachmentarray["imageAttachment"] = imageofLink as AnyObject?
        }
        else if attachPhotoImage.count > 0 {
            attachmentarray["title"]  = "" as AnyObject?
            attachmentarray["description"] = "" as AnyObject?
            attachmentarray["imageAttachment"] = attachPhotoImage as AnyObject?
            
        }
        else {
            attachmentarray = [:]
        }
        
        
        titleofLink = ""
        descriptionofLink = ""
        imageofLink = ""
        let newMessage = LGChatMessage(content: message, sentBy: .User,date: "now",imageUrl : "" , userId : currentUserId,attachment: attachmentarray as NSDictionary)
        var shouldSendMessage = true
        if let value = self.delegate?.shouldChatController?(self, addMessage: newMessage) {
            shouldSendMessage = value
        }
        
        if shouldSendMessage {
            self.addNewMessage(newMessage)
        }
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let padding: CGFloat = 10.0
        sizingCell.bounds.size.width = self.view.bounds.width
        let height = self.sizingCell.setupWithMessage(messages[(indexPath as NSIndexPath).row]).height + padding;
        return height
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isDragging {
            self.chatInput.textView.resignFirstResponder()
        }
    }
    
    // MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "identifier", for: indexPath) as! LGChatMessageCell
        let message = self.messages[(indexPath as NSIndexPath).row]
        let url = message.imageUrl
        let user_id = message.userId
        
        
        let url1 = URL(string: url)
        
        if let url1 = URL(string: url){
            
            let request: URLRequest = URLRequest(url: url1)
            let mainQueue = OperationQueue.main
            NSURLConnection.sendAsynchronousRequest(request, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
                if error == nil {
                    // Convert the downloaded data in to a UIImage object
                    let image = UIImage(data: data!)
                    DispatchQueue.main.async(execute: {
                        
                        cell.opponentImageView.image = image
                        
                    })
                }
                else {
                    //print("Error: \(error!.localizedDescription)")
                }
            })
            
        }
        
        
        if url1 != nil{
          //  cell.opponentImageView.sd_setImage(with: url1 as URL!, completed: { (image, error, Imagechachetype, Imageurl) in
         //       DispatchQueue.main.async {
                    
                    cell.opponentImageViewButton.addTarget(self, action: #selector(LGChatController.userprofile(_:)), for: UIControl.Event.touchUpInside)
                    cell.opponentImageViewButton.tag = user_id
                    cell.photoViewButton.tag = (indexPath as NSIndexPath).row
                    cell.photoViewButton.addTarget(self, action: #selector(LGChatController.actionafterClick(_:)), for: UIControl.Event.touchUpInside)
        //        }
        //    })
        }
        
        _ = cell.setupWithMessage(message)
        return cell;
    }
    
}
// MARK: Chat Input
protocol LGChatInputDelegate : class {
    func chatInputDidResize(_ chatInput: LGChatInput)
    func chatInput(_ chatInput: LGChatInput, didSendMessage message: String)
}

class LGChatInput : UIView, LGStretchyTextViewDelegate {
    
    // MARK: Styling
    
    struct Appearance {
        static var includeBlur = true
        static var tintColor = UIColor(red: 0.0, green: 120 / 255.0, blue: 255 / 255.0, alpha: 1.0)
        static var backgroundColor = UIColor.white
        static var textViewFont = UIFont.systemFont(ofSize: FONTSIZEMedium)
        static var textViewTextColor = UIColor.darkText
        static var textViewBackgroundColor = UIColor.white
    }
    
    /*
     These methods are included for ObjC compatibility.  If using Swift, you can set the Appearance variables directly.
     */
    
    class func setAppearanceIncludeBlur(_ includeBlur: Bool) {
        Appearance.includeBlur = includeBlur
    }
    
    class func setAppearanceTintColor(_ color: UIColor) {
        Appearance.tintColor = color
    }
    
    class func setAppearanceBackgroundColor(_ color: UIColor) {
        Appearance.backgroundColor = color
    }
    
    class func setAppearanceTextViewFont(_ textViewFont: UIFont) {
        Appearance.textViewFont = textViewFont
    }
    
    class func setAppearanceTextViewTextColor(_ textColor: UIColor) {
        Appearance.textViewTextColor = textColor
    }
    
    class func setAppearanceTextViewBackgroundColor(_ color: UIColor) {
        Appearance.textViewBackgroundColor = color
    }
    
    // MARK: Public Properties
    
    var textViewInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    weak var delegate: LGChatInputDelegate?
    
    // MARK: Private Properties
    
    fileprivate let textView = LGStretchyTextView(frame: CGRect.zero, textContainer: nil)
    fileprivate let sendButton = UIButton(type: .system)
    fileprivate let blurredBackgroundView: UIToolbar = UIToolbar()
    fileprivate var heightConstraint: NSLayoutConstraint!
    fileprivate var sendButtonHeightConstraint: NSLayoutConstraint!
    
    // MARK: Initialization
    
    override init(frame: CGRect = CGRect.zero) {
        super.init(frame: frame)
        self.setup()
        self.stylize()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Setup
    
    func setup() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setupSendButton()
        self.setupSendButtonConstraints()
        self.setupTextView()
        self.setupTextViewConstraints()
        self.setupBlurredBackgroundView()
        self.setupBlurredBackgroundViewConstraints()
    }
    
    func setupTextView() {
        textView.bounds = self.bounds.inset(by: self.textViewInsets)//UIEdgeInsetsInsetRect(self.bounds, self.textViewInsets)
        textView.stretchyTextViewDelegate = self
        textView.center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        self.styleTextView()
        self.addSubview(textView)
    }
    
    func styleTextView() {
        textView.layer.rasterizationScale = UIScreen.main.scale
        textView.layer.shouldRasterize = true
        textView.layer.cornerRadius = 5.0
        textView.layer.borderWidth = 1.0
        textView.layer.borderColor = UIColor(white: 0.0, alpha: 0.2).cgColor
    }
    
    func setupSendButton() {
        self.sendButton.isEnabled = false
        self.sendButton.setTitle("Send", for: UIControl.State())
        self.sendButton.addTarget(self, action: #selector(LGChatInput.sendButtonPressed(_:)), for: .touchUpInside)
        self.sendButton.bounds = CGRect(x: 0, y: 0, width: 40, height: 1)
        self.addSubview(sendButton)
    }
    
    func setupSendButtonConstraints() {
        self.sendButton.translatesAutoresizingMaskIntoConstraints = false
        self.sendButton.removeConstraints(self.sendButton.constraints)
        
        // TODO: Fix so that button height doesn't change on first newLine
        let rightConstraint = NSLayoutConstraint(item: self, attribute: .right, relatedBy: .equal, toItem: self.sendButton, attribute: .right, multiplier: 1.0, constant: textViewInsets.right)
        let bottomConstraint = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: self.sendButton, attribute: .bottom, multiplier: 1.0, constant: textViewInsets.bottom)
        let widthConstraint = NSLayoutConstraint(item: self.sendButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40)
        sendButtonHeightConstraint = NSLayoutConstraint(item: self.sendButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 30)
        self.addConstraints([sendButtonHeightConstraint, widthConstraint, rightConstraint, bottomConstraint])
    }
    
    func setupTextViewConstraints() {
        self.textView.translatesAutoresizingMaskIntoConstraints = false
        let topConstraint = NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: self.textView, attribute: .top, multiplier: 1.0, constant: -textViewInsets.top)
        let leftConstraint = NSLayoutConstraint(item: self, attribute: .left, relatedBy: .equal, toItem: self.textView, attribute: .left, multiplier: 1, constant: -textViewInsets.left)
        let bottomConstraint = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: self.textView, attribute: .bottom, multiplier: 1, constant: textViewInsets.bottom)
        let rightConstraint = NSLayoutConstraint(item: self.textView, attribute: .right, relatedBy: .equal, toItem: self.sendButton, attribute: .left, multiplier: 1, constant: -textViewInsets.right)
        heightConstraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.00, constant: 40)
        self.addConstraints([topConstraint, leftConstraint, bottomConstraint, rightConstraint, heightConstraint])
    }
    
    func setupBlurredBackgroundView() {
        self.addSubview(self.blurredBackgroundView)
        self.sendSubviewToBack(self.blurredBackgroundView)
    }
    
    func setupBlurredBackgroundViewConstraints() {
        self.blurredBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        let topConstraint = NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: self.blurredBackgroundView, attribute: .top, multiplier: 1.0, constant: 0)
        let leftConstraint = NSLayoutConstraint(item: self, attribute: .left, relatedBy: .equal, toItem: self.blurredBackgroundView, attribute: .left, multiplier: 1.0, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: self.blurredBackgroundView, attribute: .bottom, multiplier: 1.0, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: self, attribute: .right, relatedBy: .equal, toItem: self.blurredBackgroundView, attribute: .right, multiplier: 1.0, constant: 0)
        self.addConstraints([topConstraint, leftConstraint, bottomConstraint, rightConstraint])
    }
    
    // MARK: Styling
    
    func stylize() {
        self.textView.backgroundColor = Appearance.textViewBackgroundColor
        self.sendButton.tintColor = buttonColor
        self.textView.tintColor = Appearance.tintColor
        self.textView.font = Appearance.textViewFont
        self.textView.textColor = Appearance.textViewTextColor
        self.blurredBackgroundView.isHidden = !Appearance.includeBlur
        self.backgroundColor = Appearance.backgroundColor
    }
    
    // MARK: StretchyTextViewDelegate
    
    func stretchyTextViewDidChangeSize(_ textView: LGStretchyTextView) {
        let textViewHeight = textView.bounds.height
        if textView.text.count == 0 {
            self.sendButtonHeightConstraint.constant = textViewHeight
        }
        let targetConstant = textViewHeight + textViewInsets.top + textViewInsets.bottom
        self.heightConstraint.constant = targetConstant
        self.delegate?.chatInputDidResize(self)
    }
    
    func stretchyTextView(_ textView: LGStretchyTextView, validityDidChange isValid: Bool) {
        self.sendButton.isEnabled = isValid
    }
    
    // MARK: Button Presses
    
    @objc func sendButtonPressed(_ sender: UIButton)
    {
        if isSendMessage == 0
        {
            let nc = NotificationCenter.default
            nc.post(name: Foundation.Notification.Name(rawValue: "isSendMessage"),     object: nil)
        }
        else {
            if !self.textView.text.trimmingCharacters(in: .whitespaces).isEmpty {
                if self.textView.text.count > 0
                {
                    
                    self.delegate?.chatInput(self, didSendMessage: self.textView.text)
                    self.textView.text = ""
                    attachmentMessageFlag = false
                }
            }
        }
        
    }
}

// MARK: Text View
@objc protocol LGStretchyTextViewDelegate {
    func stretchyTextViewDidChangeSize(_ chatInput: LGStretchyTextView)
    @objc optional func stretchyTextView(_ textView: LGStretchyTextView, validityDidChange isValid: Bool)
}

class LGStretchyTextView : UITextView, UITextViewDelegate {
    
    // MARK: Delegate
    
    weak var stretchyTextViewDelegate: LGStretchyTextViewDelegate?
    
    // MARK: Public Properties
    
    var maxHeightPortrait: CGFloat = 160
    var maxHeightLandScape: CGFloat = 60
    var maxHeight: CGFloat {
        get {
            switch UIDevice.current.orientation {
            case .portrait:
                print("Portrait")
                return maxHeightPortrait
            case .portraitUpsideDown:
                print("PortraitUpsideDown")
                return maxHeightPortrait
            case .landscapeLeft:
                print("LandscapeLeft")
                return maxHeightLandScape
            case .landscapeRight:
                print("LandscapeRight")
                return maxHeightLandScape
            default:
                print("Another")
                return maxHeightPortrait
            }//UIInterfaceOrientation.isPortrait(UIApplication.shared.statusBarOrientation) ? maxHeightPortrait : maxHeightLandScape
        }
    }
    // MARK: Private Properties
    
    fileprivate var maxSize: CGSize {
        get {
            return CGSize(width: self.bounds.width, height: self.maxHeightPortrait)
        }
    }
    
    fileprivate var isValid: Bool = false {
        didSet {
            if isValid != oldValue {
                stretchyTextViewDelegate?.stretchyTextView?(self, validityDidChange: isValid)
            }
        }
    }
    
    fileprivate let sizingTextView = UITextView()
    
    // MARK: Property Overrides
    
    override var contentSize: CGSize {
        didSet {
            resize()
        }
    }
    
    override var font: UIFont! {
        didSet {
            sizingTextView.font = font
        }
    }
    
    override var textContainerInset: UIEdgeInsets
        {
        didSet {
            sizingTextView.textContainerInset = textContainerInset
        }
    }
    
    // MARK: Initializers
    
    override init(frame: CGRect = CGRect.zero, textContainer: NSTextContainer? = nil) {
        super.init(frame: frame, textContainer: textContainer);
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Setup
    
    func setup() {
        font = UIFont.systemFont(ofSize: FONTSIZEMedium)
        textContainerInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        delegate = self
    }
    
    // MARK: Sizing
    
    func resize() {
        bounds.size.height = self.targetHeight()
        stretchyTextViewDelegate?.stretchyTextViewDidChangeSize(self)
    }
    
    func targetHeight() -> CGFloat {
        
        /*
         There is an issue when calling `sizeThatFits` on self that results in really weird drawing issues with aligning line breaks ("\n").  For that reason, we have a textView whose job it is to size the textView. It's excess, but apparently necessary.  If there's been an update to the system and this is no longer necessary, or if you find a better solution. Please remove it and submit a pull request as I'd rather not have it.
         */
        
        sizingTextView.text = self.text
        let targetSize = sizingTextView.sizeThatFits(maxSize)
        let targetHeight = targetSize.height
        let maxHeight = self.maxHeight
        return targetHeight < maxHeight ? targetHeight : maxHeight
    }
    
    // MARK: Alignment
    
    func align() {
        
        guard let end = self.selectedTextRange?.end else { return }
        
        let caretRect: CGRect = self.caretRect(for: end)
        let topOfLine = caretRect.minY
        let bottomOfLine = caretRect.maxY
        
        let contentOffsetTop = self.contentOffset.y
        let bottomOfVisibleTextArea = contentOffsetTop + self.bounds.height
        
        /*
         If the caretHeight and the inset padding is greater than the total bounds then we are on the first line and aligning will cause bouncing.
         */
        
        let caretHeightPlusInsets = caretRect.height + self.textContainerInset.top + self.textContainerInset.bottom
        if caretHeightPlusInsets < self.bounds.height {
            var overflow: CGFloat = 0.0
            if topOfLine < contentOffsetTop + self.textContainerInset.top {
                overflow = topOfLine - contentOffsetTop - self.textContainerInset.top
            } else if bottomOfLine > bottomOfVisibleTextArea - self.textContainerInset.bottom {
                overflow = (bottomOfLine - bottomOfVisibleTextArea) + self.textContainerInset.bottom
            }
            self.contentOffset.y += overflow
        }
    }
    
    // MARK: UITextViewDelegate
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if transparentView != nil{
            for ob in transparentView.subviews{
                ob.removeFromSuperview()
            }
            transparentView.removeFromSuperview()
            transparentView = nil
            
        }
        if transparentView1 != nil{
            for ob in transparentView1.subviews{
                ob.removeFromSuperview()
            }
            transparentView1.removeFromSuperview()
            transparentView1 = nil
        }
        self.align()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        // TODO: Possibly filter spaces and newlines
        self.isValid = textView.text.count > 0
    }
    
}
