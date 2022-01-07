//
//  CotactDetailViewController.swift
//  seiosnativeapp
//
//  Created by ABC on 3/12/18.
//  Copyright © 2018 bigstep. All rights reserved.
//

import UIKit

var isContactUpdate : Bool = false
var profileField : NSDictionary?
class CotactDetailViewController: UIViewController {
    
    var infolabel : TTTAttributedLabel!
    var isowner : Bool!
    var noContactIcon : UILabel!
    var noContactMessage : UILabel!
    var subjectId:String!
    
    var information : UIView!
    var label1 : UILabel!
    var label2 : UILabel!
    var label3 : UILabel!
    var urlString : String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = textColorLight
        //Navigation stuff
        navSetUp()
        
        if profileField?.count == 0{
            noContactIcon = createLabel(CGRect(x: self.view.bounds.width/2 - 30,y: self.view.bounds.height/2-80,width: 60 , height: 50), text: NSLocalizedString("\(contactIcon)",  comment: "") , alignment: .center, textColor: buttonColor)
            noContactIcon.font = UIFont(name: "FontAwesome", size: 50)
            noContactIcon.isHidden = false
            view.addSubview(noContactIcon)
            
            noContactMessage = createLabel(CGRect(x: 0, y: noContactIcon.bounds.height + noContactIcon.frame.origin.y + (2 * PADING),width: self.view.bounds.width , height: 30), text: NSLocalizedString("No Contact Details to display",  comment: "") , alignment: .center, textColor: buttonColor)
            noContactMessage.numberOfLines = 0
            noContactMessage.lineBreakMode = NSLineBreakMode.byWordWrapping
            noContactMessage.backgroundColor = textColorclear
            noContactMessage.tag = 1000
            noContactMessage.isHidden = false
            view.addSubview(noContactMessage)
        }
        else
        {
            information = createView(CGRect(x:0,y:TOPPADING,width:view.bounds.width,height:100), borderColor: UIColor.clear, shadow: false)
            self.view.addSubview(information)
            showProfile()
        }
    
        
        
        //Show info from dictionary
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isContactUpdate == true{
            //Show info from dictionary
            information = createView(CGRect(x:0,y:TOPPADING,width:view.bounds.width,height:100), borderColor: UIColor.clear, shadow: false)
            self.view.addSubview(information)
            showProfile()
        }
    }
    //Navigation stuff
    func navSetUp(){
        self.title = NSLocalizedString("Contact Information",  comment: "")
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(CotactDetailViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        if isowner == true{
            let addContact = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(CotactDetailViewController.addNewContact))
            self.navigationItem.setRightBarButtonItems([addContact], animated: true)
            
        }
    }
    //Show info from dictionary
    func showProfile(){
        for view in self.information.subviews
        {
            view.removeFromSuperview()
        }
        if let profileField = profileField{
            var labelKey : String!
            var labelDesc : String!
            var origin_y = 10
            if profileField.count > 0{
                if (self.noContactIcon != nil)
                {
                    self.noContactIcon.isHidden = true
                }
                if (self.noContactMessage != nil)
                {
                    self.noContactMessage.isHidden = true
                }
                for(k,v) in profileField{
                    
                    
                    labelKey = k as? String
                    if let value = v as? String
                    {
                        labelDesc = value
                    }
                    else if let value = v as? Int
                    {
                        labelDesc = String(describing: value)
                    }
                    else if let value = v as? NSNumber
                    {
                        labelDesc = String(describing: value)
                    }
                    if labelKey == "Email" || labelKey == "email"
                    {
                        self.label1 = createLabel(CGRect(x:10,y:origin_y,width:Int(view.bounds.width),height:30), text: "", alignment: .left, textColor: textColorDark)
                        self.label1.font = UIFont(name: "Avenir-Book", size: 19)
                        self.label1.text = "\(labelKey!) : \(labelDesc!)"
                        self.label1.numberOfLines = 0
                        self.label1.lineBreakMode = NSLineBreakMode.byWordWrapping
                        self.information.addSubview(label1)
                        
                    }
                    else if labelKey == "Phone" || labelKey == "phone"
                    {
                        self.label2 = createLabel(CGRect(x:10,y:origin_y,width:Int(view.bounds.width),height:30), text: "", alignment: .left, textColor: textColorDark)
                        self.label2.font = UIFont(name: "Avenir-Book", size: 19)
                        self.label2.text = "\(labelKey!) : \(labelDesc!)"
                        self.label2.numberOfLines = 0
                        self.label2.lineBreakMode = NSLineBreakMode.byWordWrapping
                        self.information.addSubview(label2)
                    }
                    else if labelKey == "Website" || labelKey == "website"
                    {
                        self.label3 = createLabel(CGRect(x:10,y:origin_y,width:Int(view.bounds.width),height:30), text: "", alignment: .left, textColor: textColorDark)
                        self.label3.font = UIFont(name: "Avenir-Book", size: 19)
                        let myString = "\(labelKey!) : \(labelDesc!)"
                        let mutableString = NSMutableAttributedString(string: myString)
                        let length = labelKey.length
                        let length2 = labelDesc.length
                        mutableString.addAttribute( kCTForegroundColorAttributeName as NSAttributedString.Key, value: UIColor.blue, range: NSRange( location:length+3, length:length2))
                        mutableString.addAttribute(kCTUnderlineStyleAttributeName as NSAttributedString.Key, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(length+3, length2))
                        self.label3.attributedText = mutableString
                        self.label3.numberOfLines = 0
                        self.label3.lineBreakMode = NSLineBreakMode.byWordWrapping
                        self.urlString = labelDesc!
                        let tap = UITapGestureRecognizer(target: self, action: #selector(CotactDetailViewController.verifyUrl))
                        label3.isUserInteractionEnabled = true
                        label3.addGestureRecognizer(tap)
                        self.information.addSubview(label3)
                    }
                    origin_y += 30
                }
                
            }else{
                //origin_labelheight_y = origin_labelheight_y - 15
            }
            
            
        }
        
    }
    
    @objc func verifyUrl(sender:UITapGestureRecognizer) -> Bool
    {
        let urlString = self.urlString
        let url : URL!
        if urlString.hasPrefix("https://") || urlString.hasPrefix("http://")
        {
            url = URL(string: urlString)
        }
        else
        {
            let correctedURL = "http://\(urlString)"
            url = URL(string: correctedURL)
        }
        if UIApplication.shared.canOpenURL(url)
        {
            UIApplication.shared.openURL(url)
            return true
        }
        return false
    }
    
    //ADD CONTACT DETAIL
    @objc func addNewContact(){
        // Create Album Form
        isCreateOrEdit = false
        let presentedVC = FormGenerationViewController()
        presentedVC.formTitle = NSLocalizedString("Add New Contact", comment: "")
        presentedVC.contentType = "Contact"
        presentedVC.param = [ : ]
        presentedVC.url = "sitepage/get-contact/" + String(subjectId)
        presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        let nativationController = UINavigationController(rootViewController: presentedVC)
        self.present(nativationController, animated:true, completion: nil)
    }
    @objc func goBack(){
        _ = self.navigationController?.popViewController(animated: false)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
