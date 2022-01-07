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
//  MLTInfoViewController.swift
//  seiosnativeapp
//


import UIKit

class MLTInfoViewController: UIViewController, TTTAttributedLabelDelegate, UITextViewDelegate{
    
    // Variable for Blog Detail Form
    var subjectId : Int!
    var mytitle : String!
    var detailWebView = UITextView()
    var label1 : String!
    var contentType = ""
    var leftBarButtonItem : UIBarButtonItem!
    var viewTitle = "Info"
    var infoView = UIScrollView()
    var infoUrl = ""
    var infoDictionay = NSDictionary()
    var basicInfo = NSDictionary()
    var profileInfo = NSDictionary()
    var containText = true
    
    // Initialize Class Object
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        searchDic.removeAll(keepingCapacity: false)
        view.backgroundColor = bgColor
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(MLTInfoViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        if containText == false
        {
            infoView.frame = CGRect(x:0,y:5,width:self.view.bounds.width,height:self.view.bounds.height)
            view.addSubview(infoView)
            infoView.contentSize = CGSize(width: self.view.bounds.width, height: self.view.bounds.height)
            infoView.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1.0)
            view.addSubview(infoView)
            getInfo()
        }
        else
        {
            // WebView for Blog Detail
            detailWebView.frame = CGRect(x: 0, y: 5, width: view.bounds.width, height: view.bounds.height - 5)
            detailWebView.font = UIFont(name: fontName, size: FONTSIZENormal)
            detailWebView.backgroundColor = bgColor
            detailWebView.isOpaque = false
            detailWebView.isUserInteractionEnabled = true
            detailWebView.isEditable = false
            detailWebView.text = label1.html2String
            detailWebView.delegate = self
            view.addSubview(detailWebView)
        }
        
        
        
        
        
    }
    
    func createInfoView()
    {
        var originY = CGFloat(0.0)
        
        if self.profileInfo.count > 0
        {
            let headerView = UIView(frame: CGRect(x:0,y:originY,width:self.view.bounds.width,height:40))
            headerView.backgroundColor = UIColor(red: 215/255, green: 215/255, blue: 215/255, alpha: 1.0)
            infoView.addSubview(headerView)
            let headerLabel = UILabel(frame: CGRect(x:5,y:0,width:self.view.bounds.width-10,height:40))
            headerLabel.backgroundColor = UIColor.clear
            headerLabel.text = "Profile Information"
            headerLabel.textColor = UIColor.black
            headerView.addSubview(headerLabel)
            
            originY += 40
            for (key,value) in self.profileInfo
            {
                let keyText = key as? String ?? ""
                let valueText = String(describing: value)
                let keyHeight = heightForKey(text: keyText)
                var lineHeight = heightForView(text: valueText)
                if keyHeight > lineHeight
                {
                    lineHeight = keyHeight
                }
                lineHeight += 14
                let lineView = UIView(frame: CGRect(x:0,y:originY,width:self.view.bounds.width,height:lineHeight))
                let keyLabel = UILabel(frame: CGRect(x:5,y:0,width:110,height:lineHeight))
                keyLabel.text = keyText
                keyLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
                keyLabel.adjustsFontSizeToFitWidth = true
                keyLabel.numberOfLines = 2
                keyLabel.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                keyLabel.textColor = UIColor.black
                lineView.addSubview(keyLabel)
                let valueLabel = UILabel(frame: CGRect(x:125,y:0,width:self.view.bounds.width-125,height:lineHeight))
                valueLabel.text = valueText
                valueLabel.numberOfLines = 0
                valueLabel.font = UIFont(name: fontName, size: FONTSIZEMedium)
                valueLabel.textColor = UIColor.black
                lineView.addSubview(valueLabel)
                infoView.addSubview(lineView)
                originY += lineHeight
                let borderView = UIView(frame: CGRect(x:0,y:originY,width:self.view.bounds.width,height:0.5))
                borderView.backgroundColor = UIColor.gray
                infoView.addSubview(borderView)
                originY = originY + 0.5
            }
            
        }
        if self.basicInfo.count > 0
        {
            let headerView = UIView(frame: CGRect(x:0,y:originY,width:self.view.bounds.width,height:40))
            headerView.backgroundColor = UIColor(red: 215/255, green: 215/255, blue: 215/255, alpha: 1.0)
            infoView.addSubview(headerView)
            let headerLabel = UILabel(frame: CGRect(x:5,y:0,width:self.view.bounds.width-10,height:40))
            headerLabel.backgroundColor = UIColor.clear
            headerLabel.text = "Basic Information"
            headerLabel.textColor = UIColor.black
            headerView.addSubview(headerLabel)
            originY += 40
            for (key,value) in self.basicInfo
            {
                let keyText = key as? String ?? ""
                var valueText = String(describing: value)
                if keyText.range(of: "Posted By") != nil
                {
                    if let nameDic = value as? NSDictionary
                    {
                        let posterName = nameDic["name"] as? String ?? ""
                        valueText = posterName
                    }
                }
                let keyHeight = heightForKey(text: keyText)
                var lineHeight = heightForView(text: valueText)
                if keyHeight > lineHeight
                {
                    lineHeight = keyHeight
                }
                lineHeight += 14
                let lineView = UIView(frame: CGRect(x:0,y:originY,width:self.view.bounds.width,height:lineHeight))
                let keyLabel = UILabel(frame: CGRect(x:5,y:0,width:110,height:lineHeight))
                keyLabel.text = keyText
                keyLabel.numberOfLines = 0
                keyLabel.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                keyLabel.textColor = UIColor.black
                lineView.addSubview(keyLabel)
                let valueLabel = UILabel(frame: CGRect(x:125,y:0,width:self.view.bounds.width-125,height:lineHeight))
                valueLabel.text = valueText
                valueLabel.numberOfLines = 0
                valueLabel.font = UIFont(name: fontName, size: FONTSIZEMedium)
                valueLabel.textColor = UIColor.black
                lineView.addSubview(valueLabel)
                infoView.addSubview(lineView)
                originY += lineHeight
                let borderView = UIView(frame: CGRect(x:0,y:originY,width:self.view.bounds.width,height:0.5))
                borderView.backgroundColor = UIColor.gray
                infoView.addSubview(borderView)
                originY = originY + 0.5
            }
        }
        infoView.contentSize.height = originY + 20
    }
    func heightForKey(text:String) -> CGFloat
    {
        let label = UILabel(frame: CGRect(x:0,y:0,width:110,height:CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.font = UIFont(name: fontName, size: FONTSIZEMedium)
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.text = text
        label.sizeToFit()
        let labHeight = label.frame.size.height
        label.removeFromSuperview()
        return labHeight
    }
    func heightForView(text:String) -> CGFloat
    {
        let label = UILabel(frame: CGRect(x:0,y:0,width:self.view.bounds.width-125,height:CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.font = UIFont(name: fontName, size: FONTSIZEMedium)
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.text = text
        label.sizeToFit()
        let labHeight = label.frame.size.height
        label.removeFromSuperview()
        return labHeight
    }
    
    func getInfo()
    {
        if reachability.connection != .none
        {
            activityIndicatorView.center = view.center
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.startAnimating()
            let param = Dictionary<String,String>()
            let url = self.infoUrl
            post(param, url: url, method: "get") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    
                    activityIndicatorView.stopAnimating()
                    if msg
                    {
                        if let body = succeeded["body"] as? NSDictionary
                        {
                            if let basicinfo = body["basic_information"] as? NSDictionary
                            {
                                self.basicInfo = basicinfo
                            }
                            if let profileinfo = body["profile_information"] as? NSDictionary
                            {
                                self.profileInfo = profileinfo
                            }
                            self.createInfoView()
                        }
                    }
                })
            }

        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        navigationController?.navigationBar.isHidden = false
        setNavigationImage(controller: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if contentType == "product"{
            self.title = NSLocalizedString("Overview", comment: "")
        }
        else{
            self.title = NSLocalizedString(viewTitle, comment: "")
        }
        setNavigationImage(controller: self)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        setNavigationImage(controller: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func goBack(){
        _ = self.navigationController?.popViewController(animated: false)
        
    }
    
    
}
