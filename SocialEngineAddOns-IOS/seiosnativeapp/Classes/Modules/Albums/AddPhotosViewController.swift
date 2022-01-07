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

//  SignUpValidationController.swift

import UIKit
import Foundation

class AddPhotosViewController: UIViewController , UITableViewDataSource, UITableViewDelegate , UISearchBarDelegate {
    let mainView = UIView()
    var showSpinner = true                      // not show spinner at pull to refresh
    var validationTableViewButton:UITableView!              // TAbleView to show the Validation Contents
    var refresher:UIRefreshControl!             // Pull to refrresh
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var dynamicHeight:CGFloat = 50              // Dynamic Height fort for Cell
    var showOnlyMyContent = false
    var validationArray: NSArray!
    
    // Initialization of class Object
    override func viewDidLoad() {
        view.backgroundColor = bgColor
        navigationController?.navigationBar.hidden = false
        
        // Define Navigation Controller
        self.navigationController?.navigationBar.setBackgroundImage(imagefromColor(navColor), forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = imagefromColor(navColor)
        self.navigationController?.navigationBar.translucent = true
        self.navigationController?.navigationBar.tintColor = textColorLight
        let leftNavView = UIView(frame: CGRectMake(0, 0, 44, 44))
        leftNavView.backgroundColor = UIColor.clearColor()
        
        let tapView = UITapGestureRecognizer(target: self, action: Selector("openSlideMenu"))
        leftNavView.addGestureRecognizer(tapView)
        
        let menuImageView = createImageView(CGRectMake(0,12,22,22), border: false)
        menuImageView.image = UIImage(named: "dashboard_icon")
        leftNavView.addSubview(menuImageView)
        
        if (logoutUser == false && (totalNotificationCount !=  nil) && (totalNotificationCount > 0)) {
            let countLabel = createLabel(CGRectMake(17,3,17,17), text: "\(totalNotificationCount)", alignment: .Center, textColor: textColorLight)
            countLabel.backgroundColor = UIColor.redColor()
            countLabel.layer.cornerRadius = countLabel.frame.size.width / 2;
            countLabel.layer.masksToBounds = true
            countLabel.font = UIFont(name: "fontAwesome", size: FONTSIZENormal)
            leftNavView.addSubview(countLabel)
        }
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        

        print(validationArray)
        print("validationArray")
        super.viewDidLoad()
        searchDic.removeAll(keepCapacity: false)
        view.backgroundColor = bgColor
        navigationController?.navigationBar.hidden = false
        openMenu = false
        updateAfterAlert = true
        
        mainView.frame = view.frame
        mainView.backgroundColor = bgColor
        view.addSubview(mainView)
        mainView.removeGestureRecognizer(tapGesture)
        self.title = NSLocalizedString("Settings",  comment: "")
        validationTableViewButton = UITableView(frame: CGRectMake(30, TOPPADING + 70, CGRectGetWidth(view.bounds) - 30, CGRectGetHeight(view.bounds)-(TOPPADING + 70)), style: .Grouped)
        validationTableViewButton.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        validationTableViewButton.dataSource = self
        validationTableViewButton.delegate = self
        validationTableViewButton.estimatedRowHeight = 30.0
        validationTableViewButton.rowHeight = UITableViewAutomaticDimension
        validationTableViewButton.backgroundColor = tableViewBgColor
        validationTableViewButton.separatorColor = TVSeparatorColor
        mainView.addSubview(validationTableViewButton)
    }
    
    // Show Slide Menu
    func openSlideMenu(){
        toggleSideMenuView()
    }
    
    // Stop Timer
    func stopTimer() {
        stop()
    }
    
    // MARK:  UITableViewDelegate & UITableViewDataSource
    
    // Set Validation Table Footer Height
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (limit*pageNumber < totalItems){
            return 80
            
        }else{
            return 0.00001
        }
    }
    
    // Set Validation Table Header Height
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if  (UIDevice.currentDevice().userInterfaceIdiom == .Phone){
            dynamicHeight = 30.0
        }else{
            dynamicHeight = 40.0
        }
        return dynamicHeight
    }
    
    // Set Validation Section
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // Set No. of Rows in Section
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.validationArray.count
    }
    
    // Set Cell of TabelView
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
        
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        cell.imageView?.image = UIImage(named: "error.ico")
        cell.textLabel?.text = self.validationArray[indexPath.row] as? String
        return cell
    }
    
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
