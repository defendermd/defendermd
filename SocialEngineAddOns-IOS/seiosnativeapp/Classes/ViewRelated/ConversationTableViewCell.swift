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
class ConversationTableViewCell: UITableViewCell {
    
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
    var postCount :UILabel!
    var attachmentImage : UIImageView!
    var postedOn: UILabel!
    var messageView : UIView!
    
    
    var msgTextView : UITextView!
    
    // Initialize Variable for Custom Table Cell
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = UITableViewCell.SelectionStyle.blue
        
        
        messageView = createView(CGRect(x: 0, y: 0 ,width: (UIScreen.main.bounds.width - 60) , height: 100), borderColor: textColorMedium, shadow: true)
        messageView.backgroundColor = tableViewBgColor
        messageView.layer.masksToBounds = true
        messageView.layer.cornerRadius = 5.0
        self.addSubview(messageView)
        
        
        // Icon Size
        if  (UIDevice.current.userInterfaceIdiom == .phone){
            imgUser = createImageView(CGRect(x: 5, y: 5, width: 50, height: 50), border: true)
        }else{
            imgUser = createImageView(CGRect(x: 5, y: 5, width: 60, height: 60), border: true)
        }
        imgUser.backgroundColor = UIColor.lightGray
        imgUser.layer.masksToBounds = true
        imgUser.layer.cornerRadius = 5.0
        imgUser.image = UIImage(named: "user_profile_image.png")
        messageView.addSubview(imgUser)
        
        
        msgTextView = createTextView(CGRect(x: imgUser.bounds.width + 10, y: 0 ,width: (UIScreen.main.bounds.width - (imgUser.bounds.width + 60)) , height: 100), borderColor: UIColor.clear , corner: true)
        
        msgTextView.isHidden = false
        msgTextView.text = NSLocalizedString("",  comment: "")
        msgTextView.font = UIFont(name: fontName, size: FONTSIZELarge)
        msgTextView.textColor = textColorDark
        msgTextView.isEditable = false
        msgTextView.autocorrectionType = UITextAutocorrectionType.no
        messageView.addSubview(msgTextView)
        
        
        
        // Sender's Name
        labTitle = createLabel(CGRect( x: imgUser.bounds.width + 10, y: 5,width: (UIScreen.main.bounds.width - (imgUser.bounds.width + 15)) , height: 20), text: " ", alignment: .left, textColor: textColorDark)
        labTitle.numberOfLines = 0
        labTitle.font = UIFont(name: fontBold, size: FONTSIZELarge)
        self.addSubview(labTitle)
        labTitle.isHidden = true
        
        // Posted On Date Label
        postedOn = createLabel(CGRect( x: messageView.bounds.width - 130, y: msgTextView.bounds.height-12,width: 125, height: 12), text: " ", alignment: .right, textColor: textColorMedium)
        //postedOn = createLabel(CGRect(x: UIScreen.main.bounds.width - 200, 5,195, 20), " ", .right, textColorDark)
        postedOn.numberOfLines = 0
        postedOn.font = UIFont(name: fontName, size: FONTSIZESmall)
        self.addSubview(postedOn)
        postedOn.isHidden = true
        
        // Description Message
        labMessage = TTTAttributedLabel(frame: CGRect(x: 10, y: imgUser.bounds.height + 10,width: (UIScreen.main.bounds.width - 20) , height: 100))
        labMessage.numberOfLines = 0
        labMessage.textColor = textColorDark
        labMessage.font = UIFont(name: fontName, size: FONTSIZEMedium)
        self.addSubview(labMessage)
        labMessage.isHidden = true
        
        // PostCount
        postCount = createLabel(CGRect(x: (UIScreen.main.bounds.width - 75), y: 10, width: 75 , height: 15), text: " ", alignment: .right, textColor: textColorDark)
        postCount.font = UIFont(name: fontName, size: FONTSIZESmall)
        self.addSubview(postCount)
        postCount.isHidden = true
        
        if  (UIDevice.current.userInterfaceIdiom == .phone){
            attachmentImage = createImageView(CGRect(x: 5, y: labMessage.bounds.height, width: 75, height: 75), border: true)
        }else{
            attachmentImage = createImageView(CGRect(x: 5, y: labMessage.bounds.height, width: 100, height: 100), border: true)
        }
        attachmentImage.layer.masksToBounds = true
        attachmentImage.layer.cornerRadius = 5.0
        attachmentImage.isHidden = true
        self.addSubview(attachmentImage)
        attachmentImage.isHidden = true
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



