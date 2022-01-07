//
//  PageTableViewCell.swift
//  seiosnativeapp
//
//  Created by bigstep_macbook_air on 4/29/19.
//  Copyright © 2019 bigstep. All rights reserved.
//

import UIKit
class PageTableViewCell: UITableViewCell ,AutoPlayVideoLayerContainer{
    
    var pageProfilePic = UIImageView()
    var pageName = UILabel()
    var locationLabel = UILabel()
    var ratingLabel = UILabel()
    var callButton = UIButton()
    var sponsoredLabel = UILabel()
    var featuredLabel = UILabel()
    var menuButton = UIButton()
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
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    func setupCell() {
        addSubview(pageProfilePic)
        pageProfilePic.image = UIImage(named: "Welcome_SlideShow1_640x1136.png")
       
        
        addSubview(pageName)
        pageName.text = "Design Basis For Daily Necessities"
        pageName.font = UIFont.systemFont(ofSize: 18)
        
        addSubview(ratingLabel)
       
        addSubview(locationLabel)
        addSubview(menuButton)
        locationLabel.text = "Gurgaon, Haryana"
        locationLabel.textColor = .lightGray
        locationLabel.font = UIFont.systemFont(ofSize: 14)
        pageProfilePic.frame = CGRect(x: 10, y: 30, width: 74, height: 74)
     
        pageProfilePic.layer.cornerRadius = 37
        pageProfilePic.layer.borderWidth = 1
        pageProfilePic.layer.borderColor = UIColor.lightGray.cgColor
        pageProfilePic.clipsToBounds = true
        
        pageName.frame = CGRect(x: getBottomEdgeY(inputView: pageProfilePic) + 6, y: pageProfilePic.frame.origin.y + 10, width: UIScreen.main.bounds.size.width - (getBottomEdgeY(inputView: pageProfilePic) + 6 + 12 + 45), height: 25)
        
        locationLabel.frame = CGRect(x: pageName.frame.origin.x, y: getBottomEdgeY(inputView: pageName)+3, width: pageName.frame.size.width, height: 15)
        
        
        ratingLabel.frame = CGRect(x: pageName.frame.origin.x, y: getBottomEdgeY(inputView: locationLabel) + 3, width: pageName.frame.size.width, height: 15)
        menuButton.frame = CGRect(x: UIScreen.main.bounds.size.width - 40 - 12, y: pageName.frame.origin.y, width: 40, height: 40)
        menuButton.titleLabel?.font = UIFont(name: "FontAwesome", size:30.0)
        menuButton.setTitle("\u{f142}", for: .normal)
        menuButton.setTitleColor(textColorDark, for: .normal)
        menuButton.isHidden = true
        
        addSubview(callButton)
        callButton.frame = CGRect(x:UIScreen.main.bounds.size.width - 60 , y: pageName.frame.origin.y - 4, width: 50, height: 50)
        let fontAttribute = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: textColorDark]
        let attributedString = "\u{f095}"
        let myAttribute = [ NSAttributedString.Key.foregroundColor: textColorDark, NSAttributedString.Key.font: UIFont(name: "FontAwesome", size:30.0)]
        let myAttrString = NSAttributedString(string: attributedString, attributes: myAttribute)
        let nonAttributedString = NSAttributedString(string:NSLocalizedString("\nCall", comment: "") , attributes: fontAttribute )
        let finalString = NSMutableAttributedString()
        finalString.append(myAttrString)
        finalString.append(nonAttributedString)
        callButton.titleLabel?.numberOfLines = 2
        callButton.titleLabel?.textAlignment = .center
        callButton.setAttributedTitle(finalString, for: .normal)
        callButton.isHidden = true
        
        addSubview(featuredLabel)
        featuredLabel.frame = CGRect(x: UIScreen.main.bounds.size.width - 140, y: 5, width: 60, height: 20)
        featuredLabel.text = "Featured"
        featuredLabel.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 128/255, alpha: 1.0)
        featuredLabel.textColor = textColorPrime
        featuredLabel.textAlignment = .center
        featuredLabel.font = UIFont.boldSystemFont(ofSize: 12)
        featuredLabel.isHidden = true
        
        addSubview(sponsoredLabel)
        sponsoredLabel.frame = CGRect(x: getRightEdgeX(inputView: featuredLabel), y: 5, width: 70, height: 20)
        sponsoredLabel.text = "Sponsored"
        sponsoredLabel.backgroundColor = UIColor(red: 0/255, green: 128/255, blue: 128/255, alpha: 1.0)
        sponsoredLabel.textColor = textColorPrime
        sponsoredLabel.textAlignment = .center
        sponsoredLabel.font = UIFont.boldSystemFont(ofSize: 12)
        sponsoredLabel.isHidden = true
        
        
 
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set (newFrame) {
            var frame =  newFrame
            frame.origin.y += 4
            frame.size.height -= 2 * 5
            frame.size.width -= 2 * 6
            frame.origin.x += 6
            super.frame = frame
        }
    }
}
