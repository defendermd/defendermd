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
//  ClassifiedTableViewCell.swift
//  seiosnativeapp
//


import UIKit

class MusicTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var classifiedImageView : UIImageView!
    var bottomImageView : UIImageView!
    var classifiedName : UILabel!
    var classifiedPrice : UILabel!
    var menu: UIButton!
    var contentSelection:UIButton!
    var borderView : UIView!
    var MusicPlays : UILabel!
    var MusicPlays1 : UILabel!
    
    
    var classifiedImageView1 : UIImageView!
    var bottomImageView1 : UIImageView!
    var classifiedName1 : UILabel!
    var classifiedPrice1 : UILabel!
    var menu1: UIButton!
    var contentSelection1:UIButton!
    var borderView1 : UIView!
    
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    
    // Initialize Variable for Comments Table Cell
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Configure the view for the selected state
        
        let size = (UIScreen.main.bounds.width - (2 * PADING))/2
        
        classifiedImageView = Content1ImageViewWithGradient(frame: CGRect(x: 2*PADING , y: contentPADING, width: size - 2*PADING, height: 160 - 5))
        classifiedImageView.contentMode = UIView.ContentMode.scaleAspectFill
        classifiedImageView.layer.masksToBounds = true
        classifiedImageView.isUserInteractionEnabled = true
        classifiedImageView.backgroundColor = placeholderColor
        classifiedImageView.layer.shadowOpacity =  0.0
        self.addSubview(classifiedImageView)
        
        menu = createButton(CGRect(x: classifiedImageView.bounds.width - 40,y: 0, width: 40, height: 35), title: "\u{f141}", border: false,bgColor: false, textColor: textColorLight )
        menu.titleLabel?.font =  UIFont(name: "FontAwesome", size:30.0)
        menu.isHidden = true
        classifiedImageView.addSubview(menu)
        
        contentSelection = createButton(CGRect(x: 0, y: 35, width: classifiedImageView.bounds.width, height: classifiedImageView.bounds.height - 40), title: "", border: false,bgColor: false, textColor: UIColor.clear)
        classifiedImageView.addSubview(contentSelection)
        contentSelection.layer.borderWidth = 0.0
        
        
        classifiedName = createLabel(CGRect(x: 3 * PADING, y: 110, width: size, height: 30), text: "", alignment: .left, textColor: textColorLight)
        classifiedName.numberOfLines = 1
        classifiedName.font = UIFont(name: fontName, size: FONTSIZENormal)
        self.addSubview(classifiedName)
        
        MusicPlays = createLabel(CGRect(x: 3 * PADING, y: 135, width: size, height: 15), text: "", alignment: .left, textColor: textColorLight)
        MusicPlays.numberOfLines = 0
        MusicPlays.font = UIFont(name: fontName, size: FONTSIZESmall)
        self.addSubview(MusicPlays)
        MusicPlays.isHidden = true
        
        classifiedImageView1 = Content1ImageViewWithGradient(frame: CGRect(x: (2 * PADING) + size  , y: contentPADING, width: size - 2*PADING , height: 160-5))
        classifiedImageView1.contentMode = UIView.ContentMode.scaleAspectFill
        classifiedImageView1.layer.masksToBounds = true
        classifiedImageView1.isUserInteractionEnabled = true
        classifiedImageView1.backgroundColor = placeholderColor
        classifiedImageView1.layer.shadowOpacity =  0.0
        self.addSubview(classifiedImageView1)
        
        menu1 = createButton(CGRect(x: classifiedImageView1.bounds.width - 40,y: 0, width: 40, height: 35), title: "\u{f141}", border: false,bgColor: false, textColor: textColorLight )
        menu1.titleLabel?.font =  UIFont(name: "FontAwesome", size:30.0)
        menu1.isHidden = true
        classifiedImageView1.addSubview(menu1)
        
        classifiedName1 = createLabel(CGRect(x: (3*PADING) + size  , y: 110, width: size, height: 30), text: "", alignment: .left, textColor: textColorLight)
        classifiedName1.numberOfLines = 1
        classifiedName1.text = "Classified"
        classifiedName1.font = UIFont(name: fontName, size: FONTSIZENormal)
        self.addSubview(classifiedName1)
        
        MusicPlays1 = createLabel(CGRect(x: 3 * PADING + size , y: 135, width: size, height: 15), text: "", alignment: .left, textColor: textColorLight)
        MusicPlays1.numberOfLines = 0
        MusicPlays1.font = UIFont(name: fontName, size: FONTSIZESmall)
        self.addSubview(MusicPlays1)
        MusicPlays1.isHidden = true
        
        contentSelection1 = createButton(CGRect(x: 0, y: 35, width: classifiedImageView1.bounds.width, height: classifiedImageView1.bounds.height - 40), title: "", border: false,bgColor: false, textColor: UIColor.clear)
        contentSelection1.layer.borderWidth = 0.0
        classifiedImageView1.addSubview(contentSelection1)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
