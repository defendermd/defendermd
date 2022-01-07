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
//  CommentTableViewCell.swift
//  seiosnativeapp
//

import UIKit

// This Class is used by CommentsViewController & ShowMembersViewController

class CommentTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // Define Variable for Comment Table Cell
    var author_photo:UIImageView!
    var author_title:TTTAttributedLabel!
    var comment_body:TTTAttributedLabel!
    var sticker : UIImageView!
    var comment_date:UILabel!
    var delete:UIButton!
    var like:UIButton!
    var unlike:UIButton!
    var option1:UIButton!
    var option2:UIButton!
    var staff:UIButton!
    var status:UILabel!
    var imageButton : UIButton!
    var likeDot : UILabel!
    var deleteDot : UILabel!
    var likeCountDot : UILabel!
    var imageviewButton = UIButton()
    // var rsvpStatus:UILabel!
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
        
    }
    
    // Initialize Variable for Comments Table Cell
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        //self.selectionStyle = UITableViewCell.SelectionStyle.Blue
        
        
        if  (UIDevice.current.userInterfaceIdiom == .phone){
//            author_photo = createButton(CGRect(x: 5, y: 5, width: 40, height: 40), title: "", border: true, bgColor: false, textColor: textColorLight)
            author_photo = createImageView(CGRect(x: 5, y: 5, width: 50, height: 50), border: true)
            imageButton = createButton(CGRect(x: 5, y: 5, width: 50, height: 50), title: "", border: false, bgColor: false, textColor: textColorLight)
            
        }else{
//            author_photo = createButton(CGRect(x: 5, y: 5, width: 50, height: 50), title: "", border: true, bgColor: false, textColor: textColorLight)
            author_photo = createImageView(CGRect(x: 5, y: 5, width: 50, height: 50), border: true)
            imageButton = createButton(CGRect(x: 5, y: 5, width: 50, height: 50), title: "", border: false, bgColor: false, textColor: textColorLight)
        }
        
        author_photo.layer.borderColor = bgColor.cgColor
        author_photo.layer.borderWidth = 1
        author_photo.layer.cornerRadius = author_photo.frame.size.height/2
        author_photo.layer.masksToBounds = true
        self.addSubview(author_photo)
        self.addSubview(imageButton)
        
        author_title = TTTAttributedLabel(frame:CGRect(x: author_photo.bounds.width+10, y: 5, width: self.bounds.width-(author_photo.bounds.width+15), height: 100))
        author_title.numberOfLines = 0
        author_title.linkAttributes = [kCTForegroundColorAttributeName:textColorDark]
        author_title.font = UIFont(name: fontBold, size: FONTSIZENormal)
        self.addSubview(author_title)
        
        comment_body = TTTAttributedLabel(frame:CGRect(x: author_photo.bounds.width+10, y: 5, width: self.bounds.width-(author_photo.bounds.width+15), height: 100))
        comment_body.font = UIFont(name: fontName, size: FONTSIZENormal )
        comment_body.linkAttributes = [kCTForegroundColorAttributeName:textColorDark]
        comment_body.numberOfLines = 0
        self.addSubview(comment_body)
        
        sticker = createImageView(CGRect(x: author_photo.bounds.width+10, y: 5, width: 40, height: 40), border: false)
        self.addSubview(sticker)
        
        imageviewButton = createButton(CGRect(x: author_photo.bounds.width+10, y: 5, width: 40, height: 40), title: "", border: false,bgColor: false, textColor: linkColor)
        self.addSubview(imageviewButton)
        
        comment_date = createLabel(CGRect(x: author_photo.bounds.width+10, y: 70, width: 100, height: 20), text: "", alignment: .left, textColor: textColorMedium)
        comment_date.font = UIFont(name: fontName, size: FONTSIZESmall)
//        comment_date.backgroundColor = UIColor.brown
        self.addSubview(comment_date)
        
        if  (UIDevice.current.userInterfaceIdiom == .phone){
            likeDot = createLabel(CGRect(x: 135 , y: 70, width: 15, height: 15), text: "\(filledCircleIcon)", alignment: .left, textColor: buttonColor)
        }else{
            likeDot = createLabel(CGRect(x: 185 , y: 70, width: 15, height: 15), text: "\(filledCircleIcon)", alignment: .left, textColor: buttonColor)
        }
        likeDot.font = UIFont(name: "FontAwesome", size: 4)
        likeDot.isHidden = true
//        likeDot.backgroundColor = UIColor.cyan
        self.addSubview(likeDot)
        
        if  (UIDevice.current.userInterfaceIdiom == .phone){
            like = createButton(CGRect(x: 150, y: 70, width: 50 , height: 20), title: "", border: false,bgColor: false, textColor: buttonColor)
        }else{
            like = createButton(CGRect(x: 200, y: 70, width: 50 , height: 20), title: "", border: false,bgColor: false, textColor: buttonColor)
        }
        like.titleLabel?.font = UIFont(name: fontName, size: FONTSIZESmall)
        like.isHidden = true
        like.contentHorizontalAlignment = .center
