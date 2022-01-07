//
//  ManageCartViewController.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 22/08/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit
import CoreData
var Store_id:String = ""
var couponDIC = [String:String]()
var manageCartUpdate:Bool = false
var product_type:String = ""
class ManageCartViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate
{
    var cartDic = NSMutableDictionary()
    //var storearr = NSMutableArray()
    var storedic = NSMutableDictionary()
    var cartTableView:UITableView!
    var dynamicHeight:CGFloat = 70
    var footerHeight:CGFloat = 0.001
    var headerHeight:CGFloat = 40
    var StrcoupanCode:String = ""
    var btnUpdateCart:UIButton!
    var quantityDic = [String:String]()
    var logoutquantityDic = [String:String]()
    var isapplycoupon:Bool = false
    var CurrencySymbol = String()
    var Cartarr = NSMutableArray()
    var Errordic = [String:String]()
    var refresher:UIRefreshControl!
    var ErrorStorearr = NSMutableArray()
    var info:UILabel!
    var iscomingFrom = String()
    var url = String()
    var showSpinner = true
    var loginORguestView: CouponDetailView!
    var blackScreen: UIView!
    var btnLogin:UIButton!
    var btnGuest:UIButton!
    var email : UITextField!
    var directPayment = true
    var contentIcon : UILabel!
    // MARK: Load view
    override func viewDidLoad()
    {
        super.viewDidLoad()
        manageCartUpdate = false
        navigationSetUp()
        SetupView()
        

        if logoutUser == true
        {
            //Getting Record from Core data
            GetrecartData()
            
        }
        
        // When login from managecart and comes back
        if iscomingfrom == "store"
        {
            iscomingfrom = ""
            if (showSpinner)
            {
//                spinner.center = view.center
//                spinner.hidesWhenStopped = true
//                spinner.style = UIstyle.gray
//                view.addSubview(spinner)
                self.view.addSubview(activityIndicatorView)
                activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
                
            }

            let triggerTime = DispatchTime.now() + .seconds(2)
            DispatchQueue.main.asyncAfter(deadline: triggerTime) {
                self.browseCart()
            }
        }
        else
        {
            
            browseCart()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        removeNavigationViews(controller: self)
        // For redirecting to orderview page after place order
        if iscomingfrom == "orderReview"
        {
            iscomingfrom = ""
            if logoutUser == false
            {
                
                let vc = MyStoreViewController()
                self.navigationController?.pushViewController(vc, animated: false)
                
            }

        }
        if tabBarController != nil{
            baseController?.tabBar.items?[self.tabBarController!.selectedIndex].title = nil
        }

        view.backgroundColor = bgColor
        removeMarqueFroMNavigaTion(controller: self)
        if let tabBarObject = self.tabBarController?.tabBar
        {
            tabBarObject.isHidden = false
            tabBarObject.items?[self.tabBarController!.selectedIndex].title = ""
        }

        // Refreshing cart
        if manageCartUpdate == true
        {
            manageCartUpdate = false
            if logoutUser == true
            {
                //Getting Record from Core data
                GetrecartData()
                
                // Login button in case of guest user
                let button   = UIButton(type: UIButton.ButtonType.system) as UIButton
                button.setTitle("Login", for:UIControl.State.normal)
                button.frame = CGRect(x:self.view.bounds.size.width-100, y:0, width:60, height:20)
                button.backgroundColor = UIColor.clear
                button.addTarget(self, action: #selector(ManageCartViewController.loginAction), for: UIControl.Event.touchUpInside)
                let loginButton = UIBarButtonItem()
                loginButton.customView = button
                self.navigationItem.setRightBarButtonItems([loginButton], animated: true)
  
            }
            browseCart()

        }

    }
   
    override func viewDidAppear(_ animated: Bool)
    {
        setNavigationImage(controller: self)
    }

    @objc func goBack()
    {
        
         _ = self.navigationController?.popViewController(animated: false)
        
    }
    func navigationSetUp()
    {
        
        setNavigationImage(controller: self)
        self.navigationController?.navigationBar.isHidden = false
        self.title = NSLocalizedString("Shopping Cart", comment: "")
        baseController?.tabBar.items?[self.tabBarController!.selectedIndex].title = nil
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        
        if baseController.selectedIndex == 1 || baseController.selectedIndex == 2 || baseController.selectedIndex == 3{
            self.navigationItem.setHidesBackButton(true, animated: false)
            
        }
        else{
            let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
            backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
            leftNavView.addSubview(backIconImageView)
            
            leftNavView.backgroundColor = UIColor.clear
            let tapView = UITapGestureRecognizer(target: self, action: #selector(ManageCartViewController.goBack))
            leftNavView.addGestureRecognizer(tapView)
            
        }
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
    }
    func SetupView()
    {
        if tabBarHeight > 0
        {
            cartTableView = UITableView(frame: CGRect(x:0, y:0, width:view.bounds.width, height:view.bounds.height - tabBarHeight), style:.grouped)
            //cartTableView.contentInset = UIEdgeInsetsMake(0, 0, 60, 0)
        }
        else
        {
            cartTableView = UITableView(frame: CGRect(x:0, y:0, width:view.bounds.width, height:view.bounds.height - tabBarHeight ), style:.grouped)
        }
        
        cartTableView.register(ManageCartCell.self, forCellReuseIdentifier: "CellThree")
        cartTableView.estimatedRowHeight = 70
        cartTableView.rowHeight = UITableView.automaticDimension
        cartTableView.isOpaque = false
        cartTableView.backgroundColor = tableViewBgColor//UIColor.white//tableViewBgColor
        cartTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.cartTableView.dataSource = self
        self.cartTableView.delegate = self
        self.view.addSubview(cartTableView)
        
        // Set pull to referseh for eventtableview
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(ManageCartViewController.refresh), for:UIControl.Event.valueChanged)
        cartTableView.addSubview(refresher)
        
        btnUpdateCart = createButton(CGRect(x:0,y:UIScreen.main.bounds.height, width:UIScreen.main.bounds.width , height:50), title: "Update Cart", border: false, bgColor: false, textColor: textColorLight)
        btnUpdateCart.titleLabel?.font =  UIFont(name: fontName, size:FONTSIZELarge)
        btnUpdateCart.layer.cornerRadius = 2
        btnUpdateCart.layer.borderWidth = 1
        btnUpdateCart.backgroundColor = navColor
        btnUpdateCart.layer.borderColor = textColorMedium.cgColor
        btnUpdateCart.addTarget(self, action: #selector(ManageCartViewController.updateCartAction), for: .touchUpInside)
        self.view.addSubview(btnUpdateCart)
        
        // Empty cart icon
        self.contentIcon = createLabel(CGRect(x: self.view.bounds.width/2 - 30,y: self.view.bounds.height/2-50,width: 60 , height: 50), text: NSLocalizedString("\(cartIcon)",  comment: "") , alignment: .center, textColor: textColorMedium)
        self.contentIcon.font = UIFont(name: "FontAwesome", size: 50)
        self.contentIcon.isHidden = true
        self.contentIcon.tag = 1000
        self.view.addSubview(self.contentIcon)
        
        // Message when records not available
        self.info = createLabel(CGRect(x:5,y:UIScreen.main.bounds.height/2,width:self.view.bounds.width-10 , height:30), text: NSLocalizedString("Cart is empty.",  comment: "") , alignment: .center, textColor: textColorMedium)
        self.info.numberOfLines = 0
        self.info.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.info.backgroundColor = bgColor
        self.info.tag = 1000
        self.info.isHidden = true
        self.view.addSubview(self.info)
        
        blackScreen = UIView(frame: view.frame)
        blackScreen.backgroundColor = UIColor.black
        blackScreen.alpha = 0.0
        view.addSubview(blackScreen)
        
        //Creating view for checkout with login or as a guest
        loginguestCheckoutView()
        
    }
    
    // MARK:  UITableViewDelegate & UITableViewDataSource
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return headerHeight
        
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let arr = self.storedic.allKeys
        if arr.count > 0 {
            
            
            let index = arr[section]
            
            let dic = self.storedic["\(index)"] as! NSDictionary
            var storeName = String()
            storeName = ""
            if let storename = dic["name"] as? String
            {
                storeName = storename
            }
            
            let tableViewHeader = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 40))
            
            let headerLabel = createLabel(CGRect(x:10, y:0, width:UIScreen.main.bounds.width-20 , height:40), text: "", alignment:NSTextAlignment.left, textColor: textColorDark)
            headerLabel.numberOfLines = 0
            headerLabel.font = UIFont(name: fontName, size: FONTSIZEMedium)
            headerLabel.text = storeName
            headerLabel.backgroundColor = UIColor.clear
            tableViewHeader.addSubview(headerLabel)
            
            tableViewHeader.frame = CGRect(x:0, y:0, width:self.view.bounds.size.width, height:headerLabel.frame.size.height+headerLabel.frame.origin.y)
            tableViewHeader.backgroundColor = UIColor.clear//aafBgColor//UIColor.white
            headerHeight = tableViewHeader.frame.size.height
            return tableViewHeader
        }

        let tableViewHeader = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        return tableViewHeader

    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        let arr = self.storedic.allKeys
        if arr.count > 0
        {
            let index = arr[section]
            let dic = self.storedic["\(index)"] as! NSDictionary
            //CreateFooter(dic)
            footerHeight = 0.0001
            let tableViewFooter = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 50))
            
