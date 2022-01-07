//
//  MusicObject.swift
//  seiosnativeapp
//
//  Created by bigstep on 27/07/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit

class MusicObject: UIViewController {

    func redirectToPlaylistPage(_ viewController : UIViewController, id : Int){
        let presentedVC = MusicPlayListViewController()
        presentedVC.playListId = id
        viewController.navigationController?.pushViewController(presentedVC, animated: true)
    }
    
    
    func redirectToMusicBrowsePage(_ viewController : UIViewController, showOnlyMyContent : Bool){
        
        let presentedVC = MusicViewController()
        presentedVC.showOnlyMyContent = showOnlyMyContent
        viewController.navigationController?.pushViewController(presentedVC, animated: true)
        
    }
    
    func redirectToMusicBrowsePageFromNavigationDrawer(_ viewController : UIViewController, showOnlyMyContent : Bool){
        let pv = MusicViewController()
        pv.showOnlyMyContent = showOnlyMyContent
          
        return;
    }
    
    func redirectToMusicFromContentFeed(_ viewController : UIViewController, userId : String, title : String, username : String){
        let presentedVC = MusicViewController()
        presentedVC.user_id = "\(userId)"
        presentedVC.fromTab = true
        presentedVC.showOnlyMyContent = true
        presentedVC.countListTitle = title
        presentedVC.username = username
        viewController.navigationController?.pushViewController(presentedVC, animated: true)
    }

    
    
}
