//
//  CustomVideoPlayer.swift
//  seiosnativeapp
//
//  Created by bigstep_macbook_air on 8/28/19.
//  Copyright © 2019 bigstep. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation
let keywindows = UIApplication.shared.keyWindow
var pipModeSize = CGSize(width: UIScreen.main.bounds.width/2, height: UIScreen.main.bounds.width/3 - 10)
class CustomVideoPlayer : UIView {
    var videoUrl: String?
    var fromVideoProfilePage: Bool?
    var parentVC: UIViewController?
    let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: .whiteLarge)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.startAnimating()
        return aiv
    }()
   
    lazy var pausePlayButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "pause")
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.isHidden = true
        
        button.addTarget(self, action: #selector(handlePause), for: .touchUpInside)
        
        return button
    }()
    
    let currentTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "00:00"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 13)
        return label
    }()
    
    let fullScreenButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "fullScreenIcon")
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = false
        button.addTarget(self, action: #selector(enterFullScreen), for: .touchUpInside)
        return button
    }()
    
    let videoLengthLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "00:00"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .right
        return label
    }()
    
    lazy var videoSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumTrackTintColor = .red
        slider.maximumTrackTintColor = .white
        slider.setThumbImage(UIImage(named: "thumb"), for: .normal)
        
        slider.addTarget(self, action: #selector(handleSliderChange), for: .valueChanged)
        
        return slider
    }()
    
    /// calls when we slide the video slider
    @objc func handleSliderChange() {
        
        if let duration = player?.currentItem?.duration {
            let totalSeconds = CMTimeGetSeconds(duration)
            
            let value = Float64(videoSlider.value) * totalSeconds
            
            let seekTime = CMTime(value: Int64(value), timescale: 1)
            
            player?.seek(to: seekTime, completionHandler: { (completedSeek) in
                //perhaps do something later here
            })
        }
        
        
    }
    
    var isPlaying = false
    
    /// handle play pause video
    @objc func handlePause() {
        if isPlaying {
            player?.pause()
            pausePlayButton.setImage(UIImage(named: "play"), for: .normal)
            pausePlayButton.isHidden = false
            pausePlayButton.tintColor = .white
        } else {
            player?.play()
            pausePlayButton.isHidden = false
            pausePlayButton.tintColor = .clear
        }
        
        isPlaying = !isPlaying
    }
    
    let controlsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 1)
        return view
    }()
    
    init(frame: CGRect, url: String, isFromVideoProfilePage: Bool = false, vc: UIViewController = UIViewController()) {
        super.init(frame: frame)
        setupGradientLayer()
        self.videoUrl = url
        self.parentVC = vc
        controlsContainerView.frame = self.frame
        controlsContainerView.center = self.center
        self.addSubview(activityIndicatorView)
        activityIndicatorView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.fromVideoProfilePage = isFromVideoProfilePage
        
        self.addSubview(pausePlayButton)
        pausePlayButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        pausePlayButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        pausePlayButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        pausePlayButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        self.addSubview(videoLengthLabel)
        videoLengthLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8).isActive = true
        videoLengthLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        videoLengthLabel.widthAnchor.constraint(equalToConstant: 60).isActive = true
        videoLengthLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        self.addSubview(currentTimeLabel)
        currentTimeLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        currentTimeLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -2).isActive = true
        currentTimeLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
        currentTimeLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        setupPlayerView()
        backgroundColor = .black
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    var player: AVPlayer?
    var playerLayer : AVPlayerLayer!
    
    
    /// setup the video player and its layer with framing
    func setupPlayerView() {
        //warning: use your own video url here, the bandwidth for google firebase storage will run out as more and more people use this file
        let urlString = self.videoUrl!
        if let url = URL(string: urlString) {
            player = AVPlayer(url: url)
            playerLayer = AVPlayerLayer(player: player)
            self.layer.addSublayer(playerLayer)
            playerLayer.frame = controlsContainerView.frame
            playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
            player?.play()
            
            player?.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)
            
            self.addSubview(videoSlider)
            videoSlider.rightAnchor.constraint(equalTo: videoLengthLabel.leftAnchor).isActive = true
            videoSlider.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            videoSlider.leftAnchor.constraint(equalTo: currentTimeLabel.rightAnchor).isActive = true
            videoSlider.heightAnchor.constraint(equalToConstant: 30).isActive = true
            
            self.addSubview(fullScreenButton)
            fullScreenButton.bottomAnchor.constraint(equalTo: self.videoSlider.bottomAnchor, constant: -20).isActive = true
            fullScreenButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20).isActive = true
            fullScreenButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
            fullScreenButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
            
            //track player progress
            
            let interval = CMTime(value: 1, timescale: 2)
            player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { (progressTime) in
                
                let seconds = CMTimeGetSeconds(progressTime)
                let secondsString = String(format: "%02d", Int(seconds) % 60)
                let minutesString = String(format: "%02d", Int(seconds) / 60)
                self.currentTimeLabel.text = "\(minutesString):\(secondsString)"
                
                //lets move the slider thumb
                if let duration = self.player?.currentItem?.duration {
                    let durationSeconds = CMTimeGetSeconds(duration)
                    
                    self.videoSlider.value = Float(seconds / durationSeconds)
                    
                }
                
                
            })
        }
    }
    
    // calls when video is finished
    @objc func playerDidFinishPlaying() {
        self.pausePlayButton.setImage(UIImage(named: "replayicon"), for: .normal)
        self.pausePlayButton.tintColor = .white
        self.player?.currentItem?.seek(to: CMTime.zero)
        self.isPlaying = !self.isPlaying
    }
    
    @objc func dismissPlayer() {
        UIView.animate(withDuration: 0.5, delay: 0.5, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
        }) { (_) in
            UIApplication.shared.setStatusBarHidden(false, with: .fade)
            self.parentViewController()?.dismiss(animated: true, completion: nil)
        }
        
    }
    
    // To enter full screen video
    @objc func enterFullScreen() {
        let pv = CustomVideoPlayerViewController()
        pv.player = self.player
        pv.videoPlayer = self.player
        pv.videoPlayer = AVPlayer(url: URL(string: self.videoUrl!)!)
        self.player?.play()
        self.parentVC!.present(pv, animated: true) {
            pv.pipButton.frame = CGRect(x: 0, y: UIApplication.shared.statusBarFrame.height + 20, width: 20, height: 20)
            pv.pipButton.center.x = keywindows!.center.x
            pv.view.addSubview(pv.pipButton)
            pv.view.bringSubviewToFront(pv.pipButton)
            pv.pipButton.addTarget(pv, action: #selector(CustomVideoPlayerViewController.showPIP), for: .touchUpInside)
        }
    }
    
    private func setupGradientLayer() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientLayer.locations = [0.7, 1.2]
        controlsContainerView.layer.addSublayer(gradientLayer)
    }
    
    
    /// observes to check whether player is ready to play the video or not
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        //this is when the player is ready and rendering frames
        if keyPath == "currentItem.loadedTimeRanges" {
            activityIndicatorView.stopAnimating()
            controlsContainerView.backgroundColor = .clear
            pausePlayButton.isHidden = false
            pausePlayButton.tintColor = .clear
            isPlaying = true
            
            if let duration = player?.currentItem?.duration {
                let seconds = CMTimeGetSeconds(duration)
                
                let secondsText = Int(seconds) % 60
                let minutesText = String(format: "%02d", Int(seconds) / 60)
                videoLengthLabel.text = "\(minutesText):\(secondsText)"
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


