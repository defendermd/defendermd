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
//  ClassifiedTableViewCell.swift
//  seiosnativeapp
//


import UIKit

class NativeProductsCell: UITableViewCell , AutoPlayVideoLayerContainer{
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var ratings1 : UILabel!
    var productImageView1 : UIImageView!
    var bottomImageView1 : UIImageView!
    var classifiedName1 : UILabel!
    var actualPrice1 : UILabel!
    var menu1: UIButton!
    var discountedPrice1 : UILabel!

    var contentSelection1:UIButton!
    var borderView1 : UIView!
    var descriptionView1 : UIView!
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
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    
    // Initialize Variable for Comments Table Cell
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Configure the view for the selected state
        
        var size:CGFloat = 0;
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            size = (UIScreen.main.bounds.width - (5 * PADING))/3
        }
        else
        {
            size = (UIScreen.main.bounds.width - (4 * PADING))
        }
        
        size = (UIScreen.main.bounds.width - (2 * PADING))/2
        
        
        cellView = createView( CGRect(x: 0, y: 0,width: (UIScreen.main.bounds.width) , height: 320), borderColor: borderColorMedium, shadow: false)
      
 
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
        
        productImageView1 = Content1ImageViewWithGradient(frame: CGRect(x:(2 * PADING) + size  , y:contentPADING, width:size - 2*PADING , height:150-contentPADING))
        productImageView1.contentMode = UIView.ContentMode.scaleAspectFill
        productImageView1.layer.masksToBounds = true
        productImageView1.isUserInteractionEnabled = true
        productImageView1.backgroundColor = placeholderColor
        productImageView1.layer.shadowOpacity =  0.0
        
        self.addSubview(productImageView1)
        
        
        descriptionView1 = createView(CGRect(x:(2 * PADING) + size, y:150 ,width:size - 2*PADING ,height:80), borderColor: borderColorMedium, shadow: false)
        descriptionView1.layer.borderWidth = 0.5
        self.addSubview(descriptionView1)
        descriptionView1.isHidden = true
        
        
        featuredLabel1 = createLabel(CGRect(x:0, y:0, width:70, height:20), text: "Featured", alignment: .center, textColor: textColorLight)
        featuredLabel1.font = UIFont(name: fontName, size: FONTSIZEMedium)
        featuredLabel1.backgroundColor = UIColor.init(red: 0, green: 176/255, blue: 182/255, alpha: 1)
        productImageView1.addSubview(featuredLabel1)
        featuredLabel1.isHidden = true
        
        sponsoredLabel1 = createLabel(CGRect(x:0, y:25, width:70, height:20), text: "Sponsored", alignment: .center, textColor: textColorLight)
        sponsoredLabel1.font = UIFont(name: fontName, size: FONTSIZEMedium)
        sponsoredLabel1.backgroundColor = UIColor.red
        productImageView1.addSubview(sponsoredLabel1)
        sponsoredLabel1.isHidden = true

        
        
        menu1 = createButton(CGRect(x:productImageView1.bounds.width - 40,y:0, width:40, height:35), title: "\u{f141}", border: false,bgColor: false, textColor: textColorLight )
        menu1.titleLabel?.font =  UIFont(name: "FontAwesome", size:30.0)
        menu1.isHidden = true
        productImageView1.addSubview(menu1)
        
        
        classifiedName1 = createLabel(CGRect(x:5,y:5, width:descriptionView1.bounds.width-2, height:55), text: "", alignment: .left, textColor: textColorDark)
        classifiedName1.numberOfLines = 2
        classifiedName1.text = "Classified"
        
        
        classifiedName1.font = UIFont(name: fontBold, size: FONTSIZENormal)
        descriptionView1.addSubview(classifiedName1)
        
        ratings1 = createLabel(CGRect(x:2 , y:classifiedName1.bounds.height, width:descriptionView1.bounds.width, height:30), text: "", alignment: .left, textColor: textColorDark)
        ratings1.numberOfLines = 0
        ratings1.font = UIFont(name: fontName, size: FONTSIZESmall)
        descriptionView1.addSubview(ratings1)
        ratings1.isHidden = true
        
        actualPrice1 = createLabel(CGRect(x:5 , y:ratings1.frame.origin.y + ratings1.bounds.height, width:70, height:15), text: "", alignment: .left, textColor: textColorDark)
        actualPrice1.numberOfLines = 0
        actualPrice1.font = UIFont(name: fontName, size: FONTSIZESmall)
        descriptionView1.addSubview(actualPrice1)
        actualPrice1.isHidden = false
        
        
        discountedPrice1 = createLabel(CGRect(x:actualPrice1.frame.origin.x + actualPrice1.bounds.width + 5 , y:ratings1.frame.origin.y + ratings1.bounds.height, width:70, height:15), text: "", alignment: .left, textColor: textColorDark)
        discountedPrice1.numberOfLines = 0
        discountedPrice1.font = UIFont(name: fontName, size: FONTSIZESmall)
        descriptionView1.addSubview(discountedPrice1)
        discountedPrice1.isHidden = true

        
        
        contentSelection1 = createButton(CGRect(x:0, y:35, width:productImageView1.bounds.width, height:productImageView1.bounds.height - 40), title: "", border: false,bgColor: false, textColor: UIColor.clear)
        contentSelection1.layer.borderWidth = 0.0
        productImageView1.addSubview(contentSelection1)
        
        
    }
    
    func updateRating1(rating:Int, ratingCount:Int)
    {
        
        
        for ob in ratings1.subviews
        {
            ob.removeFromSuperview()
        }
        
        var origin_x = 0 as CGFloat
        for i in 1...5
        {
            let rate = createButton(CGRect(x:origin_x, y:2 , width:15, height:15), title: "", border: false, bgColor: false, textColor: textColorLight)
            rate.backgroundColor = UIColor.clear
           rate.setImage(UIImage(named: "graystar.png"), for: .normal)
            
            if i <= rating
            {
                rate.setImage(UIImage(named: "yellowStar.png"), for: .normal )
            }
            
            origin_x += 15
            ratings1.addSubview(rate)
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
