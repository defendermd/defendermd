//
//  MemberShimmeringTableCell.swift
//  seiosnativeapp
//
//  Created by bigstep_macbook_air on 7/3/19.
//  Copyright © 2019 bigstep. All rights reserved.
//

import Foundation
import UIKit

class MemberShimmeringTableCell: UITableViewCell {
    let textColorshimmer = UIColor(red: 227/255.0, green: 227/255.0, blue: 227/255.0, alpha: 1.0)
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    var cellView:UIView!
    var shimmeringView: FBShimmeringView!
    var normalImage : UIView = {
        let view = UIView()
        return view
    }()
    
    var normalName : UIView = {
        let name = UIView()
        return name
    }()

    
    var locationName : UIView = {
        let name = UIView()
        return name
    }()
    
   
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = aafBgColor
        cellView = createView(CGRect(x: 0, y: 0,width: UIScreen.main.bounds.width ,height: 90), borderColor: borderColorLight, shadow: true)
        cellView.layer.shadowColor = shadowColor.cgColor
        cellView.layer.shadowOpacity = shadowOpacity
        cellView.layer.shadowRadius = shadowRadius
        cellView.layer.shadowOffset = shadowOffset
        self.addSubview(cellView)
        
        shimmeringView = FBShimmeringView.init(frame: CGRect(x: 0, y: 0,width: cellView.frame.size.width ,height: 90))
        shimmeringView.backgroundColor = UIColor.white
        shimmeringView.contentView = cellView
        shimmeringView.isShimmering = true
        
        shimmeringView.shimmeringPauseDuration = 0.4
        shimmeringView.shimmeringAnimationOpacity = 0.5
        shimmeringView.shimmeringOpacity = 1.0
        shimmeringView.shimmeringSpeed = 230
        shimmeringView.shimmeringHighlightLength = 0.33
        shimmeringView.shimmeringDirection = FBShimmerDirection.right
        shimmeringView.shimmeringBeginFadeDuration = 0.6
        shimmeringView.shimmeringEndFadeDuration = 1.0
        self.addSubview(shimmeringView)
        
        cellView.addSubview(normalImage)
        cellView.addSubview(normalName)
        cellView.addSubview(locationName)
        normalImage.backgroundColor = textColorshimmer
        normalName.backgroundColor = textColorshimmer
        locationName.backgroundColor = textColorshimmer
        
        normalImage.frame = CGRect(x: 5, y: 25, width: 40, height: 40)
        normalImage.layer.cornerRadius = 20
        
        normalName.frame = CGRect(x: normalImage.bounds.width + 30 , y: 30, width: 250, height: 5)
        
        locationName.frame = CGRect(x: normalImage.bounds.width + 30, y: 45, width: 250, height: 5)
      
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
 func setupShimmeringImage(view : UIView, subView: UIView) {
    
    let gradientLayer = CAGradientLayer()
    gradientLayer.colors = [
        UIColor.clear.cgColor, UIColor.clear.cgColor,
        UIColor.black.cgColor, UIColor.black.cgColor,
        UIColor.clear.cgColor, UIColor.clear.cgColor
    ]
    
    gradientLayer.locations = [0, 0.2, 0.4, 0.6, 0.8, 1]
    
    let angle = -60 * CGFloat.pi / 180
    let rotationTransform = CATransform3DMakeRotation(angle, 0, 0, 1)
    gradientLayer.transform = rotationTransform
    view.layer.addSublayer(gradientLayer)
    gradientLayer.frame = subView.frame
    
    subView.layer.mask = gradientLayer
    
    
    gradientLayer.transform = CATransform3DConcat(gradientLayer.transform, CATransform3DMakeScale(3, 3, 0))
    
    let animation = CABasicAnimation(keyPath: "transform.translation.x")
    animation.duration = 2
    animation.repeatCount = Float.infinity
    animation.autoreverses = false
    animation.fromValue = -3.0 * view.frame.width
    animation.toValue = 3.0 * view.frame.width
    animation.isRemovedOnCompletion = false
    animation.fillMode = CAMediaTimingFillMode.forwards
    gradientLayer.add(animation, forKey: "shimmerKey")
}



