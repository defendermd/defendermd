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

class ClassifiedTableViewCell: UITableViewCell,AutoPlayVideoLayerContainer {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var classifiedImageView : UIImageView!
    var bottomImageView : UIImageView!
    var classifiedName : UILabel!
    var lblLoc : UILabel!
    var lblvideocount: UILabel!
    var DiaryName : UILabel!
    var classifiedPrice : UILabel!
    var menu: UIButton!
    var contentSelection:UIButton!
    var borderView : UIView!
    var MusicPlays : UILabel!
    var MusicPlays1 : UILabel!
    var closeIconView : UILabel!
    
    
    var classifiedImageView1 : UIImageView!
    var bottomImageView1 : UIImageView!
    var classifiedName1 : UILabel!
    var lblLoc1 : UILabel!
    var lblvideocount1: UILabel!
    var DiaryName1 : UILabel!
    var classifiedPrice1 : UILabel!
    var menu1: UIButton!
    var contentSelection1:UIButton!
    var borderView1 : UIView!
    var closeIconView1 : UILabel!
    
    //VARIABLES FOR MLT
    var listingDetailView : UIView!
    var listingNameLabel :UILabel!
    var listingDetailsLabel : UILabel!
    var listingOtherDetailsLabel : UILabel!
    var listingDetailView1 : UIView!
    var listingNameLabel1 :UILabel!
    var listingDetailsLabel1 : UILabel!
    var listingOtherDetailsLabel1 : UILabel!
    
    
    //For featured and sponsored label
    var featuredLabel:UILabel!
    var sponsoredLabel:UILabel!
    var featuredLabel1:UILabel!
    var sponsoredLabel1:UILabel!
    
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
        classifiedImageView = Content1ImageViewWithGradient(frame: CGRect(x: 2*PADING , y: contentPADING, width: size - 2*PADING, height: 160 - 5))
        classifiedImageView.contentMode = UIView.ContentMode.scaleAspectFill
        classifiedImageView.layer.masksToBounds = true
        classifiedImageView.isUserInteractionEnabled = true
        classifiedImageView.backgroundColor = placeholderColor
        self.addSubview(classifiedImageView)
        
        
        
        featuredLabel = createLabel(CGRect(x: 0, y: 0, width: 70, height: 20), text: "Featured", alignment: .center, textColor: textColorLight)
        featuredLabel.font = UIFont(name: fontName, size: FONTSIZEMedium)
        featuredLabel.backgroundColor = UIColor.init(red: 0, green: 176/255, blue: 182/255, alpha: 1)
        classifiedImageView.addSubview(featuredLabel)
        //featuredLabel.sizeToFit()
        featuredLabel.isHidden = true
        
        sponsoredLabel = createLabel(CGRect(x: 0, y: 25, width: 70, height: 20), text: "Sponsored", alignment: .center, textColor: textColorLight)
        sponsoredLabel.font = UIFont(name: fontName, size: FONTSIZEMedium)
        sponsoredLabel.backgroundColor = UIColor.red
        classifiedImageView.addSubview(sponsoredLabel)
        //sponsoredLabel.sizeToFit()
        sponsoredLabel.isHidden = true
        
        
        closeIconView = createLabel(CGRect(x: classifiedImageView.bounds.width/2 - classifiedImageView.bounds.width/4 , y: classifiedImageView.bounds.height/2 - classifiedImageView.bounds.height/4, width: classifiedImageView.bounds.width/2, height: classifiedImageView.bounds.height/2), text: " ", alignment: .center, textColor: textColorLight)
        closeIconView.font = UIFont(name: "FontAwesome", size: FONTSIZELarge)
        closeIconView.isHidden = true
        closeIconView.layer.shadowColor = shadowColor.cgColor
        closeIconView.layer.shadowOpacity = shadowOpacity
        closeIconView.layer.shadowRadius = shadowRadius
        closeIconView.layer.shadowOffset = shadowOffset
        classifiedImageView.addSubview(closeIconView)
        
        
        
