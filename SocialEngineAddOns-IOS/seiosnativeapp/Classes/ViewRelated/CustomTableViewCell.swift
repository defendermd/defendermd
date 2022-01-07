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
//  CustomTableViewCell.swift
//  seiosnativeapp
//


import UIKit

// This class is used by BlogViewController, TaggingViewController & MembersViewController
class CustomTableViewCell: UITableViewCell ,AutoPlayVideoLayerContainer{
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    // Define Variable for Custom Table Cell
    var imgUser:UIImageView!
    var labTitle : UILabel!
    var imgSearch:UIImageView!
    var labMessage :TTTAttributedLabel!
    var endDateLabel :TTTAttributedLabel!
    var postCount :UILabel!
    var imageview:UILabel!
    var lineView: UIView!
    var optionMenu :UIButton!
    var optionRemoveMenu :UIButton!
    var btnemoji :UIButton!
    
    //For Browse & Advanced Search Member Page
    var memberAge: UILabel!
    var memberLocation: UILabel!
    var memberMutualFriends: UILabel!
    var memberOnlineLabel: UILabel!
    
    
    var featuredLabel:UILabel!
    var sponsoredLabel:UILabel!
    var addtolist :UIButton!
    var cross :UIButton!
    var tickCheckButton:UIButton!
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
    // Initialize Variable for Custom Table Cell
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = UITableViewCell.SelectionStyle.blue
        
        // Icon Size
        if  (UIDevice.current.userInterfaceIdiom == .phone){
            imgUser = createImageView(CGRect(x: 5, y: 5, width: 50, height: 50), border: false)
        }else{
            imgUser = createImageView(CGRect(x: 5, y: 5, width: 60, height: 60), border: false)
        }
        imgUser.image = UIImage(named: "user_profile_image.png")
        imgUser.layer.masksToBounds = true
        imgUser.tag = 502
        self.addSubview(imgUser)
        
        imageview = createLabel(CGRect(x: 25, y: 25, width: 20 , height: 20), text: " ", alignment: .left, textColor: textColorLight)
        imageview.font = UIFont(name: "FontAwesome", size: FONTSIZELarge)
        imageview.isHidden = true
        imageview.tag = 502
        imgUser.addSubview(imageview)
        
        if  (UIDevice.current.userInterfaceIdiom == .phone){
            btnemoji = createButton(CGRect(x: imgUser.frame.size.width + imgUser.frame.origin.x - 5  , y: imgUser.frame.size.height + imgUser.frame.origin.y - 10 , width: 20 , height: 20), title: "", border: false, bgColor: false, textColor: textColorclear)
        }else{
            btnemoji = createButton(CGRect(x: imgUser.frame.size.width + imgUser.frame.origin.x - 5  , y: imgUser.frame.size.height + imgUser.frame.origin.y - 10 , width: 20 , height: 20), title: "", border: false, bgColor: false, textColor: textColorclear)
        }
        btnemoji.isHidden = true
        btnemoji.layer.cornerRadius = 20/2
        btnemoji.layer.borderWidth = 1
        btnemoji.layer.borderColor = UIColor.clear.cgColor
        self.addSubview(btnemoji)
        
       tickCheckButton = createButton(CGRect(x: (UIScreen.main.bounds.width - 30)  , y:  13 , width: 20 , height: 20), title: "", border: false, bgColor: false, textColor: textColorDark)
        tickCheckButton.setBackgroundImage(UIImage(named: "tickicon")?.maskWithColor(color: buttonColor), for: .normal)
        tickCheckButton.isHidden = true
        self.addSubview(tickCheckButton)
        
        
        memberOnlineLabel = createLabel(CGRect(x: imgUser.bounds.width - 15, y: imgUser.bounds.height - 15, width: 10, height: 10), text: "", alignment: .left, textColor:UIColor.green )
        memberOnlineLabel.font = UIFont(name: "FontAwesome", size:FONTSIZESmall)
        memberOnlineLabel.text = "\u{f007}"
        memberOnlineLabel.textColor = UIColor.gray
        memberOnlineLabel.isHidden = true
        imgUser.addSubview(memberOnlineLabel)

        imgSearch = createImageView(CGRect(x: 14, y: 15, width: 16, height: 16), border: false)
        imgSearch.image = UIImage(named: "searchIcon.png")
        imgSearch.clipsToBounds = true
        imgSearch.layer.masksToBounds = true
        self.addSubview(imgSearch)
        imgSearch.isHidden = true
        
        // Title
        labTitle = createLabel(CGRect( x: imgUser.bounds.width + 10, y: 10,width: (UIScreen.main.bounds.width - (imgUser.bounds.width + 15)) , height: 100), text: " ", alignment: .left, textColor: textColorDark)
        labTitle.numberOfLines = 0
        labTitle.font = UIFont(name: fontName, size: FONTSIZELarge)
        labTitle.tag = 500
//        labTitle.backgroundColor = UIColor.yellow // dummy
        self.addSubview(labTitle)
        
        memberAge = createLabel(CGRect(x: imgUser.bounds.width + 10, y: labTitle.bounds.origin.y + labTitle.bounds.height + 5, width: (UIScreen.main.bounds.width - 75), height: 20), text: "", alignment: .left, textColor:textColorMedium )
        memberAge.lineBreakMode = NSLineBreakMode.byWordWrapping
        memberAge.font = UIFont(name: "FontAwesome", size:FONTSIZESmall)
        memberAge.isHidden = true
//        memberAge.backgroundColor = UIColor.orange // dummy
        self.addSubview(memberAge)
        
