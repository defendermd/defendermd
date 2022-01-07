//
//  DiaryTableViewCell.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 29/01/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit

class WishlistTableViewCell: UITableViewCell
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
    
    var moreOptions:UIButton!
    
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
    
    var moreOptions2:UIButton!
    
    
    
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
            cellView = createView( CGRect(x: 0, y: contentPADING,width: (UIScreen.main.bounds.width) , height: 200), borderColor: borderColorMedium, shadow: false)
        }
        else
        {
            cellView = createView( CGRect(x: 0, y: 0,width: (UIScreen.main.bounds.width) , height: 200), borderColor: borderColorMedium, shadow: false)
        }
        cellView.layer.borderWidth = 0.0
        cellView.isUserInteractionEnabled = true
        cellView.backgroundColor = UIColor.clear
        self.addSubview(cellView)
        
//        countLabel = createLabel(CGRect(x: (UIScreen.main.bounds.width)-30,y: 0,width: 30, height: 30), text: "", alignment: .left, textColor:UIColor.white)
//        countLabel.font = UIFont(name: fontName, size: 16)
//        countLabel.backgroundColor = UIColor.black
//        countLabel.textAlignment = NSTextAlignment.center
//        countLabel.isHidden = true
//        self.addSubview(countLabel)
        

        
        
        titleView = createView( CGRect(x: 0, y: cellView.frame.size.height - 30, width: (UIScreen.main.bounds.width), height: 30), borderColor: borderColorMedium, shadow: false)
        titleView.layer.borderWidth = 0.0
        titleView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        self.addSubview(titleView)
        
        titleLabel = createLabel(CGRect(x: 10, y: 0, width: (UIScreen.main.bounds).width - 70, height: 30), text: "", alignment: .left, textColor: UIColor.white)
        titleLabel.font = UIFont(name: fontName, size: FONTSIZELarge)
        titleLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
        titleView.addSubview(titleLabel)
        
        lineView = UIView(frame: CGRect(x: 0,y: cellView.frame.size.height,width: (UIScreen.main.bounds).width,height: 2))
        lineView.backgroundColor = UIColor.white
        lineView.isHidden = false
        self.addSubview(lineView)
        
        
        coverImage = WishlistImageViewWithGradient(frame: CGRect(x: 0, y: 0, width: cellView.bounds.width, height: cellView.bounds.size.height))
        coverImage.layer.masksToBounds = true
        coverImage.backgroundColor = UIColor.clear//navColor
        coverImage.image = UIImage(named: "nophoto_diary_thumb_profile.png")
        coverImage.contentMode = .scaleAspectFit
        cellView.addSubview(coverImage)
        
        coverImage1 = WishlistImageViewWithGradient(frame: CGRect(x: 0, y: 0, width: cellView.bounds.width*0.6, height: cellView.bounds.size.height))
        coverImage1.layer.masksToBounds = true
        coverImage1.backgroundColor = UIColor.clear//navColor
        coverImage1.isHidden = true
        coverImage1.image = UIImage(named: "nophoto_diary_thumb_profile.png")
        cellView.addSubview(coverImage1)
        
        coverImage2 = WishlistImageViewWithGradient(frame: CGRect(x: (cellView.bounds.width*0.6)+1, y: 0, width: (cellView.bounds.width*0.4)-1, height: cellView.bounds.size.height*0.5))
        coverImage2.layer.masksToBounds = true
        coverImage2.isHidden = true
        coverImage2.backgroundColor = UIColor.clear//navColor
        coverImage2.image = UIImage(named: "nophoto_diary_thumb_profile.png")
        cellView.addSubview(coverImage2)
        
        
        coverImage3 = WishlistImageViewWithGradient(frame: CGRect(x: (cellView.bounds.width*0.6)+1, y: (cellView.bounds.size.height*0.5)+1, width: (cellView.bounds.width*0.4)-1, height: (cellView.bounds.size.height*0.5)-1))
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
        
        coverImage5 = createButton(CGRect(x: (cellView.bounds.width*0.5) + 1, y: 0, width: (cellView.bounds.width*0.5) - 1, height: cellView.bounds.size.height), title: "", border: false,bgColor: false, textColor: textColorLight)
        coverImage5.layer.masksToBounds = true
        coverImage5.backgroundColor = UIColor.clear//navColor
        coverImage5.isHidden = true
     //   coverImage5.setImage(UIImage(named: "nophoto_diary_thumb_profile.png"), for: UIControl.State())
        coverImage5.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.fill
        coverImage5.contentVerticalAlignment = UIControl.ContentVerticalAlignment.fill
        coverImage5.imageView?.contentMode = UIView.ContentMode.scaleAspectFill
        cellView.addSubview(coverImage5)
        
        coverSelection = createButton(cellView.frame, title: "", border: false,bgColor: false, textColor: textColorLight)
        coverSelection.frame.size.height = (cellView.frame.size.height)
        coverSelection.backgroundColor = UIColor.clear
        coverSelection.tintColor = UIColor.clear
        self.addSubview(coverSelection)
        
        let GradientLayer = CAGradientLayer()
        GradientLayer.frame = CGRect(x: coverSelection.frame.origin.x,y: coverSelection.frame.size.height-30, width: coverSelection.frame.size.width, height: 30)
        let colors: [CGColor] = [UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor,UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor,UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor,UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor,UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor,UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor,UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor]
        
        GradientLayer.colors = colors
        coverSelection.layer.insertSublayer(GradientLayer, above: coverSelection.imageView?.layer)
        self.addSubview(coverSelection)
        
        countLabel = createLabel(CGRect( x: coverSelection.bounds.width - 65, y: coverSelection.bounds.height - 30, width: 55, height: 30), text: "", alignment: .left, textColor:UIColor.white)
        countLabel.font = UIFont(name: fontName, size: FONTSIZESmall)
        countLabel.backgroundColor = UIColor.clear
        countLabel.textAlignment = NSTextAlignment.center
        coverSelection.addSubview(countLabel)
        
//        moreOptions = createButton(CGRect( x: coverSelection.bounds.width - 35, y: coverSelection.bounds.height - 30, width: 30, height: 30), title: "\(likeIcon)", border: false, bgColor: false, textColor: textColorLight)
//        moreOptions.backgroundColor = UIColor.clear
//        moreOptions.titleLabel?.font = UIFont(name: "fontAwesome", size: FONTSIZELarge)
//        coverSelection.addSubview(moreOptions)
        
        moreOptions = createButton(CGRect(x: (UIScreen.main.bounds.width)-25,y: 0,width: 25, height: 25), title: "\(likeIcon)", border: false, bgColor: false, textColor: textColorLight)
        moreOptions.backgroundColor = UIColor.black
        moreOptions.titleLabel?.font = UIFont(name: "fontAwesome", size: FONTSIZELarge)
        coverSelection.addSubview(moreOptions)
        
        
        
    }
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}
