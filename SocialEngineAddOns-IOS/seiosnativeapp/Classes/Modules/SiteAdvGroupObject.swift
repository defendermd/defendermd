//
//  SiteAdvGroupObject.swift
//  seiosnativeapp
//
//  Created by bigstep on 30/07/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit

class SiteAdvGroupObject: UIViewController {
    
    func redirectToAdvGroupBrowsePage(_ viewController : UIViewController, showOnlyMyContent : Bool){
        let pv = AdvancedGroupViewController()
        pv.showOnlyMyContent = showOnlyMyContent
        viewController.navigationController?.pushViewController(pv, animated: true)
    }
    
    func redirectToAdvGroupBrowsePageFromNavigationDrawer(_ viewController : UIViewController, showOnlyMyContent : Bool){
        let pv = AdvancedGroupViewController()
        pv.showOnlyMyContent = showOnlyMyContent
          
        return;
    }
    
    func redirectToAdvGroupFromContentFeed(_ viewController : UIViewController, userId : String, title : String,userName: String){
        
        let presentedVC = AdvancedGroupViewController()
        presentedVC.user_id = "\(userId)"
        presentedVC.fromTab = true
        presentedVC.showOnlyMyContent = true
        presentedVC.countListTitle = "\(title)"
        presentedVC.username = userName
        viewController.navigationController?.pushViewController(presentedVC, animated: true)
        
    }
    
    
    func redirectToAdvGroupProfilePage(_ viewController : UIViewController, subject_type : String, subject_id : String){
        let presentedVC = AdvancedGroupDetailViewController()
        presentedVC.subjectType = subject_type
        presentedVC.subjectId = subject_id
        viewController.navigationController?.pushViewController(presentedVC, animated: false)
    }
    
    
}
