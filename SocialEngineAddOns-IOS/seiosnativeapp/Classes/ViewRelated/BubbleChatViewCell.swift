//
//  BubbleChatViewCell.swift
//  seiosnativeapp
//
//  Created by bigstep on 20/08/15.
//  Copyright (c) 2015 bigstep. All rights reserved.
//
import UIKit

class BubbleChatViewCell: UITableViewCell {
    
    override func drawRect(rect: CGRect) {
        var bubbleSpace = CGRectMake(20.0, self.bounds.origin.y, self.bounds.width - 20, self.bounds.height)
        let bubblePath1 = UIBezierPath(roundedRect: bubbleSpace, byRoundingCorners: .TopLeft | .TopRight | .BottomRight, cornerRadii: CGSize(width: 20.0, height: 20.0))
        
        let bubblePath = UIBezierPath(roundedRect: bubbleSpace, cornerRadius: 20.0)
        
        UIColor.greenColor().setStroke()
        UIColor.greenColor().setFill()
        bubblePath.stroke()
        bubblePath.fill()
        
        var triangleSpace = CGRectMake(0.0, self.bounds.height - 20, 20, 20.0)
        var trianglePath = UIBezierPath()
        var startPoint = CGPoint(x: 20.0, y: self.bounds.height - 40)
        var tipPoint = CGPoint(x: 0.0, y: self.bounds.height - 30)
        var endPoint = CGPoint(x: 20.0, y: self.bounds.height - 20)
        trianglePath.moveToPoint(startPoint)
        trianglePath.addLineToPoint(tipPoint)
        trianglePath.addLineToPoint(endPoint)
        trianglePath.closePath()
        UIColor.greenColor().setStroke()
        UIColor.greenColor().setFill()
        trianglePath.stroke()
        trianglePath.fill()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        var backgroundImage = UIImageView(image: UIImage(named: "star"))
//        backgroundImage.contentMode = UIViewContentMode.ScaleAspectFit
//        self.backgroundView = backgroundImage
    }
}