//
//  SitePageObject.swift
//  seiosnativeapp
//
//  Created by bigstep on 30/07/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit

class SitePageObject: UIViewController {
    
    func redirectToPageBrowsePage(_ viewController : UIViewController, showOnlyMyContent : Bool){
        let pv = PageViewController()
        pv.showOnlyMyContent = showOnlyMyContent
        viewController.navigationController?.pushViewController(pv, animated: true)
    }
    
    func redirectToPageBrowsePageFromNavigationDrawer(_ viewController : UIViewController, showOnlyMyContent : Bool){
        let pv = PageViewController()
        pv.showOnlyMyContent = showOnlyMyContent
          
        return;
    }
    
    func redirectToPageFromContentFeed(_ viewController : UIViewController, userId : String, title : String,userName : String){
       
        let presentedVC = PageViewController()
        presentedVC.user_id = Int(userId)
        presentedVC.fromTab = true
        presentedVC.showOnlyMyContent = true
        presentedVC.countListTitle = "\(title)"
        presentedVC.username = userName
        viewController.navigationController?.pushViewController(presentedVC, animated: true)
      
    }

    
    func redirectToPageProfilePage(_ viewController : UIViewController, subject_type : String, subject_id : String){
        let presentedVC = PageDetailViewController()
        presentedVC.subjectType = subject_type
        presentedVC.subjectId =  subject_id
        presentedVC.isComingFromPage = false
        viewController.navigationController?.pushViewController(presentedVC, animated: false)
    }
    

}
