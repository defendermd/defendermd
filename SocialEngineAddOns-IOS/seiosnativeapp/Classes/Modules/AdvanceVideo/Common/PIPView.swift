//
//  PIPView.swift
//  seiosnativeapp
//
//  Created by bigstep_macbook_air on 9/3/19.
//  Copyright © 2019 bigstep. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer
class PIPView: UIView {
    var keyWindows: UIWindow?
    var currentVC: UIViewController?
    var videoUrl: String?
    var isWebView: Bool?
    var cancelButton : UIButton = {
        let button = UIButton()
        let originalImage = UIImage(named: "cross")
        let tintedImage =  originalImage?.withRenderingMode(.alwaysTemplate)
        button.setImage(tintedImage, for: .normal)
        button.tintColor = .white
        return button
    }()
    
    var maximizeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "maximize_icon"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    var playerLayer: AVPlayerLayer?
    init(frame: CGRect, playerLayer: AVPlayerLayer, url: String, isWebview: Bool = false, view: UIView = UIView()) {
        super.init(frame: frame)
        if let keyWindow = UIApplication.shared.keyWindow {
            self.keyWindows = keyWindow
        }
        self.backgroundColor = .black
        self.isWebView = isWebview
        self.videoUrl = url
        if !self.isWebView! {
            self.playerLayer = playerLayer
            self.playerLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill
            self.layer.addSublayer(playerLayer)
            self.playerLayer!.frame = CGRect(x: 0, y: 0, width: pipModeSize.width, height: pipModeSize.height)
            self.layer.masksToBounds = true
        }
        else {
            self.addSubview(view)
        }
        initGesture()
        setViews()
        self.isHidden = true
        openPIPWithAnimation()
    }
    
    func initGesture() {
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(movePIPView))
        self.addGestureRecognizer(gestureRecognizer)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        resizePipViewWithAnimation()
    }
    
    func resizePipViewWithAnimation() {
        UIView.animate(withDuration: 0.5, delay: 0.5, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.center = (self.keyWindows?.center)!
        }) { (_) in
            pipModeSize = CGSize(width: pipModeSize.width + 50, height: pipModeSize.height + 50)
            self.frame.size = CGSize(width: pipModeSize.width , height: pipModeSize.height)
            self.playerLayer?.frame = CGRect(x: 0, y: 0, width: pipModeSize.width, height: pipModeSize.height)
            self.cancelButton.frame = CGRect(x: self.frame.size.width - 30, y: 3, width: 20, height: 20)
            self.maximizeButton.frame = CGRect(x: 5, y: 3, width: 20, height: 20)
            self.cancelButton.isHidden = false
            self.maximizeButton.isHidden = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                pipModeSize = CGSize(width: pipModeSize.width - 50, height: pipModeSize.height - 50)
                self.frame.size = CGSize(width: pipModeSize.width , height: pipModeSize.height)
                self.playerLayer?.frame = CGRect(x: 0, y: 0, width: pipModeSize.width, height: pipModeSize.height)
                self.cancelButton.isHidden = true
                self.maximizeButton.isHidden = true
            }
        }
    }
    
    func setViews() {
        cancelButton.frame = CGRect(x: self.frame.size.width - 25, y: 2, width: 15, height: 15)
        self.addSubview(cancelButton)
        cancelButton.isHidden = true
        self.bringSubviewToFront(cancelButton)
        cancelButton.addTarget(self, action: #selector(PIPView.removePIPView), for: .touchUpInside)
        
        maximizeButton.frame = CGRect(x: 2, y: 2, width: 20, height: 20)
        self.addSubview(maximizeButton)
        maximizeButton.isHidden = true
        self.bringSubviewToFront(maximizeButton)
        maximizeButton.addTarget(self, action: #selector(PIPView.maximizePlayer), for: .touchUpInside)
    }
    
    func openPIPWithAnimation() {
        
        UIView.animate(withDuration: 0.5, delay: 0.5, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.isHidden = false
            self.frame = CGRect(x: UIScreen.main.bounds.width - pipModeSize.width - 10, y: UIScreen.main.bounds.height - pipModeSize.height - 10, width: pipModeSize.width, height: pipModeSize.height)
            if !self.isWebView! {
                self.playerLayer!.frame = CGRect(x: 0, y: 0, width: pipModeSize.width, height: pipModeSize.height)
            }
        }) { (_) in
        }
    }
    
    @objc func maximizePlayer() {
        let launcher = VideoLauncher()
        launcher.videoUrl = self.videoUrl!
        launcher.playerFrame = self.keyWindows?.frame
        launcher.showVideoPlayer()
        self.removePIPView()
    }
    
    @objc func movePIPView(gesture: UIPanGestureRecognizer) {
        let panTranslation = gesture.translation(in:self.keyWindows!)
        let velocity = gesture.velocity(in: self)
        if gesture.state == .ended{
            // animate to desired position after user ends the gesture
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.4, options: UIView.AnimationOptions.curveEaseOut, animations: {
                self.frame.origin = self.findRepositionPoint()
            }, completion: nil)
        }
        if gesture.state == .changed{
            if abs(velocity.x) > abs(velocity.y) {
                // removePIPView()
            }
            // position the view accordingly
            self.center = CGPoint(x: self.center.x + panTranslation.x, y: self.center.y + panTranslation.y)
        }
        gesture.setTranslation(CGPoint.zero, in: keyWindows!)
        
    }
    @objc func removePIPView() {
        self.removeFromSuperview()
        self.playerLayer?.removeFromSuperlayer()
    }
    
    func findRepositionPoint() -> CGPoint {
        var point = CGPoint.zero
        let x = self.frame.origin.x
        let y = self.frame.origin.y
        if x < 10 && getBottomEdgeY(inputView: self) > (keyWindows!.frame.size.height - 10){
            point.x = 10
            point.y = keyWindows!.frame.size.height - pipModeSize.height - 10
        }
        else if getRightEdgeX(inputView: self) > (keyWindows!.frame.size.width - 10) && getBottomEdgeY(inputView: self) > (keyWindows!.frame.size.height - 10) {
            point.x = keyWindows!.frame.size.width - pipModeSize.width - 10
            point.y = keyWindows!.frame.size.height - pipModeSize.height - 10
        }
        else if getBottomEdgeY(inputView: self) > (keyWindows!.frame.size.height - 10) && (x >= 10 && x < getRightEdgeX(inputView: self) - 10) {
            point.x = self.frame.origin.x
            point.y = keyWindows!.frame.size.height - pipModeSize.height - 10
        }
        else if x < 10 && y < 10 {
            point.x = 10
            point.y = 45
        }
        else if getRightEdgeX(inputView: self) > (keyWindows!.frame.size.width - 10) && y < 10 {
            point.x = keyWindows!.frame.size.width - pipModeSize.width - 10
            point.y = 45
        }
        else if (x >= 10 && getRightEdgeX(inputView: self) <= (keyWindows!.frame.size.width - 10)) && y < 10 {
            point.x = x
            point.y = 45
        }
        else if x < 10 && (y > 10   && getBottomEdgeY(inputView: self) < (keyWindows!.frame.size.height - 10)) {
            point.x = 10
            point.y = y
        }
        else if getRightEdgeX(inputView: self) > (keyWindows!.frame.size.width - 10) && (y > 10   && getBottomEdgeY(inputView: self) < (keyWindows!.frame.size.height - 10)) {
            point.x = keyWindows!.frame.size.width - pipModeSize.width - 10
            point.y = y
        }
        else {
            point.x = x
            point.y = y
        }
        return point
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
