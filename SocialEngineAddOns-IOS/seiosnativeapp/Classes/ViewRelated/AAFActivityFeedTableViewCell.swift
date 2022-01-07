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
//  ActivityFeedTableViewCell.swift
//  seiosnativeapp
//

import UIKit
import NVActivityIndicatorView
import AVKit
import AVFoundation

protocol QuickContentDelegate{
    func quickContentUpdateRequest(index : Int)
    func quickContentDeleteRequest(_ cell: AAFActivityFeedTableViewCell)
}

extension URLSession {
    func getSessionDescription () -> Int {
        // row id
        return Int(self.sessionDescription!)!
    }
    
    func getDebugDescription () -> Int {
        // table id
        return Int(self.debugDescription)!
    }
}

// Custom TableView Cell for Advance Activity Feed
class AAFActivityFeedTableViewCell: UITableViewCell ,UIScrollViewDelegate, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate, AutoPlayVideoLayerContainer{
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    var quickContentDelegate : QuickContentDelegate!
    var cellView:UIView!
    var cellMenu: UIView!
    var subject_photo:UIImageView!
    var subject_photo1:UIButton!
    var title:TTTAttributedLabel!
    var createdAt: UILabel!
    var likeCommentInfo:UIButton!
    var borderView = UIView()
    var sideMenu: UIButton!
    var feedInfo:TTTAttributedLabel!
    var body:TTTAttributedLabel!
    var reactionsInfo : UIView!
    var commentInfo : UIButton!
    var bodyHashtaglbl :TTTAttributedLabel!
    //var customAlbumViewshare:UIView!
    var cntentShareFeedView : UIView!
    var contentImageView : UIImageView!
    var imgViewOverLay : UIImageView!
    var contentAttributedLabel : UILabel!
    var imageButton1 : UIButton!
    var imageButton2 : UIButton!
    var imageButton3 : UIButton!
    var imageButton4 : UIButton!
    var imageButton5 : UIButton!
    var imageButton6 : UIButton!
    var imageButton7 : UIButton!
    var imageButton8 : UIButton!
    var imageButton9 : UIButton!
    var bannerButton : UIButton!
    var mapButton : UIButton!
    var img_imageButton1 : UIImageView!
    var img_imageButton2 : UIImageView!
    var img_imageButton3 : UIImageView!
    var img_imageButton4 : UIImageView!
    var img_imageButton5 : UIImageView!
    var img_imageButton6 : UIImageView!
    var img_imageButton7 : UIImageView!
    var img_imageButton8 : UIImageView!
    var img_imageButton9 : UIImageView!
    var img_bannerButton : UIImageView!
    var img_mapButton : UIImageView!
    
    var imageViewWithText : UIImageView!
    var customAlbumView:UIView!
    var countlabel: UILabel!
    var bannerTitle : TTTAttributedLabel!
    // Implement Sell Something UI
    var sellSlideshow: ContentSlideshowScrollView!
    var sellSlideShowView = UIView()
    var sellTitle = UILabel()
    var sellPrice = UILabel()
    var sellLocation = UILabel()
    var sellDesc : TTTAttributedLabel!
    var pinMenu = UIButton()
    
    var viewContianerProgressView = UIView()
    var viewBlur = UIView()
    var progressView: UIProgressView!
    var btnCrossProgressBar : UIButton!
    var borderViewProgressBar = UIView()
    var imgCrossIcon : UIImageView!
    var imgVideo:UIButton!
    var imgReplayVideo:UIButton!
    var lblReplayVideo = UILabel()
    var btnMuteUnMuteIcon:UIButton!
    var activityIndicatorView : NVActivityIndicatorView!
    
    var gifImageViewShare : UIImageView!
    var gifImageView : UIImageView!
    var gifImageView1 : UIImageView!
    var gifImageView2 : UIImageView!
    var gifImageView3 : UIImageView!
    var gifImageView4 : UIImageView!
    var gifImageView5 : UIImageView!
    var gifImageView6 : UIImageView!
    var gifImageView7 : UIImageView!
    
    var singlePhoto = false
    var scheduleFeedLabel = UILabel()
    
    var viewVideo : UIView!    
    var playerController: VideoPlayerController?
    var videoLayer: AVPlayerLayer = AVPlayerLayer()
    var videoURL: String? {
        didSet {
            if let videoURL = videoURL {
                playerController?.setupVideoFor(url: videoURL)
            }
            videoLayer.isHidden = videoURL == nil
        }
    }
    
    // Initialize Variable for Custom Table Cell
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = aafBgColor
        self.selectionStyle = UITableViewCell.SelectionStyle.none
        
        cellView = createView(CGRect(x: 0, y: 5,width: UIScreen.main.bounds.width ,height: 110), borderColor: textColorclear, shadow: false)
        cellView.isOpaque = true
        cellView.clipsToBounds = true
        self.addSubview(cellView)
        
        
        viewContianerProgressView = createView(CGRect(x: 0, y: 0 ,width: cellView.bounds.width ,height: 0), borderColor: UIColor.clear, shadow: false)
        viewContianerProgressView.isHidden = true
        viewContianerProgressView.backgroundColor = textColorLight
        viewContianerProgressView.isOpaque = true
        viewContianerProgressView.clipsToBounds = true
        
