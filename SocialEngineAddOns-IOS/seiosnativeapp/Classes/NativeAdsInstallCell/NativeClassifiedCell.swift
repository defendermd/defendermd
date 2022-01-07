//
//  NativeClassifiedCell.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 25/07/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit

class NativeClassifiedCell: UITableViewCell,AutoPlayVideoLayerContainer {

    var classifiedImageView1 : UIImageView!
    var bottomImageView1 : UIImageView!
    var classifiedName1 : UILabel!
    var lblLoc1 = UILabel()
    var DiaryName1 : UILabel!
    var classifiedPrice1 : UILabel!
    var menu1: UIButton!
    var contentSelection1:UIButton!
    var borderView1 : UIView!
    var closeIconView1 : UILabel!
    var MusicPlays1 : UILabel!
    
    //VARIABLES FOR MLT
    var listingDetailView1 : UIView!
    var listingNameLabel1 :UILabel!
    var listingDetailsLabel1 : UILabel!
    var listingOtherDetailsLabel1 : UILabel!
    
    
    //For featured and sponsored label
    var featuredLabel1:UILabel!
    var sponsoredLabel1:UILabel!
    
    var cellView: UIView!
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    // Initialize Variable for Comments Table Cell
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Configure the view for the selected state
        
        var size:CGFloat = 0;
        if(UIDevice.current.userInterfaceIdiom == .pad){
            size = (UIScreen.main.bounds.width - (5 * PADING))/3
        }else{
            size = (UIScreen.main.bounds.width - (4 * PADING))
        }
        
        size = (UIScreen.main.bounds.width - (2 * PADING))/2
        cellView = createView( CGRect(x: 0, y: 0,width: (UIScreen.main.bounds.width ) , height: 320), borderColor: borderColorMedium, shadow: false)
        //        borderView = createView(CGRect(x:0 , 0, size, 155), UIColor.clearColor() , true)
        //        self.addSubview(borderView)
    //    cellView.frame = CGRect(x: 0, y: 5,width: UIScreen.main.bounds.width ,height: 320)
        
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
        
       //  if(UIDevice.current.userInterfaceIdiom == .pad){
        classifiedImageView1 = Content1ImageViewWithGradient(frame: CGRect(x: (2 * PADING) + size  , y: contentPADING, width: size - 2*PADING , height: 160-5))
        classifiedImageView1.contentMode = UIView.ContentMode.scaleAspectFill
        classifiedImageView1.layer.masksToBounds = true
        classifiedImageView1.isUserInteractionEnabled = true
        classifiedImageView1.backgroundColor = placeholderColor
        
        self.addSubview(classifiedImageView1)
        
        
        
        featuredLabel1 = createLabel(CGRect(x: 0, y: 0, width: 70, height: 20), text: "Featured", alignment: .center, textColor: textColorLight)
        featuredLabel1.font = UIFont(name: fontName, size: FONTSIZEMedium)
        featuredLabel1.backgroundColor = UIColor.init(red: 0, green: 176/255, blue: 182/255, alpha: 1)
        classifiedImageView1.addSubview(featuredLabel1)
        //featuredLabel1.sizeToFit()
        
        
        sponsoredLabel1 = createLabel(CGRect(x: 0, y: 25, width: 70, height: 20), text: "Sponsored", alignment: .center, textColor: textColorLight)
        sponsoredLabel1.font = UIFont(name: fontName, size: FONTSIZEMedium)
        sponsoredLabel1.backgroundColor = UIColor.red
        classifiedImageView1.addSubview(sponsoredLabel1)
        //sponsoredLabel1.sizeToFit()
        sponsoredLabel1.isHidden = true
        
        
        closeIconView1 = createLabel(CGRect(x: classifiedImageView1.bounds.width/2 - classifiedImageView1.bounds.width/4 , y: classifiedImageView1.bounds.height/2 - classifiedImageView1.bounds.height/4, width: classifiedImageView1.bounds.width/2, height: classifiedImageView1.bounds.height/2), text: " ", alignment: .center, textColor: textColorLight)
        closeIconView1.font = UIFont(name: "FontAwesome", size: FONTSIZELarge)
        closeIconView1.isHidden = true
        closeIconView1.layer.shadowColor = shadowColor.cgColor
        closeIconView1.layer.shadowOpacity = shadowOpacity
        closeIconView1.layer.shadowRadius = shadowRadius
        closeIconView1.layer.shadowOffset = shadowOffset
        classifiedImageView1.addSubview(closeIconView1)
        
