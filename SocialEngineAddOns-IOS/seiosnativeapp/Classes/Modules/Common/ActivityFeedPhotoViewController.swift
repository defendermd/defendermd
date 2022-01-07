//
//  ActivityFeedPhotoViewController.swift
//  seiosnativeapp
//
//  Created by bigstep on 05/07/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit
import Photos
var update_like : Int = 0


class ActivityFeedPhotoViewController: UIViewController, UIScrollViewDelegate, UITextViewDelegate, UIGestureRecognizerDelegate {
    var feedLinkUrl = ""
    var photoAttachmentArray : NSArray!
    var photoIndex : Int!
    var photoForViewer:[PhotoViewer]!
    let photoViewerScrollView = UIScrollView()
    var bottomView : UIView!
    var likeCount : UIButton!
    var commentCount : UIButton!
    var likeShow = UIButton()
    var commentShow : UIButton!
    var shareShow : UIButton!
    var  moreMenu1 : UIButton!
    var viewBorder : UIView!
    var cross : UIButton!
    var currentPage = 0
    var commentIncrement:Int!
    var updateComment:Bool! = false
    var photoType : String!
    var editPhoto : Bool = false
    var deletePhoto:Bool!
    fileprivate var popover: Popover!
    fileprivate var popoverOptions: [PopoverOption] = [
        .type(.up),
        .blackOverlayColor(UIColor(white: 0.0, alpha: 0.6))
    ]
    var crossIcon : UIButton!
    var currentImage : String!
    var shareUrl : String!
    var photoShareUrl : String!
    var shareParam : NSDictionary!
    var editText : UITextView!
    var photoDescription = [String]()
    var photoTitle = [String]()
    var popView : UIView!
    var popAfterDelay:Bool!
    var bottomViewPhotoDescription : UITextView!
    var currentMenu :NSArray!
    var url: String!
    var bottomViewShow : Bool = false
    var leftBarButtonItem : UIBarButtonItem!
    // Reaction Varibles
    var reactionShow = UIView()
    var likeWidth : CGFloat = 0.0
    var reactionsInfo =  UIView()
    var reactionsIcon = [AnyObject]()
    var feedDic : NSDictionary!
    var feedposition : Int!
    var activityFeedComment = false
    var contentActivityFeedComment = false
    var userActivityFeedComment = false
    private var dismissEmojiView: UITapGestureRecognizer?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Create UI for scrolling reactions for selecting
        if ReactionPlugin == true{
            self.browseEmoji(contentItems: reactionsDictionary)
        }
        if photoType == "product_photo"
        {
            self.view.backgroundColor = UIColor.white
        }
        else
        {
            self.view.backgroundColor = UIColor.black
        }

        self.photoForViewer = PhotoViewer.loadPhotosInfo(photoAttachmentArray)
        photoViewerScrollView.frame = view.frame
        photoViewerScrollView.delegate = self
        photoViewerScrollView.isPagingEnabled = true
        photoViewerScrollView.tag = 0
        photoViewerScrollView.isUserInteractionEnabled = true
        self.photoViewerScrollView.contentSize.width = self.view.bounds.width * CGFloat(photoAttachmentArray.count)
        
        view.addSubview(photoViewerScrollView)
        popAfterDelay = false

        // Bottom bar for showing reactions,Like comment,share and more icon
        bottomView =  createView(CGRect(x: 0, y: view.frame.size.height - 50 - iphonXBottomsafeArea, width: view.bounds.width, height: 50), borderColor: UIColor.clear, shadow: false)
        bottomView.backgroundColor = UIColor.black
        if logoutUser == false{
            if photoType == "product_photo"
            {
                bottomView.isHidden = true
            }
            else
            {
                bottomView.isHidden = false
            }
        }
        else{
            bottomView.isHidden = true
        }
        view.addSubview(bottomView)
        viewBorder = UIView(frame:CGRect(x: 0, y: 0, width: view.bounds.width, height: 0.5))
        viewBorder.backgroundColor = UIColor.white
        bottomView.addSubview(viewBorder)

        if photoType == "product_photo"{
            cross =  createButton(CGRect(x:15, y:40 + iphonXTopsafeArea, width:30, height:30), title: "", border: false,bgColor: false, textColor: textColorLight)
            cross.setImage(UIImage(named: "cross"), for: UIControl.State())
        }
        else
        {
            cross =  createButton(CGRect(x: 15, y: 5 + iphonXTopsafeArea , width: 40, height: 70), title: "", border: false,bgColor: false, textColor: textColorLight)
            cross.setImage(UIImage(named: "cross_icon")!.maskWithColor(color: textColorLight), for: UIControl.State())
        }
        cross.titleLabel?.font = UIFont(name: "FontAwesome", size: 20)
        cross.addTarget(self, action: #selector(ActivityFeedPhotoViewController.cancel), for: .touchUpInside)
        view.addSubview(cross)

        // check whether Reaction Plugin is Enable or not
        if ReactionPlugin == true{
            reactionShow =  createView(CGRect(x: 0, y: 0.5, width: 70, height: 50), borderColor: UIColor.clear, shadow: false)
            reactionShow.backgroundColor = UIColor.black
            bottomView.addSubview(reactionShow)
            likeWidth = 70
        }
        else
        {
            likeShow = createButton(CGRect(x: 0,y: 0.5, width: 40, height: 50), title: "", border: false,bgColor: false, textColor: textColorLight)
            likeShow.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZELarge)
            likeShow.setTitle("\(likeIcon)", for: UIControl.State())
            likeShow.addTarget(self, action: #selector(ActivityFeedPhotoViewController.like_unLikeAction(_:)), for: UIControl.Event.touchUpInside)
            bottomView.addSubview(likeShow)
            likeWidth = 40
        }
        
        commentShow = createButton(CGRect(x: likeWidth,y: 0.5, width: 40, height: 50), title: "", border: false,bgColor: false, textColor: textColorLight)
        commentShow.setTitle("\(commentIcon)", for: UIControl.State())
        commentShow.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZELarge)
        commentShow.addTarget(self, action: #selector(ActivityFeedPhotoViewController.commentAction(_:)), for: UIControl.Event.touchUpInside)
        bottomView.addSubview(commentShow)
        shareShow = createButton(CGRect(x: getRightEdgeX(inputView: commentShow),y: 0.5, width: 40, height: 50), title: "", border: false,bgColor: false, textColor: textColorLight)
        shareShow.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZELarge)
        shareShow.setTitle("\(shareIcon)", for: UIControl.State())
        shareShow.addTarget(self, action: #selector(ActivityFeedPhotoViewController.shareAction(_:)), for: UIControl.Event.touchUpInside)
        bottomView.addSubview(shareShow)
        moreMenu1 = createButton(CGRect(x: getRightEdgeX(inputView: shareShow),y: 1, width: 40, height: 50), title: "", border: false,bgColor: false, textColor: textColorLight)
        moreMenu1.titleLabel?.font = UIFont(name: "FontAwesome", size: 25.0)
        moreMenu1.setTitle("\(optionIcon)", for: UIControl.State())
        moreMenu1.addTarget(self, action: #selector(ActivityFeedPhotoViewController.moreMenu), for: .touchUpInside)
        moreMenu1.isHidden = false
        bottomView.addSubview(moreMenu1)
        likeCount = createButton(CGRect(x: view.bounds.width-100,y: 0.5, width: 100, height: 24), title: "", border: false,bgColor: false, textColor: textColorLight)
        likeCount.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
        likeCount.tag = 22
        likeCount.addTarget(self, action: #selector(ActivityFeedPhotoViewController.commentAction(_:)), for: UIControl.Event.touchUpInside)
        bottomView.addSubview(likeCount)
        commentCount = createButton(CGRect(x: view.bounds.width-100,y: 25, width: 100, height: 25), title: "", border: false,bgColor: false, textColor: textColorLight)
        commentCount.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
        commentCount.tag = 23
        commentCount.addTarget(self, action: #selector(ActivityFeedPhotoViewController.commentAction(_:)), for: UIControl.Event.touchUpInside)
        bottomView.addSubview(commentCount)
        
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(ActivityFeedPhotoViewController.cancel))
        downSwipe.direction = .down
        view.addGestureRecognizer(downSwipe)
        
        popView = createView(CGRect(x: 0, y: 10+iphonXTopsafeArea, width: self.view.bounds.width, height: self.view.frame.size.height * 0.35), borderColor: borderColorClear, shadow: false)
        popView.backgroundColor = UIColor.white
        
        bottomViewPhotoDescription = createTextView(CGRect(x: 0, y: view.frame.size.height - 70 - iphonXBottomsafeArea, width: view.bounds.width, height: 0), borderColor: borderColorClear , corner: false )
        bottomViewPhotoDescription.backgroundColor = UIColor.clear
        bottomViewPhotoDescription.textColor = textColorLight
        bottomViewPhotoDescription.font = UIFont(name: fontName, size: 15.0)
        self.automaticallyAdjustsScrollViewInsets = false
        bottomViewPhotoDescription.isEditable = false
        view.addSubview(bottomViewPhotoDescription)
        
        if ReactionPlugin == true{
            reactionsInfo = createView(CGRect(x: 5,y: view.frame.size.height - 80 - iphonXBottomsafeArea ,width: 100 , height: 30), borderColor: UIColor.clear, shadow: false)
            reactionsInfo.backgroundColor =  UIColor.clear
            view.addSubview(reactionsInfo)
            bottomViewPhotoDescription.frame.origin.y = view.frame.size.height - 100

        }
        
        editText = createTextView(CGRect(x: 10,y: 50 + iphonXTopsafeArea,width: self.view.bounds.width-20,height: self.view.frame.size.height * 0.45 - 40), borderColor: borderColorClear , corner: false )
        editText.becomeFirstResponder()
        editText.backgroundColor = UIColor.white
        editText.delegate = self
        editText.backgroundColor = UIColor.clear
        editText.textColor = textColorDark
        editText.font = UIFont(name: fontName, size: FONTSIZELarge)
        editText.autocorrectionType = UITextAutocorrectionType.no
        self.automaticallyAdjustsScrollViewInsets = false
        popView.addSubview(editText)
        
        let upperPopViewInfo = createView(CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 40), borderColor: borderColorClear, shadow: false)
        upperPopViewInfo.backgroundColor = bgColor
        upperPopViewInfo.isHidden = false
        popView.addSubview(upperPopViewInfo)
        
        let editLabel = createLabel(CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 40), text: "Edit Photo", alignment: .center, textColor: textColorDark)
        upperPopViewInfo.addSubview(editLabel)
        
        crossIcon =  createButton(CGRect(x: 15, y: 0, width: 60, height: 40), title: "Cancel", border: false,bgColor: false, textColor: navColor)
        crossIcon.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZELarge)
        // crossIcon.addTarget(self, action: #selector(FBTooltipView.dismiss), for: .touchUpInside)
        upperPopViewInfo.addSubview(crossIcon)
        
