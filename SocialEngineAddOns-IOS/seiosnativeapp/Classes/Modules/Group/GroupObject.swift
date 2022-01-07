//
//  GroupObject.swift
//  seiosnativeapp
//
//  Created by bigstep on 28/07/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit

class GroupObject: UIViewController {

    func redirectToBrowsePage(_ vc : UIViewController, showOnlyMyContent : Bool){
        let presentedVC = GroupViewController()
        presentedVC.showOnlyMyContent = showOnlyMyContent
        vc.navigationController?.pushViewController(presentedVC, animated: true)
    }
    
    func redirectToBrowsePageFromContentFeed(_ vc : UIViewController, id : String, title : String){
        let presentedVC = GroupViewController()
        presentedVC.user_id = "\(id)"
        presentedVC.fromTab = true
        presentedVC.showOnlyMyContent = true
        presentedVC.countListTitle = title
        vc.navigationController?.pushViewController(presentedVC, animated: true)
    }
}