//        like.backgroundColor = UIColor.green
        self.addSubview(like)
        
        if  (UIDevice.current.userInterfaceIdiom == .phone){
            unlike = createButton(CGRect(x: 200, y: 70, width: 30 , height: 20), title: "", border: false,bgColor: false, textColor: buttonColor)
        }else{
            unlike = createButton(CGRect(x: 255, y: 70, width: 30 , height: 20), title: "", border: false,bgColor: false, textColor: buttonColor)
        }
        unlike.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZESmall)
        unlike.isHidden = true
        unlike.contentHorizontalAlignment = .center
//        unlike.backgroundColor = UIColor.lightGray
        self.addSubview(unlike)
        
        
        if  (UIDevice.current.userInterfaceIdiom == .phone){
            likeCountDot = createLabel(CGRect(x: 185 , y: 70,width: 15 , height: 15), text: "\(filledCircleIcon)", alignment: .left, textColor: buttonColor)
        }else{
            likeCountDot = createLabel(CGRect(x: 240 , y: 70,width: 15 , height: 15), text: "\(filledCircleIcon)", alignment: .left, textColor: buttonColor)
        }
        likeCountDot.font = UIFont(name: "FontAwesome", size: 4)
        likeCountDot.isHidden = true
//        likeCountDot.backgroundColor = UIColor.orange
        self.addSubview(likeCountDot)
        
        if  (UIDevice.current.userInterfaceIdiom == .phone){
            
            delete = createButton(CGRect(x: 240, y: 70,width: 50 , height: 20), title: "", border: false,bgColor: false, textColor: buttonColor)
        }else{
            delete = createButton(CGRect(x: 295, y: 70,width: 50 , height: 20), title: "", border: false,bgColor: false, textColor: buttonColor)
        }
        
        delete.titleLabel?.font = UIFont(name: fontName, size: FONTSIZESmall)
        delete.isHidden = true
        delete.contentHorizontalAlignment = .center
//        delete.backgroundColor = UIColor.yellow
        self.addSubview(delete)
        
        if  (UIDevice.current.userInterfaceIdiom == .phone){
            deleteDot = createLabel(CGRect(x: 225 , y: 70,width: 15 , height: 15), text: "\(filledCircleIcon)", alignment: .left, textColor: navColor)
        }else{
            deleteDot = createLabel(CGRect(x: 280 , y: 70,width: 15 , height: 15), text: "\(filledCircleIcon)", alignment: .left, textColor: navColor)
        }
        deleteDot.font = UIFont(name: "FontAwesome", size: 4)
        deleteDot.isHidden = true
//        deleteDot.backgroundColor = UIColor.red
        self.addSubview(deleteDot)
        
        if  (UIDevice.current.userInterfaceIdiom == .phone){
            option1 = createButton(CGRect(x: author_photo.bounds.width+10, y: 35, width: 130 , height: 20), title: "", border: false,bgColor: false, textColor: linkColor)
        }else{
            option1 = createButton(CGRect(x: 150, y: 35, width: 130 , height: 20), title: "", border: false,bgColor: false, textColor: linkColor)
        }
        
        option1.titleLabel?.font = UIFont(name: fontName, size: FONTSIZESmall)
        option1.contentHorizontalAlignment = .left
        option1.isHidden = true
        self.addSubview(option1)
        
        if  (UIDevice.current.userInterfaceIdiom == .phone){
            option2 = createButton(CGRect(x: 190, y: 35,width: 130 , height: 20), title: "", border: false,bgColor: false, textColor: linkColor)
        }else{
            option2 = createButton(CGRect(x: 350, y: 35,width: 130 , height: 20), title: "", border: false,bgColor: false, textColor: linkColor)
        }
        
        option2.titleLabel?.font = UIFont(name: fontName, size: FONTSIZESmall)
        option2.contentHorizontalAlignment = .left
        option2.isHidden = true
        self.addSubview(option2)
        
        staff = createButton(CGRect(x: 250, y: 5 ,width: 100 , height: 20), title: "", border: false,bgColor: false, textColor: linkColor)
        staff.titleLabel?.font = UIFont(name: fontName, size: FONTSIZESmall)
        staff.contentHorizontalAlignment = .left
        staff.isHidden = true
        self.addSubview(staff)
        
        status = createLabel(CGRect(x: 250, y: 5 ,width: 100 , height: 20), text: "", alignment: .left, textColor: textColorMedium)
        status.font = UIFont(name: fontName, size: FONTSIZESmall)
        self.addSubview(status)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
