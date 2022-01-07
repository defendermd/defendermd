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
//  NotificationTableViewCell.swift
//  seiosnativeapp
//

import UIKit

// This class is used by BlogViewController, TaggingViewController & MembersViewController
class NotificationTableViewCell: UITableViewCell {
    
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
    var labMessage :TTTAttributedLabel!
    var labIcon :UILabel!
    var labPostedDate :TTTAttributedLabel!
    var postCount :UILabel!
    
    var notificationIcon :UILabel!
    
    var acceptButton : UIButton!
    var notattendButton : UIButton!
    var ignoreButton : UIButton!
    
    var postedOn :TTTAttributedLabel!
    var optionMenu : UIButton!
    
    // Initialize Variable for Custom Table Cell
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = UITableViewCell.SelectionStyle.blue
        
        // Icon Size
        if  (UIDevice.current.userInterfaceIdiom == .phone){
            imgUser = createImageView(CGRect(x: 10, y: 5, width: 80, height: 80), border: true)
        }else{
            imgUser = createImageView(CGRect(x: 10, y: 5, width: 100, height: 100), border: true)
        }
        imgUser.image = UIImage(named: "user_profile_image.png")
        
        imgUser.layer.masksToBounds = true
        imgUser.layer.cornerRadius = imgUser.frame.size.width / 2
        
        //        imgUser.layer.cornerRadius = imgUser.frame.size.width / 2;
        //        imgUser.clipsToBounds = true
        //        imgUser.layer.borderWidth = 2.5
        //        imgUser.layer.masksToBounds = true
        //        imgUser.layer.cornerRadius = 5.0
        self.addSubview(imgUser)
        
        notificationIcon = createLabel(CGRect(x: 5, y: 5, width: 15, height: 15), text: "\u{f111}", alignment: .left, textColor: textColorDark)
        notificationIcon.font = UIFont(name: "FontAwesome", size:FONTSIZELarge)
        notificationIcon.textColor = navColor
        notificationIcon.isHidden = true
        self.addSubview(notificationIcon)
        //
        // Title
        labTitle = createLabel(CGRect( x: imgUser.bounds.width + 10, y: 10,width: (UIScreen.main.bounds.width - (imgUser.bounds.width + 15)) , height: 100), text: " ", alignment: .left, textColor: textColorDark)
        labTitle.numberOfLines = 0
        labTitle.font = UIFont(name: fontBold, size: FONTSIZELarge)
        self.addSubview(labTitle)
        
        // Description
        labMessage = TTTAttributedLabel(frame: CGRect(x: imgUser.bounds.width + 20, y: 10,width: (UIScreen.main.bounds.width - (imgUser.bounds.width)) , height: imgUser.bounds.height-5))
        labMessage.numberOfLines = 0
        labMessage.textColor = textColorDark
        labMessage.font = UIFont(name: fontName, size: FONTSIZENormal)
        self.addSubview(labMessage)
        
        // Icon
        labIcon = UILabel(frame: CGRect(x: imgUser.bounds.width - 20, y: 55 , width: 30,height: 30))//createLabel(CGRect(x: imgUser.bounds.width + 5, y: labMessage.bounds.height + 10 , width: 20,height: 20), text: "", alignment: .left, textColor: textColorLight)
        labIcon.textAlignment = .center
        labIcon.textColor = textColorLight
        labIcon.font = UIFont(name: "FontAwesome", size: FONTSIZELarge)
        labIcon.textAlignment = .center
        labIcon.layer.cornerRadius = 15.0
        labIcon.layer.masksToBounds = true
        labIcon.layer.borderWidth = 0.0
        self.addSubview(labIcon)
        
        // Description
        labPostedDate = TTTAttributedLabel(frame: CGRect(x: imgUser.bounds.width + labIcon.bounds.width + 10, y: 50 ,width: (UIScreen.main.bounds.width - (imgUser.bounds.width + labIcon.bounds.width  + 15)) , height: 20))
        labPostedDate.numberOfLines = 0
        labPostedDate.textColor = textColorDark
        labPostedDate.font = UIFont(name: fontName, size: FONTSIZESmall)
       // self.addSubview(labPostedDate)
        
        
        postedOn = TTTAttributedLabel(frame: CGRect(x: imgUser.bounds.width + 10, y: labMessage.bounds.height + 5,width: (UIScreen.main.bounds.width - (imgUser.bounds.width + 15)) , height: 100))
        //        postedOn.font = UIFont(name: "FontAwesome", size:FONTSIZELarge)
        postedOn.textColor = textColorLight
        postedOn.isHidden = true
        self.addSubview(postedOn)
        
        
        
        acceptButton = createButton(CGRect(x: 5, y: 5, width: 40, height: 40), title: "A", border: true, bgColor: false, textColor: textColorLight)
        acceptButton.isHidden = true
        self.addSubview(acceptButton)
        
        notattendButton = createButton(CGRect(x: 5, y: 5, width: 40, height: 40), title: "N", border: true, bgColor: false, textColor: textColorLight)
        notattendButton.isHidden = true
        self.addSubview(notattendButton)
        
        ignoreButton = createButton(CGRect(x: 5, y: 5, width: 40, height: 40), title: "I", border: true, bgColor: false, textColor: textColorLight)
        ignoreButton.isHidden = true
        self.addSubview(ignoreButton)
        
        
        // PostCount
        postCount = createLabel(CGRect(x: (UIScreen.main.bounds.width - 75), y: 10, width: 75 , height: 15), text: " ", alignment: .left, textColor: textColorDark)
        postCount.font = UIFont(name: fontName, size: FONTSIZESmall)
        self.addSubview(postCount)
        
        optionMenu = createButton(CGRect(x:UIScreen.main.bounds.width - 30, y:35, width:30, height:35), title: optionIcon, border: false, bgColor: false, textColor: textColorDark)
        optionMenu.isHidden = true
        self.addSubview(optionMenu)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



