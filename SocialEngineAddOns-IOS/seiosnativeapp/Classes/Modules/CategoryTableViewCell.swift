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

//  CategoryTableViewCell.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 07/03/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit

class CategoryTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var classifiedImageView : UIImageView!
    var bottomImageView : UIImageView!
    var DiaryName : UILabel!
    var classifiedPrice : UILabel!
    var menu: UIButton!
    var contentSelection:UIButton!
    var borderView : UIView!
    var MusicPlays : UILabel!
    var MusicPlays1 : UILabel!
    
    
    var classifiedImageView1 : UIImageView!
    var bottomImageView1 : UIImageView!
    var DiaryName1 : UILabel!
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
        
        var size:CGFloat = 0;
        if(UIDevice.current.userInterfaceIdiom == .pad){
            size = (UIScreen.main.bounds.width - (5 * PADING))/3
        }else{
            size = (UIScreen.main.bounds.width - (4 * PADING))
        }
        
        size = (UIScreen.main.bounds.width - (2 * PADING))/2
        
        
        //classifiedImageView = createImageView(CGRect(x:2*PADING , 0, size - 2*PADING, 160 - 5), border: true)
        classifiedImageView = categoryImageViewWithGradientadvanced(frame: CGRect(x: 2*PADING , y: 0, width: size - 2*PADING, height: 160 - 5))
        classifiedImageView.contentMode = UIView.ContentMode.scaleAspectFill
        classifiedImageView.layer.masksToBounds = true
        classifiedImageView.isUserInteractionEnabled = true
        classifiedImageView.backgroundColor = UIColor.lightGray//navColor
        self.addSubview(classifiedImageView)
        
        
        
        
        contentSelection = createButton(CGRect(x: 0, y: 0, width: classifiedImageView.bounds.width, height: classifiedImageView.bounds.height - 40), title: "", border: false,bgColor: false, textColor: UIColor.clear)
        contentSelection.backgroundColor = UIColor.clear
        classifiedImageView.addSubview(contentSelection)
        
        DiaryName = createLabel(CGRect(x: 5,y: (classifiedImageView.frame.size.height-60)/2, width: classifiedImageView.frame.size.width-10, height: 60), text: "", alignment: .left, textColor: textColorLight)
        DiaryName.numberOfLines = 0
        DiaryName.font = UIFont(name: fontBold, size: FONTSIZELarge)
        classifiedImageView.addSubview(DiaryName)
        DiaryName.textAlignment = NSTextAlignment.center
        DiaryName.isHidden = true
        DiaryName.lineBreakMode = NSLineBreakMode.byWordWrapping
        
       
        DiaryName.layer.shadowColor = shadowColor.cgColor
        DiaryName.layer.shadowOpacity = shadowOpacity
        DiaryName.layer.shadowRadius = shadowRadius
        DiaryName.layer.shadowOffset = shadowOffset
        
        

        classifiedImageView1 = categoryImageViewWithGradientadvanced(frame: CGRect(x: (2 * PADING) + size  , y: 0, width: size - 2*PADING , height: 160-5))
        //classifiedImageView1 = createImageView(CGRect(x:(2 * PADING) + size  , 0, size - 2*PADING , 160-5), border: true)
        classifiedImageView1.contentMode = UIView.ContentMode.scaleAspectFill
        classifiedImageView1.layer.masksToBounds = true
        classifiedImageView1.isUserInteractionEnabled = true
        classifiedImageView1.backgroundColor = UIColor.lightGray//navColor
        
        self.addSubview(classifiedImageView1)
        
 
        
        DiaryName1 = createLabel(CGRect(x: 5  , y: (classifiedImageView1.frame.size.height-60)/2, width: classifiedImageView1.frame.size.width-10, height: 60), text: "", alignment: .left, textColor: textColorLight)
        DiaryName1.numberOfLines = 0
        DiaryName1.font = UIFont(name: fontBold, size: FONTSIZELarge)
        classifiedImageView1.addSubview(DiaryName1)
        DiaryName1.textAlignment = NSTextAlignment.center
        DiaryName1.isHidden = true
        DiaryName1.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        DiaryName1.layer.shadowColor = shadowColor.cgColor
        DiaryName1.layer.shadowOpacity = shadowOpacity
        DiaryName1.layer.shadowRadius = shadowRadius
        DiaryName1.layer.shadowOffset = shadowOffset

        
    
        
        contentSelection1 = createButton(CGRect(x: 0, y: 0, width: classifiedImageView1.bounds.width, height: classifiedImageView1.bounds.height - 40), title: "", border: false,bgColor: false, textColor: UIColor.clear)
        contentSelection1.backgroundColor = UIColor.clear
        classifiedImageView1.addSubview(contentSelection1)
        
        
        
        
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
