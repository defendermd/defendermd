//
//  SiteStoreObject.swift
//  seiosnativeapp
//
//  Created by bigstep on 30/07/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit

class SiteStoreObject: UIViewController {
    
    func redirectToStoresBrowse(viewController : UIViewController, showOnlyMyContent : Bool){
        let pv = StoresBrowseViewController()
        pv.showOnlyMyContent = showOnlyMyContent
        viewController.navigationController?.pushViewController(pv, animated: true)
    }
    
    func redirectToStoreBrowseFromNavigationDrawer(viewController : UIViewController, showOnlyMyContent : Bool){
        let pv = StoresBrowseViewController()
        pv.showOnlyMyContent = showOnlyMyContent
          
        return;
    }
    
    func redirectToStoreBrowseFromContentFeed(viewController : UIViewController, userId : Int, title : String){
        
        let presentedVC = StoresBrowseViewController()
        presentedVC.showOnlyMyContent = true
        viewController.navigationController?.pushViewController(presentedVC, animated: true)
        
    }
    
    
    func redirectToStoreProfile(viewController : UIViewController, subject_type : String, subject_id : String){
        let presentedVC = StoresProfileViewController()
        presentedVC.storeId = subject_id
        presentedVC.subjectType = subject_type
        viewController.navigationController?.pushViewController(presentedVC, animated: false)
    }
    


    func redirectToProductsViewPage(viewController : UIViewController, showOnlyMyContent : Bool){
        let pv = ProductsViewPage()
        pv.showOnlyMyContent = showOnlyMyContent
        viewController.navigationController?.pushViewController(pv, animated: true)
    }
    func redirectToProductsViewPageFromNavigationDrawer(viewController : UIViewController, showOnlyMyContent : Bool){
        let pv = ProductsViewPage()
        pv.showOnlyMyContent = showOnlyMyContent
          
        return;
    }
    func redirectToProductsProfilePage(viewController : UIViewController, showOnlyMyContent : Bool,product_id:String){
        let pv = ProductProfilePage()
        pv.product_id = product_id
//        pv.showOnlyMyContent = showOnlyMyContent
        viewController.navigationController?.pushViewController(pv, animated: false)
    }

    func redirectToConfigFormViewPage(viewController : UIViewController, showOnlyMyContent : Bool,configArray : NSDictionary, productId : String, priceValue : CGFloat){
        let pv = ConfigurationFormViewController()
//        pv.showOnlyMyContent = showOnlyMyContent
        pv.configArrayValue = configArray
        pv.priceAmount = priceValue
        pv.product_id = productId
        viewController.navigationController?.pushViewController(pv, animated: true)
    }
    
    func redirectToCouponsBrowse(viewController : UIViewController, showOnlyMyContent : Bool, fromStore: Bool, storeId: Int){
        let pv = CouponsBrowseViewController()
        pv.showOnlyMyContent = showOnlyMyContent
        pv.fromStore = fromStore
        if storeId != 0{
            pv.content_id = "\(storeId)"
        }
        viewController.navigationController?.pushViewController(pv, animated: true)
        
    }
    func redirectToCouponsBrowseFromNavigationDrawer(viewController : UIViewController, showOnlyMyContent : Bool, fromStore: Bool, storeId: Int){
        let pv = CouponsBrowseViewController()
        pv.showOnlyMyContent = showOnlyMyContent
        pv.fromStore = fromStore
        if storeId != 0{
            pv.content_id = "\(storeId)"
        }
          
        return;
    }
    
    func redirectToMyStore(viewController : UIViewController){
        let pv = MyStoreViewController()
        viewController.navigationController?.pushViewController(pv, animated: true)
    }
    
//    func redirectToMyStoreFromNavigationDrawer(viewController : UIViewController)
//    {
//        let pv = MyStoreViewController()
//
//        return;
//    }
    
    func redirectToManageCart(viewController : UIViewController){
        let pv = ManageCartViewController()
        viewController.navigationController?.pushViewController(pv, animated: true)
    }
    
//    func redirectToManageCartFromNavigationDrawer(viewController : UIViewController)
//    {
//        let pv = ManageCartViewController()
//          
//        return;
//    }
    
}
