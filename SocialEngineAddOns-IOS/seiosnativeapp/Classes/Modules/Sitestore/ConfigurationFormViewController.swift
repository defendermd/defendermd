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

//  ConfigurationFormViewController.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 03/02/16.
//  Copyright © 2016 bigstep. All rights reserved.

import UIKit
class ConfigurationFormViewController: UIViewController, TTTAttributedLabelDelegate,UITextViewDelegate,UITextFieldDelegate{
    var dic = Dictionary<String, AnyObject>()
    var product_id : String!
    var productConfigName = Dictionary<String,String>()//[:]
    var valueList : NSMutableArray =  []
    var configArrayValue : NSDictionary!
    var scrollView : UIScrollView!
    var configView : UIView!
    var label1 : UIButton!
    var label3 : UIButton!
    var label4 : TTTAttributedLabel!
    var editText : UITextView!
    var editText1 : UITextView!
    var editBody : String! = ""
    var multioption : NSDictionary!
    var configArrayValueChange : NSMutableArray! = []
    var configArrayIndependentFields : NSArray! = []
    var labelKey : String!
    var labelDesc : String!
    var defaultString : String  = ""
    var labelKey2 : String!
    var labelDesc2 : String!
    var profileFieldString = ""
    var profileFieldString2 = ""
    var origin_labelheight_y2 : CGFloat = 0
    var origin_labelheight_y : CGFloat = 0
    var indexValueofMultiCheckBox : Int = 0
    var dependentField : Int = 0
    var parametersToPass = Dictionary<String, String>()
    var extraParemeters = Dictionary<String, Int>()
    var multiCheckbox = [AnyObject]()
    var count : Int = 0
    var flag : Bool = false
    var combinationId : Int!
    var priceAmount : CGFloat!
    var priceIncrease : CGFloat = 0
    var checkBoxField : Bool = false
    var error = false
    var btnTag = 0
    // Initialize Class Object
    override func viewDidLoad() {
        super.viewDidLoad()
        configurations.removeAll(keepingCapacity: false)
        configArrayValueChange =   configArrayValue["dependentFields"]  as? NSMutableArray
        error = false
        // Do any additional setup after loading the view.
        searchDic.removeAll(keepingCapacity: false)
        view.backgroundColor = bgColor
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(ConfigurationFormViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        
        
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")
        leftNavView.addSubview(backIconImageView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ConfigurationFormViewController.tapGesture))
        view.addGestureRecognizer(tapGesture)
        
        let done = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style:.plain , target:self , action: #selector(ConfigurationFormViewController.Done))
        self.navigationItem.rightBarButtonItem = done
        
        
        scrollView = UIScrollView(frame: view.bounds)
        scrollView.backgroundColor = bgColor
        scrollView.delegate = self
        scrollView.bounces = false
        //scrollView.contentSize = view.bounds.size
        scrollView.sizeToFit()
        view.addSubview(scrollView)
        
        
        configView = createView(CGRect(x:0, y:0, width:view.bounds.width, height:0), borderColor: UIColor.clear, shadow: false)
        configView.backgroundColor = UIColor.white//UIColor(red: 229/255.0, green: 229/255.0, blue: 229/255.0, alpha: 1.0)
        configView.isHidden = false
        configView.tag = 1000
        scrollView.addSubview(configView)
        
        
        label1 = createButton(CGRect(x:PADING,y:10,width:self.view.bounds.width/2 - PADING , height:30), title: "", border: false,bgColor: false, textColor: textColorLight)
        label3 = createButton(CGRect(x:PADING,y:10,width:self.view.bounds.width/2 - PADING , height:30), title: "", border: false,bgColor: false, textColor: textColorLight)
        label1.isHidden = true
        label3.isHidden = true
        
        configView.addSubview(label1)
        configView.addSubview(label3)
        
        priceValue = priceAmount
        
        setConfigurationView()
        
        //browseConfigurations()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        setNavigationImage(controller: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNavigationImage(controller: self)
        self.title = NSLocalizedString("Select Configurations", comment: "")
       
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        for view in self.configView.subviews as [UIView] {
            if let btn = view as? UIButton {
                if btn.tag > 0 && btn.tag <= self.dependentField - 1 && btn.tag != 1000{
                    if   let configValue = self.configArrayValueChange[btn.tag] as? NSDictionary{
                        if let  _ = configValue["multiOptions"] as? NSDictionary{
                            //(self.configArrayValueChange[btn.tag] as AnyObject).remove("multiOptions")
                            
                        }
                    }
                }
            }
        }
        
        navigationController?.navigationBar.isHidden = false
        setNavigationImage(controller: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func setConfigurationView()
    {
        if configArrayValue != nil
        {
            if configArrayValue.count > 0
            {
                var topOrigin = self.configView.frame.origin.y
                if let dependentArr = configArrayValue["dependentFields"] as? NSArray
                {
                    configArrayValueChange = dependentArr as! NSMutableArray
                    var main_origin_y = topOrigin
                    for(index,element) in dependentArr.enumerated()
                    {
                        if let dic = element as? NSDictionary
                        {
                            if let type = dic["type"] as? String
                            {
                                if type == "select"
                                {
                                    var fieldLabel = ""
                                    if let label = dic["label"] as? String
                                    {
                                        fieldLabel = label
                                    }
                                    else if let label = dic["label"] as? Int
                                    {
                                        fieldLabel = String(label)
                                    }
                                    else if let label = dic["label"] as? Double
                                    {
                                        fieldLabel = String(label)
                                    }
                                    let fieldView = UIView(frame: CGRect(x:0,y:main_origin_y,width:self.view.bounds.width,height:40))
                                    fieldView.backgroundColor = UIColor.white
                                    self.configView.addSubview(fieldView)
                                    let headerView = UILabel(frame: CGRect(x:0,y:0,width:self.view.bounds.width,height:40))
                                    headerView.backgroundColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1.0)
                                    fieldView.addSubview(headerView)
                                    let headerLabel = UILabel(frame: CGRect(x:2*PADING,y:0,width:self.view.bounds.width,height:40))
                                    headerLabel.backgroundColor = UIColor.clear
                                    headerLabel.text = fieldLabel
                                    headerView.addSubview(headerLabel)
                                    let origin_y = getBottomEdgeY(inputView: headerLabel)
                                    let label = UILabel(frame: CGRect(x:5,y:origin_y,width:self.view.bounds.width/2-5,height:40))
                                    label.text = "Select " + fieldLabel
                                    label.textAlignment = .left
                                    label.font.withSize(12.0)
                                    label.textColor = UIColor.black
                                    fieldView.addSubview(label)
                                    let width1 = self.view.bounds.width/CGFloat(2)
                                    let label2 = UIButton(frame : CGRect(x:width1,y:origin_y+5,width:self.view.bounds.width/2-5,height:30))
                                    label2.setTitle("----Select----", for: .normal)
                                    label2.setTitleColor(UIColor.black, for: .normal)
                                    label2.backgroundColor = UIColor.white
                                    label2.layer.borderWidth = 1.0
                                    label2.titleEdgeInsets.right = 30
                                    label2.layer.borderColor = textColorMedium.cgColor
                                    label2.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
                                    label2.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
                                    label2.addTarget(self, action: #selector(dependentPressed(_:)), for: .touchUpInside)
                                    label2.tag = index
                                    fieldView.addSubview(label2)
                                    let imageview = UIImageView(frame: CGRect(x:label2.bounds.width - 30, y:3, width:25, height:24))
                                    imageview.image = UIImage(named: "Down1")
                                    label2.addSubview(imageview)
                                    fieldView.frame.size.height += label.frame.size.height
                                    main_origin_y += fieldView.frame.size.height
                                }
                            }
                        }
                    }
                    topOrigin = main_origin_y
                    //self.configView.frame.size.height = main_origin_y+10
                    //self.scrollView.contentSize.height = self.configView.frame.size.height+30
                }
                
                if let indFieldsArr = configArrayValue["independentFields"] as? NSArray
                {
                    if indFieldsArr.count > 0
                    {
                        configArrayIndependentFields = indFieldsArr
                        var main_origin_y = topOrigin
                        for (index, element) in indFieldsArr.enumerated()
                        {
                            if let dic = element as? NSDictionary
                            {
                                let type = dic["type"] as? String ?? ""
                                if type == "multi_checkbox" || type == "checkbox"
                                {
                                    checkBoxField = true
                                    if dic["multiOptions"] != nil
                                    {
                                        if let options = dic["multiOptions"] as? NSDictionary
                                        {
                                            var fieldLabel = ""
                                            if let label = dic["label"] as? String
                                            {
                                                fieldLabel = label
                                            }
                                            else if let label = dic["label"] as? Int
                                            {
                                                fieldLabel = String(label)
                                            }
                                            else if let label = dic["label"] as? Double
                                            {
                                                fieldLabel = String(label)
                                            }
                                            let fieldView = UIView(frame: CGRect(x:0,y:main_origin_y,width:self.view.bounds.width,height:40))
                                            fieldView.backgroundColor = UIColor.white
                                            self.configView.addSubview(fieldView)
                                            let headerView = UILabel(frame: CGRect(x:0,y:0,width:self.view.bounds.width,height:40))
                                            headerView.backgroundColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1.0)
                                            fieldView.addSubview(headerView)
                                            let headerLabel = UILabel(frame: CGRect(x:2*PADING,y:0,width:self.view.bounds.width,height:40))
                                            headerLabel.backgroundColor = UIColor.clear
                                            headerLabel.text = fieldLabel
                                            headerView.addSubview(headerLabel)
                                            var origin_y = getBottomEdgeY(inputView: headerLabel)
                                            for (key,value) in options
                                            {
                                                if let fieldDic = value as? NSDictionary
                                                {
                                                    var fieldTitle = ""
                                                    if let title = fieldDic["label"] as? String
                                                    {
                                                        fieldTitle = title
                                                    }
                                                    else if let title = fieldDic["label"] as? Int
                                                    {
                                                        fieldTitle = String(title)
                                                    }
                                                    else if let title = fieldDic["label"] as? Double
                                                    {
                                                        fieldTitle = String(title)
                                                    }
                                                    let mainTitle = String(format: NSLocalizedString(" %@   \(fieldTitle)  ", comment: ""), "\u{f096}")
                                                    
                                                    let fieldButton = UIButton(frame: CGRect(x:2*PADING,y:origin_y,width:self.view.bounds.width,height:40))
                                                    
                                                    fieldButton.setTitle(mainTitle, for: .normal)
                                                    fieldButton.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZELarge)
                                                    fieldButton.setTitleColor(UIColor.black, for: .normal)
                                                    fieldButton.backgroundColor = UIColor.white
                                                    fieldButton.contentHorizontalAlignment = .left
                                                    extraParemeters["\(key)"] = index
                                                    let btnTag = Int(key as! String)
                                                    fieldButton.tag = btnTag!
                                                    fieldButton.isUserInteractionEnabled = true
                                                    print("Button tag is \(fieldButton.tag)")
                                                    fieldButton.addTarget(self, action: #selector(ConfigurationFormViewController.multiCheckBoxPressed(_:)), for: .touchUpInside)
                                                    fieldView.addSubview(fieldButton)
                                                    origin_y += 40
                                                    fieldView.frame.size.height += 40
                                                }
                                            }
                                            main_origin_y += fieldView.frame.size.height
                                            
                                            
                                        }
                                    }
                                }
                                else if type == "text"
                                {
                                    
                                    var fieldLabel = ""
                                    if let label = dic["label"] as? String
                                    {
                                        fieldLabel = label
                                    }
                                    else if let label = dic["label"] as? Int
                                    {
                                        fieldLabel = String(label)
                                    }
                                    else if let label = dic["label"] as? Double
                                    {
                                        fieldLabel = String(label)
                                    }
                                    let fieldView = UIView(frame: CGRect(x:0,y:main_origin_y,width:self.view.bounds.width,height:40))
                                    fieldView.backgroundColor = UIColor.white
                                    self.configView.addSubview(fieldView)
                                    let headerView = UILabel(frame: CGRect(x:0,y:0,width:self.view.bounds.width,height:40))
                                    headerView.backgroundColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1.0)
                                    fieldView.addSubview(headerView)
                                    let headerLabel = UILabel(frame: CGRect(x:2*PADING,y:0,width:self.view.bounds.width,height:40))
                                    headerLabel.backgroundColor = UIColor.clear
                                    headerLabel.text = fieldLabel
                                    headerView.addSubview(headerLabel)
                                    let origin_y = getBottomEdgeY(inputView: headerLabel)
                                    
                                    
                                    let textView =  UITextField(frame: CGRect(x: 5, y: origin_y+5, width: self.view.bounds.width-10, height: 30))
                                    textView.font = UIFont.systemFont(ofSize: 15)
                                    textView.borderStyle = UITextField.BorderStyle.roundedRect
                                    textView.placeholder = "Enter Text Here"
                                    textView.layer.borderWidth = 0.5
                                    textView.layer.borderColor = UIColor.black.cgColor
                                    textView.autocorrectionType = UITextAutocorrectionType.no
                                    textView.keyboardType = UIKeyboardType.default
                                    textView.returnKeyType = UIReturnKeyType.done
                                    textView.clearButtonMode = UITextField.ViewMode.whileEditing;
                                    textView.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
                                    textView.delegate = self
                                    textView.tag = index
                                    fieldView.addSubview(textView)
                                    fieldView.frame.size.height += textView.frame.size.height+10
                                    main_origin_y += fieldView.frame.size.height
                                    
                                }
                                    
                                else if type == "textarea"
                                {
                                    
                                    var fieldLabel = ""
                                    if let label = dic["label"] as? String
                                    {
                                        fieldLabel = label
                                    }
                                    else if let label = dic["label"] as? Int
                                    {
                                        fieldLabel = String(label)
                                    }
                                    else if let label = dic["label"] as? Double
                                    {
                                        fieldLabel = String(label)
                                    }
                                    let fieldView = UIView(frame: CGRect(x:0,y:main_origin_y,width:self.view.bounds.width,height:40))
                                    fieldView.backgroundColor = UIColor.white
                                    self.configView.addSubview(fieldView)
                                    let headerView = UILabel(frame: CGRect(x:0,y:0,width:self.view.bounds.width,height:40))
                                    headerView.backgroundColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1.0)
                                    fieldView.addSubview(headerView)
                                    let headerLabel = UILabel(frame: CGRect(x:2*PADING,y:0,width:self.view.bounds.width,height:40))
                                    headerLabel.backgroundColor = UIColor.clear
                                    headerLabel.text = fieldLabel
                                    headerView.addSubview(headerLabel)
                                    let origin_y = getBottomEdgeY(inputView: headerLabel)
                                    
                                    let textArea = createTextView(CGRect(x:5,y:origin_y+5 , width:self.view.bounds.width-7,height:100), borderColor: borderColorClear , corner: false )
                                    textArea.backgroundColor = bgColor
                                    textArea.delegate = self
                                    textArea.backgroundColor = UIColor.clear
                                    textArea.textColor = textColorMedium
                                    textArea.layer.borderWidth = 1.0
                                    textArea.tag = index
                                    textArea.layer.borderColor = UIColor.black.cgColor
                                    textArea.font = UIFont(name: fontName, size: FONTSIZELarge)
                                    textArea.autocorrectionType = UITextAutocorrectionType.yes
                                    textArea.text = NSLocalizedString("",  comment: "")
                                    self.automaticallyAdjustsScrollViewInsets = false
                                    textArea.isScrollEnabled = true
                                    fieldView.addSubview(textArea)
                                    fieldView.frame.size.height += textArea.frame.size.height+10
                                    main_origin_y += fieldView.frame.size.height
                                }
                                    
                                else if type == "radio"
                                {
                                    var description = ""
                                    if let desc = dic["description"] as? String
                                    {
                                        description = desc
                                    }
                                    else if let desc = dic["description"] as? Int
                                    {
                                        description = String(desc)
                                    }
                                    else if let desc = dic["description"] as? Double
                                    {
                                        description = String(desc)
                                    }
                                    var fieldLabel = ""
                                    if let label = dic["label"] as? String
                                    {
                                        fieldLabel = label
                                    }
                                    else if let label = dic["label"] as? Int
                                    {
                                        fieldLabel = String(label)
                                    }
                                    else if let label = dic["label"] as? Double
                                    {
                                        fieldLabel = String(label)
                                    }
                                    let fieldView = UIView(frame: CGRect(x:0,y:main_origin_y+5,width:self.view.bounds.width,height:40))
                                    fieldView.backgroundColor = UIColor.white
                                    self.configView.addSubview(fieldView)
                                    let headerView = UILabel(frame: CGRect(x:0,y:0,width:self.view.bounds.width,height:40))
                                    headerView.backgroundColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1.0)
                                    fieldView.addSubview(headerView)
                                    let headerLabel = UILabel(frame: CGRect(x:2*PADING,y:0,width:self.view.bounds.width,height:40))
                                    headerLabel.backgroundColor = UIColor.clear
                                    headerLabel.text = fieldLabel
                                    headerView.addSubview(headerLabel)
                                    let origin_y = getBottomEdgeY(inputView: headerLabel)
                                    let label = UILabel(frame: CGRect(x:5,y:origin_y,width:self.view.bounds.width/2-5,height:40))
                                    label.text = description
                                    label.textAlignment = .left
                                    label.font.withSize(12.0)
                                    label.textColor = UIColor.black
                                    fieldView.addSubview(label)
                                    let width1 = self.view.bounds.width/CGFloat(2)
                                    let label2 = UIButton(frame : CGRect(x:width1,y:origin_y+5,width:self.view.bounds.width/2-5,height:30))
                                    label2.setTitle("----Select----", for: .normal)
                                    label2.setTitleColor(UIColor.black, for: .normal)
                                    label2.backgroundColor = UIColor.white
                                    label2.layer.borderWidth = 1.0
                                    label2.titleEdgeInsets.right = 30
                                    label2.layer.borderColor = textColorMedium.cgColor
                                    label2.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
                                    label2.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
                                    label2.addTarget(self, action: #selector(radioButtonPressed(_:)), for: .touchUpInside)
                                    label2.tag = index
                                    fieldView.addSubview(label2)
                                    let imageview = UIImageView(frame: CGRect(x:label2.bounds.width - 30, y:3, width:25, height:24))
                                    imageview.image = UIImage(named: "Down1")
                                    label2.addSubview(imageview)
                                    fieldView.frame.size.height += label.frame.size.height
                                    main_origin_y += fieldView.frame.size.height
                                    
                                    
                                }
                            }
                        }
                        topOrigin = main_origin_y+10
                        //self.scrollView.contentSize.height = self.configView.frame.size.height
                    }
                    
                }
                self.configView.frame.size.height = topOrigin + 10
                self.scrollView.contentSize.height = self.configView.frame.size.height+30
            }
        }
    }
    
    @objc func radioButtonPressed(_ sender: UIButton)
    {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        if let radioDic = configArrayIndependentFields[sender.tag] as? NSDictionary
        {
            let configName = radioDic["name"] as? String ?? ""
            if let options = radioDic["multiOptions"] as? NSDictionary
            {
                for(k,v) in options
                {
                    
                    if v is NSDictionary
                    {
                        let v = v as! NSDictionary
                        let label = v["label"] as? String ?? ""
                        alertController.addAction(UIAlertAction(title: label, style: .default, handler:{ (UIAlertAction) -> Void in
                            sender.setTitle("  \(label)", for: UIControl.State.normal)
                            self.dic[configName] = k as AnyObject
                            if let priceIncrement = v["price_increment"] as? Bool{
                                if priceIncrement == true
                                {
                                    if  let priceIncrement = v["price"] as? CGFloat{
                                        self.priceIncrease = self.priceIncrease + priceIncrement
                                    }
                                }
                                else
                                {
                                    if let priceDecrement = v["price"] as? CGFloat
                                    {
                                        self.priceIncrease = self.priceIncrease - priceDecrement
                                    }
                                }
                                
                            }
                        }))
                        
                    }
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
            popover?.sourceRect = CGRect(x:view.bounds.width/2, y:view.bounds.height/2 , width:1, height:1)
            popover?.permittedArrowDirections = UIPopoverArrowDirection()
        }
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    @objc func multiCheckBoxPressed(_ sender: UIButton)
    {
        let stringTag = String(sender.tag)
        let index = extraParemeters["\(stringTag)"]
        print("Index is \(String(describing: index))")
        if let configValue = configArrayIndependentFields[index!] as? NSDictionary
        {
            let type = configValue["type"] as! String
            if type == "multi_checkbox" || type == "checkbox"
            {
                if let options = configValue["multiOptions"] as? NSDictionary
                {
                    for (index,element) in options
                    {
                        if index as! String == String(sender.tag)
                        {
                            if parametersToPass.count > 0
                            {
                                if parametersToPass[index as! String] != nil
                                {
                                    let stringValue = index as! String
                                    let value = parametersToPass["\(stringValue)"]
                                    let profilestring = String(format: NSLocalizedString(" %@   \(value ?? "")  ", comment: ""), "\u{f096}")
                                    sender.setTitle("\(profilestring)", for: UIControl.State.normal)
                                    parametersToPass.removeValue(forKey: index as! String)
                                    
                                }
                                else
                                {
                                    if let values = element as? NSDictionary
                                    {
                                        var value1 = ""
                                        if let val = values["label"] as? String
                                        {
                                            value1 = val
                                        }
                                        else if let val = values["label"] as? Int
                                        {
                                            value1 = String(val)
                                        }
                                        else if let val = values["label"] as? Double
                                        {
                                            value1 = String(val)
                                        }
                                        
                                        parametersToPass["\(index)"] = "\(value1)"
                                        // let value  = (values["label"] as! String)
                                        
                                        let    profileString = String(format: NSLocalizedString(" %@   \(value1)  ", comment: ""), "\u{f046}")
                                        sender.setTitle("\(profileString)", for: UIControl.State.normal)
                                        
                                    }
                                }
                            }
                            else
                            {
                                if let values = element as? NSDictionary
                                {
                                    var value1 = ""
                                    if let val = values["label"] as? String
                                    {
                                        value1 = val
                                    }
                                    else if let val = values["label"] as? Int
                                    {
                                        value1 = String(val)
                                    }
                                    else if let val = values["label"] as? Double
                                    {
                                        value1 = String(val)
                                    }
                                    parametersToPass["\(index)"] = "\(value1)"
                                    let    profileString = String(format: NSLocalizedString(" %@   \(value1)  ", comment: ""), "\u{f046}")
                                    sender.setTitle("\(profileString)", for: UIControl.State.normal)
                                }
                            }
                        }
                        
                    }
                }
            }
        }
        print("Parameters to pass are \(parametersToPass)")
    }
    
    @objc func dependentPressed(_ sender : UIButton)
    {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        if let configValue = configArrayValueChange[sender.tag] as? NSDictionary
        {
            let configName = configValue["name"] as? String ?? ""
            let type = configValue["type"] as? String ?? ""
            if type ==  "select"
            {
                if let multiOptions = configValue["multiOptions"] as? NSDictionary
                {
                    for(k,v) in multiOptions
                    {
                        if v is NSDictionary
                        {
                            let v = v as! NSDictionary
                            var valueLabel = ""
                            if let val = v["label"] as? String
                            {
                                valueLabel = val
                            }
                            else if let val = v["label"] as? Int
                            {
                                valueLabel = String(val)
                            }
                            else if let val = v["label"] as? Double
                            {
                                valueLabel = String(val)
                            }
                            alertController.addAction(UIAlertAction(title: valueLabel, style: .default, handler:{ (UIAlertAction) -> Void in
                                sender.setTitle(valueLabel, for: UIControl.State.normal)
                                for view in self.configView.subviews as [UIView] {
                                    view.subviews.compactMap{ $0 as? UIButton }.map {
                                        $0.isUserInteractionEnabled = false
                                        sender.isUserInteractionEnabled = false
                                        if $0.tag > sender.tag {
                                            $0.setTitle(" -----Select----- ", for: UIControl.State.normal)
                                            //                                            if   let configValue = self.configArrayValueChange[$0.tag] as? NSDictionary{
                                            //                                                if let  _ = configValue["multiOptions"] as? NSDictionary{
                                            //                                                    (self.configArrayValueChange[$0.tag] as AnyObject).remove("multiOptions")
                                            //
                                            //                                                }
                                            //                                            }
                                        }
                                    }
                                }
                                
                                /// response
                                if Reachabable.isConnectedToNetwork() {
                                    removeAlert()
                                    //                                    spinner.center = self.view.center
                                    //                                    spinner.hidesWhenStopped = true
                                    //                                    spinner.style = UIstyle.gray
                                    //                                    self.view.addSubview(spinner)
                                    self.view.addSubview(activityIndicatorView)
                                    activityIndicatorView.center = self.view.center
                                    activityIndicatorView.startAnimating()
                                    
                                    var dic = Dictionary<String, String>()
                                    dic = ["\(configName)": "\(k)","product_id": String(self.product_id), "price": String(describing: self.priceAmount!)]
                                    let method = "GET"
                                    
                                    // Send Server Request to Explore Page Contents with Page_ID
                                    post(dic, url: "sitestore/product/variation-option", method: method) { (succeeded, msg) -> () in
                                        DispatchQueue.main.async(execute:  {
                                            activityIndicatorView.stopAnimating()
                                            for view in self.configView.subviews as [UIView] {
                                                view.subviews.compactMap{ $0 as? UIButton }.map {
                                                    $0.isUserInteractionEnabled = true
                                                    sender.isUserInteractionEnabled = true
                                                   
                                                }
                                            }
                                            if msg{
                                                
                                                let nameField : String!
                                                if let response = succeeded["body"] as? NSDictionary
                                                {
                                                    
                                                    if let field = response["field"] as? NSDictionary{
                                                        if let nameOfField = field["name"] as? String{
                                                            nameField = nameOfField
                                                            if  self.configArrayValueChange.count > 0{
                                                                var  i = 0
                                                                for configValue in self.configArrayValueChange {
                                                                    if let dic = configValue as? NSDictionary {
                                                                        if  let name = dic["name"] as? String{
                                                                            if nameField != nil{
                                                                                if  name == nameField{
                                                                                    self.configArrayValueChange[i] = field
                                                                                }
                                                                                else{
                                                                                    self.configArrayValueChange[i] = configValue
                                                                                }
                                                                                
                                                                            }
                                                                            
                                                                        }
                                                                    }
                                                                    i = i + 1
                                                                }
                                                                
                                                            }
                                                            
                                                        }
                                                        
                                                    }
                                                }
                                                // On Success Update
                                                // Update
                                                if succeeded["message"] != nil{
                                                    showToast(message: succeeded["message"] as! String, controller: self)
                                                }
                                                
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
                                    showToast(message: network_status_msg, controller: self)
                                }
                            }))
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
                        popover?.sourceRect = CGRect(x:view.bounds.width/2, y:view.bounds.height/2 , width:1, height:1)
                        popover?.permittedArrowDirections = UIPopoverArrowDirection()
                    }
                    self.present(alertController, animated: true, completion: nil)
                }
                else
                {
                    
                    if  let configValue = configArrayValueChange[sender.tag - 1] as? NSDictionary{
                        if let type = configValue["type"] as? String{
                            if type == "select" {
                                let dependentString = (configValue["label"] as? String)!
                                 showToast(message:NSLocalizedString("Please select \(dependentString) first",comment: ""), controller: self)
                            }
                        }
                    }
                    
                }
            }
        }
        print("Dependent field Pressed!")
    }

    
    // When Click On Done
    @objc func Done()
    {
        self.view.endEditing(true)
        valueList = []
        for view in self.configView.subviews as [UIView]
        {
            
            if let fieldView = view as? UIView
            {
                for subview in fieldView.subviews as [UIView]
                {
                    if let btn = subview as? UIButton
                    {
                        if var string = btn.titleLabel?.text
                        {
                            string = string.trimString(string)
                            valueList.add(string)
                            
                            if defaultString != ""
                            {
                                if string == defaultString
                                {
                                    error = true
                                    productDetailUpdate = false
                                    let alertController = UIAlertController(title: "Error", message:  NSLocalizedString("Please select the desired product options from below", comment: ""), preferredStyle: UIAlertController.Style.alert)
                                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
                                    self.present(alertController, animated: true, completion: nil)
                                    
                                }
                                else
                                {
                                    productDetailUpdate = true
                                }
                            }
                        }
                    }
                }
            }
           
            if let btn = view as? UIButton
            {
                if  btn.tag != 1000
                {
                    if var string = btn.titleLabel?.text
                    {
                        string = string.trimString(string)
                        valueList.add(string)
                        
                        if defaultString != ""
                        {
                            if string == defaultString
                            {
                                error = true
                                productDetailUpdate = false
                                let alertController = UIAlertController(title: "Error", message:  NSLocalizedString("Please select the desired product options from below", comment: ""), preferredStyle: UIAlertController.Style.alert)
                                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
                                self.present(alertController, animated: true, completion: nil)
                                
                            }
                            else
                            {
                                productDetailUpdate = true
                            }
                        }
                    }
                }
            }
        }
        
        // Store Selected Dependent ConfigValue
        if configArrayValueChange != nil {
        for key in configArrayValueChange{
            
            if let dicc = key as? NSDictionary{
                if let multioption = dicc["multiOptions"]{
                    
                    for (k,v) in multioption as! NSDictionary {
                        
                        if let v = v as? NSDictionary{
                            if v["label"] is NSNumber {
                                if let valueLabel = v["label"]! as? NSNumber{
                                    
                                    for (_, element) in valueList.enumerated() {
                                        
                                        if element as! String == String(describing: valueLabel){
                                            dic[String(describing: dicc["name"]!)] = k as AnyObject?
                                        }
                                        
                                    }
                                    
                                }
                                
                            }
                            else {
                                if let valueLabel = v["label"] as? String {
                                    
                                    for (_, element) in valueList.enumerated() {
                                        
                                        if element as! String == valueLabel{
                                            dic[String(describing: dicc["name"]!)] = k as AnyObject?
                                        }
                                        
                                    }
                                    
                                }
                            }
                        }
                    }
                    
                }
            }
        }
        }
        if checkBoxField == true{
            btnTag = 0
            print("configValue")
            // Store Selected MultiCheckBox ConfigValue
           // let   indexValueofMultiCheckBoxx = indexValueofMultiCheckBox - dependentField
            for  i in 0..<configArrayIndependentFields.count {
            if let configValue = configArrayIndependentFields[i] as? NSDictionary{
                
                print(configValue)
                let configName = configValue["name"] as! String
                let type = configValue["type"] as! String
                multiCheckbox.removeAll(keepingCapacity: false)
                if type == "multi_checkbox" || type == "checkbox"{
                    
                   
                    
                    if let multioption = configValue["multiOptions"] as? NSDictionary{
                        
                        for(k,v) in multioption
                        {
                            let v = v as! NSDictionary
                            for (key,_) in parametersToPass{
                                
                                if key == k as! String
                                {
                                    
//                                    for (k,_) in parametersToPass
//                                    {
                                        multiCheckbox.append(Int(k as! String) as AnyObject)
                                    //}
                                    dic[configName]  = multiCheckbox as AnyObject?
                                    print(dic[configName])
                                    if let priceIncrement = v["price_increment"] as? Bool
                                    {
                                        if priceIncrement == true
                                        {
                                            if  let priceIncrement = v["price"] as? CGFloat{
                                                priceIncrease = priceIncrease + priceIncrement
                                            }
                                        }
                                        else
                                        {
                                            if let priceDecrement = v["price"] as? CGFloat
                                            {
                                                priceIncrease = priceIncrease - priceDecrement
                                            }
                                        }
                                    }
                                }
                                else
                                {
                                    continue
                                }
                            }
                        }
                    }
                    
                    print(parametersToPass)
                    
                }
            }
                
        }
        }
        
        if error == false{
            finalPriceChange()
        }
        else{
            error = false
        }
        
    }
    
    // Final price value change
    func finalPriceChange(){
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            var parameters = [String:String]()
            parameters["product_id"] = String(product_id)
            if configArrayValueChange != nil {
            for key in configArrayValueChange{
                
                if let dicc = key as? NSDictionary{
                    if let multioption = dicc["multiOptions"]{
                        
                        for (k,v) in multioption as! NSDictionary {
                            
                            if let v = v as? NSDictionary{
                                if let valueLabel = v["label"] as? Int{
                                    
                                    for (_, element) in valueList.enumerated() {
                                        
                                        if element as! String == String(valueLabel){
                                            parameters[dicc["name"] as! String]  = String(describing: k)
                                        }
                                        
                                    }
                                    
                                }else{
                                    if let valueLabel = v["label"] as? String{
                                        
                                        for (_, element) in valueList.enumerated() {
                                            
                                            if element as! String == valueLabel{
                                                parameters[dicc["name"] as! String]  = String(describing: k)
                                            }
                                            
                                        }
                                        
                                    }
                                }
                            }
                            
                        }
                        
                    }
                }
            }
            
            
            // Send Server Request to Explore classified Contents with classified_ID
            post(parameters, url: "sitestore/product/getcombination", method: "POST") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    
                    if msg{
                        if let response = succeeded["body"] as? NSDictionary
                        {
                            if let PriceValue = response["price"]  as? CGFloat{
                                priceValue = PriceValue
                            }
                            
                            if let combinationIdd = response["combination_id"]  as? Int{
                                self.combinationId = combinationIdd
                            }
                            
                            priceValue = priceValue + self.priceIncrease
                            
                            // Store CobinationId
                            if self.combinationId != nil{
                                self.dic["combination_id"]  = self.combinationId as AnyObject
                            }
                            
                            // Insert value in an array so that it use for add to cart
                            configurations["configFields"] = self.dic as AnyObject
                            _ = self.navigationController?.popViewController(animated: false)
                        }
                        
                    }
                    else
                    {
                        // Handle Server Side Error
                        if succeeded["message"] != nil
                        {
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                        }
                    }
                })
            }
            }
            else{
                configurations["configFields"] = self.dic as AnyObject
                _ = self.navigationController?.popViewController(animated: false)
            }
        }
        else{
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self)
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        NotificationCenter.default.addObserver(self, selector: #selector(ConfigurationFormViewController.keyboardWillShow(sender:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        NotificationCenter.default.addObserver(self, selector: #selector(ConfigurationFormViewController.keyboardWillShow(sender:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        let fieldTag = textField.tag
        if let textFieldDic = configArrayIndependentFields[fieldTag] as? NSDictionary
        {
            if let configName = textFieldDic["name"] as? String
            {
                if textField.text != ""
                {
                    dic[configName] = textField.text as AnyObject
                }
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        let fieldTag = textView.tag
        if let textViewDic = configArrayIndependentFields[fieldTag] as? NSDictionary
        {
            if let configName = textViewDic["name"] as? String
            {
                if textView.text != ""
                {
                    dic[configName] = textView.text as AnyObject
                }
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        scrollView.frame.origin.y = 0.0
        return true
    }
    
    
    func textViewDidChange(_ textView: UITextView){
        //textView.frame.size.width = 150
        if textView.tag == 1000{
            if textView.frame.size.height <  30 {
                textView.sizeToFit()
                textView.layoutIfNeeded()
                
            }
            else{
                //editText.isScrollEnabled = true
            }
        }
        else{
            if textView.frame.size.height <  100 {
                textView.sizeToFit()
                textView.layoutIfNeeded()
                
            }
            else{
                //editText1.isScrollEnabled = true
            }
        }
    }
    
    // Whenever keyboard will open
    @objc func keyboardWillShow(sender: NSNotification) {
        
        if let keyboardSize = (sender.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size.height
        {
            if scrollView.contentSize.height > view.bounds.height - keyboardSize{
                scrollView.frame.origin.y = -200
            }
        }
        
    }
    
    
    @objc func tapGesture()
    {
        self.view.endEditing(true)
        scrollView.frame.origin.y = 0.0
    }
    
    @objc func goBack()
    {
        _ = self.navigationController?.popViewController(animated: false)
    }
    
    
}
