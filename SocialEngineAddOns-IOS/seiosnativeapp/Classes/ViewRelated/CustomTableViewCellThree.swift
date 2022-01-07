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

class CustomTableViewCellThree: UITableViewCell ,AutoPlayVideoLayerContainer{
    
    override func awakeFromNib() {
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
    var videoDuration : UILabel!
    var imgVideo : UIButton!
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
    
    var cellView2: UIView!
    var contentImage2:UIImageView!
    var contentName2:UILabel!
    var totalMembers2: UILabel!
    var createdBy2: TTTAttributedLabel!
    var menu2: UIButton!
    var eventTime2 :UILabel!
    var contentSelection2:UIButton!
    var videoDuration2 : UILabel!
    var imgVideo2 : UIButton!
     var imgViewOverLay : UIImageView!
    var imgViewOverLay2 : UIImageView!
    
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
            cellView = createView( CGRect(x: 2*PADING, y: 0 ,width: (UIScreen.main.bounds.width/2 - 4*PADING) , height: 230), borderColor: textColorclear, shadow: false)
        }else{
            cellView = createView( CGRect(x: 0, y: 0,width: (UIScreen.main.bounds.width) , height: 230), borderColor: textColorclear, shadow: false)
        }
        

        self.addSubview(cellView)
        
        Adimageview = createImageView(CGRect(x: 5,y: 60,width: cellView.bounds.width - 10,height: 165), border: false)
        Adimageview.isHidden = true
        Adimageview.backgroundColor = UIColor.black
        cellView.addSubview(Adimageview)
        
        videoLayer.backgroundColor = UIColor.clear.cgColor
        videoLayer.videoGravity = AVLayerVideoGravity.resize
        videoLayer.frame = Adimageview.bounds
        Adimageview.layer.addSublayer(videoLayer)
        
        contentImage = createImageView(CGRect(x: 0, y: 0, width: cellView.bounds.width, height: 190), border: false)
        contentImage.layer.cornerRadius = cornerRadiusSmall
        contentImage.layer.masksToBounds = true
        contentImage.contentMode = UIView.ContentMode.scaleAspectFill
        cellView.addSubview(contentImage)
        
        imgViewOverLay = createImageView(CGRect(x: 0, y: 0, width: cellView.bounds.width, height: 190), border: false)
        imgViewOverLay.layer.cornerRadius = cornerRadiusSmall
        imgViewOverLay.layer.masksToBounds = true
        imgViewOverLay.contentMode = UIView.ContentMode.scaleAspectFit
        cellView.addSubview(imgViewOverLay)
        
        videoDuration = createLabel(CGRect(x: (contentImage.bounds.width-60), y: 0, width: 60,height: 25), text: "", alignment: .center, textColor: textColorLight)
        videoDuration.font = UIFont(name: fontName, size: FONTSIZENormal)
        videoDuration.backgroundColor = UIColor.black
        videoDuration.isHidden = true
        contentImage.addSubview(videoDuration)
        
        // Set

        contentName = createLabel(CGRect(x: 10, y: 110, width: (contentImage.bounds.width-20), height: 100), text: "", alignment: .left, textColor: textColorLight)
        
        contentName.numberOfLines = 0
        contentName.font = UIFont(name: fontBold, size: FONTSIZEMedium)
        cellView.addSubview(contentName)
        
        
        
        totalMembers = createLabel(CGRect(x: 10, y: 190, width: 100, height: 40), text: "", alignment: .left, textColor: textColorDark)
        totalMembers.font = UIFont(name: fontName, size: FONTSIZESmall)
        totalMembers.textAlignment = .center
        cellView.addSubview(totalMembers)
        
   
        
        
        
        createdBy = TTTAttributedLabel(frame: CGRect(x: 120, y: 190, width: contentImage.bounds.width-120, height: 40))
        createdBy.textAlignment = .right
        createdBy.linkAttributes = [kCTForegroundColorAttributeName:textColorDark]
        createdBy.textColor = textColorDark
        createdBy.font = UIFont(name: fontName, size: FONTSIZESmall)
        cellView.addSubview(createdBy)
        
        eventTime = createLabel(CGRect(x: 50, y: 152, width: contentImage.bounds.width-150, height: 20), text: "", alignment: .center, textColor: textColorDark)
        eventTime.font = UIFont(name: fontBold, size: FONTSIZEMedium)
        eventTime.textColor = UIColor.red
        cellView.addSubview(eventTime)
        
        menu = createButton(CGRect(x: contentImage.bounds.width-40, y: 140, width: 40, height: 40), title: "\u{f141}", border: false,bgColor: false,textColor: textColorLight )
        menu.titleLabel?.font =  UIFont(name: "FontAwesome", size:30.0)
        menu.layer.shadowColor = shadowColor.cgColor
        menu.layer.shadowOpacity = shadowOpacity
        menu.layer.shadowRadius = shadowRadius
        menu.layer.shadowOffset = shadowOffset
        cellView.addSubview(menu)
        
