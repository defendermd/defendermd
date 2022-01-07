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
//  SetPrivacyViewController.swift
//  SocailEngineDemoForSwift
//

import UIKit
import Foundation
import CoreData
var arrayPrivacy = [String]()
var setEditPrivacy = ""
class SetPrivacyViewController: UIViewController , UITableViewDataSource, UITableViewDelegate{
    let mainView = UIView()
    var showSpinner = true                      // not show spinner at pull to refresh
    var privacyTableView:UITableView!              // TAbleView to show the blog Contents
    var refresher:UIRefreshControl!             // Pull to refrresh
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var dynamicHeight:CGFloat = 40              // Dynamic Height fort for Cell
    var showOnlyMyContent = false
    var delete:Bool! = false
    var count1 : Int!
    var settingArray : NSArray!
    var keysResponse = [AnyObject]()
    var valuesResponse = [AnyObject]()
    var leftBarButtonItem : UIBarButtonItem!
    
    
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
        
        let cancel = UIBarButtonItem(title: NSLocalizedString("Cancel",  comment: ""), style:.plain , target:self , action: #selector(SetPrivacyViewController.cancel))
        self.navigationItem.leftBarButtonItem = cancel
        navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "FontAwesome", size: FONTSIZELarge)!],for: UIControl.State())
        cancel.tintColor = textColorPrime
        
        mainView.frame = view.frame
        mainView.backgroundColor = bgColor
        view.addSubview(mainView)
        mainView.removeGestureRecognizer(tapGesture)
        
        // makeSettingsArray()
        self.title = NSLocalizedString("Privacy Settings",  comment: "")
        
        
        
        // Initialize Blog Table
        privacyTableView = UITableView(frame: CGRect(x: 0, y: 0 , width: view.bounds.width, height: view.bounds.height), style: .grouped)
        privacyTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        privacyTableView.dataSource = self
        privacyTableView.delegate = self
        privacyTableView.estimatedRowHeight = 40.0
        privacyTableView.rowHeight = UITableView.automaticDimension
        privacyTableView.backgroundColor = tableViewBgColor
        privacyTableView.separatorColor = TVSeparatorColor
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            privacyTableView.estimatedRowHeight = 0
            privacyTableView.estimatedSectionHeaderHeight = 0
            privacyTableView.estimatedSectionFooterHeight = 0
        }
        mainView.addSubview(privacyTableView)
        
        getPrivacyDetail()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
        }
        
        
    }
    
    func getPrivacyDetail(){
        if  let privacy = postPermission["userprivacy"] as? NSDictionary{
            let allkeys = privacy.allKeys
            self.keysResponse = allkeys as [AnyObject]
            self.valuesResponse = privacy.allValues as [AnyObject]
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
    
    // Set Settings Tabel Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (limit*pageNumber < totalItems){
            return 80
            
        }else{
            return 0.00001
        }
    }
    
    // Set Settings Tabel Header Height
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
    
    // Set Settings Section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.valuesResponse.count
    }
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
        
    {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle , reuseIdentifier: "Cell")
        
        cell.accessoryView = nil
        
        var FontIconLabelString = "\u{f10c}"
        
        
//        if arrayPrivacy.contains(keysResponse[(indexPath as NSIndexPath).row] as! String){
//
//            FontIconLabelString = "\u{f058}"
//            UserDefaults.standard.setValue(keysResponse[(indexPath as NSIndexPath).row] as? String, forKey: "privacy")
//        }
//        else{
//            FontIconLabelString = "\u{f10c}"
//
//        }
        
        if  keysResponse[(indexPath as NSIndexPath).row] as? String == UserDefaults.standard.string(forKey: "privacy"){
             UserDefaults.standard.setValue(keysResponse[(indexPath as NSIndexPath).row] as? String, forKey: "privacy")
            FontIconLabelString = "\u{f058}"
        }
        
//        if let privacyString = UserDefaults.standard.string(forKey: "privacy"){
//            if privacyString == keysResponse[(indexPath as NSIndexPath).row] as! String {
//                FontIconLabelString = "\u{f058}"
//            }else{
//                FontIconLabelString = "\u{f10c}"
//            }
//
//        }
//
        let labelString =  valuesResponse[(indexPath as NSIndexPath).row] as! String
        let attrString: NSMutableAttributedString = NSMutableAttributedString(string: "\(FontIconLabelString)  ")
        attrString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "FontAwesome" , size: 15.0)!, range: NSMakeRange(0, attrString.length))
        attrString.addAttribute(NSAttributedString.Key.foregroundColor , value: navColor, range: NSMakeRange(0, attrString.length))
        
        let descString: NSMutableAttributedString = NSMutableAttributedString(string: labelString)
        descString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: fontName , size: 16.0)!, range: NSMakeRange(0, descString.length))
        
        attrString.append(descString);
        cell.textLabel?.attributedText = attrString

        return cell
        
    }
    // Handle Settings Table Cell Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
       
        //print(keysResponse[(indexPath as NSIndexPath).row])
        
        if keysResponse[(indexPath as NSIndexPath).row] as! String == "network_list_custom" {
            
            let presentedVC = MultiplePrivacyViewController()
            if let _ = postPermission["multiple_networklist"] as? NSNull {
            }
            else {
                presentedVC.privacyArray = postPermission["multiple_networklist"] as! [AnyObject]
            }
            presentedVC.contentType = "network_list_custom"
            setEditPrivacy = "network_list_custom"
            self.navigationController?.pushViewController(presentedVC, animated: true)
        }
        else if  keysResponse[(indexPath as NSIndexPath).row] as! String == "friend_list_custom"{
            
            let presentedVC = MultiplePrivacyViewController()
            if postPermission["userlist"] != nil {
                presentedVC.privacyArray = postPermission["userlist"] as! [AnyObject]
            }
            presentedVC.contentType = "friend_list_custom"
            setEditPrivacy = "friend_list_custom"
            self.navigationController?.pushViewController(presentedVC, animated: true)
            
            //print("====Done1===")
            
        }
        else{
            UserDefaults.standard.setValue(keysResponse[(indexPath as NSIndexPath).row] as! String, forKey: "privacy")
            arrayPrivacy.removeAll()
            setEditPrivacy = keysResponse[(indexPath as NSIndexPath).row] as! String
            //UserDefaults.standard.setValue(keysResponse[(indexPath as NSIndexPath).row] as! String, forKey: "privacy")
            arrayPrivacy.append(keysResponse[(indexPath as NSIndexPath).row] as! String)
        cancel()
        }
    }
    
     override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func cancel(){
       dismiss(animated: true, completion: nil)
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
