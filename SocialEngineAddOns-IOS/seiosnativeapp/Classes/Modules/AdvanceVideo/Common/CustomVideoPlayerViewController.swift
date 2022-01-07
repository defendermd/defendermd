//
//  CustomVideoPlayerViewController.swift
//  seiosnativeapp
//
//  Created by bigstep_macbook_air on 9/16/19.
//  Copyright © 2019 bigstep. All rights reserved.
//

import Foundation
import AVKit
import UIKit

class CustomVideoPlayerViewController: AVPlayerViewController {
    var pipButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "pip_Icon")
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.isHidden = false
        return button
    }()
    var pipView: PIPViews!
    var videoPlayer: AVPlayer?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.player?.play()
        if showPipOption() == "no" {
            self.pipButton.isHidden = true
        }
        else {
           self.pipButton.isHidden = false
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        for view in (keywindows?.subviews)! {
            if view.tag == 9999 {
                view.removeFromSuperview()
            }
        }
        if let player = self.player {
            self.videoPlayer = player
            player.play()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    /// when pip button is tapped, this function calls and dismiss the current view controller and set the pip view
    @objc func showPIP() {
        for view in (keywindows?.subviews)! {
            if view.tag == 9999 {
                view.removeFromSuperview()
            }
        }
        isVideoPlayingInPIP = true
        self.pipView = PIPViews(frame: CGRect(x: (keywindow!.frame.size.width - pipModeSize.width)/2, y: (keywindow!.frame.size.height - pipModeSize.height)/2, width: pipModeSize.width, height: pipModeSize.height), videoPlayer: self.videoPlayer!, parentViewController: self, currentTimeStamp: (self.videoPlayer?.currentTime())!)
        self.pipView.isHidden = true
        keywindows?.addSubview(self.pipView!)
        self.pipView.openPIPWithAnimation()
        self.dismiss(animated: true, completion: nil)
    }
}

/// to check whether pip mode is enabled or not
///
/// - Returns: returns yes if enable
func showPipOption() -> String {
    let defaults = UserDefaults.standard
    if let name = defaults.object(forKey: "pipMode")
    {
        if  UserDefaults.standard.object(forKey: "pipMode") != nil
        {
            if name as! String == "yes" {
                return "yes"
            }
            else {
                return "no"
            }
        }
        else {
            return "yes"
        }
    }
    else if show_PIP == 1 {
        return "yes"
    }
    else {
        return "no"
    }
}
