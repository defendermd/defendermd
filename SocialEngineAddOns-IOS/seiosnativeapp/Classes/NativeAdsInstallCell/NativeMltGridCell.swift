//
//  NativeMltGridCell.swift
//  seiosnativeapp
//
//  Created by Ankit on 24/07/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit

class NativeMltGridCell: UITableViewCell,AutoPlayVideoLayerContainer {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    var cellView2: UIView!
    var cellView: UIView!
    var contentImage2:UIImageView!
    var contentName2:UILabel!
    var totalMembers2: UILabel!
    var createdBy2: TTTAttributedLabel!
    var menu2: UIButton!
    var eventTime2 :UILabel!
    var contentSelection2:UIButton!
    var dateView2 : UIView!
    var titleView2 : UIView!
    var titleLabel2 : UILabel!
    var locLabel2 : UILabel!
    var dateLabel2 : UILabel!
    var dateLabel3 : UILabel!
    var menuButton2 : UIButton!
    var lineView2 : UIView!
    var closeIconView2 : UILabel!
    
    //VARIABLE FOR MLT PLUGIN
    var listingPriceTagLabel2: UILabel!
    var listingDetailsLabel2 : UILabel!
    
    //For featured and sponsored label

    var featuredLabel2:UILabel!
    var sponsoredLabel2:UILabel!
    var playerController: VideoPlayerController?
    var Adimageview:UIImageView!
    var btnMuteUnMuteIcon:UIButton!
    var videoLayer: AVPlayerLayer = AVPlayerLayer()
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
            cellView = createView( CGRect(x: 0, y: 0,width: (UIScreen.main.bounds.width/2) , height: 320), borderColor: borderColorMedium, shadow: false)
        }else{
            cellView = createView( CGRect(x: 0, y: 0,width: (UIScreen.main.bounds.width) , height: 320), borderColor: borderColorMedium, shadow: false)
        }
        
        
        
        let cornerRadius: CGFloat = 2
        let shadowOffsetWidth: Int = 0
        let shadowOffsetHeight: Int = 3
        let shadowOpacity: Float = 0.5
        cellView.layer.cornerRadius = cornerRadius
        cellView.layer.masksToBounds = false
        cellView.layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight);
        cellView.layer.shadowOpacity = shadowOpacity
        
        cellView.backgroundColor = bgColor//UIColor.white
        self.addSubview(cellView)
        
        
        
        Adimageview = createImageView(CGRect(x: 5,y: 60,width: cellView.bounds.width - 10,height: cellView.bounds.height/2 + 5), border: false)
        Adimageview.backgroundColor = UIColor.black
        Adimageview.isHidden = true
        cellView.addSubview(Adimageview)
        
        
        
        btnMuteUnMuteIcon = createButton(CGRect(x: cellView.bounds.width - 50, y: 60 + (cellView.bounds.height/2 + 5) - 40, width: 40, height: 40), title: "", border: false, bgColor: false, textColor: .white)
        btnMuteUnMuteIcon.setImage(UIImage(named: "muteIcon1")!.maskWithColor(color: textColorLight), for: UIControl.State.normal)
        //btnMuteUnMuteIcon.titleLabel?.font =  UIFont(name: "fontAwesome", size:FONTSIZEVeryLarge)
        cellView.addSubview(btnMuteUnMuteIcon)
        
        videoLayer.backgroundColor = UIColor.clear.cgColor
        videoLayer.videoGravity = AVLayerVideoGravity.resize
        videoLayer.frame = Adimageview.bounds
        Adimageview.layer.addSublayer(videoLayer)
        
  
        
        
        if(UIDevice.current.userInterfaceIdiom == .pad){
            // RHS
            cellView2 = createView( CGRect(x: (UIScreen.main.bounds.width/2), y: 0,width: (UIScreen.main.bounds.width/2) , height: 250), borderColor: borderColorMedium, shadow: false)
            cellView2.layer.borderWidth = 0.0
            self.addSubview(cellView2)
            dateView2 = UIView( frame: CGRect(x: (UIScreen.main.bounds.width/2), y: 180,width: 70 , height: 70))
            dateView2.backgroundColor = navColor
            self.addSubview(dateView2)
            
            titleView2 = UIView( frame: CGRect(x: (UIScreen.main.bounds.width) / 2 + 70, y: 180,width: (UIScreen.main.bounds).width / 2 - 70 , height: 70))
            titleView2.backgroundColor = textColorLight
            self.addSubview(titleView2)
            
            
            titleLabel2 = createLabel(CGRect(x: 10, y: 5, width: 100, height: 30), text: "", alignment: .left, textColor: textColorDark)
            titleLabel2.font = UIFont(name: fontName, size: 16)
            titleView2.addSubview(titleLabel2)
            
            locLabel2 = createLabel(CGRect(x: 10, y: 30, width: 100, height: 30), text: "", alignment: .left, textColor: textColorMedium)
            locLabel2.font = UIFont(name: fontName, size: 12)
            titleView2.addSubview(locLabel2)
            
            dateLabel2 = createLabel(CGRect(x: 10, y: 50, width: 100, height: 30), text: "", alignment: .left, textColor: textColorMedium)
            dateLabel2.font = UIFont(name: fontName, size: 12)
            titleView2.addSubview(dateLabel2)
            
            listingDetailsLabel2 = createLabel(CGRect(x: 10, y: 70, width: 100, height: 30), text: "", alignment: .left, textColor: textColorMedium)
            listingDetailsLabel2.font = UIFont(name: "FontAwesome", size: 12)
            listingDetailsLabel2.isHidden = true
            titleView2.addSubview(listingDetailsLabel2)
            
            dateLabel3 = createLabel(CGRect(x: 20, y: 10, width: 50, height: 60), text: "", alignment: .center, textColor: textColorMedium)
            dateLabel3.font = UIFont(name: fontName, size: 16)
            dateView2.addSubview(dateLabel3)
            
            lineView2 = UIView(frame: CGRect(x: 0,y: 250,width: (UIScreen.main.bounds).width/2,height: 5))
            //lineView.layer.borderWidth = 7.0
            //lineView.layer.borderColor = UIColor.whiteColor().CGColor
            lineView2.backgroundColor = UIColor.white
            self.addSubview(lineView2)
            lineView2.isHidden = true
            
            
            contentImage2 = ContentImageViewWithGradient(frame: CGRect(x: 0, y: 0, width: cellView.bounds.width, height: 190))
            contentImage2.layer.masksToBounds = true
            contentImage2.backgroundColor = navColor
            contentImage2.layer.shadowColor = shadowColor.cgColor
            contentImage2.layer.shadowOffset = CGSize(width: 0,height: 5);
            contentImage2.layer.shadowOpacity = 0.5;
            contentImage2.contentMode = UIView.ContentMode.scaleAspectFill
            cellView2.addSubview(contentImage2)
            
            
            featuredLabel2 = createLabel(CGRect(x: 0, y: 0, width: 75, height: 20), text: "Featured", alignment: .center, textColor: textColorLight)
            featuredLabel2.font = UIFont(name: fontName, size: FONTSIZEMedium)
            featuredLabel2.backgroundColor = UIColor.init(red: 0, green: 176, blue: 182, alpha: 0)
            contentImage2.addSubview(featuredLabel2)
            featuredLabel2.sizeToFit()
            featuredLabel2.isHidden = true
            
            sponsoredLabel2 = createLabel(CGRect(x: contentImage2.bounds.width - 71, y: 0, width: 70, height: 20), text: "Sponsored", alignment: .center, textColor: textColorLight)
            sponsoredLabel2.font = UIFont(name: fontName, size: FONTSIZEMedium)
            sponsoredLabel2.backgroundColor = UIColor.red
            contentImage2.addSubview(sponsoredLabel2)
            sponsoredLabel2.sizeToFit()
            sponsoredLabel2.isHidden = true
            
            
            closeIconView2 = createLabel(CGRect(x: contentImage2.bounds.width/2 - contentImage2.bounds.width/6 , y: contentImage2.bounds.height/2 - contentImage2.bounds.height/6, width: contentImage2.bounds.width/3, height: contentImage2.bounds.height/3), text: " ", alignment: .center, textColor: textColorLight)
            closeIconView2.font = UIFont(name: "FontAwesome", size: FONTSIZELarge)
            closeIconView2.isHidden = true
            closeIconView2.layer.shadowColor = shadowColor.cgColor
            closeIconView2.layer.shadowOpacity = shadowOpacity
            closeIconView2.layer.shadowRadius = shadowRadius
            closeIconView2.layer.shadowOffset = shadowOffset
            cellView2.addSubview(closeIconView2)
            
            
            menuButton2 = createButton(CGRect(x: titleView2.bounds.width-40, y: 0, width: 30, height: 40), title: "\u{f141}", border: false,bgColor: false,textColor: textColorLight)
            menuButton2.titleLabel?.font =  UIFont(name: "FontAwesome", size:30.0)
            menuButton2.layer.shadowColor = shadowColor.cgColor
            menuButton2.layer.shadowOpacity = shadowOpacity
            menuButton2.layer.shadowRadius = shadowRadius
            menuButton2.layer.shadowOffset = shadowOffset
            cellView2.addSubview(menuButton2)
            menuButton2.isHidden = true
            
            
            contentName2 = createLabel(CGRect(x: 10, y: 110, width: (contentImage2.bounds.width-20), height: 100), text: "", alignment: .left, textColor: textColorLight)
            //        contentName2.layer.shadowColor = UIColor.lightGrayColor().CGColor
            //        contentName2.layer.shadowOpacity = 1.0
            //        contentName2.layer.shadowRadius = 4.0
            contentName2.numberOfLines = 0
            contentName2.layer.shadowColor = shadowColor.cgColor
            contentName2.layer.shadowOpacity = 0.2
            contentName2.layer.shadowRadius = shadowRadius
            contentName2.layer.shadowOffset = shadowOffset
            contentName2.font = UIFont(name: fontBold, size: FONTSIZEMedium)
            cellView2.addSubview(contentName2)
            
            totalMembers2 = createLabel(CGRect(x: 10, y: 150, width: 100, height: 40), text: "", alignment: .left, textColor: textColorDark)
            totalMembers2.font = UIFont(name: fontName, size: FONTSIZESmall)
            cellView2.addSubview(totalMembers2)
            
            createdBy2 = TTTAttributedLabel(frame: CGRect(x: 120, y: 150, width: contentImage2.bounds.width-120, height: 40))
            createdBy2.textAlignment = .right
            createdBy2.textColor = textColorLight
            //            createdBy2.layer.shadowColor = shadowColor.CGColor
            //            createdBy2.layer.shadowOpacity = shadowOpacity
            //            createdBy2.layer.shadowRadius = shadowRadius
            //            createdBy2.layer.shadowOffset = shadowOffset
            createdBy2.font = UIFont(name: fontName, size: FONTSIZESmall)
            cellView2.addSubview(createdBy2)
            
            eventTime2 = createLabel(CGRect(x: 50, y: 152, width: contentImage2.bounds.width-150, height: 20), text: "", alignment: .center, textColor: textColorDark)
            eventTime2.font = UIFont(name: fontBold, size: FONTSIZEMedium)
            eventTime2.textColor = UIColor.red
            cellView2.addSubview(eventTime2)
            
            menu2 = createButton(CGRect(x: contentImage2.bounds.width-30, y: 210, width: 30, height: 40), title: "\u{f141}", border: false,bgColor: false, textColor: textColorLight)
            menu2.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZELarge)
            cellView2.addSubview(menu2)
            menu2.isHidden = true
            contentSelection2 = createButton(cellView2.frame, title: "", border: false,bgColor: false, textColor: textColorLight)
            contentSelection2.frame.size.height = (cellView2.frame.size.height-40)
            self.addSubview(contentSelection2)
            
        }
    }
    func visibleVideoHeight() -> CGFloat {
        cellView.isHidden = false
        
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
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
