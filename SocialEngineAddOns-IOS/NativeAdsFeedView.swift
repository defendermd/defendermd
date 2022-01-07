//
//  NativeAdsFeedView.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 15/07/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit

class NativeAdsFeedView: UIView
{
    
    

    var iconView:UIImageView!
    var headlineView:TTTAttributedLabel!
    var bodyView:TTTAttributedLabel!
    var Adimageview:UIImageView!
    var callToActionView:UIButton!
    
 
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addCustomView()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   func addCustomView()
   {
            iconView = createImageView(CGRectMake(5, 5, 40, 40), border: true)
            iconView.image = UIImage(named: "user_profile_image.png")
            self.addSubview(iconView)
    
            headlineView = TTTAttributedLabel(frame:CGRectMake(CGRectGetWidth(iconView.bounds) + 10 , 5, CGRectGetWidth(self.bounds)-(CGRectGetWidth(iconView.bounds) + 55), 30))
            headlineView.numberOfLines = 0
            headlineView.textColor = textColorDark
            headlineView.font = UIFont(name: fontName, size: FONTSIZENormal)
            self.addSubview(headlineView)
    
    
            bodyView = TTTAttributedLabel(frame:CGRectMake(10 , CGRectGetHeight(iconView.bounds) + 5 + iconView.frame.origin.y, CGRectGetWidth(self.bounds)-15, 40))
            bodyView.numberOfLines = 0
            bodyView.textColor = textColorDark
            bodyView.font = UIFont(name: fontName, size: FONTSIZENormal)
            bodyView.hidden = false
            self.addSubview(bodyView)
    
    
            Adimageview = createImageView(CGRectMake(10 , CGRectGetHeight(bodyView.bounds) + 5 + bodyView.frame.origin.y, CGRectGetWidth(self.bounds)-20, 150), border: true)
            self.addSubview(Adimageview)
    
    
            callToActionView = createButton(CGRectMake(10,CGRectGetHeight(Adimageview.bounds) + 5 + Adimageview.frame.origin.y, 80, 30), title: "", border: false, bgColor: false, textColor: textColorLight)
            callToActionView.titleLabel?.font = UIFont(name: fontBold , size: FONTSIZESmall)
            callToActionView.titleLabel?.textColor = textColorMedium
            callToActionView.backgroundColor = UIColor.greenColor()
            self.addSubview(callToActionView)

    
   }

}
