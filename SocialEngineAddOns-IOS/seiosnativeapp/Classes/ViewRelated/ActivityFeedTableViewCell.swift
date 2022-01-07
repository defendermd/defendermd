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
//  ActivityFeedTableViewCell.swift
//  seiosnativeapp
//

import UIKit

// Custom TableView Cell for Advance Activity Feed
class ActivityFeedTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    var cellView:UIView!
    var cellMenu: UIView!
    var subject_photo:UIImageView!
    var subject_photo1:UIButton!
    var title:TTTAttributedLabel!
    var createdAt: UILabel!
    var likeCommentInfo:UIButton!
    var sideMenu: UIButton!
    var feedInfo:TTTAttributedLabel!
    var descriptionView : UIView!
    
    // Initialize Variable for Custom Table Cell
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
        cellView = createView(CGRect(x: 5, y: 10,width: UIScreen.main.bounds.width-10 ,height: 110), borderColor: borderColorLight, shadow: true)
        
        cellView.layer.shadowColor = shadowColor.cgColor
        cellView.layer.shadowOpacity = shadowOpacity
        cellView.layer.shadowRadius = shadowRadius
        cellView.layer.shadowOffset = shadowOffset
        
        self.addSubview(cellView)        
        cellMenu = createView(CGRect(x: 0, y: cellView.bounds.height-30 ,width: cellView.bounds.width ,height: 30), borderColor: borderColorMedium, shadow: false)
        
        cellMenu.backgroundColor = borderColorLight
        cellView.addSubview(cellMenu)
        
        subject_photo = createImageView(CGRect(x: 5, y: 5, width: 40, height: 40), border: true)
        subject_photo1 = createButton(CGRect( x: 5,y: 5, width: 40, height: 40), title: "", border: false, bgColor: false, textColor: textColorLight)
        
        
        subject_photo.image = UIImage(named: "user_profile_image.png")
        cellView.addSubview(subject_photo1)
        subject_photo1.addSubview(subject_photo)
        
        title = TTTAttributedLabel(frame:CGRect(x: subject_photo.bounds.width + 10 , y: 5, width: cellView.bounds.width-(subject_photo.bounds.width + 55), height: 100))
        title.numberOfLines = 0
        title.linkAttributes = [kCTForegroundColorAttributeName:textColorDark]
        title.textColor = textColorDark
        title.font = UIFont(name: fontName, size: FONTSIZENormal)
        cellView.addSubview(title)
        
        
        createdAt = createLabel(CGRect(x: subject_photo.bounds.width + 15, y: 35, width: cellView.bounds.width-(subject_photo.bounds.width + 60), height: 20), text: "", alignment: .left, textColor: textColorMedium)
        createdAt.font = UIFont(name: fontName, size: FONTSIZESmall)
        cellView.addSubview(createdAt)
        
        
        sideMenu = createButton(CGRect( x: cellView.bounds.width - 20, y: 5, width: 20, height: 20), title: "\u{f107}", border: false, bgColor: false, textColor: textColorMedium)
        sideMenu.isHidden = true
        sideMenu.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZEExtraLarge)
        cellView.addSubview(sideMenu)
        
        
        likeCommentInfo = createButton(CGRect(x: 5,y: 0 ,width: 200 , height: 30), title: "", border: false,bgColor: false, textColor: textColorMedium)
        likeCommentInfo.titleLabel?.font = UIFont(name: fontName , size: FONTSIZESmall)
        likeCommentInfo.titleLabel?.textColor = textColorMedium
        cellView.addSubview(likeCommentInfo)
        
        
        feedInfo = TTTAttributedLabel(frame:CGRect(x: subject_photo.bounds.width + 10 , y: 5, width: cellView.bounds.width-(subject_photo.bounds.width + 55), height: 100))
        feedInfo.numberOfLines = 0
        feedInfo.linkAttributes = [kCTForegroundColorAttributeName:textColorDark]
        feedInfo.textColor = textColorDark
        feedInfo.font = UIFont(name: fontName, size: FONTSIZEMedium)
        feedInfo.isHidden = true
        cellView.addSubview(feedInfo)
        
        descriptionView = createView(CGRect(x: 5, y: 10,width: UIScreen.main.bounds.width-10 ,height: 110), borderColor: borderColorLight, shadow: true)
        
        descriptionView.layer.shadowColor = shadowColor.cgColor
        descriptionView.layer.shadowOpacity = shadowOpacity
        descriptionView.layer.shadowRadius = shadowRadius
        descriptionView.layer.shadowOffset = shadowOffset
        
        cellView.addSubview(descriptionView)
        descriptionView.isHidden = true
        
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
