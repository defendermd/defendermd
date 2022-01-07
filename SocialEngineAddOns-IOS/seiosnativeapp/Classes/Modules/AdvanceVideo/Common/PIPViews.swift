//
//  PIPViews.swift
//  seiosnativeapp
//
//  Created by bigstep_macbook_air on 9/16/19.
//  Copyright © 2019 bigstep. All rights reserved.
//

import Foundation
import UIKit
import AVKit
var isVideoPlayingInPIP = false
class PIPViews: UIView {
    var isPlaying: Bool = false
    var cancelButton : UIButton = {
        let button = UIButton()
        let originalImage = UIImage(named: "cross")
        let tintedImage =  originalImage?.withRenderingMode(.alwaysTemplate)
        button.setImage(tintedImage, for: .normal)
        button.tintColor = .white
        return button
    }()
    
    /// button to enter the full screen
    var maximizeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "fullScreenIcon"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    var playPauseButton: UIButton = {
        let button = UIButton()
        let originalImage = UIImage(named: "pause")
        let tintedImage =  originalImage?.withRenderingMode(.alwaysTemplate)
        button.setImage(tintedImage, for: .normal)
        button.tintColor = .white
        button.isHidden = true
        button.addTarget(self, action: #selector(handlePause), for: .touchUpInside)
        return button
    }()
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var parentVC: UIViewController?
    var currentTime: CMTime?
    init(frame: CGRect, videoPlayer: AVPlayer, parentViewController: UIViewController, currentTimeStamp: CMTime) {
        super.init(frame: frame)
        self.frame = frame
        self.tag = 9999
        self.player = videoPlayer
        self.parentVC = parentViewController
        self.backgroundColor = .black
        self.currentTime = currentTimeStamp
        initPlayer()
        initSubViews()
        initGesture()
        
    }
    
    func initPlayer() {
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        self.playerLayer = AVPlayerLayer(player: self.player)
        self.layer.addSublayer(self.playerLayer!)
        self.playerLayer!.frame = CGRect(x: 0, y: 0, width: pipModeSize.width, height: pipModeSize.height)
        playerLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.player?.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)
        
    }
    
