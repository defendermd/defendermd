//
//  VideoPlayerDismiss.swift
//  seiosnativeapp
//
//  Created by bigstep_macbook_air on 8/30/19.
//  Copyright © 2019 bigstep. All rights reserved.
//

import Foundation
import UIKit
func dismissVideoPlayer(parentVC: UIViewController, childVC: UIViewController, dismiss: Bool = true)
{
    UIView.animate(withDuration: 0.5, delay: 0.3, options: UIView.AnimationOptions.curveEaseIn, animations: {
        if dismiss {
        parentVC.navigationController?.setNavigationBarHidden(false, animated: false)
        childVC.view.frame = CGRect(x: 0, y: parentVC.view.frame.size.height + 10, width: parentVC.view.frame.size.width, height: 0)
        }
        else {
            childVC.view.frame = CGRect(x: 0, y: 0, width: parentVC.view.frame.size.width, height: parentVC.view.frame.size.height)
            isChildViewActive = true
        }
    },completion: { finish in
        if !dismiss {
            parentVC.navigationController?.setNavigationBarHidden(true, animated: false)
        }
    })
}


