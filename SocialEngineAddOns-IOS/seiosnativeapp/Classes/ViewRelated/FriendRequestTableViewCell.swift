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
class FriendRequestTableViewCell: UITableViewCell {
    
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
    var title : UILabel!
    var acceptButton : CustomButton!
    var rejectButton : UIButton!
    
    // Initialize Variable for Custom Table Cell
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = UITableViewCell.SelectionStyle.blue
        
        imgUser = createImageView(CGRect(x: 10, y: 10, width: 70, height: 70), border: true)
        imgUser.image = UIImage(named: "user_profile_image.png")
        imgUser.layer.masksToBounds = true
        imgUser.isUserInteractionEnabled = true
        self.addSubview(imgUser)
        
        title = createLabel(CGRect( x: imgUser.bounds.width + 20, y: 15,width: (UIScreen.main.bounds.width - (imgUser.bounds.width + 15)) , height: 20), text: " ", alignment: .left, textColor: textColorDark)
        title.numberOfLines = 0
        title.font = UIFont(name: fontBold, size: FONTSIZENormal)
        title.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.addSubview(title)
        
        acceptButton = CustomButton()
        acceptButton.frame = CGRect(x: imgUser.bounds.width + 20 , y: title.bounds.height + 18, width: 100, height: 30)
        acceptButton.setTitle(NSLocalizedString("Accept",  comment: ""), for: .normal)
        acceptButton.setTitleColor(textColorLight, for: .normal)
        acceptButton.layer.backgroundColor = navColor.cgColor
        acceptButton.setTitleColor(textColorPrime, for: UIControl.State())
        acceptButton.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZESmall)
        acceptButton.layer.cornerRadius = 3.0
        self.addSubview(acceptButton)
        
        
        rejectButton = createButton(CGRect(x: imgUser.bounds.width + 130, y: title.bounds.height + 18, width: 100, height: 30), title: NSLocalizedString("Reject",  comment: ""), border: true, bgColor: false, textColor: textColorDark)
        rejectButton.layer.backgroundColor = UIColor.white.cgColor
        //rejectButton.layer.backgroundColor = textColorMedium.CGColor
        rejectButton.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZESmall)
        rejectButton.layer.cornerRadius = 3.0
        rejectButton.setTitleColor(textColorDark, for: UIControl.State())
        self.addSubview(rejectButton)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}




