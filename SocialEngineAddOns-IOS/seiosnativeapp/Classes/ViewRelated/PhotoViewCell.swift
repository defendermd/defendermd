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

class PhotoViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var image1:UIButton!
    var photo1 : UIImageView!
    var likeCommentLabel: UILabel!
    
    var image2:UIButton!
    var photo2 : UIImageView!
    var likeCommentLabel1 : UILabel!
    var gifImageView : UIImageView!
    var gifImageView1 : UIImageView!
    // Initialize Variable for Comments Table Cell
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Configure the view for the selected state
        var size:CGFloat = 0;
        // size = (UIScreen.main.bounds.width)/2
        
        size = (UIScreen.main.bounds.width - (2 * PADING))/2
        
        photo1  = ContentImageViewWithGradient(frame: CGRect(x: 2*PADING, y: contentPADING ,width: size - 2*PADING , height: size ))
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
        
        gifImageView = createImageView(CGRect(x: 0, y: 0, width: 50, height: 50), border: false)
        gifImageView.center = photo1.center
        gifImageView.image = UIImage(named: "gif_icon.png")
        gifImageView.isHidden = true
        photo1.addSubview(gifImageView)
        
        image1 = createButton(CGRect(x: 0, y: 0,width: size , height: size), title: "", border: false,bgColor: false, textColor: textColorLight)
        image1.isHidden = true
        image1.imageView?.contentMode = UIView.ContentMode.scaleAspectFill
        photo1.addSubview(image1)
        
        likeCommentLabel = createLabel(CGRect(x: 10, y: image1.bounds.height - 30, width: size , height: 30), text: "", alignment: .left, textColor: textColorLight)
        likeCommentLabel.font = UIFont(name: fontBold, size: FONTSIZELarge )
        //        totalMembers.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        photo1.addSubview(likeCommentLabel)
        
        photo2  = ContentImageViewWithGradient(frame: CGRect(x: (2 * PADING) + size  , y: contentPADING , width: size - 2*PADING , height: size))
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
        
        gifImageView1 = createImageView(CGRect(x: 0, y: 0, width: 50, height: 50), border: false)
        gifImageView1.center = photo2.center
        gifImageView1.image = UIImage(named: "gif_icon.png")
        gifImageView1.isHidden = true
        
        
        image2 = createButton(CGRect(x: size, y: 0,width: size , height: size), title: "", border: false,bgColor: false, textColor: textColorLight)
        image2.isHidden = true
        image2.imageView?.contentMode = UIView.ContentMode.scaleAspectFill
        self.addSubview(image2)
        
        likeCommentLabel1 = createLabel(CGRect(x: 10, y: image1.bounds.height - 30, width: size , height: 30), text: "", alignment: .left, textColor: textColorLight)
        likeCommentLabel1.font = UIFont(name: fontBold, size: FONTSIZELarge )
        //        totalMembers.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        photo2.addSubview(likeCommentLabel1)
        
        self.addSubview(gifImageView1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
