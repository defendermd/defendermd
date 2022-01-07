//
//  LiveObjectViewController.swift
//  seiosnativeapp
//
//  Created by bigstep on 19/02/19.
//  Copyright © 2019 bigstep. All rights reserved.
//

import UIKit

class LiveObjectViewController: LiveStreamingObjectDelegates {
    static func redirectToLivePage(_ viewController: UIViewController, isBroadcaster: Bool, chName: String) {
        let presentedVC = LiveViewController()
        presentedVC.isBroadcaster = isBroadcaster
        presentedVC.chName = chName
        presentedVC.modalPresentationStyle = .fullScreen
        viewController.navigationController?.present(presentedVC, animated: true, completion: nil)
    }
    
    static func redirectToPreview(_ viewController: UIViewController) {
        let pv = PreviewViewController()
        pv.modalPresentationStyle = .fullScreen
        viewController.navigationController?.present(pv, animated: true, completion: nil)
    }
    
    static func redirectToLivePageFromNotification(_ viewController: UIViewController, isBroadcaster: Bool, chName: String, videoId: Int, videoType: String) {
        let presentedVC = LiveViewController()
        presentedVC.isBroadcaster = false
        presentedVC.chName = chName
        presentedVC.videoId = videoId
        presentedVC.videoType = videoType
        presentedVC.modalPresentationStyle = .fullScreen
        viewController.navigationController?.present(presentedVC, animated: true, completion: nil)
    }
}
