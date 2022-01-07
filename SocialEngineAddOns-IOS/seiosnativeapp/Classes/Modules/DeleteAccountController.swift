/*
* Copyright (c) 2016 BigStep Technologies Private Limited.
*
* You may not use this file except in compliance with the
* SocialEngineAddOns License Agreement.
* You may obtain a copy of the License at:
* https://www.socialengineaddons.com/ios-app-license
* The full copyright and license information is also mentioned
* in the LICENSE file that was distributed with this
* source code.
*/

//
//  DeleteAccountController.swift
//  seiosnativeapp
//


import UIKit
import CoreData
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

class DeleteAccountController: UIViewController {
    var popAfterDelay:Bool!
    var leftBarButtonItem : UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = bgColor
 
        
        let url = "members/settings/delete"
        displayAlertWithOtherButton(NSLocalizedString("Delete Account", comment: ""),message: NSLocalizedString("Are you sure that you want to delete your Account? This action cannot be undone.",comment: "") , otherButton: NSLocalizedString("Delete Account", comment: "")) { () -> () in
            self.deletePollMenuAction(url)
        }
        self.present(alert, animated: true, completion: nil)
        
    }
    func deletePollMenuAction(_ url : String){
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            let dic = Dictionary<String, String>()
            // Send Server Request to Explore pollContents with Poll_ID
            post(dic, url: "\(url)", method: "DELETE") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        //print("delete")
                        if((AccessToken.current) != nil){
                            let loginManager = LoginManager()
                            loginManager.logOut()
                        }
                        post(["oauth_consumer_secret":"\(oauth_consumer_secret)"], url: "logout", method: "POST") {
                            (succeeded, msg) -> () in
                            
                            DispatchQueue.main.async(execute: {
                                activityIndicatorView.stopAnimating()
                            })
                            
                        }
                        menuRefreshConter = 0
                        logoutUser = true
                        refreshMenu = true
                        
                        let request: NSFetchRequest<UserInfo>
                        
                        if #available(iOS 10.0, *){
                            request = UserInfo.fetchRequest() as! NSFetchRequest<UserInfo>
                        }else{
                            request = NSFetchRequest(entityName: "UserInfo")
                        }
                        
                        request.returnsObjectsAsFaults = false
                        let results = try? context.fetch(request)
                        if(results?.count>0){
                            for result: AnyObject in results! {
                                
                                if (result.value(forKey: "oauth_token") as? String) != nil{
                                    //print("delete from Core Data \(token)")
                                    // Delete From Core Data
                                    context.delete(result as! NSManagedObject)
                                }
                            }
                            do {
                                try context.save()
                            } catch _ {
                            }
                        }
                        
                        let request1: NSFetchRequest<ActivityFeedData>
                        
                        if #available(iOS 10.0, *){
                            request1 = ActivityFeedData.fetchRequest() as! NSFetchRequest<ActivityFeedData>
                        }else{
                            request1 = NSFetchRequest(entityName: "ActivityFeedData")
                        }
                        
                        request1.returnsObjectsAsFaults = false
                        let results1 = try? context.fetch(request1)
                        if(results1?.count>0){
                            
                            // If exist than Delete all entries
                            for result: AnyObject in results1! {
                                //print("result fedd")
                                context.delete(result as! NSManagedObject)
                            }
                            do {
                                // Update Saved Feed
                                try context.save()
                            } catch _ {
                            }
                            
                            
                        }
                        
                        _ = self.navigationController?.popToRootViewController(animated: true)

                        // self.parentViewController?.dismissViewControllerAnimated(true, completion: nil)
                        return;
                        
                        
                    }
                    else{
                        // Handle Server Side Error
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                    }
                })
            }
        }else{
            // No Internet Connection Message
            showAlertMessage(view.center , msg: network_status_msg , timer: false)
        }
    }
    func showAlertMessage( _ centerPoint: CGPoint, msg: String, timer: Bool){
        self.view .addSubview(validationMsg)
        showCustomAlert(centerPoint, msg: msg)
        if timer {
            // Initialization of Timer
           self.createTimer(self)
        }
    }
    func createTimer(_ target: AnyObject){
        timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  #selector(stopTimer), userInfo: nil, repeats: false)
    }
    @objc func stopTimer() {
        stop()
        
    }
    
    
}
    