        contentSelection = createButton(cellView.frame, title: "", border: false,bgColor: false, textColor: textColorLight)
        contentSelection.frame.size.height = (cellView.frame.size.height)
        self.addSubview(contentSelection)
        imgVideo = createButton(CGRect(x: (UIScreen.main.bounds.width/2) - 20, y: (contentSelection.bounds.height/2) - 30, width: 50, height: 50), title: "", border: false, bgColor: false, textColor: textColorMedium)
        imgVideo.center = contentImage.center
        imgVideo.setImage(UIImage(named: "VideoImage-white.png")!.maskWithColor(color: textColorLight), for: UIControl.State.normal)
        contentSelection.addSubview(imgVideo)
        

        if(UIDevice.current.userInterfaceIdiom == .pad){
            // RHS
            cellView2 = createView( CGRect(x: (UIScreen.main.bounds.width/2 + (2*PADING)), y: 0,width: (UIScreen.main.bounds.width/2 - 4*PADING) , height: 230), borderColor: textColorclear, shadow: false)

            self.addSubview(cellView2)
            

            contentImage2 = createImageView(CGRect(x: 0, y: 0, width: cellView.bounds.width, height: 190), border: true)
            contentImage2.layer.masksToBounds = true
            contentImage2.contentMode = UIView.ContentMode.scaleAspectFill //UIView.ContentMode.ScaleAspectFill
            cellView2.addSubview(contentImage2)
            
            imgViewOverLay2 = createImageView(CGRect(x: 0, y: 0, width: cellView.bounds.width, height: 190), border: true)
            imgViewOverLay2.layer.masksToBounds = true
            imgViewOverLay2.contentMode = UIView.ContentMode.scaleAspectFit //UIView.ContentMode.ScaleAspectFill
            cellView2.addSubview(imgViewOverLay2)
            
            
            videoDuration2 = createLabel(CGRect(x: (contentImage2.bounds.width-50), y: 0, width: 50,height: 30), text: "", alignment: .center, textColor: textColorLight)
            videoDuration2.font = UIFont(name: fontName, size: FONTSIZEMedium)
            videoDuration2.backgroundColor = UIColor.black
            videoDuration2.isHidden = true
            contentImage2.addSubview(videoDuration2)
            
            contentName2 = createLabel(CGRect(x: 10, y: 110, width: (contentImage.bounds.width-20), height: 100), text: "", alignment: .left, textColor: textColorLight)
            
            contentName2.numberOfLines = 0
            contentName2.font = UIFont(name: fontBold, size: FONTSIZEMedium)
            cellView2.addSubview(contentName2)
            
    
           
            
            totalMembers2 = createLabel(CGRect(x: 10, y: 190, width: 100, height: 40), text: "", alignment: .left, textColor: textColorDark)
            totalMembers2.font = UIFont(name: fontName, size: FONTSIZESmall)
            cellView2.addSubview(totalMembers2)
            
            createdBy2 = TTTAttributedLabel(frame: CGRect(x: 120, y: 190, width: contentImage.bounds.width-120, height: 40))
            createdBy2.textAlignment = .right
            createdBy2.linkAttributes = [kCTForegroundColorAttributeName:textColorDark]
            createdBy2.textColor = textColorDark
            createdBy2.font = UIFont(name: fontName, size: FONTSIZESmall)
            cellView2.addSubview(createdBy2)
            

            eventTime2 = createLabel(CGRect(x: 50, y: 152, width: contentImage.bounds.width-150, height: 20), text: "", alignment: .center, textColor: textColorDark)
            eventTime2.font = UIFont(name: fontBold, size: FONTSIZEMedium)
            eventTime2.textColor = UIColor.red
            cellView2.addSubview(eventTime2)
            
            menu2 = createButton(CGRect(x: contentImage2.bounds.width-40, y: 140, width: 40, height: 40), title: "\u{f141}", border: false,bgColor: false, textColor: textColorLight)
            menu2.titleLabel?.font =  UIFont(name: "FontAwesome", size:30.0)
            menu2.layer.shadowColor = shadowColor.cgColor

            menu2.layer.shadowOpacity = shadowOpacity
            menu2.layer.shadowRadius = shadowRadius
            menu2.layer.shadowOffset = shadowOffset
            cellView2.addSubview(menu2)
            
            contentSelection2 = createButton(cellView2.frame, title: "", border: false,bgColor: false, textColor: textColorLight)
            contentSelection2.frame.size.height = (cellView2.frame.size.height-90)
            self.addSubview(contentSelection2)
            imgVideo2 = createButton(CGRect(x: (UIScreen.main.bounds.width/2) - 20, y: (contentSelection2.bounds.height/2) - 30, width: 50, height: 50), title: "", border: false, bgColor: false, textColor: textColorMedium)
            imgVideo2.center = contentImage2.center
            imgVideo2.setImage(UIImage(named: "VideoImage-white.png")!.maskWithColor(color: textColorLight), for: UIControl.State.normal)
            contentSelection2.addSubview(imgVideo2)
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
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
