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
//  Like&CommentViewController.swift
//  seiosnativeapp

import UIKit

var likeCommentContent_id :String!
var likeCommentContentType : String!
var Messag_Owner : Bool = false
var Messag_OwnerId : Int = 0
var Messag_Url : String = ""
var info : UILabel!
var total_Likes = 0
var total_Comments = 0
var Message_OwnerId : Int = 0
var like_CommentStyle:Int!
class Like_CommentView: UIView {
    
    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func drawRect(rect: CGRect) {
     // Drawing code
     }
     */
    var isLikePost = false
    var like = UIButton()
    var comment : UIButton!
    var share : UIButton!
    var more : UIButton!
    var isLike:Bool!
    var like_Comment :UIButton!
    var canComment:Int!
    var photoAlbumId: Int = 0
    var myMenu:NSArray!
    var shareImage:UIImage!
    // Reaction Varibles
    var reactionsInfo =  UIView()
    var reactionShow = UIView()
    var likeCommentViewer:[LikeCommentView]!
    var reactionsIcon = [AnyObject]()
    // Initialize the Like_CommentView FrameSize
//    convenience init()
//    {
//        if !fromAlbum {
//        if DeviceType.IS_IPHONE_X{
//            self.init(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - 40 - tabBarHeight,width: UIScreen.main.bounds.width,height: 40));
//        }
//        else{
//            self.init(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - 48 - tabBarHeight,width: UIScreen.main.bounds.width,height: 40));
//        }
//    }
//        else {
//            self.init(frame: likeCommentFrame)
//            fromAlbum = false
//        }
//    }
    
