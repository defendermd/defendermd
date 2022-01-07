//
//  two_step_verificationViewController.swift
//  seiosnativeapp
//
//  Created by Bigstep IOS on 10/11/17.
//  Copyright © 2017 bigstep. All rights reserved.
//


//
//  ViewController.swift
//  Audio
//
//  Created by Bigstep IOS on 6/14/17.
//  Copyright © 2017 Bigstep IOS. All rights reserved.
//

import UIKit
import AVFoundation
var otpurl = [String]()
var userid  = Int()
var addedittype : String = ""

class two_step_verificationViewController: UIViewController{

    var label1 = UILabel()
    var label2 = UILabel()
    var image = UIImageView()
    var label3 = UILabel()
    var label4 = UILabel()
    var switchButton = UISwitch()
    var label5 = UILabel()
    var edit = UIButton()
    var remove = UIButton()
    var actionValue : Int = 0
    var no_textfield = UITextField()
    var save = UIButton()
    var add_no = UITextField()
    var save_add_no = UIButton()
    var addlabel = UILabel()
    var box = UIView()
    var cancel = UIButton()
    var code_refresh : Int = 0
    var txtValue = UITextField()
    var tapGesture = UITapGestureRecognizer()
    var keyBoardHeight1 :  CGFloat = 0
    var value :  CGFloat = 0
    var phoneno : String = ""
    var country_code : String = ""
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(two_step_verificationViewController.getdata), name: NSNotification.Name(rawValue: "editNo"), object: nil)
        
        navigationItem.title = "\(NSLocalizedString("Phone Number Details",  comment: ""))"
        view.backgroundColor = bgColor
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(two_step_verificationViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        self.getdata()
    }
    
    @objc func goBack()
    {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers
        for aViewController in viewControllers {
            if aViewController is SettingsViewController {
                self.navigationController!.popToViewController(aViewController, animated: true)
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        // Register to receive notification
      
    }
    
    func declaration()
    {
        label2 = UILabel(frame: CGRect(x: 10, y : TOPPADING+10  ,width: UIScreen.main.bounds.width-20, height: 50))
        label2.text = "\(NSLocalizedString("Enabling two factor verification secures your account from unauthorized access, as you will receive OTP code on your registered phone number whenever you are signing in your account.",  comment: "")) "
        label2.textAlignment = NSTextAlignment.justified
        label2.font = UIFont(name: fontName, size: FONTSIZENormal)
        label2.numberOfLines = 0
        label2.lineBreakMode = NSLineBreakMode.byWordWrapping
        label2.sizeToFit()
        view.addSubview(label2)
        
        if otpurl.count > 1
        {
            label1 = UILabel(frame: CGRect(x: 10, y : getBottomEdgeY(inputView: label2) + 30 + 10,width: 30, height: 20))
            label1.text = closedIcon
            label1.textColor = textColorDark
            label1.font = UIFont(name: "FontAwesome", size: FONTSIZEExtraLarge)
            view.addSubview(label1)
            
            label3 = UILabel(frame: CGRect(x: getRightEdgeX(inputView: label1), y : getBottomEdgeY(inputView: label2) + 30 + 10,width: UIScreen.main.bounds.width-(getRightEdgeX(inputView: label1)+70), height: 20))
            label3.text = "\(NSLocalizedString("Two factor verification for ",  comment: ""))" + "+" + self.country_code + " " + self.phoneno
            label3.textColor = textColorDark
            label3.font = UIFont(name: fontName, size: FONTSIZENormal)
            label3.numberOfLines = 0
            label3.lineBreakMode = NSLineBreakMode.byWordWrapping
            label3.sizeToFit()
            view.addSubview(label3)
            
            switchButton = UISwitch(frame: CGRect(x: UIScreen.main.bounds.width - 60, y : getBottomEdgeY(inputView: label2) + 30 ,width: 40, height: 20))
            if actionValue == 0 {
                label3.text = "\(NSLocalizedString("Two factor verification for ",  comment: ""))" + "+" + self.country_code + " " + self.phoneno
                switchButton.isOn = false
            }
            else
            {
                label3.text = "\(NSLocalizedString("Two factor verification for ",  comment: ""))" + "+" + self.country_code + " " + self.phoneno
                switchButton.isOn = true
            }
            switchButton.addTarget(self, action: #selector(action(_ :)), for: .touchUpInside)
            view.addSubview(switchButton)
            
            label4 = UILabel(frame: CGRect(x: 10, y : getBottomEdgeY(inputView: label1) + 39,width: 30, height: 20))
            label4.text = "\u{f10b}"
            label4.textColor = textColorDark
            label4.font = UIFont(name: "FontAwesome", size: FONTSIZEExtraLarge)
            view.addSubview(label4)
            
            label5 = UILabel(frame: CGRect(x: getRightEdgeX(inputView: label1), y : getBottomEdgeY(inputView: label1) + 35,width: UIScreen.main.bounds.width - 140, height: 25))
            label5.text = "+\(self.country_code) \(self.phoneno)"
            label5.font = UIFont(name: "FontAwesome", size: FONTSIZELarge)
            view.addSubview(label5)
            
            edit = createButton(CGRect(x: UIScreen.main.bounds.width - 120, y: getBottomEdgeY(inputView: label1) + 35, width: 50 , height: 30), title: blogIcon, border: false,bgColor: false, textColor: textColorDark)
            edit.contentHorizontalAlignment = .center
            edit.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZEExtraLarge)
            edit.addTarget(self, action: #selector(editno), for: .touchUpInside)
            view.addSubview(edit)
            
            remove = createButton(CGRect(x: getRightEdgeX(inputView: edit) + 10, y: getBottomEdgeY(inputView: label1) + 35, width: 50 , height: 30), title: deleteFeedIcon, border: false,bgColor: false, textColor: textColorDark)
            remove.contentHorizontalAlignment = .center
            remove.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZEExtraLarge)
            remove.addTarget(self, action: #selector(alertview), for: .touchUpInside)
            view.addSubview(remove)
        }
        else{
            
            let presentedVC = EdittwostepverficationsettingViewController()
            presentedVC.url = "otpverifier/add-mobileno"
            addedittype = "add"
            presentedVC.Addno = true
            self.navigationController?.pushViewController(presentedVC, animated: false)
        }
    }
    
    @objc func getdata()
    {
        view.addSubview(activityIndicatorView)
        activityIndicatorView.center = self.view.center
        activityIndicatorView.startAnimating()
        otpurl.removeAll(keepingCapacity: false)
        var parameter = [String:String]()
        parameter = ["":""]
        // Send Server Request to Sign Up Form
        post(parameter,url: "otpverifier/add-mobileno" , method: "GET") { (succeeded, msg) -> () in
            
            DispatchQueue.main.async(execute: {
                activityIndicatorView.stopAnimating()
                if msg{
                    if let body = succeeded["body"] as? NSDictionary
                    {
                        if let body = succeeded["body"] as? NSDictionary
                        {
                            if let response = body["response"] as? NSDictionary
                            {
                                if let phoneno = response["phoneno"] as? Int64{
                                    self.phoneno = String(describing: phoneno)
                                }
                                userid = response["user_id"]! as! Int
                                if let enable = response["enable_verification"] as? Int{
                                    self.actionValue = enable
                                }
                                if let country_code = response["country_code"] as? Int{
                                    self.country_code = String(describing: country_code)
                                }
                            }
                        }
                        
                        if let gutterMenu = body["menu"] as? NSArray
                        {
                            for i in stride(from: 0, to: gutterMenu.count, by: 1){
                                if let dic = gutterMenu[i] as? NSDictionary{
                                    otpurl.append((dic["url"] as? String)!)
                                }
                            }
                        }
                    }
                    for ob in self.view.subviews{
                        ob.removeFromSuperview()
                    }
                    self.declaration()
                }
                else
                {
                    if succeeded["message"] != nil{
                        showToast(message: succeeded["message"] as! String, controller: self)
                        
                    }
                }
            })
        }
    }
    
    @objc func action(_ sender: UISwitch)
    {
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.center = self.view.center
        activityIndicatorView.startAnimating()
        var parameter = [String:String]()
        
        if actionValue == 0
        {
            parameter = ["enable_verification":"1"]
        }
        else
        {
            parameter = ["enable_verification":"0"]
        }
        post(parameter,url: "otpverifier/enable-verification" , method: "POST") { (succeeded, msg) -> () in
            
            DispatchQueue.main.async(execute: {
                activityIndicatorView.stopAnimating()
                self.code_refresh = 1
                if msg{
                    if self.actionValue == 0
                    {
                        self.switchButton.isOn = true
                        self.label3.text = "\(NSLocalizedString("Two factor verification for ",  comment: ""))" + "+" + self.country_code + " " + self.phoneno
                        self.actionValue = 1
                        showToast(message: "\(NSLocalizedString("Two factor verification enabled.",  comment: ""))", controller: self)
                    }
                    else
                    {
                        self.switchButton.isOn = false
                        self.label3.text = "\(NSLocalizedString("Two factor verification for ",  comment: ""))" + "+" + self.country_code + " " + self.phoneno
                        self.actionValue = 0
                        showToast(message: "\(NSLocalizedString("Two factor verification disabled.",  comment: ""))", controller: self)
                    }
                    
                }
                else
                {
                    if succeeded["message"] != nil{
                        showToast(message: succeeded["message"] as! String, controller: self)
                        
                    }
                }
                
            })
        }
    }
    
    @objc func editno()
    {
        let presentedVC = EdittwostepverficationsettingViewController()
        presentedVC.url = "otpverifier/edit-mobileno"
        addedittype = "edit"
        presentedVC.Addno = false
        presentedVC.countrycode = self.country_code
        presentedVC.phoneno = self.phoneno
        self.navigationController?.pushViewController(presentedVC, animated: false)
    }
    
    @objc func alertview()
    {
        let alert = UIAlertController(title: "\(NSLocalizedString("Remove Phone Number ?",  comment: ""))", message: "\(NSLocalizedString("Are you sure you want to remove the phone number ?",  comment: ""))", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive, handler: {
            (UIAlertAction) -> Void in
            self.removeno()
        }))
        self.present(alert, animated: true, completion: nil)
    }

    func removeno()
    {
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.center = self.view.center
        activityIndicatorView.startAnimating()
        var parameter = [String:String]()
        parameter = ["":""]
        // Send Server Request to Sign Up Form
        post(parameter,url: "otpverifier/delete-mobileno" , method: "DELETE") { (succeeded, msg) -> () in
            
            DispatchQueue.main.async(execute: {
                activityIndicatorView.stopAnimating()
                self.code_refresh = 1
                if msg{                    
                    for ob in self.view.subviews{
                        ob.removeFromSuperview()
                    }
                    self.getdata()
                    showToast(message: "Your mobile number is successfully deleted ", controller: self)
                }
                else
                {
                    showToast(message: succeeded["message"] as! String, controller: self)
                }
            })
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
