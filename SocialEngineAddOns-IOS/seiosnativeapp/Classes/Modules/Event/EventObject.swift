//
//  EventObject.swift
//  seiosnativeapp
//
//  Created by bigstep on 28/07/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit

class EventObject: UIViewController {

    func redirectToEventBrowsePage(_ viewController : UIViewController, showOnlyMyContent : Bool){
        let pv = EventViewController()
        pv.showOnlyMyContent = showOnlyMyContent
        viewController.navigationController?.pushViewController(pv, animated: true)
    }
    
    func redirectToEventBrowsePageFromNavigationDrawer(_ viewController : UIViewController, showOnlyMyContent : Bool){
        let pv = EventViewController()
        pv.showOnlyMyContent = showOnlyMyContent
          
        return;
    }
    
    func redirectToEventFromContentFeed(_ viewController : UIViewController, userId : Int, title : String){
        let presentedVC = EventViewController()
        presentedVC.user_id = "\(userId)"
        presentedVC.fromTab = true
        presentedVC.showOnlyMyContent = true
        presentedVC.countListTitle = title
        viewController.navigationController?.pushViewController(presentedVC, animated: true)
    }
    
}
