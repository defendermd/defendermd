
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

import UIKit

// This Class is used in MLT Browse view

class MLTGridTableViewCell: UITableViewCell,AutoPlayVideoLayerContainer {
    
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
    var dateView : UIView!
    var titleView : UIView!
    var titleLabel : UILabel!
    var statsLabel : UILabel!
    var locLabel : UILabel!
    var dateLabel : UILabel!
    var dateLabel1 : UILabel!
    var menuButton: UIButton!
    var lineView : UIView!
    var closeIconView : UILabel!
    
    var cellView2: UIView!
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
    var statsLabel2 : UILabel!
    var locLabel2 : UILabel!
    var dateLabel2 : UILabel!
    var dateLabel3 : UILabel!
    var menuButton2 : UIButton!
    var lineView2 : UIView!
    var closeIconView2 : UILabel!
    
    //VARIABLE FOR MLT PLUGIN
    var listingPriceTagLabel: UILabel!
    var listingDetailsLabel :UILabel!
    var listingDetailsLabel2 : UILabel!
    
    //For featured and sponsored label
    var featuredLabel:UILabel!
    var sponsoredLabel:UILabel!
    var featuredLabel2:UILabel!
    var sponsoredLabel2:UILabel!

    //Variables for Store
    var ownerImage:UIImageView!
    var ownerImage2:UIImageView!
    var likesLabel: UILabel!
    var likesLabel2: UILabel!
    var followersLabel: UILabel!
    var followersLabel2: UILabel!
    
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
            cellView = createView( CGRect(x: 0, y: 0,width: (UIScreen.main.bounds.width/2) , height: 250), borderColor: borderColorMedium, shadow: false)
        }else{
            cellView = createView( CGRect(x: 0, y: 0,width: (UIScreen.main.bounds.width) , height: 250), borderColor: borderColorMedium, shadow: false)

        }
        
        
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
        
        dateView = UIView( frame: CGRect(x: 0, y: 180,width: 70 , height: 70))
        dateView.backgroundColor = navColor
        dateView.isHidden = true
        self.addSubview(dateView)
        
        titleView = UIView( frame: CGRect(x: 70, y: 180,width: (cellView.bounds).width - 70 , height: 70))
        titleView.backgroundColor = UIColor.white
        self.addSubview(titleView)
        
        
        titleLabel = createLabel(CGRect(x: 10, y: 5, width: 100, height: 30), text: "", alignment: .left, textColor: textColorDark)
        titleLabel.font = UIFont(name: fontName, size: FONTSIZELarge)
        titleView.addSubview(titleLabel)

        
        statsLabel = createLabel(CGRect(x:10, y: 5, width: 100, height: 30), text: "", alignment: .left, textColor: textColorDark)
        statsLabel.font = UIFont(name: fontName, size: FONTSIZENormal)
        statsLabel.isHidden = true
        titleView.addSubview(statsLabel)

        locLabel = createLabel(CGRect(x: 10, y: 30, width: 100, height: 30), text: "", alignment: .left, textColor: textColorMedium)
        locLabel.font = UIFont(name: fontName, size: 12)
        titleView.addSubview(locLabel)
        dateLabel = createLabel(CGRect(x: 10, y: 50, width: 100, height: 30), text: "", alignment: .left, textColor: textColorMedium)

        dateLabel.font = UIFont(name: fontName, size: 12)
        titleView.addSubview(dateLabel)
        
        
        //WORK FOR MLT PLUGIN
        
        listingPriceTagLabel = createLabel(CGRect(x: 10, y: 110, width: 10, height: 20), text: "", alignment: .left, textColor: textColorMedium)
        listingPriceTagLabel.isHidden = true
        cellView.addSubview(listingPriceTagLabel)
        
        listingDetailsLabel = createLabel(CGRect(x: 10, y: 70, width: 100, height: 30), text: "", alignment: .left, textColor: textColorMedium)
        listingDetailsLabel.font = UIFont(name: "FontAwesome", size: 12)
        listingDetailsLabel.isHidden = true
        titleView.addSubview(listingDetailsLabel)
        
        dateLabel1 = createLabel(CGRect(x: 20, y: 10, width: 50, height: 60), text: "", alignment: .center, textColor: textColorMedium)
        dateLabel1.font = UIFont(name: fontName, size: 16)
        dateView.addSubview(dateLabel1)

        lineView = UIView(frame: CGRect(x: 0,y: 250,width: (UIScreen.main.bounds).width,height: 5))
        lineView.backgroundColor = tableViewBgColor
        self.addSubview(lineView)
        lineView.isHidden = true
        
        contentImage = ContentImageViewWithGradient(frame: CGRect(x: 0, y: 0, width: cellView.bounds.width, height: cellView.bounds.height - cellView.bounds.height/4))

        contentImage.layer.masksToBounds = true
        contentImage.contentMode = UIView.ContentMode.scaleAspectFill
        contentImage.backgroundColor = placeholderColor
        contentImage.layer.shadowColor = shadowColor.cgColor
        contentImage.layer.shadowOpacity = shadowOpacity
        contentImage.layer.shadowRadius = shadowRadius
        contentImage.layer.shadowOffset = shadowOffset
        cellView.addSubview(contentImage)
        
        featuredLabel = createLabel(CGRect(x: 0, y: 0, width: 70, height: 20), text: "Featured", alignment: .center, textColor: textColorLight)
        featuredLabel.font = UIFont(name: fontName, size: FONTSIZEMedium)
        featuredLabel.backgroundColor = UIColor.init(red: 0, green: 176/255, blue: 182/255, alpha: 1)
        contentImage.addSubview(featuredLabel)
        featuredLabel.isHidden = true

        
        sponsoredLabel = createLabel(CGRect(x: contentImage.bounds.width - 65, y: 0, width: 70, height: 20), text: "Sponsored", alignment: .center, textColor: textColorLight)
        sponsoredLabel.font = UIFont(name: fontName, size: FONTSIZEMedium)
        sponsoredLabel.backgroundColor = UIColor.red
        contentImage.addSubview(sponsoredLabel)
        sponsoredLabel.isHidden = true

        
        
        closeIconView = createLabel(CGRect(x: contentImage.bounds.width/2 - contentImage.bounds.width/6 , y: contentImage.bounds.height/2 - contentImage.bounds.height/6, width: contentImage.bounds.width/3, height: contentImage.bounds.height/3), text: " ", alignment: .center, textColor: textColorLight)
        closeIconView.font = UIFont(name: "FontAwesome", size: FONTSIZELarge)
        closeIconView.isHidden = true
        closeIconView.layer.shadowColor = shadowColor.cgColor
        closeIconView.layer.shadowOpacity = shadowOpacity
        closeIconView.layer.shadowRadius = shadowRadius
        closeIconView.layer.shadowOffset = shadowOffset
        contentImage.addSubview(closeIconView)
        
        likesLabel = createLabel(CGRect(x: contentImage.bounds.width - 20,y: contentImage.bounds.height - 45,width: 20, height:20), text: "", alignment: .right, textColor: textColorLight)
        likesLabel.font = UIFont(name: fontName, size: FONTSIZEMedium)
        likesLabel.backgroundColor = UIColor.clear
        likesLabel.isHidden = true
        contentImage.addSubview(likesLabel)

        followersLabel = createLabel(CGRect(x: contentImage.bounds.width - 20, y: contentImage.bounds.height - 20,width: 20,height: 20), text: "", alignment: .right, textColor: textColorLight)
        followersLabel.font = UIFont(name: fontName, size: FONTSIZEMedium)
        followersLabel.backgroundColor = UIColor.clear
        followersLabel.isHidden = true
        contentImage.addSubview(followersLabel)
        
        
        menuButton = createButton(CGRect(x: contentImage.bounds.width - 40, y: 5,width: 30,height: 40), title: "\(optionIcon)", border: false,bgColor: false,textColor: textColorLight)

        menuButton.titleLabel?.font =  UIFont(name: "FontAwesome", size:30.0)
        menuButton.layer.shadowColor = shadowColor.cgColor
        menuButton.layer.shadowOpacity = shadowOpacity
        menuButton.layer.shadowRadius = shadowRadius
        menuButton.layer.shadowOffset = shadowOffset

        cellView.addSubview(menuButton)
        menuButton.isHidden = true
        
        // Set
        contentName = createLabel(CGRect(x: 10, y: 110, width: (contentImage.bounds.width-20), height: 100), text: "", alignment: .left, textColor: textColorLight)

        contentName.numberOfLines = 0
        contentName.font = UIFont(name: fontBold, size: FONTSIZEExtraLarge)
        contentName.layer.shadowColor = shadowColor.cgColor
        contentName.layer.shadowOpacity = shadowOpacity
        contentName.layer.shadowRadius = shadowRadius
        contentName.layer.shadowOffset = shadowOffset
        cellView.addSubview(contentName)
        
        
        totalMembers = createLabel(CGRect(x: 10, y: 150, width: 100, height: 40), text: "", alignment: .left, textColor: textColorDark)
        totalMembers.font = UIFont(name: fontName, size: 12)
        totalMembers.isHidden = true
        cellView.addSubview(totalMembers)
        
        createdBy = TTTAttributedLabel(frame: CGRect(x: 120, y: 150, width: contentImage.bounds.width-120, height: 40))
        createdBy.textAlignment = .right
        createdBy.textColor = textColorLight
        createdBy.font = UIFont(name: fontName, size: FONTSIZESmall)
        createdBy.isHidden = true
        cellView.addSubview(createdBy)
        
        eventTime = createLabel(CGRect(x: 50, y: 152, width: contentImage.bounds.width-150, height: 20), text: "", alignment: .center, textColor: textColorDark)
        eventTime.font = UIFont(name: fontBold, size: FONTSIZEMedium)
        eventTime.textColor = UIColor.red
        eventTime.isHidden = true
        cellView.addSubview(eventTime)
        
        menu = createButton(CGRect(x: contentImage.bounds.width-30, y: 210, width: 30, height: 40), title: "\u{f141}", border: false,bgColor: false,textColor: textColorLight)
        menu.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZELarge)
        cellView.addSubview(menu)

        menu.isHidden = true

        contentSelection = createButton(cellView.frame, title: "", border: false,bgColor: false, textColor: textColorLight)
        contentSelection.frame.size.height = (cellView.frame.size.height-40)
        self.addSubview(contentSelection)
        
        //FOR OWNER IMAGE IN STORE PLUGIN
        if(UIDevice.current.userInterfaceIdiom == .pad){
            ownerImage = createImageView(CGRect(x: 30,y:contentImage.bounds.height,width: 120,height: 120 ), border: true)
        }else{
            ownerImage = createImageView(CGRect(x: 10,y:contentImage.bounds.height,width: 100,height: 100), border: true)
        }
        
        
        ownerImage.layer.borderColor = UIColor.white.cgColor
        ownerImage.layer.borderWidth = 2.5
        ownerImage.layer.cornerRadius = contentImage.frame.size.width / 2
        ownerImage.backgroundColor = placeholderColor
        ownerImage.contentMode = UIView.ContentMode.scaleAspectFill
        ownerImage.layer.masksToBounds = true
        ownerImage.image = UIImage(named: "user_profile_image.png")
        ownerImage.tag = 321
        ownerImage.isUserInteractionEnabled = true
        ownerImage.isHidden = true
        titleView.addSubview(ownerImage)
        
        
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

            statsLabel2 = createLabel(CGRect(x: 10,y: 5,width: 100,height: 30), text: "", alignment: .left, textColor: textColorDark)
            statsLabel2.font = UIFont(name: fontName, size: FONTSIZENormal)
            statsLabel2.isHidden = true
            titleView2.addSubview(statsLabel2)
            
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

            lineView2 = UIView(frame: CGRect(x: (UIScreen.main.bounds).width/2, y: 250, width: (UIScreen.main.bounds).width/2, height: 5))
            lineView2.backgroundColor = tableViewBgColor
            self.addSubview(lineView2)
            lineView2.isHidden = true


            contentImage2 = ContentImageViewWithGradient(frame: CGRect(x: 0, y: 0, width: cellView2.bounds.width, height: cellView2.bounds.width - cellView2.bounds.width/4))

            contentImage2.layer.masksToBounds = true
            contentImage2.backgroundColor = navColor
            contentImage2.layer.shadowColor = shadowColor.cgColor
            contentImage2.layer.shadowOffset = CGSize(width: 0,height: 5);
            contentImage2.layer.shadowOpacity = 0.5;
            contentImage2.contentMode = UIView.ContentMode.scaleAspectFill
            cellView2.addSubview(contentImage2)
            

            featuredLabel2 = createLabel(CGRect(x: 0, y: 0, width: 75, height: 20), text: "Featured", alignment: .center, textColor: textColorLight)
            featuredLabel2.font = UIFont(name: fontName, size: FONTSIZEMedium)
            featuredLabel2.backgroundColor = UIColor.init(red: 0, green: 176/255, blue: 182/255, alpha: 1)
            contentImage2.addSubview(featuredLabel2)
            featuredLabel2.isHidden = true

            
            sponsoredLabel2 = createLabel(CGRect(x: contentImage2.bounds.width - 71, y: 0, width: 70, height: 20), text: "Sponsored", alignment: .center, textColor: textColorLight)
            sponsoredLabel2.font = UIFont(name: fontName, size: FONTSIZEMedium)
            sponsoredLabel2.backgroundColor = UIColor.red
            contentImage2.addSubview(sponsoredLabel2)

            sponsoredLabel2.isHidden = true



            closeIconView2 = createLabel(CGRect(x: contentImage2.bounds.width/2 - contentImage2.bounds.width/6 , y: contentImage.bounds.height/2 - contentImage2.bounds.height/6, width: contentImage2.bounds.width/3, height: contentImage2.bounds.height/3), text: " ", alignment: .center, textColor: textColorLight)
            closeIconView2.font = UIFont(name: "FontAwesome", size: FONTSIZELarge)
            closeIconView2.isHidden = true
            closeIconView2.layer.shadowColor = shadowColor.cgColor
            closeIconView2.layer.shadowOpacity = shadowOpacity
            closeIconView2.layer.shadowRadius = shadowRadius
            closeIconView2.layer.shadowOffset = shadowOffset
            cellView2.addSubview(closeIconView2)
            
            likesLabel2 = createLabel(CGRect(x: contentImage2.bounds.width - 20,y: contentImage2.bounds.height - 45,width: 20,height: 20), text: "", alignment: .right, textColor: textColorLight)
            likesLabel2.font = UIFont(name: fontName, size: FONTSIZEMedium)
            likesLabel2.backgroundColor = UIColor.clear
            likesLabel2.isHidden = true
            contentImage2.addSubview(likesLabel2)
            
            followersLabel2 = createLabel(CGRect(x: contentImage2.bounds.width - 20,y: contentImage2.bounds.height - 20,width: 20, height: 20), text: "", alignment: .right, textColor: textColorLight)
            followersLabel2.font = UIFont(name: fontName, size: FONTSIZEMedium)
            followersLabel2.backgroundColor = UIColor.clear
            followersLabel2.isHidden = true
            contentImage2.addSubview(followersLabel2)

            
            menuButton2 = createButton(CGRect(x: titleView2.bounds.width-40, y: 0, width: 30, height: 40), title: "\u{f141}", border: false,bgColor: false,textColor: textColorLight)
            menuButton2.titleLabel?.font =  UIFont(name: "FontAwesome", size:30.0)
            menuButton2.layer.shadowColor = shadowColor.cgColor
            menuButton2.layer.shadowOpacity = shadowOpacity
            menuButton2.layer.shadowRadius = shadowRadius
            menuButton2.layer.shadowOffset = shadowOffset
            cellView2.addSubview(menuButton2)
            menuButton2.isHidden = true

            contentName2 = createLabel(CGRect(x: 10, y: 110, width: (contentImage.bounds.width-20), height: 100), text: "", alignment: .left, textColor: textColorLight)

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
            
            createdBy2 = TTTAttributedLabel(frame: CGRect(x: 120, y: 150, width: contentImage.bounds.width-120, height: 40))
            createdBy2.textAlignment = .right
            createdBy2.textColor = textColorLight
            //            createdBy2.layer.shadowColor = shadowColor.CGColor
            //            createdBy2.layer.shadowOpacity = shadowOpacity
            //            createdBy2.layer.shadowRadius = shadowRadius
            //            createdBy2.layer.shadowOffset = shadowOffset
            createdBy2.font = UIFont(name: fontName, size: FONTSIZESmall)
            cellView2.addSubview(createdBy2)
            
            eventTime2 = createLabel(CGRect(x: 50, y: 152, width: contentImage.bounds.width-150, height: 20), text: "", alignment: .center, textColor: textColorDark)
            eventTime2.font = UIFont(name: fontBold, size: FONTSIZEMedium)
            eventTime2.textColor = UIColor.red
            cellView2.addSubview(eventTime2)
            
            menu2 = createButton(CGRect(x: contentImage.bounds.width-30, y: 210, width: 30, height: 40), title: "\u{f141}", border: false,bgColor: false, textColor: textColorLight)
            menu2.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZELarge)
            cellView2.addSubview(menu2)
            menu2.isHidden = true
            contentSelection2 = createButton(cellView2.frame, title: "", border: false,bgColor: false, textColor: textColorLight)
            contentSelection2.frame.size.height = (cellView2.frame.size.height-40)
            self.addSubview(contentSelection2)
            
            
            //FOR OWNER IMAGE IN STORE PLUGIN
            ownerImage2 = createImageView(CGRect(x: 30,y: contentImage2.bounds.height,width: 120,height: 120), border: true)
            ownerImage2.layer.borderColor = UIColor.white.cgColor
            ownerImage2.layer.borderWidth = 2.5
            ownerImage2.layer.cornerRadius = contentImage2.frame.size.width / 2
            ownerImage2.backgroundColor = placeholderColor
            ownerImage2.contentMode = UIView.ContentMode.scaleAspectFill
            ownerImage2.layer.masksToBounds = true
            ownerImage2.image = UIImage(named: "user_profile_image.png")
            ownerImage2.tag = 321
            ownerImage2.isUserInteractionEnabled = true
            ownerImage2.isHidden = true
            titleView2.addSubview(ownerImage2)
            
        }
    }
    func visibleVideoHeight() -> CGFloat {
        
        //viewVideo.isHidden = false
        cellView.isHidden = false
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
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