            if let coupancode = dic["canApplyCoupon"] as? Int
            {
                let txtcoupan = createTextField(CGRect(x:10, y:10, width:100, height:30), borderColor: borderColorClear , placeHolderText: "Enter code", corner: true)
                txtcoupan.font =  UIFont(name: fontName, size: FONTSIZESmall)
                txtcoupan.backgroundColor = tableViewBgColor
                txtcoupan.layer.masksToBounds = true
                txtcoupan.delegate = self
                txtcoupan.tag = section
                tableViewFooter.addSubview(txtcoupan)
                
                let btnApplycoupan =  createButton(CGRect(x:txtcoupan.frame.size.width+txtcoupan.frame.origin.x+10, y:txtcoupan.frame.size.height+txtcoupan.frame.origin.y+5, width:100, height:30), title: "Apply Coupon", border: false,bgColor: false, textColor: textColorLight)
                btnApplycoupan.backgroundColor =  navColor
                btnApplycoupan.layer.cornerRadius = 2.0
                btnApplycoupan.layer.borderWidth = 1
                btnApplycoupan.layer.borderColor = textColorLight.cgColor
                btnApplycoupan.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZESmall)
                btnApplycoupan.addTarget(self, action: #selector(ManageCartViewController.ApplyCoupanAction), for: .touchUpInside)
                btnApplycoupan.tag = section
                btnApplycoupan.isUserInteractionEnabled = true
                tableViewFooter.addSubview(btnApplycoupan)
                
                var footerY = btnApplycoupan.frame.size.height+btnApplycoupan.frame.origin.y+10
                if coupancode == 0
                {
                    btnApplycoupan.isUserInteractionEnabled = false
                }
                if let error = dic["couponerror"] as? String
                {
                    let errorLabel = createLabel(CGRect(x:10,y:btnApplycoupan.frame.size.height+btnApplycoupan.frame.origin.y+5,width:self.view.bounds.size.width-20,height:12), text: "", alignment: .left, textColor: UIColor.red)
                    errorLabel.numberOfLines = 0
                    errorLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
                    errorLabel.font = UIFont(name: fontName, size: FONTSIZESmall)
                    errorLabel.text = "\(error)"
                    errorLabel.sizeToFit()
                    tableViewFooter.addSubview(errorLabel)
                    footerY = errorLabel.frame.size.height+errorLabel.frame.origin.y+10
                    
                    let couponkey = "coupon_code_"+"\(index)"
                    couponDIC.removeValue(forKey: couponkey)
                    
                    
                }
                
                let paymentSummaryLabel = createLabel(CGRect(x:10,y:footerY,width:self.view.bounds.size.width-20,height:15), text: "", alignment: .left, textColor: textColorDark)
                paymentSummaryLabel.numberOfLines = 0
                paymentSummaryLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
                paymentSummaryLabel.font = UIFont(name: fontName, size: FONTSIZENormal)
                paymentSummaryLabel.text = NSLocalizedString("Payment Summary", comment: "")
                tableViewFooter.addSubview(paymentSummaryLabel)
                
                var i = paymentSummaryLabel.frame.size.height+paymentSummaryLabel.frame.origin.y+10
                if let profileField = dic["totalAmountFields"] as? NSMutableDictionary
                {
                    
                    
                    for (k,v) in profileField
                    {
                        let profileFieldLabel = createLabel(CGRect(x:10,y:i,width:self.view.bounds.size.width-120,height:15), text: "", alignment: .left, textColor: textColorMedium)
                        profileFieldLabel.numberOfLines = 0
                        profileFieldLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
                        profileFieldLabel.textColor = textColorMedium
                        profileFieldLabel.layer.borderColor = navColor.cgColor
                        profileFieldLabel.font = UIFont(name: fontName, size: FONTSIZENormal)
                        profileFieldLabel.text = "\(k)"
                        tableViewFooter.addSubview(profileFieldLabel)
                        
                        let profileFieldvalueLabel = createLabel(CGRect(x:self.view.bounds.size.width-110,y:i,width:100,height:15), text: "", alignment: .left, textColor: textColorDark)
                        profileFieldvalueLabel.numberOfLines = 0
                        profileFieldvalueLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
                        profileFieldvalueLabel.textColor = textColorDark
                        profileFieldvalueLabel.layer.borderColor = navColor.cgColor
                        profileFieldvalueLabel.font = UIFont(name: fontBold, size: FONTSIZENormal)
                        
                        var value = gettwoFractionDigits(FractionDigit: "\(v)")
                        value = "\(self.CurrencySymbol)"+"\(value)"
                        
                        if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
                            let defaults = UserDefaults.standard
                            if let name = defaults.object(forKey: "Currency")
                            {
                                let price = gettwoFractionDigits(FractionDigit: "\(v)")
                                let changePrice = (defaults.object(forKey: "PriceRate") as! Float) * Float(price)!
                                let showPrice = (String(format:"%.2f", changePrice))
                                
                                profileFieldvalueLabel.text =  "\(getCurrencySymbol(name as! String)) \(showPrice)"
                                
                            }
                        }
                        else{
                        
                        profileFieldvalueLabel.text = value
                        }
                        tableViewFooter.addSubview(profileFieldvalueLabel)
                        i = i+25
                        
                        
                    }
                    // Showing VAT if applied
                    if let vatField = dic["totalVatFields"] as? NSMutableDictionary
                    {
                        // Showing store subtotal
                        for (k,v) in vatField
                        {
                            
                            let vatFieldLabel = createLabel(CGRect(x:10,y:i,width:self.view.bounds.size.width-120,height:15), text: "", alignment: .left, textColor: textColorMedium)
                            vatFieldLabel.numberOfLines = 0
                            vatFieldLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
                            vatFieldLabel.textColor = textColorMedium
                            vatFieldLabel.layer.borderColor = navColor.cgColor
                            vatFieldLabel.font = UIFont(name: fontName, size: FONTSIZENormal)
                            vatFieldLabel.text = "\(k)"
                            tableViewFooter.addSubview(vatFieldLabel)
                            
                            let vatFieldvalueLabel = createLabel(CGRect(x:self.view.bounds.size.width-110,y:i,width:100,height:15), text: "", alignment: .left, textColor: textColorDark)
                            vatFieldvalueLabel.numberOfLines = 0
                            vatFieldvalueLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
                            vatFieldvalueLabel.textColor = textColorDark
                            vatFieldvalueLabel.font = UIFont(name: fontBold, size: FONTSIZENormal)
                            vatFieldvalueLabel.layer.borderColor = navColor.cgColor
                            vatFieldvalueLabel.textAlignment = NSTextAlignment.right
                            var value = gettwoFractionDigits(FractionDigit:"\(v)")
                            value = "\(self.CurrencySymbol)"+"\(value)"
                            
                            if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
                                let defaults = UserDefaults.standard
                                if let name = defaults.object(forKey: "Currency")
                                {
                                    let price = gettwoFractionDigits(FractionDigit: "\(v)")
                                    let changePrice = (defaults.object(forKey: "PriceRate") as! Float) * Float(price)!
                                    let showPrice = (String(format:"%.2f", changePrice))
                                    
                                    vatFieldvalueLabel.text =  "\(getCurrencySymbol(name as! String)) \(showPrice)"
                                    
                                }
                            }
                            else{
                                
                                vatFieldvalueLabel.text = value
                            }
                            
                           // vatFieldvalueLabel.text = value
                            tableViewFooter.addSubview(vatFieldvalueLabel)
                            
                            i = i+25
                            
                            
                        }
                    }
                    