    /// will open the pip mode screen and set at the bottom of the screen
    func openPIPWithAnimation() {
        UIView.animate(withDuration: 0.5, delay: 0.5, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.isHidden = false
            self.frame = CGRect(x: UIScreen.main.bounds.width - pipModeSize.width - 10, y: UIScreen.main.bounds.height - pipModeSize.height - 10, width: pipModeSize.width, height: pipModeSize.height)
            self.playerLayer!.frame = CGRect(x: 0, y: 0, width: pipModeSize.width, height: pipModeSize.height)
            
        }) { (_) in
            if let player = self.player {
                player.currentItem?.seek(to: self.currentTime!)
                player.play()
            }
        }
    }
    
    
    /// set subviews for pipview
    func initSubViews() {
        cancelButton.frame = CGRect(x: self.frame.size.width - 25, y: 8, width: 15, height: 15)
        self.addSubview(cancelButton)
        cancelButton.isHidden = true
        self.bringSubviewToFront(cancelButton)
        cancelButton.addTarget(self, action: #selector(PIPViews.removePIPView), for: .touchUpInside)
        
        maximizeButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        maximizeButton.center = self.center
        self.addSubview(maximizeButton)
        maximizeButton.isHidden = true
        self.bringSubviewToFront(maximizeButton)
        maximizeButton.addTarget(self, action: #selector(PIPViews.maximizePlayer), for: .touchUpInside)
        
        playPauseButton.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        playPauseButton.isHidden = true
        self.addSubview(playPauseButton)
    }
    
    
    /// remove pip view from anywhere in the app
    @objc func removePIPView() {
        pipModeSize = CGSize(width: UIScreen.main.bounds.width/2, height: UIScreen.main.bounds.width/3 - 10)
        isVideoPlayingInPIP = false
        self.player = nil
        self.playerLayer?.removeFromSuperlayer()
        DispatchQueue.main.async {
            self.removeFromSuperview()
        }
        
        // it is used to get the current view controller which is visible at the particular time
        let topMostViewController = UIApplication.shared.topMostViewController()
        if topMostViewController is AdvanceActivityFeedViewController {
            // if the current controller is AdvanceActivityFeedViewController then ebable video autoplay
            if let vc = topMostViewController as? AdvanceActivityFeedViewController {
                vc.enableDisableVideoAutoPlay()
                vc.feedObj.tableView.reloadData()
            }
        }
        
    }
    
    /// maximize the pipview
    @objc func maximizePlayer() {
        pipModeSize = CGSize(width: UIScreen.main.bounds.width/2, height: UIScreen.main.bounds.width/3 - 10)
        if (self.player?.observationInfo != nil) {
            
            self.player?.removeObserver(self, forKeyPath: "currentItem.loadedTimeRanges")
            
        }
        NotificationCenter.default.removeObserver(self)
        self.removePIPView()
        if let vc = self.parentVC as? CustomVideoPlayerViewController {
            if let topController = UIApplication.topViewController() {
                topController.present(vc, animated: true) {
                    if let player = self.player {
                        vc.player = player
                    }
                    vc.pipButton.frame = CGRect(x: 0, y: UIApplication.shared.statusBarFrame.height + 20, width: 20, height: 20)
                    vc.pipButton.center.x = keywindows!.center.x
                    vc.view.addSubview(vc.pipButton)
                    vc.view.bringSubviewToFront(vc.pipButton)
                    vc.pipButton.addTarget(vc, action: #selector(CustomVideoPlayerViewController.showPIP), for: .touchUpInside)
                }
                
            }
        }
        else {
            if let topController = UIApplication.topViewController() {
                let nativationController = UINavigationController(rootViewController: self.parentVC!)
                topController.present(nativationController, animated:true, completion: nil)
            }
            
        }
    }
    
    /// initialize gesture to move the pipview
    func initGesture() {
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(movePIPView))
        self.addGestureRecognizer(gestureRecognizer)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.addGestureRecognizer(tap)
    }
    
    /// calls when tap on pip view
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        resizePipViewWithAnimation()
    }
    
    /// move the pip mode view with in the screen
    @objc func movePIPView(gesture: UIPanGestureRecognizer) {
        let panTranslation = gesture.translation(in:keywindows)
        if let view = gesture.view {
            view.center = CGPoint(x:view.center.x + panTranslation.x,
                                  y:view.center.y + panTranslation.y)
        }
        gesture.setTranslation(CGPoint.zero, in: keywindows)
        if gesture.state == .ended{
            let velocity = gesture.velocity(in: keywindows)
            let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
            let slideMultiplier = magnitude / 300
            let slideFactor = 0.01 * slideMultiplier     //Increase for more of a slide
            var finalPoint = CGPoint(x:gesture.view!.center.x + (velocity.x * slideFactor),
                                     y:gesture.view!.center.y + (velocity.y * slideFactor))
            
            UIView.animate(withDuration: Double(slideFactor * 1),
                           delay: 0,
                           // 6
                options: UIView.AnimationOptions.curveEaseOut,
                animations: {gesture.view!.center = finalPoint },
                completion: {(true) in
                    if magnitude > 1000 {
                        self.outOfSuperviewBounds()
                    }
                    else {
                        //animate to desired position after user ends the gesture
                        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.4, options: UIView.AnimationOptions.curveEaseOut, animations: {
                            self.frame.origin = self.findRepositionPoint()
                        }, completion: nil)
                    }
                    
            })
            
        }
        gesture.setTranslation(CGPoint.zero, in: keywindows)
        
    }
    
    /// check if pipview is completely outside the superview
    func outOfSuperviewBounds() {
        if self.frame.origin.x < 20 || self.frame.origin.y < 0 || getRightEdgeX(inputView: self) > keywindows!.frame.size.width + 20 || getBottomEdgeY(inputView: self) > keywindows!.frame.size.height + 20 {
            self.removePIPView()
        }
        else {
            //animate to desired position after user ends the gesture
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.4, options: UIView.AnimationOptions.curveEaseOut, animations: {
                self.frame.origin = self.findRepositionPoint()
            }, completion: nil)
        }
        
    }
    
    /// find out the reposition point when pipview is dragged outside its parentview
    ///
    /// - Returns: returns the point to set the pipview
    func findRepositionPoint() -> CGPoint {
        var point = CGPoint.zero
        let x = self.frame.origin.x
        let y = self.frame.origin.y
        if x < 10 && getBottomEdgeY(inputView: self) > (keywindows!.frame.size.height - 10){
            point.x = 10
            point.y = keywindows!.frame.size.height - pipModeSize.height - 10
        }
        else if getRightEdgeX(inputView: self) > (keywindows!.frame.size.width - 10) && getBottomEdgeY(inputView: self) > (keywindows!.frame.size.height - 10) {
            point.x = keywindows!.frame.size.width - pipModeSize.width - 10
            point.y = keywindows!.frame.size.height - pipModeSize.height - 10
        }
        else if getBottomEdgeY(inputView: self) > (keywindows!.frame.size.height - 10) && (x >= 10 && x < getRightEdgeX(inputView: self) - 10) {
            point.x = self.frame.origin.x
            point.y = keywindows!.frame.size.height - pipModeSize.height - 10
        }
        else if x < 10 && y < 10 {
            point.x = 10
            point.y = 45
        }
        else if getRightEdgeX(inputView: self) > (keywindows!.frame.size.width - 10) && y < 10 {
            point.x = keywindows!.frame.size.width - pipModeSize.width - 10
            point.y = 45
        }
        else if (x >= 10 && getRightEdgeX(inputView: self) <= (keywindows!.frame.size.width - 10)) && y < 10 {
            point.x = x
            point.y = 45
        }
        else if x < 10 && (y > 10   && getBottomEdgeY(inputView: self) < (keywindows!.frame.size.height - 10)) {
            point.x = 10
            point.y = y
        }
        else if getRightEdgeX(inputView: self) > (keywindows!.frame.size.width - 10) && (y > 10   && getBottomEdgeY(inputView: self) < (keywindows!.frame.size.height - 10)) {
            point.x = keywindows!.frame.size.width - pipModeSize.width - 10
            point.y = y
        }
        else {
            point.x = x
            point.y = y
        }
        return point
    }
    
    /// resize pip view and displays the buttons when tap
    func resizePipViewWithAnimation() {
        UIView.animate(withDuration: 0.5, delay: 0.5, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.center = keywindows!.center
        }) { (_) in
            if pipModeSize.width == UIScreen.main.bounds.width/2 {
                pipModeSize = CGSize(width: pipModeSize.width + 50, height: pipModeSize.height + 50)
            }
            self.frame.size = CGSize(width: pipModeSize.width , height: pipModeSize.height)
            self.playerLayer?.frame = CGRect(x: 0, y: 0, width: pipModeSize.width, height: pipModeSize.height)
            self.center = (keywindows?.center)!
            self.cancelButton.frame = CGRect(x: self.frame.size.width - 30, y: 8, width: 20, height: 20)
            self.maximizeButton.frame = CGRect(x: (self.frame.size.width - 30)/2, y: (self.frame.size.height - 30)/2, width: 30, height: 30)
            self.cancelButton.isHidden = false
            self.playPauseButton.isHidden = false
            self.maximizeButton.isHidden = false
            self.playPauseButton.frame = CGRect(x: (self.frame.size.width - 25)/2, y: (self.frame.size.height - 35), width: 25, height: 25)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                if pipModeSize.width > UIScreen.main.bounds.width/2 {
                    pipModeSize = CGSize(width: pipModeSize.width - 50, height: pipModeSize.height - 50)
                }
                self.frame.size = CGSize(width: pipModeSize.width , height: pipModeSize.height)
                self.playerLayer?.frame = CGRect(x: 0, y: 0, width: pipModeSize.width, height: pipModeSize.height)
                self.cancelButton.isHidden = true
                self.maximizeButton.isHidden = true
                self.playPauseButton.isHidden = true
            }
        }
    }
    
    /// this function observe the player whether player is ready to play video or not
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // when player is ready to play video
        if keyPath == "currentItem.loadedTimeRanges" {
            isPlaying = true
            
        }
    }
    
    /// pause/play the video
    @objc func handlePause() {
        self.playPauseButton.tintColor = .white
        self.playPauseButton.isHidden = false
        if isPlaying {
            let originalImage = UIImage(named: "play")
            let tintedImage =  originalImage?.withRenderingMode(.alwaysTemplate)
            self.playPauseButton.setImage(tintedImage, for: .normal)
            player?.pause()
        } else {
            let originalImage = UIImage(named: "pause")
            let tintedImage =  originalImage?.withRenderingMode(.alwaysTemplate)
            self.playPauseButton.setImage(tintedImage, for: .normal)
            player?.play()
        }
        isPlaying = !isPlaying
    }
    
    
    /// this function calls when video ends
    @objc func playerDidFinishPlaying() {
        self.removePIPView()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

