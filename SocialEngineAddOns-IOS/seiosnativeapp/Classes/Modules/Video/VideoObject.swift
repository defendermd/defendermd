//
//  VideoObject.swift
//  seiosnativeapp
//
//  Created by bigstep on 27/07/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit

class VideoObject: UIViewController {
    
    func redirectToVideoProfilePage(_ viewController : UIViewController, videoId : Int, videoType : Int, videoUrl : String){
        let presentedVC = VideoProfileViewController()
        presentedVC.videoId = videoId
        presentedVC.videoType = videoType
        presentedVC.videoUrl = videoUrl
        viewController.navigationController?.pushViewController(presentedVC, animated: true)
    }
    
    func redirectToVideoProfilePageForListings(_ viewController : UIViewController, videoId : Int, videoType : Int, videoUrl : String, listingId : Int, listingTypeId : Int){
        let presentedVC = VideoProfileViewController()
        presentedVC.listingTypeId = listingTypeId
        presentedVC.videoProfileTypeCheck = "listings"
        presentedVC.videoId = videoId
        presentedVC.videoType = videoType
        presentedVC.videoUrl = videoUrl
        presentedVC.listingId = listingId
        viewController.navigationController?.pushViewController(presentedVC, animated: true)
    }
    
    func redirectToVideoProfilePageForAdvEvents(_ viewController : UIViewController, videoId : Int, videoType : Int, videoUrl : String, eventId : Int){
        let presentedVC = VideoProfileViewController()
        presentedVC.videoProfileTypeCheck = "AdvEventProfile"
        presentedVC.videoId = videoId
        presentedVC.videoType = videoType
        presentedVC.videoUrl = videoUrl
        presentedVC.event_id = eventId
        viewController.navigationController?.pushViewController(presentedVC, animated: true)
    }
    
    func redirectToVideoBrowsePage(_ viewController : UIViewController, showOnlyMyContent : Bool){
        
        let presentedVC = VideoBrowseViewController()
        presentedVC.showOnlyMyContent = showOnlyMyContent
        viewController.navigationController?.pushViewController(presentedVC, animated: true)
        
    }
    
    func redirectToVideoBrowsePageFromNavigationDrawer(_ viewController : UIViewController, showOnlyMyContent : Bool){
        let pv = VideoBrowseViewController()
        pv.showOnlyMyContent = showOnlyMyContent
          
        return;
    }
    
    func redirectToVideoFromContentFeed(_ viewController : UIViewController, userId : String, title : String, videoTypeCheck : String){
        let presentedVC = VideoBrowseViewController()
        presentedVC.user_id = "\(userId)"
        presentedVC.fromTab = true
        presentedVC.showOnlyMyContent = true
        presentedVC.countListTitle = title
        if videoTypeCheck != ""{
            presentedVC.videoTypeCheck = videoTypeCheck
        }
        
        viewController.navigationController?.pushViewController(presentedVC, animated: true)
    }
    

    

}