        let done =  createButton(CGRect(x: popView.bounds.width - 60, y: 0, width: 60, height: 40), title: "Done", border: false,bgColor: false, textColor: navColor)
        done.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZELarge)
        done.addTarget(self, action: #selector(ActivityFeedPhotoViewController.edit), for: .touchUpInside)
        upperPopViewInfo.addSubview(done)
        
        let recognizer = UITapGestureRecognizer(target: self, action:#selector(ActivityFeedPhotoViewController.handleTap(_:)))
        recognizer.delegate = self
        photoViewerScrollView.addGestureRecognizer(recognizer)
        openScrollImageForIndex()
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(ActivityFeedPhotoViewController.doubleTapped(_:)))
        doubleTap.numberOfTapsRequired = 2;
        photoViewerScrollView.addGestureRecognizer(doubleTap);
        
        if photoIndex > 0 {
            let pageWidth = Int(self.photoViewerScrollView.contentSize.width / CGFloat(photoAttachmentArray.count))
            let pageIndexToScroll = pageWidth * photoIndex
            let floatValue = CGFloat(pageIndexToScroll)
            photoViewerScrollView.setContentOffset(CGPoint(x: floatValue, y: 0), animated: true)
        }
        UItoShowLikes()
        self.bottomViewShow = true
        dismissEmojiView = UITapGestureRecognizer(target: self, action: #selector(dismissView))
        
        if let tap = dismissEmojiView {
            
            view.addGestureRecognizer(tap)
            
        }
 
    }
    
    @objc private func dismissView() {
       
        scrollViewEmoji.isHidden = true
        arrowView.isHidden = true
        
        //view.removeGestureRecognizer(tap)
        
    }
    
    // View according whether Reaction plugin enabled or not
    func UItoShowLikes(){
        let isLike = (self.photoForViewer[self.currentPage].is_like)
        if(isLike != nil){
            if isLike == true{
                if ReactionPlugin == true{
                    for ob in self.reactionShow.subviews{
                        if ob.tag == 200 || ob.tag == 300{
                            ob.removeFromSuperview()
                        }
                    }
                    let reactions = (self.photoForViewer[self.currentPage].reactions)
                    if let myReaction = reactions?["my_feed_reaction"] as? NSDictionary{
                        //print(myReaction)
                        let titleReaction = myReaction["caption"] as? String ?? ""
                        let  title =  NSLocalizedString("\(titleReaction)", comment: "")
                        if let myIcon = myReaction["reaction_image_icon"] as? String{
                            let ImageView = createButton(CGRect(x: 0,y: 12,width: 25,height: 25), title: "", border: false, bgColor: false, textColor: textColorLight)
                            ImageView.imageEdgeInsets =  UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
                            ImageView.tag = 300
                            let imageUrl = myIcon
                            let url = NSURL(string:imageUrl)
                            ImageView.kf.setImage(with: url! as URL, for: .normal, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                                
                            })
                            self.reactionShow.addSubview(ImageView)
                            ImageView.addTarget(self, action: #selector(ActivityFeedPhotoViewController.like_unLikeAction(_:)), for: .touchUpInside)
                            let menu = createButton(CGRect(x: 25, y: 0, width: reactionShow.frame.size.width - 20,height: 50), title: " \(title)", border: false,bgColor: false, textColor: textColorMedium )
                            menu.addTarget(self, action: #selector(ActivityFeedPhotoViewController.like_unLikeAction(_:)), for: UIControl.Event.touchUpInside)
                            let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ActivityFeedPhotoViewController.longPressed(sender:)))
                            menu.addGestureRecognizer(longPressRecognizer)
                            menu.tag = 200
                            menu.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
                            menu.titleLabel?.font = UIFont(name: fontName, size: FONTSIZENormal)
                            //menu.titleLabel?.adjustsFontSizeToFitWidth = true
                            self.reactionShow.addSubview(menu)
                            
                            likeWidth = 70
                            commentShow.frame.origin.x = likeWidth
                            shareShow.frame.origin.x = getRightEdgeX(inputView: commentShow)
                            moreMenu1.frame.origin.x = getRightEdgeX(inputView: shareShow)                
                        }
                        else
                        {
                            ShowLikeButton()
                        }
                    }
                    else
                    {
                        ShowLikeButton()
                    }
                }
                else{
                    self.likeShow.setTitleColor(navColor, for: UIControl.State())
                }
            }
            else{
                if ReactionPlugin == true{
                    
                    ShowLikeButton()
                }
                else{
                    self.likeShow.setTitleColor(textColorLight, for: UIControl.State())
                }
            }
        }
        if ReactionPlugin ==  true
        {
            for ob in (reactionsInfo.subviews){
                ob.removeFromSuperview()
            }
            var origin_x:CGFloat = 0.0
            reactionsIcon.removeAll(keepingCapacity: false)
            if (self.photoForViewer[self.currentPage].reactions) != nil{
                let reactionsof = (self.photoForViewer[self.currentPage].reactions)
                if let reactions = reactionsof?["feed_reactions"] as? NSDictionary{
                    //print(reactions)
                    var menuWidth = CGFloat()
                    var i : Int = 0
                    for (_,value) in reactions
                    {
                        if let reaction = value as? NSDictionary{
                            if i <= 2
                            {
                                if (reaction["reaction_image_icon"] as? String) != nil{
                                    menuWidth = 13
                                    let   emoji = createButton(CGRect(x: origin_x ,y: 5,width: menuWidth,height: 18), title: "", border: false, bgColor: false, textColor: textColorLight)
                                    emoji.imageEdgeInsets =  UIEdgeInsets(top: 4, left: 0, bottom: 1, right: 0)
                                    let imageUrl = reaction["reaction_image_icon"] as? String
                                    reactionsIcon.append(imageUrl as AnyObject)
                                    let url = NSURL(string:imageUrl!)
                                    if url != nil
                                    {
                                        emoji.kf.setImage(with: url as URL?, for: .normal, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in                        
                    })
                                    }
                                    emoji.tag = 22
                                    emoji.addTarget(self, action: #selector(ActivityFeedPhotoViewController.commentAction(_:)), for: UIControl.Event.touchUpInside)
                                    reactionsInfo.addSubview(emoji)
                                    origin_x += (menuWidth) + 2
                                    i = i + 1
                                }
                            }
                        }
                    }
                }
            }
            var infoTitle = ""
            let  likes = (self.photoForViewer[self.currentPage].likes_count)
            if likes != nil {
                if isLike == true{
                    if likes == 1
                    {
                        infoTitle =  String(format: NSLocalizedString("You reacted on this", comment: ""),likes!)
                    }
                    else if likes == 2
                    {
                        infoTitle =  String(format: NSLocalizedString(" You and %d other reacted ", comment: ""),likes! - 1)
                    }
                    else if likes! > 2
                    {
                        infoTitle =  String(format: NSLocalizedString(" You and %d others reacted ", comment: ""),likes! - 1)
                    }
                }
                else{
                    if likes! >= 1{
                        infoTitle =  String(format: NSLocalizedString("%d ", comment: ""),likes!)
                    }
                }
            }
            if infoTitle == ""{
                reactionsInfo.frame.size.height = 0
            }
            let likeCommentInfo = createButton(CGRect(x: origin_x + 2 ,y: 3 ,width: 200 , height: 30), title: "", border: false,bgColor: false, textColor: textColorMedium)
            likeCommentInfo.titleLabel?.font = UIFont(name: fontName , size: FONTSIZESmall)
            likeCommentInfo.tag = 22
            likeCommentInfo.addTarget(self, action: #selector(ActivityFeedPhotoViewController.commentAction(_:)), for: UIControl.Event.touchUpInside)
            likeCommentInfo.titleLabel?.textColor = likeInfo
            likeCommentInfo.contentHorizontalAlignment = .left
            likeCommentInfo.setTitle("\(infoTitle)", for: .normal)
            likeCommentInfo.sizeToFit()
            reactionsInfo.addSubview(likeCommentInfo)
            reactionsInfo.frame.size.width = origin_x + likeCommentInfo.frame.size.width + 5
            if logoutUser == true{
                reactionsInfo.isHidden = true
            }
            else{
                reactionsInfo.isHidden = false
            }
        }
        
        if let photoDescription = self.photoForViewer[self.currentPage].photo_description{
            if photoDescription != ""{
                let font = UIFont(name: fontName, size: 15.0)
                var height = heightForView(photoDescription, font: font!, width: view.bounds.width)
                if height > 130{
                    height = 130
                }
                self.bottomViewPhotoDescription.isHidden = false
                if ReactionPlugin == true{
                    self.bottomViewPhotoDescription.frame = CGRect(x: 0, y: view.frame.size.height - (height + 50 + 15 +  reactionsInfo.frame.size.height), width: view.bounds.width, height: height + 15)
                }
                else{
                    self.bottomViewPhotoDescription.frame = CGRect(x: 0, y: view.frame.size.height - (height + 50 + 15), width: view.bounds.width, height: height + 15)
                }
                self.bottomViewPhotoDescription.text = photoDescription
            }
            else{
                self.bottomViewPhotoDescription.isHidden = true
            }
        }
        if let likecount = self.photoForViewer[self.currentPage].likes_count{
            let finalText = singlePluralCheck( NSLocalizedString(" Like", comment: ""),  plural: NSLocalizedString(" Likes", comment: ""), count: likecount)
            self.likeCount.setTitle("\(finalText)", for: UIControl.State())
        }
        if let commentcount = self.photoForViewer[self.currentPage].comment_count{
            let finalText = singlePluralCheck( NSLocalizedString(" Comment", comment: ""),  plural: NSLocalizedString(" Comments", comment: ""), count: commentcount)
            self.commentCount.setTitle("\(finalText)", for: UIControl.State())
        }
    }

    func ShowLikeButton()
    {
        for ob in self.reactionShow.subviews{
            if ob.tag == 200 || ob.tag == 300{
                ob.removeFromSuperview()
            }
        }
        let menu = createButton(CGRect(x: 0,y: 0, width: 40, height: 50), title: "", border: false,bgColor: false, textColor: textColorLight)
        menu.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZELarge)
        menu.setTitle("\(likeIcon)", for: UIControl.State())
        menu.addTarget(self, action: #selector(ActivityFeedPhotoViewController.like_unLikeAction(_:)), for: UIControl.Event.touchUpInside)
        menu.tag = 200
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ActivityFeedPhotoViewController.longPressed(sender:)))
        menu.addGestureRecognizer(longPressRecognizer)
        self.reactionShow.addSubview(menu)
        likeWidth = 40
        commentShow.frame.origin.x = likeWidth
        shareShow.frame.origin.x = getRightEdgeX(inputView: commentShow)
        moreMenu1.frame.origin.x = getRightEdgeX(inputView: shareShow)
    }
    // MARK: Start code for when Reaction Plugin is enabled
    
    // View of all possible reactions that we can like
    func animateReaction() {
        arrowView.isHidden = true
        let frame = CGRect(x: 0, y: 0, width: 70, height: 70)
        let image = reactionButtonImage.imageView?.image
        let imageView = UIImageView(frame: frame)
        imageView.image = image
        imageView.center = (self.view.parentViewController()?.view.center)!
        imageView.isHidden = false
        view.addSubview(imageView)
        view.bringSubviewToFront( imageView)
        
        imageView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 1.5, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 10.0, options: UIView.AnimationOptions.allowUserInteraction, animations: {
            imageView.transform = .identity
        }, completion: { (_) in
            imageView.isHidden = true
            imageView.removeFromSuperview()
        }
        )
    }
    
   
    func browseEmoji(contentItems: NSDictionary)
    {
        for ob in scrollViewEmoji.subviews{
            ob.removeFromSuperview()
            arrowView.removeFromSuperview()
        }
        // var allReactionsValueDic = Dictionary<String, AnyObject>() // sorted Reaction Dictionary
        if let allReactionsValueDic = sortedReactionDictionary(dic: contentItems) as? Dictionary<String, AnyObject>
        {
            
            let space:CGFloat = 15
            let vSpace:CGFloat = 9
            let viewWidth = self.view.frame.width - 12
            let iconHeight = (viewWidth/6) - (space*7)/6
            let viewHeight = iconHeight + (2*vSpace)
            
            scrollViewEmoji.frame = CGRect(x:0,y: 0,width: viewWidth,height: viewHeight)
            arrowView.frame = CGRect(x: 0, y: 0, width: 14, height: 10)
            scrollViewEmoji.backgroundColor = UIColor.white//UIColor.clear
            arrowView.backgroundColor = UIColor.white
            scrollViewEmoji.layer.cornerRadius = CGFloat(viewHeight/2)
            var menuWidth = CGFloat()
            var origin_x:CGFloat = 15
            var i : Int = 0
            for key in allReactionsValueDic.keys.sorted(by: <) {
                if let   v = allReactionsValueDic[key]
                {
                    
                    if let icon = v["icon"] as? NSDictionary{
                        
                        menuWidth = iconHeight
                        let   emoji = createButton(CGRect(x: origin_x,y: vSpace,width: iconHeight,height: iconHeight), title: "", border: false, bgColor: false, textColor: textColorLight)
                        emoji.addTarget(self, action: #selector(ActivityFeedPhotoViewController.feedMenuReactionLikes(sender:)), for: .touchUpInside)
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
                        else if let imageUrl = icon["reaction_image_icon"] as? String
                        {
                            let url = NSURL(string:imageUrl)
                            if url != nil
                            {
                                emoji.kf.setImage(with: url as URL?, for: .normal, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                                })
                            }
                        }
                        scrollViewEmoji.addSubview(emoji)
                        origin_x = origin_x + menuWidth + CGFloat(space)
                        i = i + 1
                    }
                    
                }
                
                
            }
            
            scrollViewEmoji.contentSize = CGSize(width: origin_x, height: CGFloat(viewHeight))
            scrollViewEmoji.bounces = false
            scrollViewEmoji.isUserInteractionEnabled = true
            scrollViewEmoji.showsVerticalScrollIndicator = false
            scrollViewEmoji.showsHorizontalScrollIndicator = false
            scrollViewEmoji.alwaysBounceHorizontal = true
            scrollViewEmoji.alwaysBounceVertical = false
            scrollViewEmoji.isDirectionalLockEnabled = true;
            scrollViewEmoji.isHidden = true
            arrowView.isHidden = true
            scrollViewEmoji.layer.shadowColor = UIColor(white: 0.4, alpha: 0.4).cgColor
            scrollViewEmoji.layer.borderColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1).cgColor
            scrollViewEmoji.layer.borderWidth = 1
            scrollViewEmoji.layer.shadowRadius = 50
            scrollViewEmoji.layer.shadowOpacity = 0.5
            scrollViewEmoji.layer.shadowOffset = CGSize(width: 0, height: 35)
            arrowView.layer.shadowColor = UIColor(white: 0.4, alpha: 0.4).cgColor
            arrowView.layer.borderColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1).cgColor
            arrowView.layer.borderWidth = 1
            arrowView.layer.shadowRadius = 50
            arrowView.layer.shadowOpacity = 0.5
            arrowView.layer.shadowOffset = CGSize(width: 0, height: 35)
        }
    }
    
    // when press long then show reactions view