    // Initialize Like_CommentView
    override init(frame: CGRect) {
        super.init(frame: frame)
        if likeCommentContentType != "album" {
            if DeviceType.IS_IPHONE_X{
                self.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - 40 - tabBarHeight,width: UIScreen.main.bounds.width,height: 40)
              //  self.init(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - 40 - tabBarHeight,width: UIScreen.main.bounds.width,height: 40));
            }
            else{
                self.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - 48 - tabBarHeight,width: UIScreen.main.bounds.width,height: 40)
                //self.init(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - 48 - tabBarHeight,width: UIScreen.main.bounds.width,height: 40));
            }
        }
        // Make a call to custom SetUP
        myCustomSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // Floating Message Button Action
    @objc func clickOnFloatyMsgButton()
    {
        if isChannelizeAvailable{
            let data : [AnyHashable:Any] = [AnyHashable("userId"):Message_OwnerId]
            if let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController{
                let moduleName = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
                if let channelizeClass = NSClassFromString(moduleName + "." + "ChannelizeHelper") as? ChannelizeHelperDelegates.Type{
                    channelizeClass.performChannelizeLaunch(navigationController: navigationController, data: data)
                } else{
                    if let parentVC = self.parentViewController(){
                        let presentedVC = MessageOwnerViewController()
                        presentedVC.url = Messag_Url
                        parentVC.navigationController?.pushViewController(presentedVC, animated: true)
                    }
                }
                
            }
        } else{
            if let parentVC = self.parentViewController(){
                let presentedVC = MessageOwnerViewController()
                presentedVC.url = Messag_Url
                parentVC.navigationController?.pushViewController(presentedVC, animated: true)
            }
        }
    }
    
    // Make a CustomSetup After Initialization
    func myCustomSetup()
    {
        if likeCommentContentType == "album" {
            self.frame = likeCommentFrame
        }
        // Do any additional setup after loading the view.
        self.isHidden = true
        if ReactionPlugin == true
        {
//            if ReactionPlugin == true{
//                browseEmojis(contentItems: reactionsDictionary)
//            }
            browseEmojis(contentItems: reactionsDictionary)
            fetchReactionResponse()
        }
        else
        {
            findLikeComments()
        }
        total_Likes = 0
        total_Comments = 0
        
        if like_CommentStyle == 1{
            if likeCommentContentType == "album" {
                self.backgroundColor = UIColor.white
                self.layer.borderWidth = 0.5
                self.layer.borderColor = UIColor(white: 0.5, alpha: 0.3).cgColor
//                self.layer.shadowColor = UIColor(white: 0.5, alpha: 0.5)
//                self.layer.shadowOpacity = shadowOpacity
//                self.layer.shadowRadius = shadowRadius/2
//                self.layer.shadowOffset = shadowOffset
            }
            else {
            self.backgroundColor = UIColor.white
            self.layer.shadowColor = shadowColor.cgColor
            self.layer.shadowOpacity = shadowOpacity
            self.layer.shadowRadius = shadowRadius
            self.layer.shadowOffset = shadowOffset
            }
            
            // check whether Reaction Plugin is Enable or not
            if ReactionPlugin == true{
                reactionShow =  createView(CGRect(x: 0, y: 0, width: self.bounds.width/3, height: self.bounds.height), borderColor: UIColor.clear, shadow: false)
                reactionShow.backgroundColor = UIColor.clear// UIColor.black
            }
            else
            {
                like = createButton(CGRect(x: 0,y: 0,width: self.bounds.width/3, height: self.bounds.height), title: NSLocalizedString(" ", comment: ""), border: false, bgColor: false,textColor: textColorMedium)
                like.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
            }
            
            if Messag_Owner == true {
                
                if logoutUser == true{
                    info = createLabel(CGRect(x: 0,y: 0,width: self.bounds.width, height: self.bounds.height), text: "", alignment: .center, textColor: textColorMedium)
                    
                    like.isHidden = true
                    comment.isHidden = true
                    
                }else{
                    info = createLabel(CGRect(x: self.bounds.width/3,y: 0,width: self.bounds.width/3, height: self.bounds.height), text: "", alignment: .center, textColor: textColorMedium)
                    info.font = UIFont(name: "FontAwesome", size: FONTSIZELarge)
                }
                
                info.adjustsFontSizeToFitWidth = true
                info.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
                info.layer.borderColor = UIColor.black.cgColor
                info.numberOfLines = 0
                var finalText = ""
                finalText = "\(likeIcon)"
                finalText += " / "
                finalText += "\(commentIcon)"
                info.text = finalText
                
                self.addSubview(info)
                
                like_Comment = createButton(CGRect(x: self.bounds.width/3,y: 0,width: self.bounds.width/3, height: self.bounds.height), title: "", border: false,bgColor: false, textColor: textColorMedium)
                like_Comment.tag = 1
                like_Comment.addTarget(self, action: #selector(Like_CommentView.commentAction(_:)), for: .touchUpInside)
                self.addSubview(like_Comment)
                
                comment = createButton(CGRect(x: 2*self.bounds.width/3,y: 0,width: self.bounds.width/3, height: self.bounds.height), title: String(format: NSLocalizedString("Message", comment: "")), border: false,bgColor: false, textColor: textColorMedium)
                comment.titleLabel?.font = UIFont(name: fontName, size: FONTSIZENormal)
                comment.tag = 1
                comment.addTarget(self, action: #selector(Like_CommentView.clickOnFloatyMsgButton), for: .touchUpInside)
                self.addSubview(comment)
                
                let img = UIImageView(frame: CGRect(x:13, y:14, width:15, height:15))
                
                if isChannelizeAvailable{
                    img.image = UIImage(named:"channelize_icon")?.maskWithColor(color: textColorLight)
                } else{
                    img.image = UIImage(named:"messageIcon")?.maskWithColor(color: textColorLight)
                }
                img.contentMode = .scaleAspectFit
                comment.addSubview(img)
            }
            else
            {
                if likeCommentContentType == "sitevideo_channel"
                {
                    
                    comment = createButton(CGRect(x: self.bounds.width/3,y: 0,width: self.bounds.width/3, height: self.bounds.height), title: String(format: NSLocalizedString("%@ Subscribe", comment: ""), subscribeIcon), border: false,bgColor: false, textColor: textColorMedium)
                }
                else if likeCommentContentType == "album" {
                    comment = createButton(CGRect(x: self.bounds.width/3,y: 0,width: self.bounds.width/3, height: self.bounds.height), title: "", border: false, bgColor: false, textColor: textColorDark)
                    comment.setImage(UIImage(named: "commentIcon"), for: .normal)
                    let padding = (comment.frame.width-25)/2
                    comment.imageEdgeInsets = UIEdgeInsets(top: 12.5, left: padding, bottom: 12.5, right: padding)
                   
                }
                else
                {
                    comment = createButton(CGRect(x: self.bounds.width/3,y: 0,width: self.bounds.width/3, height: self.bounds.height), title: String(format: NSLocalizedString("%@ Comment", comment: ""), commentIcon), border: false,bgColor: false, textColor: textColorMedium)
                }
               
                if logoutUser == true{
                    info = createLabel(CGRect(x: 0,y: 0,width: self.bounds.width, height: self.bounds.height), text: "", alignment: .center, textColor: textColorMedium)
                    
                    like.isHidden = true
                    comment.isHidden = true
                    
                }else{
                    info = createLabel(CGRect(x: 2 * self.bounds.width/3,y: 0,width: self.bounds.width/3, height: self.bounds.height), text: "", alignment: .center, textColor: textColorMedium)
                    info.font = UIFont(name: "FontAwesome", size: FONTSIZELarge)
                }
           
                if issubscribe == 1
                {
                    
                    self.comment.titleLabel?.textColor = navColor
                    self.comment.setTitleColor(navColor , for: UIControl.State())
                }
                comment.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
                comment.tag = 1
                comment.addTarget(self, action: #selector(Like_CommentView.commentAction(_:)), for: .touchUpInside)
                self.addSubview(comment)
                
                info.adjustsFontSizeToFitWidth = true
                info.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
                info.layer.borderColor = UIColor.black.cgColor
                info.numberOfLines = 0
                var finalText = ""
                finalText = "\(likeIcon)"
                finalText += " / "
                finalText += "\(commentIcon)"
                info.text = finalText
                
                self.addSubview(info)
                
                like_Comment = createButton(CGRect(x: 3*self.bounds.width/5,y: 0,width: 2*self.bounds.width/5, height: self.bounds.height), title: "", border: false,bgColor: false, textColor: textColorMedium)
                like_Comment.tag = 0
                like_Comment.addTarget(self, action: #selector(Like_CommentView.commentAction1(_:)), for: .touchUpInside)
                self.addSubview(like_Comment)
            }
        }
        else if like_CommentStyle == 2{
            self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
            if ReactionPlugin == true{
                reactionShow =   createView(CGRect(x: 0, y: 0, width: self.bounds.width/5, height: self.bounds.height), borderColor: UIColor.clear, shadow: false)
                reactionShow.backgroundColor = UIColor.clear
            }
            else{
                like = createButton(CGRect(x: 0,y: 0,width: self.bounds.width/5, height: self.bounds.height), title: NSLocalizedString("\(likeIcon)", comment: ""), border: false,bgColor: false, textColor: textColorLight)
                like.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZELarge)
            }
            comment = createButton(CGRect(x: self.bounds.width/5,y: 0,width: self.bounds.width/5, height: self.bounds.height), title: "\(commentIcon)", border: false,bgColor: false, textColor: textColorLight)
            
            
            share = createButton(CGRect(x: 2 * self.bounds.width/5,y: 0,width: self.bounds.width/5, height: self.bounds.height), title: shareIcon, border: false,bgColor: false, textColor: textColorLight)
            share.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZELarge)
            share.addTarget(self, action: #selector(Like_CommentView.shareAction), for: .touchUpInside)
            self.addSubview(share)
            
            more = createButton(CGRect(x: 3*self.bounds.width/5,y: 0,width: 0, height: self.bounds.height), title: optionIcon, border: false,bgColor: false, textColor: textColorLight)
            more.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZELarge)
            more.addTarget(self, action: #selector(Like_CommentView.showMenu), for: .touchUpInside)
            self.addSubview(more)
            more.isHidden = true
            if logoutUser == true{
                info = createLabel(CGRect(x: 0,y: 0,width: self.bounds.width, height: self.bounds.height), text: "", alignment: .center, textColor: textColorLight)
                like.isHidden = true
                comment.isHidden = true
                more.isHidden = true
                share.isHidden = true
                
                var finalText = ""
                finalText = "\(likeIcon)"
                finalText += " / "
                finalText += "\(commentIcon)"
                info.text = finalText
                
            }else{
                info = createLabel(CGRect(x: 3*self.bounds.width/5,y: 0,width: 2*self.bounds.width/5, height: self.bounds.height), text: "", alignment: .center, textColor: textColorLight)
            }
            
            info.adjustsFontSizeToFitWidth = true
            info.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
            info.layer.borderColor = UIColor.black.cgColor
            info.numberOfLines = 0
            var finalText = ""
            finalText = "\(likeIcon)"
            finalText += " / "
            finalText += "\(commentIcon)"
            info.text = finalText
            
            self.addSubview(info)
            
            like_Comment = createButton(CGRect(x: 3*self.bounds.width/5,y: 0,width: 2*self.bounds.width/5, height: self.bounds.height), title: "", border: false,bgColor: false, textColor: textColorMedium)
            like_Comment.tag = 0
            like_Comment.addTarget(self, action: #selector(Like_CommentView.commentAction1(_:)), for: .touchUpInside)
            self.addSubview(like_Comment)
            
            if issubscribe == 1
            {
                
                self.comment.titleLabel?.textColor = navColor
                self.comment.setTitleColor(navColor , for: UIControl.State())
            }
            comment.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
            comment.tag = 1
            comment.addTarget(self, action: #selector(Like_CommentView.commentAction(_:)), for: .touchUpInside)
            self.addSubview(comment)
            
        }
        // Applied condition whether Reaction Plugin iss enabled or not
        if ReactionPlugin == true{
            self.addSubview(reactionShow)
        }
        else{
            like.addTarget(self, action: #selector(Like_CommentView.like_unLikeAction(_:)), for: .touchUpInside)
            self.addSubview(like)
        }
        
    }
    // MARK: Start code for when Reaction Plugin is enabled

    // fetch response of reaction if reaction plugin is enabled
    func  fetchReactionResponse(){
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
            // Send Server Request to Get info of Total Likes & total Comments  Content
            post(["subject_id": String(likeCommentContent_id), "subject_type": likeCommentContentType,"getReaction" : "1"], url: "reactions/content-reaction", method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    if msg{
                        if succeeded["body"] != nil{
                            self.isHidden = false
                            if let body = succeeded["body"] as? NSDictionary {
                                self.likeCommentViewer =  LikeCommentView.loadPhotosInfoDictionary(body)
                                self.canComment = self.likeCommentViewer[0].canComment
                                self.isLike = self.likeCommentViewer[0].is_like
                            }
                            self.uiForLike()
                        }
                    }
                    else{
                        // Handle Server Side Error
                        if succeeded["message"] != nil{
                            displayAlert("Info", error: (succeeded["message"] as! String))
                            if let parentVC = self.parentViewController(){
                                showCustomAlert(parentVC.view.center, msg: network_status_msg)
                            }
                        }
                    }
                })
            }
        }else{
            // No Internet Connection Message
            displayAlert("Info", error: network_status_msg)
            if let parentVC = self.parentViewController(){
                showCustomAlert(parentVC.view.center, msg: network_status_msg)
            }
        }
        
    }
    
    // View according whether Reaction plugin enabled or not
    func uiForLike(){
        for ob in self.reactionShow.subviews{
            if ob.tag == 200 || ob.tag == 300{
                ob.removeFromSuperview()
            }
        }
        if ReactionPlugin == true{
            if self.likeCommentViewer[0].likes_count != nil{
                total_Likes = self.likeCommentViewer[0].likes_count!
            }
            if self.likeCommentViewer[0].comments_count != nil{
                total_Comments = self.likeCommentViewer[0].comments_count!
            }
        }
        if likeCommentContentType == "album" {
            self.comment.titleLabel?.font = UIFont(name: fontName, size: FONTSIZENormal)
            self.comment.titleLabel?.adjustsFontSizeToFitWidth = true
            self.comment.setTitleColor(iconColor , for: UIControl.State())
            self.comment.titleEdgeInsets.left = 5
            if total_Comments > 0 {
                self.comment.setTitle("\(total_Comments)", for: .normal)
            }
        }
        if (self.likeCommentViewer[0].my_feed_reaction) != nil && ((self.likeCommentViewer[0].my_feed_reaction)?.count)! > 0{
            let myReaction = self.likeCommentViewer[0].my_feed_reaction!
            let width = self.reactionShow.frame.size.width
            let titleReaction = myReaction["caption"] as! String
            let  title =  NSLocalizedString("\(titleReaction)", comment: "")
            if let myIcon = myReaction["reaction_image_icon"] as? String{
                if likeCommentContentType == "album" {
                   
                let ImageView = createButton(CGRect(x: 0,y: 0,width: self.reactionShow.frame.size.width, height: self.reactionShow.frame.size.height), title: "", border: false, bgColor: false, textColor: textColorLight)
//                let padding = (ImageView.frame.width-25)/2
//                ImageView.imageEdgeInsets = UIEdgeInsets(top: 7.5, left: padding, bottom: 7.5, right: padding)
                //ImageView.tag = 300
//                let imageUrl = myIcon
//                let url = NSURL(string:imageUrl)
//                ImageView.kf.setImage(with: url as URL?, for: .normal, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
//
//                })
                let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(Like_CommentView.longPressed(sender:)))
                ImageView.addTarget(self, action: #selector(Like_CommentView.like_unLikeAction(_:)), for: .touchUpInside)
                ImageView.tag = 200
                ImageView.addGestureRecognizer(longPressRecognizer)
               // self.reactionShow.addSubview(ImageView)
                let menu = createButton(CGRect(x: 0,y: 0,width: self.reactionShow.frame.size.width, height: self.reactionShow.frame.size.height), title: " \(total_Likes)", border: false,bgColor: false, textColor: textColorMedium )
                let imageUrl = myIcon
                let url = NSURL(string:imageUrl)
                menu.kf.setImage(with: url as URL?, for: .normal, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                        
                    })
                let padding = (menu.frame.width-25)/2
                menu.imageEdgeInsets = UIEdgeInsets(top: 12.5, left: padding, bottom: 12.5, right: padding)
                menu.addTarget(self, action: #selector(Like_CommentView.like_unLikeAction(_:)), for: UIControl.Event.touchUpInside)
                
                menu.addGestureRecognizer(longPressRecognizer)
                menu.tag = 200
                //menu.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
                menu.titleLabel?.font = UIFont(name: fontName, size: FONTSIZENormal+1)
                //menu.titleLabel?.adjustsFontSizeToFitWidth = true
               // menu.titleEdgeInsets.left = padding
                menu.titleLabel?.textColor = navColor
                menu.titleEdgeInsets.top = 4
                menu.titleEdgeInsets.left = -6
                menu.setTitleColor(navColor , for: UIControl.State())
                self.reactionShow.addSubview(menu)
            }
                else {
                    let ImageView = createButton(CGRect(x: width/2 - 25,y: 7,width: 25,height: 25), title: "", border: false, bgColor: false, textColor: textColorLight)
                    ImageView.imageEdgeInsets =  UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
                    ImageView.tag = 300
                    let imageUrl = myIcon
                    let url = NSURL(string:imageUrl)
                    ImageView.kf.setImage(with: url as URL?, for: .normal, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                        
                    })
                    self.reactionShow.addSubview(ImageView)
                    let menu = createButton(CGRect(x: width/2, y: 0, width: self.reactionShow.frame.size.width - (width/2),height: self.reactionShow.frame.size.height), title: " \(title)", border: false,bgColor: false, textColor: textColorMedium )
                    menu.addTarget(self, action: #selector(Like_CommentView.like_unLikeAction(_:)), for: UIControl.Event.touchUpInside)
                    let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(Like_CommentView.longPressed(sender:)))
                    menu.addGestureRecognizer(longPressRecognizer)
                    menu.tag = 200
                    menu.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
                    menu.titleLabel?.font = UIFont(name: fontName, size: FONTSIZENormal)
                    menu.titleLabel?.adjustsFontSizeToFitWidth = true
                    menu.titleLabel?.textColor = navColor
                    menu.setTitleColor(navColor , for: UIControl.State())
                    self.reactionShow.addSubview(menu)
                }
            }
            
        }
        else
        {
            if likeCommentContentType == "album" {
                for ob in self.reactionShow.subviews {
                    if ob.tag == 200 {
                        ob.removeFromSuperview()
                    }
                }
                let    menu = createButton(CGRect(x: 0,y: 0,width: self.reactionShow.frame.size.width, height: self.reactionShow.frame.size.height), title: "", border: false,bgColor: false, textColor: iconColor)
                menu.setImage(UIImage(named: "likeIcon"), for: .normal)
                let padding = (menu.frame.width-25)/2
                menu.imageEdgeInsets = UIEdgeInsets(top: 12.5, left: padding, bottom: 12.5, right: padding)
               // menu.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
                menu.addTarget(self, action: #selector(Like_CommentView.like_unLikeAction(_:)), for: UIControl.Event.touchUpInside)
                if total_Likes > 0 {
                    menu.setTitle("\(total_Likes)", for: .normal)
                }
                menu.tag = 200
                menu.titleLabel?.font = UIFont(name: fontName, size: FONTSIZENormal+1)
                menu.titleLabel?.adjustsFontSizeToFitWidth = true
                menu.titleLabel?.textColor = iconColor
               // menu.setTitleColor(navColor , for: UIControl.State())
               // menu.setTitle(String(format: NSLocalizedString("%@ Like", comment: ""), likeIcon), for: UIControl.State())
                //menu.setTitleColor(textColorMedium , for: UIControl.State())
                let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(Like_CommentView.longPressed(sender:)))
                menu.addGestureRecognizer(longPressRecognizer)
                menu.titleEdgeInsets.top = 4
                menu.titleEdgeInsets.left = 9
                self.reactionShow.addSubview(menu)
            }
            else {
            let    menu = createButton(CGRect(x: 0,y: 0,width: self.reactionShow.frame.size.width, height: self.reactionShow.frame.size.height), title: NSLocalizedString("\(likeIcon)", comment: ""), border: false,bgColor: false, textColor: textColorLight)
            menu.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
            menu.addTarget(self, action: #selector(Like_CommentView.like_unLikeAction(_:)), for: UIControl.Event.touchUpInside)
            menu.titleLabel?.textColor = textColorMedium
            menu.tag = 200
            menu.setTitle(String(format: NSLocalizedString("%@ Like", comment: ""), likeIcon), for: UIControl.State())
            menu.titleLabel?.textColor = textColorMedium
            menu.setTitleColor(textColorMedium , for: UIControl.State())
            let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(Like_CommentView.longPressed(sender:)))
            menu.addGestureRecognizer(longPressRecognizer)
            self.reactionShow.addSubview(menu)
            }
        }
         if ReactionPlugin == true{
        if let reactions = self.likeCommentViewer[0].feed_reaction{
            reactionsIcon.removeAll(keepingCapacity: false)
            var i = 0
            
            for (_,v) in reactions
            {
                let tempValueDic = v as! NSDictionary
                if i <= 2{
                    if let icon = tempValueDic["reaction_image_icon"] as? String{
                        reactionsIcon.append(icon as AnyObject)
                        
                    }
                    
                }
                i = i + 1
            }
            
            
        }
        }
        if logoutUser == false{
            reactionShow.isHidden = false
            comment.isHidden = false
        }
        else{
            reactionShow.isHidden = true
            comment.isHidden = true
        }
        
        var finalText = ""
        finalText = "\(total_Likes) \(likeIcon)"
        finalText += " / "
        finalText += "\(total_Comments) \(commentIcon)"
        info.text = finalText
    }
    
    // View of all possible reactions that we can like
    func browseEmojis(contentItems: NSDictionary)
    {
        scrollviewEmojiLikeView.backgroundColor = .clear
        arrowView.backgroundColor = .clear
        for ob in scrollviewEmojiLikeView.subviews{
            ob.removeFromSuperview()
            arrowView.removeFromSuperview()
        }
        // var allReactionsValueDic = Dictionary<String, AnyObject>() // sorted Reaction Dictionary
        if let allReactionsValueDic = sortedReactionDictionary(dic: contentItems) as? Dictionary<String, AnyObject>
        {
//            let iconHeight = 42
//            let space = 9
//            let viewWidth = (6 * iconHeight) + space*(6-1) + space*3 + 6
//            let viewHeight = iconHeight + (2*space)
            
            let space:CGFloat = 15
            let vSpace:CGFloat = 9
            let viewWidth = self.frame.width - 12
            let iconHeight = (viewWidth/6) - (space*7)/6
            let viewHeight = iconHeight + (2*vSpace)
            scrollviewEmojiLikeView.frame = CGRect(x:0,y: 0,width: viewWidth ,height: viewHeight)
            arrowView.frame = CGRect(x: 0, y: 0, width: 14, height: 10)
            scrollviewEmojiLikeView.backgroundColor = UIColor.black.withAlphaComponent(0.85)//UIColor.clear
            arrowView.backgroundColor = UIColor.black.withAlphaComponent(0.85)
            //                scrollViewEmoji.layer.borderWidth = 2.0
            //                scrollViewEmoji.layer.borderColor = aafBgColor.cgColor  //UIColor.red.cgColor //tableViewBgColor.cgColor
            scrollviewEmojiLikeView.layer.cornerRadius = CGFloat(viewHeight/2)
            var menuWidth = CGFloat()
            var origin_x:CGFloat = 15
            var i : Int = 0
            for key in allReactionsValueDic.keys.sorted(by: <) {
                if let   v = allReactionsValueDic[key]
                {
                    if let icon = v["icon"] as? NSDictionary{
                        
                        menuWidth = iconHeight
                        let   emoji = createButton(CGRect(x: origin_x,y: vSpace,width: iconHeight,height: iconHeight), title: "", border: false, bgColor: false, textColor: textColorLight)
                        emoji.addTarget(self, action: #selector(Like_CommentView.feedMenuReactionLikes(sender:)), for: .touchUpInside)
                        emoji.tag = v["reactionicon_id"] as? Int ?? 0
                        if let imageUrl = icon["reaction_image_large_icon"] as? String
                        {
                            let url = NSURL(string:imageUrl)
                            if url != nil
                            {
                                emoji.kf.setImage(with: url as URL?, for: .normal, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                                })
                            }
                        }
                        scrollviewEmojiLikeView.addSubview(emoji)
                        origin_x = origin_x + menuWidth  + space
                        i = i + 1
                    }
                    
                }
            }
            
            scrollviewEmojiLikeView.contentSize = CGSize(width: origin_x, height: CGFloat(viewHeight))
            scrollviewEmojiLikeView.bounces = false
            scrollviewEmojiLikeView.isUserInteractionEnabled = true
            scrollviewEmojiLikeView.showsVerticalScrollIndicator = false
            scrollviewEmojiLikeView.showsHorizontalScrollIndicator = false
            scrollviewEmojiLikeView.alwaysBounceHorizontal = true
            scrollviewEmojiLikeView.alwaysBounceVertical = false
            scrollviewEmojiLikeView.isDirectionalLockEnabled = true;
            scrollviewEmojiLikeView.isHidden = true
            arrowView.isHidden = true
        }
    }

    func animateReaction() {
        arrowView.isHidden = true
        let frame = CGRect(x: 0, y: 0, width: 70, height: 70)
        var image = UIImage()
        if isLikePost {
           image = likeIconImage
            isLikePost = false
        }
        else {
            image = (reactionButtonImage.imageView?.image)!
        }
        let imageView = UIImageView(frame: frame)
        imageView.image = image
        imageView.isHidden = false
        imageView.center = (parentViewController()?.view.center)!
        parentViewController()?.view.addSubview(imageView)
        parentViewController()?.view.bringSubviewToFront(imageView)
        imageView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 1.5, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 10.0, options: UIView.AnimationOptions.allowUserInteraction, animations: {
            imageView.transform = .identity
        }, completion: { (_) in
            imageView.isHidden = true
            imageView.removeFromSuperview()
        }
        )
    }
    
    // When click on Particular Reactions
    @objc func feedMenuReactionLikes(sender:UIButton){
        reactionButtonImage = sender
        animateReaction()
        var reaction = ""
        for (_,v) in reactionsDictionary
        {
            var updatedDictionary = Dictionary<String, AnyObject>()
            let v = v as! NSDictionary
            if  let reactionId = v["reactionicon_id"] as? Int
            {
                if reactionId == sender.tag
                {
                    reaction = (v["reaction"] as? String)!
                    updatedDictionary["reactionicon_id"] = v["reactionicon_id"]  as AnyObject?
                    updatedDictionary["caption" ] = v["caption"]  as AnyObject?
                    if let icon  = v["icon"] as? NSDictionary{
                        updatedDictionary["reaction_image_icon"] = icon["reaction_image_icon"]  as AnyObject?
                    }
                    updatedDictionary["reaction"] =  v["reaction"]  as AnyObject?
                    updatedDictionary["order"] =  v["order"]  as AnyObject?
                    var url = ""
                    url = "advancedcomments/like"
                    DispatchQueue.main.async(execute: {
                        soundEffect("Like")
                    })
                    updateReactions(url: url,reaction : reaction,subject_id  : likeCommentContent_id, updateMyReaction : updatedDictionary as NSDictionary,feedIndex: scrollviewEmojiLikeView.tag,subject_type : likeCommentContentType,updateType : "update")
                }
            }
        }
    }
    
    // UpdateReactions when like or unlike or React
    func updateReactions(url : String,reaction : String,subject_id : String,updateMyReaction : NSDictionary,feedIndex: Int,subject_type : String,updateType : String){
        var dic = Dictionary<String, String>()
        let updateTypeString = updateType
        scrollviewEmojiLikeView.isHidden = true
        for (index,value) in self.likeCommentViewer.enumerated(){
            let newDictionary:NSMutableDictionary = [:]
            newDictionary["reactions"] = value.reactions
            newDictionary["isLike"] = value.is_like
            newDictionary["totalComments"] = value.comments_count
            newDictionary["canComment"] = value.canComment
            let changedDictionary : NSMutableDictionary = [:]
            changedDictionary.removeAllObjects()
            switch(updateTypeString) {
                
            case  "update" :
                var addDictionary : Bool! = false
                newDictionary["totalLikes"] = value.likes_count
                let tempchangedDictionary : NSMutableDictionary = [:]
                // when already like just need to replace
                let is_like = (self.likeCommentViewer[0].is_like)
                if  is_like == true
                {
                    self.isLike = value.is_like
                    addDictionary = true
                    let myReaction = (self.likeCommentViewer[0].my_feed_reaction)
                    if (myReaction?.count)! > 0{
                        let reactionId = myReaction?["reactionicon_id"] as? Int
                        let feedReaction  = (self.likeCommentViewer[0].feed_reaction)
                        if (self.likeCommentViewer[0].feed_reaction) != nil{
                            if (feedReaction?.count)! > 0{
                                // remove  reaction that is already liked from feed_reaction Dictionary
                                for(k,v) in feedReaction!{
                                    let dicValue = v as! NSDictionary
                                    let currentId = Int((k as! String))
                                    
                                    if reactionId == currentId{
                                        if let countOfFeed = dicValue["reaction_count"] as? Int {
                                            if countOfFeed != 1 {
                                                if let dic = v as? NSDictionary{
                                                    var dict = Dictionary<String, AnyObject>()
                                                    for (key, value) in dic{
                                                        if key as! String == "reaction_count"
                                                        {
                                                            dict["reaction_count"] = (value as! Int - 1) as AnyObject?
                                                        }
                                                        else{
                                                            dict["\(key)"] = value as AnyObject?
                                                        }
                                                    }
                                                    tempchangedDictionary["\(k)"] = dict
                                                }
                                            }
                                        }
                                    }
                                    else{
                                        tempchangedDictionary["\(k)"] = v
                                    }
                                }
                                // add reaction that you like in feed_reaction Dictionary
                                for(k,v) in tempchangedDictionary{
                                    let idReaction : Int = updateMyReaction["reactionicon_id"] as! Int
                                    let currentId = Int((k as! String))
                                    if currentId == idReaction {
                                        addDictionary = false
                                        var dict = Dictionary<String, AnyObject>()
                                        if let dic = v as? NSDictionary{
                                            for (key, value) in dic{
                                                if key as! String == "reaction_count" {
                                                    dict["reaction_count"] = ((value as! Int) + 1) as AnyObject
                                                }
                                                else{
                                                    dict["\(key)"] = value as AnyObject?
                                                }
                                            }
                                            changedDictionary["\(k)"] = dict
                                        }
                                    }
                                    else{
                                        changedDictionary["\(k)"] = v
                                    }
                                }
                            }
                        }
                    }
                }
                    // when not liked before
                else
                {
                    addDictionary = true
                    newDictionary["totalLikes"] = value.likes_count! + 1
                    newDictionary["isLike"] = true
                    self.isLike = true
                    if (self.likeCommentViewer[0].feed_reaction) != nil{
                        let  reactions = (self.likeCommentViewer[0].feed_reaction)
                        if (reactions?.count)! > 0{
                            // if reaction that we like alredy exist in feed_reaction then increase count value else addDictionary must be true
                            for(k,v) in reactions!{
                                let idReaction : Int = updateMyReaction["reactionicon_id"] as! Int
                                let currentId = Int((k as! String))
                                if currentId == idReaction {
                                    addDictionary = false
                                    var dict = Dictionary<String, AnyObject>()
                                    if let dic = v as? NSDictionary{
                                        for (key, value) in dic{
                                            if key as! String == "reaction_count" {
                                                dict["reaction_count"] = ((value as! Int) + 1) as AnyObject
                                            }
                                            else{
                                                dict["\(key)"] = value as AnyObject?
                                            }
                                        }
                                        changedDictionary["\(k)"] = dict
                                    }
                                }
                                else{
                                    changedDictionary["\(k)"] = v
                                }
                            }
                        }
                    }
                }
                if addDictionary == true{
                    var dict2 = Dictionary<String, AnyObject>()
                    for (k,v) in updateMyReaction{
                        dict2["\(k)"] = v as AnyObject?
                    }
                    dict2["reaction_count"] = 1 as AnyObject?
                    changedDictionary["\(updateMyReaction["reactionicon_id"]!)"] = dict2
                }
                
            case  "delete" :
                newDictionary["totalLikes"] = value.likes_count! - 1
                let tempLike =  (self.likeCommentViewer[0].is_like)
                if(tempLike == true)
                {
                    newDictionary["isLike"] = false
                    self.isLike = false
                    let  reactions = (self.likeCommentViewer[0].feed_reaction)
                    for(k,v) in reactions!
                    {
                        let dicValue = v as! NSDictionary
                        let currentId = Int((k as! String))
                        if (self.likeCommentViewer[0].my_feed_reaction) != nil{
                            let  myReaction = (self.likeCommentViewer[0].my_feed_reaction)
                            if (myReaction?.count)! > 0
                            {
                                if let reactionId = myReaction?["reactionicon_id"] as? Int
                                {
                                    if reactionId == currentId
                                    {
                                        if let countOfFeed = dicValue["reaction_count"] as? Int {
                                            if countOfFeed != 1
                                            {
                                                if let dic = v as? NSDictionary
                                                {
                                                    var dict = Dictionary<String, AnyObject>()
                                                    for (key, value) in dic
                                                    {
                                                        if key as! String == "reaction_count"
                                                        {
                                                            dict["reaction_count"] = (value as! Int - 1) as AnyObject?
                                                        }
                                                        else
                                                        {
                                                            dict["\(key)"] = value as AnyObject?
                                                            
                                                        }
                                                    }
                                                    changedDictionary["\(k)"] = dict
                                                }
                                            }
                                        }
                                    }
                                    else
                                    {
                                        changedDictionary["\(k)"] = v
                                        
                                    }
                                }
                            }
                            else
                            {
                                changedDictionary["\(k)"] = v
                                
                            }
                        }
                        else
                        {
                            changedDictionary["\(k)"] = v
                            
                        }
                    }
                }
            default:
                print("default")
                
            }
            
            newDictionary["my_feed_reaction"] = updateMyReaction
            newDictionary["feed_reactions"] = changedDictionary
            var newData = LikeCommentView.loadPhotosInfoDictionary(newDictionary)
            self.likeCommentViewer[index] = newData[0] as LikeCommentView
            
            
        }
        self.uiForLike()
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
            dic["reaction"] = "\(reaction)"
            dic["subject_id"] = "\(subject_id)"
            dic["subject_type"] = "\(subject_type)"
            dic["sendNotification"] = "\(0)"
            userInteractionOff = false
            // Send Server Request to Update Feed Gutter Menu
            post(dic, url: "\(url)", method: "POST") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    userInteractionOff = true
                    if msg{
                        // On Success Update Feed Gutter Menu
                        
                        var url = ""
                        url = "advancedcomments/send-like-notitfication"
                        if Reachabable.isConnectedToNetwork() {

                            removeAlert()
                            post(dic, url: "\(url)", method: "POST") { (succeeded, msg) -> () in
                                DispatchQueue.main.async(execute:{
                                    userInteractionOff = true
                                })
                            }
                        }
                        else{
                            // No Internet Connection Message
                            UIApplication.shared.keyWindow?.makeToast(network_status_msg, duration: 5, position: "bottom")
                        }

                    }
                })
            }
        }
        else
        {
            UIApplication.shared.keyWindow?.makeToast(network_status_msg, duration: 5, position: "bottom")
        }
    }
    
    // when press long on like then show view of all reactions
