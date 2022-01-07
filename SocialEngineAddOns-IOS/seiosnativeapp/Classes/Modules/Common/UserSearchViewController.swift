//
//  UserSearchViewController.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 02/01/18.
//  Copyright © 2018 bigstep. All rights reserved.
//

import UIKit

class UserSearchViewController: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate, UITableViewDelegate,UITableViewDataSource
{
    var sendMsg:UIBarButtonItem!
    var searchLabel: UITextField!
    var searchString : String!
    var userArray : NSMutableArray!
    var searchTable: UITableView!
    var userDic : NSDictionary!
    var iscomingFrom:String = ""
    var popAfterDelay:Bool!
    var button : UIButton!
   // var navView = UIView()
   // var titleLabel = UILabel()
    var leftBarButtonItem : UIBarButtonItem!
    var Url: String?
    var info:UILabel!
    var defaultHostValue = ""
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barTintColor = UIColor.white
        
        popAfterDelay = false
 
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(UserSearchViewController.cancel))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        
        button   = UIButton(type: UIButton.ButtonType.system) as UIButton
        button.frame = CGRect(x: self.view.bounds.size.width-100, y: 0, width: 20, height: 20)
        button.backgroundColor = UIColor.clear
        button.setImage(UIImage(named: "Checkmark.png")!.maskWithColor(color: textColorPrime), for: UIControl.State())
        button.addTarget(self, action: #selector(UserSearchViewController.send), for: UIControl.Event.touchUpInside)
        button.isHidden = true
        let sendButton = UIBarButtonItem()
        
        sendButton.customView = button
        self.navigationItem.setRightBarButtonItems([sendButton], animated: true)
        
        
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UserSearchViewController.resignKeyboard))
        tap.delegate = self
        tap.cancelsTouchesInView = false;
        view.addGestureRecognizer(tap)
        
        
        searchLabel = createTextField(CGRect(x: PADING, y: TOPPADING, width: view.bounds.width - (2 * PADING ), height: 40), borderColor: borderColorClear , placeHolderText: NSLocalizedString("Type Member Name",  comment: ""), corner: true)
        searchLabel.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Type Member Name",  comment: ""), attributes: [NSAttributedString.Key.foregroundColor: placeholderColor])
        searchLabel.addTarget(self, action: #selector(UserSearchViewController.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        searchLabel.font =  UIFont(name: fontName, size: FONTSIZELarge)
        searchLabel.backgroundColor = bgColor
        searchLabel.delegate = self
        searchLabel.layer.masksToBounds = true
        view.addSubview(searchLabel)
        searchLabel.becomeFirstResponder()
        
        
        
        let lineView1 = UIView(frame: CGRect(x: PADING,y: self.searchLabel.frame.size.height+self.searchLabel.frame.origin.y ,width: self.searchLabel.frame.size.width,height: 0.5))
        lineView1.layer.borderWidth = 0.5
        lineView1.layer.borderColor = textColorMedium.cgColor
        self.view.addSubview(lineView1)
        
        
        searchTable = UITableView(frame: (CGRect(x: searchLabel.bounds.origin.x,y: searchLabel.frame.origin.y+searchLabel.frame.size.height+1, width: searchLabel.bounds.size.width, height: view.bounds.height-(searchLabel.bounds.origin.x + searchLabel.frame.size.height+5 + tabBarHeight) )), style: UITableView.Style.grouped)
        searchTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        searchTable.contentInset = UIEdgeInsets(top: -35, left: 0, bottom: 0, right: 0)
        searchTable.rowHeight = 35
        searchTable.isHidden = true
        searchTable.isOpaque = false
        searchTable.backgroundColor = UIColor.white//tableViewBgColor
        view.addSubview(searchTable)
        
        if searchLabel.text == "" {
            self.button.isHidden = false
        }else{
            self.button.isHidden = true
        }
    
    }
    
    // Stop Timer
    @objc func stopTimer() {
        stop()
        
        if popAfterDelay == true
        {
            _ = navigationController?.popViewController(animated: true)
            
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        
        let navView = UIView()
        let titleLabel = UILabel()
        navView.frame = CGRect(x: 60, y: 0, width: self.view.frame.size.width-120, height: 44)
        navView.tag = 1001
        titleLabel.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width-120, height: self.navigationController!.navigationBar.frame.size.height)
        titleLabel.text = NSLocalizedString("Choose Host",  comment: "")
        titleLabel.textColor = textColorPrime
        titleLabel.font = UIFont(name: fontName, size: 18)
        //titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.textAlignment = .center
        
        navView.addSubview(titleLabel)
        //[self.navigationController.navigationBar addSubview:view]
        self.navigationController?.navigationBar.addSubview(navView)
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //titleLabel.text = ""
        self.navigationController?.navigationBar.viewWithTag(1001)?.removeFromSuperview()
    }
    
    func openSlideMenu()
    {
        self.view.endEditing(true)
        let dashObj = DashboardViewController()
        dashObj.getDynamicDashboard()
        dashObj.dashboardTableView.reloadData()
        // 
        openSideMenu = true
    }
    
    @objc func resignKeyboard()
    {
        self.view.endEditing(true)
    }
    

    @objc func cancel()

    {
        _ = self.navigationController?.popViewController(animated: true)
        
    }
    
    // MARK: TextFeild Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        
        self.view.endEditing(true)
        return true;
        
    }
    
    @objc func textFieldDidChange(_ textField: UITextField)
    {
        removeAlert()
//        spinner.center = view.center
//        spinner.hidesWhenStopped = true
//        spinner.style = UIstyle.gray
//        self.view.addSubview(spinner)
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.center = self.view.center
        activityIndicatorView.startAnimating()
        searchString = searchLabel.text

        var parameters = Dictionary<String, String>()
        //var method = ""
        if Url == "user/suggest"
        {
           parameters = ["search": searchString]
           // method = "GET"
        }
        else{
            parameters = ["host_auto": searchString,"host_type_select":"siteevent_organizer"]
           // method = "POST"
        }
        
        //url = "user/suggest"
        // Send Server Request to Explore Group Contents with Group_ID
        post(parameters, url: Url!, method: "GET") { (succeeded, msg) -> () in
            DispatchQueue.main.async(execute: {
                activityIndicatorView.stopAnimating()
                if msg
                {
                    if succeeded["message"] != nil
                    {
                        showToast(message: succeeded["message"] as! String, controller: self)
                        
                    }
                    if succeeded["body"] != nil
                    {
                        
                        if let contentInfo = succeeded["body"] as? NSArray
                        {
                            for ob in self.view.subviews{
                                if ob.tag == 1000{
                                    ob.removeFromSuperview()
                                    
                                }
                            }
                            if contentInfo.count>0
                            {
                                
                                self.userArray = contentInfo as! NSMutableArray
                                UIView.animate(withDuration: 0.7, delay: 0.0, options: .curveEaseOut, animations: {
                                    self.searchTable.isHidden = false
                                    self.searchTable.dataSource = self
                                    self.searchTable.delegate = self
                                    self.searchTable.reloadData()
                                    
                                }, completion: { finished in
                                    
                                })
                                
                            }
                            else{
                                if self.userArray != nil {
                                    self.userArray.removeAllObjects()
                                }
                                self.searchTable.reloadData()
                                self.info = createLabel(CGRect(x: 0, y: self.view.center.y,width: self.view.bounds.width , height: 60), text: NSLocalizedString("You don't have any related entries, add a host now",  comment: "") , alignment: .center, textColor: textColorMedium)
                                self.info.numberOfLines = 0
                                self.info.lineBreakMode = NSLineBreakMode.byWordWrapping
                                self.info.center = self.view.center
                                self.info.backgroundColor = textColorclear
                                self.info.tag = 1000
                                self.view.addSubview(self.info)
 
                            }
                            
                        }
                    }
                    
                }
                else
                {
                    if self.userArray != nil {
                        self.userArray.removeAllObjects()
                    }
                    self.searchTable.reloadData()
                }
                
            })
        }
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let  char = string.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")
        
        if (isBackSpace == -92) {
            //            searchLabel.text = ""
        }
        
        if searchLabel.text == "" {
            self.button.isHidden = false
        }else{
            self.button.isHidden = true
            
        }
        
        return true
    }
    
    // MARK:  UITableViewDelegate & UITableViewDataSource
    
    // Set Tabel Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        
        return 0.00001
        
    }
    
    // Set Tabel Header Height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 0.00001
    }
    
    // Set TableView Section
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        
        return 35.0
        
        
    }
    
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if userArray.count>0
        {
            return userArray.count
        }
        else
        {
            return 0
        }
    }
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = UITableViewCell.SelectionStyle.blue
        let dic = userArray.object(at: (indexPath as NSIndexPath).row) as! NSDictionary
        if Url == "user/suggest"
        {
            cell.textLabel?.text = dic["label"] as? String
        }
        else{
            cell.textLabel?.text = dic["host_title"] as? String
        }
        
        return cell
        
    }
    
    // Handle Blog Table Cell Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        userDic = userArray.object(at: (indexPath as NSIndexPath).row) as! NSDictionary
        if Url == "user/suggest"
        {
            searchLabel.text = userDic["label"] as? String
            defaultHostValue = userDic["label"] as! String
            hostDictionary["host_type_select"] = "user"
            hostDictionary["host_auto"] = String(userDic["id"] as! Int)
        }
        else{
            searchLabel.text = userDic["host_title"] as? String
            defaultHostValue = userDic["host_title"] as! String
            hostDictionary["host_type_select"] = "siteevent_organizer"
            hostDictionary["host_auto"] = String(userDic["host_id"] as! Int)
        }
        
        if let _ = hostDictionary["host_title"]
        {
           hostDictionary.removeValue(forKey: "host_title")
        }
        if let _ = hostDictionary["host_description"]
        {
            hostDictionary.removeValue(forKey: "host_description")
        }
        //print(hostDictionary)
        self.searchTable.isHidden = true
        defaultHostValue = self.searchLabel.text!
        self.view.endEditing(true)
        self.searchTable.isHidden = true
        if Formbackup["host"] != nil
        {
            Formbackup["host"] = defaultHostValue
        }
        
        for vc in (self.navigationController?.viewControllers ?? []) {
            if vc is FormGenerationViewController {
                _ = self.navigationController?.popToViewController(vc, animated: true)
                break
            }
        }
        
        
    }
    

    @objc func send()

    {
//        defaultlocation = searchLabel.text!
//        self.view.endEditing(true)
//        self.searchTable.isHidden = true
//        let defaults = UserDefaults.standard
//        
//        defaults.set(defaultlocation, forKey: "Location")
//        self.view.makeToast("Your location has been updated successfully.", duration: 5, position: "bottom")
//        self.popAfterDelay = true
//       self.createTimer(self)
        
        
    }
    
}