//    @objc func longPressed(sender: UILongPressGestureRecognizer)
//    {
//        let  Currentcell = (sender.view?.tag)!
//        let tapLocation = sender.location(in: self.view)
//        if sender.state == .began {
//            soundEffect("reactions_popup")
//            scrollViewEmoji.frame.origin.x = tapLocation.x
//            scrollViewEmoji.frame.origin.y = tapLocation.y - 90
//             scrollViewEmoji.alpha = 0
//            scrollViewEmoji.isHidden = false
//            scrollViewEmoji.tag =  Currentcell
//            view.removeGestureRecognizer(sender)
//            view.addSubview(scrollViewEmoji)
//            UIView.animate(withDuration: 0.5, delay: 0.4, options: .curveEaseOut, animations: {
//                scrollViewEmoji.alpha = 1
//            }, completion: nil)
//        }
//    }
    
    @objc func longPressed(sender: UILongPressGestureRecognizer)
    {
        let  Currentcell = (sender.view?.tag)!
        let tapLocation = sender.location(in: self.view)
        scrollViewEmoji.center.x = self.view.center.x
        scrollViewEmoji.backgroundColor = UIColor.white
        arrowView.backgroundColor = UIColor.white
        if sender.state == .began {
            soundEffect("reactions_popup")
            if tapLocation.y < TOPPADING + scrollViewEmoji.frame.height + arrowView.frame.height + 20{
                scrollViewEmoji.frame.origin.y = tapLocation.y + arrowView.frame.height + 20
                arrowView.transform = CGAffineTransform(rotationAngle: .pi)
                arrowView.frame.origin = CGPoint(x: scrollViewEmoji.frame.origin.x + 30, y: scrollViewEmoji.frame.origin.y - arrowView.frame.height)
            }
            else {
                arrowView.transform = .identity
                scrollViewEmoji.frame.origin.y = tapLocation.y - scrollViewEmoji.frame.height - arrowView.frame.height - 20
                arrowView.frame.origin = CGPoint(x: scrollViewEmoji.frame.origin.x + 30, y: getBottomEdgeY(inputView: scrollViewEmoji) - 2)
            }
            if tableViewFrameType == "CommentsViewController"
            {
                UIApplication.shared.keyWindow?.removeGestureRecognizer(sender)
                //window?.removeGestureRecognizer(sender)
            }
            else
            {
                view.removeGestureRecognizer(sender)
            }

            let stackView = scrollViewEmoji.subviews.reversed()
            stackView.forEach({ (emoji) in
                emoji.alpha = 0
                scrollViewEmoji.bringSubviewToFront( emoji)
                emoji.transform = CGAffineTransform(translationX: -100, y: emoji.frame.origin.y)
            })
            arrowView.alpha = 0

            arrowView.alpha = 0
            arrowView.tag = Currentcell
            scrollViewEmoji.alpha = 0
            scrollViewEmoji.isHidden = false
            scrollViewEmoji.tag =  Currentcell
            view.addSubview(scrollViewEmoji)
            view.addSubview(arrowView)
            view.bringSubviewToFront( arrowView)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                scrollViewEmoji.alpha = 1
                arrowView.alpha = 1
                arrowView.isHidden = false
            }, completion: { (_) in

            }
            )

            UIView.animate(withDuration:0.2, animations: {
                let stackView = scrollViewEmoji.subviews.reversed()
                stackView.forEach({ (emoji) in

                    emoji.alpha = 1
                    emoji.transform = .identity
                })
            }) { (_) in
                //
            }
        }
    }
    
    // remove reactions view
    func removeEmoji(recognizer: UITapGestureRecognizer){
        scrollViewEmoji.isHidden = true
        arrowView.isHidden = true
        view.removeGestureRecognizer(recognizer)
    }
    
    // When click on Particular Reactions
    @objc func feedMenuReactionLikes(sender:UIButton){
        reactionButtonImage = sender
        arrowView.isHidden = true
        let photoId = (photoForViewer[currentPage].photo_id!)
        var photo_type = "photo"
        if (photoType == ("album_photo")) || (photoType == ("album")) {
            photo_type = "photo"
        }else{
            photo_type = photoType
        }
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
                    updateReactions(url: url,reaction : reaction,subject_id  : "\(photoId)", updateMyReaction : updatedDictionary as NSDictionary,feedIndex: scrollViewEmoji.tag,subject_type : photo_type,updateType : "update")
                }
            }
        }
    }
    
    // UpdateReactions when like or unlike or React
    func updateReactions(url : String,reaction : String,subject_id : String,updateMyReaction : NSDictionary,feedIndex: Int,subject_type : String, updateType : String){
        let updateTypeString = updateType
        var dic = Dictionary<String, String>()
        scrollViewEmoji.isHidden = true
        arrowView.isHidden = true
        let is_like = (photoForViewer[currentPage].is_like)
        let photoId = (photoForViewer[currentPage].photo_id!)
        for (index,value) in self.photoForViewer.enumerated(){
            if value.photo_id == photoId{
                let newDictionary:NSMutableDictionary = [:]
                newDictionary["image"] = value.image
                newDictionary["loading_flag"] = value.loading_flag
                newDictionary["photo_id"] = value.photo_id
                newDictionary["photo_description"] = value.photo_description
                newDictionary["comment_count"] = value.comment_count
                total_Comments = value.comment_count ?? 0
                newDictionary["title"] = value.photo_title
                newDictionary["menu"] = value.menu
                newDictionary["description"] = value.description
                let changedDictionary : NSMutableDictionary = [:]
                changedDictionary.removeAllObjects()
                var addDictionary : Bool! = false
                switch(updateTypeString) {
                case  "update" :
                    newDictionary["is_like"] = value.is_like
                    newDictionary["like_count"] = value.likes_count!
                    
                    total_Likes = value.likes_count!
                    addDictionary = true
                    let tempchangedDictionary : NSMutableDictionary = [:]
                    // when already like just need to replace
                    if  is_like == true
                    {
                        let myReaction = (self.photoForViewer[self.currentPage].my_feed_reaction)
                        if (myReaction?.count)! > 0{
                            let reactionId = myReaction?["reactionicon_id"] as? Int
                            let feedReaction  = (self.photoForViewer[self.currentPage].feed_reaction)
                            if (self.photoForViewer[self.currentPage].feed_reaction) != nil{
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
                    // when or like alredy
                    else
                    {
                        addDictionary = true
                        newDictionary["is_like"] = true
                        if (value.likes_count != nil){
                            newDictionary["like_count"] = value.likes_count! + 1
                            total_Likes = value.likes_count! + 1
                        }
                        if (self.photoForViewer[self.currentPage].feed_reaction) != nil{
                            let reactions = (self.photoForViewer[self.currentPage].feed_reaction)
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
                    if value.likes_count! > 0
                    {
                        newDictionary["like_count"] = value.likes_count! - 1
                        total_Likes = value.likes_count! - 1
                    }
                  
                    if(is_like == true)
                    {
                        newDictionary["is_like"] = false
                        let  reactions = (self.photoForViewer[self.currentPage].feed_reaction)
                        for(k,v) in reactions!
                        {
                            let dicValue = v as! NSDictionary
                            let currentId = Int((k as! String))
                            if (self.photoForViewer[self.currentPage].my_feed_reaction) != nil{
                                let  myReaction = (self.photoForViewer[self.currentPage].my_feed_reaction)
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
                let newDictionaryReaction :NSMutableDictionary = [:]
                newDictionaryReaction["my_feed_reaction"] = updateMyReaction
                if changedDictionary.count>0
                {
                  newDictionaryReaction["feed_reactions"] = changedDictionary
                }
                else
                {
                  newDictionaryReaction.removeObject(forKey: "feed_reactions")
                }
                newDictionary["reactions"] = newDictionaryReaction
                
//                //print(newDictionaryReaction)
//                //print(changedDictionary)
//                //print(updateMyReaction)
                
                // Update photoviewer with update reactions
                var newData = PhotoViewer.loadPhotosInfoDictionary(newDictionary)
                self.photoForViewer[index] = newData[0] as PhotoViewer
                // End Update photoviewer with update reactions
                
                // Update feedArray attacment dic
                let dic = feedDic as! NSMutableDictionary
                
                //print(dic)
                let arr = dic["attachment"] as! NSMutableArray
                let  dic2 = arr[index] as! NSMutableDictionary
                dic2["reactions"] = newDictionaryReaction
                let islike  =  newDictionary["is_like"]
                let likecount  = newDictionary["like_count"]
                dic2["is_like"] = islike
                dic2["like_count"] = likecount
                arr[index] = dic2
                dic["attachment"] = arr
                if userActivityFeedComment == true
                {
                    userFeedArray[feedposition] = dic
                    
                }
                else if activityFeedComment == true
                {
                    
                    feedArray[feedposition] = dic
                }
                else
                {
                    contentFeedArray[feedposition] = dic
                }
                
                // End update feedArray attacment dic
                
                //print(dic)
                
                if index == 0
                {
                    // Update Feed islike,likecount,Feed reaction and Myreaction while reacting on first photo of feed
                    self.updateActivityFeed(likecount as? Int ?? 0, commentCount: total_Comments, islike: islike as! Bool,feed_reactions:changedDictionary,my_feed_reaction:updateMyReaction,photoindex:index)
                }

            }
        }
        self.UItoShowLikes()
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
                        // call notificatiom
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
                           showToast(message: network_status_msg, controller: self, onView: false, time: 5)
                        }
                        
                    }
                })
            }
        }
        else
        {
            showToast(message: network_status_msg, controller: self, onView: false, time: 5)
        }
    }
    
    
    //Update Activity Feed
    func updateActivityFeed(_ likeCount:Int, commentCount:Int,islike : Bool,feed_reactions:NSDictionary,my_feed_reaction:NSDictionary,photoindex:Int){
        
        feedUpdate = false
        
        if let feed = feedDic {
            let newDictionary:NSMutableDictionary = [:] //= [String:AnyObject]()
            
            if feed["subject_image"]  != nil{
                newDictionary["subject_image"] = feed["subject_image"]
            }
            if feed["feed_title"]  != nil{
                newDictionary["feed_title"] = feed["feed_title"]
            }
            if feed["feed_createdAt"]  != nil{
                newDictionary["feed_createdAt"] = feed["feed_createdAt"]
            }
            
            if feed["attachment"]  != nil{
                newDictionary["attachment"] = feed["attachment"]
            }
            if feed["attactment_Count"]  != nil{
                newDictionary["attactment_Count"] = feed["attactment_Count"]
            }
            if feed["action_id"]  != nil{
                newDictionary["action_id"] = feed["action_id"]
            }
            if feed["feed_Type"]  != nil{
                newDictionary["feed_Type"] = feed["feed_Type"]
            }
            if feed["feed_menus"]  != nil{
                newDictionary["feed_menus"] = feed["feed_menus"]
            }
            if feed["feed_footer_menus"]  != nil{
                newDictionary["feed_footer_menus"] = feed["feed_footer_menus"]
            }
            if (feed["feed_reactions"]  != nil || feed_reactions.count>0){
                newDictionary["feed_reactions"] = feed_reactions
            }
            if (feed["my_feed_reaction"]  != nil || my_feed_reaction.count>0){
                newDictionary["my_feed_reaction"] = my_feed_reaction
            }
            if feed["comment"]  != nil{
                newDictionary["comment"] = feed["comment"]
            }
            if feed["delete"]  != nil{
                newDictionary["delete"] = feed["delete"]
            }
            if feed["share"]  != nil{
                newDictionary["share"] = feed["share"]
            }
            if feed["is_like"] != nil {
                newDictionary["is_like"] = islike
            }
            if feed["params"] != nil{
                newDictionary["params"] = feed["params"]
            }
            if feed["tags"] != nil{
                newDictionary["tags"] = feed["tags"]
            }
            if feed["action_type_body_params"] != nil{
                newDictionary["action_type_body_params"] = feed["action_type_body_params"]
            }
            if feed["action_type_body"] != nil{
                newDictionary["action_type_body"] = feed["action_type_body"]
            }
            
            if feed["photo_attachment_count"] != nil{
                newDictionary["photo_attachment_count"] = feed["photo_attachment_count"]
            }
            if feed["object_id"] != nil{
                newDictionary["object_id"] = feed["object_id"]
            }
            if feed["object_type"] != nil{
                newDictionary["object_type"] = feed["object_type"]
            }
            newDictionary["comment_count"] = commentCount
            if(feed["likes_count"] != nil) {
                newDictionary["likes_count"] = likeCount
            }
            if feed["hashtags"] != nil{
                newDictionary["hashtags"] = feed["hashtags"]
            }
            
            if feed["decoration"] != nil{
                newDictionary["decoration"] = feed["decoration"]
            }
            if feed["wordStyle"] != nil{
                newDictionary["wordStyle"] = feed["wordStyle"]
            }
            if feed["publish_date"] != nil{
                newDictionary["publish_date"] = feed["publish_date"]
            }
            if feed["isNotificationTurnedOn"] != nil{
                newDictionary["isNotificationTurnedOn"] = feed["isNotificationTurnedOn"]
                
            }
            
            if feed["attachment_content_type"] != nil{
                newDictionary["attachment_content_type"] = feed["attachment_content_type"]
            }
            
            
            // Updating corresponding array for showing instant update on feed page
            if userActivityFeedComment == true
            {
                userFeedArray[feedposition] = newDictionary
                
            }
            else if activityFeedComment == true
            {
              //  //print(newDictionary)
                feedArray[feedposition] = newDictionary
            }
            else
            {
                contentFeedArray[feedposition] = newDictionary
            }
            
            //print(newDictionary)
            
            update_like = 1
        }
    }

    // MARK: Finish code for when Reaction Plugin is enabled
    
    func openScrollImageForIndex(){
        
        self.photoViewerScrollView.isHidden = false
        
        for i in (0 ..< photoForViewer.count) {
            var frame = CGRect()
            frame.origin.x = self.view.bounds.width * CGFloat(i)
            frame.origin.y = 0
            frame.size = self.photoViewerScrollView.frame.size
            let innerscrollview = UIScrollView()
            innerscrollview.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: frame.size.height)
            innerscrollview.minimumZoomScale = 1;
            innerscrollview.maximumZoomScale = 3;
            innerscrollview.zoomScale = 1;
            innerscrollview.contentSize = self.photoViewerScrollView.bounds.size
            innerscrollview.delegate = self;
            innerscrollview.showsHorizontalScrollIndicator = false;
            innerscrollview.showsVerticalScrollIndicator = false;
            innerscrollview.isUserInteractionEnabled = true
            
            let doubleTap = UITapGestureRecognizer(target: self, action: #selector(ActivityFeedPhotoViewController.doubleTapped(_:)))
            doubleTap.numberOfTapsRequired = 2;
            innerscrollview.addGestureRecognizer(doubleTap);
            
            var imageView = UIImageView()
            imageView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
            imageView.contentMode = UIView.ContentMode.scaleAspectFit
            imageView.isUserInteractionEnabled = true
            imageView.tag = 111
            
            imageView.image = UIImage(named: "album-default.png")
            innerscrollview.addSubview(imageView)
            if let url = URL(string: photoForViewer[i].image!)
            {
                imageView.kf.indicatorType = .activity
                (imageView.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                imageView.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                })
                
            }
            self.photoViewerScrollView.addSubview(innerscrollview)
        }
        
        
        
        self.photoViewerScrollView.contentSize = CGSize(width: view.frame.size.width * CGFloat(photoForViewer.count) , height: view.frame.size.height)
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
         scrollViewEmoji.isHidden = true
         scrollviewEmojiLikeView.isHidden = true
        arrowView.isHidden = true
        
        if photoViewerScrollView.contentOffset.x < 0{
            photoViewerScrollView.contentOffset.x = -(photoViewerScrollView.contentOffset.x )
            photoViewerScrollView.isScrollEnabled = false
            
        }
        else{
         photoViewerScrollView.isScrollEnabled = true
        }
        
        currentPage = Int(floor(photoViewerScrollView.contentOffset.x / photoViewerScrollView.frame.size.width))
        //Int(floor((photoViewerScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1);
        
        UItoShowLikes()
        
        if let likecount = photoForViewer[currentPage].likes_count{
            let finalText = singlePluralCheck( NSLocalizedString(" Like", comment: ""),  plural: NSLocalizedString(" Likes", comment: ""), count: likecount)
            likeCount.setTitle("\(finalText)", for: UIControl.State())
        }
        if let commentcount = photoForViewer[currentPage].comment_count{
            let finalText = singlePluralCheck( NSLocalizedString(" Comment", comment: ""),  plural: NSLocalizedString(" Comments", comment: ""), count: commentcount)
            commentCount.setTitle("\(finalText)", for: UIControl.State())
            
        }
        
    }
    
    func showAlertMessage( _ centerPoint: CGPoint, msg: String, timer: Bool){
        self.view .addSubview(validationMsg)
        showCustomAlert(centerPoint, msg: msg)
        if timer {
            // Initiamsg: lization of Timer
           self.createTimer(self)
        }
    }
    func createTimer(_ target: AnyObject){
        timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  #selector(stopTimer), userInfo: nil, repeats: false)
    }
    @objc func stopTimer() {
        stop()
        if popAfterDelay == true {
            cancel()
        }
    }
    
    @objc func like_unLikeAction(_ sender:UIButton){
        scrollViewEmoji.isHidden = true
        arrowView.isHidden = true
        let is_like = (photoForViewer[currentPage].is_like)
        let photoId = (photoForViewer[currentPage].photo_id!)
        var total_likes = (photoForViewer[currentPage].likes_count)
        
        if is_like != nil {
            
            if is_like == true{
                if ReactionPlugin == false{
                    // work for like
                    total_likes = total_likes! - 1
                    animationEffectOnButton(sender)
                    likeShow.setTitleColor(textColorLight , for: UIControl.State())
                }
            }
            else{
                if ReactionPlugin == false{
                    // work for unlike
                    total_likes = total_likes! + 1
                    animationEffectOnButton(sender)
                    likeShow.setTitleColor(navColor , for: UIControl.State())
                }
            }
            
            let finalText = singlePluralCheck( NSLocalizedString(" Like", comment: ""),  plural: NSLocalizedString(" Likes", comment: ""), count: total_likes ?? 0)
            likeCount.setTitle("\(finalText)", for: UIControl.State())
            var photo_type = "photo"
            if (photoType == ("album_photo")) || (photoType == ("album")) {
                photo_type = "photo"
            }else{
                photo_type = photoType
            }
            if ReactionPlugin == true{
                
                 if is_like == false{
                    // updateReaction
                    let photoId = (photoForViewer[currentPage].photo_id!)
                    var photo_type = "photo"
                    if (photoType == ("album_photo")) || (photoType == ("album")) {
                        photo_type = "photo"
                    }else{
                        photo_type = photoType
                    }
                    var reaction = ""
                    for (k,v) in reactionsDictionary
                    {
                        let v = v as! NSDictionary
                        var updatedDictionary = Dictionary<String, AnyObject>()
                        if  (v["reactionicon_id"] as? Int) != nil
                        {
                            if k as! String == "like"
                            {
                                reaction = (v["reaction"] as? String)!
                                updatedDictionary["reactionicon_id"] = v["reactionicon_id"]  as AnyObject?
                                updatedDictionary["caption" ] = v["caption"]  as AnyObject?
                                if let icon  = v["icon"] as? NSDictionary{
                                    animateLikeReaction()
                                    updatedDictionary["reaction_image_icon"] = icon["reaction_image_icon"] as! String as AnyObject?
                                }
                                var url = ""
                                url = "advancedcomments/like"
                                DispatchQueue.main.async(execute:  {
                                    soundEffect("Like")
                                })
                                 updateReactions(url: url,reaction : reaction,subject_id  : "\(photoId)", updateMyReaction : updatedDictionary as NSDictionary,feedIndex: scrollViewEmoji.tag,subject_type : photo_type,updateType : "update")
                            }
                        }
                    }
                }
                 else{
                    // delete Reaction
                    let photoId = (photoForViewer[currentPage].photo_id!)
                    var photo_type = "photo"
                    if (photoType == ("album_photo")) || (photoType == ("album")) {
                        photo_type = "photo"
                    }else{
                        photo_type = photoType
                    }
                    let reaction = ""
                    var updatedDictionary = Dictionary<String, AnyObject>()
                    updatedDictionary = [ : ]
                    var url = ""
                    url = "unlike"
                    DispatchQueue.main.async(execute:  {
                        soundEffect("Like")
                    })
                    updateReactions(url: url,reaction : reaction,subject_id  : "\(photoId)", updateMyReaction : updatedDictionary as NSDictionary,feedIndex: sender.tag,subject_type : photo_type,updateType : "delete")
                }
            }
            else{
            // Check Internet Connection
            if Reachabable.isConnectedToNetwork() {
                removeAlert()
                var path = ""
                // Set path for Like & UnLike
                if is_like == true{
                    path = "unlike"
                }else{
                    path = "like"
                }
                // Send Server Request to Like/Unlike Content
                post(["subject_id":"\(photoId)", "subject_type": "\(photo_type)"], url: path, method: "POST") {
                    (succeeded, msg) -> () in
                    sender.isEnabled = true
                    DispatchQueue.main.async(execute: {
                        if msg{
                            //feedUpdate = true
                            listingDetailUpdate = true
                            pageDetailUpdate = true
                            contentFeedUpdate = true
                            // On Success Update
                            if succeeded["message"] != nil{
                                if(is_like == true){
                                    sender.setTitleColor(textColorLight , for: UIControl.State())
//                                    sender.isEnabled = true
                                }else{
                                    sender.setTitleColor(navColor, for: UIControl.State())
                                }
                                
                                for (index,value) in self.photoForViewer.enumerated(){
                                    if value.photo_id == photoId{
                                        let newDictionary:NSMutableDictionary = [:]
                                        newDictionary["image"] = value.image
                                        newDictionary["loading_flag"] = value.loading_flag
                                        newDictionary["photo_id"] = value.photo_id
                                        newDictionary["photo_description"] = value.photo_description
                                        newDictionary["comment_count"] = value.comment_count
                                        newDictionary["title"] = value.photo_title
                                        newDictionary["menu"] = value.menu
                                        newDictionary["description"] = value.description
                                        if path.range(of: "unlike") != nil{
                                            newDictionary["is_like"] = false
                                            if value.likes_count! > 0
                                            {
                                               newDictionary["like_count"] = value.likes_count! - 1
                                            }
                                            
                                        }else{
                                            newDictionary["is_like"] = true
                                            newDictionary["like_count"] = value.likes_count! + 1
                                        }
                                        
                                        var newData = PhotoViewer.loadPhotosInfoDictionary(newDictionary)
                                        self.photoForViewer[index] = newData[0] as PhotoViewer
                                    }
                                }
                                
                                let finalText = singlePluralCheck( NSLocalizedString(" Like", comment: ""),  plural: NSLocalizedString(" Likes", comment: ""), count: total_likes!)
                                self.likeCount.setTitle("\(finalText)", for: UIControl.State())
                                
                                
                            }
                            
                        }
                        else{
                            // Handle Server Side Error
                            if succeeded["message"] != nil{
                            }
                            
                        }
                    })
                    
                }
            } else{
                // No Internet Connection Message
                displayAlert("Info", error: network_status_msg)
                
                if let parentVC = self.parent{
                    showCustomAlert(parentVC.view.center, msg: network_status_msg)
                    // parentVC.presentViewController(alert, animated: true, completion: nil)
                }
                }
            }
        }
    }
    
    func animateLikeReaction() {
    
        
        arrowView.isHidden = true
        let frame = CGRect(x: 0, y: 0, width: 70, height: 70)
       
        let image = reactionButtonImage.imageView?.image
        let imageView = UIImageView(frame: frame)
        imageView.image = likeIconImage
        imageView.center = view.center
        imageView.isHidden = false
        imageView.frame.origin.y = UIScreen.main.bounds.height/2 - 35
        imageView.frame.origin.x = UIScreen.main.bounds.width/2 - 35
        view.addSubview(imageView)
        view.bringSubviewToFront( imageView)
        imageView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 1.5, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 10.0, options: UIView.AnimationOptions.allowUserInteraction, animations: {
            imageView.transform = .identity
        }, completion: { (_) in
            imageView.isHidden = true
            imageView.removeFromSuperview()
        }
        )
    }

    
    @objc func commentAction(_ sender:UIButton){
        let photoId = (photoForViewer[currentPage].photo_id!)
        if let parentVC = self.parent{
            let presentedVC = CommentsViewController()
            updateComment = true
            commentIncrement = currentPage
            likeCommentContent_id = "\(photoId)"
            var photo_type = photoType
            if (photoType == ("album_photo")) || (photoType == ("album")) {
                photo_type = "photo"
            }else{
                photo_type = photoType
            }
            
            likeCommentContentType  = photo_type
            presentedVC.openCommentTextView = 1
            presentedVC.pushFlag = true
            presentedVC.commentPermission = 1
            presentedVC.activityFeedComment = false
            presentedVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            presentedVC.fromPhotoViewer = true
            presentedVC.reactionsIcon = reactionsIcon
            presentedVC.fromSingleFeed = false
            let navigationController = UINavigationController(rootViewController: presentedVC)
            parentVC.present(navigationController, animated: true, completion: nil)
        }
    }
    
    @objc func moreMenu(){
        editPhoto = false
        self.currentMenu = (photoForViewer[currentPage].menu)!
        self.currentImage = (photoForViewer[currentPage].image)!
        self.currentImage = (photoForViewer[currentPage].image)!
        if feedLinkUrl != "" {
            self.photoShareUrl = feedLinkUrl
        }
        else {
            if let photoUrl = (photoForViewer[currentPage].photoUrl)
            {
                self.photoShareUrl = photoUrl
            }
            else if let photoUrl = (photoForViewer[currentPage].photoUrlForAlbum)
            {
                self.photoShareUrl = photoUrl
            }
            else
            {
                self.photoShareUrl = self.currentImage
            }
        }
      
       // self.photoShareUrl = (photoForViewer[currentPage].photoUrl)!
        // Generate Blog Menu Come From Server as Alert Popover
        self.deletePhoto = false
        let url = URL(string: self.currentImage)
        
        var imgView = UIImageView()
        let  imageTemp = UIImage()
        imgView.kf.indicatorType = .activity
        (imgView.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
        imgView.kf.setImage(with: url, placeholder: UIImage(named: "user_profile_image.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
            
        })
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Share Outside",  comment: ""), style: .default, handler:{
            (UIAlertAction) -> Void in
            let url = URL(string: self.currentImage)
            let data = try? Data(contentsOf: url!)
            let  image = UIImage(data: data!)
            self.shareTextImageAndURL(self.title, sharingImage: image, photoShareUrl: self.photoShareUrl)

        }))
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Save Photo",  comment: ""), style: .default, handler:{
            (UIAlertAction) -> Void in
            
            let url = URL(string: self.currentImage)
            let data = try? Data(contentsOf: url!)
            let  image = UIImage(data: data!)
