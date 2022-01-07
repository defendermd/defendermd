//
//  NativeEventCell.swift
//  seiosnativeapp
//
//  Created by Ankit on 23/07/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit

class NativeEventCell: UITableViewCell ,AutoPlayVideoLayerContainer{

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
   
    var cellView2: UIView!
    var cellView: UIView!
    var contentImage2:UIImageView!
    var hostImage2:UIImageView!
    var hostSelection2:UIButton!
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
    var gutterMenu2: UIButton!
    var lineView2 : UIView!
    
    var btnMembercount2:UIButton!
    var lblMembercount2 : UILabel!
    var btnviewcount2:UIButton!
    var lblviewcount2 : UILabel!
    var btnlikecount2:UIButton!
    var lbllikecount2 : UILabel!
    var btnTittle2:UIButton!
    var btnDate1:UIButton!
    var featuredLabel2:UILabel!
    var sponsoredLabel2:UILabel!
    var Adimageview:UIImageView!
    var btnMuteUnMuteIcon:UIButton!
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
            cellView = createView( CGRect(x: 0, y: 0,width: (UIScreen.main.bounds.width/2) , height: 260), borderColor: borderColorMedium, shadow: false)
        }else{
            cellView = createView( CGRect(x: 0, y: 0,width: (UIScreen.main.bounds.width) , height: 260), borderColor: borderColorMedium, shadow: false)
        }
