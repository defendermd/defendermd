//
//  MultiplePrivacyViewController.swift
//  seiosnativeapp
//
//  Created by bigstep on 16/04/18.
//  Copyright © 2018 bigstep. All rights reserved.
//

import UIKit

class MultiplePrivacyViewController: UIViewController , UITableViewDataSource, UITableViewDelegate{
    
    var privacyArray = [AnyObject]()
    var privacyTableView:UITableView!
    var dynamicHeight : CGFloat = 0.0
    var contentType = ""
    var localPrivacy = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        //print(privacyArray)
        view.backgroundColor = bgColor
        self.title = NSLocalizedString("Privacy Settings",  comment: "")
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(MultiplePrivacyViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        let button   = UIButton(type: UIButton.ButtonType.system) as UIButton
        button.frame = CGRect(x: self.view.bounds.size.width-100,y: 0,width: 18,height: 18)
        button.backgroundColor = UIColor.clear
        let loctionimg = UIImage(named: "checkmark.png")!.maskWithColor(color: textColorPrime)
        button.setImage(loctionimg , for: UIControl.State.normal)
        button.addTarget(self, action: #selector(MultiplePrivacyViewController.submit), for: UIControl.Event.touchUpInside)
        let locButton = UIBarButtonItem()
        locButton.customView = button
        self.navigationItem.setRightBarButtonItems([locButton], animated: true)
        
        localPrivacy = arrayPrivacy
        arrayPrivacy.removeAll()
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
        view.addSubview(privacyTableView)
        
        if privacyArray.count == 0 {
            showToast(message: "no listing available", controller: self)
        }

        // Do any additional setup after loading the view.
    }
    @objc func submit(){
    
        if arrayPrivacy.count > 0 {
            let arr =  arrayPrivacy.removeDuplicates()
            arrayPrivacy = arr
            //print(arrayPrivacy)
            
        UserDefaults.standard.setValue(contentType, forKey: "privacy")
        
        dismiss(animated: false, completion: nil)
        }
        else{
            showToast(message: "please select any fields", controller: self)
            //print("please select values")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
       
            return 0.00001
        
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
        return privacyArray.count
    }
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
        
    {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle , reuseIdentifier: "Cell")
        
        let row = (indexPath as NSIndexPath).row as Int
        cell.accessoryView = nil
        var privacyInfo:NSDictionary
       
        
        privacyInfo = privacyArray[row] as! NSDictionary
//        if arrayPrivacy.contains(privacyInfo["name"] as! String){
//
//            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
//        }
//        else{
//            cell.accessoryType = UITableViewCell.AccessoryType.none
//
//        }
        cell.textLabel?.text = privacyInfo["label"] as? String
        
        
        return cell
        
    }
    // Handle Settings Table Cell Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       // let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle , reuseIdentifier: "Cell")
        let cell: UITableViewCell = tableView.cellForRow(at: indexPath)!
        let row = (indexPath as NSIndexPath).row as Int
        var privacyInfo:NSDictionary
       
        
        privacyInfo = privacyArray[row] as! NSDictionary
        if (cell.accessoryType == UITableViewCell.AccessoryType.none) {
            
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
            arrayPrivacy.append(String(describing: privacyInfo["name"] as AnyObject))
            //print(arrayPrivacy)
        }
        else{
            cell.accessoryType = UITableViewCell.AccessoryType.none
            if let index = arrayPrivacy.index(of: String(describing: privacyInfo["name"] as AnyObject)) {
                arrayPrivacy.remove(at: index)
            }
            
            //print("====final")
            //print(arrayPrivacy)
            
        }
        tableView.deselectRow(at: indexPath, animated: true)
       // UserDefaults.standard.setValue(keysResponse[(indexPath as NSIndexPath).row] as! String, forKey: "privacy")
        
       
    }
    @objc func goBack()
    {
        arrayPrivacy.removeAll()
        arrayPrivacy = localPrivacy
         dismiss(animated: false, completion: nil)
      //  _ = self.navigationController?.popViewController(animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension Array where Element:Equatable {
    func removeDuplicates() -> [Element] {
        var result = [Element]()
        
        for value in self {
            if result.contains(value) == false {
                result.append(value)
            }
        }
        
        return result
    }
}
