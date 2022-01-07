//
//  NativeAdinstallFeedCell.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 18/07/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit
//import GoogleMobileAds
class NativeAdinstallFeedCell: UITableViewCell , AutoPlayVideoLayerContainer
{
    
    var cellView = UIView()
    var profile_photo:UIImageView!
    var title:TTTAttributedLabel!
    var body:TTTAttributedLabel!
    var Adimageview:UIImageView!
    var Adiconview:UIImageView!
    var callToActionView:UIButton!
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
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
        
        
        
        if adsType_feeds == 0{
            Adiconview = createImageView(CGRect(x: cellView.frame.size.width-19, y: 0, width: 19, height: 15), border: true)
            Adiconview.image = UIImage(named: "ad_badge.png")
            cellView.addSubview(Adiconview)
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