        memberLocation = createLabel(CGRect(x: imgUser.bounds.width + 10, y: memberAge.bounds.origin.y + memberAge.bounds.height + 5, width: (UIScreen.main.bounds.width - 75), height: 20), text: "", alignment: .left, textColor:textColorMedium )
        memberLocation.lineBreakMode = NSLineBreakMode.byWordWrapping
        memberLocation.font = UIFont(name: "FontAwesome", size:FONTSIZESmall)
        memberLocation.isHidden = true
//        memberLocation.backgroundColor = UIColor.blue // dummy
        self.addSubview(memberLocation)
        
        memberMutualFriends = createLabel(CGRect(x: imgUser.bounds.width + 10, y: memberLocation.bounds.origin.y + memberLocation.bounds.height + 5, width: (UIScreen.main.bounds.width - 75), height: 20), text: "", alignment: .left, textColor:textColorMedium )
        memberMutualFriends.lineBreakMode = NSLineBreakMode.byWordWrapping
        memberMutualFriends.font = UIFont(name: "FontAwesome", size:FONTSIZESmall)
//        memberMutualFriends.backgroundColor = UIColor.green // dummy
        self.addSubview(memberMutualFriends)
        
        // Description
        labMessage = TTTAttributedLabel(frame: CGRect(x: imgUser.bounds.width + 10, y: 10,width: (UIScreen.main.bounds.width - (imgUser.bounds.width + 15)) , height: 100))
        labMessage.numberOfLines = 0
        labMessage.linkAttributes = [kCTForegroundColorAttributeName:textColorMedium]
        labMessage.textColor = textColorMedium
        labMessage.font = UIFont(name: fontName, size: FONTSIZESmall)
        labMessage.tag = 501
//        labMessage.backgroundColor = UIColor.green
//        labMessage.backgroundColor = UIColor.purple // dummy
        self.addSubview(labMessage)
        
        addtolist = createButton(CGRect(x: 10, y: getBottomEdgeY(inputView: memberMutualFriends)+10, width: 100, height: 30), title: "Add To List", border: false, bgColor: false, textColor: textColorPrime)
        addtolist.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZESmall)
        addtolist.backgroundColor = buttonColor
        addtolist.isHidden = true
        labMessage.addSubview(addtolist)
        
        cross = createButton(CGRect(x: UIScreen.main.bounds.width-100, y: 10, width: 20, height: 20), title: crossIcon, border: false, bgColor: false, textColor: textColorDark)
        cross.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZESmall)
//        cross.backgroundColor = navColor
        cross.isHidden = true
        self.addSubview(cross)
        
        // Description
                endDateLabel = TTTAttributedLabel(frame:CGRect(x:imgUser.bounds.width + 10, y:labMessage.bounds.height,width:UIScreen.main.bounds.width - (imgUser.bounds.width + 15) , height:100))
        endDateLabel.numberOfLines = 0
        endDateLabel.linkAttributes = [kCTForegroundColorAttributeName:textColorMedium]
        endDateLabel.textColor = textColorMedium
        endDateLabel.font = UIFont(name: fontName, size: FONTSIZESmall)
//        endDateLabel.backgroundColor = UIColor.green // dummy
        self.addSubview(endDateLabel)
        
        // PostCount
        postCount = createLabel(CGRect(x: (UIScreen.main.bounds.width - 75), y: 10, width: 75 , height: 15), text: " ", alignment: .left, textColor: textColorDark)
        postCount.font = UIFont(name: fontName, size: FONTSIZESmall)
        self.addSubview(postCount)
        
        optionMenu = createButton(CGRect(x: (UIScreen.main.bounds.width - 75), y: 10, width: 75 , height: 15), title: "\(optionIcon)", border: false, bgColor: false, textColor: textColorDark)
        
        optionMenu.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZEExtraLarge)
        optionMenu.isHidden = true
        self.addSubview(optionMenu)
        
        optionRemoveMenu = createButton(CGRect(x: (UIScreen.main.bounds.width - 75), y: 20, width: 75 , height: 20), title: "\(removeIcon)", border: false, bgColor: false, textColor: textColorDark)
        
        optionRemoveMenu.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZEExtraLarge)
        optionRemoveMenu.isHidden = true
        self.addSubview(optionRemoveMenu)

        
        
        lineView = UIView(frame: CGRect(x: 0, y: self.bounds.height,width: (UIScreen.main.bounds).width, height: 2))
        lineView.backgroundColor = tableViewBgColor
        self.addSubview(lineView)
        lineView.isHidden = true
        
        
        sponsoredLabel = createLabel(CGRect(x: (UIScreen.main.bounds).width - 40, y: lineView.frame.origin.y-20, width: 40, height: 20), text: "Sponsored", alignment: .center, textColor: textColorLight)
        sponsoredLabel.font = UIFont(name: fontName, size: FONTSIZESmall)
        sponsoredLabel.backgroundColor = UIColor.red
        self.addSubview(sponsoredLabel)
        sponsoredLabel.isHidden = true
        
        featuredLabel = createLabel(CGRect(x: (UIScreen.main.bounds).width - 90, y: lineView.frame.origin.y-20, width: 40, height: 20), text: "Featured", alignment: .center, textColor: textColorLight)
        featuredLabel.font = UIFont(name: fontName, size: FONTSIZESmall)
        featuredLabel.backgroundColor = UIColor.init(red: 0, green: 176/255, blue: 182/255, alpha: 1)
        self.addSubview(featuredLabel)
        featuredLabel.isHidden = true
        
        
    }
    
    override func prepareForReuse() {
         super.prepareForReuse()
         memberAge.text = ""
         memberLocation.text = ""
        memberMutualFriends.text = ""
        tickCheckButton.setBackgroundImage(UIImage(named : ""), for: .normal)
        
    }
    func visibleVideoHeight() -> CGFloat {
        
        
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



