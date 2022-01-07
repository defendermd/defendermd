//
//  HostChangeViewControlle.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 29/12/17.
//  Copyright © 2017 bigstep. All rights reserved.
//

import UIKit
@objcMembers class HostChangeViewControlle: FXFormViewController {
    
    var hostSelectionFormArr = [AnyObject]()
    var temphostSelectionFormArr = [AnyObject]()
    // Initialization of class Object
    override func viewDidLoad() {
        super.viewDidLoad()
        
        defaultHostType = ""
        // Do any additional setup after loading the view.
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(HostChangeViewControlle.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            self.formController.tableView.estimatedSectionHeaderHeight = 0
        }
       // popAfterDelay = false
        self.title = NSLocalizedString("Host Detail", comment: "")
        conditionForm = "HostChange"
        conditionalForm = "HostChange"
        
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "userName")
        defaults.removeObject(forKey: "useId")
        
        temphostSelectionFormArr = hostSelectionFormArr
        temphostSelectionFormArr.remove(at: hostSelectionFormArr.count-2)
        generateSignUpProfileForm()
        
    }
    @objc func goBack() {
        
        self.navigationController?.popViewController(animated: false)
        
    }

    func checkBoxValueChanged(_ cell: FXFormFieldCellProtocol)
    {
        let form = cell.field.form as! CreateNewForm
        Form.removeAll(keepingCapacity: false)
        Form = hostCreateArr
        var index = Int()
        for i in 0 ..< (Form.count) where i < Form.count
        {
            let dic = Form[i] as! NSDictionary
            let name = dic["name"] as! String
            if name == "host_link"
            {
                index = i;
            }
            if (form.valuesByKey["\(name)"] != nil)
            {
                Formbackup["\(name)"] = form.valuesByKey["\(name)"]
            }
        }
        if form.valuesByKey["host_link"] as! Bool == true
        {
            
            for dic in hostCreateFormSocialArr
            {
                index += 1
                Form.insert(dic as AnyObject, at: index)
                
            }
            
            
        }
        self.formController.form = CreateNewForm()
        self.formController.tableView.reloadData()
    }
    
    // Host type changed
    func hostTypeChanged(_ cell: FXFormFieldCellProtocol)
    {
        let form = cell.field.form as! CreateNewForm
        for i in 0 ..< (Form.count) where i < Form.count
        {
            let dic = Form[i] as! NSDictionary
            let name = dic["name"] as! String
            if (form.valuesByKey["\(name)"] != nil)
            {
                Formbackup["\(name)"] = form.valuesByKey["\(name)"]
            }
            
        }
        if form.valuesByKey["host_type_select"] as! String == "Other Individual or Organization"
        {
            defaultHostType = form.valuesByKey["host_type_select"] as! String
            hostDictionary["host_type_select"] = findKeyForValue(form.valuesByKey["host_type_select"] as! String)
            Form = hostSelectionFormArr
            self.formController.form = CreateNewForm()
            
        }
        else
        {
            defaultHostType = form.valuesByKey["host_type_select"] as! String
            hostDictionary["host_type_select"] = findKeyForValue(form.valuesByKey["host_type_select"] as! String)
            Form = temphostSelectionFormArr//hostSelectionFormArr
            self.formController.form = CreateNewForm()
            
        }
        self.formController.tableView.reloadData()
    }
    func addHostAction(_ cell: FXFormFieldCellProtocol)
    {
        Form = hostCreateArr
        self.formController.form = CreateNewForm()
        self.formController.tableView.reloadData()
        
    }
    func cancelHostAction(_ cell: FXFormFieldCellProtocol)
    {
        
        self.navigationController?.popViewController(animated: false)
    }
    func cancelHostCreationAction(_ cell : FXFormFieldCellProtocol)
    {
        Form = hostSelectionFormArr
        self.formController.form = CreateNewForm()
        self.formController.tableView.reloadData()

    }
    func addHostCreationAction(_ cell : FXFormFieldCellProtocol)
    {
        let form = cell.field.form as! CreateNewForm
        var error = ""
        if (form.valuesByKey["host_title"] != nil){
            if ((form.valuesByKey["host_title"] as! String) == "") &&  error == ""{
                
                error = NSLocalizedString("Please enter host name.", comment: "")
            }
        }
        if(form.valuesByKey["host_description"] != nil){
            if ((form.valuesByKey["host_description"] as! String) == "") &&  error == ""{
                error = NSLocalizedString("Please enter Description.", comment: "")
            }
        }
        
        if error != ""{
            let alertController = UIAlertController(title: "Error", message: error, preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
        else{
            
            var dic = Dictionary<String, String>()
            for (key, value) in form.valuesByKey
            {
                if let receiver = value as? NSString
                {
                    dic["\(key)"] = receiver as String
                }
                if let receiver = value as? Int {
                    dic["\(key)"] = String(receiver)
                }
                if let receiver = value as? Date {
                    let tempString = String(describing: receiver)
                    
                    let tempArray = tempString.components(separatedBy: "+")
                    dic["\(key)"] = tempArray[0] as String
                }
                
            }
            if mediaType == "image"
            {
                if (form.valuesByKey["host_photo"]) != nil
                {
                    let imageArray = [form.valuesByKey["host_photo"] as! UIImage]
                    // filePathArray.removeAll(keepingCapacity: false)
                    // filePathArray = saveFileInDocumentDirectory(imageArray)
                    var path = [String]()
                    path = saveFileInDocumentDirectory(imageArray)
                    filePathArray.append(path[0] + " host_photo")
                    uploadMultiplePhoto = "advancedevent"
                    
                }

            }
            hostDictionary.update(dic)
            //print(hostDictionary)
            // Change Host Name
            if Formbackup["host"] != nil
            {
                Formbackup["host"] = form.valuesByKey["host_title"] as! String
            }
            
            // Redirecting to FormGenrationViewControleer
            for vc in (self.navigationController?.viewControllers ?? []) {
                if vc is FormGenerationViewController {
                    _ = self.navigationController?.popToViewController(vc, animated: true)
                    break
                }
            }
        }
    }
    // For selecting Members redirect to user search
    func selectUserAction(_ cell : FXFormFieldCellProtocol)
    {
        let form = cell.field.form as! CreateNewForm
        var dic = Dictionary<String, String>()
        
        for (key, value) in form.valuesByKey
        {
            if (key as! NSString == "host_type_select"){
                dic["\(key)"] = findKeyForValue(form.valuesByKey["\(key)"] as! String)
            }
            else{
                if let receiver = value as? NSString
                {
                    dic["\(key)"] = receiver as String
                }
                if let receiver = value as? Int {
                    dic["\(key)"] = String(receiver)
                }
                if let receiver = value as? Date {
                    let tempString = String(describing: receiver)
                    
                    let tempArray = tempString.components(separatedBy: "+")
                    dic["\(key)"] = tempArray[0] as String
                }
            }
            
        }
        hostDictionary.update(dic)
        let VC = UserSearchViewController()
        if form.valuesByKey["host_type_select"] as! String == "Member"
        {
          VC.Url = "user/suggest"
        }
        else
        {
           VC.Url =  "advancedevents/get-hosts"
        }
        
        self.navigationController?.pushViewController(VC, animated: false)
    }
    func generateSignUpProfileForm()
    {

        Form = temphostSelectionFormArr//hostSelectionFormArr
        self.formController.form = CreateNewForm()
        self.formController.tableView.reloadData()
    }
}
