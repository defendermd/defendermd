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

// AdvancePhotoViewController.swift
import UIKit
var isPresented = false

class AdvancePhotoViewController: UIViewController, UIGestureRecognizerDelegate, UIScrollViewDelegate, UITextViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var photoType:String!
    var photoID:Int!
    var photoForViewer:[PhotoViewer]!
    var myMenu : NSArray = []
    var deletePhoto:Bool!
    var popAfterDelay:Bool!
    
    var myTimer:Timer!
    var total_items:Int!
    var onceUpdate:Bool!
    var loadedImageCount:Int!
    var attachmentID:String = ""
    var currentImageArray = [String]()
    var likeCountArray = [Int]()
    var commentCountArray = [Int]()
    var photoAlbumId : String = ""
    var cross:UIButton!
    var url: String!
    var param: NSDictionary!
    var contentType:String! = ""
    var notShowComment = false
    var albumTitle : String!
    var ownerTitle : String!
    
    var advancedActivityFlag : Bool!
    var pageNumber:Int! = 1
    var currentMenu :NSArray!
    var tempObject = [AnyObject]()
    var currentImage : String!
    var like_Photo_Id:Int!
    var bottomViewShow : Bool = false
    var shareUrl : String!
    var photoShareUrl : String!
    var shareParam : NSDictionary!
    var imageUrl : String!
    var currentPhotoId : Int!
    var commentIncrement:Int!
    var updateComment:Bool! = false
    var upperViewInfo:UIView!
    var photoInfo1 : UILabel!
    var currentPage : Int!
    var bottomView : UIView!
    var likeCount : UIButton!
    var commentCount : UIButton!
    var likeShow = UIButton()
    var commentShow : UIButton!
    var shareShow : UIButton!
    var moreMenu1 : UIButton!
    var photoIdd : Int!
    var pageValue = 1
    var photoIDdd : Int!
    var requestPhoto : Bool! = false
    var photoLimit : Int! = 20
    var viewBorder : UIView!
    var lightBoxImage :UIImageView!
    var listingTypeId : Int!
    var listingPhotoId : Int!
    var pageId : Int!
    var albumId : Int!
    var photoId : Int!
    var groupId : Int!
    var reactionHeight : CGFloat! = 0
    var taggedHeight : CGFloat! = 0
    fileprivate var popover: Popover!
    fileprivate var popoverOptions: [PopoverOption] = [
        .type(.up),
        .blackOverlayColor(UIColor(white: 0.0, alpha: 0.6))
    ]
    var crossIcon : UIButton!
    var popView : UIView!
    var bottomViewPhotoDescription : UITextView!
    var editText : UITextView!
    var photoDescription = [String]()
    var photoTitle = [String]()
    var editPhoto : Bool = false
    var screenwidth : CGFloat!
    var screenheight : CGFloat!
    var currentPageoffset: CGFloat!
    var leftBarButtonItem : UIBarButtonItem!
    // Reaction Varibles
    var reactionShow = UIView()
    var likeWidth : CGFloat = 0.0
    var reactionsInfo =  UIView()
    var reactionsIcon = [AnyObject]()
    var taggedUserLabel : UIButton!
    var tagShowLabel : UIButton!
    var tagView : UIView!
    var tagsArrayCount = [Int]()
    var allphotos = [NSDictionary]()
    var collectionViewImages: UICollectionView!
    let collectionIdentifier = "collectionCell"
    var collectionViewLayout = UICollectionViewFlowLayout()
    private var dismissEmojiView: UITapGestureRecognizer?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if ReactionPlugin == true{
            self.browseEmoji(contentItems: reactionsDictionary)
        }
        requestPhoto = true
        photoIDdd = photoID
        
        
        // CollectionView Flow Layout Configuration
        collectionViewLayout.scrollDirection = .horizontal
        collectionViewLayout.minimumLineSpacing = 0.0
        collectionViewLayout.minimumInteritemSpacing = 0
        collectionViewLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionViewLayout.itemSize = CGSize(width: view.bounds.width, height: view.bounds.height)
        
        // CollectionView Initialization
        collectionViewImages = UICollectionView(frame:CGRect(x: 0.0, y: iphonXTopsafeArea, width: view.bounds.width, height: view.bounds.height-iphonXBottomsafeArea-50) , collectionViewLayout: collectionViewLayout)
        collectionViewImages.register(PhotoViewerCell.self, forCellWithReuseIdentifier: collectionIdentifier)
        collectionViewImages.backgroundColor = .clear
        collectionViewImages.dataSource = self
        collectionViewImages.delegate = self
        collectionViewImages.alwaysBounceHorizontal = true
        view.addSubview(collectionViewImages)
        
        let recognizer = UITapGestureRecognizer(target: self, action:#selector(AdvancePhotoViewController.handleTap(_:)))
        recognizer.delegate = self
        collectionViewImages.addGestureRecognizer(recognizer)
        
        // Do any additional setup after loading the view.
        if contentType == "product_photo"{
            self.view.backgroundColor = UIColor.white
        }
        else{
            self.view.backgroundColor = UIColor.black
        }
        if let tabBarObject = self.tabBarController?.tabBar
        {
            tabBarObject.isHidden = true
            
        }
        popAfterDelay = false
        refreshPhotos = false
        
        onceUpdate = false
        like_Photo_Id = 0
        isPresented = true
        
        switch(photoType){
        case "photo":
            contentType = "album_photo"
        case "photo_albim":
            contentType = "photo"
            photoType = "photo"
        case "group_photo":
            contentType = "group_photo"
        case "event_photo":
            contentType = "event_photo"
        case "sitereview_photo":
            contentType = "listings"
        case "sitepage_photo":
            contentType = "sitepage_photo"
        case "product_photo":
            contentType = "product_photo"
        case "sitegroup_photo":
            contentType = "sitegroup_photo"
            
        default:
            print("error")
        }
        
        lightBoxImage  = UIImageView(frame:view.frame);
        lightBoxImage.contentMode = UIView.ContentMode.scaleAspectFit
        lightBoxImage.clipsToBounds = true;
        lightBoxImage.layer.shadowColor = UIColor.black.cgColor
        lightBoxImage.isHidden = false
        let coverImageUrl = URL(string: imageUrl)
        self.lightBoxImage.kf.indicatorType = .activity
        (self.lightBoxImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
        self.lightBoxImage.kf.setImage(with: coverImageUrl, placeholder: UIImage(named : "album-default.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
            
        })
        
        loadedImageCount = 0
        currentPage = loadedImageCount
        photoIdd = self.photoID + currentPage
        
        if logoutUser == true {
            notShowComment = true
        }
        
        upperViewInfo = createView(CGRect(x:0, y:0, width:self.view.bounds.width, height:60), borderColor: borderColorClear, shadow: false)
        if (albumTitle != nil){
            if ownerTitle != nil {
                if(albumTitle == "" && ownerTitle == ""){
                    upperViewInfo = createView(CGRect(x: 0, y: 0+iphonXTopsafeArea, width: self.view.bounds.width, height: 60), borderColor: borderColorClear, shadow: false)
                }
                upperViewInfo = createView(CGRect(x: 0, y: 0+iphonXTopsafeArea, width: self.view.bounds.width, height: 100), borderColor: borderColorClear, shadow: false)
            }
        }
        upperViewInfo.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        upperViewInfo.isHidden = false
        view.addSubview(upperViewInfo)
        
        cross =  createButton(CGRect(x: 15, y: 10, width: 40, height: 70), title: "", border: false,bgColor: false, textColor: textColorLight)
        cross.setImage(UIImage(named: "cross_icon")!.maskWithColor(color: textColorLight), for: UIControl.State())
        cross.titleLabel?.font = UIFont(name: "FontAwesome", size: 20)
        cross.addTarget(self, action: #selector(AdvancePhotoViewController.cancel), for: .touchUpInside)
        upperViewInfo.addSubview(cross)
        
        
        photoInfo1 = createLabel(CGRect(x: 10,y: 20,width: view.bounds.width - 110 , height: 70), text: "", alignment: .center, textColor: textColorLight)
        photoInfo1.numberOfLines = 0
        photoInfo1.font = UIFont(name: fontName , size: FONTSIZENormal )
        photoInfo1.center = upperViewInfo.center
        if DeviceType.IS_IPHONE_X{
            photoInfo1.frame.origin.y = 15
        }
        upperViewInfo.addSubview(photoInfo1)
        
        taggedUserLabel =  createButton(CGRect(x: view.bounds.width - 70, y: 10, width: 40, height: 70), title: "", border: false,bgColor: false, textColor: navColor)
        taggedUserLabel.titleLabel?.font = UIFont(name: "FontAwesome", size: 20)
        taggedUserLabel.setTitle("\(taggedIcon)", for: UIControl.State())
        taggedUserLabel.addTarget(self, action: #selector(AdvancePhotoViewController.showTag(_:)), for: .touchUpInside)
        taggedUserLabel.isHidden = true
        upperViewInfo.addSubview(taggedUserLabel)
        if contentType != "album_photo"
        {
            taggedUserLabel.isHidden = true
        }
        
        // For showing tagged user on Bottom
        tagView =  createView(CGRect(x: 0, y: view.frame.size.height - 90 - iphonXBottomsafeArea, width: view.bounds.width, height: 35), borderColor: UIColor.clear, shadow: false)
        tagView.backgroundColor = UIColor.clear
        view.addSubview(tagView)
        
        // For showing tagged user on Bottom
        tagShowLabel =  createButton(CGRect(x: 0, y: 5, width: view.bounds.width, height: 30), title: "", border: false,bgColor: false, textColor: navColor)
        tagShowLabel.titleLabel?.font = UIFont(name: fontNormal, size: 15)
        tagShowLabel.contentHorizontalAlignment = .left
        tagShowLabel.titleEdgeInsets.left = 10
        tagShowLabel.isHidden = true
        tagShowLabel.addTarget(self, action: #selector(AdvancePhotoViewController.showTagUser(_:)), for: .touchUpInside)
        tagView.addSubview(tagShowLabel)
        
        // For showing bottom bar for Like, comment, reaction and more options
        bottomViewPhotoDescription = createTextView(CGRect(x: 0, y: view.frame.size.height - 70 - iphonXBottomsafeArea, width: view.bounds.width, height: 10), borderColor: borderColorClear , corner: false )
        bottomViewPhotoDescription.backgroundColor = UIColor.clear
        bottomViewPhotoDescription.textColor = textColorLight
        bottomViewPhotoDescription.font = UIFont(name: fontName, size: 15.0)
        bottomViewPhotoDescription.isEditable = false
        bottomViewPhotoDescription.isHidden = true
        view.addSubview(bottomViewPhotoDescription)
        self.automaticallyAdjustsScrollViewInsets = false
        
        bottomView =  createView(CGRect(x: 0, y: view.frame.size.height - 50 - iphonXBottomsafeArea, width: view.bounds.width, height: 50), borderColor: UIColor.clear, shadow: false)
        bottomView.backgroundColor = UIColor.black
        if notShowComment == false {
            view.addSubview(bottomView)
        }
        
        viewBorder = UIView(frame:CGRect(x: 0, y: 0, width: view.bounds.width, height: 0.5))
        viewBorder.backgroundColor = UIColor.white
        bottomView.addSubview(viewBorder)
        bottomView.isHidden = true
        // check whether Reaction Plugin is Enable or not
        if ReactionPlugin == true{
            reactionShow =  createView(CGRect(x: 0, y: 0.5, width: 70, height: 50), borderColor: UIColor.clear, shadow: false)
            reactionShow.backgroundColor = UIColor.black
            bottomView.addSubview(reactionShow)
            likeWidth = 70
        }
        else{
            likeShow = createButton(CGRect(x: 0,y: 0.5, width: 40, height: 50), title: "", border: false,bgColor: false, textColor: textColorLight)
            likeShow.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZELarge)
            likeShow.setTitle("\(likeIcon)", for: UIControl.State())
            likeShow.addTarget(self, action: #selector(AdvancePhotoViewController.like_unLikeAction(_:)), for: UIControl.Event.touchUpInside)
            bottomView.addSubview(likeShow)
            likeWidth = 40
        }
        
        commentShow = createButton(CGRect(x: likeWidth,y: 0.5, width: 40, height: 50), title: "", border: false,bgColor: false, textColor: textColorLight)
        commentShow.setTitle("\(commentIcon)", for: UIControl.State())
        commentShow.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZELarge)
        commentShow.addTarget(self, action: #selector(AdvancePhotoViewController.commentAction(_:)), for: UIControl.Event.touchUpInside)
        bottomView.addSubview(commentShow)
        
        // Share icon on bottom
        shareShow = createButton(CGRect(x: getRightEdgeX(inputView: commentShow),y: 0.5, width: 40, height: 50), title: "", border: false,bgColor: false, textColor: textColorLight)
        shareShow.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZELarge)
        shareShow.setTitle("\(shareIcon)", for: UIControl.State())
        shareShow.addTarget(self, action: #selector(AdvancePhotoViewController.shareAction(_:)), for: UIControl.Event.touchUpInside)
        bottomView.addSubview(shareShow)
        
        // More icon on bottom
        moreMenu1 = createButton(CGRect(x: getRightEdgeX(inputView: shareShow),y: 0.5, width: 40, height: 50), title: "", border: false,bgColor: false, textColor: textColorLight)
        moreMenu1.titleLabel?.font = UIFont(name: "FontAwesome", size: 25.0)
        moreMenu1.setTitle("\(optionIcon)", for: UIControl.State())
        moreMenu1.addTarget(self, action: #selector(AdvancePhotoViewController.moreMenu), for: .touchUpInside)
        moreMenu1.isHidden = false
        bottomView.addSubview(moreMenu1)
        
        // Like count on bottom right most
        likeCount = createButton(CGRect(x: view.bounds.width-100,y: 0.5, width: 100, height: 24), title: "", border: false,bgColor: false, textColor: textColorLight)
        likeCount.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
        likeCount.tag = 22
        likeCount.addTarget(self, action: #selector(AdvancePhotoViewController.commentAction(_:)), for: UIControl.Event.touchUpInside)
        bottomView.addSubview(likeCount)
        
        // Comment count on bottom right most
        commentCount = createButton(CGRect(x: view.bounds.width-100,y: 25, width: 100, height: 25), title: "", border: false,bgColor: false, textColor: textColorLight)
        commentCount.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
        commentCount.tag = 23
        commentCount.addTarget(self, action: #selector(AdvancePhotoViewController.commentAction(_:)), for: UIControl.Event.touchUpInside)
        bottomView.addSubview(commentCount)
        
        if (albumTitle != nil){
            if ownerTitle != nil {
                if( albumTitle != "" && ownerTitle != ""){
                    
                    let simpleText : String = "By " + ownerTitle + "\n" + albumTitle + "\n"
                    let photoText : String = simpleText + String(photoIdd + 1) + " - " + String(total_items)
                    photoInfo1.text = photoText
                    
                }
                else{
                    photoInfo1.text = String(photoIdd + 1) + " - " + String(total_items)
                }
            }
            else{
                photoInfo1.text = String(photoIdd + 1) + " - " + String(total_items)
            }
        }
        else{
            self.photoInfo1.text = String(photoIdd + 1) + " - " + String(total_items)
        }
        
        
        popView = createView(CGRect(x: 0, y: 10+iphonXTopsafeArea, width: self.view.bounds.width, height: self.view.frame.size.height * 0.35), borderColor: borderColorClear, shadow: false)
        popView.backgroundColor = UIColor.white
        
        let upperPopViewInfo = createView(CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 40), borderColor: borderColorClear, shadow: false)
        upperPopViewInfo.backgroundColor = bgColor
        upperPopViewInfo.isHidden = false
        popView.addSubview(upperPopViewInfo)
        
        let editLabel = createLabel(CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 40), text: "Edit Photo", alignment: .center, textColor: textColorDark)
        upperPopViewInfo.addSubview(editLabel)
        
        crossIcon =  createButton(CGRect(x: 15, y: 0, width: 60, height: 40), title: "Cancel", border: false,bgColor: false, textColor: textColorLight)
        crossIcon.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZELarge)
        crossIcon.addTarget(self, action: #selector(AdvancePhotoViewController.dismiss2), for: .touchUpInside)
        //upperPopViewInfo.addSubview(crossIcon)
        
        let done =  createButton(CGRect(x: popView.bounds.width - 60, y: 0, width: 60, height: 40), title: "Done", border: false,bgColor: false, textColor: navColor)
        done.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZELarge)
        done.addTarget(self, action: #selector(AdvancePhotoViewController.edit), for: .touchUpInside)
        upperPopViewInfo.addSubview(done)
        
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(AdvancePhotoViewController.cancel))
        downSwipe.direction = .down
        view.addGestureRecognizer(downSwipe)
        
        if ReactionPlugin == true{
            reactionsInfo = createView(CGRect(x: 5,y: view.frame.size.height - 80 - iphonXBottomsafeArea ,width: 100 , height: 30), borderColor: UIColor.clear, shadow: false)
            reactionsInfo.backgroundColor =  UIColor.clear
            reactionsInfo.isHidden = false
            view.addSubview(reactionsInfo)
        }
        
        editText = createTextView(CGRect(x: 10,y: 50,width: self.view.bounds.width-20,height: self.view.frame.size.height * 0.45 - 40), borderColor: borderColorClear , corner: false )
        editText.becomeFirstResponder()
        editText.backgroundColor = UIColor.white
        editText.delegate = self
        editText.backgroundColor = UIColor.clear
        editText.textColor = textColorDark
        editText.font = UIFont(name: fontName, size: FONTSIZELarge)
        editText.autocorrectionType = UITextAutocorrectionType.no
        popView.addSubview(editText)
        
        if allphotos.count != 0
        {
            self.photoForViewer.removeAll(keepingCapacity: false)
            self.photoForViewer = PhotoViewer.loadPhotosInfo(self.allphotos as NSArray)
            self.currentImageArray.removeAll(keepingCapacity: false)
            for id in 0  ..< self.photoForViewer.count  {
                
                self.currentImageArray.append(self.photoForViewer[id].image!)
                
                if let photo_description = self.photoForViewer[id].photo_description
                {
                    self.photoDescription.append(photo_description)
                }
                if let photo_title = self.photoForViewer[id].photo_title
                {
                    self.photoTitle.append(photo_title)
                }
                if self.notShowComment == false
                {
                    if let like_count = self.photoForViewer[id].likes_count
                    {
                        self.likeCountArray.append(like_count)
                    }
                    if let comment_count = self.photoForViewer[id].comment_count
                    {
                        self.commentCountArray.append(comment_count)
                    }
                }
            }
            if self.contentType == "product_photo"{
                self.bottomView.isHidden = false
                self.reactionShow.isHidden = true
                self.likeShow.isHidden = true
                self.commentShow.isHidden = true
                self.likeCount.isHidden = true
                self.commentCount.isHidden = true
                shareShow.frame.origin.x = view.bounds.width/2 - 50
                moreMenu1.frame.origin.x = view.bounds.width/2
            }
            else{
                self.bottomView.isHidden = false
            }
            bottomViewShow = true
            if photoID == 0
            {
                UItoShowLikes()
            }
            
            collectionViewImages.scrollToItem(at:IndexPath(item: photoID, section: 0), at: .right, animated: false)
            
        }
        else
        {
            explorePic()
        }
        
        self.edgesForExtendedLayout = UIRectEdge.all;
        self.automaticallyAdjustsScrollViewInsets = false
        
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
        
        if photoForViewer.count > self.currentPage {
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
                            let titleReaction = myReaction["caption"] as! String
                            let  title =  NSLocalizedString("\(titleReaction)", comment: "")
                            if let myIcon = myReaction["reaction_image_icon"] as? String{
                                let ImageView = createButton(CGRect(x: 0,y: 12,width: 25,height: 25), title: "", border: false, bgColor: false, textColor: textColorLight)
                                ImageView.imageEdgeInsets =  UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
                                ImageView.tag = 300
                                let imageUrl = myIcon
                                let url = NSURL(string:imageUrl)
                                ImageView.kf.setImage(with: url as URL?, for: .normal, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                                    
                                })
                                self.reactionShow.addSubview(ImageView)
                                ImageView.addTarget(self, action: #selector(AdvancePhotoViewController.like_unLikeAction(_:)), for: .touchUpInside)
                                let menu = createButton(CGRect(x: 20, y: 0, width: reactionShow.frame.size.width - 20,height: 50), title: " \(title)", border: false,bgColor: false, textColor: textColorMedium )
                                menu.addTarget(self, action: #selector(AdvancePhotoViewController.like_unLikeAction(_:)), for: UIControl.Event.touchUpInside)
                                let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(AdvancePhotoViewController.longPressed(sender:)))
                                menu.addGestureRecognizer(longPressRecognizer)
                                menu.tag = 200
                                menu.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
                                menu.titleLabel?.font = UIFont(name: fontName, size: FONTSIZENormal)
                                menu.titleLabel?.adjustsFontSizeToFitWidth = true
                                self.reactionShow.addSubview(menu)
                                likeWidth = 60
                                commentShow.frame.origin.x = likeWidth
                                if self.contentType == "product_photo"{
                                    shareShow.frame.origin.x = view.bounds.width/2 - 30
                                    moreMenu1.frame.origin.x = view.bounds.width/2 + 30
                                }
                                else{
                                    shareShow.frame.origin.x = getRightEdgeX(inputView: commentShow)
                                    moreMenu1.frame.origin.x = getRightEdgeX(inputView: shareShow)
                                }
                            }
                        }
                    }
                    else{
                        self.likeShow.setTitleColor(navColor, for: UIControl.State())
                    }
                }
                else{
                    if ReactionPlugin == true{
                        for ob in self.reactionShow.subviews{
                            if ob.tag == 200 || ob.tag == 300{
                                ob.removeFromSuperview()
                            }
                        }
                        let  menu = createButton(CGRect(x: 0,y: 0, width: 40, height: 50), title: "", border: false,bgColor: false, textColor: textColorLight)
                        menu.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZELarge)
                        menu.setTitle("\(likeIcon)", for: UIControl.State())
                        menu.addTarget(self, action: #selector(AdvancePhotoViewController.like_unLikeAction(_:)), for: UIControl.Event.touchUpInside)
                        menu.tag = 200
                        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(AdvancePhotoViewController.longPressed(sender:)))
                        menu.addGestureRecognizer(longPressRecognizer)
                        self.reactionShow.addSubview(menu)
                        likeWidth = 40
                        commentShow.frame.origin.x = likeWidth
                        if self.contentType == "product_photo"{
                            shareShow.frame.origin.x = view.bounds.width/2 - 25
                            moreMenu1.frame.origin.x = view.bounds.width/2 + 25
                        }
                        else{
                            shareShow.frame.origin.x = getRightEdgeX(inputView: commentShow)
                            moreMenu1.frame.origin.x = getRightEdgeX(inputView: shareShow)
                        }
                    }
                    else{
                        self.likeShow.setTitleColor(textColorLight, for: UIControl.State())
                    }
                }
            }
            if ReactionPlugin ==  true{
                for ob in (reactionsInfo.subviews){
                    ob.removeFromSuperview()
                }
                var origin_x:CGFloat = 0.0
                reactionsIcon.removeAll(keepingCapacity: false)
                if (self.photoForViewer[self.currentPage].reactions) != nil{
                    let reactionsof = (self.photoForViewer[self.currentPage].reactions)
                    if let reactions = reactionsof?["feed_reactions"] as? NSDictionary{
                        var menuWidth = CGFloat()
                        var i : Int = 0
                        for (_,value) in reactions
                        {
                            if let reaction = value as? NSDictionary{
                                if i <= 2
                                {
                                    if (reaction["reaction_image_icon"] as? String) != nil{
                                        menuWidth = 13
                                        let   emoji = createButton(CGRect(x: origin_x ,y: 3,width: menuWidth,height: 18), title: "", border: false, bgColor: false, textColor: textColorLight)
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
                                        emoji.addTarget(self, action: #selector(AdvancePhotoViewController.commentAction(_:)), for: UIControl.Event.touchUpInside)
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
                if let  likes = (self.photoForViewer[self.currentPage].likes_count)
                {
                    if isLike == true
                    {
                        if likes == 1
                        {
                            infoTitle =  String(format: NSLocalizedString("You reacted on this", comment: ""),likes)
                        }
                        else if likes == 2
                        {
                            infoTitle =  String(format: NSLocalizedString(" You and %d other reacted ", comment: ""),likes - 1)
                        }
                        else if likes > 2
                        {
                            infoTitle =  String(format: NSLocalizedString(" You and %d others reacted ", comment: ""),likes - 1)
                        }
                    }
                    else
                    {
                        if likes >= 1
                        {
                            infoTitle =  String(format: NSLocalizedString("%d ", comment: ""),likes)
                        }
                    }
                }
                
                let likeCommentInfo = createButton(CGRect(x: origin_x + 5 ,y: 0 ,width: 200 , height: 30), title: "", border: false,bgColor: false, textColor: textColorMedium)
                likeCommentInfo.titleLabel?.font = UIFont(name: fontName , size: FONTSIZESmall)
                likeCommentInfo.tag = 22
                likeCommentInfo.addTarget(self, action: #selector(AdvancePhotoViewController.commentAction(_:)), for: UIControl.Event.touchUpInside)
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
                if infoTitle == ""{
                    reactionsInfo.frame.size.height = 0
                }
                else{
                    reactionsInfo.frame.size.height = 30
                }
                reactionHeight = reactionsInfo.frame.size.height
            }
            
            if let likecount = self.photoForViewer[self.currentPage].likes_count{
                let finalText = singlePluralCheck( NSLocalizedString(" Like", comment: ""),  plural: NSLocalizedString(" Likes", comment: ""), count: likecount)
                self.likeCount.setTitle("\(finalText)", for: UIControl.State())
            }
            if let commentcount = self.photoForViewer[self.currentPage].comment_count{
                let finalText = singlePluralCheck( NSLocalizedString(" Comment", comment: ""),  plural: NSLocalizedString(" Comments", comment: ""), count: commentcount)
                self.commentCount.setTitle("\(finalText)", for: UIControl.State())
            }
            
            
            
            // Start code for tagged user work
            if let tagsArray = photoForViewer[currentPage].tags{
                self.tagView.isHidden = false
                tagView.frame.size.height = 35
                var firstTag = ""
                if tagsArray.count > 0{
                    if let listingMain = tagsArray[0] as? NSDictionary{
                        if let listing = listingMain["text"] as? String {
                            firstTag = listing
                        }
                    }
                    tagView.frame.origin.y = self.view.frame.size.height - (50 + self.reactionHeight + tagView.frame.size.height + iphonXBottomsafeArea)
                    let tagCount = tagsArray.count
                    tagShowLabel.isHidden = false
                    switch(tagCount){
                    case 1:
                        self.tagShowLabel.setTitle("- with \(firstTag)", for: UIControl.State())
                    case 2:
                        self.tagShowLabel.setTitle("- with \(firstTag)"+" and \((tagsArray.count) - 1) other", for: UIControl.State())
                    default:
                        self.tagShowLabel.setTitle("- with \(firstTag)"+" and \((tagsArray.count) - 1) others", for: UIControl.State())
                    }
                    
                }
                else{
                    tagShowLabel.isHidden = true
                }
            }
            else{
                self.tagView.isHidden = true
                tagView.frame.size.height = 0
            }
            taggedHeight = tagView.frame.size.height
            // finish work for tagged user work
            if let photoDescription = self.photoForViewer[self.currentPage].photo_description{
                if photoDescription != ""{
                    let font = UIFont(name: fontName, size: 15.0)
                    var height = heightForView(photoDescription, font: font!, width: self.view.bounds.width)
                    if height > 130{
                        height = 130
                    }
                    var cal = self.view.frame.size.height
                    cal -= (height + 65 + self.reactionHeight + self.taggedHeight + iphonXBottomsafeArea)
                    
                    self.bottomViewPhotoDescription.frame = CGRect(x: 0, y: CGFloat(cal), width: self.view.bounds.width, height: height + 15)
                    
                    self.bottomViewPhotoDescription.isHidden = false
                    self.bottomViewPhotoDescription.text = photoDescription
                }
                else{
                    self.bottomViewPhotoDescription.isHidden = true
                }
            }
        }
    }
    
    
    // MARK: Start code for when Reaction Plugin is enabled
    
    // View of all possible reactions that we can like
    
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
            scrollViewEmoji.backgroundColor = UIColor.white
            arrowView.backgroundColor = UIColor.white
            //                scrollViewEmoji.layer.borderWidth = 2.0
            //                scrollViewEmoji.layer.borderColor = aafBgColor.cgColor  //UIColor.red.cgColor //tableViewBgColor.cgColor
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
                        emoji.addTarget(self, action: #selector(AdvancePhotoViewController.feedMenuReactionLikes(sender:)), for: .touchUpInside)
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
        }
    }
    
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
        arrowView.backgroundColor = UIColor.clear
        view.removeGestureRecognizer(recognizer)
    }
    
    func animateReaction() {
        arrowView.isHidden = true
        let frame = CGRect(x: 0, y: 0, width: 70, height: 70)
        let image = reactionButtonImage.imageView?.image
        let imageView = UIImageView(frame: frame)
        imageView.image = image
        imageView.center = (self.view.parentViewController()?.view.center)!
        imageView.isHidden = false
        view.addSubview(imageView)
        view.bringSubviewToFront(imageView)
        
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
        arrowView.isHidden = true
        let photoId = (photoForViewer[currentPage].photo_id!)
        var reaction = ""
        animateReaction()
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
                    var url = ""
                    url = "advancedcomments/like"
                    DispatchQueue.main.async(execute: {
                        soundEffect("Like")
                    })
                    updateReactions(url: url,reaction : reaction,subject_id  : "\(photoId)", updateMyReaction : updatedDictionary as NSDictionary,feedIndex: scrollViewEmoji.tag,subject_type : photoType,updateType : "update")
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
                newDictionary["title"] = value.photo_title
                newDictionary["menu"] = value.menu
                newDictionary["description"] = value.description
                newDictionary["tags"] = value.tags
                let changedDictionary : NSMutableDictionary = [:]
                changedDictionary.removeAllObjects()
                var addDictionary : Bool! = false
                switch(updateTypeString) {
                case  "update" :
                    newDictionary["is_like"] = value.is_like
                    newDictionary["like_count"] = value.likes_count!
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
                        // when ot like alredy
                    else
                    {
                        addDictionary = true
                        newDictionary["is_like"] = true
                        if (value.likes_count != nil){
                            newDictionary["like_count"] = value.likes_count! + 1
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
                    newDictionary["like_count"] = value.likes_count! - 1
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
                newDictionaryReaction["feed_reactions"] = changedDictionary
                newDictionary["reactions"] = newDictionaryReaction
                
                var newData = PhotoViewer.loadPhotosInfoDictionary(newDictionary)
                self.photoForViewer[index] = newData[0] as PhotoViewer
                
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
                            showToast(message: network_status_msg, controller: self, onView: false, time: 5.0)
                        }
                        
                    }
                })
            }
        }
        else
        {
            showToast(message: network_status_msg, controller: self, onView: false, time: 5.0)
        }
    }
    
    // MARK: Finish code for when Reaction Plugin is enabled
    
    override func viewWillAppear(_ animated: Bool) {
        //        explorePic()
        self.browseEmoji(contentItems: reactionsDictionary)
        navigationController?.navigationBar.isHidden = true
        
        if let tabBarObject = self.tabBarController?.tabBar
        {
            tabBarObject.isHidden = true
            
        }
        
        if(updateComment == true){
            let finalText = singlePluralCheck( NSLocalizedString(" Comment", comment: ""),  plural: NSLocalizedString(" Comments", comment: ""), count: total_Comments)
            commentCount.setTitle("\(finalText)", for: UIControl.State())
            commentUpdate()
            updateComment = false
            if photoForViewer.count > self.currentPage
            {
                let value = self.photoForViewer[self.currentPage]
                value.comment_count = total_Comments
                self.photoForViewer[self.currentPage] = value
                
            }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        scrollViewEmoji.isHidden = true
        arrowView.isHidden = true
        scrollviewEmojiLikeView.isHidden = true
        if let tabBarObject = self.tabBarController?.tabBar
        {
            tabBarObject.isHidden = false
            
        }
        setNavigationImage(controller: self)
        
    }
    
    @objc func showTag(_ sender:UIButton){
        let photoId = (photoForViewer[currentPage].photo_id!)
        let presentedVC = TaggingViewController()
        presentedVC.contentType = "album_photo"
        presentedVC.photoTagId = photoId
        presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        let nativationController = UINavigationController(rootViewController: presentedVC)
        self.present(nativationController, animated:true, completion: nil)
        
    }
    @objc func showTagUser(_ sender:UIButton){
        let photoId = (photoForViewer[currentPage].tags!)
        let presentedVC = TagListViewController()
        presentedVC.contentType = ""
        presentedVC.blogResponse = photoId as [AnyObject]
        self.navigationController?.pushViewController(presentedVC, animated: true)
    }
    
    func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
        
        return true
    }
    var flip = 0
    @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
        scrollViewEmoji.isHidden = true
        arrowView.isHidden = true
        let tempHeight =  upperViewInfo.frame.size.height
        
        if flip == 0{
            flip = 1
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.bottomView.frame.origin.y = self.view.bounds.height
                self.upperViewInfo.frame.origin.y = -tempHeight
                self.bottomViewPhotoDescription.alpha = 0
                self.crossIcon.alpha = 0
                self.cross.alpha = 0
                self.reactionsInfo.alpha = 0
            })
        }
        else{
            if bottomViewShow == true{
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    self.bottomView.frame.origin.y = self.view.bounds.height - 50 - iphonXTopsafeArea
                    self.upperViewInfo.frame.origin.y = 0 + iphonXTopsafeArea
                    self.bottomViewPhotoDescription.alpha = 1
                    self.crossIcon.alpha = 1
                    self.cross.alpha = 1
                    self.reactionsInfo.alpha = 1
                })
            }
            flip = 0
            upperViewInfo.isHidden = false
        }
        
    }
    
    @objc func cancel(){
        // PhotoViewer.getDictionaryFromPhotoViewer(photoForViewer)
        PhotoViewer.getDictionaryFromPhotoViewer(photoForViewer)
        isPresented = false
        _ = self.navigationController?.popViewController(animated: false)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // Generate Custom Alert Messages
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
    // Stop Timer
    @objc func stopTimer() {
        stop()
        if popAfterDelay == true {
            cancel()
        }
    }
    
    
    @objc func dismiss2(){
        
        editPhoto = false
        popover.dismiss()
    }
    
    @objc func keyboardWillShow(_ sender: Foundation.Notification) {
        
        if editPhoto == true{
            if let userInfo = (sender as NSNotification).userInfo {
                let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue.size.height
                if keyboardHeight != 0 {
                    let startPoint = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height - keyboardHeight)
                    self.popover.show(self.popView, point: startPoint)
                }
            }
        }
    }
    
    @objc func edit(){
        editPhoto = false
        self.popover.dismiss()
        let photoId = (photoForViewer[currentPage].photo_id!)
        let photoTitle = (photoForViewer[currentPage].photo_title!)
        
        let font = UIFont(name: fontName, size: 15.0)
        var height = heightForView(self.editText.text, font: font!, width: self.view.bounds.width)
        if height > 130{
            height = 130
        }
        
        var cal = view.frame.size.height
        cal -= (height + 65 + reactionHeight + taggedHeight + iphonXBottomsafeArea)
        
        bottomViewPhotoDescription.frame = CGRect(x: 0, y: CGFloat(cal), width: view.bounds.width, height: height + 15)
        
        if self.editText.text != ""{
            bottomViewPhotoDescription.isHidden = false
        }
        else{
            bottomViewPhotoDescription.isHidden = true
            
        }
        
        self.bottomViewPhotoDescription.text = self.editText.text
        
        if self.currentMenu != nil{
            for menuItem in self.currentMenu{
                if let dic = menuItem as? NSDictionary{
                    if dic["name"] as! String ==  "edit"{
                        let urlString = dic["url"] as! String
                        
                        url = urlString
                        //print(url)
                        //print(editText.text)
                        if Reachabable.isConnectedToNetwork() {
                            var dic = Dictionary<String, String>()
                            
                            dic["title"] =  photoTitle
                            dic["description"] = editText.text
                            dic["photo_id"] = String(photoId)
                            dic["album_id"] = attachmentID
                            post(dic,url: url , method: "POST") { (succeeded, msg) -> () in
                                DispatchQueue.main.async(execute: {
                                    
                                    // activityIndicatorView.stopAnimating()
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
                                                    newDictionary["photo_description"] = self.editText.text
                                                    newDictionary["comment_count"] = value.comment_count
                                                    newDictionary["menu"] = value.menu
                                                    newDictionary["title"] = value.photo_title
                                                    newDictionary["like_count"] = value.likes_count
                                                    newDictionary["description"] = self.editText.text
                                                    newDictionary["tags"] = value.tags
                                                    var newData = PhotoViewer.loadPhotosInfoDictionary(newDictionary)
                                                    self.photoForViewer[index] = newData[0] as PhotoViewer
                                                }
                                                
                                            }
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
        
        
    }
    
    func exploreMorePhotos(){
        // Check Internet Connection
        
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
            userInteractionOff = false
            self.view.isUserInteractionEnabled = false
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            var tempUrl : String
            if (self.url != nil && self.url != ""){
                tempUrl = self.url
            }else if(self.contentType == "sitepage_photo"){
                
                tempUrl = "sitepage/photos/viewphoto/\(pageId)/\(albumId)/\(photoId)"
            }
            else if self.contentType == "sitegroup_photo"{
                tempUrl = "advancedgroups/photos/viewphoto/\(groupId!)/\(albumId!)/\(photoId!)"
            }
            else{
                tempUrl = "albums/photo/list"
            }
            
            
            var dic = Dictionary<String, String>()
            if (param != nil && param.count > 0) {
                for (key, value) in param{
                    
                    if let id = value as? NSNumber {
                        dic["\(key)"] = String(id as! Int)
                    }
                    
                    if let receiver = value as? NSString {
                        dic["\(key)"] = receiver as String
                    }
                }
            }
            if pageValue * photoLimit >= total_items{
                pageValue = 1
            }
            else{
                pageValue = pageValue + 1
            }
            
            dic["page"] = "\(pageValue)"
            dic["limit"] = String(photoLimit)
            dic["menu"] = "1"
            dic["album_id"] = attachmentID
            if self.contentType == "listings"{
                
                dic["listingtype_id"] = String(listingTypeId)
            }
            
            // Send Server Request to Explore Group Contents with Group_ID
            post(dic, url: tempUrl, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    
                    userInteractionOff = true
                    self.view.isUserInteractionEnabled = true
                    activityIndicatorView.stopAnimating()
                    if msg{
                        
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        
                        if succeeded["body"] != nil{
                            
                            if let body = succeeded["body"] as? NSDictionary{
                                
                                if let images = body["images"] as? NSArray{
                                    self.photoForViewer = self.photoForViewer + PhotoViewer.loadPhotosInfo(images)
                                }
                                else if let images = body["photos"] as? NSArray{
                                    self.photoForViewer = self.photoForViewer + PhotoViewer.loadPhotosInfo(images)
                                }
                                else if let images = body["albumPhotos"] as? NSArray{
                                    self.photoForViewer = self.photoForViewer + PhotoViewer.loadPhotosInfo(images)
                                }
                                
                                
                                
                                let i:Int =  self.loadedImageCount
                                
                                for id in i  ..< self.photoForViewer.count  {
                                    
                                    self.photoDescription.append(self.photoForViewer[id].photo_description!)
                                    self.photoTitle.append(self.photoForViewer[id].photo_title!)
                                    self.currentImageArray.append(self.photoForViewer[id].image!)
                                    self.likeCountArray.append(self.photoForViewer[id].likes_count!)
                                    self.commentCountArray.append(self.photoForViewer[id].comment_count!)
                                    
                                }
                                if let tagsArray = self.photoForViewer[self.currentPage].tags{
                                    self.tagView.isHidden = false
                                    var firstTag = ""
                                    
                                    
                                    if tagsArray.count > 0{
                                        if let listingMain = tagsArray[0] as? NSDictionary{
                                            
                                            if let listing = listingMain["text"] as? String {
                                                
                                                firstTag = listing
                                                
                                            }
                                        }
                                        
                                        let tagCount = tagsArray.count
                                        self.tagShowLabel.isHidden = false
                                        switch(tagCount){
                                            
                                        case 1:
                                            self.tagShowLabel.setTitle("- with \(firstTag)", for: UIControl.State())
                                        case 2:
                                            self.tagShowLabel.setTitle("- with \(firstTag)"+" and \((tagsArray.count) - 1) other", for: UIControl.State())
                                        default:
                                            self.tagShowLabel.setTitle("- with \(firstTag)"+" and \((tagsArray.count) - 1) others", for: UIControl.State())
                                        }
                                        
                                    }
                                    else{
                                        self.tagShowLabel.isHidden = true
                                    }
                                    
                                }
                                else{
                                    self.tagView.isHidden = true
                                }
                                
                                self.collectionViewImages.reloadData()
                                self.collectionViewImages.scrollToItem(at:IndexPath(item: self.photoIdd, section: 0), at: .right, animated: false)
                                
                                self.onceUpdate = false
                                
                            }
                        }
                        
                        
                        
                        
                    }else{
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
    
    func explorePic(){
        if Reachabable.isConnectedToNetwork() {
            
            removeAlert()
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            
            activityIndicatorView.startAnimating()
            
            var tempUrl : String
            
            if (self.url != nil && self.url != ""){
                tempUrl = self.url
            }else{
                if contentType == "photo"{
                    tempUrl = "albums/photo/list"
                }
                else{
                    tempUrl = "albums/view-content-album"
                }
                
            }
            
            var dic = Dictionary<String, String>()
            if (param != nil && param.count > 0) {
                for (key, value) in param{
                    
                    if let id = value as? NSNumber {
                        dic["\(key)"] = String(id as! Int)
                    }
                    
                    if let receiver = value as? NSString {
                        dic["\(key)"] = receiver as String
                    }
                }
            }
            
            if photoID > (photoLimit-1){
                pageValue = ((photoID)/photoLimit) + 1
                photoIDdd = photoID - (photoLimit * (pageValue - 1) )
                
            }
            
            dic["page"] = "\(pageValue)"
            dic["limit"] = String(photoLimit)
            dic["menu"] = "1"
            dic["album_id"] = attachmentID
            if ReactionPlugin == true{
                dic["getReaction"] = "1"
            }
            if self.contentType != nil && self.contentType == "listings"{
                dic["listingtype_id"] = String(listingTypeId)
            }
            
            
            // Send Server Request to Explore Group Contents with Group_ID
            
            post(dic, url: tempUrl, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    // activityIndicatorView.stopAnimating()
                    activityIndicatorView.stopAnimating()
                    
                    if msg{
                        
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        
                        if succeeded["body"] != nil{
                            if let body = succeeded["body"] as? NSDictionary{
                                
                                self.lightBoxImage.isHidden = true
                                
                                self.photoForViewer.removeAll(keepingCapacity: false)
                                
                                if let images = body["images"] as? NSArray{
                                    
                                    let imageCount =  images.count
                                    
                                    if (self.advancedActivityFlag != nil && self.advancedActivityFlag == true) {
                                        
                                        for tempIndex in stride(from: 0, through: imageCount-1, by: 1){
                                            let a = images[tempIndex] as! NSDictionary
                                            
                                            if(a["photo_id"] as? Int == self.photoID){
                                                self.photoID = tempIndex
                                                break
                                            }
                                        }
                                        
                                    }
                                    
                                    self.photoForViewer = PhotoViewer.loadPhotosInfo(images)
                                    
                                }
                                else if let images = body["photos"] as? NSArray{
                                    
                                    let imageCount =  images.count
                                    
                                    if (self.advancedActivityFlag != nil && self.advancedActivityFlag == true) {
                                        
                                        for tempIndex in stride(from: 0, through: imageCount-1, by: 1){
                                            let a = images[tempIndex] as! NSDictionary
                                            
                                            if(a["photo_id"] as? Int == self.photoID){
                                                self.photoID = tempIndex
                                                break
                                            }
                                        }
                                        
                                    }
                                    
                                    self.photoForViewer = PhotoViewer.loadPhotosInfo(images)
                                    
                                }
                                    
                                else if let images = body["albumPhotos"] as? NSArray{
                                    
                                    let imageCount =  images.count
                                    
                                    if (self.advancedActivityFlag != nil && self.advancedActivityFlag == true) {
                                        
                                        for tempIndex in stride(from: 0, through: imageCount-1, by: 1){
                                            let a = images[tempIndex] as! NSDictionary
                                            
                                            if(a["photo_id"] as? Int == self.photoID){
                                                self.photoID = tempIndex
                                                break
                                            }
                                        }
                                        
                                    }
                                    
                                    self.photoForViewer = PhotoViewer.loadPhotosInfo(images)
                                    
                                }
                                
                                self.currentImageArray.removeAll(keepingCapacity: false)
                                
                                for id in 0  ..< self.photoForViewer.count  {
                                    
                                    self.currentImageArray.append(self.photoForViewer[id].image!)
                                    self.photoDescription.append(self.photoForViewer[id].photo_description!)
                                    self.photoTitle.append(self.photoForViewer[id].photo_title!)
                                    if self.notShowComment == false {
                                        self.likeCountArray.append(self.photoForViewer[id].likes_count!)
                                        self.commentCountArray.append(self.photoForViewer[id].comment_count!)
                                    }
                                }
                                
                                
                                self.UItoShowLikes()
                                
                                
                                if logoutUser == false{
                                    if self.contentType == "product_photo"{
                                        self.bottomView.isHidden = false
                                        self.reactionShow.isHidden = true
                                        self.likeShow.isHidden = true
                                        self.commentShow.isHidden = true
                                        self.likeCount.isHidden = true
                                        self.commentCount.isHidden = true
                                        self.shareShow.frame.origin.x = self.view.bounds.width/2 - 50
                                        self.moreMenu1.frame.origin.x = self.view.bounds.width/2
                                    }
                                    else{
                                        self.bottomView.isHidden = false
                                        if self.contentType == "album_photo"
                                        {
                                            self.taggedUserLabel.isHidden = false
                                        }
                                        
                                    }
                                }
                                else{
                                    self.bottomView.isHidden = true
                                }
                                
                                self.collectionViewImages.reloadData()
                                self.collectionViewImages.scrollToItem(at:IndexPath(item: self.photoID, section: 0), at: .right, animated: false)
                                
                                
                                
                            }
                            self.bottomViewShow = true
                            
                        }
                    }else{
                        
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
    
    // Handle Menu Action
    func showMenu(){
        // Generate Blog Menu Come From Server as Alert Popover
        deletePhoto = false
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        for menuItem in myMenu{
            if let dic = menuItem as? NSDictionary{
                
                alertController.addAction(UIAlertAction(title: (dic["label"] as! String), style: .default, handler:{ (UIAlertAction) -> Void in
                    
                    // Change Here For Edit
                    if dic["name"] as! String ==  "edit"{
                        let presentedVC = EditPhotoViewController()
                        let urlString = dic["url"] as! String
                        if let param = dic["urlParams"] as? NSDictionary{
                            presentedVC.parameters = param
                        }
                        presentedVC.url = urlString
                        presentedVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                        let nativationController = UINavigationController(rootViewController: presentedVC)
                        self.present(nativationController, animated:true, completion: nil)
                        
                        
                    }
                    
                    // Change Here For Delete
                    if dic["name"] as! String == "delete"{
                        
                        // Confirmation Alert
                        displayAlertWithOtherButton(NSLocalizedString("Delete \(self.contentType) Photo",  comment: ""),message: NSLocalizedString("Are you sure you want to delete this photo?",  comment: "") , otherButton: NSLocalizedString("Delete Photo",  comment: "")) { () -> () in
                            self.deletePhoto = true
                            self.updatePhoto(dic["urlParams"] as! NSDictionary, url:dic["url"] as! String )
                        }
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                    
                    // Share Blog
                    if dic["name"] as! String == "share"{
                        
                        self.shareUrl = dic["url"] as! String
                        self.shareParam = dic["urlParams"] as! NSDictionary
                        
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
        
        if  (UIDevice.current.userInterfaceIdiom == .phone){
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel",  comment: ""), style: .default, handler:nil))
        }else{
            // Present Alert as Popover for iPad
            alertController.modalPresentationStyle = UIModalPresentationStyle.popover
            let popover = alertController.popoverPresentationController
            popover?.sourceView = UIButton()
            popover?.sourceRect = CGRect(x: view.bounds.height-50, y: view.bounds.width, width: 0, height: 0)
            popover?.permittedArrowDirections = UIPopoverArrowDirection.up
        }
        self.present(alertController, animated:true, completion: nil)
        
    }
    
    func updatePhoto(_ parameter: NSDictionary , url : String){
        
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
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
            
            if self.contentType == "listings"{
                
                dic["listingtype_id"] = String(listingTypeId)
                dic["photo_id"] = String(listingPhotoId)
            }
            
            var method:String
            
            if url.range(of: "delete") != nil
            {
                method = "DELETE"
            }
            else
            {
                method = "POST"
            }
            
            
            // Send Server Request to Explore Blog Contents with Blog_ID
            post(dic, url: "\(url)", method: method ) { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    // activityIndicatorView.stopAnimating()
                    activityIndicatorView.stopAnimating()
                    updateUserData()
                    if msg
                    {
                        if succeeded["message"] != nil
                        {
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        else
                        {
                            if method == "DELETE"
                            {
                                showToast(message: NSLocalizedString("Photo has been deleted successfully", comment: ""), controller: self, onView: false, time: 5.0)
                            }
                        }
                        
                        groupUpdate = true
                        eventUpdate = true
                        if self.deletePhoto == true
                        {
                            self.popAfterDelay = true
                            self.createTimer(self)
                            refreshPhotos = true
                            updateFromAlbum = true
                            
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
    
    //MARK: ScrollView Delegates
    
    private func indexOfMajorCell() -> Int {
        let itemWidth = collectionViewLayout.itemSize.width
        let proportionalOffset = collectionViewLayout.collectionView!.contentOffset.x / itemWidth
        return Int(round(proportionalOffset))
    }
    private var indexOfCellBeforeDragging = 0
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        indexOfCellBeforeDragging = indexOfMajorCell()
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        targetContentOffset.pointee = scrollView.contentOffset
        
        // calculate where scrollView should snap to:
        let indexOfMajorCell = self.indexOfMajorCell()
        
        // calculate conditions:
        let swipeVelocityThreshold: CGFloat = 0.5 // after some trail and error
        let hasEnoughVelocityToSlideToTheNextCell = indexOfCellBeforeDragging + 1 < photoForViewer.count && velocity.x > swipeVelocityThreshold
        let hasEnoughVelocityToSlideToThePreviousCell = indexOfCellBeforeDragging - 1 >= 0 && velocity.x < -swipeVelocityThreshold
        let majorCellIsTheCellBeforeDragging = indexOfMajorCell == indexOfCellBeforeDragging
        let didUseSwipeToSkipCell = majorCellIsTheCellBeforeDragging && (hasEnoughVelocityToSlideToTheNextCell || hasEnoughVelocityToSlideToThePreviousCell)
        
        if didUseSwipeToSkipCell {
            
            let snapToIndex = indexOfCellBeforeDragging + (hasEnoughVelocityToSlideToTheNextCell ? 1 : -1)
            let toValue = collectionViewLayout.itemSize.width * CGFloat(snapToIndex)
            
            // Damping equal 1 => no oscillations => decay animation:
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: velocity.x, options: .allowUserInteraction, animations: {
                print("albumid--\(self.albumId)")
                scrollView.contentOffset = CGPoint(x: toValue, y: 0)
                scrollView.layoutIfNeeded()
            }, completion: nil)
            
        } else {
            // This is a much better to way to scroll to a cell:
            let indexPath = IndexPath(row: indexOfMajorCell, section: 0)
            
            collectionViewLayout.collectionView!.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
        //   }
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollViewEmoji.isHidden = true
        scrollviewEmojiLikeView.isHidden = true
        arrowView.isHidden = true
        var visibleRect = CGRect()
        visibleRect.origin = collectionViewImages.contentOffset
        visibleRect.size = collectionViewImages.bounds.size
        
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        
        guard let indexPath = collectionViewImages.indexPathForItem(at: visiblePoint) else { return }
        
        var page = indexPath.row
        if allphotos.count > page {
            let photoinfo = self.allphotos[page]
            if  let id = photoinfo["album_id"] as? String {
                self.photoAlbumId = id
            }
            if page == total_items{
                page = 0
            }
            currentPage = page
            print("Current page \(currentPage)")
            photoIdd = self.photoID + currentPage - photoIDdd
        }
        if(photoIdd >= total_items){
            photoIdd = photoIdd - total_items
        }
        if (albumTitle != nil){
            if ownerTitle != nil {
                if( albumTitle != "" && ownerTitle != ""){
                    let simpleText : String = "By " + ownerTitle + "\n" + albumTitle + "\n"
                    let photoText : String = simpleText + String(photoIdd + 1) + " - " + String(total_items)
                    photoInfo1.text = photoText
                    
                }
                else{
                    photoInfo1.text = String(photoIdd + 1) + " - " + String(total_items)
                    
                }
            }
                
            else{
                photoInfo1.text = String(photoIdd + 1) + " - " + String(total_items)
            }
        }
        else{
            photoInfo1.text = String(photoIdd + 1) + " - " + String(total_items)
        }
        
        
        self.UItoShowLikes()
        pageNumber = (photoIdd/photoLimit)+1
        if (photoIdd+1 == pageNumber*photoLimit && photoForViewer.count < total_items)
        {
            if photoIdd+1 == photoForViewer.count
            {
                exploreMorePhotos()
            }
            
        }
    }
    
    @objc func moreMenu(){
        editPhoto = false
        self.currentImage = (photoForViewer[currentPage].image)!
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
        // Generate Blog Menu Come From Server as Alert Popover
        self.deletePhoto = false
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        if  self.contentType == "photo" {
            alertController.addAction(UIAlertAction(title: "View Album", style: .default, handler:{
                (UIAlertAction) -> Void in
                
                let vc = AlbumProfileViewController()
                print("albumid--\(self.photoAlbumId)")
                vc.albumId = "\(self.photoAlbumId)"
                allPhotos.removeAll()
                self.navigationController?.pushViewController(vc, animated: true)
            }))
        }
        
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
            ALAssetsLibrary().writeImageData(toSavedPhotosAlbum: data, metadata:nil , completionBlock: nil)
            self.view.makeToast(NSLocalizedString("Photo Saved", comment: ""), duration: 5, position: CSToastPositionCenter)
            
            
        }))
        if (photoForViewer[currentPage].menu) != nil
        {
            self.currentMenu = (photoForViewer[currentPage].menu)!
            if self.currentMenu != nil{
                for menuItem in self.currentMenu{
                    if let dic = menuItem as? NSDictionary{
                        
                        
                        if dic["name"] as! String != "share"{
                            alertController.addAction(UIAlertAction(title: (dic["label"] as! String), style: .default, handler:{ (UIAlertAction) -> Void in
                                
                                // Change Here For Edit
                                if dic["name"] as! String ==  "edit"{
                                    self.editPhoto = true
                                    NotificationCenter.default.addObserver(self, selector: #selector(AdvancePhotoViewController.keyboardWillShow(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
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
                                    displayAlertWithOtherButton(NSLocalizedString("Delete Photo",  comment: ""),message: NSLocalizedString("Are you sure you want to delete this photo?",  comment: "") , otherButton: NSLocalizedString("Delete Photo",  comment: "")) { () -> () in
                                        self.deletePhoto = true
                                        if let dicparam = dic["urlParams"] as? NSDictionary
                                        {
                                            self.updatePhoto(dicparam, url:dic["url"] as! String )
                                        }
                                        else
                                        {
                                            let dicparam = ["":""]
                                            self.updatePhoto(dicparam as NSDictionary, url:dic["url"] as! String )
                                        }
                                        
                                    }
                                    self.present(alert, animated: true, completion: nil)
                                    
                                }
                                
                                // Share Picture
                                if dic["name"] as! String == "share"{
                                    
                                    self.shareUrl = dic["url"] as! String
                                    self.shareParam = dic["urlParams"] as! NSDictionary
                                    self.shareItem()
                                    
                                }
                                
                                // Report this Picture
                                if dic["name"] as! String == "report"{
                                    let presentedVC = ReportContentViewController()
                                    if self.contentType == "listings"{
                                        presentedVC.param = [ : ]
                                    }
                                    else{
                                        if dic["urlParams"] != nil{
                                            presentedVC.param = (dic["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary}
                                        else{
                                            presentedVC.param = [ : ]
                                        }
                                    }
                                    
                                    presentedVC.url = dic["url"] as! String
                                    self.navigationController?.pushViewController(presentedVC, animated: true)
                                    
                                }
                                
                                // Make User Profile Photo
                                if dic["name"] as! String == "make_profile_photo" {
                                    displayAlertWithOtherButton(NSLocalizedString("Make Profile Photo",  comment: ""),message: NSLocalizedString("Do you want to make this photo your profile photo?",  comment: "") , otherButton: NSLocalizedString("Save",  comment: "")) { () -> () in
                                        
                                        if self.contentType == "sitepage_photo"
                                        {
                                            self.updatePhoto(["" : ""], url:dic["url"] as! String )
                                        }
                                        else
                                        {
                                            self.updatePhoto(dic["urlParams"] as! NSDictionary, url:dic["url"] as! String )
                                        }
                                    }
                                    self.present(alert, animated: true, completion: nil)
                                }
                                
                            }))
                        }
                        
                    }
                    
                }
            }
        }
        
        if  (UIDevice.current.userInterfaceIdiom == .phone){
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel",  comment: ""), style: .cancel, handler:nil))
        }else{
            alertController.popoverPresentationController?.sourceView = view
            alertController.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.width/2 , y: view.bounds.height/2, width: 0, height: 0)
            alertController.popoverPresentationController!.permittedArrowDirections = UIPopoverArrowDirection()
            
        }
        self.present(alertController, animated:true, completion: nil)
        
        
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
        
        var shareType = String()
        if photoType != nil && photoType == "siteevent_photo"
        {
            shareType = photoType
            
        }
        else
        {
            shareType = "album_photo"
        }
        
        
        
        if contentType != nil && contentType != ""{
            if contentType == "listings"{
                shareType = photoType
            }
            else if contentType == "product_photo"
            {
                shareType = "sitestoreproduct_photo"
            }
            else
            {
                shareType = contentType
            }
        }
        
        pv.param = ["type": shareType, "id": String(photoid)]
        pv.Sharetitle = ""
        pv.ShareDescription = ""
        pv.imageString = image
        pv.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        let nativationController = UINavigationController(rootViewController: pv)
        self.present(nativationController, animated:true, completion: nil)
        
        
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
                    total_likes = total_likes! - 1
                    animationEffectOnButton(sender)
                    sender.setTitleColor(textColorLight , for: UIControl.State())
                }
            }
            else{
                if ReactionPlugin == false{
                    total_likes = total_likes! + 1
                    animationEffectOnButton(sender)
                    sender.setTitleColor(navColor , for: UIControl.State())
                }
            }
            
            
            let finalText = singlePluralCheck( NSLocalizedString(" Like", comment: ""),  plural: NSLocalizedString(" Likes", comment: ""), count: total_likes!)
            likeCount.setTitle("\(finalText)", for: UIControl.State())
            
            if ReactionPlugin == true{
                if is_like == false{
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
                                reaction = (v["reaction"] as? String)!
                                updatedDictionary["reactionicon_id"] = v["reactionicon_id"]  as AnyObject?
                                updatedDictionary["caption" ] = v["caption"]  as AnyObject?
                                if let icon  = v["icon"] as? NSDictionary{
                                    updatedDictionary["reaction_image_icon"] = icon["reaction_image_icon"] as! String as AnyObject?
                                }
                                var url = ""
                                url = "advancedcomments/like"
                                DispatchQueue.main.async(execute:  {
                                    soundEffect("Like")
                                })
                                animateLikeReaction()
                                updateReactions(url: url,reaction : reaction,subject_id  : "\(photoId)", updateMyReaction : updatedDictionary as NSDictionary,feedIndex: scrollViewEmoji.tag,subject_type : photoType,updateType : "update")
                            }
                        }
                    }
                }
                else{
                    // delete Reaction
                    let photoId = (photoForViewer[currentPage].photo_id!)
                    let reaction = ""
                    var updatedDictionary = Dictionary<String, AnyObject>()
                    updatedDictionary = [ : ]
                    var url = ""
                    url = "unlike"
                    DispatchQueue.main.async(execute:  {
                        soundEffect("Like")
                    })
                    updateReactions(url: url,reaction : reaction,subject_id  : "\(photoId)", updateMyReaction : updatedDictionary as NSDictionary,feedIndex: sender.tag,subject_type : photoType,updateType: "delete")
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
                    
                    if(is_like == true){
                        sender.setTitleColor(textColorLight , for: UIControl.State())
                    }else{
                        sender.setTitleColor(navColor, for: UIControl.State())
                    }
                    
                    for (index,value) in self.photoForViewer.enumerated(){
                        if value.photo_id == photoId{
                            if path.range(of: "unlike") != nil
                            {
                                value.is_like = false
                                value.likes_count = value.likes_count! - 1
                            }else{
                                value.is_like = true
                                value.likes_count = value.likes_count! + 1
                            }
                            self.photoForViewer[index] = value//newData[0] as PhotoViewer
                        }
                    }
                    
                    let finalText = singlePluralCheck( NSLocalizedString(" Like", comment: ""),  plural: NSLocalizedString(" Likes", comment: ""), count: total_likes!)
                    self.likeCount.setTitle("\(finalText)", for: UIControl.State())
                    
                    
                    // Send Server Request to Like/Unlike Content
                    post(["subject_id":"\(photoId)", "subject_type": photoType], url: path, method: "POST") {
                        (succeeded, msg) -> () in
                        ///
                        
                        DispatchQueue.main.async(execute: {
                            // sender.isEnabled = true
                            if msg{
                                // On Success Update
                                if succeeded["message"] != nil{
                                    
                                }
                                
                            }
                            else{
                                // Handle Server Side Error
                                if succeeded["message"] != nil{
                                }
                                
                            }
                        })
                        
                    }
                }  else{
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
        view.bringSubviewToFront(imageView)
        imageView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 1.5, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 10.0, options: UIView.AnimationOptions.allowUserInteraction, animations: {
            imageView.transform = .identity
        }, completion: { (_) in
            imageView.isHidden = true
            imageView.removeFromSuperview()
        }
        )
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
                newDictionary["title"] = value.photo_title
                newDictionary["menu"] = value.menu
                newDictionary["description"] = value.description
                newDictionary["like_count"] = value.likes_count
                newDictionary["is_like"] = value.is_like
                newDictionary["tags"] = value.tags
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
    
    func shareTextImageAndURL(_ sharingText: String?, sharingImage: UIImage?, photoShareUrl : String?)
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
        
        //let activityItems = ActivityShareItemSources(text: shareText, image: shareImage!, url: URL(string: shareUrl)!)
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
    
    @objc func commentAction(_ sender:UIButton){
        
        editPhoto = false
        let photoId = (photoForViewer[currentPage].photo_id!)
        if let parentVC = self.parent{
            let presentedVC = CommentsViewController()
            updateComment = true
            commentIncrement = sender.tag
            likeCommentContent_id = "\(photoId)"
            likeCommentContentType  = photoType
            presentedVC.openCommentTextView = 1
            presentedVC.pushFlag = true
            presentedVC.commentPermission = 1
            presentedVC.reactionsIcon = reactionsIcon
            presentedVC.activityFeedComment = false
            presentedVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            let navigationController = UINavigationController(rootViewController: presentedVC)
            parentVC.present(navigationController, animated: true, completion: nil)
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView)->UIView?
    {
        return scrollView.viewWithTag(111)
        
    }
    
    func doubleTapped(_ sender:UITapGestureRecognizer)
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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        
    }
    
    // MARK: - CollectionView Delegates
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoForViewer.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionIdentifier, for: indexPath) as! PhotoViewerCell
        cell.awakeFromNib()
        
        let obj = photoForViewer[indexPath.row]
        
        if let strUrl = obj.image, let url = URL(string: strUrl)
        {
            cell.imageView.kf.indicatorType = .activity
            (cell.imageView.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
            cell.imageView.kf.setImage(with: url, placeholder: UIImage(named : "default.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                
            })
        }
        
        return cell
    }
    
    
}