//        cellView.backgroundColor = UIColor.white
//        self.addSubview(cellView)
        
        cellView.frame = CGRect(x: 0, y: 5,width: UIScreen.main.bounds.width ,height: 320)
        
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
            cellView2 = createView( CGRect(x: (UIScreen.main.bounds.width/2), y: 0,width: (UIScreen.main.bounds.width/2) , height: 260), borderColor: borderColorMedium, shadow: false)
            
            cellView2.layer.borderWidth = 0.0
            self.addSubview(cellView2)
            cellView2.isUserInteractionEnabled = true
            
            
            
            
            titleView2 = UIView( frame: CGRect(x: (UIScreen.main.bounds.width) / 2 + 70, y: 180,width: (UIScreen.main.bounds).width / 2 - 70 , height: 80))
            titleView2.backgroundColor = textColorLight
            titleView2.isUserInteractionEnabled = true
            self.addSubview(titleView2)
            
            dateView2 = UIView( frame: CGRect(x: (UIScreen.main.bounds.width/2), y: 180,width: 70 , height: titleView2.frame.size.height))
            dateView2.backgroundColor = navColor
            dateView2.isUserInteractionEnabled = true
            self.addSubview(dateView2)
            
            
            titleLabel2 = createLabel(CGRect(x: 10, y: 5, width: 100, height: 30), text: "", alignment: .left, textColor: textColorDark)
            titleLabel2.font = UIFont(name: fontName, size: 16)
            titleLabel2.isUserInteractionEnabled = true
            titleView2.addSubview(titleLabel2)
            
            btnTittle2  = createButton(CGRect(x: titleLabel2.frame.origin.x,y: titleLabel2.frame.origin.y-5, width: titleView2.frame.size.width-30, height: titleLabel2.frame.size.height), title: "", border: false,bgColor: false,textColor: UIColor.clear)
            btnTittle2.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZELarge)
            titleLabel2.addSubview(btnTittle2)
            
            
            locLabel2 = createLabel(CGRect(x: 10, y: 30, width: 100, height: 30), text: "", alignment: .left, textColor: textColorMedium)
            locLabel2.font = UIFont(name: fontName, size: 12)
            titleView2.addSubview(locLabel2)
            
            dateLabel2 = createLabel(CGRect(x: 10, y: 50, width: 100, height: 30), text: "", alignment: .left, textColor: textColorMedium)
            dateLabel2.font = UIFont(name: fontName, size: 12)
            titleView2.addSubview(dateLabel2)
            
            dateLabel3 = createLabel(CGRect(x: 0,  y: (titleView2.frame.size.height-60)/2, width: 50, height: 60), text: "", alignment: .left, textColor: textColorMedium)
            dateLabel3.font = UIFont(name: fontName, size: 16)
            dateLabel3.textAlignment = NSTextAlignment.center
            dateLabel3.isUserInteractionEnabled = true
            dateView2.addSubview(dateLabel3)
            
            
            btnDate1  = createButton(CGRect(x: 0, y: (titleView2.frame.size.height-50)/2, width: 70, height: 60), title: "", border: false,bgColor: false,textColor: UIColor.clear)
            btnDate1.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZELarge)
            dateLabel3.addSubview(btnDate1)
            btnDate1.backgroundColor = UIColor.clear
            btnDate1.isUserInteractionEnabled = true
            
            
            
            
            
            btnMembercount2  = createButton(CGRect(x: 12,y: dateLabel2.frame.size.height+dateLabel2.frame.origin.y+20-30, width: 20, height: 20), title: "\u{f007}", border: false,bgColor: false,textColor: textColorMedium)
            btnMembercount2.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZELarge)
            titleView2.addSubview(btnMembercount2)
            btnMembercount2.isHidden = true
            
            lblMembercount2 = createLabel(CGRect(x: btnMembercount2.frame.origin.x + btnMembercount2.frame.size.width+10, y: dateLabel2.frame.size.height+dateLabel2.frame.origin.y+20-30, width: 20, height: 20), text: "20", alignment: .left, textColor: textColorMedium)
            lblMembercount2.font = UIFont(name: fontName, size: 12)
            titleView2.addSubview(lblMembercount2)
            lblMembercount2.isHidden = true
            
            btnviewcount2  = createButton(CGRect(x: lblMembercount2.frame.origin.x + lblMembercount2.frame.size.width+20,y: dateLabel2.frame.size.height+dateLabel2.frame.origin.y+20-30, width: 20, height: 20), title: "\u{f06e}", border: false,bgColor: false,textColor: textColorMedium)
            btnviewcount2.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZELarge)
            titleView2.addSubview(btnviewcount2)
            btnviewcount2.isHidden = true
            
            lblviewcount2 = createLabel(CGRect(x: btnviewcount2.frame.origin.x + btnviewcount2.frame.size.width+10, y: dateLabel2.frame.size.height+dateLabel2.frame.origin.y+20-30, width: 20, height: 20), text: "200", alignment: .left, textColor: textColorMedium)
            lblviewcount2.font = UIFont(name: fontName, size: 12)
            titleView2.addSubview(lblviewcount2)
            lblviewcount2.isHidden = true
            
            
            
            btnlikecount2  = createButton(CGRect(x: lblviewcount2.frame.origin.x + lblviewcount2.frame.size.width+20,y: dateLabel2.frame.size.height+dateLabel2.frame.origin.y+20-30, width: 20, height: 20), title: "\u{f164}", border: false,bgColor: false,textColor: textColorMedium)
            btnlikecount2.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZELarge)
            titleView2.addSubview(btnlikecount2)
            btnlikecount2.isHidden = true
            
            lbllikecount2 = createLabel(CGRect(x: btnlikecount2.frame.origin.x + btnlikecount2.frame.size.width+10, y: dateLabel2.frame.size.height+dateLabel2.frame.origin.y+20-30, width: 20, height: 20), text: "500", alignment: .left, textColor: textColorMedium)
            lbllikecount2.font = UIFont(name: fontName, size: 12)
            titleView2.addSubview(lbllikecount2)
            lbllikecount2.isHidden = true
            
            
            menuButton2 = createButton(CGRect(x: titleView2.bounds.width-40, y: 0, width: 30, height: 40), title: "\u{f141}", border: false,bgColor: false,textColor: textColorMedium)
            menuButton2.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZEExtraLarge)
            titleView2.addSubview(menuButton2)
            menuButton2.isHidden = true
            
            
            lineView2 = UIView(frame: CGRect(x: 0,y: 250,width: (UIScreen.main.bounds).width/2,height: 5))
            //lineView.layer.borderWidth = 7.0
            //lineView.layer.borderColor = UIColor.whiteColor().CGColor
            lineView2.backgroundColor = UIColor.white
            self.addSubview(lineView2)
            lineView2.isHidden = true
            
            
            contentImage2 = ContentImageViewWithGradientadvanced(frame: CGRect(x: 0, y: 0, width: cellView.bounds.width, height: 190))
            contentImage2.layer.masksToBounds = true
            contentImage2.backgroundColor = placeholderColor
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
            
            sponsoredLabel2 = createLabel(CGRect(x: contentImage2.bounds.width - 73, y: 0, width: 70, height: 20), text: "Sponsored", alignment: .center, textColor: textColorLight)
            sponsoredLabel2.font = UIFont(name: fontName, size: FONTSIZEMedium)
            sponsoredLabel2.backgroundColor = UIColor.red
            contentImage2.addSubview(sponsoredLabel2)
            sponsoredLabel2.sizeToFit()
            sponsoredLabel2.isHidden = true
            
            contentSelection2 = createButton(cellView2.frame, title: "", border: false,bgColor: false, textColor: textColorLight)
            contentSelection2.frame.size.height = (cellView2.frame.size.height-40)
            self.addSubview(contentSelection2)
            
            
            gutterMenu2  = createButton(CGRect(x: contentSelection2.bounds.width-40,y: contentSelection2.frame.origin.y, width: 45, height: 45), title: "", border: false,bgColor: false,textColor: UIColor.clear)
            gutterMenu2.setImage(UIImage(named: "option"), for: UIControl.State())
            contentSelection2.addSubview(gutterMenu2)
            gutterMenu2.isHidden = true
            //gutterMenu2.backgroundColor = UIColor.redColor()
            
            //Set HostImage
            hostImage2 = createImageView(CGRect(x: cellView2.bounds.width-80, y: 100, width: 70, height: 70), border: false)
            hostImage2.layer.masksToBounds = false
            hostImage2.backgroundColor = placeholderColor
            hostImage2.layer.borderWidth = 2.0
            hostImage2.layer.borderColor = borderColorLight.cgColor
            hostImage2.layer.cornerRadius = hostImage2.frame.height/2
            hostImage2.clipsToBounds = true
            hostImage2.isHidden = true
            hostImage2.isUserInteractionEnabled = true
            contentSelection2.addSubview(hostImage2)
            
            hostSelection2 = createButton(CGRect(x: cellView2.bounds.width-80, y: 100, width: 70, height: 70), title: "", border: false,bgColor: false, textColor:UIColor.clear)
            hostSelection2.isHidden = true
            hostSelection2.backgroundColor = UIColor.clear
            hostSelection2.isUserInteractionEnabled = true
            contentSelection2.addSubview(hostSelection2)
            
            
            
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
            
            menuButton2 = createButton(CGRect(x: cellView2.bounds.width-40, y: 0, width: 40, height: 40), title: "\u{f141}", border: false,bgColor: false,textColor: textColorLight)
            menuButton2.titleLabel?.font =  UIFont(name: "FontAwesome", size:30.0)
            menuButton2.layer.shadowColor = shadowColor.cgColor
            menuButton2.layer.shadowOpacity = shadowOpacity
            menuButton2.layer.shadowRadius = shadowRadius
            menuButton2.layer.shadowOffset = shadowOffset
            
            cellView2.addSubview(menuButton2)
            menuButton2.isHidden = true
            
            
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
            
            //            contentSelection2 = createButton(CGRect(x:(UIScreen.main.bounds.width/2), 40,(UIScreen.main.bounds.width/2) , 250), title: "", border: false,bgColor: false, textColor: textColorLight)
            //            contentSelection2.frame.size.height = (cellView2.frame.size.height-40)
            //            self.addSubview(contentSelection2)
            
            
        }
    }
    func visibleVideoHeight() -> CGFloat {
        cellView.isHidden = false
        //viewVideo.isHidden = false
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
