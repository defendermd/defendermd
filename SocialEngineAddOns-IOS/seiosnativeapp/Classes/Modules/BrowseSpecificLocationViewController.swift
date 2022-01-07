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
//  BrowseSpecificLocationViewController.swift
//  seiosnativeapp

import UIKit

class BrowseSpecificLocationViewController: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource
{
    var sendMsg:UIBarButtonItem!
    var loctextfeild: UITextField!
    var locbtn: UIButton!
    var loc : String!
    var locationArray:NSArray!
    var locationTable: UITableView!
    var locDic : NSDictionary!
    var iscomingFrom:String = ""
    var popAfterDelay:Bool!
    var leftBarButtonItem : UIBarButtonItem!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barTintColor = UIColor.white

        
        self.title = NSLocalizedString("Search Location",  comment: "")
        
        
        if iscomingFrom == "feed"
        {
            let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            leftNavView.backgroundColor = UIColor.clear
            let tapView = UITapGestureRecognizer(target: self, action: #selector(BrowseSpecificLocationViewController.cancel))
            leftNavView.addGestureRecognizer(tapView)
            let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
            backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
            leftNavView.addSubview(backIconImageView)
            
            let barButtonItem = UIBarButtonItem(customView: leftNavView)
            self.navigationItem.leftBarButtonItem = barButtonItem

        }

        
        let button   = UIButton(type: UIButton.ButtonType.system) as UIButton
        button.frame = CGRect(x: self.view.bounds.size.width-100, y: 0, width: 20, height: 20)
        button.backgroundColor = UIColor.clear
        button.setImage(UIImage(named: "Checkmark.png")!.maskWithColor(color: textColorPrime), for: UIControl.State())
        button.addTarget(self, action: #selector(BrowseSpecificLocationViewController.send), for: UIControl.Event.touchUpInside)
        let sendButton = UIBarButtonItem()
        
        sendButton.customView = button
        sendButton.tintColor = textColorPrime
        self.navigationItem.setRightBarButtonItems([sendButton], animated: true)
        

        loctextfeild = createTextField(CGRect(x: PADING, y: TOPPADING, width: view.bounds.width - (2 * PADING ), height: 40), borderColor: borderColorClear , placeHolderText: NSLocalizedString("Select location",  comment: ""), corner: true)
        loctextfeild.attributedPlaceholder = NSAttributedString(string: "Select location", attributes: [NSAttributedString.Key.foregroundColor: placeholderColor])
        loctextfeild.addTarget(self, action: #selector(BrowseSpecificLocationViewController.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        loctextfeild.font =  UIFont(name: fontName, size: FONTSIZELarge)
        loctextfeild.backgroundColor = bgColor
        loctextfeild.layer.masksToBounds = true
        loctextfeild.isUserInteractionEnabled = false
        view.addSubview(loctextfeild)
        
        locbtn  = createButton(CGRect(x: PADING, y: TOPPADING, width: view.bounds.width - (2 * PADING ), height: 40), title: "", border: false,bgColor: false,textColor: UIColor.clear)
        locbtn.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZELarge)
        locbtn.addTarget(self, action: #selector(BrowseSpecificLocationViewController.selectlocation), for: .touchUpInside)
        view.addSubview(locbtn)
        
        let defaults = UserDefaults.standard
        if let name = defaults.string(forKey: "Location")
        {
            
            loctextfeild.text = "\(name)"
            
        }
        else if defaultlocation != nil && defaultlocation != ""
        {
            loctextfeild.text = "\(defaultlocation)"
        }
        
        let lineView1 = UIView(frame: CGRect(x: PADING,y: self.loctextfeild.frame.size.height+self.loctextfeild.frame.origin.y ,width: self.loctextfeild.frame.size.width,height: 1))
        lineView1.layer.borderWidth = 1.0
        lineView1.layer.borderColor = textColorMedium.cgColor
        self.view.addSubview(lineView1)
        
        
        locationTable = UITableView(frame: (CGRect(x: loctextfeild.bounds.origin.x,y: loctextfeild.frame.origin.y+loctextfeild.frame.size.height+1, width: loctextfeild.bounds.size.width, height: 100)), style: UITableView.Style.grouped)
        locationTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        locationTable.contentInset = UIEdgeInsets(top: -30, left: 0, bottom: 0, right: 0)
        locationTable.rowHeight = 25
        locationTable.isHidden = true
        locationTable.isOpaque = false
        //locationTable.separatorStyle = UITableViewCell.SeparatorStyle.None
        locationTable.backgroundColor = UIColor.white//tableViewBgColor
        view.addSubview(locationTable)
   
        
    }
    
    @objc func stopTimer() {
        stop()
        
        if popAfterDelay == true
        {
            _ = navigationController?.popViewController(animated: true)

        }
    }
    
    func openSlideMenu(){
        self.view.endEditing(true)
        let dashObj = DashboardViewController()
        dashObj.getDynamicDashboard()
        dashObj.dashboardTableView.reloadData()
     //    
        openSideMenu = true
        
        
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
        loc = loctextfeild.text
        var url = ""
        let parameters = ["suggest": "\(loc)"]
        url = "location-suggest"
        // Send Server Request to Explore Group Contents with Group_ID
        post( parameters, url: url, method: "POST") { (succeeded, msg) -> () in
            
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
                            if contentInfo.count>0
                            {
                                self.locationArray = contentInfo
                                UIView.animate(withDuration: 0.7, delay: 0.0, options: .curveEaseOut, animations: {
                                    self.locationTable.isHidden = false
                                    self.locationTable.dataSource = self
                                    self.locationTable.delegate = self
                                    self.locationTable.reloadData()
                                    
                                    }, completion: { finished in

                                        
                                })
                            }
                        }
                    }
                    
                }
                
            })
        }
        
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let  char = string.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")
        
        if (isBackSpace == -92) {
            loctextfeild.text = ""
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
        
        return 25.0
        
        
    }
    
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if locationArray.count>0
        {
            return locationArray.count
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
        cell.textLabel?.text = locationArray.object(at: (indexPath as NSIndexPath).row) as? String
        return cell
    }
    
    // Handle Blog Table Cell Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        loctextfeild.text = locationArray.object(at: (indexPath as NSIndexPath).row) as? String
        UIView.animate(withDuration: 0.7, delay: 0.0, options: .curveEaseOut, animations: {
            
            self.locationTable.isHidden = true
            }, completion: { finished in
                
        })
        
    }
    
    @objc func selectlocation()
    {
        let dic = Locationdic["restapilocation"] as! NSDictionary
        
        
        var arr = [String]()
        for (key, _) in dic {
            arr.append("\(key)")
        }
        
        if arr.count>0
        {
            locationArray = arr as NSArray?
            UIView.animate(withDuration: 0.7, delay: 0.0, options: .curveEaseOut, animations: {
                self.locationTable.isHidden = false
                self.locationTable.dataSource = self
                self.locationTable.delegate = self
                self.locationTable.reloadData()
                
                }, completion: { finished in
                    
            })
        }
        
    }
    func createTimer(_ target: AnyObject){
        timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  #selector(stopTimer), userInfo: nil, repeats: false)
    }
    @objc func send()
    {
        defaultlocation = loctextfeild.text!
        let defaults = UserDefaults.standard
        self.view.endEditing(true)
        self.locationTable.isHidden = true
        defaults.set("\(defaultlocation)", forKey: "Location")
        showToast(message: "Your location has been updated successfully.", controller: self)
        self.popAfterDelay = true
       self.createTimer(self)
        
    }
    
}
