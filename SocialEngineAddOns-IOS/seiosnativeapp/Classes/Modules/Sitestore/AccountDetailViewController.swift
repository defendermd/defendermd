//
//  AccountDetailViewController.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 29/08/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit

class AccountDetailViewController: UIViewController {

    var btnShop : UIButton!
    var btnLogin : UIButton!
    var leftBarButtonItem : UIBarButtonItem!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        btnShop = createButton(CGRect(x: view.bounds.width-200/2, y: (view.bounds.height-60)/2, width: 200, height: 40), title: NSLocalizedString("Shop as Guest",comment: ""), border: false, bgColor: true, textColor: textColorLight)
        btnShop.backgroundColor = navColor
        btnShop.layer.cornerRadius = cornerRadiusSmall
        btnShop.addTarget(self, action: #selector(AccountDetailViewController.shopAction), for: .touchUpInside)
        view.addSubview(btnShop)
        
        
        btnLogin = createButton(CGRect(x:(view.bounds.width-200)/2,y: btnShop.frame.origin.y+50, width:200, height:40), title: NSLocalizedString("Login/Sign up",comment: ""),border: false,bgColor: true , textColor: textColorLight)
        btnLogin.backgroundColor = navColor
        btnLogin.layer.cornerRadius = cornerRadiusSmall
        btnLogin.addTarget(self, action: #selector(AccountDetailViewController.loginAction), for: .touchUpInside)
        view.addSubview(btnLogin)


        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        
                
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(AccountDetailViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem

        
        self.title = NSLocalizedString("Account Details", comment: "")
        
    }
    
    @objc func goBack()
    {
        
        _ = self.navigationController?.popViewController(animated: false)
    }
    
    @objc func shopAction()
    {
        //iscontinuingShop = true
        _ = self.navigationController?.popViewController(animated: false)
    }
    
    @objc func loginAction()
    {
        if showAppSlideShow == 1 {
            let presentedVC  = SlideShowLoginScreenViewController()
            iscomingfrom = "store"
            self.navigationController?.pushViewController(presentedVC, animated: true)
            
        }
        else{
        let VC = LoginViewController()
        self.navigationController?.pushViewController(VC, animated: true)
        iscomingfrom = "store"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    

}
