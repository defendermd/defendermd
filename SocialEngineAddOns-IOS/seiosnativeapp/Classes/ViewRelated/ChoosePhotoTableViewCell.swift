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
//  PhotosTableViewCell.swift
//  seiosnativeapp
//

import UIKit

// This Class is used by PhotoListViewController & UploadPhotosEventViewController

class ChoosePhotoTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var image1:UIButton!
    var photo1 : UIImageView!
    var likeCommentLabel: UILabel!
    var contentSelection1:UIButton!
    
    var image2:UIButton!
    var photo2 : UIImageView!
    var likeCommentLabel1 : UILabel!
    var contentSelection2:UIButton!
    
    //FOR CHOOSE PHOTO VIEW
    var image3:UIButton!
    var photo3 : UIImageView!
    var likeCommentLabel3: UILabel!
    var contentSelection3:UIButton!
    
    var image4:UIButton!
    var photo4 : UIImageView!
    var likeCommentLabel4 : UILabel!
    var contentSelection4:UIButton!
    
    
    
    
    
    // Initialize Variable for Comments Table Cell
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Configure the view for the selected state
        var size:CGFloat = 0;
        // size = (UIScreen.main.bounds.width)/2
        
        size = (UIScreen.main.bounds.width - (2 * PADING))/4
        
        photo1  = ContentImageViewWithGradient(frame: CGRect(x: 2*PADING, y: contentPADING, width: size - 2*PADING, height: size))
        photo1.contentMode = UIView.ContentMode.scaleAspectFill
        photo1.layer.masksToBounds = true
        photo1.isUserInteractionEnabled = true
        photo1.backgroundColor = placeholderColor
        photo1.layer.shadowColor = shadowColor.cgColor
        photo1.layer.shadowOpacity = shadowOpacity
        photo1.layer.shadowRadius = shadowRadius
        photo1.layer.shadowOffset = shadowOffset
        photo1.isHidden = true
        self.addSubview(photo1)
        
        image1 = createButton(CGRect(x: 0, y: 0, width: size, height: size), title: "", border: false, bgColor: false, textColor: textColorLight)
        image1.isHidden = true
        image1.imageView?.contentMode = UIView.ContentMode.scaleAspectFill
        photo1.addSubview(image1)
        
        likeCommentLabel = createLabel(CGRect(x: 10, y: image1.bounds.height - 30, width: size, height: 30), text: "", alignment: .left, textColor: textColorLight)
        likeCommentLabel.font = UIFont(name: fontBold, size: FONTSIZELarge )
        //        totalMembers.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        likeCommentLabel.isHidden =  true
        photo1.addSubview(likeCommentLabel)
        
        contentSelection1 = createButton(CGRect(x: 0, y: 0, width: photo1.bounds.width, height: photo1.bounds.height), title: "", border: false,bgColor: false, textColor: UIColor.clear)
        photo1.addSubview(contentSelection1)
        
        photo2  = ContentImageViewWithGradient(frame: CGRect(x: (2 * PADING) + size, y: contentPADING, width: size - 2*PADING, height: size))
        photo2.contentMode = UIView.ContentMode.scaleAspectFill
        photo2.layer.masksToBounds = true
        photo2.isUserInteractionEnabled = true
        photo2.backgroundColor = placeholderColor
        photo2.layer.shadowColor = shadowColor.cgColor
        photo2.layer.shadowOpacity = shadowOpacity
        photo2.layer.shadowRadius = shadowRadius
        photo2.layer.shadowOffset = shadowOffset
        photo2.isHidden = true
        
        self.addSubview(photo2)
        
        image2 = createButton(CGRect(x: size, y: 0, width: size, height: size), title: "", border: false, bgColor: false, textColor: textColorLight)
        image2.isHidden = true
        image2.imageView?.contentMode = UIView.ContentMode.scaleAspectFill
        photo2.addSubview(image2)
        
        likeCommentLabel1 = createLabel(CGRect(x: 10, y: image1.bounds.height - 30, width: size, height: 30), text: "", alignment: .left, textColor: textColorLight)
        likeCommentLabel1.font = UIFont(name: fontBold, size: FONTSIZELarge )
        //        totalMembers.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        likeCommentLabel1.isHidden =  true
        photo2.addSubview(likeCommentLabel1)
        
        contentSelection2 = createButton(CGRect(x: 0, y: 0, width: photo2.bounds.width, height: photo2.bounds.height), title: "", border: false,bgColor: false, textColor: UIColor.clear)
        photo2.addSubview(contentSelection2)
        
        
        
        // FOR CHOOSE PHOTO VIEW
        photo3  = ContentImageViewWithGradient(frame: CGRect(x: (2 * PADING) + (2 * size), y: contentPADING , width: size - 2*PADING, height: size))
        photo3.contentMode = UIView.ContentMode.scaleAspectFill
        photo3.layer.masksToBounds = true
        photo3.isUserInteractionEnabled = true
        photo3.backgroundColor = placeholderColor
        photo3.layer.shadowColor = shadowColor.cgColor
        photo3.layer.shadowOpacity = shadowOpacity
        photo3.layer.shadowRadius = shadowRadius
        photo3.layer.shadowOffset = shadowOffset
        photo3.isHidden = true
        
        self.addSubview(photo3)
        
        image3 = createButton(CGRect(x: size, y: 0, width: size, height: size), title: "", border: false, bgColor: false, textColor: textColorLight)
        image3.isHidden = true
        image3.imageView?.contentMode = UIView.ContentMode.scaleAspectFill
        photo3.addSubview(image3)
        
        likeCommentLabel3 = createLabel(CGRect(x: 10, y: image1.bounds.height - 30, width: size , height: 30), text: "", alignment: .left, textColor: textColorLight)
        likeCommentLabel3.font = UIFont(name: fontBold, size: FONTSIZELarge )
        //        totalMembers.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        likeCommentLabel3.isHidden = true
        photo3.addSubview(likeCommentLabel3)
        
        contentSelection3 = createButton(CGRect(x: 0, y: 0, width: photo3.bounds.width, height: photo3.bounds.height), title: "", border: false,bgColor: false, textColor: UIColor.clear)
        photo3.addSubview(contentSelection3)
        
        photo4  = ContentImageViewWithGradient(frame: CGRect(x: (2 * PADING) + (3 * size)  , y: contentPADING , width: size - 2*PADING, height: size))
        photo4.contentMode = UIView.ContentMode.scaleAspectFill
        photo4.layer.masksToBounds = true
        photo4.isUserInteractionEnabled = true
        photo4.backgroundColor = placeholderColor
        photo4.layer.shadowColor = shadowColor.cgColor
        photo4.layer.shadowOpacity = shadowOpacity
        photo4.layer.shadowRadius = shadowRadius
        photo4.layer.shadowOffset = shadowOffset
        photo4.isHidden = true
        
        self.addSubview(photo4)
        
        image4 = createButton(CGRect(x: size, y: 0, width: size, height: size), title: "", border: false, bgColor: false, textColor: textColorLight)
        image4.isHidden = true
        image4.imageView?.contentMode = UIView.ContentMode.scaleAspectFill
        photo4.addSubview(image4)
        
        likeCommentLabel4 = createLabel(CGRect(x: 10, y: image1.bounds.height - 30, width: size , height: 30), text: "", alignment: .left, textColor: textColorLight)
        likeCommentLabel4.font = UIFont(name: fontBold, size: FONTSIZELarge )
        //        totalMembers.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        likeCommentLabel4.isHidden = true
        photo4.addSubview(likeCommentLabel4)
        
        contentSelection4 = createButton(CGRect(x: 0, y: 0, width: photo4.bounds.width, height: photo4.bounds.height), title: "", border: false,bgColor: false, textColor: UIColor.clear)
        photo4.addSubview(contentSelection4)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