                    if let couponDic =  dic["coupon"] as? NSDictionary
                    {
                        let couponcode = couponDic["coupon_code"]
                        let coupanvalue = gettwoFractionDigits(FractionDigit:"\(couponDic["value"] as! Double)")
                        // profileField["\(couponcode!)"] = "\(coupanvalue)"
                        
                        let couponLabel = createLabel(CGRect(x:10,y:i,width:self.view.bounds.size.width-120,height:15), text: "", alignment: .left, textColor: textColorMedium)
                        couponLabel.numberOfLines = 0
                        couponLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
                        couponLabel.textColor = textColorMedium
                        couponLabel.layer.borderColor = navColor.cgColor
                        couponLabel.font = UIFont(name: fontName, size: FONTSIZENormal)
                        couponLabel.text = "\(couponcode!)"
                        tableViewFooter.addSubview(couponLabel)
                        
                        let couponvalueLabel = createLabel(CGRect(x:self.view.bounds.size.width-110,y:i,width:100,height:15), text: "", alignment: .left, textColor: textColorDark)
                        couponvalueLabel.numberOfLines = 0
                        couponvalueLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
                        couponvalueLabel.textColor = textColorDark
                        couponvalueLabel.font = UIFont(name: fontBold, size: FONTSIZENormal)
                        couponvalueLabel.layer.borderColor = navColor.cgColor
                        couponvalueLabel.textAlignment = NSTextAlignment.right
                        var value = gettwoFractionDigits(FractionDigit:"\(coupanvalue)")
                        value = "-"+"\(self.CurrencySymbol)"+"\(value)"
                        
                        if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
                            let defaults = UserDefaults.standard
                            if let name = defaults.object(forKey: "Currency")
                            {
                                let price = gettwoFractionDigits(FractionDigit: "\(coupanvalue)")
                                let changePrice = (defaults.object(forKey: "PriceRate") as! Float) * Float(price)!
                                let showPrice = (String(format:"%.2f", changePrice))
                                
                                couponvalueLabel.text =  "\(getCurrencySymbol(name as! String)) \(showPrice)"
                                
                            }
                        }
                        else{
                            
                            couponvalueLabel.text = value
                        }
                      //  couponvalueLabel.text = value
                        tableViewFooter.addSubview(couponvalueLabel)
                        i = couponvalueLabel.frame.size.height+couponvalueLabel.frame.origin.y+10
                        
                        
                    }
                    // Showing grand total
                    if let grandtotal =  dic["total"] as? Double
                    {
                        
                        let grandtotalLabel = createLabel(CGRect(x:10,y:i,width:self.view.bounds.size.width-120,height:15), text: "", alignment: .left, textColor: textColorMedium)
                        grandtotalLabel.numberOfLines = 0
                        grandtotalLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
                        grandtotalLabel.textColor = textColorMedium
                        grandtotalLabel.layer.borderColor = navColor.cgColor
                        grandtotalLabel.font = UIFont(name: fontName, size: FONTSIZENormal)
                        grandtotalLabel.text = NSLocalizedString("Grand Total", comment: "")
                        tableViewFooter.addSubview(grandtotalLabel)
                        
                        let grandtotalvalueLabel = createLabel(CGRect(x:self.view.bounds.size.width-110,y:i,width:100,height:15), text: "", alignment: .left, textColor: textColorDark)
                        grandtotalvalueLabel.numberOfLines = 0
                        grandtotalvalueLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
                        grandtotalvalueLabel.textColor = textColorDark
                        grandtotalvalueLabel.font = UIFont(name: fontBold, size: FONTSIZENormal)
                        grandtotalvalueLabel.layer.borderColor = navColor.cgColor
                        grandtotalvalueLabel.textAlignment = NSTextAlignment.right
                        var value = gettwoFractionDigits(FractionDigit:"\(grandtotal)")
                        value = "\(self.CurrencySymbol)"+"\(value)"
                        
                        if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
                            let defaults = UserDefaults.standard
                            if let name = defaults.object(forKey: "Currency")
                            {
                                let price = gettwoFractionDigits(FractionDigit: "\(grandtotal)")
                                let changePrice = (defaults.object(forKey: "PriceRate") as! Float) * Float(price)!
                                let showPrice = (String(format:"%.2f", changePrice))
                                
                                grandtotalvalueLabel.text =  "\(getCurrencySymbol(name as! String)) \(showPrice)"
                                
                            }
                        }
                        else{
                            
                            grandtotalvalueLabel.text = value
                        }
                      //  grandtotalvalueLabel.text = value
                        tableViewFooter.addSubview(grandtotalvalueLabel)
                        i = grandtotalvalueLabel.frame.size.height+grandtotalvalueLabel.frame.origin.y+10
                        
                        
                    }
                    
                    let btnCheckout =  createButton(CGRect(x:self.view.bounds.size.width-110,y:i, width:100, height:35), title: "Checkout", border: false,bgColor: false, textColor: textColorLight)
                    btnCheckout.backgroundColor =  navColor
                    btnCheckout.layer.cornerRadius = 2.0
                    btnCheckout.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZESmall)
                    btnCheckout.setTitleColor(textColorDark, for: .highlighted)
                    btnCheckout.addTarget(self, action: #selector(ManageCartViewController.checkoutAction), for: .touchUpInside)
                    btnCheckout.tag = section
                    tableViewFooter.addSubview(btnCheckout)
                    if ErrorStorearr.contains(index)
                    {
                        btnCheckout.isUserInteractionEnabled = false
                        btnCheckout.alpha = 0.5
                    }
                    tableViewFooter.frame = CGRect(x:0, y:0, width:self.view.bounds.size.width,height:i)
                    
                    tableViewFooter.backgroundColor = UIColor.white//tableViewBgColor
                    footerHeight = tableViewFooter.frame.size.height+10
                    
                }
                
            }
        }

        return footerHeight
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        let arr = self.storedic.allKeys
        if arr.count > 0
        {
        let index = arr[section]
        let dic = self.storedic["\(index)"] as! NSDictionary
        footerHeight = 0.0001
        let tableViewFooter = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 50))
        
        if let coupancode = dic["canApplyCoupon"] as? Int
        {
            
            let txtcoupan = createTextField(CGRect(x:10, y:10, width:100, height:30), borderColor: borderColorClear , placeHolderText: "Enter code", corner: true)
            txtcoupan.font =  UIFont(name: fontName, size: FONTSIZESmall)
            txtcoupan.backgroundColor = tableViewBgColor
            txtcoupan.layer.masksToBounds = true
            txtcoupan.delegate = self
            txtcoupan.tag = section
            tableViewFooter.addSubview(txtcoupan)
            
            let btnApplycoupan =  createButton(CGRect(x:txtcoupan.frame.size.width+txtcoupan.frame.origin.x+10,y:10, width:100, height:30), title: "Apply Coupon", border: false,bgColor: false, textColor: textColorLight)
            btnApplycoupan.backgroundColor =  navColor
            btnApplycoupan.layer.cornerRadius = 2.0
            btnApplycoupan.layer.borderWidth = 1
            btnApplycoupan.layer.borderColor = textColorLight.cgColor
            btnApplycoupan.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZESmall)
            btnApplycoupan.addTarget(self, action: #selector(ManageCartViewController.ApplyCoupanAction), for: .touchUpInside)
            btnApplycoupan.tag = section
            btnApplycoupan.isUserInteractionEnabled = true
            tableViewFooter.addSubview(btnApplycoupan)
            
            var footerY = btnApplycoupan.frame.size.height+btnApplycoupan.frame.origin.y+10
            if coupancode == 0
            {
                btnApplycoupan.isUserInteractionEnabled = false
            }
            if let error = dic["couponerror"] as? String
            {
                let errorLabel = createLabel(CGRect(x:10,y:btnApplycoupan.frame.size.height+btnApplycoupan.frame.origin.y+5,width:self.view.bounds.size.width-20,height:12), text: "", alignment: .left, textColor: UIColor.red)
                errorLabel.numberOfLines = 0
                errorLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
                errorLabel.font = UIFont(name: fontName, size: FONTSIZESmall)
                errorLabel.text = "\(error)"
                tableViewFooter.addSubview(errorLabel)
                errorLabel.sizeToFit()
                footerY = errorLabel.frame.size.height+errorLabel.frame.origin.y+10
                
                let couponkey = "coupon_code_"+"\(index)"
                couponDIC.removeValue(forKey: couponkey)
                
                
            }
            let paymentSummaryLabel = createLabel(CGRect(x:10,y:footerY,width:self.view.bounds.size.width-20,height:15), text: "", alignment: .left, textColor: textColorDark)
            paymentSummaryLabel.numberOfLines = 0
            paymentSummaryLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
            paymentSummaryLabel.font = UIFont(name: fontName, size: FONTSIZENormal)
            paymentSummaryLabel.text = NSLocalizedString("Payment Summary", comment: "")
            tableViewFooter.addSubview(paymentSummaryLabel)
            
            var i = paymentSummaryLabel.frame.size.height+paymentSummaryLabel.frame.origin.y+10
            if let profileField = dic["totalAmountFields"] as? NSMutableDictionary
            {

                for (k,v) in profileField
                {
                    
                    let profileFieldLabel = createLabel(CGRect(x:10,y:i,width:self.view.bounds.size.width-120,height:15), text: "", alignment: .left, textColor: textColorMedium)
                    profileFieldLabel.numberOfLines = 0
                    profileFieldLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
                    profileFieldLabel.textColor = textColorMedium
                    profileFieldLabel.layer.borderColor = navColor.cgColor
                    profileFieldLabel.font = UIFont(name: fontName, size: FONTSIZENormal)
                    profileFieldLabel.text = "\(k)"
                    tableViewFooter.addSubview(profileFieldLabel)
                    
                    let profileFieldvalueLabel = createLabel(CGRect(x:self.view.bounds.size.width-110,y:i,width:100,height:15), text: "", alignment: .left, textColor: textColorDark)
                    profileFieldvalueLabel.numberOfLines = 0
                    profileFieldvalueLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
                    profileFieldvalueLabel.textColor = textColorDark
                    profileFieldvalueLabel.font = UIFont(name: fontBold, size: FONTSIZENormal)
                    profileFieldvalueLabel.layer.borderColor = navColor.cgColor
                    profileFieldvalueLabel.textAlignment = NSTextAlignment.right
                    var value = gettwoFractionDigits(FractionDigit:"\(v)")
                    value = "\(self.CurrencySymbol)"+"\(value)"
                    if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
                        let defaults = UserDefaults.standard
                        if let name = defaults.object(forKey: "Currency")
                        {
                            let price = gettwoFractionDigits(FractionDigit: "\(v)")
                            let changePrice = (defaults.object(forKey: "PriceRate") as! Float) * Float(price)!
                            let showPrice = (String(format:"%.2f", changePrice))
                            
                            profileFieldvalueLabel.text =  "\(getCurrencySymbol(name as! String)) \(showPrice)"
                            
                        }
                    }
                    else{
                        profileFieldvalueLabel.text = value
                    }
                    
                    tableViewFooter.addSubview(profileFieldvalueLabel)
                    
                    i = i+25
                    
                    
                }
                
                // Showing VAT if applied
                if let vatField = dic["totalVatFields"] as? NSMutableDictionary
                {
                    // Showing store subtotal
                    for (k,v) in vatField
                    {
                        
                        let vatFieldLabel = createLabel(CGRect(x:10,y:i,width:self.view.bounds.size.width-120,height:15), text: "", alignment: .left, textColor: textColorMedium)
                        vatFieldLabel.numberOfLines = 0
                        vatFieldLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
                        vatFieldLabel.textColor = textColorMedium
                        vatFieldLabel.layer.borderColor = navColor.cgColor
                        vatFieldLabel.font = UIFont(name: fontName, size: FONTSIZENormal)
                        vatFieldLabel.text = "\(k)"
                        tableViewFooter.addSubview(vatFieldLabel)
                        
                        let vatFieldvalueLabel = createLabel(CGRect(x:self.view.bounds.size.width-110,y:i,width:100,height:15), text: "", alignment: .left, textColor: textColorDark)
                        vatFieldvalueLabel.numberOfLines = 0
                        vatFieldvalueLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
                        vatFieldvalueLabel.textColor = textColorDark
                        vatFieldvalueLabel.font = UIFont(name: fontBold, size: FONTSIZENormal)
                        vatFieldvalueLabel.layer.borderColor = navColor.cgColor
                        vatFieldvalueLabel.textAlignment = NSTextAlignment.right
                        var value = gettwoFractionDigits(FractionDigit:"\(v)")
                        value = "\(self.CurrencySymbol)"+"\(value)"
                        
                        if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
                            let defaults = UserDefaults.standard
                            if let name = defaults.object(forKey: "Currency")
                            {
                                let price = gettwoFractionDigits(FractionDigit: "\(v)")
                                let changePrice = (defaults.object(forKey: "PriceRate") as! Float) * Float(price)!
                                let showPrice = (String(format:"%.2f", changePrice))
                                
                                vatFieldvalueLabel.text =  "\(getCurrencySymbol(name as! String)) \(showPrice)"
                                
                            }
                        }
                        else{
                            vatFieldvalueLabel.text = value
                        }
                        
                      //  vatFieldvalueLabel.text = value
                        tableViewFooter.addSubview(vatFieldvalueLabel)
                        
                        i = i+25
                        
                        
                    }
                }
                if let couponDic =  dic["coupon"] as? NSDictionary
                {
                    let couponcode = couponDic["coupon_code"]
                    let coupanvalue = gettwoFractionDigits(FractionDigit:"\(couponDic["value"] as! Double)")
                    // profileField["\(couponcode!)"] = "\(coupanvalue)"
                    
                    let couponLabel = createLabel(CGRect(x:10,y:i,width:self.view.bounds.size.width-120,height:15), text: "", alignment: .left, textColor: textColorMedium)
                    couponLabel.numberOfLines = 0
                    couponLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
                    couponLabel.textColor = textColorMedium
                    couponLabel.layer.borderColor = navColor.cgColor
                    couponLabel.font = UIFont(name: fontName, size: FONTSIZENormal)
                    couponLabel.text = "\(couponcode!)"
                    tableViewFooter.addSubview(couponLabel)
                    
                    let couponvalueLabel = createLabel(CGRect(x:self.view.bounds.size.width-110,y:i,width:100,height:15), text: "", alignment: .left, textColor: textColorDark)
                    couponvalueLabel.numberOfLines = 0
                    couponvalueLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
                    couponvalueLabel.textColor = textColorDark
                    couponvalueLabel.font = UIFont(name: fontBold, size: FONTSIZENormal)
                    couponvalueLabel.layer.borderColor = navColor.cgColor
                    couponvalueLabel.textAlignment = NSTextAlignment.right
                    var value = gettwoFractionDigits(FractionDigit:"\(coupanvalue)")
                    value = "-"+"\(self.CurrencySymbol)"+"\(value)"
                    
                    if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
                        let defaults = UserDefaults.standard
                        if let name = defaults.object(forKey: "Currency")
                        {
                            let price = gettwoFractionDigits(FractionDigit: "\(coupanvalue)")
                            let changePrice = (defaults.object(forKey: "PriceRate") as! Float) * Float(price)!
                            let showPrice = (String(format:"%.2f", changePrice))
                            
                            couponvalueLabel.text =  "-\(getCurrencySymbol(name as! String)) \(showPrice)"
                            
                        }
                    }
                    else{
                        couponvalueLabel.text = value
                    }
                    
                  //  couponvalueLabel.text = value
                    tableViewFooter.addSubview(couponvalueLabel)
                    i = couponvalueLabel.frame.size.height+couponvalueLabel.frame.origin.y+10
                    
                    
                }
                // Showing grand total
                if let grandtotal =  dic["total"] as? Double
                {
                    
                    let grandtotalLabel = createLabel(CGRect(x:10,y:i,width:self.view.bounds.size.width-120,height:15), text: "", alignment: .left, textColor: textColorMedium)
                    grandtotalLabel.numberOfLines = 0
                    grandtotalLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
                    grandtotalLabel.textColor = textColorMedium
                    grandtotalLabel.layer.borderColor = navColor.cgColor
                    grandtotalLabel.font = UIFont(name: fontName, size: FONTSIZENormal)
                    grandtotalLabel.text = NSLocalizedString("Grand Total", comment: "")
                    tableViewFooter.addSubview(grandtotalLabel)
                    
                    let grandtotalvalueLabel = createLabel(CGRect(x:self.view.bounds.size.width-110,y:i,width:100,height:15), text: "", alignment: .left, textColor: textColorDark)
                    grandtotalvalueLabel.numberOfLines = 0
                    grandtotalvalueLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
                    grandtotalvalueLabel.textColor = textColorDark
                    grandtotalvalueLabel.font = UIFont(name: fontBold, size: FONTSIZENormal)
                    grandtotalvalueLabel.layer.borderColor = navColor.cgColor
                    grandtotalvalueLabel.textAlignment = NSTextAlignment.right
                    var value = gettwoFractionDigits(FractionDigit:"\(grandtotal)")
                    value = "\(self.CurrencySymbol)"+"\(value)"
                    if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
                        let defaults = UserDefaults.standard
                        if let name = defaults.object(forKey: "Currency")
                        {
                            let price = gettwoFractionDigits(FractionDigit: "\(grandtotal)")
                            let changePrice = (defaults.object(forKey: "PriceRate") as! Float) * Float(price)!
                            let showPrice = (String(format:"%.2f", changePrice))
                            
                            grandtotalvalueLabel.text =  "\(getCurrencySymbol(name as! String)) \(showPrice)"
                            
                        }
                    }
                    else{
                    grandtotalvalueLabel.text = value
                    }
                    tableViewFooter.addSubview(grandtotalvalueLabel)
                    i = grandtotalvalueLabel.frame.size.height+grandtotalvalueLabel.frame.origin.y+10
                    
                    
                }

                let btnCheckout =  createButton(CGRect(x:self.view.bounds.size.width-110,y:i, width:100, height:35), title: "Checkout", border: false,bgColor: false, textColor: textColorLight)
                btnCheckout.backgroundColor =  navColor
                btnCheckout.layer.cornerRadius = 2.0
                btnCheckout.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZESmall)
                btnCheckout.setTitleColor(textColorDark, for: .highlighted)
                btnCheckout.addTarget(self, action: #selector(ManageCartViewController.checkoutAction), for: .touchUpInside)
                btnCheckout.tag = section
                btnCheckout.isUserInteractionEnabled = true
                btnCheckout.alpha = 1.0
                tableViewFooter.addSubview(btnCheckout)
                if ErrorStorearr.contains(index)
                {
                    btnCheckout.isUserInteractionEnabled = false
                    btnCheckout.alpha = 0.5
                }
                tableViewFooter.frame = CGRect(x:0, y:0, width:self.view.bounds.size.width,height:i)
                tableViewFooter.backgroundColor = UIColor.white//tableViewBgColor
                footerHeight = tableViewFooter.frame.size.height+10
            }
            
        }
        return tableViewFooter
        }
        
        let tableViewFooter = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        return tableViewFooter
   
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if dynamicHeight > 70
        {
            return dynamicHeight+1
        }
        return 71
        
    }
    
    // Set TableView Section
    func numberOfSections(in tableView: UITableView) -> Int
    {
      return storedic.count
    }
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let arr = self.storedic.allKeys
        if arr.count > 0
        {
            
            let index = arr[section]
            let dic = self.storedic["\(index)"] as! NSDictionary
            if let productarr = dic["products"] as? NSArray
            {
                return productarr.count
            }
        }
        
        return 0
    }
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = cartTableView.dequeueReusableCell(withIdentifier: "CellThree", for: indexPath)as! ManageCartCell
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.backgroundColor = UIColor.white//tableViewBgColor
        cell.profileFieldLabel.text = ""
        cell.profileFieldLabel.isHidden = true
        cell.errorLabel.isHidden = true
        cell.profileFieldLabel.frame = CGRect(x:cell.imgUser.bounds.width + 10, y:cell.btnPlus.frame.origin.y + cell.btnPlus.bounds.height + 8  , width:UIScreen.main.bounds.width - (cell.imgUser.bounds.width+10) , height:0)
        cell.lineView.frame = CGRect(x:0, y:cell.imgUser.frame.size.height+cell.imgUser.frame.origin.y+10,width:(UIScreen.main.bounds).width, height:1)
        let arr = self.storedic.allKeys
        let index = arr[indexPath.section]
        let dic = self.storedic["\(index)"] as! NSDictionary
        
        if let productarr = dic["products"] as? NSArray
        {
            let dic = productarr[indexPath.row] as! NSDictionary
            let product_id = dic["cartproduct_id"] as? Int
            let logoutproduct_id = dic["product_id"] as? Int
            cell.labTitle.text = dic["title"] as? String
            let url = NSURL(string: dic["image_profile"] as! NSString as String)
            cell.imgUser.kf.indicatorType = .activity
            (cell.imgUser.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
            cell.imgUser.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                
            })
            var quantity1 = Int()
            var price1 = Double()

            if let quantity = dic["quantity"] as? Int
            {
                cell.labQuantity.text = String(quantity)
                quantity1 = quantity
                if logoutUser == false
                {
                    
                    quantityDic["\(product_id!)"] = String(quantity)
                    for (key,value) in Errordic
                    {
                        if key == "\(product_id!)"
                        {
                            cell.errorLabel.isHidden = false
                            cell.errorLabel.text = "\(value)"
                            if !ErrorStorearr.contains(index)
                            {
                                ErrorStorearr.add(index)
                            }
                        }
                    }
                }
                else
                {
                    logoutquantityDic["\(logoutproduct_id!)"] = "\(quantity1)"
                }
                
            }
            if let error = dic["error"] as? String
            {
                cell.errorLabel.isHidden = false
                cell.errorLabel.text = String(error)
                if !ErrorStorearr.contains(index)
                {
                    ErrorStorearr.add(index)
                }
                logoutquantityDic["\(logoutproduct_id!)"] = "0"
            }
            
            var subtotal = ""
            
            if let price = dic["unitPrice"] as? Double
            {
                let value = gettwoFractionDigits(FractionDigit:"\(price)")
                if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
                    let defaults = UserDefaults.standard
                    if let name = defaults.object(forKey: "Currency")
                    {
                        let price = value//gettwoFractionDigits(FractionDigit: "\(grandtotal)")
                        let changePrice = (defaults.object(forKey: "PriceRate") as! Float) * Float(price)!
                        let showPrice = (String(format:"%.2f", changePrice))
                        
                        cell.labPrice.text =  "\(getCurrencySymbol(name as! String)) \(showPrice)"
                        
                    }
                }
                else{
                cell.labPrice.text = String(self.CurrencySymbol)+String(value)
                }
                subtotal = value
            }
            if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
                let defaults = UserDefaults.standard
                if let name = defaults.object(forKey: "Currency")
                {
                    let price = subtotal//gettwoFractionDigits(FractionDigit: "\(grandtotal)")
                    let changePrice = (defaults.object(forKey: "PriceRate") as! Float) * Float(price)!
                    let showPrice = (String(format:"%.2f", changePrice))
                    
                    cell.labSubTotal.text =  "\(getCurrencySymbol(name as! String)) \(showPrice)"
                    
                }
            }
            else{
            cell.labSubTotal.text = String(self.CurrencySymbol)+String(subtotal)
            }
            cell.btnMinus.tag = indexPath.row
            cell.btnPlus.tag = indexPath.row
            cell.btnPlus.addTarget(self, action: #selector(ManageCartViewController.plusAction), for: .touchUpInside)
            cell.btnMinus.addTarget(self, action: #selector(ManageCartViewController.minusAction), for: .touchUpInside)
            
            if let profileField =  dic["configuration"] as? NSDictionary
            {
                cell.profileFieldLabel.isHidden = false
                var profileFieldString = ""
                for (k,v) in profileField
                {
                    
                    profileFieldString += k as! String
                    profileFieldString += ": "
                    
                    var tempValue = ""
                    if (v is String){
                        tempValue = v as! String
                    }else{
                        tempValue = "\(v)"
                    }
                    profileFieldString += tempValue
                    profileFieldString += "\n"
                    
                    //self.profileFieldLabel.text = profileFieldString
                    cell.profileFieldLabel.setText(profileFieldString, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                        
                        let boldFont1 = CTFontCreateWithName((fontName as CFString?)!, FONTSIZEMedium, nil)
                        
                        let range1 = (profileFieldString as NSString).range(of: profileFieldString)
                        mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont1, range: range1)
                        mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorMedium , range: range1)
                        
                        return mutableAttributedString!
                    })
                }
                
                cell.profileFieldLabel.sizeToFit()
                
                dynamicHeight = 70
                if dynamicHeight < (cell.profileFieldLabel.frame.origin.y + cell.profileFieldLabel.bounds.height)
                {
                    dynamicHeight = cell.profileFieldLabel.frame.origin.y + cell.profileFieldLabel.bounds.height+10
                    cell.lineView.frame.origin.y = dynamicHeight
                    
                }
            }
            else
            {
                dynamicHeight = 70
                
                if dynamicHeight < (cell.profileFieldLabel.frame.origin.y + cell.profileFieldLabel.bounds.height)
                {
                    dynamicHeight = cell.profileFieldLabel.frame.origin.y + cell.profileFieldLabel.bounds.height+10
                    cell.lineView.frame.origin.y = dynamicHeight
                    
                }
            }
        }
        
        if directPayment == false && ErrorStorearr.count>0
        {
            CreateFooter(dic: self.cartDic)
        }
        return cell
    }
    
    // Handle Blog Table Cell Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCell.EditingStyle.delete)
        {
            DeleteAction(indexpath: indexPath as NSIndexPath)
        }
    }
    
    // MARK: Getting Checkout Form
    func browseCart()
    {
        
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork()
        {
            if (showSpinner)
            {
//                spinner.center = view.center
//                spinner.hidesWhenStopped = true
//                spinner.style = UIstyle.gray
//                view.addSubview(spinner)
                self.view.addSubview(activityIndicatorView)
                activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
                
            }
            
            // Reset Objects
            self.info.isHidden = true
            self.contentIcon.isHidden = true
            //Set Parameters & path for Sign Up Form
            var parameter = [String:String]()
            var path = ""
            parameter = ["":""]
            var method = ""
            if couponDIC.count>0
            {
                parameter = couponDIC
            }

            path = "sitestore/cart"
            method = "GET"

            // Logout user
            if logoutUser == true
            {
                if Cartarr.count>0
                {
                    // Convert core data array into json object
                    parameter["productsData"] = GetjsonObject(data:Cartarr)
                }
                else
                {
                    
                    self.info.text = "Cart Empty"
                    self.info.isHidden = false
                    self.contentIcon.isHidden = false
                    if self.showSpinner
                    {
                        activityIndicatorView.stopAnimating()
                    }
                    self.refresher.endRefreshing()
                    self.ErrorStorearr.removeAllObjects()
                    self.cartDic.removeAllObjects()
                    self.storedic.removeAllObjects()
                    self.cartTableView.reloadData()
                    return
                }
            }
            
            // Send Server Request for Sign Up Form
            post(parameter, url: path, method: "\(method)") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    if self.showSpinner
                    {
                        activityIndicatorView.stopAnimating()
                        self.ErrorStorearr.removeAllObjects()
                        self.cartDic.removeAllObjects()
                        self.storedic.removeAllObjects()
                    }
                    else
                    {
                        self.refresher.endRefreshing()
                        self.ErrorStorearr.removeAllObjects()
                        self.cartDic.removeAllObjects()
                        self.storedic.removeAllObjects()
                    }
                    self.showSpinner = true
                    if msg
                    {

                        if let dic = succeeded["body"] as? NSMutableDictionary
                        {
 
                            self.cartDic = dic
                            if let dic = self.cartDic["stores"] as? NSMutableDictionary
                            {
                                self.storedic = dic
                            }
                            if let StrCurrency = self.cartDic["currency"] as? String
                            {
                                self.CurrencySymbol = getCurrencySymbol(StrCurrency)
                            }
                            if let directpayment = self.cartDic["directPayment"] as? Bool
                            {
                                self.directPayment = directpayment
                            }
                            
                            self.CreateFooter(dic: dic)
                            
                            
                        }
                        if self.cartDic.count == 0
                        {
                            self.info.isHidden = false
                            self.contentIcon.isHidden = false
                            let dic = NSMutableDictionary()
                            self.CreateFooter(dic: dic)
                        }
                        if self.iscomingFrom == "MYorders"
                        {
                           getCartCount()
                        }
                        self.cartTableView.reloadData()
                        
                        
                    }
                    else
                    {
                        if succeeded["message"] != nil
                        {
                            self.cartTableView.reloadData()
                            if self.cartDic.count == 0
                            {
                                self.info.text = "\(succeeded["message"]!)"
                                self.info.isHidden = false
                                self.contentIcon.isHidden = false
                            }
                        }
                    }
                })
            }
        }
        else
        {
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self)
        }
    }
    
    // MARK: TextFeild Delegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        
        self.cartTableView.contentOffset.y = self.cartTableView.contentOffset.y+90
        return true;
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        self.cartTableView.contentOffset.y = self.cartTableView.contentOffset.y-90
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        StrcoupanCode = textField.text!
    }
    
    //MARK: Pull to Request Action
    @objc func refresh()
    {
        
        if Reachabable.isConnectedToNetwork()
        {
            self.Errordic.removeAll()
            showSpinner = false
            hideUpdatecartButton()
            browseCart()
        }
        else
        {
            // No Internet Connection Message
            refresher.endRefreshing()
            showToast(message: network_status_msg, controller: self)
        }
        
        
    }
    // MARK: Action Method
    @objc func updateCartAction(sender: UIButton)
    {
        if logoutUser == true
        {
            hideUpdatecartButton()
            GetrecartData()
            getCartCount()
            browseCart()
        }
        else
        {
            if Reachabable.isConnectedToNetwork()
            {
//                spinner.center = view.center
//                spinner.hidesWhenStopped = true
//                spinner.style = UIstyle.gray
//                view.addSubview(spinner)
                self.view.addSubview(activityIndicatorView)
                activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
                
                hideUpdatecartButton()
                
                ErrorStorearr.removeAllObjects()
                var parameter = [String:String]()
                var path = ""
                parameter = ["":""]

                //Set Parameters & path for quantity update
                var quantity:String = ""
                var productId:String = ""
                for(key,value) in quantityDic
                {
                    if quantity != ""
                    {
                        quantity += ","+"\(value)"
                    }
                    else
                    {
                        quantity = "\(value)"
                    }
                    
                    if productId != ""
                    {
                        productId += ","+"\(key)"
                    }
                    else
                    {
                        productId = "\(key)"
                    }
                    
                }
                parameter["cartproduct_id"] = "\(productId)"
                parameter["quantity"] = "\(quantity)"
                path = "sitestore/cart/update-quantity"
                // Send Server Request for Sign Up Form
                post(parameter, url: path, method: "POST") { (succeeded, msg) -> () in
                    DispatchQueue.main.async(execute: {
                        activityIndicatorView.stopAnimating()
                        if msg{
                            // On Success Add Value to Form Array & Values to formValue Array
                            if succeeded["message"] != nil
                            {
                                showToast(message: succeeded["message"] as! String, controller: self)
                                
                            }
                            self.Errordic.removeAll()
                            if logoutUser == false
                            {
                                self.browseCart()
                            }
                            else
                            {
                                if let dic = succeeded["body"] as? NSMutableDictionary
                                {
                                    
                                    self.cartDic = dic
                                    if let dic = self.cartDic["stores"] as? NSMutableDictionary
                                    {
                                        self.storedic = dic
                                    }
                                    if let StrCurrency = self.cartDic["currency"] as? String
                                    {
                                        self.CurrencySymbol = getCurrencySymbol(StrCurrency)
                                    }
                                    self.cartTableView.reloadData()
                                    self.CreateFooter(dic: dic)
                                    self.UpdateCoreData()

                                    
                                }
                            }
                            
                            getCartCount()
                            
                        }
                        else
                        {
                            if logoutUser == false
                            {
                                if validation.count > 0
                                {
                                    self.Errordic = validation as! [String : String]
                                }
                                else
                                {
                                    showToast(message: succeeded["message"] as! String, controller: self)
                                }
                                
                                //self.browseCart()
                                self.cartTableView.reloadData()
                                
                            }
                            else
                            {
                                if let dic = succeeded["body"] as? NSMutableDictionary
                                {
                                    self.Errordic.removeAll()
                                    self.cartDic = dic
                                    if let dic = self.cartDic["stores"] as? NSMutableDictionary
                                    {
                                        self.storedic = dic
                                    }
                                    if let StrCurrency = self.cartDic["currency"] as? String
                                    {
                                        self.CurrencySymbol = getCurrencySymbol(StrCurrency)
                                    }
                                    
                                    self.cartTableView.reloadData()
                                    self.CreateFooter(dic: dic)
                                    
                                }
                            }
                            
                            
                        }
                    })
                }
            }
        }

    }
    @objc func plusAction(sender: UIButton)
    {
        let position: CGPoint = sender.convert(CGPoint.zero, to: self.cartTableView)
        if let indexPath = self.cartTableView.indexPathForRow(at: position)
        {
            let section = indexPath.section
            let row = indexPath.row
            let arr = self.storedic.allKeys
            let index = arr[section]
            let storedic = self.storedic["\(index)"] as! NSMutableDictionary
            if let productarr = storedic["products"] as? NSMutableArray
            {
                let dic = productarr[indexPath.row] as! NSMutableDictionary
                if logoutUser == false
                {
                    if var quantity = dic["quantity"] as? Int
                    {
                        quantity = quantity+1
                        dic["quantity"] = quantity
                        productarr[row] = dic
                        storedic["products"] = productarr
                        self.storedic["\(index)"] =  storedic
                        DispatchQueue.main.async {
                            
                            let offset = self.cartTableView.contentOffset
                            self.cartTableView.reloadData()
                            self.cartTableView.layoutIfNeeded()
                            self.cartTableView.setContentOffset(offset, animated: false)
                            self.showUpdatecartButton()
                            
                        }
                    }
                }
                else
                {
                    
                    let product_id = dic["product_id"] as? Int
                    let product_type = dic["product_type"] as? String
                    if let configdic = dic["configFields"] as? NSDictionary
                    {
                        if var quantity = dic["quantity"] as? Int
                        {
                            quantity = quantity+1
                            dic["quantity"] = quantity
                            productarr[row] = dic
                            storedic["products"] = productarr
                            self.storedic["\(index)"] =  storedic
                            DispatchQueue.main.async
                                {
                                    
                                    let offset = self.cartTableView.contentOffset
                                    self.cartTableView.reloadData()
                                    self.cartTableView.layoutIfNeeded()
                                    self.cartTableView.setContentOffset(offset, animated: false)
                                    self.showUpdatecartButton()
                                    
                            }
                            UpdateQuantityofCoreDataWithConfig(product_type: product_type!, configdic: configdic, product_id: product_id!,quantity:quantity)
                        }
                       
                    }
                    else
                    {
                        if var quantity = dic["quantity"] as? Int
                        {
                            quantity = quantity+1
                            dic["quantity"] = quantity
                            productarr[row] = dic
                            storedic["products"] = productarr
                            self.storedic["\(index)"] =  storedic
                            DispatchQueue.main.async
                                {
                                    
                                    let offset = self.cartTableView.contentOffset
                                    self.cartTableView.reloadData()
                                    self.cartTableView.layoutIfNeeded()
                                    self.cartTableView.setContentOffset(offset, animated: false)
                                    self.showUpdatecartButton()
                                    
                            }
                            let configdic = NSDictionary()
                            UpdateQuantityofCoreData(product_type: product_type!, configdic: configdic, product_id: product_id!,quantity: quantity)
                        }

                    }


                }
            }
            
        }
        
    }
    func showUpdatecartButton()
    {
        UIView.animate(withDuration:0.35) { () -> Void in
            self.btnUpdateCart.frame.origin.y = UIScreen.main.bounds.height-(tabBarHeight + 50)
            self.cartTableView.frame.size.height = self.view.bounds.height - (tabBarHeight+50)
        }

    }
    func hideUpdatecartButton()
    {
        UIView.animate(withDuration:0.35) { () -> Void in
            self.btnUpdateCart.frame.origin.y = UIScreen.main.bounds.height
            self.cartTableView.frame.size.height = self.view.bounds.height - tabBarHeight
        }

    }
    @objc func minusAction(sender: UIButton)
    {
        let position: CGPoint = sender.convert(CGPoint.zero, to: self.cartTableView)
        if let indexPath = self.cartTableView.indexPathForRow(at: position)
        {
            let section = indexPath.section
            let row = indexPath.row
            let arr = self.storedic.allKeys
            let index = arr[section]
            let storedic = self.storedic["\(index)"] as! NSMutableDictionary
            if let productarr = storedic["products"] as? NSMutableArray
            {
                let dic = productarr[indexPath.row] as! NSMutableDictionary
                if logoutUser == false
                {
                    if var quantity = dic["quantity"] as? Int
                    {
                        if (quantity>0)
                        {
                            quantity = quantity-1
                            dic["quantity"] = quantity
                            productarr[row] = dic
                            storedic["products"] = productarr
                            self.storedic["\(index)"] =  storedic
                            DispatchQueue.main.async {
                                
                                let offset = self.cartTableView.contentOffset
                                self.cartTableView.reloadData()
                                self.cartTableView.layoutIfNeeded()
                                self.cartTableView.setContentOffset(offset, animated: false)
                                self.showUpdatecartButton()
                                
                            }
                            
                        }
                        
                        
                    }
                }
                else
                {
                    let product_id = dic["product_id"] as? Int
                    let product_type = dic["product_type"] as? String
                    if let configdic = dic["configFields"] as? NSDictionary
                    {
                        if var quantity = dic["quantity"] as? Int
                        {
                            if (quantity>0)
                            {
                                quantity = quantity-1
                                dic["quantity"] = quantity
                                productarr[row] = dic
                                storedic["products"] = productarr
                                self.storedic["\(index)"] =  storedic
                                UpdateQuantityofCoreDataWithConfig(product_type: product_type!, configdic: configdic, product_id: product_id!,quantity:quantity)
                                DispatchQueue.main.async {
                                    
                                    let offset = self.cartTableView.contentOffset
                                    self.cartTableView.reloadData()
                                    self.cartTableView.layoutIfNeeded()
                                    self.cartTableView.setContentOffset(offset, animated: false)
                                    self.showUpdatecartButton()
                                    
                                }
                            }
                        }
                        
                    }
                    else
                    {
                        if var quantity = dic["quantity"] as? Int
                        {
                            if (quantity>0)
                            {
                                quantity = quantity-1
                                dic["quantity"] = quantity
                                productarr[row] = dic
                                storedic["products"] = productarr
                                self.storedic["\(index)"] =  storedic
                                let configdic = NSDictionary()
                                UpdateQuantityofCoreData(product_type: product_type!, configdic: configdic, product_id: product_id!,quantity: quantity)
                                DispatchQueue.main.async {
                                    
                                    let offset = self.cartTableView.contentOffset
                                    self.cartTableView.reloadData()
                                    self.cartTableView.layoutIfNeeded()
                                    self.cartTableView.setContentOffset(offset, animated: false)
                                    self.showUpdatecartButton()
                                    
                                }
                            }
                        }

                    }


            }
            
        }
        
        }
    }
    
    @objc func ApplyCoupanAction(sender:UIButton)
    {
        self.view.endEditing(true)
        isapplycoupon = true
        if let _ = self.cartDic["canApplyCoupon"] as? Int
        {
            Store_id = ""
            couponDIC["coupon_code"] = "\(StrcoupanCode)"
        }
        else
        {
            let section = sender.tag
            let arr = self.storedic.allKeys
            let index = arr[section]
            Store_id = "\(index)"
            Store_id = "coupon_code_"+Store_id
            couponDIC[Store_id] = "\(StrcoupanCode)"
            
        }
        browseCart()
    }
    
    @objc func checkoutAction(sender:UIButton)
    {
        
        if logoutUser == false
        {
            if let _ = self.cartDic["canApplyCoupon"] as? Int
            {
                Store_id = ""
            }
            else
            {
                let section = sender.tag
                let arr = self.storedic.allKeys
                let index = arr[section]
                Store_id = "\(index)"
            }
            //For checkout
            let presentedVC = BillingAndShippingViewController()
            let nativationController = UINavigationController(rootViewController: presentedVC)
            nativationController.modalPresentationStyle = .fullScreen
            self.present(nativationController, animated:false, completion: nil)

            
        }
        else
        {
            if let _ = self.cartDic["canApplyCoupon"] as? Int
            {
                Store_id = ""
            }
            else
            {
                let section = sender.tag
                let arr = self.storedic.allKeys
                let index = arr[section]
                Store_id = "\(index)"
            }
          // Showing checkout with login or guestview
          showView()
            
        }
    }
    
    func DeleteAction(indexpath:NSIndexPath)
    {
        var product_id = Int()
        let section = indexpath.section
        let arr = self.storedic.allKeys
        let index = arr[section]
        let storedic = self.storedic["\(index)"] as! NSMutableDictionary
        if logoutUser == true
        {
            if let productarr = storedic["products"] as? NSMutableArray
            {
                let dic = productarr[indexpath.row] as! NSMutableDictionary
                product_id = dic["product_id"] as! Int
                
            }
            DeleteFromCoreData(index:product_id)
            return
            
        }
        if Reachabable.isConnectedToNetwork()
        {
//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            
            if let productarr = storedic["products"] as? NSMutableArray
            {
                let dic = productarr[indexpath.row] as! NSMutableDictionary
                product_id = dic["cartproduct_id"] as! Int
                
            }
            
            //Set Parameters & path for Sign Up Form
            var parameter = [String:String]()
            var path = ""
            parameter = ["":""]
            // parameter["cartproduct_id"] = "\(product_id)"
            path = "sitestore/cart/delete-product/\(product_id)"
            
            // Send Server Request for Sign Up Form
            post(parameter, url: path, method: "DELETE") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        if succeeded["message"] != nil
                        {
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                        }
                        self.browseCart()
                        getCartCount()
                        
                    }
                    else
                    {
                        if succeeded["message"] != nil
                        {
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                    }
                })
            }
        }
    }
    
    @objc func loginAction(sender:UIButton)
    {
        hideView()
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
        //self.loginguestCheckoutView()
        
        
    }
    func CreateFooter(dic:NSDictionary)
    {
        if dic.count > 0
        {
            if let coupancode = dic["canApplyCoupon"] as? Int
            {
                let tableViewFooter = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 50))
                
                
                let txtcoupan = createTextField(CGRect(x:10, y:10, width:100, height:30), borderColor: borderColorClear , placeHolderText: "Enter code", corner: true)
                txtcoupan.font =  UIFont(name: fontName, size: FONTSIZESmall)
                txtcoupan.backgroundColor = tableViewBgColor
                txtcoupan.layer.masksToBounds = true
                txtcoupan.delegate = self
                tableViewFooter.addSubview(txtcoupan)
                
                let btnApplycoupan =  createButton(CGRect(x:txtcoupan.frame.size.width+txtcoupan.frame.origin.x+10,y:10, width:100, height:30), title: "Apply Coupon", border: false,bgColor: false, textColor: textColorLight)
                btnApplycoupan.backgroundColor =  navColor
                btnApplycoupan.layer.cornerRadius = 2.0
                btnApplycoupan.layer.borderWidth = 1
                btnApplycoupan.layer.borderColor = textColorLight.cgColor
                btnApplycoupan.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZESmall)
                btnApplycoupan.setTitleColor(textColorDark, for: .highlighted)
                btnApplycoupan.addTarget(self, action: #selector(ManageCartViewController.ApplyCoupanAction), for: .touchUpInside)
                btnApplycoupan.isUserInteractionEnabled = true
                tableViewFooter.addSubview(btnApplycoupan)
                
                var footerY = btnApplycoupan.frame.size.height+btnApplycoupan.frame.origin.y+10
                if coupancode == 0
                {
                    btnApplycoupan.isUserInteractionEnabled = false
                }
                if let error = dic["couponerror"] as? String
                {
                    let errorLabel = createLabel(CGRect(x:10,y:btnApplycoupan.frame.size.height+btnApplycoupan.frame.origin.y+5,width:self.view.bounds.size.width-20,height:12), text: "", alignment: .left, textColor: UIColor.red)
                    errorLabel.numberOfLines = 0
                    errorLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
                    errorLabel.font = UIFont(name: fontName, size: FONTSIZESmall)
                    errorLabel.text = "\(error)"
                    tableViewFooter.addSubview(errorLabel)
                    errorLabel.sizeToFit()
                    footerY = errorLabel.frame.size.height+errorLabel.frame.origin.y+10
                    
                    let couponkey = "coupon_code"
                    couponDIC.removeValue(forKey:couponkey)
                    
                    
                }
                
                let paymentSummaryLabel = createLabel(CGRect(x:10,y:footerY,width:self.view.bounds.size.width-20,height:15), text: "", alignment: .left, textColor: textColorDark)
                paymentSummaryLabel.numberOfLines = 0
                paymentSummaryLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
                paymentSummaryLabel.font = UIFont(name: fontName, size: FONTSIZENormal)
                paymentSummaryLabel.text = NSLocalizedString("Payment Summary", comment: "")
                tableViewFooter.addSubview(paymentSummaryLabel)
                
                var i = paymentSummaryLabel.frame.size.height+paymentSummaryLabel.frame.origin.y+10
                if let profileField = dic["totalAmountFields"] as? NSMutableDictionary
                {
                    
                    // Showing store subtotal
                    for (k,v) in profileField
                    {
                        
                        let profileFieldLabel = createLabel(CGRect(x:10,y:i,width:self.view.bounds.size.width-120,height:15), text: "", alignment: .left, textColor: textColorMedium)
                        profileFieldLabel.numberOfLines = 0
                        profileFieldLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
                        profileFieldLabel.textColor = textColorMedium
                        profileFieldLabel.layer.borderColor = navColor.cgColor
                        profileFieldLabel.font = UIFont(name: fontName, size: FONTSIZENormal)
                        profileFieldLabel.text = "\(k)"
                        tableViewFooter.addSubview(profileFieldLabel)
                        
                        let profileFieldvalueLabel = createLabel(CGRect(x:self.view.bounds.size.width-110,y:i,width:100,height:15), text: "", alignment: .left, textColor: textColorDark)
                        profileFieldvalueLabel.numberOfLines = 0
                        profileFieldvalueLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
                        profileFieldvalueLabel.textColor = textColorDark
                        profileFieldvalueLabel.font = UIFont(name: fontBold, size: FONTSIZENormal)
                        profileFieldvalueLabel.layer.borderColor = navColor.cgColor
                        profileFieldvalueLabel.textAlignment = NSTextAlignment.right
                        var value = gettwoFractionDigits(FractionDigit:"\(v)")
                        value = "\(self.CurrencySymbol)"+"\(value)"
                        
                        if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
                            let defaults = UserDefaults.standard
                            if let name = defaults.object(forKey: "Currency")
                            {
                                let price = gettwoFractionDigits(FractionDigit: "\(v)")
                                let changePrice = (defaults.object(forKey: "PriceRate") as! Float) * Float(price)!
                                let showPrice = (String(format:"%.2f", changePrice))
                                
                                profileFieldvalueLabel.text =  "\(getCurrencySymbol(name as! String)) \(showPrice)"
                                
                            }
                        }
                        else{
                            profileFieldvalueLabel.text = value
                        }
                        
                       // profileFieldvalueLabel.text = value
                        tableViewFooter.addSubview(profileFieldvalueLabel)
                        
                        i = i+25
                        
                        
                    }
                    
                    // Showing VAT if applied
                    if let vatField = dic["totalVatFields"] as? NSMutableDictionary
                    {
                        // Showing store subtotal
                        for (k,v) in vatField
                        {
                            
                            let vatFieldLabel = createLabel(CGRect(x:10,y:i,width:self.view.bounds.size.width-120,height:15), text: "", alignment: .left, textColor: textColorMedium)
                            vatFieldLabel.numberOfLines = 0
                            vatFieldLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
                            vatFieldLabel.textColor = textColorMedium
                            vatFieldLabel.layer.borderColor = navColor.cgColor
                            vatFieldLabel.font = UIFont(name: fontName, size: FONTSIZENormal)
                            vatFieldLabel.text = "\(k)"
                            tableViewFooter.addSubview(vatFieldLabel)
                            
                            let vatFieldvalueLabel = createLabel(CGRect(x:self.view.bounds.size.width-110,y:i,width:100,height:15), text: "", alignment: .left, textColor: textColorDark)
                            vatFieldvalueLabel.numberOfLines = 0
                            vatFieldvalueLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
                            vatFieldvalueLabel.textColor = textColorDark
                            vatFieldvalueLabel.font = UIFont(name: fontBold, size: FONTSIZENormal)
                            vatFieldvalueLabel.layer.borderColor = navColor.cgColor
                            vatFieldvalueLabel.textAlignment = NSTextAlignment.right
                            var value = gettwoFractionDigits(FractionDigit:"\(v)")
                            value = "\(self.CurrencySymbol)"+"\(value)"
                            if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
                                let defaults = UserDefaults.standard
                                if let name = defaults.object(forKey: "Currency")
                                {
                                    let price = gettwoFractionDigits(FractionDigit: "\(v)")
                                    let changePrice = (defaults.object(forKey: "PriceRate") as! Float) * Float(price)!
                                    let showPrice = (String(format:"%.2f", changePrice))
                                    
                                    vatFieldvalueLabel.text =  "\(getCurrencySymbol(name as! String)) \(showPrice)"
                                    
                                }
                            }
                            else{
                                vatFieldvalueLabel.text = value
                            }
                           // vatFieldvalueLabel.text = value
                            tableViewFooter.addSubview(vatFieldvalueLabel)
                            
                            i = i+25
                            
                            
                        }
                    }
                    // Showing coupon discount
                    if let couponDic =  dic["coupon"] as? NSDictionary
                    {
                        let couponcode = couponDic["coupon_code"]
                        let coupanvalue = gettwoFractionDigits(FractionDigit:"\(couponDic["value"] as! Double)")
                        
                        
                        let couponLabel = createLabel(CGRect(x:10,y:i,width:self.view.bounds.size.width-120,height:15), text: "", alignment: .left, textColor: textColorMedium)
                        couponLabel.numberOfLines = 0
                        couponLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
                        couponLabel.textColor = textColorMedium
                        couponLabel.layer.borderColor = navColor.cgColor
                        couponLabel.font = UIFont(name: fontName, size: FONTSIZENormal)
                        couponLabel.text = "\(couponcode!)"
                        tableViewFooter.addSubview(couponLabel)
                        
                        let couponvalueLabel = createLabel(CGRect(x:self.view.bounds.size.width-110,y:i,width:100,height:15), text: "", alignment: .left, textColor: textColorDark)
                        couponvalueLabel.numberOfLines = 0
                        couponvalueLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
                        couponvalueLabel.textColor = textColorDark
                        couponvalueLabel.font = UIFont(name: fontBold, size: FONTSIZENormal)
                        couponvalueLabel.layer.borderColor = navColor.cgColor
                        couponvalueLabel.textAlignment = NSTextAlignment.right
                        var value = gettwoFractionDigits(FractionDigit:"\(coupanvalue)")
                        value = "-"+"\(self.CurrencySymbol)"+"\(value)"
                        if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
                            let defaults = UserDefaults.standard
                            if let name = defaults.object(forKey: "Currency")
                            {
                                let price = gettwoFractionDigits(FractionDigit: "\(coupanvalue)")
                                let changePrice = (defaults.object(forKey: "PriceRate") as! Float) * Float(price)!
                                let showPrice = (String(format:"%.2f", changePrice))
                                
                                couponvalueLabel.text =  "\(getCurrencySymbol(name as! String)) \(showPrice)"
                                
                            }
                        }
                        else{
                            couponvalueLabel.text = value
                        }
                       // couponvalueLabel.text = value
                        tableViewFooter.addSubview(couponvalueLabel)
                        i = couponvalueLabel.frame.size.height+couponvalueLabel.frame.origin.y+10
                        
                        
                    }
                    // Showing grand total
                    if let grandtotal =  dic["grandTotal"] as? Double
                    {
                        
                        let grandtotalLabel = createLabel(CGRect(x:10,y:i,width:self.view.bounds.size.width-120,height:15), text: "", alignment: .left, textColor: textColorMedium)
                        grandtotalLabel.numberOfLines = 0
                        grandtotalLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
                        grandtotalLabel.textColor = textColorMedium
                        grandtotalLabel.layer.borderColor = navColor.cgColor
                        grandtotalLabel.font = UIFont(name: fontName, size: FONTSIZENormal)
                        grandtotalLabel.text = NSLocalizedString("Grand Total", comment: "")
                        tableViewFooter.addSubview(grandtotalLabel)
                        
                        let grandtotalvalueLabel = createLabel(CGRect(x:self.view.bounds.size.width-110,y:i,width:100,height:15), text: "", alignment: .left, textColor: textColorDark)
                        grandtotalvalueLabel.numberOfLines = 0
                        grandtotalvalueLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
                        grandtotalvalueLabel.textColor = textColorDark
                        grandtotalvalueLabel.font = UIFont(name: fontBold, size: FONTSIZENormal)
                        grandtotalvalueLabel.layer.borderColor = navColor.cgColor
                        grandtotalvalueLabel.textAlignment = NSTextAlignment.right
                        var value = gettwoFractionDigits(FractionDigit:"\(grandtotal)")
                        value = "\(self.CurrencySymbol)"+"\(value)"
                        
                        if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
                            let defaults = UserDefaults.standard
                            if let name = defaults.object(forKey: "Currency")
                            {
                                let price = gettwoFractionDigits(FractionDigit: "\(grandtotal)")
                                let changePrice = (defaults.object(forKey: "PriceRate") as! Float) * Float(price)!
                                let showPrice = (String(format:"%.2f", changePrice))
                                
                                grandtotalvalueLabel.text =  "\(getCurrencySymbol(name as! String)) \(showPrice)"
                                
                            }
                        }
                        else{
                            grandtotalvalueLabel.text = value
                        }
                        
                       // grandtotalvalueLabel.text = value
                        tableViewFooter.addSubview(grandtotalvalueLabel)
                        i = grandtotalvalueLabel.frame.size.height+grandtotalvalueLabel.frame.origin.y+10
                        
                        
                    }
                    
                    let btnCheckout =  createButton(CGRect(x:self.view.bounds.size.width-110,y:i, width:100, height:35), title: "Checkout", border: false,bgColor: false, textColor: textColorLight)
                    btnCheckout.backgroundColor =  navColor
                    btnCheckout.layer.cornerRadius = 2.0
                    btnCheckout.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZESmall)
                    btnCheckout.setTitleColor(textColorDark, for: .highlighted)
                    btnCheckout.addTarget(self, action: #selector(ManageCartViewController.checkoutAction), for: .touchUpInside)
                    btnCheckout.alpha = 1.0
                    btnCheckout.isUserInteractionEnabled = true
                    tableViewFooter.addSubview(btnCheckout)
                    
                    if ErrorStorearr.count>0
                    {
                        btnCheckout.isUserInteractionEnabled = false
                        btnCheckout.alpha = 0.5
                    }
                    tableViewFooter.frame = CGRect(x:0, y:0, width:self.view.bounds.size.width, height:btnCheckout.frame.size.height+btnCheckout.frame.origin.y+10)
                    tableViewFooter.backgroundColor = UIColor.white//tableViewBgColor//UIColor.white
                    self.cartTableView.tableFooterView  = tableViewFooter
                }
                
            }
        }
        else
        {
            let tableViewFooter = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            self.cartTableView.tableFooterView = tableViewFooter
        }
    }
    
    // Get record from core data into array
    func GetrecartData()
    {
        let results = GetallRecord()
        Cartarr.removeAllObjects()
        if results.count>0
        {
            for result: Any in results
            {
                let data = (result as AnyObject).value(forKey: "added_products")
                let output = NSKeyedUnarchiver.unarchiveObject(with: data as! Data)
                if let dict = output as? NSDictionary
                {
                    Cartarr.add(dict)
                    
                }
                
            }
            //print(Cartarr)
            
        }
        else
        {
            Cartarr.removeAllObjects()
            let dic = NSMutableDictionary()
            self.CreateFooter(dic: dic)
        }
    }

    // View for choosing checkout with login or guest
    func loginguestCheckoutView()
    {
        loginORguestView = CouponDetailView(frame:CGRect(x:10, y:view.bounds.height, width:view.bounds.width - 20, height:160))
        loginORguestView.couponImage.image = nil
        
        loginORguestView.doneButton.addTarget(self, action: #selector(ManageCartViewController.hideView), for: UIControl.Event.touchUpInside)
        loginORguestView.couponImage.isHidden = true
        loginORguestView.couponLabel.isHidden = true
        loginORguestView.couponStartDateLabel.isHidden = true
        loginORguestView.couponEndDateLabel.isHidden = true
        loginORguestView.couponStartDate.isHidden = true
        loginORguestView.couponEndDate.isHidden = true
        loginORguestView.couponCode.isHidden = true
        loginORguestView.couponDiscount.isHidden = true
        loginORguestView.couponDescription.isHidden = true
        loginORguestView.couponUsageLimit.isHidden = true
        
//        var lbltitle:UILabel!
//        lbltitle = createLabel(CGRect(x:10, 0, UIScreen.main.bounds.width-40, 30), text: NSLocalizedString("Account Details", comment: ""), alignment: NSTextAlignment.center, textColor: textColorDark)
//        lbltitle.font = UIFont(name: fontName, size:FONTSIZELarge)
//        lbltitle.backgroundColor = UIColor.clear
//        loginORguestView.addSubview(lbltitle)
        
        
        btnGuest = createButton(CGRect(x:50,y:20, width:UIScreen.main.bounds.width-120 , height:35), title: "Checkout as a Guest", border: false, bgColor: false, textColor: textColorLight)
        btnGuest.titleLabel?.font =  UIFont(name: fontName, size:FONTSIZELarge)
        btnGuest.layer.cornerRadius = 2
        btnGuest.backgroundColor = navColor
        btnGuest.addTarget(self, action: #selector(ManageCartViewController.btnGuestAction), for: .touchUpInside)
        loginORguestView.addSubview(btnGuest)
        
        var lblOR:UILabel!
        lblOR = createLabel(CGRect(x:10, y:btnGuest.frame.size.height+btnGuest.frame.origin.y+10, width:UIScreen.main.bounds.width-40, height:20), text: NSLocalizedString("Or", comment: ""), alignment: NSTextAlignment.center, textColor: textColorDark)
        lblOR.font = UIFont(name: fontName, size:FONTSIZELarge)
        lblOR.backgroundColor = UIColor.clear
        loginORguestView.addSubview(lblOR)
        
        
        btnLogin = createButton(CGRect(x:50,y:lblOR.frame.size.height+lblOR.frame.origin.y+10,width: UIScreen.main.bounds.width-120 , height:35), title: "Login", border: false, bgColor: false, textColor: textColorLight)
        btnLogin.titleLabel?.font =  UIFont(name: fontName, size:FONTSIZELarge)
        btnLogin.layer.cornerRadius = 2
        btnLogin.backgroundColor = navColor
        btnLogin.addTarget(self, action: #selector(ManageCartViewController.loginAction), for: .touchUpInside)
        loginORguestView.addSubview(btnLogin)
        

        
        view.addSubview(loginORguestView)
    }
    @objc func hideView(){
        UIView.animate(withDuration:0.35) { () -> Void in
            self.loginORguestView.frame.origin.y = self.view.bounds.height
            self.blackScreen.alpha = 0.0
            self.view.endEditing(true)
        }
        

    }
    func showView()
    {
  
        UIView.animate(withDuration:0.5) { () -> Void in
            self.loginORguestView.frame.origin.y = self.view.bounds.height/2-(2*TOPPADING)
            self.blackScreen.alpha = 0.3
            self.view.endEditing(true)
        }
    }
    @objc func btnGuestAction(sender:UIButton)
    {
        hideView()
        //For checkout
        let presentedVC = BillingAndShippingViewController()
        presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        let nativationController = UINavigationController(rootViewController: presentedVC)
        self.present(nativationController, animated:false, completion: nil)

    }
    // Update core data
    func UpdateCoreData()
    {
        var updatedDicToBeAdded = Dictionary<String, AnyObject>()
        let results = GetallRecord()
        if results.count>0
        {
            for result:Any in results
            {
                
                let data = (result as AnyObject).value(forKey: "added_products")
                let output = NSKeyedUnarchiver.unarchiveObject(with: data as! Data)
                if let dict = output as? NSDictionary
                {
                    let p_id = dict["product_id"] as! Int
                    let strquantity = logoutquantityDic["\(p_id)"]
                    let quantity = Int(strquantity!)
                    if quantity != 0
                    {
                        updatedDicToBeAdded = dict as! Dictionary<String, AnyObject>
                        updatedDicToBeAdded["quantity"] = "\(quantity!)" as AnyObject?
                        (result as AnyObject).setValue(NSKeyedArchiver.archivedData(withRootObject: updatedDicToBeAdded), forKey: "added_products")
                        do
                        {
                            try context.save()
                        }
                        catch _
                        {
                        }
                        
                    }
                    
                }
                
            }
            Cartarr.removeAllObjects()
            GetrecartData()
            
        }
        
    }
    // Delete core data
    func DeleteFromCoreData(index:Int)
    {
        let results = GetallRecord()
        if results.count>0
        {
            for i in 0 ..< results.count
            {
                let result = results[i]
                let data = (result as AnyObject).value(forKey: "added_products")
                let output = NSKeyedUnarchiver.unarchiveObject(with: data as! Data)
                if let dict = output as? NSDictionary
                {
                    let p_id = dict["product_id"] as! Int
                    if p_id == index
                    {
                        context.delete(result as! NSManagedObject)
                        do
                        {
                            try context.save()
                            Cartarr.removeAllObjects()
                            getCartCount()
                            GetrecartData()
                            browseCart()
                        }
                        catch _
                        {
                        }
                    }
                }
            }
            
            
        }
    }
    func UpdateQuantityofCoreDataWithConfig(product_type:String,configdic:NSDictionary,product_id:Int, quantity:Int)
    {
        let results = GetallRecord()
        if(results.count>0){
        
            for result: Any in results{
                let data = (result as AnyObject).value(forKey: "added_products")
                let output = NSKeyedUnarchiver.unarchiveObject(with: data as! Data)
                if let dict = output as? NSDictionary
                {
                    let productid = dict["product_id"] as? Int
                    
                    let configCoreData = dict["configFields"] as? NSDictionary
                    //print(configCoreData!)
                    //print(configdic)

                    if product_type == "configurable" && product_id == productid!
                    {
                        if configCoreData! == configdic
                        {
                            
                            if quantity != 0
                            {
                                var updatedDicToBeAdded = dict as! Dictionary<String, AnyObject>
                                updatedDicToBeAdded["quantity"] = quantity as AnyObject?
                                (result as AnyObject).setValue(NSKeyedArchiver.archivedData(withRootObject: updatedDicToBeAdded), forKey: "added_products")
                                do
                                {
                                    try context.save()
                                }
                                catch _
                                {
                                }
                                
                            }
                            
                        }
                    }
  
                }
                
            }
            
            
        }
    }
    func UpdateQuantityofCoreData(product_type:String,configdic:NSDictionary,product_id:Int,quantity:Int)
    {
        let results = GetallRecord()
        if(results.count>0){
            
            for result: Any in results
            {
                let data = (result as AnyObject).value(forKey: "added_products")
                let output = NSKeyedUnarchiver.unarchiveObject(with: data as! Data)
                if let dict = output as? NSDictionary
                {
                    let productid = dict["product_id"] as? Int
                    if product_id == productid
                    {
                        
                        if quantity != 0
                        {
                            var updatedDicToBeAdded = dict as! Dictionary<String, AnyObject>
                            updatedDicToBeAdded["quantity"] = quantity as AnyObject?
                            (result as AnyObject).setValue(NSKeyedArchiver.archivedData(withRootObject: updatedDicToBeAdded), forKey: "added_products")
                            do
                            {
                                try context.save()
                            }
                            catch _
                            {
                            }
                        }
                        
                    }
                }
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