        viewBlur = createView(CGRect(x: 0, y: 0 ,width: cellView.bounds.width ,height: 0), borderColor: UIColor.clear, shadow: false)
        viewBlur.isHidden = true
        viewBlur.backgroundColor = UIColor.white.withAlphaComponent(0.7)

        progressView = UIProgressView(frame: CGRect( x: 10 ,y: 21, width: viewContianerProgressView.bounds.width - 55, height: 6))
        //progressView.center = viewContianerProgressView.center
        progressView.progress = 0
        progressView.trackTintColor = UIColor.lightGray.withAlphaComponent(0.7)
        progressView.progressTintColor = navColor
        viewContianerProgressView.addSubview(progressView)
        
        imgCrossIcon = createImageView(CGRect(x: 0, y: 0, width: 15, height: 15), border: false)
        imgCrossIcon.image = UIImage(named: "StoryIcons_Cross")!.maskWithColor(color: textColorMedium)
        imgCrossIcon.isHidden = false
        viewContianerProgressView.addSubview(imgCrossIcon)
        
        btnCrossProgressBar = createButton(CGRect( x: cellView.bounds.width - 45 ,y: 2, width: 40, height: 40), title: "", border: false, bgColor: false, textColor: textColorLight)
        //btnCrossProgressBar.setBackgroundImage(UIImage(named: "StoryIcons_Cross")!.maskWithColor(color: textColorDark), for: UIControl.State.normal)
        btnCrossProgressBar.isHidden = false
        btnCrossProgressBar.backgroundColor = .clear
        btnCrossProgressBar.addTarget(self, action: #selector(btnProgressCloseAction(_:)), for: .touchUpInside)
        
        
        imgCrossIcon.center = btnCrossProgressBar.center
        
        activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 16, height: 16), type: .circleStrokeSpin, color: navColor, padding: nil)
        activityIndicatorView.isHidden = false
        activityIndicatorView.center = btnCrossProgressBar.center
        viewContianerProgressView.addSubview(activityIndicatorView)
        
        viewContianerProgressView.addSubview(btnCrossProgressBar)
        
        borderViewProgressBar = createView(CGRect(x: 0,y: viewContianerProgressView.bounds.height + viewContianerProgressView.frame.origin.y - 5 ,width: cellView.bounds.width , height: 1), borderColor: textColorLight, shadow: true)
        viewContianerProgressView.addSubview(borderViewProgressBar)
        
        //Bottom bar for showing like ,comment,share
        cellMenu = createView(CGRect(x: 0, y: cellView.bounds.height-40 ,width: cellView.bounds.width ,height: 40), borderColor: UIColor.clear, shadow: false)
        cellMenu.backgroundColor = borderColorLight
        cellMenu.layer.shouldRasterize = true
        cellMenu.layer.rasterizationScale = UIScreen.main.scale
        cellMenu.isOpaque = true
        cellView.addSubview(cellMenu)
        
        subject_photo = createImageView(CGRect(x: 3, y: 3, width: 50, height: 50), border: true)
        subject_photo1 = createButton(CGRect( x: 5,y: 5, width: 50, height: 50), title: "", border: false, bgColor: false, textColor: textColorLight)
        subject_photo.image = UIImage(named: "user_profile_image.png")
        subject_photo.layer.cornerRadius = subject_photo.frame.size.width/2
        subject_photo.clipsToBounds = true
        subject_photo.isOpaque = true
        cellView.addSubview(subject_photo1)
        subject_photo1.addSubview(subject_photo)
        
        
        title = TTTAttributedLabel(frame:CGRect(x: subject_photo.bounds.width + 10 , y: 5, width: cellView.bounds.width-(subject_photo.bounds.width + 65), height: 15))
        title.numberOfLines = 0
        title.longPressLabel()
        title.linkAttributes = [kCTForegroundColorAttributeName:textColorDark]
        title.textColor = textColorDark
        title.font = UIFont(name: fontBold, size: FONTSIZENormal)
        title.isOpaque = true
        cellView.addSubview(title)
        
        
        createdAt = createLabel(CGRect(x: subject_photo.bounds.width + 15, y: 35, width: cellView.bounds.width-(subject_photo.bounds.width + 65), height: 30), text: "", alignment: .left, textColor: textColorMedium)
        createdAt.font =  UIFont(name: "FontAwesome", size:FONTSIZESmall)
        createdAt.isOpaque = true
        cellView.addSubview(createdAt)
        
        
        scheduleFeedLabel = createLabel(CGRect(x: 0, y: 35, width: cellView.bounds.width, height: 30), text: "", alignment: .left, textColor: textColorMedium)
        scheduleFeedLabel.backgroundColor = textColorLight
        scheduleFeedLabel.font =  UIFont(name: "FontAwesome", size:FONTSIZENormal)
        scheduleFeedLabel.isOpaque = true
        scheduleFeedLabel.isHidden = true
        cellView.addSubview(scheduleFeedLabel)
        
        sideMenu = createButton(CGRect(x: cellView.bounds.width - 35, y: 5, width: 30, height: 25), title: "", border: false, bgColor: false, textColor: textColorMedium)
        sideMenu.isHidden = true
        sideMenu.titleLabel?.font =  UIFont(name: fontName, size:FONTSIZENormal)
        sideMenu.setImage(UIImage(named: "more.png")!.maskWithColor(color: textColorMedium), for: UIControl.State.normal)
        cellView.addSubview(sideMenu)
        
        pinMenu = createButton(CGRect(x: cellView.bounds.width - 60, y: 5, width: 20, height: 25), title: "\(pinicon)", border: false, bgColor: false, textColor: navColor)
        pinMenu.isHidden = true
        pinMenu.titleLabel?.font =  UIFont(name: "fontAwesome", size:FONTSIZELarge)
        //pinMenu.setImage(UIImage(named: "pinpost")!.maskWithColor(color: navColor), for: UIControl.State.normal)
        cellView.addSubview(pinMenu)
        
        body = TTTAttributedLabel(frame:CGRect(x: 10 , y: subject_photo.bounds.height + 5 + subject_photo.frame.origin.y, width: cellView.bounds.width-15, height: 300))
        body.numberOfLines = 0
        body.textColor = textColorDark
        body.linkAttributes = [kCTForegroundColorAttributeName:textColorLight]
        body.backgroundColor = textColorLight
        body.longPressLabel()
        body.font = UIFont(name: fontName, size: FONTSIZENormal)
        body.isHidden = true
        body.isOpaque = true
        cellView.addSubview(body)
        
        
        
        bodyHashtaglbl = TTTAttributedLabel(frame:CGRect(x: 10,y: getBottomEdgeY(inputView: body)+5 + 5,width: cellView.bounds.width - 10 ,height: 40))
        bodyHashtaglbl.isHidden = true
        bodyHashtaglbl.numberOfLines = 0
        bodyHashtaglbl.linkAttributes = [kCTForegroundColorAttributeName:textColorDark]
        bodyHashtaglbl.lineBreakMode = NSLineBreakMode.byWordWrapping
        bodyHashtaglbl.sizeToFit()
        bodyHashtaglbl.isOpaque = true
        cellView.addSubview(bodyHashtaglbl)
        
        let tempHeight = ceil(cellView.bounds.width * 0.80)
        
        
        cntentShareFeedView = createView(CGRect(x: 0,y: getBottomEdgeY(inputView: body)+5,width: cellView.bounds.width , height:tempHeight), borderColor: textColorclear, shadow: false)
        cntentShareFeedView.layer.shadowColor = shadowColor.cgColor
        cntentShareFeedView.layer.shadowOpacity = shadowOpacity
        cntentShareFeedView.layer.shadowRadius = shadowRadius
        cntentShareFeedView.layer.shadowOffset = shadowOffset
        cntentShareFeedView.layer.shouldRasterize = true
        cntentShareFeedView.layer.isOpaque = true
        cntentShareFeedView.layer.rasterizationScale = UIScreen.main.scale
        cellView.addSubview(cntentShareFeedView)
        
        contentImageView = createImageView(CGRect(x: 0,y: 0,width: cntentShareFeedView.bounds.width ,height: tempHeight - 60), border: false)
        contentImageView.backgroundColor = textColorLight
        contentImageView.layer.masksToBounds = true
        // contentImageView.isOpaque = true
        contentImageView.isUserInteractionEnabled = true
         cntentShareFeedView.addSubview(contentImageView)
        
        viewVideo = createView(CGRect(x: 0,y: 0,width: cntentShareFeedView.bounds.width ,height: tempHeight - 60) , borderColor: .clear , shadow: false)
        viewVideo.isHidden = true
        viewVideo.layer.shouldRasterize = true
        viewVideo.layer.isOpaque = true
        viewVideo.layer.rasterizationScale = UIScreen.main.scale
        viewVideo.backgroundColor = .clear
        cntentShareFeedView.addSubview(viewVideo)
        
        videoLayer.backgroundColor = UIColor.clear.cgColor
        videoLayer.videoGravity = AVLayerVideoGravity.resize
        viewVideo.layer.addSublayer(videoLayer)
        
        
        imgViewOverLay = createImageView(CGRect(x: 0,y: 0,width: cntentShareFeedView.bounds.width ,height: tempHeight - 60), border: false)
        imgViewOverLay.isHidden = false
        imgViewOverLay.backgroundColor = .clear
        imgViewOverLay.layer.masksToBounds = true
        imgViewOverLay.isUserInteractionEnabled = true
        cntentShareFeedView.addSubview(imgViewOverLay)
        
        btnMuteUnMuteIcon = createButton(CGRect(x: contentImageView.bounds.width - 50, y: 10, width: 40, height: 40), title: "", border: false, bgColor: false, textColor: .white)
        btnMuteUnMuteIcon.setImage(UIImage(named: "muteIcon1")!.maskWithColor(color: textColorLight), for: UIControl.State.normal)
        //btnMuteUnMuteIcon.titleLabel?.font =  UIFont(name: "fontAwesome", size:FONTSIZEVeryLarge)
        cntentShareFeedView.addSubview(btnMuteUnMuteIcon)
       
        
        //For showing Video icon
        imgVideo = createButton(CGRect(x: (UIScreen.main.bounds.width/2) - 20, y: (contentImageView.bounds.height/2) - 30, width: 50, height: 50), title: "", border: false, bgColor: false, textColor: textColorMedium)
        imgVideo.setImage(UIImage(named: "VideoImage-white.png")!.maskWithColor(color: textColorLight), for: UIControl.State.normal)
        imgVideo.isHidden = true
        imgVideo.isUserInteractionEnabled = true
        imgViewOverLay.addSubview(imgVideo)
        imgVideo.center = contentImageView.center
        
        
        imgReplayVideo = createButton(CGRect(x: (UIScreen.main.bounds.width/2) - 20, y: (contentImageView.bounds.height/2) - 30, width: 54, height: 54), title: "", border: false, bgColor: false, textColor: textColorMedium)
        imgReplayVideo.setImage(UIImage(named: "replayicon.png")!.maskWithColor(color: textColorLight), for: UIControl.State.normal)
        imgReplayVideo.isHidden = true
        imgReplayVideo.isUserInteractionEnabled = true
        imgViewOverLay.addSubview(imgReplayVideo)
        imgReplayVideo.center = contentImageView.center
        
        lblReplayVideo = createLabel(CGRect(x:(UIScreen.main.bounds.width/2) - 50, y: (contentImageView.bounds.height/2) - 62, width: 100, height: 25), text: NSLocalizedString("Play again", comment: ""), alignment: .center, textColor: .white)
        lblReplayVideo.font = UIFont(name: fontBold, size: FONTSIZEMedium)
        lblReplayVideo.backgroundColor = .clear
        lblReplayVideo.isHidden = true
        imgViewOverLay.addSubview(lblReplayVideo)
        
        
        gifImageViewShare = createImageView(CGRect(x: 0, y: 0, width: 50, height: 50), border: false)
        gifImageViewShare.center = contentImageView.center
        gifImageViewShare.image = UIImage(named: "gif_icon.png")
        gifImageViewShare.isHidden = true
        contentImageView.addSubview(gifImageViewShare)
        
        
        contentAttributedLabel = createLabel(CGRect(x: 5,y: tempHeight - 55, width:cntentShareFeedView.bounds.width-10 ,height: 50), text: NSLocalizedString("",  comment: "") , alignment: .left, textColor: textColorDark)
        cntentShareFeedView.addSubview(contentAttributedLabel)

        customAlbumView = createView(CGRect(x: 0,y: getBottomEdgeY(inputView: body)+5, width: cellView.bounds.width ,height: 0) , borderColor: textColorclear , shadow: false)
        customAlbumView.isHidden = true
        customAlbumView.backgroundColor = textColorLight
        customAlbumView.isOpaque = true
        cellView.addSubview(customAlbumView)
        
        
        // Showing 1 image start
        imageButton1 = createButton(CGRect(x: 0,y: 5,width: cellView.bounds.width , height:tempHeight) , title: "", border: false, bgColor: false, textColor: textColorLight)
        imageButton1.backgroundColor =  placeholderColor
        imageButton1.layer.masksToBounds = true
        imageButton1.layer.isOpaque = true
        
        
        img_imageButton1 = createImageView(CGRect(x: 0,y: 5,width: cellView.bounds.width , height:tempHeight), border: false)
        img_imageButton1.backgroundColor = textColorLight
        img_imageButton1.layer.masksToBounds = true
        img_imageButton1.isUserInteractionEnabled = true
        img_imageButton1.isHidden = true
        customAlbumView.addSubview(img_imageButton1)
        customAlbumView.addSubview(imageButton1)
        
        bannerButton = createButton(CGRect(x: 0,y: 5,width: cellView.bounds.width , height:tempHeight) , title: "", border: false, bgColor: false, textColor: textColorLight)
        bannerButton.backgroundColor =  placeholderColor
        bannerButton.layer.masksToBounds = true
        bannerButton.isHidden = true
        bannerButton.layer.isOpaque = true
        
        
        img_bannerButton = createImageView(CGRect(x: 0,y: 5,width: cellView.bounds.width , height:tempHeight), border: false)
        img_bannerButton.backgroundColor = textColorLight
        img_bannerButton.layer.masksToBounds = true
        img_bannerButton.isUserInteractionEnabled = true
        img_bannerButton.isHidden = true
        customAlbumView.addSubview(img_bannerButton)
        customAlbumView.addSubview(bannerButton)
        
        mapButton = createButton(CGRect(x: 0,y: 5,width: cellView.bounds.width , height:tempHeight) , title: "", border: false, bgColor: false, textColor: textColorLight)
        mapButton.backgroundColor =  placeholderColor
        mapButton.layer.masksToBounds = true
        mapButton.isHidden = true
        mapButton.layer.isOpaque = true
        
        
        img_mapButton = createImageView(CGRect(x: 0,y: 5,width: cellView.bounds.width , height:tempHeight), border: false)
        img_mapButton.backgroundColor = textColorLight
        img_mapButton.layer.masksToBounds = true
        img_mapButton.isUserInteractionEnabled = true
        img_mapButton.isHidden = true
        customAlbumView.addSubview(img_mapButton)
        customAlbumView.addSubview(mapButton)
        
        //For showing gif icon
        gifImageView = createImageView(CGRect(x: 0, y: 0, width: 50, height: 50), border: false)
        gifImageView.center = imageButton1.center
        gifImageView.image = UIImage(named: "gif_icon.png")
        gifImageView.isHidden = true
        imageButton1.addSubview(gifImageView)
        
        bannerTitle = TTTAttributedLabel(frame:CGRect(x: 10,y: 5,width: cellView.bounds.width - 20 ,height: tempHeight))
        bannerTitle.font =  UIFont(name: fontName, size:24)
        bannerTitle.linkAttributes = [kCTForegroundColorAttributeName:textColorDark]
        // bannerTitle.isOpaque = true
        customAlbumView.addSubview(bannerTitle)
        
        // Showing 2 images start
        let tempHeight2 = ceil(cellView.bounds.width * 0.65)
        let tempWidth = ceil((cellView.bounds.width-5) / 2)
        imageButton2 = createButton(CGRect(x: 0,y: 5,width: tempWidth , height:tempHeight2) , title: "", border: false, bgColor: false, textColor: textColorLight)
        imageButton2.backgroundColor = placeholderColor
        imageButton2.imageView?.contentMode = UIView.ContentMode.scaleAspectFill
        imageButton2.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.fill
        imageButton2.contentVerticalAlignment = UIControl.ContentVerticalAlignment.fill
        imageButton2.isHidden = true
        imageButton2.layer.masksToBounds = true
        imageButton2.layer.isOpaque = true
        
        
        img_imageButton2 = createImageView(CGRect(x: 0,y: 5,width: tempWidth , height:tempHeight2), border: false)
        img_imageButton2.backgroundColor = textColorLight
        img_imageButton2.layer.masksToBounds = true
        img_imageButton2.isUserInteractionEnabled = true
        img_imageButton2.isHidden = true
        customAlbumView.addSubview(img_imageButton2)
        customAlbumView.addSubview(imageButton2)
        
        //For showing gif icon
        gifImageView1 = createImageView(CGRect(x: 0, y: 0, width: 50, height: 50), border: false)
        gifImageView1.center = imageButton2.center
        gifImageView1.image = UIImage(named: "gif_icon.png")
        gifImageView1.isHidden = true
        imageButton2.addSubview(gifImageView1)
        
        imageButton3 = createButton(CGRect(x:tempWidth + 5,y: 5,width: tempWidth, height:tempHeight2) , title: "", border: false, bgColor: false, textColor: textColorLight)
        imageButton3.backgroundColor = placeholderColor
        imageButton3.imageView?.contentMode = UIView.ContentMode.scaleAspectFill
        imageButton3.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.fill
        imageButton3.contentVerticalAlignment = UIControl.ContentVerticalAlignment.fill
        imageButton3.isHidden = true
        imageButton3.layer.masksToBounds = true
        imageButton3.layer.isOpaque = true
        
        
        img_imageButton3 = createImageView(CGRect(x:tempWidth + 5,y: 5,width: tempWidth, height:tempHeight2), border: false)
        img_imageButton3.backgroundColor = textColorLight
        img_imageButton3.layer.masksToBounds = true
        img_imageButton3.isUserInteractionEnabled = true
        img_imageButton3.isHidden = true
        customAlbumView.addSubview(img_imageButton3)
        customAlbumView.addSubview(imageButton3)
        
        //For showing gif icon
        gifImageView2 = createImageView(CGRect(x: 0, y: 0, width: 50, height: 50), border: false)
        gifImageView2.center = imageButton3.center
        gifImageView2.image = UIImage(named: "gif_icon.png")
        gifImageView2.isHidden = true
        imageButton3.addSubview(gifImageView2)
        // Showing 2 images end
        
        // Showing 3 images start
        let tempHeightRightImage = ceil((tempHeight - 5)/2)
        let tempWidth1 = ceil((cellView.bounds.width)*0.6)
        let tempWidth2 = cellView.bounds.width - tempWidth1
        imageButton4 = createButton(CGRect(x: 0,y: 5,width: tempWidth1 ,height: tempHeight) , title: "", border: false, bgColor: false, textColor: textColorLight)
        imageButton4.backgroundColor = placeholderColor
        imageButton4.imageView?.contentMode = UIView.ContentMode.scaleAspectFill
        imageButton4.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.fill
        imageButton4.contentVerticalAlignment = UIControl.ContentVerticalAlignment.fill
        imageButton4.isHidden = true
        imageButton4.layer.masksToBounds = true
        imageButton4.layer.isOpaque = true
        
        
        img_imageButton4 = createImageView(CGRect(x: 0,y: 5,width: tempWidth1 ,height: tempHeight), border: false)
        img_imageButton4.backgroundColor = textColorLight
        img_imageButton4.layer.masksToBounds = true
        img_imageButton4.isUserInteractionEnabled = true
        img_imageButton4.isHidden = true
        customAlbumView.addSubview(img_imageButton4)
        customAlbumView.addSubview(imageButton4)
        
        //For showing gif icon
        gifImageView3 = createImageView(CGRect(x: 0, y: 0, width: 50, height: 50), border: false)
        gifImageView3.center = imageButton4.center
        gifImageView3.image = UIImage(named: "gif_icon.png")
        gifImageView3.isHidden = true
        imageButton4.addSubview(gifImageView3)
        
        imageButton5 = createButton(CGRect(x: tempWidth1 + 5 ,y: 5,width: tempWidth2-5, height:tempHeightRightImage) , title: "", border: false, bgColor: false, textColor: textColorLight)
        imageButton5.backgroundColor = placeholderColor
        imageButton5.imageView?.contentMode = UIView.ContentMode.scaleAspectFill
        imageButton5.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.fill
        imageButton5.contentVerticalAlignment = UIControl.ContentVerticalAlignment.fill
        imageButton5.isHidden = true
        imageButton5.layer.masksToBounds = true
        imageButton5.layer.isOpaque = true
        
        
        img_imageButton5 = createImageView(CGRect(x: tempWidth1 + 5 ,y: 5,width: tempWidth2-5, height:tempHeightRightImage), border: false)
        img_imageButton5.backgroundColor = textColorLight
        img_imageButton5.layer.masksToBounds = true
        img_imageButton5.isUserInteractionEnabled = true
        img_imageButton5.isHidden = true
        customAlbumView.addSubview(img_imageButton5)
        customAlbumView.addSubview(imageButton5)
        
        //For showing gif icon
        gifImageView4 = createImageView(CGRect(x: 0, y: 0, width: 50, height: 50), border: false)
        gifImageView4.center = imageButton5.center
        gifImageView4.image = UIImage(named: "gif_icon.png")
        gifImageView4.isHidden = true
        imageButton5.addSubview(gifImageView3)
        
        imageButton6 = createButton(CGRect(x: tempWidth1 + 5,y: 10+tempHeightRightImage,width: tempWidth2 - 5  ,height: tempHeightRightImage) , title: "", border: false, bgColor: false, textColor: textColorLight)
        imageButton6.backgroundColor = placeholderColor
        imageButton6.imageView?.contentMode = UIView.ContentMode.scaleAspectFill
        imageButton6.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.fill
        imageButton6.contentVerticalAlignment = UIControl.ContentVerticalAlignment.fill
        imageButton6.isHidden = true
        imageButton6.layer.masksToBounds = true
        imageButton6.layer.isOpaque = true
        
        
        img_imageButton6 = createImageView(CGRect(x:  tempWidth1 + 5,y: 10+tempHeightRightImage,width: tempWidth2 - 5  ,height: tempHeightRightImage), border: false)
        img_imageButton6.backgroundColor = textColorLight
        img_imageButton6.layer.masksToBounds = true
        img_imageButton6.isUserInteractionEnabled = true
        img_imageButton6.isHidden = true
        customAlbumView.addSubview(img_imageButton6)
        customAlbumView.addSubview(imageButton6)
        
        //For showing gif icon
        gifImageView5 = createImageView(CGRect(x: 0, y: 0, width: 50, height: 50), border: false)
        gifImageView5.center = imageButton6.center
        gifImageView5.image = UIImage(named: "gif_icon.png")
        gifImageView5.isHidden = true
        imageButton6.addSubview(gifImageView3)
        // Showing 3 images end
        
        // Showing 4 images start
        imageButton7 = createButton(CGRect(x: 0,y: 5,width: tempWidth ,height: tempHeightRightImage) , title: "", border: false, bgColor: false, textColor: textColorLight)
        imageButton7.backgroundColor = placeholderColor
        imageButton7.imageView?.contentMode = UIView.ContentMode.scaleAspectFill
        imageButton7.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.fill
        imageButton7.contentVerticalAlignment = UIControl.ContentVerticalAlignment.fill
        imageButton7.layer.masksToBounds = true
        imageButton7.layer.isOpaque = true
        
        
        img_imageButton7 = createImageView(CGRect(x:  0,y: 5,width: tempWidth ,height: tempHeightRightImage), border: false)
        img_imageButton7.backgroundColor = textColorLight
        img_imageButton7.layer.masksToBounds = true
        img_imageButton7.isUserInteractionEnabled = true
        //img_imageButton7.isHidden = true
        customAlbumView.addSubview(img_imageButton7)
        customAlbumView.addSubview(imageButton7)
        
        imageButton8 = createButton(CGRect(x:5 + tempWidth ,y: 5,width: tempWidth, height:tempHeightRightImage) , title: "", border: false, bgColor: false, textColor: textColorLight)
        imageButton8.backgroundColor = placeholderColor
        imageButton8.imageView?.contentMode = UIView.ContentMode.scaleAspectFill
        imageButton8.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.fill
        imageButton8.contentVerticalAlignment = UIControl.ContentVerticalAlignment.fill
        imageButton8.layer.masksToBounds = true
        imageButton8.layer.isOpaque = true
        
        
        img_imageButton8 = createImageView(CGRect(x: 5 + tempWidth ,y: 5,width: tempWidth, height:tempHeightRightImage), border: false)
        img_imageButton8.backgroundColor = textColorLight
        img_imageButton8.layer.masksToBounds = true
        img_imageButton8.isUserInteractionEnabled = true
        //img_imageButton8.isHidden = true
        customAlbumView.addSubview(img_imageButton8)
        customAlbumView.addSubview(imageButton8)
        
        imageButton9 = createButton(CGRect(x: 0,y: 10+tempHeightRightImage,width: tempWidth , height: tempHeightRightImage) , title: "", border: false, bgColor: false, textColor: textColorLight)
        imageButton9.backgroundColor = placeholderColor
        imageButton9.imageView?.contentMode = UIView.ContentMode.scaleAspectFill
        imageButton9.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.fill
        imageButton9.contentVerticalAlignment = UIControl.ContentVerticalAlignment.fill
        imageButton9.layer.masksToBounds = true
        imageButton9.layer.isOpaque = true
        
        
        img_imageButton9 = createImageView(CGRect(x: 0,y: 10+tempHeightRightImage,width: tempWidth , height: tempHeightRightImage), border: false)
        img_imageButton9.backgroundColor = textColorLight
        img_imageButton9.layer.masksToBounds = true
        img_imageButton9.isUserInteractionEnabled = true
        //img_imageButton9.isHidden = true
        customAlbumView.addSubview(img_imageButton9)
        customAlbumView.addSubview(imageButton9)
        
        imageViewWithText = createImageView(CGRect(x: 5 + tempWidth,y: 10+tempHeightRightImage, width: tempWidth ,height: tempHeightRightImage), border: false) //
        imageViewWithText.backgroundColor = placeholderColor
        imageViewWithText.isOpaque = true
        imageViewWithText.layer.masksToBounds = true
        
        countlabel = createLabel(CGRect(x: 0,y: 0, width: tempWidth,height: tempHeightRightImage), text: "", alignment: .center, textColor: textColorLight)
        countlabel.font = UIFont(name: fontBold, size: 30)
        countlabel.isHidden = true
        countlabel.isOpaque = true
        imageViewWithText.addSubview(countlabel)
        customAlbumView.addSubview(imageViewWithText)
        // Showing 4 images end
        // Showing posted imageview start
        
        
        //Showing reaction icons on left
        reactionsInfo = createView(CGRect(x: 0,y: 0 ,width: 100 , height: 30), borderColor: textColorclear, shadow: false)
        reactionsInfo.backgroundColor =  textColorclear
        reactionsInfo.isHidden = true
        reactionsInfo.isOpaque = true
        cellView.addSubview(reactionsInfo)
        
        // Showing reaction and like count on left
        likeCommentInfo = createButton(CGRect(x: 15,y: 0 ,width: 200 , height: 30), title: "", border: false,bgColor: false, textColor: textColorMedium)
        likeCommentInfo.titleLabel?.font = UIFont(name: fontName , size: FONTSIZESmall)
        likeCommentInfo.titleLabel?.textColor = textColorMedium
        likeCommentInfo.backgroundColor =  textColorclear
        likeCommentInfo.contentHorizontalAlignment = .left
        likeCommentInfo.isOpaque = true
        cellView.addSubview(likeCommentInfo)
        
        borderView = createView(CGRect(x: 0,y: 0 ,width: cellView.bounds.width , height: 1), borderColor: UIColor(red: 207/255.0, green: 208/255.0, blue: 212/255.0, alpha: 0.3), shadow: false)
        borderView.isHidden = true
        cellView.addSubview(borderView)
        
        //Showing comment count on right
        commentInfo = createButton(CGRect(x: cellView.bounds.width - 115 ,y: 0 , width: 100  , height: 30), title: "", border: false,bgColor: false, textColor: textColorMedium)
        commentInfo.titleLabel?.font = UIFont(name: fontName , size: FONTSIZESmall)
        commentInfo.titleLabel?.textColor = textColorMedium
        commentInfo.isHidden = true
        commentInfo.backgroundColor =  textColorclear
        commentInfo.contentHorizontalAlignment = .right
        commentInfo.isOpaque = true
        cellView.addSubview(commentInfo)
        
        
        // Featured carausal
        
        
        sellSlideShowView = UIView(frame: CGRect(x:0, y: subject_photo.bounds.height + 5 + subject_photo.frame.origin.y, width: cellView.bounds.width, height: 250))
        sellSlideShowView.backgroundColor = textColorclear
        sellSlideShowView.isHidden = true
        
        
        
        sellSlideshow = ContentSlideshowScrollView(frame: CGRect(x:0, y: 5, width: cellView.bounds.width, height: 250))
        sellSlideshow.backgroundColor = UIColor.white
        sellSlideshow.delegate = self
        sellSlideShowView.addSubview(sellSlideshow)
        cellView.addSubview(sellSlideShowView)
        
        sellSlideShowView.layer.borderWidth = 1
        sellSlideShowView.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        
        sellTitle = createLabel(CGRect(x:10, y: sellSlideshow.bounds.size.height + 10, width: cellView.bounds.width, height: 25), text: "", alignment: .left, textColor: textColorDark)
        sellTitle.font = UIFont(name: fontBold, size: FONTSIZEMedium)
        sellTitle.backgroundColor = textColorLight
        sellSlideShowView.addSubview(sellTitle)
        
        sellPrice = createLabel(CGRect(x:10, y: sellTitle.frame.origin.y + sellTitle.bounds.size.height, width: cellView.bounds.width, height: 25), text: "", alignment: .left, textColor: textColorDark)
        sellPrice.font = UIFont(name: "fontAwesome", size: FONTSIZEMedium)
        sellPrice.backgroundColor = textColorLight
        sellSlideShowView.addSubview(sellPrice)
        
        sellLocation = createLabel(CGRect(x:10, y: sellPrice.frame.origin.y + sellPrice.bounds.size.height, width: cellView.bounds.width, height: 25), text: "", alignment: .left, textColor: textColorMedium)
        sellLocation.font = UIFont(name: "fontAwesome", size: FONTSIZEMedium)
        sellLocation.backgroundColor = textColorLight
        sellSlideShowView.addSubview(sellLocation)
        
 
        sellDesc = TTTAttributedLabel(frame:CGRect(x:10, y: sellLocation.frame.origin.y + sellLocation.bounds.size.height + 10, width: cellView.bounds.width, height: 25))
        sellDesc.textAlignment = .left
        sellDesc.linkAttributes = [kCTForegroundColorAttributeName:textColorDark]
        sellDesc.textColor = textColorDark
        //createLabel(CGRect(x:10, y: sellLocation.frame.origin.y + sellLocation.bounds.size.height + 10, width: cellView.bounds.width, height: 25), text: "", alignment: .left, textColor: textColorDark)
        sellDesc.font = UIFont(name: "fontAwesome", size: FONTSIZEMedium)
        sellDesc.backgroundColor = textColorLight
        sellSlideShowView.addSubview(sellDesc)
        
        
        
        // After hiding feed UNDO action
        
        feedInfo = TTTAttributedLabel(frame:CGRect(x: subject_photo.bounds.width + 10 , y: 5 , width: cellView.bounds.width-(subject_photo.bounds.width + 55), height: 100))
        feedInfo.numberOfLines = 0
        feedInfo.textColor = textColorDark
        feedInfo.linkAttributes = [kCTForegroundColorAttributeName:textColorDark]
        feedInfo.font = UIFont(name: fontName, size: FONTSIZEMedium)
        feedInfo.isHidden = true
        feedInfo.isOpaque = true
        cellView.addSubview(feedInfo)

        
        cellView.addSubview(viewContianerProgressView)
        cellView.addSubview(viewBlur)
        self.improvePerformance()
        
    }
    /// Change view settings for faster drawing
    private func improvePerformance() {
        /// Cache the view into a bitmap instead of redrawing the view each time
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
        self.isOpaque = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //Quick Content Methods
    @objc func btnProgressCloseAction(_ sender: AnyObject)
    {
        quickContentDelegate.quickContentDeleteRequest(self)
    }
    func updateDisplay(progress: Float) {
        progressView.setProgress(progress, animated: true)
    }
    func showHideIndicator(show : Bool)
    {
        if show
        {
            activityIndicatorView.isHidden = true
            activityIndicatorView.stopAnimating()
            imgCrossIcon.isHidden = false
            btnCrossProgressBar.isHidden = false
        }
        else
        {
            activityIndicatorView.isHidden = false
            activityIndicatorView.startAnimating()
            imgCrossIcon.isHidden = true
            btnCrossProgressBar.isHidden = true

        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        videoLayer.frame = viewVideo.bounds
    }
    // MARK: - Video Play Method
    func playVideo(strURL : String?)
    {
        videoURL = strURL
        if let strURL = strURL, !strURL.isEmpty
        {
            viewVideo.isHidden = false
        }
    }
    override func prepareForReuse()
    {
        super.prepareForReuse()
        contentImageView.image = nil
    }
    func visibleVideoHeight() -> CGFloat {
        viewVideo.isHidden = false
        if muteVideo == true
        {
            btnMuteUnMuteIcon.setImage(UIImage(named: "muteIcon1")!.maskWithColor(color: textColorLight), for: UIControl.State.normal)
            //cell.btnMuteUnMuteIcon.setTitle("\(muteVideoIcon)", for: .normal)
        }
        else
        {
            btnMuteUnMuteIcon.setImage(UIImage(named: "unmuteIcon1")!.maskWithColor(color: textColorLight), for: UIControl.State.normal)
            //cell.btnMuteUnMuteIcon.setTitle("\(unMuteIconIcon)", for: .normal)
        }
        let videoFrameInParentSuperView: CGRect? = self.superview?.superview?.superview?.convert(contentImageView.frame, from: contentImageView)
        guard let videoFrame = videoFrameInParentSuperView,
            let superViewFrame = superview?.frame else {
                return 0
        }
        let visibleVideoFrame = videoFrame.intersection(superViewFrame)
        return visibleVideoFrame.size.height
    }
    
    
}

