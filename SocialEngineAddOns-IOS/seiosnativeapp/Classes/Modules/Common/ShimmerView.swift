//
//  ShimmerView.swift
//  seiosnativeapp
//
//  Created by bigstep_macbook_air on 8/6/19.
//  Copyright © 2019 bigstep. All rights reserved.
//

import Foundation
import UIKit

protocol Shimmerable {
    func start(count: Int) -> Void
    func stop() -> Void
    var lightColor: UIColor {get set}
    var darkColor: UIColor {get set}
    var isShimmering: Bool {get}
}

extension UIView: Shimmerable {
    
    private struct ShimmerProperties {
        static let shimmerKey:String = "io.monroy.shimmer.key"
        static var lightColor:CGColor = UIColor.white.withAlphaComponent(0.1).cgColor
        static var darkColor:CGColor = UIColor.black.withAlphaComponent(1).cgColor
        static var isShimmering:Bool = false
        static var gradient:CAGradientLayer = CAGradientLayer()
        static var animation:CABasicAnimation = CABasicAnimation(keyPath: "locations")
    }
    var lightColor: UIColor {
        get {
            return UIColor(cgColor: ShimmerProperties.lightColor)
        }
        set {
            ShimmerProperties.lightColor = newValue.cgColor
        }
    }
    var darkColor: UIColor {
        get {
            return UIColor(cgColor: ShimmerProperties.darkColor)
        }
        set {
            ShimmerProperties.darkColor = newValue.cgColor
        }
    }
    
    var isShimmering: Bool {
        get {
            return ShimmerProperties.isShimmering
        }
    }
    
    func stop() {
        guard ShimmerProperties.isShimmering else {return}
        self.layer.mask?.removeAnimation(forKey: ShimmerProperties.shimmerKey)
        self.layer.mask = nil
        ShimmerProperties.isShimmering = false
        self.layer.setNeedsDisplay()
    }
    
    func start(count: Int = 3) {
        guard !ShimmerProperties.isShimmering else {return}
        
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            self.stop()
        })
        
        ShimmerProperties.isShimmering = true
        
        ShimmerProperties.gradient.colors = [ShimmerProperties.darkColor, ShimmerProperties.lightColor, ShimmerProperties.darkColor];
        ShimmerProperties.gradient.frame = CGRect(x: CGFloat(-2*self.bounds.size.width), y: CGFloat(0.0), width: CGFloat(4*self.bounds.size.width), height: CGFloat(self.bounds.size.height))
        ShimmerProperties.gradient.startPoint = CGPoint(x: Double(0.0), y: Double(0.5));
        ShimmerProperties.gradient.endPoint = CGPoint(x: Double(1.0), y: Double(0.5));
        ShimmerProperties.gradient.locations = [0.4, 0.5, 0.6];
        
        ShimmerProperties.animation.duration = 1.0
        ShimmerProperties.animation.repeatCount =  .infinity
        ShimmerProperties.animation.fromValue = [0.0, 0.12, 0.3]
        ShimmerProperties.animation.toValue = [0.6, 0.86, 1.0]
        
        ShimmerProperties.gradient.add(ShimmerProperties.animation, forKey: ShimmerProperties.shimmerKey)
        self.layer.mask = ShimmerProperties.gradient;
        
        CATransaction.commit()
    }
}
