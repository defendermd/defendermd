
//
//  NativeVideoCellTableViewCell.swift
//  seiosnativeapp
//
//  Created by Ankit on 23/07/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit

class NativeVideoCellTableViewCell: UITableViewCell, AutoPlayVideoLayerContainer{

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var cellView: UIView!
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
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Configure the view for the selected state
        
        // LHS
        if(UIDevice.current.userInterfaceIdiom == .pad){
            cellView = createView( CGRect(x: 0, y: 0 ,width: (UIScreen.main.bounds.width) , height: 320), borderColor: borderColorMedium, shadow: false)
        }else{
            cellView = createView( CGRect(x: 0, y: 0,width: (UIScreen.main.bounds.width ) , height: 320), borderColor: borderColorMedium, shadow: false)
        }
        let cornerRadius: CGFloat = 2
        let shadowOffsetWidth: Int = 0
        let shadowOffsetHeight: Int = 3
        let shadowOpacity: Float = 0.5
        cellView.layer.cornerRadius = cornerRadius
        cellView.layer.masksToBounds = false
        cellView.layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight);
        cellView.layer.shadowOpacity = shadowOpacity
        
        cellView.backgroundColor = bgColor
        self.addSubview(cellView)
        Adimageview = createImageView(CGRect(x: 5,y: 60,width: cellView.bounds.width - 10,height: 165), border: false)
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
            cellView2 = createView( CGRect(x: (UIScreen.main.bounds.width/2 + PADING), y: 0,width: (UIScreen.main.bounds.width/2 - 2*PADING) , height: 230), borderColor: borderColorMedium, shadow: false)
            
            cellView2.layer.shadowColor = shadowColor.cgColor
            cellView2.layer.shadowOpacity = shadowOpacity
            cellView2.layer.shadowRadius = shadowRadius
            cellView2.layer.shadowOffset = shadowOffset
            self.addSubview(cellView2)
            
            contentImage2 = createImageView(CGRect(x: 0, y: 0, width: cellView.bounds.width, height: 190), border: true)
            contentImage2.layer.masksToBounds = true
            contentImage2.contentMode = UIView.ContentMode.scaleAspectFill //UIView.ContentMode.ScaleAspectFill
            cellView2.addSubview(contentImage2)
            
            imgViewOverLay = createImageView(CGRect(x: 0, y: 0, width: cellView.bounds.width, height: 190), border: true)
            imgViewOverLay.layer.masksToBounds = true
            imgViewOverLay.contentMode = UIView.ContentMode.scaleAspectFit
            cellView2.addSubview(imgViewOverLay)
            
            
            videoDuration2 = createLabel(CGRect(x: (contentImage2.bounds.width-50), y: 0, width: 50,height: 30), text: "", alignment: .center, textColor: textColorLight)
            videoDuration2.font = UIFont(name: fontName, size: FONTSIZEMedium)
            videoDuration2.backgroundColor = UIColor.black
            videoDuration2.isHidden = true
            contentImage2.addSubview(videoDuration2)
            
            contentName2 = createLabel(CGRect(x: 10, y: 110, width: (contentImage2.bounds.width-20), height: 100), text: "", alignment: .left, textColor: textColorLight)
            //        contentName2.layer.shadowColor = UIColor.lightGrayColor().CGColor
            //        contentName2.layer.shadowOpacity = 1.0
            //        contentName2.layer.shadowRadius = 4.0
            contentName2.numberOfLines = 0
            contentName2.layer.shadowColor = shadowColor.cgColor
            contentName2.layer.shadowOpacity = shadowOpacity
            contentName2.layer.shadowRadius = shadowRadius
            contentName2.layer.shadowOffset = shadowOffset
            contentName2.font = UIFont(name: fontBold, size: FONTSIZEMedium)
            cellView2.addSubview(contentName2)
            
            
//            videoPlayLabel2 = createLabel(CGRect(x: 10, y: 150, width: 100, height: 40), text: "\u{f04b}", alignment: .center, textColor: textColorLight)
//            videoPlayLabel2.frame = contentImage2.frame
//            videoPlayLabel2.font = UIFont(name: "FontAwesome", size: FONTSIZELarge)
//            videoPlayLabel2.textAlignment = NSTextAlignment.center
//            cellView.addSubview(videoPlayLabel2)
            
        
           
            
            totalMembers2 = createLabel(CGRect(x: 10, y: 190, width: 100, height: 40), text: "", alignment: .left, textColor: textColorDark)
            totalMembers2.font = UIFont(name: fontName, size: FONTSIZESmall)
            cellView2.addSubview(totalMembers2)
            
            createdBy2 = TTTAttributedLabel(frame: CGRect(x: 120, y: 190, width: contentImage2.bounds.width-120, height: 40))
            createdBy2.textAlignment = .right
            createdBy2.textColor = textColorDark
            createdBy2.font = UIFont(name: fontName, size: FONTSIZESmall)
            cellView2.addSubview(createdBy2)
            
            eventTime2 = createLabel(CGRect(x: 50, y: 152, width: contentImage2.bounds.width-150, height: 20), text: "", alignment: .center, textColor: textColorDark)
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
//        else{
//            self.addSubview(cellView)
//            Adimageview = createImageView(CGRect(x: 30,y: 60,width: cellView.bounds.width - 60,height: 165), border: false)
//            Adimageview.isHidden = true
//            cellView.addSubview(Adimageview)
//
//            videoLayer.backgroundColor = UIColor.clear.cgColor
//            videoLayer.videoGravity = AVLayerVideoGravity.resize
//            videoLayer.frame = Adimageview.bounds
//            Adimageview.layer.addSublayer(videoLayer)
//        }
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
