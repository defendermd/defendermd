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
//  SettingsViewController.swift
//  SocailEngineDemoForSwift
//

import UIKit
import Foundation
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

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let mainView = UIView()
    var showSpinner = true                      // not show spinner at pull to refresh
    var blogTableView:UITableView!              // TAbleView to show the blog Contents
    var refresher:UIRefreshControl!             // Pull to refrresh
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var dynamicHeight:CGFloat = 40              // Dynamic Height fort for Cell
    var showOnlyMyContent = false
    var delete:Bool! = false
    var count1 : Int!
    var settingArray : NSArray!
    var settingResponse = [AnyObject]()
    var leftBarButtonItem : UIBarButtonItem!
    var pipSwitch: UISwitch!
    
    // Flag to refresh Blog
    // Initialization of class Object
    override func viewDidLoad() {
        
        super.viewDidLoad()
        searchDic.removeAll(keepingCapacity: false)
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        openMenu = false
        updateAfterAlert = true
        
        let subViews = mainView.subviews
        for subview in subViews{
            subview.removeFromSuperview()
        }
        self.navigationItem.hidesBackButton = true
        mainView.frame = view.frame
        mainView.backgroundColor = bgColor
        view.addSubview(mainView)
        mainView.removeGestureRecognizer(tapGesture)
        
        // makeSettingsArray()
        self.title = NSLocalizedString("Settings",  comment: "")
        if tabBarController != nil{
            baseController?.tabBar.items?[self.tabBarController!.selectedIndex].title = nil
        }

        
        
        // Initialize Blog Table
        blogTableView = UITableView(frame: CGRect(x: 0, y: 0 , width: view.bounds.width, height: view.bounds.height - TOPPADING), style: .grouped)
        blogTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        blogTableView.dataSource = self
        blogTableView.delegate = self
        blogTableView.estimatedRowHeight = 40.0
        blogTableView.rowHeight = UITableView.automaticDimension
        blogTableView.backgroundColor = tableViewBgColor
        blogTableView.separatorColor = TVSeparatorColor
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            blogTableView.estimatedRowHeight = 0
            blogTableView.estimatedSectionHeaderHeight = 0
            blogTableView.estimatedSectionFooterHeight = 0
        }
        mainView.addSubview(blogTableView)
        
  
        getUserInfo()
        if show_PIP == 1 {
        checkpipViewStatus()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        removeNavigationViews(controller: self)
    }
    
    // Check for Blog Update Every Time when View Appears
    override func viewDidAppear(_ animated: Bool) {
        
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
        }
        
    }
    
    func getUserInfo(){
        if Reachabable.isConnectedToNetwork() {
            removeAlert()

            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            // Send Server Request to Explore Blog Contents with Blog_ID
            post([:], url: "get-user-account-menu", method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    
                    if msg{
                        
                        self.settingArray = succeeded["body"] as! NSArray
                        self.count1 = self.settingArray.count
                        self.settingResponse = self.settingResponse + ((self.settingArray as AnyObject) as! [AnyObject])
                        self.blogTableView.reloadData()
                    }
                    
                })
            }
        }else{
            // No Internet Connection Message
            showAlertMessage(view.center , msg: network_status_msg , timer: false)
        }
    }
    
    // check pip enable/disable
    func checkpipViewStatus() {
        if  UserDefaults.standard.object(forKey: "pipMode") == nil
        {
            UserDefaults.standard.set("yes", forKey: "pipMode")
        }
    }
    
    // Handle TapGesture On Open Slide Menu
    func handleTap(_ recognizer: UITapGestureRecognizer) {
        openMenu = false
        openMenuSlideOnView(mainView)
        mainView.removeGestureRecognizer(tapGesture)
    }
    
    // Generate Custom Alert Messages
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
    // Stop Timer
    @objc func stopTimer() {
        stop()
    }
    
    // MARK:  UITableViewDelegate & UITableViewDataSource
    
    // Set Blog Tabel Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (limit*pageNumber < totalItems){
            return 80
            
        }else{
            return 0.00001
        }
    }
    
    // Set Blog Tabel Header Height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if  (UIDevice.current.userInterfaceIdiom == .phone){
            dynamicHeight = 50.0
        }else{
            dynamicHeight = 70.0
        }
        return dynamicHeight
    }
    
    // Set Blog Section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.settingResponse.count
    }
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        var blogInfo:NSDictionary
        blogInfo = settingResponse[(indexPath as NSIndexPath).row] as! NSDictionary
        
        cell.textLabel!.text = blogInfo["label"] as? String
        cell.textLabel!.font = UIFont(name: fontName, size: 16.0)
        if blogInfo["name"] as! String == "picture_in_picture" {
            pipSwitch = UISwitch(frame: CGRect(x: 0, y: 0 , width:  30, height: 10))
            pipSwitch.addTarget(self, action: #selector(SettingsViewController.switchAction), for: .valueChanged)
            if let name = UserDefaults.standard.object(forKey: "pipMode")
            {
                if  UserDefaults.standard.object(forKey: "pipMode") != nil
                {
                    if name as! String == "yes" {
                        pipSwitch.setOn(true, animated: true)
                    }
                    else {
                       pipSwitch.setOn(false, animated: true)
                    }
                }
            }
            cell.accessoryView = pipSwitch
        }
        else {
            cell.accessoryView = nil
        }
        
        
        return cell
        
    }
    
    // Handle Blog Table Cell Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var labelName: String
        var settingInfo:NSDictionary
        settingInfo = settingResponse[(indexPath as NSIndexPath).row] as! NSDictionary
        labelName = settingInfo["name"] as! String
        changeView(labelName)
        
        
    }
    @objc func switchAction() {
        if self.pipSwitch.isOn {
            UserDefaults.standard.set("yes", forKey: "pipMode")
        }
        else {
            UserDefaults.standard.set("no", forKey: "pipMode")
        }
    }
    
    func changeView(_ labelName : String){
        var presentedVC:UIViewController!
        switch(labelName){
            
        case "general":
            presentedVC = GeneralSettingsController()
            break
            
        case "privacy":
            presentedVC = PrivacySettingsController()
            signUplayoutType = false
            break
            
        case "network":
            presentedVC = NetworksSettingsController()
            break
            
        case "notification":
            presentedVC = NotificationsSettingsViewController()
            signUplayoutType = false
            break // Notification setting
            
        case "password":
            presentedVC = ChangePasswordSettingsController()
            break
            
        case "delete":
            delete = true
            let url = "members/settings/delete"
            displayAlertWithOtherButton(NSLocalizedString("Delete Account", comment: ""),message: NSLocalizedString("Are you sure that you want to delete your Account? This action cannot be undone.",comment: "") , otherButton: NSLocalizedString("Delete Account", comment: "")) { () -> () in
                self.deletePollMenuAction(url)
            }
            self.present(alert, animated: true, completion: nil)
            break
            
        case "mystore":
            iscomingfrom = ""
            SiteStoreObject().redirectToMyStore(viewController: self)
            return
            
        case "subscription":
            presentedVC = SignupUserSubscriptionViewController()
            (presentedVC as! SignupUserSubscriptionViewController).user_id = currentUserId
            (presentedVC as! SignupUserSubscriptionViewController).isFromSettings = true
            break
            
        case "mobileinfo":
            presentedVC = two_step_verificationViewController()
            break
        case "video_autoplay":
            presentedVC = VideoAuotPlayViewController()
            break
        default:
            presentedVC = GeneralSettingsController()
            break
            
        }
        
        if delete == false{
            navigationController?.pushViewController(presentedVC, animated: true)
        }
        else if delete == true{
            delete = false
        }
    }
   
    func deletePollMenuAction(_ url : String){
        //         delete = true
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
//                        if((FBSDKAccessToken.current()) != nil){
//                            let loginManager = FBSDKLoginManager()
//                            loginManager.logOut()
//                        }
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
                        if #available(iOS 10.0, *) {
                            request = UserInfo.fetchRequest() as! NSFetchRequest<UserInfo>
                        } else {
                            request = NSFetchRequest(entityName: "UserInfo")
                        }
                        
                        request.returnsObjectsAsFaults = false
                        let results = try? context.fetch(request)
                        if(results?.count>0){
                            for result: Any in results! {
                                
                                if let token = (result as AnyObject).value(forKey: "oauth_token") as? String{
                                    print("delete from Core Data \(token)")
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
                        if #available(iOS 10.0, *) {
                            request1 = ActivityFeedData.fetchRequest() as! NSFetchRequest<ActivityFeedData>
                        } else {
                            request1 = NSFetchRequest(entityName: "ActivityFeedData")
                        }
                        
                        request1.returnsObjectsAsFaults = false
                        let results1 = try? context.fetch(request1)
                        if(results1?.count>0){
                            
                            // If exist than Delete all entries
                            for result: AnyObject in results1! {
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
    
    
    //    override func viewWillDisappear(animated: Bool) {
    //
    //        mainView.removeGestureRecognizer(tapGesture)
    //       //  searchDic.removeAll(keepingCapacity: false)
    //    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
