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
//  CustomTableViewCellThree.swift
//  seiosnativeapp
//

import UIKit

// This Class is used by GroupViewController & EventViewController

class GroupTableViewCell: UITableViewCell,AutoPlayVideoLayerContainer {
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    var cellView: UIView!
    var contentImage:UIImageView!
    var contentName:UILabel!
    var totalMembers: UILabel!
    var createdBy: TTTAttributedLabel!
    var menu: UIButton!
    var eventTime :UILabel!
    var contentSelection:UIButton!
    var contentVieww : UIView!
    var closeIconView : UILabel!
    var ownerLabel = UILabel()
    
    var featuredLabel:UILabel!
    var sponsoredLabel:UILabel!
    var featuredLabel2:UILabel!
    var sponsoredLabel2:UILabel!

    
    var cellView2: UIView!
    var contentImage2:UIImageView!
    var contentName2:UILabel!
    var totalMembers2: UILabel!
    var createdBy2: TTTAttributedLabel!
    var menu2: UIButton!
    var eventTime2 :UILabel!
    var contentSelection2:UIButton!
    var contentView2 : UIView!
    var ownerLabel2 = UILabel()
    var Adimageview:UIImageView!
    var videoLayer: AVPlayerLayer = AVPlayerLayer()
    var playerController: VideoPlayerController?
    var videoURL: String? {
        didSet {
            if let videoURL = videoURL {
                playerController?.setupVideoFor(url: videoURL)
            }
            videoLayer.isHidden = videoURL == nil
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    
    // Initialize Variable for Comments Table Cell
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Configure the view for the selected state
        
        // LHS
        if(UIDevice.current.userInterfaceIdiom == .pad){
            cellView = createView( CGRect(x: 0, y: 0,width: (UIScreen.main.bounds.width/2 ) , height: 250 ), borderColor: borderColorMedium, shadow: false)
        }else{
            cellView = createView( CGRect(x: 0, y: 0,width: (UIScreen.main.bounds.width ) , height: 250), borderColor: borderColorMedium, shadow: false)
        }
        
        cellView.layer.shadowColor = shadowColor.cgColor
        cellView.layer.shadowOpacity = shadowOpacity
        cellView.layer.shadowRadius = shadowRadius
        cellView.layer.shadowOffset = shadowOffset
        cellView.layer.borderWidth = 0.0
        self.addSubview(cellView)
        
        Adimageview = createImageView(CGRect(x: 30,y: 60,width: cellView.bounds.width - 60,height: 165), border: false)
        Adimageview.isHidden = true
        Adimageview.backgroundColor = UIColor.black
        cellView.addSubview(Adimageview)
        
        videoLayer.backgroundColor = UIColor.clear.cgColor
        videoLayer.videoGravity = AVLayerVideoGravity.resize
        videoLayer.frame = Adimageview.bounds
        Adimageview.layer.addSublayer(videoLayer)
        
        contentImage =  ContentImageViewWithGradient(frame: CGRect(x: 0, y: 0, width: cellView.bounds.width, height: cellView.bounds.height))
        contentImage.layer.masksToBounds = true
        contentImage.contentMode = UIView.ContentMode.scaleAspectFill
        contentImage.backgroundColor = placeholderColor
        contentImage.layer.shadowColor = shadowColor.cgColor
        contentImage.layer.shadowOpacity = shadowOpacity
        contentImage.layer.shadowRadius = shadowRadius
        contentImage.layer.shadowOffset = shadowOffset
        cellView.addSubview(contentImage)
        
        //        contentVieww = createView(CGRectMake(PADING, 110, CGRectGetWidth(contentImage.bounds) - 2*PADING,  CGRectGetHeight(cellView.bounds) - 110), UIColor.clearColor(), true)
        //        contentVieww.backgroundColor =  UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        //        cellView.addSubview(contentVieww)
        
        
        // Set
        contentName = createLabel(CGRect(x: 10, y: 10, width: (contentImage.bounds.width-20), height: 200), text: "", alignment: .left, textColor: textColorLight)
        contentName.numberOfLines = 0
        contentName.font = UIFont(name: fontBold, size: FONTSIZEExtraLarge)
        contentName.layer.shadowColor = shadowColor.cgColor
        contentName.layer.shadowOpacity = shadowOpacity
        contentName.layer.shadowRadius = shadowRadius
        contentName.layer.shadowOffset = shadowOffset
        cellView.addSubview(contentName)
        
        closeIconView = createLabel(CGRect(x: contentImage.bounds.width/2 - contentImage.bounds.width/6 , y: contentImage.bounds.height/2 - contentImage.bounds.height/6, width: contentImage.bounds.width/3, height: contentImage.bounds.height/3), text: " ", alignment: .center, textColor: textColorLight)
        closeIconView.font = UIFont(name: "FontAwesome", size: FONTSIZELarge)
        closeIconView.isHidden = true
        closeIconView.layer.shadowColor = shadowColor.cgColor
        closeIconView.layer.shadowOpacity = shadowOpacity
        closeIconView.layer.shadowRadius = shadowRadius
        closeIconView.layer.shadowOffset = shadowOffset
        contentImage.addSubview(closeIconView)
        
        
        
        totalMembers = createLabel(CGRect(x: 10, y: 200,  width: (contentImage.bounds.width-20), height: 40), text: "", alignment: .left, textColor: textColorLight)
        totalMembers.font = UIFont(name: fontName, size: FONTSIZEMedium)
        totalMembers.layer.shadowColor = shadowColor.cgColor
        totalMembers.layer.shadowOpacity = shadowOpacity
        cellView.addSubview(totalMembers)
        
        createdBy = TTTAttributedLabel(frame: CGRect(x: 120, y: 200, width: contentImage.bounds.width-120, height: 40))
        createdBy.textAlignment = .right
        createdBy.textColor = textColorLight
        createdBy.font = UIFont(name: fontName, size: FONTSIZESmall)
        cellView.addSubview(createdBy)
        
        ownerLabel = createLabel(CGRect(x: 10, y: 200,  width: (contentImage.bounds.width-20), height: 40), text: "", alignment: .left, textColor: textColorLight)
        ownerLabel.font = UIFont(name: fontName, size: 12)
        ownerLabel.layer.shadowColor = shadowColor.cgColor
        ownerLabel.layer.shadowOpacity = shadowOpacity
        cellView.addSubview(ownerLabel)
        
        
        eventTime = createLabel(CGRect(x: 50, y: 202, width: contentImage.bounds.width-150, height: 20), text: "", alignment: .center, textColor: textColorLight)
        eventTime.font = UIFont(name: fontBold, size: FONTSIZEMedium)
        eventTime.textColor = UIColor.red
        cellView.addSubview(eventTime)
        
        featuredLabel = createLabel(CGRect(x: 0, y: 0, width: 70, height: 20), text: "Featured", alignment: .center, textColor: textColorLight)
        featuredLabel.font = UIFont(name: fontName, size: FONTSIZEMedium)
        featuredLabel.backgroundColor = UIColor.init(red: 0, green: 176/255, blue: 182/255, alpha: 1)
        cellView.addSubview(featuredLabel)
        featuredLabel.isHidden = true
        
        
        sponsoredLabel = createLabel(CGRect(x: contentImage.bounds.width - 65, y: 0, width: 70, height: 20), text: "Sponsored", alignment: .center, textColor: textColorLight)
        sponsoredLabel.font = UIFont(name: fontName, size: FONTSIZEMedium)
        sponsoredLabel.backgroundColor = UIColor.red
        cellView.addSubview(sponsoredLabel)
        sponsoredLabel.isHidden = true

        
        //        if(UIDevice.currentDevice().userInterfaceIdiom == .Pad){
        //            cellView = createView( CGRectMake(0, 0,(CGRectGetWidth(UIScreen.mainScreen().bounds)/2 ) , 250 ), borderColor: borderColorMedium, shadow: false)
        //        }else{
        //            cellView = createView( CGRectMake(0, 0,(CGRectGetWidth(UIScreen.mainScreen().bounds) ) , 250), borderColor: borderColorMedium, shadow: false)
        //        }
        
        menu = createButton(CGRect(x: contentImage.bounds.width-40, y: 0, width: 40, height: 40), title: "\u{f141}", border: false,bgColor: false,textColor: textColorLight )
        menu.titleLabel?.font =  UIFont(name: "FontAwesome", size:30.0)
        menu.layer.shadowColor = shadowColor.cgColor
        menu.layer.shadowOpacity = shadowOpacity
        menu.layer.shadowRadius = shadowRadius
        menu.layer.shadowOffset = shadowOffset
        
        cellView.addSubview(menu)
        
        contentSelection = createButton(CGRect(x: 0, y: 40, width: cellView.bounds.width, height: cellView.bounds.height), title: "", border: false,bgColor: false, textColor: textColorLight)
        contentSelection.frame.size.height = (cellView.frame.size.height-40)
        self.addSubview(contentSelection)
        
        
        if(UIDevice.current.userInterfaceIdiom == .pad){
            // RHS
            //             cellView = createView( CGRectMake(PADING, 0,(CGRectGetWidth(UIScreen.mainScreen().bounds)/2 - 2*PADING) , 250 ), borderColorMedium, false)
            
            cellView2 = createView( CGRect(x: (UIScreen.main.bounds.width/2 ), y: 0,width: (UIScreen.main.bounds.width/2) , height: 250), borderColor: borderColorMedium, shadow: false)
            
            cellView2.layer.shadowColor = shadowColor.cgColor
            cellView2.layer.shadowOpacity = shadowOpacity
            cellView2.layer.shadowRadius = shadowRadius
            cellView2.layer.shadowOffset = shadowOffset
            cellView2.layer.borderWidth = 0.0
            self.addSubview(cellView2)
            
            contentImage2 = ContentImageViewWithGradient(frame: CGRect(x: 0, y: 0, width: cellView.bounds.width, height: cellView.bounds.height))
            contentImage2.layer.masksToBounds = true
            contentImage2.contentMode =  UIView.ContentMode.scaleAspectFill //UIView.ContentMode.Top
            
            contentImage2.backgroundColor = placeholderColor
            contentImage2.layer.shadowColor = shadowColor.cgColor
            contentImage2.layer.shadowOpacity = shadowOpacity
            contentImage2.layer.shadowRadius = shadowRadius
            contentImage2.layer.shadowOffset = shadowOffset
            
            cellView2.addSubview(contentImage2)
            
            contentName2 = createLabel(CGRect(x: 10, y: 110, width: (contentImage2.bounds.width-20), height: 200), text: "", alignment: .left, textColor: textColorLight)
            //        contentName2.layer.shadowColor = UIColor.lightGrayColor().CGColor
            //        contentName2.layer.shadowOpacity = 1.0
            //        contentName2.layer.shadowRadius = 4.0
            contentName2.font = UIFont(name: fontBold, size: FONTSIZEExtraLarge)
            contentName2.numberOfLines = 0
            contentName2.layer.shadowColor = shadowColor.cgColor
            contentName2.layer.shadowOpacity = shadowOpacity
            contentName2.layer.shadowRadius = shadowRadius
            contentName2.layer.shadowOffset = shadowOffset
            contentName2.font = UIFont(name: fontBold, size: FONTSIZELarge)
            cellView2.addSubview(contentName2)
            
            //            contentView2 = createView(CGRectMake(PADING, 110, CGRectGetWidth(contentImage.bounds) - 2*PADING,  CGRectGetHeight(cellView.bounds) - 110), UIColor.clearColor(), true)
            //            contentView2.backgroundColor =  UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
            //            cellView.addSubview(contentView2)
            
            
            
            
            
            totalMembers2 = createLabel(CGRect(x: 10, y: 200,  width: (contentImage2.bounds.width-20), height: 40), text: "", alignment: .left, textColor: textColorLight)
            totalMembers2.font = UIFont(name: fontName, size: FONTSIZEMedium)
            
            totalMembers2.layer.shadowColor = shadowColor.cgColor
            totalMembers2.layer.shadowOpacity = shadowOpacity
            
            cellView2.addSubview(totalMembers2)
            
            createdBy2 = TTTAttributedLabel(frame: CGRect(x: 120, y: 200, width: contentImage2.bounds.width-120, height: 40))
            createdBy2.textAlignment = .right
            createdBy2.textColor = textColorLight
            createdBy2.font = UIFont(name: fontName, size: FONTSIZESmall)
            cellView2.addSubview(createdBy2)
            
            eventTime2 = createLabel(CGRect(x: 50, y: 202, width: contentImage2.bounds.width-150, height: 20), text: "", alignment: .center, textColor: textColorLight)
            eventTime2.font = UIFont(name: fontBold, size: FONTSIZEMedium)
            eventTime2.textColor = UIColor.red
            cellView2.addSubview(eventTime2)
            
            ownerLabel2 = createLabel(CGRect(x: 10, y: 200,  width: (contentImage2.bounds.width-20), height: 40), text: "", alignment: .left, textColor: textColorLight)
            ownerLabel2.font = UIFont(name: fontName, size: 12)
            
            ownerLabel2.layer.shadowColor = shadowColor.cgColor
            ownerLabel2.layer.shadowOpacity = shadowOpacity
            
            cellView2.addSubview(ownerLabel2)
            
            featuredLabel2 = createLabel(CGRect(x: 0, y: 0, width: 75, height: 20), text: "Featured", alignment: .center, textColor: textColorLight)
            featuredLabel2.font = UIFont(name: fontName, size: FONTSIZEMedium)
            featuredLabel2.backgroundColor = UIColor.init(red: 0, green: 176/255, blue: 182/255, alpha: 1)
            cellView2.addSubview(featuredLabel2)
            featuredLabel2.isHidden = true
            
            
            sponsoredLabel2 = createLabel(CGRect(x: contentImage2.bounds.width - 71, y: 0, width: 70, height: 20), text: "Sponsored", alignment: .center, textColor: textColorLight)
            sponsoredLabel2.font = UIFont(name: fontName, size: FONTSIZEMedium)
            sponsoredLabel2.backgroundColor = UIColor.red
            cellView2.addSubview(sponsoredLabel2)
            
            sponsoredLabel2.isHidden = true

            
            menu2 = createButton(CGRect(x: contentImage2.bounds.width-40, y: 0, width: 40, height: 40), title: "\u{f141}", border: false,bgColor: false, textColor: textColorLight)
            menu2.titleLabel?.font =  UIFont(name: "FontAwesome", size:30.0)
            menu2.layer.shadowColor = shadowColor.cgColor
            menu2.layer.shadowOpacity = shadowOpacity
            menu2.layer.shadowRadius = shadowRadius
            menu2.layer.shadowOffset = shadowOffset
            
            cellView2.addSubview(menu2)
            
            contentSelection2 = createButton(CGRect(x: (UIScreen.main.bounds.width/2 ), y: 40,width: (UIScreen.main.bounds.width/2) , height: 250), title: "", border: false,bgColor: false, textColor: textColorLight)
            contentSelection2.frame.size.height = (cellView2.frame.size.height-40)
            self.addSubview(contentSelection2)
            
        }
    }
    func visibleVideoHeight() -> CGFloat {
        cellView.isHidden = false
        //viewVideo.isHidden = false
        
        let videoFrameInParentSuperView: CGRect? = self.superview?.superview?.superview?.convert(Adimageview.frame, from: Adimageview)
        guard let videoFrame = videoFrameInParentSuperView,
            let superViewFrame = superview?.frame else {
                return 0
        }
        let visibleVideoFrame = videoFrame.intersection(superViewFrame)
        return visibleVideoFrame.size.height
    }
    func playVideo(strURL : String?)
    {
        videoURL = strURL
        if let strURL = strURL, !strURL.isEmpty
        {
            
            //  viewVideo.isHidden = false
        }
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        ownerLabel.text = ""
        ownerLabel2.text = ""
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
