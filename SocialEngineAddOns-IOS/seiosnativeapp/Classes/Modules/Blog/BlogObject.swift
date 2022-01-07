//
//  BlogObject.swift
//  seiosnativeapp
//
//  Created by bigstep on 26/07/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit

class BlogObject: UIViewController {
    
    func redirectToBlogBrowsePage(_ viewController : UIViewController, showOnlyMyContent : Bool){
        let pv = BlogViewController()
        pv.showOnlyMyContent = showOnlyMyContent
        viewController.navigationController?.pushViewController(pv, animated: true)
     }
    
    func redirectToBlogBrowsePageFromNavigationDrawer(_ viewController : UIViewController, showOnlyMyContent : Bool){
        let pv = BlogViewController()
        pv.showOnlyMyContent = showOnlyMyContent
          
        return;
    }
    
    func redirectToBlogDetailPage(_ viewController : UIViewController, blogId : Int, title : String){
        let presentedVC = BlogDetailViewController()
        presentedVC.blogId = blogId
        presentedVC.blogName = title
        viewController.navigationController?.pushViewController(presentedVC, animated: true)
    }
    
    func redirectToBlogFromContentFeed(_ viewController : UIViewController, userId : String, title : String){
        let presentedVC = BlogViewController()
        presentedVC.showOnlyMyContent = true
        presentedVC.user_id = userId
        presentedVC.fromTab = true
        presentedVC.countListTitle = title
        viewController.navigationController?.pushViewController(presentedVC, animated: true)
    }
    

}
