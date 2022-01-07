//
//  ClassifiedObject.swift
//  seiosnativeapp
//
//  Created by bigstep on 27/07/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit

class ClassifiedObject: UIViewController {
    
    func redirectToProfilePage(_ viewController : UIViewController, id : Int){
        let presentedVC = ClassifiedDetailViewController()
        presentedVC.classifiedId = id
        viewController.navigationController?.pushViewController(presentedVC, animated: true)
    }
    
    func redirectToClassifiedBrowsePage(_ viewController : UIViewController, showOnlyMyContent : Bool){
        let pv = ClassifiedViewController()
        pv.showOnlyMyContent = showOnlyMyContent
        viewController.navigationController?.pushViewController(pv, animated: true)
    }
    
    func redirectToClassifiedBrowsePageFromNavigationDrawer(_ viewController : UIViewController, showOnlyMyContent : Bool){
        let pv = ClassifiedViewController()
        pv.showOnlyMyContent = showOnlyMyContent
          
        return;
    }
    
    
    func redirectToClassifiedFromContentFeed(_ viewController : UIViewController, userId : String, title : String){
        let presentedVC = ClassifiedViewController()
        presentedVC.user_id = userId
        presentedVC.fromTab = true
        presentedVC.showOnlyMyContent = true
        presentedVC.countListTitle = "\(title)"
        viewController.navigationController?.pushViewController(presentedVC, animated: true)
        
        
    }

}