//    @objc func longPressed(sender: UILongPressGestureRecognizer)
//    {
//        let  Currentcell = (sender.view?.tag)!
//        let tapLocation = sender.location(in: self)
//         if sender.state == .began {
//            soundEffect("reactions_popup")
//            scrollviewEmojiLikeView.frame.origin.x =  tapLocation.x
//            scrollviewEmojiLikeView.frame.origin.y = (parentViewController()?.view.bounds.height )! - (tabBarHeight + self.frame.size.height + scrollviewEmojiLikeView.frame.size.height + 10)
//            scrollviewEmojiLikeView.alpha = 0
//            scrollviewEmojiLikeView.isHidden = false
//            scrollviewEmojiLikeView.tag =  Currentcell
//            parentViewController()?.view.removeGestureRecognizer(sender)
//            parentViewController()?.view.addSubview(scrollviewEmojiLikeView)
//            UIView.animate(withDuration: 0.5, delay: 0.4, options: .curveEaseOut, animations: {
//                scrollviewEmojiLikeView.alpha = 1
//            }, completion: nil)
//        }
//    }
//    
    
    @objc func longPressed(sender: UILongPressGestureRecognizer)
    {
        arrowView.layer.shadowColor = UIColor.black.cgColor
        arrowView.layer.borderColor = UIColor.black.cgColor
        //scrollviewEmojiLikeView.backgroundColor = UIColor.black.withAlphaComponent(0.85)//UIColor.clear
        arrowView.backgroundColor = UIColor.black.withAlphaComponent(0.85)
        arrowView.transform = .identity
        let  Currentcell = (sender.view?.tag)!
        let tapLocation = sender.location(in: self)
        if sender.state == .began {
            soundEffect("reactions_popup")
            scrollviewEmojiLikeView.center = (parentViewController()?.view.center)!
            if likeCommentContentType == "album" {
                let tap = sender.location(in: parentViewController()?.view)
                print("taplocation--\(tapLocation.y )")
                scrollviewEmojiLikeView.frame.origin.y = tap.y - scrollviewEmojiLikeView.frame.size.height - 30
                arrowView.frame.origin = CGPoint(x: scrollviewEmojiLikeView.frame.origin.x + 45, y: getBottomEdgeY(inputView: scrollviewEmojiLikeView) - 2)
            }
            else {
                scrollviewEmojiLikeView.frame.origin.y = (parentViewController()?.view.bounds.height )! - (tabBarHeight + self.frame.size.height + scrollviewEmojiLikeView.frame.size.height + 10)
                arrowView.frame.origin = CGPoint(x: scrollviewEmojiLikeView.frame.origin.x + 30, y: getBottomEdgeY(inputView: scrollviewEmojiLikeView) - 2)
            }
            
            arrowView.alpha = 0
            arrowView.tag = Currentcell
            scrollviewEmojiLikeView.alpha = 0
            scrollviewEmojiLikeView.isHidden = false
            scrollviewEmojiLikeView.tag =  Currentcell
            parentViewController()?.view.removeGestureRecognizer(sender)
            parentViewController()?.view.addSubview(scrollviewEmojiLikeView)
            parentViewController()?.view.addSubview(arrowView)
            
            let stackView = scrollviewEmojiLikeView.subviews.reversed()
            stackView.forEach({ (emoji) in
                emoji.alpha = 0
                emoji.transform = CGAffineTransform(translationX: -100, y: emoji.frame.origin.y)
            })

            scrollviewEmojiLikeView.transform = CGAffineTransform(translationX: 0, y: tapLocation.y)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                scrollviewEmojiLikeView.alpha = 1
                scrollviewEmojiLikeView.transform = .identity
                
            }, completion: { (_) in
                arrowView.alpha = 1
                arrowView.isHidden = false
            }
            )
            
            
            UIView.animate(withDuration:0.3, animations: {
                let stackView = scrollviewEmojiLikeView.subviews.reversed()
                stackView.forEach({ (emoji) in
                    
                    emoji.alpha = 1
                    emoji.transform = .identity
                })
            }) { (_) in
                //
            }



        }
        
    }
    
    
