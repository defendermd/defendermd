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

class SignUpValidationController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let mainView = UIView()
    var showSpinner = true                      // not show spinner at pull to refresh
    var validationTableViewButton:UITableView!              // TAbleView to show the Validation Contents
    var refresher:UIRefreshControl!             // Pull to refrresh
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var dynamicHeight:CGFloat = 50              // Dynamic Height fort for Cell
    var showOnlyMyContent = false
    var validationArray: NSArray!
    var leftBarButtonItem : UIBarButtonItem!
    
    // Initialization of class Object
    override func viewDidLoad() {
        
        super.viewDidLoad()
        searchDic.removeAll(keepingCapacity: false)
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        openMenu = false
        updateAfterAlert = true
        
        mainView.frame = view.frame
        mainView.backgroundColor = bgColor
        view.addSubview(mainView)
        mainView.removeGestureRecognizer(tapGesture)
        self.title = NSLocalizedString("Settings",  comment: "")
        validationTableViewButton = UITableView(frame: CGRect(x: 0, y: TOPPADING , width: view.bounds.width, height: view.bounds.height-TOPPADING), style: .grouped)
        validationTableViewButton.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        validationTableViewButton.dataSource = self
        validationTableViewButton.delegate = self
        validationTableViewButton.estimatedRowHeight = 30.0
        validationTableViewButton.rowHeight = UITableView.automaticDimension
        validationTableViewButton.backgroundColor = tableViewBgColor
        validationTableViewButton.separatorColor = TVSeparatorColor
        mainView.addSubview(validationTableViewButton)
    }
 
    
    // Stop Timer
    @objc func stopTimer() {
        stop()
    }
    
    // MARK:  UITableViewDelegate & UITableViewDataSource
    
    // Set Validation Table Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (limit*pageNumber < totalItems){
            return 80
            
        }else{
            return 0.00001
        }
    }
    
    // Set Validation Table Header Height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if  (UIDevice.current.userInterfaceIdiom == .phone){
            dynamicHeight = 30.0
        }else{
            dynamicHeight = 40.0
        }
        return dynamicHeight
    }
    
    // Set Validation Section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.validationArray.count
    }
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
        
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
        cell.imageView?.image = UIImage(named: "error.ico")
        cell.textLabel?.text = self.validationArray[(indexPath as NSIndexPath).row] as? String
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
