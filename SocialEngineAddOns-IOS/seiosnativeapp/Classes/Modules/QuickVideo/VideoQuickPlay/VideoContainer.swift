//
//  VideoObject.swift
//  seiosnativeapp
//
//  Created by BigStep on 29/10/18.
//  Copyright © 2018 bigstep. All rights reserved.
//

import UIKit
import AVFoundation

class VideoContainer : NSObject, NSDiscardableContent {
    var url: String
    var preferredPeakBitRate: Double = 1000000
    var sharedVideoPlayer : VideoPlayerController
    var playOn: Bool {
        didSet {
            player.automaticallyWaitsToMinimizeStalling = false
            player.isMuted = muteVideo
            playerItem.preferredPeakBitRate = preferredPeakBitRate
            if playOn && playerItem.status == .readyToPlay {
                do {
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.duckOthers)
                }
                catch {
                    // report for an error
                }
                player.play()
            }
            else{
                player.pause()
            }
        }
    }
    
    let player: AVPlayer
    let playerItem: AVPlayerItem
    
    init(player: AVPlayer, item: AVPlayerItem, url: String, sharedVideoPlayer: VideoPlayerController) {
        self.player = player
        self.playerItem = item
        self.url = url
        playOn = false
        self.sharedVideoPlayer = sharedVideoPlayer
    }
    
    func beginContentAccess() -> Bool {
        return true
    }
    
    func endContentAccess() {
        
    }
    
    func discardContentIfPossible() {
        
    }
    
    func isContentDiscarded() -> Bool {
        return false
    }
}
