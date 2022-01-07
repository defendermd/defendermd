//
//  AdvanceEventObject.swift
//  seiosnativeapp
//
//  Created by bigstep on 30/07/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit

class AdvanceEventObject: UIViewController {

    func redirectToAdvanceEventBrowsePage(_ viewController : UIViewController, showOnlyMyContent : Bool){
        let pv = AdvancedEventViewController()
        pv.showOnlyMyContent = showOnlyMyContent
        viewController.navigationController?.pushViewController(pv, animated: true)
    }
    
    func redirectToAdvanceEventBrowsePageFromNavigationDrawer(_ viewController : UIViewController, showOnlyMyContent : Bool){
        let pv = AdvancedEventViewController()
        pv.showOnlyMyContent = showOnlyMyContent
          
        return;
    }
    
    
}