//            ALAssetsLibrary().writeImageData(toSavedPhotosAlbum: imageTemp.png, metadata:nil , completionBlock: nil)
//            self.view.makeToast(NSLocalizedString("Photo Saved", comment: ""), duration: 5, position: CSToastPositionCenter)
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image!)
            }, completionHandler: { success, error in
                
            })
            showToast(message: NSLocalizedString("Your photo will be saved in gallery.",comment: ""), controller: self, onView: false, time: 2)
        }))
        
        if self.currentMenu != nil{
            for menuItem in currentMenu{
                if let dic = menuItem as? NSDictionary{
                    
                    if dic["label"] as! String != "Share"{
                        
                        alertController.addAction(UIAlertAction(title: (dic["label"] as! String), style: .default, handler:{ (UIAlertAction) -> Void in
                            // Change Here For Edit
                            if dic["name"] as! String ==  "edit"{
                                self.editPhoto = true
                                NotificationCenter.default.addObserver(self, selector: #selector(ActivityFeedPhotoViewController.keyboardWillShow(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
                                let startPoint = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height - 50)
                                self.popover = Popover(options: self.popoverOptions, showHandler: nil, dismissHandler: nil)
                                self.popover.show(self.popView, point: startPoint)
                                if (self.photoForViewer[self.currentPage].photo_description) != nil{
                                    self.editText.text =  self.photoForViewer[self.currentPage].photo_description!
                                }
                                self.editText.becomeFirstResponder()
                            }
                            // Change Here For Delete
                            if dic["name"] as! String == "delete"{
                                
                                // Confirmation Alert
                                displayAlertWithOtherButton(NSLocalizedString("Delete Group Photo",  comment: ""),message: NSLocalizedString("Are you sure you want to delete this photo?",  comment: "") , otherButton: NSLocalizedString("Delete Photo",  comment: "")) { () -> () in
                                    self.deletePhoto = true
                                    self.updatePhoto(dic["urlParams"] as! NSDictionary, url:dic["url"] as! String )
                                }
                                self.present(alert, animated: true, completion: nil)
                            }
                            // Share Blog
                            if dic["name"] as! String == "share"{
                                self.shareUrl = dic["url"] as! String
                                self.shareParam = dic["urlParams"] as! NSDictionary
                                self.shareItem()
                                
                            }
                            // Report this Blog
                            if dic["name"] as! String == "report"{
                                let presentedVC = ReportContentViewController()
                                presentedVC.param = (dic["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary

                                presentedVC.url = dic["url"] as! String
                                self.navigationController?.pushViewController(presentedVC, animated: true)
                                
                            }
                            // Subscribe/Unsubscribe this Blog
                            
                            if dic["name"] as! String == "make_profile_photo" {
                                displayAlertWithOtherButton(NSLocalizedString("Make Profile Photo",  comment: ""),message: NSLocalizedString("Do you want to make this photo your profile photo?",  comment: "") , otherButton: NSLocalizedString("Save",  comment: "")) { () -> () in
                                    self.updatePhoto(dic["urlParams"] as! NSDictionary, url:dic["url"] as! String )
                                }
                                self.present(alert, animated: true, completion: nil)
                            }
                            
                        }))
                    }
                    
                }
                
            }
        }
        
        if  (UIDevice.current.userInterfaceIdiom == .phone){
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel",  comment: ""), style: .cancel, handler:nil))
        }else{
            //alertController = UIAlertController(title: "Appcoda", message: "Message in alert dialog", preferredStyle: UIAlertController.Style.actionSheet)
            alertController.popoverPresentationController?.sourceView = view
            alertController.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.width/2 , y: view.bounds.height/2, width: 0, height: 0)
            alertController.popoverPresentationController!.permittedArrowDirections = UIPopoverArrowDirection()
            
            // Present Alert as Popover for iPad
            //            alertController.modalPresentationStyle = UIModalPresentationStyle.popover
            //            let popover = alertController.popoverPresentationController
            //            popover?.sourceView = UIButton()
            //            popover?.sourceRect = CGRect(x:view.bounds.height/2, view.bounds.width/2, 0, 0)
            //            popover?.permittedArrowDirections = UIPopoverArrowDirection()
            
        }
        self.present(alertController, animated:true, completion: nil)
    }
    
    func shareTextImageAndURL(_ sharingText: String?, sharingImage: UIImage?,photoShareUrl: String?)
    {
        var shareText = ""
        var shareUrl = "none"
        var shareImage : UIImage?
        
        if let text = sharingText
        {
            shareText = text
        }
        if let image = sharingImage
        {
            shareImage = image
        }
        if let photoUrl = photoShareUrl
        {
            shareUrl = photoUrl
        }
        let jpgImage = shareImage?.jpegData(compressionQuality:0.8)
        
        let activityViewController = UIActivityViewController(activityItems: [shareText, URL(string: shareUrl)!, jpgImage], applicationActivities: nil)
        
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
            presentationController?.sourceView = view
            presentationController?.sourceRect = CGRect(x: view.bounds.width/2 , y: view.bounds.width/2, width: 0, height: 0)
            presentationController?.permittedArrowDirections = UIPopoverArrowDirection()
        }
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func updatePhoto(_ parameter: NSDictionary , url : String){
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            var dic = Dictionary<String, String>()
            for (key, value) in parameter{
                
                if let id = value as? NSNumber {
                    dic["\(key)"] = String(id as! Int)
                }
                
                if let receiver = value as? NSString {
                    dic["\(key)"] = receiver as String
                }
            }
            dic["oauth_consumer_secret"] = "\(oauth_consumer_secret)"
            
            
            var method:String
            
            if url.range(of: "delete") != nil{
                method = "DELETE"
            }else{
                method = "POST"
            }
            
            // Send Server Request to Explore Blog Contents with Blog_ID
            post(dic, url: "\(url)", method: method ) { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    updateUserData()
                    
                    if msg{
                        feedUpdate = true
                        advGroupDetailUpdate = true
                        pageDetailUpdate = true
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            groupUpdate = true
                            eventUpdate = true
                            if self.deletePhoto == true{
                                self.popAfterDelay = true
                                refreshPhotos = true
                                self.cancel()
                            }
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
    
    override func viewWillAppear(_ animated: Bool)
    {
        navigationController?.navigationBar.isHidden = true
        self.browseEmoji(contentItems: reactionsDictionary)
        if(updateComment == true)
        {
            let finalText = singlePluralCheck( NSLocalizedString(" Comment", comment: ""),  plural: NSLocalizedString(" Comments", comment: ""), count: total_Comments)
            commentCount.setTitle("\(finalText)", for: UIControl.State())
            commentUpdate()
            updateComment = false
            feedUpdate = true
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        contentfeedArrUpdate = true
        scrollViewEmoji.isHidden = true
        arrowView.isHidden = true
        scrollviewEmojiLikeView.isHidden = true
    }
    func commentUpdate(){
        let photoId = (photoForViewer[currentPage].photo_id)
        var total_comments = (photoForViewer[currentPage].comment_count)
        total_comments = total_comments! + 1
        
        for (index,value) in self.photoForViewer.enumerated(){
            if value.photo_id == photoId{
                let newDictionary:NSMutableDictionary = [:]
                newDictionary["image"] = value.image
                newDictionary["loading_flag"] = value.loading_flag
                newDictionary["photo_id"] = value.photo_id
                newDictionary["photo_description"] = value.photo_description
                newDictionary["comment_count"] = total_Comments
                newDictionary["menu"] = value.menu
                newDictionary["title"] = value.photo_title
                newDictionary["description"] = value.description
                newDictionary["like_count"] = value.likes_count
                newDictionary["is_like"] = value.is_like
                if value.reactions != nil{
                    newDictionary["reactions"] = value.reactions
                }
                if value.feed_reaction != nil{
                    newDictionary["feed_reactions"] = value.feed_reaction
                }
                if value.my_feed_reaction != nil{
                    newDictionary["my_feed_reaction"] = value.my_feed_reaction
                }
                var newData = PhotoViewer.loadPhotosInfoDictionary(newDictionary)
                self.photoForViewer[index] = newData[0] as PhotoViewer
            }
        }
    }
    
    @objc func cancel(){
        isPresented = false
        self.dismiss(animated: true, completion: nil)
    }
    
    func shareItem(){
        let pv = AdvanceShareViewController()
        pv.url = self.shareUrl
        pv.param = self.shareParam as! [AnyHashable : Any] as NSDictionary

        pv.Sharetitle = ""
        pv.ShareDescription = ""
        pv.imageString = self.currentImage

        pv.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        let nativationController = UINavigationController(rootViewController: pv)
        self.present(nativationController, animated:true, completion: nil)
        
    }
    
    @objc func shareAction(_ sender:UIButton){
        editPhoto = false
        let image = (photoForViewer[currentPage].image)
        let photoid = (photoForViewer[currentPage].photo_id!)
        
        let pv = AdvanceShareViewController()
        pv.url = "activity/share"
        pv.param = ["type":"album_photo", "id": "\(photoid)"]
        pv.Sharetitle = ""
        pv.ShareDescription = ""
        pv.imageString = image

        pv.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        let nativationController = UINavigationController(rootViewController: pv)
        self.present(nativationController, animated:true, completion: nil)
        
    }
    
    @objc func edit(){
        self.popover.dismiss()
        let photoId = (photoForViewer[currentPage].photo_id!)
        let photoTitle = (photoForViewer[currentPage].photo_title!)
        
        let font = UIFont(name: fontName, size: 15.0)
        var height = heightForView("\(self.editText.text)", font: font!, width: self.view.bounds.width)
        if height > 130{
            height = 130
        }
        if ReactionPlugin == true{
            self.bottomViewPhotoDescription.frame = CGRect(x: 0, y: self.view.frame.size.height - (height + 50 + 15 +  reactionsInfo.frame.size.height), width: self.view.bounds.width, height: height + 15)
        }
        else{
            self.bottomViewPhotoDescription.frame = CGRect(x: 0, y: self.view.frame.size.height - (height + 50 + 15), width: self.view.bounds.width, height: height + 15)
        }
        self.bottomViewPhotoDescription.text = "\(self.editText.text)"
        
        var parameters:NSDictionary!
        if self.currentMenu != nil{
            for menuItem in self.currentMenu{
                if let dic = menuItem as? NSDictionary{
                    if dic["name"] as! String ==  "edit"{
                        let urlString = dic["url"] as! String
                        if let param = dic["urlParams"] as? NSDictionary{
                            parameters = param
                        }
                        url = urlString
                        if Reachabable.isConnectedToNetwork() {
                            var dic = Dictionary<String, String>()
                            for (key, value) in parameters{
                                
                                if let id = value as? NSNumber {
                                    dic["\(key)"] = String(id as! Int)
                                }
                                
                                if let receiver = value as? NSString {
                                    dic["\(key)"] = receiver as String
                                }
                            }
                            
                            //                            dic["title"] =  ""
                            dic["title"] =  "\(photoTitle)"
                            dic["description"] = "\(editText.text)"
                            post(dic,url: url , method: "POST") { (succeeded, msg) -> () in
                                DispatchQueue.main.async(execute: {
                                    activityIndicatorView.stopAnimating()
                                    if msg{
                                        // On Sucess Update Blog
                                        if succeeded["message"] != nil{
                                            
                                            
                                            
                                            for (index,value) in self.photoForViewer.enumerated(){
                                                
                                                
                                                if value.photo_id == photoId{
                                                    
                                                    let newDictionary:NSMutableDictionary = [:]
                                                    newDictionary["image"] = value.image
                                                    newDictionary["loading_flag"] = value.loading_flag
                                                    newDictionary["photo_id"] = value.photo_id
                                                    newDictionary["comment_count"] = value.comment_count
                                                    newDictionary["menu"] = value.menu
                                                    //                                                    newDictionary["description"] = value.description
                                                    newDictionary["like_count"] = value.likes_count
                                                    newDictionary["title"] = "\(String(describing: value.photo_title))"
                                                    newDictionary["description"] = "\(self.editText.text)"
                                                    var newData = PhotoViewer.loadPhotosInfoDictionary(newDictionary)
                                                    self.photoForViewer[index] = newData[0] as PhotoViewer
                                                }
                                            }
                                        }
                                    }else{
                                        // Handle server Side Error
                                        if succeeded["message"] != nil{
                                        }
                                    }
                                })
                            }
                        }else{
                            // No Internet Connection Message
                            showToast(message: network_status_msg, controller: self)
                        }
                    }
                }
            }
        }
        editPhoto = false
    }
    
    func dismiss(){
        editPhoto = false
        popover.dismiss()
    }
    
    @objc func keyboardWillShow(_ sender: Foundation.Notification) {
        if editPhoto == true{
            if let userInfo = (sender as NSNotification).userInfo {
                let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue.size.height
                if keyboardHeight > 0 {

                    UIView.animate(withDuration: 0.5, animations: {
                        let startPoint = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height - keyboardHeight)
                        self.popover.show(self.popView, point: startPoint)
                        
                    })
                }
            }
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView)->UIView?
    {
        //        lightBoxImage.image = nil
        return scrollView.viewWithTag(111)
        
    }
    
    @objc func doubleTapped(_ sender:UITapGestureRecognizer)
    {
        let scroll = sender.view as! UIScrollView
        if scroll.zoomScale > 1.0
        {
            scroll.setZoomScale(1.0, animated:true);
        }
        else
        {
            let point = sender.location(in: scroll);
            scroll.zoom(to: CGRect(x: point.x-50, y: point.y-50, width: 100, height: 100), animated:true)
        }
    }
    
    @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
        scrollViewEmoji.isHidden = true
        arrowView.isHidden = true
        if photoViewerScrollView.tag == 0{
            photoViewerScrollView.tag = 1
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.bottomView.frame.origin.y = self.view.bounds.height
                self.bottomViewPhotoDescription.alpha = 0
                self.reactionsInfo.alpha = 0
                self.crossIcon.alpha = 0
                self.cross.alpha = 0
            })
        }
        else{
            if bottomViewShow == true{
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    self.bottomView.frame.origin.y = self.view.bounds.height - 50
                    self.bottomViewPhotoDescription.alpha = 1
                    self.reactionsInfo.alpha = 1
                    self.crossIcon.alpha = 1
                    self.cross.alpha = 1
                })
            }
            photoViewerScrollView.tag = 0
        }
    }
    
    func pinchDetected(_ pinchRecognizer: UIPinchGestureRecognizer) {
        let scale: CGFloat = pinchRecognizer.scale;
        
        for ob in photoViewerScrollView.subviews{
            if ob.tag == 111 {
                ob.transform = self.view.transform.scaledBy(x: scale, y: scale);
                pinchRecognizer.scale = 1.0;
            }
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
extension UIImage {
    var jpeg: Data? {
        return self.jpegData(compressionQuality:1.0)   // QUALITY min = 0 / max = 1
    }
    var png: Data? {
        return self.pngData()
    }
}
