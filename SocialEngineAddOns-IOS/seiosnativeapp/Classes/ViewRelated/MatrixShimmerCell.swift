//
//  MatrixShimmerCell.swift
//  seiosnativeapp
//
//  Created by bigstep_macbook_air on 7/4/19.
//  Copyright © 2019 bigstep. All rights reserved.
//

import Foundation
import UIKit
class MatrixShimmerCell : UICollectionViewCell {
    let textColorshimmer = UIColor(red: 227/255.0, green: 227/255.0, blue: 227/255.0, alpha: 1.0)
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
    
    
    var firendButtonView : UIView = {
        let icon = UIView()
        return icon
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        cellView = createView(CGRect(x: 0, y: 0,width: self.frame.size.width ,height: 200), borderColor: borderColorLight, shadow: true)
        cellView.layer.shadowColor = shadowColor.cgColor
        cellView.layer.shadowOpacity = shadowOpacity
        cellView.layer.shadowRadius = shadowRadius
        cellView.layer.shadowOffset = shadowOffset
        self.addSubview(cellView)
        
        shimmeringView = FBShimmeringView.init(frame: CGRect(x: 0, y: 0,width: self.frame.size.width ,height: 200))
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
        cellView.addSubview(firendButtonView)
        
        normalImage.frame = CGRect(x: 0, y: 30, width: 50, height: 50)
        normalImage.layer.cornerRadius = 25
        normalImage.frame.origin.x = (self.frame.size.width - 50)/2
        normalImage.backgroundColor = textColorshimmer
        
        normalName.frame = CGRect(x: 10 , y:getBottomEdgeY(inputView: normalImage) + 25, width: self.frame.size.width - 20, height: 8)
        normalName.backgroundColor = textColorshimmer
        
        locationName.frame = CGRect(x: 10, y: getBottomEdgeY(inputView: normalName) + 5, width: self.frame.size.width - 20, height: 8)
        locationName.backgroundColor = textColorshimmer
        
        firendButtonView.frame = CGRect(x: 20, y: getBottomEdgeY(inputView: locationName) + 5, width: self.frame.size.width - 40, height: 8)
        firendButtonView.backgroundColor = textColorshimmer
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

