//
//  SitePageObject.swift
//  seiosnativeapp
//
//  Created by bigstep on 30/07/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit

class SiteMltObject: UIViewController {
    
    func redirectToMltBrowsePage(_ viewController : UIViewController, showOnlyMyContent : Bool , listingTypeIdValue : Int , listingNameValue : String , MLTbrowseorMyListingsValue : Bool , browseTypeValue : Int , viewTypeValue : Int,dashboardMenuDic:NSDictionary){
        //print(dashboardMenuDic)
         print("switch--\(browseTypeValue)")
        switch(browseTypeValue){
           
        case 1:
            let presentedVC = MLTBrowseListViewController()
            presentedVC.title = sitereviewMenuDictionary["headerLabel"] as? String
            presentedVC .showOnlyMyContent = false
            presentedVC .listingTypeId = sitereviewMenuDictionary["listingtype_id"] as! Int
            presentedVC .viewType = viewTypeValue //sitereviewMenuDictionary["viewProfileType"] as! Int
            presentedVC .listingName = sitereviewMenuDictionary["headerLabel"] as! String
            presentedVC .browseOrMyListings = MLTbrowseOrMyListings!
            presentedVC.dashboardMenuDic = dashboardMenuDic
            viewController.navigationController?.pushViewController(presentedVC, animated: false)
            
            break
        case 2:
            let presentedVC = MLTBrowseGridViewController()
            presentedVC.title = sitereviewMenuDictionary["headerLabel"] as? String
            
            presentedVC .showOnlyMyContent = false
            presentedVC .listingTypeId = sitereviewMenuDictionary["listingtype_id"] as! Int
            presentedVC .viewType = viewTypeValue //sitereviewMenuDictionary["viewProfileType"] as! Int
            presentedVC .listingName = sitereviewMenuDictionary["headerLabel"] as! String
            presentedVC .browseOrMyListings = MLTbrowseOrMyListings!
            presentedVC.dashboardMenuDic = dashboardMenuDic
            viewController.navigationController?.pushViewController(presentedVC, animated: false)
            
            break
        case 3:
            let presentedVC = MLTBrowseMatrixViewController()
            
            presentedVC.title = sitereviewMenuDictionary["headerLabel"] as? String
            
            presentedVC .showOnlyMyContent = false
            presentedVC .listingTypeId = sitereviewMenuDictionary["listingtype_id"] as! Int
            presentedVC .viewType = viewTypeValue //sitereviewMenuDictionary["viewProfileType"] as! Int
            presentedVC .listingName = sitereviewMenuDictionary["headerLabel"] as! String
            presentedVC .browseOrMyListings = MLTbrowseOrMyListings!
            presentedVC.dashboardMenuDic = dashboardMenuDic
            viewController.navigationController?.pushViewController(presentedVC, animated: false)
            
            break
        default:
            
            let presentedVC = GoogleMapViewController()
            presentedVC.title = sitereviewMenuDictionary["headerLabel"] as? String
            presentedVC.showOnlyMyContent = false
            presentedVC.listingTypeId = sitereviewMenuDictionary["listingtype_id"] as! Int
            presentedVC.viewType = viewTypeValue //sitereviewMenuDictionary["viewProfileType"] as! Int
            presentedVC.listingName = sitereviewMenuDictionary["headerLabel"] as! String
            presentedVC.browseOrMyListings = MLTbrowseOrMyListings!
            presentedVC.dashboardMenuDic = dashboardMenuDic
            viewController.navigationController?.pushViewController(presentedVC, animated: false                                                                                                                                               )
            break
        }
        
    }
        
    func redirectToMltFromContentFeed(_ viewController : UIViewController, id : String, title : String , browseTypeValue : Int , viewTypeValue : Int , listingTypeIdValue : Int , nameLabel : String , path : String ,username : String){
        
        switch browseTypeValue{
        case 1:
            
            let presentedVC = MLTBrowseListViewController()
            presentedVC.fromTab = true
            presentedVC.countListTitle = "\(title)"
            presentedVC.listingTypeId = listingTypeIdValue
            presentedVC.showOnlyMyContent = true
            presentedVC.viewType = viewTypeValue
            presentedVC.listingName = nameLabel
            presentedVC.user_id = "\(id)"
            presentedVC.path = path
            viewController.navigationController?.pushViewController(presentedVC, animated: true)
            
            break
            
        case 2:
            
            let presentedVC = MLTBrowseGridViewController()
            presentedVC.fromTab = true
            presentedVC.countListTitle = "\(title)"
            presentedVC.listingTypeId = listingTypeIdValue
            presentedVC.showOnlyMyContent = true
            presentedVC.viewType = viewTypeValue
            presentedVC.listingName = nameLabel
            presentedVC.user_id = "\(id)"
            presentedVC.path = path
            viewController.navigationController?.pushViewController(presentedVC, animated: true)
            break
            
        default:
            
            let presentedVC = MLTBrowseMatrixViewController()
            presentedVC.fromTab = true
            presentedVC.countListTitle = "\(title)"
            presentedVC.listingTypeId = listingTypeIdValue
            presentedVC.showOnlyMyContent = true
            presentedVC.viewType = viewTypeValue
            presentedVC.listingName = nameLabel
            presentedVC.user_id = "\(id)"
            presentedVC.path = path
            presentedVC.username = username
            viewController.navigationController?.pushViewController(presentedVC, animated: true)
            break
        }
        
        
    }
    
    
    func redirectToMltProfilePage(_ viewController : UIViewController, subjectType : String, listingTypeIdValue : Int , listingIdValue : String , viewTypeValue : Int){
        switch viewTypeValue{
        case 2:
            
            let presentedVC = MLTClassifiedSimpleTypeViewController()
            presentedVC.listingId = listingIdValue
            presentedVC.listingTypeId = listingTypeIdValue
            presentedVC.subjectType = subjectType
            viewController.navigationController?.pushViewController(presentedVC, animated: false)
            break
            
        case 3:
            
            let presentedVC = MLTClassifiedAdvancedTypeViewController()
            presentedVC.listingId = listingIdValue
            presentedVC.listingTypeId = listingTypeIdValue
            presentedVC.subjectType = subjectType
            viewController.navigationController?.pushViewController(presentedVC, animated: false)
            break
            
        default:
            
            let presentedVC = MLTBlogTypeViewController()
            presentedVC.listingId = listingIdValue
            presentedVC.listingTypeId = listingTypeIdValue
            presentedVC.subjectType = subjectType
            viewController.navigationController?.pushViewController(presentedVC, animated: false)
            break
        } 
    }
    
    
}