        menu = createButton(CGRect(x: classifiedImageView.bounds.width - 40,y: 0, width: 40, height: 40), title: "\u{f141}", border: false,bgColor: false, textColor: textColorLight )
        menu.titleLabel?.font =  UIFont(name: "FontAwesome", size:30.0)
        menu.isHidden = true
        menu.layer.shadowColor = shadowColor.cgColor
        menu.layer.shadowOpacity = shadowOpacity
        menu.layer.shadowRadius = shadowRadius
        menu.layer.shadowOffset = shadowOffset
        
        classifiedImageView.addSubview(menu)
        
        contentSelection = createButton(CGRect(x: 0, y: 40, width: classifiedImageView.bounds.width, height: classifiedImageView.bounds.height - 40), title: "", border: false,bgColor: false, textColor: UIColor.clear)
        classifiedImageView.addSubview(contentSelection)
        
        //WORK FOR MLT PLUGIN
        listingDetailView = UIView( frame: CGRect(x: 2 * PADING, y: 155 , width: size , height: 30))
        listingDetailView.backgroundColor = UIColor.white
        listingDetailView.isHidden = true
        self.addSubview(listingDetailView)
        
        listingNameLabel = createLabel(CGRect(x: 0, y: 0, width: size, height: 14), text: "", alignment: .left, textColor: textColorMedium)
        listingNameLabel.font = UIFont(name: "FontAwesome", size:FONTSIZENormal)
        listingNameLabel.textColor = UIColor.black
        listingDetailView.addSubview(listingNameLabel)
        listingNameLabel.isHidden = true
        
        listingDetailsLabel = createLabel(CGRect(x: 0, y: 14, width: size, height: 14), text: "", alignment: .left, textColor: textColorMedium)
        listingDetailsLabel.font = UIFont(name: fontName, size: 12)
        listingDetailsLabel.textColor = UIColor.black
        listingDetailView.addSubview(listingDetailsLabel)
        listingDetailsLabel.isHidden = true
        
        listingOtherDetailsLabel = createLabel(CGRect(x: 0, y: 28, width: size, height: 14), text: "", alignment: .left, textColor: textColorMedium)
        listingOtherDetailsLabel.font = UIFont(name: "FontAwesome", size: 12)
        listingOtherDetailsLabel.textColor = UIColor.black
        listingDetailView.addSubview(listingOtherDetailsLabel)
        listingOtherDetailsLabel.isHidden = true
        // WORK FOR MLT PLUGIN ENDS
        
        DiaryName = createLabel(CGRect(x: 0  , y: (classifiedImageView.frame.size.height-30)/2, width: size, height: 30), text: "", alignment: .left, textColor: textColorLight)
        DiaryName.numberOfLines = 0
        DiaryName.font = UIFont(name: fontBold, size: FONTSIZENormal)
        self.addSubview(DiaryName)
        DiaryName.textAlignment = NSTextAlignment.center
        DiaryName.isHidden = true
        

        classifiedName = createLabel(CGRect(x: 4 * PADING  , y: 100, width: size, height: 30), text: "", alignment: .left, textColor: textColorLight)
        classifiedName.numberOfLines = 0
        classifiedName.textAlignment = .left
        classifiedName.layer.shadowOffset = CGSize(width: 0, height: -0.5)
        classifiedName.layer.shadowColor = UIColor.black.cgColor
        classifiedName.layer.shadowOpacity = 0.5
        classifiedName.layer.shadowRadius = 0.5
        classifiedName.font = UIFont(name: fontBold, size: FONTSIZENormal)
        self.addSubview(classifiedName)
        
        lblLoc = createLabel(CGRect(x: 4 * PADING  , y: 125, width: size, height: 25), text: "", alignment: .left, textColor: textColorLight)
        lblLoc.numberOfLines = 1
        lblLoc.textAlignment = .left
        lblLoc.lineBreakMode = .byTruncatingTail
        lblLoc.layer.shadowOffset = CGSize(width: 0, height: -0.5)
        lblLoc.layer.shadowColor = UIColor.black.cgColor
        lblLoc.layer.shadowOpacity = 0.5
        lblLoc.layer.shadowRadius = 0.5
        lblLoc.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
        self.addSubview(lblLoc)
        
