//
//  CouponDetailView.swift
//  seiosnativeapp
//
//  Created by Bigstep IOS on 8/12/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit

class CouponDetailView: UIView {
    
    var couponLabel:UILabel!
    var couponStartDateLabel:UILabel!
    var couponEndDateLabel:UILabel!
    var couponStartDate:UILabel!
    var couponEndDate:UILabel!
    var couponCode:UITextView!
    var couponDiscount:UILabel!
    var couponDescription:UILabel!
    var couponUsageLimit:UILabel!
    var couponImage: UIImageView!
    var doneButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame : frame)
        
        self.backgroundColor = UIColor.white
        self.isOpaque = false
        
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowOffset = shadowOffset
        self.layer.cornerRadius = 3
        
        couponImage = UIImageView(frame: CGRect(x:10, y:10, width:75, height:75))
        couponImage.layer.borderColor = UIColor.white.cgColor
        couponImage.layer.borderWidth = 2.5
        //couponImage.layer.cornerRadius = couponImage.frame.size.width / 2
        couponImage.backgroundColor = placeholderColor
        couponImage.contentMode = UIView.ContentMode.scaleAspectFill
        couponImage.layer.masksToBounds = true
        couponImage.image = UIImage(named: "user_profile_image.png")
        couponImage.tag = 321
        couponImage.isUserInteractionEnabled = true
        self.addSubview(couponImage)
        
        couponLabel = createLabel(CGRect(x:getRightEdgeX(inputView:couponImage) + 10, y:10, width:self.bounds.width - getRightEdgeX(inputView: couponImage) - 10, height:20), text: "Coupon Label", alignment: NSTextAlignment.left, textColor: textColorDark)
        couponLabel.font = UIFont(name: fontName, size:FONTSIZEMedium)
        self.addSubview(couponLabel)
        
        couponStartDateLabel = createLabel(CGRect(x:getRightEdgeX(inputView: couponImage) + 10, y:getBottomEdgeY(inputView: couponLabel) + 5, width:65, height:15), text: "Start Date", alignment: NSTextAlignment.left, textColor: textColorDark)
        couponStartDateLabel.font = UIFont(name: fontName, size:FONTSIZESmall)
        self.addSubview(couponStartDateLabel)
        
        couponEndDateLabel = createLabel(CGRect(x:getRightEdgeX(inputView: couponImage) + 10, y:getBottomEdgeY(inputView: couponStartDateLabel) + 5, width:65, height:15), text: "End Date", alignment: NSTextAlignment.left, textColor: textColorDark)
        couponEndDateLabel.font = UIFont(name: fontName, size:FONTSIZESmall)
        self.addSubview(couponEndDateLabel)
        
        couponStartDate = createLabel(CGRect(x:getRightEdgeX(inputView: couponStartDateLabel) + 5, y:getBottomEdgeY(inputView: couponLabel) + 5, width:self.bounds.width - getRightEdgeX(inputView: couponStartDateLabel) - 5, height:15), text: "Coupon Start Date", alignment: NSTextAlignment.center, textColor: textColorDark)
        couponStartDate.font = UIFont(name: fontName, size:FONTSIZESmall)
        self.addSubview(couponStartDate)
        
        couponEndDate = createLabel(CGRect(x:getRightEdgeX(inputView: couponEndDateLabel) + 5, y:getBottomEdgeY(inputView:couponStartDateLabel) + 5, width:self.bounds.width - getRightEdgeX(inputView: couponEndDateLabel) - 5, height:15), text: "Coupon End Date", alignment: NSTextAlignment.center, textColor: textColorDark)
        couponEndDate.font = UIFont(name: fontName, size:FONTSIZESmall)
        self.addSubview(couponEndDate)
        
        //        couponCode = createLabel(CGRect(x:0, couponEndDate.frame.origin.y + CGRectGetHeight(couponEndDate.bounds) + 5, self.bounds.width, 30), text: "Coupon Code", alignment: NSTextAlignment.center, textColor: textColorLight)
        //        couponCode.font = UIFont(name: "FontAwesome", size:FONTSIZESmall)
        //        couponCode.backgroundColor = UIColor.black
        //        self.addSubview(couponCode)
        
        couponUsageLimit = createLabel(CGRect(x:getRightEdgeX(inputView: couponImage) + 10, y:getBottomEdgeY(inputView:couponEndDateLabel) + 5, width:self.bounds.width - getRightEdgeX(inputView: couponImage) - 10, height:30), text: "", alignment: NSTextAlignment.left, textColor: textColorDark)
        couponUsageLimit.font = UIFont(name: fontName, size:FONTSIZESmall)
        self.addSubview(couponUsageLimit)
        
        couponCode = createTextView(CGRect(x:20, y:getBottomEdgeY(inputView:couponUsageLimit) + 5, width:self.bounds.width - 40, height:30), borderColor: UIColor.clear, corner: true)
        couponCode.font = UIFont(name: fontBold, size:FONTSIZEMedium)
        couponCode.textAlignment = NSTextAlignment.center
        couponCode.textColor = UIColor.white
        couponCode.backgroundColor = UIColor.black
        couponCode.isEditable = false
        self.addSubview(couponCode)
        
        couponDescription = createLabel(CGRect(x:10, y:getBottomEdgeY(inputView:couponCode) + 10, width:self.bounds.width - 20, height:30), text: "Coupon Description", alignment: NSTextAlignment.center, textColor: textColorDark)
        couponDescription.font = UIFont(name: fontName, size:FONTSIZESmall)
        self.addSubview(couponDescription)
        
        couponDiscount = createLabel(CGRect(x:0, y:couponCode.frame.origin.y + couponCode.bounds.height + 5, width:self.bounds.width, height:30), text: "Coupon Discount", alignment: NSTextAlignment.center, textColor: textColorLight)
        couponDiscount.font = UIFont(name: fontName, size:FONTSIZESmall)
        couponDiscount.backgroundColor = UIColor.red
        couponDiscount.isHidden = true
        self.addSubview(couponDiscount)
        
        
        doneButton = createButton(CGRect(x:self.bounds.width - 20, y:5, width:15, height:15), title: "", border: false, bgColor: false, textColor: textColorDark)
        doneButton.setImage(UIImage(named:"cross.png"), for: UIControl.State.normal)
        self.addSubview(doneButton)
        
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
