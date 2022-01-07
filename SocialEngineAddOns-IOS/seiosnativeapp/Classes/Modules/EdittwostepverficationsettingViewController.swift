//
//  EdittwostepverficationsettingViewController.swift
//  seiosnativeapp
//
//  Created by Bigstep IOS on 4/16/18.
//  Copyright © 2018 bigstep. All rights reserved.
//

import UIKit

class EdittwostepverficationsettingViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    var tapGesture = UITapGestureRecognizer()
    var no_textfield = UITextField()
    var code_textfield = UITextField()
    var label2 = UILabel()
    var linelabel1 = UILabel()
    var linelabel2 = UILabel()
    var verify = UIButton()
    var url : String = ""
    var Addno : Bool = false
    var phoneno : String = ""
    var countrycode : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let sidepaading : CGFloat = 10
        
        navigationItem.title = "\(NSLocalizedString("Phone Number Details",  comment: ""))"
        view.backgroundColor = bgColor
        
       let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(EdittwostepverficationsettingViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(EdittwostepverficationsettingViewController.resignKeyboard))
        tapGesture.delegate = self
        tapGesture.cancelsTouchesInView = false;
        view.addGestureRecognizer(tapGesture)
        
        label2 = UILabel(frame: CGRect(x: sidepaading, y : TOPPADING+10  ,width: UIScreen.main.bounds.width-(2*sidepaading), height: 50))
        label2.text = "\(NSLocalizedString("Enabling two factor verification secures your account from unauthorized access, as you will receive OTP code on your registered phone number whenever you are signing in your account.",  comment: "")) "
        label2.textAlignment = NSTextAlignment.justified
        label2.font = UIFont(name: fontName, size: normalFontSize)
        label2.numberOfLines = 0
        label2.lineBreakMode = NSLineBreakMode.byWordWrapping
        label2.sizeToFit()
        view.addSubview(label2)
        
        code_textfield = UITextField(frame: CGRect(x: sidepaading, y : getBottomEdgeY(inputView: label2) + 10,width: 80, height: 45))
        let paddingView : UIView = UIView(frame: CGRect(x :0, y :0, width: 5, height : 20))
        code_textfield.leftView = paddingView
        code_textfield.leftViewMode = UITextField.ViewMode.always
        code_textfield.text = countrycode//"Code"
        code_textfield.placeholder = NSLocalizedString("Code", comment: "")
        code_textfield.keyboardType = UIKeyboardType.numbersAndPunctuation
        view.addSubview(code_textfield)
       
        linelabel1 = UILabel(frame: CGRect(x: sidepaading, y : getBottomEdgeY(inputView: code_textfield) - 11,width: 80, height: 1))
        linelabel1.backgroundColor = buttonColor
        linelabel1.font = UIFont(name: fontName, size: FONTSIZENormal)
        view.addSubview(linelabel1)
    
        no_textfield = UITextField(frame: CGRect(x: getRightEdgeX(inputView: code_textfield)+10, y : getBottomEdgeY(inputView: label2) + 10,width: UIScreen.main.bounds.width-(getRightEdgeX(inputView: code_textfield)+40), height: 45))
        let paddingView1 : UIView = UIView(frame: CGRect(x :0, y :0, width: 5, height : 20))
        no_textfield.leftView = paddingView1
        no_textfield.leftViewMode = UITextField.ViewMode.always
        no_textfield.text = phoneno//"Phone Number"
        no_textfield.placeholder = NSLocalizedString("Phone Number", comment: "")
        no_textfield.keyboardType = UIKeyboardType.decimalPad
        view.addSubview(no_textfield)
        
        linelabel2 = UILabel(frame: CGRect(x: getRightEdgeX(inputView: code_textfield)+10, y : getBottomEdgeY(inputView: no_textfield) - 11,width: UIScreen.main.bounds.width-(getRightEdgeX(inputView: code_textfield)+40), height: 1))
        linelabel2.backgroundColor = buttonColor
        linelabel2.font = UIFont(name: fontName, size: FONTSIZENormal)
        view.addSubview(linelabel2)
        
        verify = createButton(CGRect(x: sidepaading, y: getBottomEdgeY(inputView: no_textfield) + 30, width: UIScreen.main.bounds.width - (2*sidepaading) , height: 50), title: "\(NSLocalizedString("Verify",  comment: ""))", border: false,bgColor: false, textColor: textColorLight)
        verify.layer.borderColor = buttonBgColor.cgColor
        verify.layer.cornerRadius = verify.frame.size.width / 2;
        verify.layer.borderWidth = 2.5
        verify.layer.cornerRadius = 5.0
        verify.contentHorizontalAlignment = .center
        verify.titleLabel?.font = UIFont(name: fontNormal, size: FONTSIZELarge)
        verify.layer.borderWidth = borderWidth
        verify.backgroundColor = buttonBgColor
        verify.backgroundColor = buttonBgColor
        verify.addTarget(self, action: #selector(self.save_no), for: .touchUpInside)
        view.addSubview(verify)
    }
    
    @objc func resignKeyboard(){
        self.no_textfield.resignFirstResponder()
        self.code_textfield.resignFirstResponder()
    }
    
    @objc func save_no()
    {
        OTPvalue = no_textfield.text!
        
        if code_textfield.text?.length != 0 {
            if no_textfield.text?.length != 0{
                verify.setTitle(NSLocalizedString("Verifying...",comment: ""), for: UIControl.State())
                view.addSubview(activityIndicatorView)
                activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
                var parameter = [String:String]()
                parameter = ["mobileno":no_textfield.text!,"country_code":code_textfield.text!]
                // Send Server Request to Sign Up Form
                post(parameter,url: url , method: "POST") { (succeeded, msg) -> () in
                    DispatchQueue.main.async(execute: {
                        self.verify.setTitle(NSLocalizedString("Verify",comment: ""), for: UIControl.State())
                        activityIndicatorView.stopAnimating()
                        if msg{
                            country_code = self.code_textfield.text!
                            //print(succeeded)
                            let presentedVC = OtpVerificationViewController()
                            presentedVC.url = self.url
                            presentedVC.edit_no = 1
                            presentedVC.useremail = self.no_textfield.text!
                            if let subsResponse = succeeded["body"] as? NSDictionary{
                                if let response = subsResponse["response"] as? NSDictionary{
                                    if let duration = response["duration"] as? Int
                                    {
                                        presentedVC.duration = duration
                                    }
                                }
                            }
                            self.navigationController?.pushViewController(presentedVC, animated: false)
                        }
                        else
                        {
                            if succeeded["message"] != nil{
                                self.view.makeToast(succeeded["message"] as! String, duration: 5, position: CSToastPositionCenter)
                                
                            }
                        }
                        
                    })
                }
            }
            else
            {
                self.view.makeToast(NSLocalizedString("Please enter a valid phone number.",  comment: ""), duration: 5, position: CSToastPositionCenter)
            }
        }
        else
        {
            self.view.makeToast(NSLocalizedString("Please enter the Country Code. For example +91",  comment: ""), duration: 5, position: CSToastPositionCenter)
        }
    }
    
    @objc func goBack()
    {
        if Addno == true{
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers
            for aViewController in viewControllers {
                if aViewController is SettingsViewController {
                    self.navigationController!.popToViewController(aViewController, animated: true)
                }
            }
        }
        else
        {
            _ = self.navigationController?.popViewController(animated: false)
        }
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