        //        bottomImageView1 = createImageView(CGRect(x:(2*PADING) + size  , 150, size, 50), true)
        //        bottomImageView1.contentMode = UIView.ContentMode.ScaleAspectFill
        //        bottomImageView1.layer.masksToBounds = true
        //        bottomImageView1.backgroundColor =  UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        //        self.addSubview(bottomImageView1)
        //
        
        menu1 = createButton(CGRect(x: classifiedImageView1.bounds.width - 40,y: 0, width: 40, height: 40), title: "\u{f141}", border: false,bgColor: false, textColor: textColorLight )
        menu1.titleLabel?.font =  UIFont(name: "FontAwesome", size:30.0)
        menu1.isHidden = true
        menu1.layer.shadowColor = shadowColor.cgColor
        menu1.layer.shadowOpacity = shadowOpacity
        menu1.layer.shadowRadius = shadowRadius
        menu1.layer.shadowOffset = shadowOffset
        
        classifiedImageView1.addSubview(menu1)
        
        DiaryName1 = createLabel(CGRect(x: size  , y: (classifiedImageView1.frame.size.height-30)/2, width: size, height: 30), text: "", alignment: .left, textColor: textColorLight)
        DiaryName1.numberOfLines = 0
        DiaryName1.font = UIFont(name: fontBold, size: FONTSIZENormal)
        self.addSubview(DiaryName1)
        DiaryName1.textAlignment = NSTextAlignment.center
        DiaryName1.isHidden = true
        
        classifiedName1 = createLabel(CGRect(x: (3*PADING) + size  , y: 100, width: size, height: 30), text: "", alignment: .left, textColor: textColorLight)
        classifiedName1.numberOfLines = 0
        classifiedName1.text = ""
        
        //        classifiedName1.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        classifiedName1.font = UIFont(name: fontBold, size: FONTSIZENormal)
        self.addSubview(classifiedName1)
        
        lblLoc1 = createLabel(CGRect(x: (3*PADING) + size  , y: getBottomEdgeY(inputView: classifiedName1), width: size, height: 25), text: "", alignment: .left, textColor: textColorLight)
        lblLoc1.numberOfLines = 1
        lblLoc1.text = ""
        
        //        classifiedName1.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        lblLoc1.font = UIFont(name: fontBold, size: FONTSIZENormal)
        self.addSubview(lblLoc1)
        
        MusicPlays1 = createLabel(CGRect(x: 3 * PADING + size , y: 140, width: size, height: 13), text: "", alignment: .left, textColor: textColorLight)
        MusicPlays1.numberOfLines = 0
        MusicPlays1.font = UIFont(name: fontName, size: FONTSIZESmall)
        //        classifiedName.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        self.addSubview(MusicPlays1)
        MusicPlays1.isHidden = true
        
        contentSelection1 = createButton(CGRect(x: 0, y: 40, width: classifiedImageView1.bounds.width, height: classifiedImageView1.bounds.height - 40), title: "", border: false,bgColor: false, textColor: UIColor.clear)
        classifiedImageView1.addSubview(contentSelection1)
        
        listingDetailView1 = UIView( frame: CGRect(x: (2 * PADING) + size, y: 155 , width: size , height: 30))
        listingDetailView1.backgroundColor = UIColor.white
        listingDetailView1.isHidden = true
        self.addSubview(listingDetailView1)
        
        
        listingNameLabel1 = createLabel(CGRect(x: 0, y: 0, width: size, height: 14), text: "", alignment: .left, textColor: textColorMedium)
        listingNameLabel1.font = UIFont(name: "FontAwesome", size:FONTSIZENormal)
        listingNameLabel1.textColor = UIColor.black
        listingDetailView1.addSubview(listingNameLabel1)
        listingNameLabel1.isHidden = true
        
        listingDetailsLabel1 = createLabel(CGRect(x: 0, y: 14, width: size, height: 14), text: "", alignment: .left, textColor: textColorMedium)
        listingDetailsLabel1.font = UIFont(name: fontName, size: 12)
        listingDetailsLabel1.textColor = UIColor.black
        listingDetailView1.addSubview(listingDetailsLabel1)
        listingDetailsLabel1.isHidden = true
        
        listingOtherDetailsLabel1 = createLabel(CGRect(x: 0, y: 28, width: size, height: 14), text: "", alignment: .left, textColor: textColorMedium)
        listingOtherDetailsLabel1.font = UIFont(name: "FontAwesome", size: 12)
        listingOtherDetailsLabel1.textColor = UIColor.black
        listingDetailView1.addSubview(listingOtherDetailsLabel1)
        listingOtherDetailsLabel1.isHidden = true
       // }
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
