//
//  PollObject.swift
//  seiosnativeapp
//
//  Created by bigstep on 30/07/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit

class PollObject: UIViewController {

    func redirectToPollBrowsePage(_ viewController : UIViewController, showOnlyMyContent : Bool){
        let pv = PollViewController()
        pv.showOnlyMyContent = showOnlyMyContent
        viewController.navigationController?.pushViewController(pv, animated: true)
    }
    
    func redirectToPollBrowsePageFromNavigationDrawer(_ viewController : UIViewController, showOnlyMyContent : Bool){
        let pv = PollViewController()
        pv.showOnlyMyContent = showOnlyMyContent
          
        return;
    }
    
}
