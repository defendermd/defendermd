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

//  DiaryTableViewCell.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 29/01/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit

class DiaryTableViewCell: UITableViewCell
{

    var cellView: UIView!
    var titleView : UIView!
    var titleLabel:UILabel!
    var countLabel:UILabel!
    var lineView : UIView!
    var coverSelection:UIButton!
    var coverImage:UIImageView!
    var coverImage1:UIImageView!
    var coverImage2:UIImageView!
    var coverImage3:UIImageView!
    
    var coverImage4:UIButton!
    var coverImage5:UIButton!
    
    
    var cellView2: UIView!
    var titleView2 : UIView!
    var titleLabel2:UILabel!
    var countLabel2:UILabel!
    var lineView2 : UIView!
    var coverSelection2:UIButton!
    var coverImage6:UIImageView!
    var coverImage7:UIImageView!
    var coverImage8:UIImageView!
    var coverImage9:UIImageView!
    
    var coverImage10:UIButton!
    var coverImage11:UIButton!
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    // Initialize Variable for Comments Table Cell
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            cellView = createView( CGRect(x: 0, y: 0,width: (UIScreen.main.bounds.width/2) , height: 200), borderColor: borderColorMedium, shadow: false)
        }
        else
        {
            cellView = createView( CGRect(x: 0, y: 0,width: (UIScreen.main.bounds.width) , height: 200), borderColor: borderColorMedium, shadow: false)
        }

        cellView.layer.borderWidth = 0.0
        cellView.isUserInteractionEnabled = true
        cellView.backgroundColor = UIColor.clear
        self.addSubview(cellView)
        
        
        lineView = UIView(frame: CGRect(x: 0,y: cellView.frame.size.height,width: (UIScreen.main.bounds).width,height: 2))
        lineView.backgroundColor = UIColor.white
        lineView.isHidden = false
        self.addSubview(lineView)
        
        coverImage = DiaryImageViewWithGradient(frame: CGRect(x: 0, y: 0, width: cellView.bounds.width, height: cellView.bounds.size.height))
        coverImage.layer.masksToBounds = true
        coverImage.backgroundColor = UIColor.clear//navColor
        coverImage.image = UIImage(named: "nophoto_diary_thumb_profile.png")
        cellView.addSubview(coverImage)
        
        coverImage1 = DiaryImageViewWithGradient(frame: CGRect(x: 0, y: 0, width: cellView.bounds.width*0.6, height: cellView.bounds.size.height))
        coverImage1.layer.masksToBounds = true
        coverImage1.backgroundColor = UIColor.clear//navColor
        coverImage1.isHidden = true
        coverImage1.image = UIImage(named: "nophoto_diary_thumb_profile.png")
        cellView.addSubview(coverImage1)
        
        coverImage2 = DiaryImageViewWithGradient(frame: CGRect(x: (cellView.bounds.width*0.6)+1, y: 0, width: (cellView.bounds.width*0.4)-1, height: cellView.bounds.size.height*0.5))
        coverImage2.layer.masksToBounds = true
        coverImage2.isHidden = true
        coverImage2.backgroundColor = UIColor.clear//navColor
        coverImage2.image = UIImage(named: "nophoto_diary_thumb_profile.png")
        cellView.addSubview(coverImage2)
        
        
        coverImage3 = DiaryImageViewWithGradient(frame: CGRect(x: (cellView.bounds.width*0.6)+1, y: (cellView.bounds.size.height*0.5)+1, width: (cellView.bounds.width*0.4)-1, height: (cellView.bounds.size.height*0.5)-1))
        coverImage3.layer.masksToBounds = true
        coverImage3.backgroundColor = UIColor.clear//navColor
        coverImage3.isHidden = true
        coverImage3.image = UIImage(named: "nophoto_diary_thumb_profile.png")
        cellView.addSubview(coverImage3)
        
        coverImage4 = createButton(CGRect(x: 0, y: 0, width: cellView.bounds.width*0.5, height: cellView.bounds.size.height), title: "", border: false,bgColor: false, textColor: textColorLight)
        coverImage4.layer.masksToBounds = true
        coverImage4.backgroundColor = UIColor.clear//navColor
        coverImage4.isHidden = true
        coverImage4.setImage(UIImage(named: "nophoto_diary_thumb_profile.png"), for: UIControl.State())
        coverImage4.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.fill
        coverImage4.contentVerticalAlignment = UIControl.ContentVerticalAlignment.fill
        coverImage4.imageView?.contentMode = UIView.ContentMode.scaleAspectFill
        cellView.addSubview(coverImage4)
        
        
        

        coverImage5 = createButton(CGRect(x: (cellView.bounds.width*0.5)+1, y: 0, width: (cellView.bounds.width*0.5)-1, height: cellView.bounds.size.height), title: "", border: false,bgColor: false, textColor: textColorLight)
        coverImage5.layer.masksToBounds = true
        coverImage5.backgroundColor = UIColor.clear//navColor
        coverImage5.isHidden = true
        coverImage5.setImage(UIImage(named: "nophoto_diary_thumb_profile.png"), for: UIControl.State())
        coverImage5.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.fill
        coverImage5.contentVerticalAlignment = UIControl.ContentVerticalAlignment.fill
        coverImage5.imageView?.contentMode = UIView.ContentMode.scaleAspectFill
        
        cellView.addSubview(coverImage5)
        
        
        coverSelection = createButton(cellView.frame, title: "", border: false,bgColor: false, textColor: textColorLight)
        coverSelection.frame.size.height = (cellView.frame.size.height)
        coverSelection.backgroundColor = UIColor.clear
        coverSelection.tintColor = UIColor.clear
        
        
        let GradientLayer = CAGradientLayer()
        GradientLayer.frame = CGRect(x: coverSelection.frame.origin.x,y: coverSelection.frame.size.height-30, width: coverSelection.frame.size.width, height: 30)
        let colors: [CGColor] = [UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor,UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor,UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor,UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor,UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor,UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor,UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor]
        
        GradientLayer.colors = colors
        coverSelection.layer.insertSublayer(GradientLayer, above: coverSelection.imageView?.layer)
        self.addSubview(coverSelection)
        
        titleLabel = createLabel(CGRect(x: 10, y: cellView.frame.size.height-30, width: cellView.frame.size.width-70, height: 30), text: "", alignment: .left, textColor: UIColor.white)
        titleLabel.font = UIFont(name: fontName, size: FONTSIZELarge)
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
        self.addSubview(titleLabel)

        countLabel = createLabel(CGRect( x: coverSelection.bounds.width - 60, y: coverSelection.bounds.height - 30, width: 50, height: 30), text: "", alignment: .left, textColor:UIColor.white)
        countLabel.font = UIFont(name: fontName, size: FONTSIZESmall)
        countLabel.backgroundColor = UIColor.clear
        countLabel.textAlignment = NSTextAlignment.center
        self.addSubview(countLabel)

        
        
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            // RHS
            cellView2 = createView(CGRect(x: (UIScreen.main.bounds.width/2), y: 0,width: (UIScreen.main.bounds.width/2) , height: 200), borderColor: borderColorMedium, shadow: false)
            
            cellView2.layer.borderWidth = 0.0
            self.addSubview(cellView2)
            cellView2.isUserInteractionEnabled = true
            
 
            lineView2 = UIView(frame: CGRect(x: 0,y: cellView2.frame.size.height,width: (UIScreen.main.bounds).width,height: 2))
            lineView2.backgroundColor = UIColor.white
            lineView2.isHidden = false
            self.addSubview(lineView2)
            
            coverImage6 = DiaryImageViewWithGradient(frame: CGRect(x: 0, y: 0, width: cellView2.bounds.width, height: cellView2.bounds.size.height))
            coverImage6.layer.masksToBounds = true
            coverImage6.backgroundColor = UIColor.clear//navColor
            coverImage6.image = UIImage(named: "nophoto_diary_thumb_profile.png")
            cellView2.addSubview(coverImage6)
            
            coverImage7 = DiaryImageViewWithGradient(frame: CGRect(x: 0, y: 0, width: cellView2.bounds.width*0.6, height: cellView2.bounds.size.height))
            coverImage7.layer.masksToBounds = true
            coverImage7.backgroundColor = UIColor.clear//navColor
            coverImage7.isHidden = true
            coverImage7.image = UIImage(named: "nophoto_diary_thumb_profile.png")
            cellView2.addSubview(coverImage7)
            
            coverImage8 = DiaryImageViewWithGradient(frame: CGRect(x: (cellView2.bounds.width*0.6)+1, y: 0, width: (cellView2.bounds.width*0.4)-1, height: cellView2.bounds.size.height*0.5))
            coverImage8.layer.masksToBounds = true
            coverImage8.isHidden = true
            coverImage8.backgroundColor = UIColor.clear//navColor
            coverImage8.image = UIImage(named: "nophoto_diary_thumb_profile.png")
            cellView2.addSubview(coverImage8)
            
            
            coverImage9 = DiaryImageViewWithGradient(frame: CGRect(x: (cellView2.bounds.width*0.6)+1, y: (cellView.bounds.size.height*0.5)+1, width: (cellView2.bounds.width*0.4)-1, height: (cellView2.bounds.size.height*0.5)-1))
            coverImage9.layer.masksToBounds = true
            coverImage9.backgroundColor = UIColor.clear//navColor
            coverImage9.isHidden = true
            coverImage9.image = UIImage(named: "nophoto_diary_thumb_profile.png")
            cellView2.addSubview(coverImage9)
            
            //          coverImage4 = DiaryButtonViewWithGradient(frame: CGRect(x:0, 0, CGRectGetWidth(cellView.bounds)*0.5, cellView.bounds.size.height))
            coverImage10 = createButton(CGRect(x: 0, y: 0, width: cellView2.bounds.width*0.5, height: cellView2.bounds.size.height), title: "", border: false,bgColor: false, textColor: textColorLight)
            coverImage10.layer.masksToBounds = true
            coverImage10.backgroundColor = UIColor.clear//navColor
            coverImage10.isHidden = true
            coverImage10.setImage(UIImage(named: "nophoto_diary_thumb_profile.png"), for: UIControl.State())
            coverImage10.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.fill
            coverImage10.contentVerticalAlignment = UIControl.ContentVerticalAlignment.fill
            coverImage10.imageView?.contentMode = UIView.ContentMode.scaleAspectFill
            cellView2.addSubview(coverImage10)
            
            
            

            coverImage11 = createButton(CGRect(x: (cellView2.bounds.width*0.5)+1, y: 0, width: (cellView2.bounds.width*0.5)-1, height: cellView2.bounds.size.height), title: "", border: false,bgColor: false, textColor: textColorLight)
            coverImage11.layer.masksToBounds = true
            coverImage11.backgroundColor = UIColor.clear//navColor
            coverImage11.isHidden = true
            coverImage11.setImage(UIImage(named: "nophoto_diary_thumb_profile.png"), for: UIControl.State())
            coverImage11.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.fill
            coverImage11.contentVerticalAlignment = UIControl.ContentVerticalAlignment.fill
            coverImage11.imageView?.contentMode = UIView.ContentMode.scaleAspectFill
            coverImage11.layer.shadowColor = UIColor.black.cgColor
            coverImage11.layer.shadowOffset = CGSize(width: 20, height: 20)
            coverImage11.layer.shadowRadius = 20
            cellView2.addSubview(coverImage11)
            
            
            coverSelection2 = createButton(cellView2.frame, title: "", border: false,bgColor: false, textColor: textColorLight)
            coverSelection2.frame.size.height = (cellView2.frame.size.height)
            coverSelection2.backgroundColor = UIColor.clear
            coverSelection2.tintColor = UIColor.clear
            
            let GradientLayer3 = CAGradientLayer()
            GradientLayer3.frame = CGRect(x: coverSelection2.frame.origin.x,y: coverSelection2.frame.size.height-30, width: coverSelection2.frame.size.width, height: 30)
            let colors3: [CGColor] = [UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor,UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor,UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor,UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor,UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor,UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor,UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor]
            GradientLayer3.colors = colors3
            coverSelection2.layer.insertSublayer(GradientLayer3, above: coverSelection2.imageView?.layer)

            self.addSubview(coverSelection2)
            
            
            
            
            titleLabel2 = createLabel(CGRect(x: cellView2.frame.size.width+10, y: cellView2.frame.size.height-35, width: cellView2.frame.size.width-70, height: 30), text: "", alignment: .left, textColor: UIColor.white)
            titleLabel2.font = UIFont(name: fontName, size: FONTSIZELarge)
            titleLabel2.backgroundColor = UIColor.clear
            titleLabel2.lineBreakMode = NSLineBreakMode.byTruncatingTail
            self.addSubview(titleLabel2)
            
            countLabel2 = createLabel(CGRect(x: cellView.frame.size.width+cellView2.frame.size.width-70,y: 0,width: 50, height: 30), text: "", alignment: .left, textColor:UIColor.white)
            countLabel2.font = UIFont(name: fontName, size: FONTSIZESmall)
            countLabel2.backgroundColor = UIColor.clear
            countLabel2.textAlignment = NSTextAlignment.left
            self.addSubview(countLabel2)
            

            
  
        }


    }
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}
