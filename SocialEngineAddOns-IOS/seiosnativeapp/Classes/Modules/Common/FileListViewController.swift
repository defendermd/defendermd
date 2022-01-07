//
//  FileListViewController.swift
//  seiosnativeapp
//
//  Created by Vidit Paliwal on 13/03/18.
//  Copyright © 2018 bigstep. All rights reserved.
//

import Foundation
import UIKit

class FileListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    var contentType : String!
    var url : String!
    var FileListTableview : UITableView!
    var responseArr : NSArray!
    var dynamicHeight : CGFloat = 230
    var contentGutterMenu : NSArray = []
    var leftBarButtonItem : UIBarButtonItem!
    var contentId : Int!
    var storeID : String!
    var productID : String!
    var urlParams : NSDictionary!
    var popAfterDelay : Bool!
    var uploadUrl : String!
    var deleteFileEntry:Bool!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.view.backgroundColor = bgColor
        popAfterDelay = false
        FileListTableview = UITableView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height), style: .grouped)
        FileListTableview.register(FileListTableViewCell.self, forCellReuseIdentifier: "Cell")
        FileListTableview.estimatedRowHeight = 60.0
        FileListTableview.separatorStyle = UITableViewCell.SeparatorStyle.none
        FileListTableview.contentInset = UIEdgeInsets(top: -35, left: 0, bottom: 0, right: 0)
        FileListTableview.backgroundColor = tableViewBgColor
        self.FileListTableview.isOpaque = false
        self.view.addSubview(FileListTableview)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barTintColor = UIColor.white
        setNavigationImage(controller: self)
        if self.contentType == "mainFile"
        {
            self.title = NSLocalizedString("Main Files", comment: "")
        }
        else if self.contentType == "sampleFile"
        {
            self.title = NSLocalizedString("Sample Files", comment: "")
        }
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(FileListViewController.cancel))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        
        exploreContent()
    }
    
    @objc func addFile()
    {

        let presentedVC = FormGenerationViewController()
        presentedVC.url = uploadUrl
        if self.contentType == "mainFile"
        {
            presentedVC.formTitle = "Upload Main File"
            presentedVC.contentType = "mainFile"
        }
        else if self.contentType == "sampleFile"
        {
            presentedVC.formTitle = "Upload Sample File"
            presentedVC.contentType = "sampleFile"
        }
        
        presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        let nativationController = UINavigationController(rootViewController: presentedVC)
        self.present(nativationController, animated:false, completion: nil)

    }
    
    @objc func cancel()
    {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        
        return 0.00001
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
            return 0.0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return dynamicHeight
    }
    
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        return responseArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FileListTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.backgroundColor = UIColor.clear
        let dic = responseArr.object(at: (indexPath as NSIndexPath).row)
        let fileResponseDic = dic as! NSDictionary
        let fileDic = fileResponseDic["file"] as? NSDictionary
        
        let titleDic = fileDic!["title"] as? NSDictionary
        if titleDic != nil
        {
            let title = titleDic!["value"] as? String
            if title != nil
            {
                cell.fileTitle.text = "File Title : "+title!
            }
        }
        
        let downloadDic = fileDic!["download_limit"] as? NSDictionary
        if downloadDic != nil
        {
            let downLimit = downloadDic!["value"] as? Int
            if downLimit != nil
            {
                cell.downloadTitle.text = "Max Downloads : "+String(describing: downLimit!)
                if downLimit == 0
                {
                    cell.downloadTitle.text = "Max Download : Unlimited"
                }
            }
            else
            {
                cell.downloadTitle.text = "Max Download : Unlimited"
            }
        }
        
        let typeDic = fileDic!["extension"] as? NSDictionary
        if typeDic != nil
        {
            let filetypeName = typeDic!["value"] as? String
            if filetypeName != nil
            {
                cell.extensionTitle.text = "File Extension : "+filetypeName!
            }
        }
        
        let statusDic = fileDic!["status"] as? NSDictionary
        if statusDic != nil
        {
            let status = statusDic!["value"] as? Int
            if status != nil
            {
                if status == 1
                {
                    cell.statusTtile.text = "File Status : Active"
                }
                else
                {
                    cell.statusTtile.text = "File Status : Inactive"
                }
            }
            let status2 = statusDic!["value"] as? String
            if status2 != nil
            {
                cell.statusTtile.text = "File Status : Inactive"
            }
        }
        
        cell.btnMenu.tag = (indexPath as NSIndexPath).row
        cell.btnMenu.addTarget(self, action: #selector(FileListViewController.showGutterMenuOptions(_:)), for: .touchUpInside)
        
        
        return cell
    }
    
    @objc func showGutterMenuOptions(_ sender: UIButton)
    {
        print("gutter menu options to be displayed!")
        var fileInfo : NSDictionary!
        fileInfo = responseArr[sender.tag] as! NSDictionary
        let fileDic = fileInfo["file"] as? NSDictionary
        
        if let guttermenu2 = fileDic?["menu"] as? NSArray
        {
            self.contentGutterMenu = guttermenu2 as NSArray
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
            for menu in contentGutterMenu
            {
                if let menuItem = menu as? NSDictionary
                {
                    var actionUrl = ""
                    var titleString = ""
                    var params : NSDictionary = [:]
                    if let actionurl = menuItem["url"] as? String
                    {
                        actionUrl = actionurl
                    }
                    if let param = menuItem["urlParams"] as? NSDictionary
                    {
                        params = param
                    }
                    if let titlestring = menuItem["name"] as? String
                    {
                        titleString = titlestring
                    }
                    if titleString.range(of: "delete") != nil
                    {
                        alertController.addAction(UIAlertAction(title: (menuItem["label"] as! String), style: UIAlertAction.Style.destructive, handler:{ (UIAlertAction) -> Void in
                            
                            let condition = menuItem["name"] as! String
                            switch(condition)
                            {
                                
                            case "delete_file":
                                
                                displayAlertWithOtherButton(NSLocalizedString("Delete File", comment: ""),message: NSLocalizedString("Are you sure you want to delete this File?",comment: "") , otherButton: NSLocalizedString("Delete File", comment: "")) { () -> () in
                                    self.deleteFileEntry = true
                                    self.performFileAction(params : params as NSDictionary, url: actionUrl )
                                    
                                    }
                                
                                    self.present(alert, animated: true, completion: nil)
                                
                            default:
                                
                                showToast(message: unconditionalMessage, controller: self)
                                
                            }
                        }))
                    }
                    else
                    {
                        alertController.addAction(UIAlertAction(title: (menuItem["label"] as! String), style: .default, handler:{ (UIAlertAction) -> Void in
                            let condition = menuItem["name"] as! String
                            
                            switch(condition)
                            {
                            case "edit_file":
                                let presentedVC = FormGenerationViewController()
                                presentedVC.param = (menuItem["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                presentedVC.contentType = "editFile"
                                presentedVC.formTitle = "Edit File"
                                isCreateOrEdit = false
                                presentedVC.url = actionUrl
                                //presentedVC.storeId = self.storeID
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:false, completion: nil)
                            case "disable_file":
                                self.performFileAction(params: params as NSDictionary, url: actionUrl)
                                self.deleteFileEntry = false
                            case "enable_file":
                                self.performFileAction(params: params as NSDictionary, url: actionUrl)
                                self.deleteFileEntry = false
                            case "download":
                                let url = menuItem["downloadUrl"] as! String
                                let fileUrl = URL(string: url)
                                if UIApplication.shared.canOpenURL(fileUrl!)
                                {
                                    UIApplication.shared.openURL(fileUrl!)
                                }
                            default:
                                showToast(message: unconditionalMessage, controller: self)
                            }
                            
                            
                        }))
                    }
                }
            }
            if  (UIDevice.current.userInterfaceIdiom == .phone)
            {
                alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .cancel, handler:nil))
            }
            else
            {
                // Present Alert as! Popover for iPad
                alertController.modalPresentationStyle = UIModalPresentationStyle.popover
                let popover = alertController.popoverPresentationController
                popover?.sourceView = UIButton()
                popover?.sourceRect = CGRect(x: view.bounds.width/2, y: view.bounds.height/2 , width: 1, height: 1)
                popover?.permittedArrowDirections = UIPopoverArrowDirection()
            }
            self.present(alertController, animated:true, completion: nil)
        }
    }
    
    func performFileAction(params: NSDictionary, url: String)
    {
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            var dic = Dictionary<String, String>()
            
            for (key, value) in params{
                
                if let id = value as? Int {
                    dic["\(key)"] = String(id as Int)
                }
                
                if let receiver = value as? NSString {
                    dic["\(key)"] = receiver as String
                }
            }
            
            var method:String
            
            if url.range(of:"delete") != nil{
                method = "DELETE"
            }else{
                method = "POST"
            }
            
            post(dic, url: "\(url)", method: method) { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute:  {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                        }
                        
                        if self.deleteFileEntry == true {
                            storeUpdate = true
                            storeDetailUpdate = true
                            productDetailUpdate = true
                            productUpdate = true
                            
                            //_ = self.dismiss(animated: false, completion: nil)
                            //_ = self.navigationController?.popViewController(animated: false)
                            //return
                            self.FileListTableview.reloadData()
                            self.exploreContent()
                        }
                        else
                        {
                            storeUpdate = true
                            storeDetailUpdate = true
                            productUpdate = true
                            productDetailUpdate = true
                            self.FileListTableview.reloadData()
                            self.exploreContent()
                            
                        }
                        
                        
                    }else{
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
            createTimer(self)
        }
    }
    func createTimer(_ target: AnyObject){
        timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  #selector(stopTimer), userInfo: nil, repeats: false)
    }
    @objc func stopTimer() {
        stop()
    }
    func exploreContent()
    {
        if Reachabable.isConnectedToNetwork()
        {
            removeAlert()
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            var parameters = Dictionary<String, String>()
            if urlParams != nil
            {
                for (key, value) in urlParams{
                    if let id = value as? Int
                    {
                        parameters["\(key)"] = String(id as Int)
                    }
                    if let receiver = value as? NSString
                    {
                        parameters["\(key)"] = receiver as String
                    }
                }
            }
            
            post(parameters, url: url, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async( execute: {
                    activityIndicatorView.stopAnimating()
                    
                    if msg
                    {
                        let addButton = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(FileListViewController.addFile))
                        self.navigationItem.rightBarButtonItem = addButton
                        
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        if succeeded["body"] != nil
                        {
                            
                            if let body = succeeded["body"] as? NSDictionary
                            {
//                                if let canUpload = body["canUpload"] as? Int
//                                {
//                                    if canUpload == 1 {
//                                        let addButton = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(FileListViewController.addFile))
//                                        self.navigationItem.rightBarButtonItem = addButton
//                                    }
//                                }
                                if let response = body["response"] as? NSArray
                                {
                                    self.responseArr = response
                                    self.FileListTableview.dataSource = self
                                    self.FileListTableview.delegate = self
                                    self.FileListTableview.isOpaque = false
                                    self.FileListTableview.isHidden = false
                                    self.FileListTableview.reloadData()
                                }
                                
                                let response2 = body["response"] as? NSArray
                                if response2?.count == 0 || response2 == nil
                                {
                                    self.responseArr = []
                                    showToast(message: "No File is available. Please add a file!", controller: self)
                                    self.FileListTableview.reloadData()
                                }
                                
                                if let upUrl = body["uploadurl"] as? String
                                {
                                    self.uploadUrl = upUrl
                                }
                            }
                        }
                    }
                    else{
                        
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                    }
                })
                
            }
        }
    }

}
