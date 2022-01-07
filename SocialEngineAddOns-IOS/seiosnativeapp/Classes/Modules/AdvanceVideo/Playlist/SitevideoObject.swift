//
//  SitevideoObject.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 05/06/17.
//  Copyright © 2017 bigstep. All rights reserved.
//

import UIKit

class SitevideoObject: UIViewController {
    
    func redirectToAdvVideoBrowsePage(_ viewController : UIViewController, showOnlyMyContent : Bool){
        
        let presentedVC = AdvanceVideoViewController()
        presentedVC.showOnlyMyContent = showOnlyMyContent
        viewController.navigationController?.pushViewController(presentedVC, animated: true)
        
    }
    
    func redirectToAdvVideoBrowsePageFromNavigationDrawer(_ viewController : UIViewController, showOnlyMyContent : Bool){
        let pv = AdvanceVideoViewController()
        pv.showOnlyMyContent = showOnlyMyContent
          
        return;
    }
    
    func redirectToChannelBrowsePage(_ viewController : UIViewController, showOnlyMyContent : Bool){
        
        let presentedVC = ChannelViewController()
        presentedVC.showOnlyMyContent = showOnlyMyContent
        viewController.navigationController?.pushViewController(presentedVC, animated: true)
        
    }
    
    func redirectToChannelBrowsePageFromNavigationDrawer(_ viewController : UIViewController, showOnlyMyContent : Bool){
        let pv = ChannelViewController()
        pv.showOnlyMyContent = showOnlyMyContent
          
        return;
    }

    func redirectToPlaylistBrowsePage(_ viewController : UIViewController, showOnlyMyContent : Bool){
        
        let presentedVC = PlaylistBrowseViewController()
        presentedVC.showOnlyMyContent = showOnlyMyContent
        viewController.navigationController?.pushViewController(presentedVC, animated: true)
        
    }
    
    func redirectToPlaylistBrowsePageFromNavigationDrawer(_ viewController : UIViewController, showOnlyMyContent : Bool){
        let pv = PlaylistBrowseViewController()
        pv.showOnlyMyContent = showOnlyMyContent
          
        return;
    }

     func redirectToAdvVideoProfilePage(_ viewController : UIViewController, videoId : Int, videoType : Int, videoUrl : String, isFromDeeplink:Bool = false){
          let presentedVC = AdvanceVideoProfileViewController()
          presentedVC.videoId = videoId
          presentedVC.videoType = videoType
          presentedVC.videoUrl = videoUrl
          presentedVC.isComingFromDeepLink = isFromDeeplink
          let navigationController = UINavigationController(rootViewController: presentedVC)
          navigationController.modalPresentationStyle = .fullScreen
          viewController.present(navigationController, animated: true, completion: nil)
      }
    
    func redirectToChannelProfilePage(_ viewController : UIViewController, videoId : String, subjectType : String){
        let presentedVC = ChannelProfileViewController()
        presentedVC.subjectId = videoId
        presentedVC.subjectType = subjectType
        viewController.navigationController?.pushViewController(presentedVC, animated: true)
    }
    
    func redirectToPlaylistProfilePage(_ viewController : UIViewController, playlistId : String, subjectType : String){
        let presentedVC = PlaylistProfileViewController()
        presentedVC.playlistId = playlistId
        presentedVC.subjectType = subjectType
        viewController.navigationController?.pushViewController(presentedVC, animated: true)
    }
    
    func redirectToAdvVideoFromContentFeed(_ viewController : UIViewController, userId : String, title : String, videoTypeCheck : String,userName: String){
        let presentedVC = AdvanceVideoViewController()
        presentedVC.user_id = "\(userId)"
        presentedVC.fromTab = true
        presentedVC.showOnlyMyContent = true
        presentedVC.countListTitle = title
        presentedVC.username = userName
        if videoTypeCheck != ""{
            presentedVC.videoTypeCheck = videoTypeCheck
        }
        viewController.navigationController?.pushViewController(presentedVC, animated: true)
    }

}