//    @objc func longPressed(sender: UILongPressGestureRecognizer)
//    {
//        //        let imageView = UIImageView()
//        //        view.willRemoveSubview(imageView)
//        //        imageView.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
//        //        view.addSubview(imageView)
//        //        imageView.image = #imageLiteral(resourceName: "arrow.png")
//        //        imageView.alpha = 0
//        let  Currentcell = (sender.view?.tag)!
//        let tapLocation = sender.location(in: self.view)
//        scrollViewEmoji.center.x = view.center.x
//        //        imageView.layer.borderWidth = 2.0
//        //        imageView.layer.borderColor = aafBgColor.cgColor  //UIColor.red.cgColor //tableViewBgColor.cgColor
//        //        imageView.layer.cornerRadius = scrollViewEmoji.frame.height/2
//        if sender.state == .began {
//            soundEffect("reactions_popup")
//            scrollViewEmoji.frame.origin.y = tapLocation.y - 90
//            if tableViewFrameType == "CommentsViewController"
//            {
//                UIApplication.shared.keyWindow?.removeGestureRecognizer(sender)
//                //window?.removeGestureRecognizer(sender)
//            }
//            else
//            {
//                view.removeGestureRecognizer(sender)
//            }
//
//            let stackView = scrollViewEmoji.subviews.reversed()
//            stackView.forEach({ (emoji) in
//                emoji.alpha = 0
//                emoji.transform = CGAffineTransform(translationX: -100, y: emoji.frame.origin.y)
//            })
//            arrowView.alpha = 0
//            arrowView.frame.origin = CGPoint(x: scrollViewEmoji.frame.origin.x + 30, y: getBottomEdgeY(inputView: scrollViewEmoji) - 2)
//            arrowView.alpha = 0
//            arrowView.tag = Currentcell
//            scrollViewEmoji.alpha = 0
//            scrollViewEmoji.isHidden = false
//            scrollViewEmoji.tag =  Currentcell
//            view.addSubview(scrollViewEmoji)
//            view.addSubview(arrowView)
//            //            imageView.frame.origin = CGPoint(x: scrollViewEmoji.frame.origin.x + 25, y: getBottomEdgeY(inputView: scrollViewEmoji) - 5)
//            //            imageView.transform = CGAffineTransform(translationX: getRightEdgeX(inputView: scrollViewEmoji) + 20, y: getBottomEdgeY(inputView: scrollViewEmoji) + 10)
//            scrollViewEmoji.transform = CGAffineTransform(translationX: 0, y: tapLocation.y)
//            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
//                scrollViewEmoji.alpha = 1
//                scrollViewEmoji.transform = .identity
//            }, completion: { (_) in
//                arrowView.alpha = 1
//                arrowView.isHidden = false
//            }
//            )
//
//
//            UIView.animate(withDuration:0.5, animations: {
//                let stackView = scrollViewEmoji.subviews.reversed()
//                stackView.forEach({ (emoji) in
//
//                    emoji.alpha = 1
//                    emoji.transform = .identity
//                })
//            }) { (_) in
//                //
//            }
//        }
//
//
//
//    }
    
    
    
    // remove reactions view
    func removeEmoji(recognizer: UITapGestureRecognizer){
        scrollviewEmojiLikeView.isHidden = true
        parentViewController()?.view.removeGestureRecognizer(recognizer)
    }
    
    // MARK: Finish code for when Reaction Plugin is enabled
    
    @objc func shareAction(){
        
    }
    
    // Handle Menu Action
    @objc func showMenu(){
        // Generate Blog Menu Come From Server as! Alert Popover
        (self.parentViewController() as! AdvancePhotoViewController).deletePhoto = false
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        for menuItem in myMenu{
            if let dic = menuItem as? NSDictionary{
                alertController.addAction(UIAlertAction(title: (dic["label"] as! String), style: .default, handler:{ (UIAlertAction) -> Void in
                    // Change Here For Edit
                    if dic["name"] as! String ==  "edit"{
                        let presentedVC = EditPhotoViewController()
                        presentedVC.parameters = dic["urlParams"] as! NSDictionary
                        presentedVC.url = dic["url"] as! String
                        presentedVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                        let nativationController = UINavigationController(rootViewController: presentedVC)
                        self.parentViewController()?.present(nativationController, animated:true, completion: nil)
                        
                    }
                    // Change Here For Delete
                    if dic["name"] as! String == "delete"{
                        
                        // Confirmation Alert
                        displayAlertWithOtherButton(NSLocalizedString("Delete Group Photo",  comment: ""),message: NSLocalizedString("Are you sure you want to delete this photo?",  comment: "") , otherButton: NSLocalizedString("Delete Photo",  comment: "")) { () -> () in
                            (self.parentViewController() as! AdvancePhotoViewController).deletePhoto = true
                            (self.parentViewController() as! AdvancePhotoViewController).updatePhoto(dic["urlParams"] as! NSDictionary, url:dic["url"] as! String )
                        }
                        self.parentViewController()?.present(alert, animated: true, completion: nil)
                        
                    }
                    
                    // Report this Blog
                    if dic["name"] as! String == "report"{
                        let presentedVC = ReportContentViewController()
                        presentedVC.param = (dic["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                        presentedVC.url = dic["url"] as! String
                        self.parentViewController()?.navigationController?.pushViewController(presentedVC, animated: true)
                        
                    }
                    // Subscribe/Unsubscribe this Blog
                    
                    if dic["name"] as! String == "make_profile_photo" {
                        displayAlertWithOtherButton(NSLocalizedString("Make Profile message: Photo",  comment: ""),message: NSLocalizedString("Do you want to make this photo your profile phootherButton: to?",  comment: "") , otherButton: NSLocalizedString("Save",  comment: "")) { () -> () in
                            (self.parentViewController() as! AdvancePhotoViewController).updatePhoto(dic["urlParams"] as! NSDictionary, url:dic["url"] as! String )
                        }
                        self.parentViewController()?.present(alert, animated: true, completion: nil)
                    }
                    
                }))
            }
        }
        
        
        if  (UIDevice.current.userInterfaceIdiom == .phone){
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel",  comment: ""), style: .cancel, handler:nil))
        }else{
            // Present Alert as! Popover for iPad
            alertController.modalPresentationStyle = UIModalPresentationStyle.popover
            let popover = alertController.popoverPresentationController
            popover?.sourceView = UIButton()
            popover?.sourceRect = CGRect(x: 40, y: 3.5*self.bounds.width/5, width: 0, height: 0)
            popover?.permittedArrowDirections = UIPopoverArrowDirection.down
        }
        self.parentViewController()?.present(alertController, animated:true, completion: nil)
        
        
    }
    
    // Open CommentsViewController on Tapping Comment
    @objc func commentAction(_ sender:UIButton)
    {
        if likeCommentContentType == "sitevideo_channel"
        {
            subscribe_unsubscribeAction()
            
        }
        else
        {
            if let parentVC = self.parentViewController(){
                let presentedVC = CommentsViewController()
                presentedVC.openCommentTextView = 1//sender.tag
                presentedVC.pushFlag = true
                presentedVC.commentPermission = canComment
                presentedVC.activityFeedComment = false
                presentedVC.reactionsIcon = reactionsIcon
                presentedVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                let navigationController = UINavigationController(rootViewController: presentedVC)
                navigationController.modalPresentationStyle = .fullScreen
                parentVC.present(navigationController, animated: true, completion: nil)
            }
        }
    }
    @objc func commentAction1(_ sender:UIButton)
    {
        if let parentVC = self.parentViewController(){
            let presentedVC = CommentsViewController()
            presentedVC.openCommentTextView = 1//sender.tag
            presentedVC.pushFlag = true
            presentedVC.commentPermission = canComment
            presentedVC.activityFeedComment = false
             presentedVC.reactionsIcon = reactionsIcon
            presentedVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            let navigationController = UINavigationController(rootViewController: presentedVC)
            navigationController.modalPresentationStyle = .fullScreen
            parentVC.present(navigationController, animated: true, completion: nil)
        }
    }
    
    // MARK: - Server Connection For Update Like & Comments
    
    // Like/Unlike Action
    @objc func like_unLikeAction(_ sender:UIButton){
        arrowView.isHidden = true
        scrollviewEmojiLikeView.isHidden = true
        DispatchQueue.main.async(execute: {
            soundEffect("Like")
        })
        if self.isLike != nil {
            if self.isLike == true{
                if ReactionPlugin == false{
                    if like_CommentStyle == 2{
                        animationEffectOnButton(sender)
                        self.like.titleLabel?.textColor = textColorLight
                        self.like.setTitleColor(textColorLight , for: UIControl.State())
                        self.like.isEnabled = false
                    }
                    else{
                        animationEffectOnButton(sender)
                        self.like.titleLabel?.textColor = textColorMedium
                        self.like.setTitleColor(textColorMedium , for: UIControl.State())
                        self.like.isEnabled = false
                    }
                }
            }
            else{
                if ReactionPlugin == false{
                    animationEffectOnButton(sender)
                    self.like.titleLabel?.textColor = navColor
                    self.like.setTitleColor(navColor , for: UIControl.State())
                    self.like.isEnabled = false
                }
            }
            if ReactionPlugin == true{
                if self.isLike == false{
                    // updateReaction
                    var reaction = ""
                    for (k,v) in reactionsDictionary
                    {
                        let v = v as! NSDictionary
                        var updatedDictionary = Dictionary<String, AnyObject>()
                        if  (v["reactionicon_id"] as? Int) != nil
                        {
                            if k as! String == "like"
                            {
                                isLikePost = true
                                animateReaction()
                                reaction = (v["reaction"] as? String)!
                                updatedDictionary["reactionicon_id"] = v["reactionicon_id"]  as AnyObject?
                                updatedDictionary["caption" ] = v["caption"]  as AnyObject?
                                if let icon  = v["icon"] as? NSDictionary{
                                    updatedDictionary["reaction_image_icon"] = icon["reaction_image_icon"] as! String as AnyObject?
                                }
                                var url = ""
                                if enabledModules.contains("nestedcomment") {
                                    url = "advancedcomments/like"
                                }
                                else {
                                    url = "like"
                                }
                                DispatchQueue.main.async(execute:  {
                                    soundEffect("Like")
                                })
                                updateReactions(url: url,reaction : reaction,subject_id  : likeCommentContent_id, updateMyReaction : updatedDictionary as NSDictionary,feedIndex: scrollviewEmojiLikeView.tag,subject_type : likeCommentContentType,updateType : "update")
                            }
                        }
                    }
                }
                else{
                    // delete Reaction
                    let reaction = ""
                    var updatedDictionary = Dictionary<String, AnyObject>()
                    updatedDictionary = [ : ]
                    var url = ""
                    url = "unlike"
                    DispatchQueue.main.async(execute:  {
                        soundEffect("Like")
                    })
                    updateReactions(url: url,reaction : reaction,subject_id  : likeCommentContent_id, updateMyReaction : updatedDictionary as NSDictionary,feedIndex: sender.tag,subject_type : likeCommentContentType,updateType : "delete")
                }
            }
            else{
                // Check Internet Connection
                if Reachabable.isConnectedToNetwork() {
                    removeAlert()
                    var path = ""
                    // Set path for Like & UnLike
                    if self.isLike == true{
                        path = "unlike"
                    }else{
                        path = "like"
                    }
                    // Send Server Request to Like/Unlike Content
                    post(["subject_id":String(likeCommentContent_id), "subject_type": likeCommentContentType], url: path, method: "POST") {
                        (succeeded, msg) -> () in
                        self.like.isEnabled = true
                        DispatchQueue.main.async(execute: {
                            if msg{
                                // On Success Update
                                if succeeded["message"] != nil{
                                    
                                    
                                    if(self.isLike == true){
                                        self.isLike = false
                                        total_Likes = total_Likes - 1
                                        self.like.setTitle(likeIcon, for: UIControl.State())
                                        if like_CommentStyle == 2 {
                                            self.like.titleLabel?.textColor = textColorLight
                                            self.like.setTitleColor(textColorLight, for: UIControl.State())
                                            self.like.setTitle("\(likeIcon)", for: UIControl.State())
                                            self.like.isEnabled = true
                                        }else{
                                            self.like.titleLabel?.textColor = textColorMedium
                                            self.like.setTitle("\(likeIcon) Like", for: UIControl.State())
                                            self.like.titleLabel?.textColor = textColorMedium
                                            self.like.setTitleColor(textColorMedium , for: UIControl.State())
                                            self.like.isEnabled = true
                                        }
                                    }
                                    else
                                    {

                                        self.isLike = true
                                        total_Likes = total_Likes + 1
                                        if like_CommentStyle == 2 {
                                            self.like.titleLabel?.textColor = navColor
                                            self.like.setTitleColor(navColor, for: UIControl.State())
                                            self.like.setTitle("\(likeIcon)", for: UIControl.State())
                                            self.like.isEnabled = true
                                        }else{
                                            //
                                            self.like.setTitle("\(likeIcon) Like", for: UIControl.State())
                                            self.like.titleLabel?.textColor = navColor
                                            self.like.setTitleColor(navColor , for: UIControl.State())
                                            self.like.isEnabled = true
                                        }
                                        
                                        
                                    }
                                    
                                    var finalText = ""
                                    finalText = "\(total_Likes) \(likeIcon)"
                                    finalText += " / "
                                    finalText += "\(total_Comments) \(commentIcon)"
                                    info.text = finalText
                                }
                                
                                if  likeCommentContentType == "photo"{
                                    feedUpdate = true
                                }
                                
                            }else{
                                // Handle Server Side Error
                                if succeeded["message"] != nil{
                                    displayAlert("Info", error: (succeeded["message"] as! String))
                                    if let parentVC = self.parentViewController(){
                                        parentVC.present(alert, animated: true, completion: nil)
                                    }
                                }
                                
                            }
                        })
                    }
                }else{
                    // No Internet Connection Message
                    displayAlert("Info", error: network_status_msg)
                    
                    if let parentVC = self.parentViewController(){
                        showCustomAlert(parentVC.view.center, msg: network_status_msg)
                        // parentVC.presentViewController(alert, animated: true, completion: nil)
                    }
                    
                }
            }
        }
        
    }
    
    func findLikeComments(){
        
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
            // Send Server Request to Get info of Total Likes & total Comments  Content
            post(["content_id": String(likeCommentContent_id), "content_type": likeCommentContentType], url: "/likes-comments", method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    if msg{
                        if succeeded["body"] != nil{
                            
                            self.isHidden = false
                            if let body = succeeded["body"] as? NSDictionary {
                                // On Success Get Total Likes & Total Comments
                                total_Comments = body["getTotalComments"] as! Int
                                total_Likes = body["getTotalLikes"] as! Int
                                self.canComment = body["canComment"] as! Int
                                // Set Updated Label Info
                                var finalText = ""
                                
                                finalText = "\(total_Likes) \(likeIcon)"
                                finalText += " / "
                                finalText += "\(total_Comments) \(commentIcon)"
                                info.text = finalText
                                
                                // Set Updated Label for like/unlike
                                self.isLike = body["isLike"] as! Bool
                                if self.isLike == false{
                                    if like_CommentStyle == 1 {
                                        self.like.titleLabel?.textColor = textColorMedium
                                        self.like.setTitle("\(likeIcon) Like", for: UIControl.State())
                                        self.like.titleLabel?.textColor = textColorMedium
                                        self.like.setTitleColor(textColorMedium , for: UIControl.State())
                                    }else if like_CommentStyle == 2 {
                                        self.like.titleLabel?.textColor = textColorLight
                                        self.like.setTitleColor(textColorLight, for: UIControl.State())
                                        self.like.setTitle("\(likeIcon)", for: UIControl.State())
                                    }else{
                                        
                                        self.like.setTitle(likeIcon, for: UIControl.State())
                                        self.like.titleLabel?.textColor = navColor
                                        self.like.setTitleColor(navColor, for: UIControl.State())
                                    }
                                    
                                }else{
                                    self.like.setTitle(likeIcon, for: UIControl.State())
                                    
                                    if like_CommentStyle == 1 {
                                        //self.like.titleLabel?.textColor = textColorMedium
                                        //
                                        self.like.setTitle("\(likeIcon) Like", for: UIControl.State())
                                        self.like.titleLabel?.textColor = navColor
                                        self.like.setTitleColor(navColor , for: UIControl.State())
                                    }
                                    else if like_CommentStyle == 2 {
                                        self.like.titleLabel?.textColor = navColor
                                        self.like.setTitleColor(navColor, for: UIControl.State())
                                        self.like.setTitle("\(likeIcon)", for: UIControl.State())
                                    }else{
                                        //
                                        self.like.setTitle(unlikeIcon, for: UIControl.State())
                                        self.like.titleLabel?.textColor = textColorMedium
                                        self.like.setTitleColor(textColorMedium, for: UIControl.State())
                                    }
                                    
                                    
                                }
                                
                            }
                            
                        }
                        
                        
                        
                        
                    }else{
                        // Handle Server Side Error
                        if succeeded["message"] != nil{
                            //                            displayAlert("Info", (succeeded["message"] as! String))
                            //                            if let parentVC = self.parentViewController(){
                            //                                parentVC.presentViewController(alert, animated: true, completion: nil)
                            //                            }
                        }
                        
                    }
                })
            }
        }
        else{
            // No Internet Connection Message
            displayAlert("Info", error: network_status_msg)
            if let parentVC = self.parentViewController(){
                showCustomAlert(parentVC.view.center, msg: network_status_msg)
                // parentVC.presentViewController(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    // MARK:- Subscriber information
    func subscribe_unsubscribeAction()
    {
            if issubscribe == 1
            {
                issubscribe = 0
                self.comment.titleLabel?.textColor = textColorMedium
                self.comment.setTitleColor(textColorMedium , for: UIControl.State())
                self.comment.isEnabled = false

            }
            else
            {
                issubscribe = 1
                self.comment.titleLabel?.textColor = navColor
                self.comment.setTitleColor(navColor , for: UIControl.State())
                self.comment.isEnabled = false
                
            }
                // Check Internet Connection
                if Reachabable.isConnectedToNetwork() {
                    removeAlert()
                    // Send Server Request to Like/Unlike Content
                    post(["value":String(issubscribe)], url: "advancedvideo/channel/channel-subscribe/" + String(likeCommentContent_id), method: "POST") {
                        (succeeded, msg) -> () in
                        DispatchQueue.main.async(execute: {
                            self.comment.isEnabled = true
                            if msg{
                                // On Success Update
                                if succeeded["message"] != nil
                                {

                                    var finalText = ""
                                    finalText = "\(total_Likes) \(likeIcon)"
                                    finalText += " / "
                                    finalText += "\(total_Comments) \(commentIcon)"
                                    info.text = finalText
                                }
                                
                            }
                            else
                            {
                                if issubscribe == 1
                                {
                                    issubscribe = 0
                                    self.comment.titleLabel?.textColor = textColorMedium
                                    self.comment.setTitleColor(textColorMedium , for: UIControl.State())
                                    self.comment.isEnabled = false
                                    
                                }
                                else
                                {
                                    issubscribe = 1
                                    self.comment.titleLabel?.textColor = navColor
                                    self.comment.setTitleColor(navColor , for: UIControl.State())
                                    self.comment.isEnabled = false
                                    
                                }
                                // Handle Server Side Error
                                if succeeded["message"] != nil{
                                    displayAlert("Info", error: (succeeded["message"] as! String))
                                    if let parentVC = self.parentViewController(){
                                        parentVC.present(alert, animated: true, completion: nil)
                                    }
                                }
                                
                            }
                        })
                    }
                }else{
                    // No Internet Connection Message
                    displayAlert("Info", error: network_status_msg)
                    if let parentVC = self.parentViewController(){
                        showCustomAlert(parentVC.view.center, msg: network_status_msg)
                        // parentVC.presentViewController(alert, animated: true, completion: nil)
                    }
                    
                }
    }

}