        lblvideocount = createLabel(CGRect(x: classifiedName.frame.origin.x , y: 145, width: size, height: 10), text: "", alignment: .left, textColor: textColorLight)
        lblvideocount.numberOfLines = 0
        lblvideocount.font = UIFont(name: fontBold, size: FONTSIZESmall)
        lblvideocount.isHidden = true
        lblvideocount.textAlignment = .left
        self.addSubview(lblvideocount)
        
        MusicPlays = createLabel(CGRect(x: 3 * PADING  , y: 140, width: size, height: 13), text: "", alignment: .left, textColor: textColorLight)
        MusicPlays.numberOfLines = 0
        MusicPlays.font = UIFont(name: fontName, size: FONTSIZENormal)

        self.addSubview(MusicPlays)
        MusicPlays.isHidden = true
        
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
        featuredLabel1.isHidden = true

        
        sponsoredLabel1 = createLabel(CGRect(x: 0, y: 25, width: 70, height: 20), text: "Sponsored", alignment: .center, textColor: textColorLight)
        sponsoredLabel1.font = UIFont(name: fontName, size: FONTSIZEMedium)
        sponsoredLabel1.backgroundColor = UIColor.red
        classifiedImageView1.addSubview(sponsoredLabel1)

        sponsoredLabel1.isHidden = true
        
        
        closeIconView1 = createLabel(CGRect(x: classifiedImageView1.bounds.width/2 - classifiedImageView.bounds.width/4 , y: classifiedImageView1.bounds.height/2 - classifiedImageView1.bounds.height/4, width: classifiedImageView1.bounds.width/2, height: classifiedImageView1.bounds.height/2), text: " ", alignment: .center, textColor: textColorLight)
        closeIconView1.font = UIFont(name: "FontAwesome", size: FONTSIZELarge)
        closeIconView1.isHidden = true
        closeIconView1.layer.shadowColor = shadowColor.cgColor
        closeIconView1.layer.shadowOpacity = shadowOpacity
        closeIconView1.layer.shadowRadius = shadowRadius
        closeIconView1.layer.shadowOffset = shadowOffset
        classifiedImageView1.addSubview(closeIconView1)

        
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
        
        classifiedName1 = createLabel(CGRect(x: (4*PADING) + size  , y: 100, width: size, height: 30), text: "", alignment: .left, textColor: textColorLight)
        classifiedName1.numberOfLines = 0
        classifiedName1.text = "Classified"
        classifiedName1.layer.shadowOffset = CGSize(width: 0, height: -0.5)
        classifiedName1.layer.shadowColor = UIColor.black.cgColor
        classifiedName1.layer.shadowOpacity = 0.5
        classifiedName1.layer.shadowRadius = 0.5
        classifiedName1.font = UIFont(name: fontBold, size: FONTSIZENormal)
        classifiedName1.textAlignment = .left
        self.addSubview(classifiedName1)
        
        lblLoc1 = createLabel(CGRect(x: (4*PADING) + size  , y: 125, width: size, height: 25), text: "", alignment: .left, textColor: textColorLight)
        lblLoc1.numberOfLines = 1
        lblLoc1.textAlignment = .left
        lblLoc1.lineBreakMode = .byTruncatingTail
        lblLoc1.layer.shadowOffset = CGSize(width: 0, height: -0.5)
        lblLoc1.layer.shadowColor = UIColor.black.cgColor
        lblLoc1.layer.shadowOpacity = 0.5
        lblLoc1.layer.shadowRadius = 0.5
        lblLoc1.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
        self.addSubview(lblLoc1)
        
        lblvideocount1 = createLabel(CGRect(x: classifiedName1.frame.origin.x , y: 145, width: size, height: 10), text: "", alignment: .left, textColor: textColorLight)
        lblvideocount1.numberOfLines = 0
        lblvideocount1.font = UIFont(name: fontBold, size: FONTSIZESmall)
        lblvideocount1.isHidden = true
        lblvideocount1.textAlignment = .left
        self.addSubview(lblvideocount1)
        
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
        
    }
    func visibleVideoHeight() -> CGFloat {
        
        //viewVideo.isHidden = false
        
        let videoFrameInParentSuperView: CGRect? = self.superview?.superview?.superview?.convert(self.frame, from: self)
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
        lblLoc.text = ""
        lblLoc1.text = ""
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
