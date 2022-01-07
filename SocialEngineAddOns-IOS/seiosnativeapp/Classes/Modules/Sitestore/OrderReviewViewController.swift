//
//  OrderReviewViewController.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 12/08/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit
import CoreData
class OrderReviewViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextViewDelegate {
    
    var popAfterDelay:Bool!
    var orderReviewTableView:UITableView!
    var index = Int()
    var orderDic = NSDictionary()
    var storedic = NSMutableDictionary()
    var dynamicHeight:CGFloat = 70
    var footerHeight:CGFloat = 0.0001
    var headerHeight:CGFloat = 40
    var activeField: UITextView?
    var offset:CGPoint!
    var orderNotedic = [String:String]()
    var CurrencySymbol = String()
    var placeorderView = UIView()
    var btnPlaceOrder:UIButton!
    var iscomingFrom = String()
    var url = String()
    var headerView = UIView()
    var logoutCartarr = NSMutableArray()
    var orderId = String()
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if logoutUser == true
        {
            //Getting Record from Core data
            GetrecartData()
            
        }
        orderReviewTableView = UITableView(frame: CGRect(x:0, y:0, width:view.bounds.width, height:view.bounds.height-50), style:.grouped)
        orderReviewTableView.register(OrderReviewTableViewCell.self, forCellReuseIdentifier: "CellThree")
        orderReviewTableView.estimatedRowHeight = 70
        orderReviewTableView.rowHeight = UITableView.automaticDimension
        orderReviewTableView.isOpaque = false
        orderReviewTableView.backgroundColor = tableViewBgColor//UIColor.white//tableViewBgColor
        orderReviewTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        // cartTableView.estimatedSectionFooterHeight = 120
        self.orderReviewTableView.dataSource = self
        self.orderReviewTableView.delegate = self
        self.view.addSubview(orderReviewTableView)
        
        
        
        placeorderView = createView( CGRect(x:0,y:UIScreen.main.bounds.height-50 , width:UIScreen.main.bounds.width , height:50), borderColor: borderColorMedium, shadow: false)
        placeorderView.layer.shadowColor = shadowColor.cgColor
        placeorderView.layer.shadowOpacity = shadowOpacity
        placeorderView.layer.shadowRadius = shadowRadius
        placeorderView.layer.shadowOffset = shadowOffset
        placeorderView.layer.borderWidth = 1.0
        placeorderView.backgroundColor = UIColor.white
        self.view.addSubview(placeorderView)
        
        
        btnPlaceOrder = createButton(CGRect(x:20, y:8, width:UIScreen.main.bounds.width-40 , height:34), title:NSLocalizedString("Place Order",  comment: "") , border: false, bgColor: false, textColor: textColorLight)
        btnPlaceOrder.titleLabel?.font =  UIFont(name: fontName, size:FONTSIZELarge)
        btnPlaceOrder.layer.cornerRadius = 2
        btnPlaceOrder.layer.borderWidth = 1
        btnPlaceOrder.backgroundColor = navColor
        btnPlaceOrder.layer.borderColor = textColorMedium.cgColor
        btnPlaceOrder.addTarget(self, action: #selector(OrderReviewViewController.PlaceOrderAction), for: .touchUpInside)
        placeorderView.addSubview(btnPlaceOrder)
        
        
        isCreateOrEdit = true
        

        
        browseorderReview()
    }
    
    override func viewWillAppear(_ animated: Bool) {
    
        if manageCartUpdate == true
        {
            _ = self.dismiss(animated: false, completion: nil)
            return
        }
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(OrderReviewViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem

        
        popAfterDelay = false
        if iscomingFrom == "MYorders"
        {
            self.title = String(format: NSLocalizedString("Order Id: %@", comment: ""),orderId)
            placeorderView.isHidden = true
            orderReviewTableView.frame = CGRect(x:0, y:0, width:view.bounds.width, height:view.bounds.height)
        }
        else
        {
            self.title = NSLocalizedString("Order Review", comment: "")
            placeorderView.isHidden = false
            orderReviewTableView.frame = CGRect(x:0, y:0, width:view.bounds.width, height:view.bounds.height-50)

        }
        
    }
    // Stop Timer
    @objc func stopTimer()
    {
        stop()
        if popAfterDelay == true
        {
            self.dismiss(animated: true, completion: nil)
            
        }
    }
    @objc func goBack(){
         _ = self.navigationController?.popViewController(animated: false)
    }
    
    // MARK:  UITableViewDelegate & UITableViewDataSource
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        if iscomingFrom == "MYorders"
        {
          return headerView.frame.size.height+headerHeight
        }
        return headerHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let arr = self.storedic.allKeys
        if arr.count > 0
        {
            let index = arr[section]
            let dic = self.storedic["\(index)"] as! NSDictionary
            let storeName = dic["name"] as! String
            let tableViewHeader = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 40))
            var feildsY = CGFloat()
            feildsY = 0
            
            if iscomingFrom == "MYorders"
            {
                headerView = createView(CGRect(x:PADING, y:5,width:(UIScreen.main.bounds.width - 2*PADING) , height:30), borderColor: borderColorMedium, shadow: false)
                headerView.layer.shadowColor = shadowColor.cgColor
                headerView.layer.shadowOpacity = shadowOpacity
                headerView.layer.shadowRadius = shadowRadius
                headerView.layer.shadowOffset = shadowOffset
                tableViewHeader.addSubview(headerView)
                feildsY = 5.0
                if let  billing_address = self.orderDic["billing_address"] as? NSArray
                {
                    for i in 0 ..< billing_address.count
                    {
                        let value = billing_address[i]
                        let labTitle = createLabel(CGRect(x:10, y:feildsY,width:(headerView.bounds.width - 20) , height:20), text: " ", alignment: .left, textColor: textColorDark)
                        labTitle.numberOfLines = 0
                        labTitle.lineBreakMode = NSLineBreakMode.byTruncatingTail
                        if i == 0
                        {
                            labTitle.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                        }
                        else
                        {
                            labTitle.font = UIFont(name: fontName, size: FONTSIZEMedium)
                        }
                        labTitle.text = "\(value)"
                        headerView.addSubview(labTitle)
                        labTitle.sizeToFit()
                        feildsY = feildsY+labTitle.frame.size.height+10
                        
                    }
                    
                }
                if let  shipping_address = self.orderDic["shipping_address"] as? NSArray
                {
                    feildsY = feildsY+5
                    let lineView = UIView(frame: CGRect(x:0, y:feildsY,width:UIScreen.main.bounds.width, height:1))
                    lineView.backgroundColor = aafBgColor
                    headerView.addSubview(lineView)
                    feildsY = feildsY+10
                    for i in 0 ..< shipping_address.count
                    {
                        let value = shipping_address[i]
                        let labTitle = createLabel(CGRect(x:10, y:feildsY,width:(headerView.bounds.width - 20) , height:20), text: " ", alignment: .left, textColor: textColorDark)
                        labTitle.numberOfLines = 0
                        labTitle.lineBreakMode = NSLineBreakMode.byTruncatingTail
                        if i == 0
                        {
                            labTitle.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                        }
                        else
                        {
                            labTitle.font = UIFont(name: fontName, size: FONTSIZEMedium)
                        }
                        labTitle.text = "\(value)"
                        headerView.addSubview(labTitle)
                        labTitle.sizeToFit()
                        feildsY = feildsY+labTitle.frame.size.height+10
                        
                    }
                    
                }
                if let order = self.orderDic["order"] as? NSDictionary
                {
                    feildsY = feildsY+5
                    let lineView = UIView(frame: CGRect(x:0, y:feildsY,width:UIScreen.main.bounds.width, height:1))
                    lineView.backgroundColor = aafBgColor
                    headerView.addSubview(lineView)
                    feildsY = feildsY+10
                    if let label = order["label"] as? NSString
                    {
                        let labTitle = createLabel(CGRect(x:10,y:feildsY,width:self.headerView.bounds.size.width-120,height:15), text: "", alignment: .left, textColor: textColorDark)
                        labTitle.numberOfLines = 0
                        labTitle.lineBreakMode = NSLineBreakMode.byTruncatingTail
                        labTitle.textColor = textColorDark
                        labTitle.layer.borderColor = navColor.cgColor
                        labTitle.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                        labTitle.text = "\(label)"
                        headerView.addSubview(labTitle)
                        feildsY = feildsY+labTitle.frame.size.height+10
                    }
                    if let OrderDate = order["order_date"] as? NSString
                    {
                        let labTitle = createLabel(CGRect(x:10,y:feildsY,width:self.headerView.bounds.size.width/3,height:15), text: "", alignment: .left, textColor: textColorMedium)
                        labTitle.numberOfLines = 0
                        labTitle.lineBreakMode = NSLineBreakMode.byTruncatingTail
                        labTitle.textColor = textColorDark
                        labTitle.layer.borderColor = navColor.cgColor
                        labTitle.font = UIFont(name: fontName, size: FONTSIZENormal)
                        labTitle.text = NSLocalizedString("Order Date",  comment: "")
                        headerView.addSubview(labTitle)
                        
                        
                        let labTitlevalue = createLabel(CGRect(x:self.headerView.bounds.size.width/3+10, y:feildsY,width:((self.headerView.bounds.size.width/3)*2)-20 , height:20), text: " ", alignment: .left, textColor: textColorDark)
                        labTitlevalue.numberOfLines = 0
                        labTitlevalue.lineBreakMode = NSLineBreakMode.byTruncatingTail
                        labTitlevalue.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                        let date = dateDifferenceWithEventTime("\(OrderDate)")
                        var DateC = date.components(separatedBy: ",")
                        var tempInfo = "\(DateC[1]) \(DateC[0]) \(DateC[2])"
                        if DateC.count > 3{
                            tempInfo += " at \(DateC[3])"
                            labTitlevalue.text = "\(tempInfo)"
                        }
                        
                        labTitlevalue.textAlignment = NSTextAlignment.right
                        headerView.addSubview(labTitlevalue)
                        feildsY = feildsY+labTitlevalue.frame.size.height+10
                    }
                    if let OrderStatus = order["order_status"] as? NSString
                    {
                        let labTitle = createLabel(CGRect(x:10,y:feildsY,width:self.headerView.bounds.size.width/3,height:15), text: "", alignment: .left, textColor: textColorMedium)
                        labTitle.numberOfLines = 0
                        labTitle.lineBreakMode = NSLineBreakMode.byTruncatingTail
                        labTitle.textColor = textColorDark
                        labTitle.layer.borderColor = navColor.cgColor
                        labTitle.font = UIFont(name: fontName, size: FONTSIZENormal)
                        labTitle.text = NSLocalizedString("Order Status",  comment: "")
                        headerView.addSubview(labTitle)
                        
                        
                        let labTitlevalue = createLabel(CGRect(x:self.headerView.bounds.size.width/3+10, y:feildsY,width:((self.headerView.bounds.size.width/3)*2)-20 , height:20), text: " ", alignment: .left, textColor: textColorDark)
                        labTitlevalue.numberOfLines = 0
                        labTitlevalue.lineBreakMode = NSLineBreakMode.byTruncatingTail
                        labTitlevalue.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                        labTitlevalue.text = "\(OrderStatus)"
                        labTitlevalue.textAlignment = NSTextAlignment.right
                        headerView.addSubview(labTitlevalue)
                        feildsY = feildsY+labTitlevalue.frame.size.height+10
                    }
                    if let TaxAmount = order["tax_amount"] as? Int
                    {
                        let labTitle = createLabel(CGRect(x:10,y:feildsY,width:self.headerView.bounds.size.width/3,height:15), text: "", alignment: .left, textColor: textColorMedium)
                        labTitle.numberOfLines = 0
                        labTitle.lineBreakMode = NSLineBreakMode.byTruncatingTail
                        labTitle.textColor = textColorDark
                        labTitle.layer.borderColor = navColor.cgColor
                        labTitle.font = UIFont(name: fontName, size: FONTSIZENormal)
                        labTitle.text = NSLocalizedString("Tax Amount",  comment: "")
                        headerView.addSubview(labTitle)
                        
                        
                        let labTitlevalue = createLabel(CGRect(x:self.headerView.bounds.size.width/3+10, y:feildsY,width:((self.headerView.bounds.size.width/3)*2)-20 , height:20), text: " ", alignment: .left, textColor: textColorDark)
                        labTitlevalue.numberOfLines = 0
                        labTitlevalue.lineBreakMode = NSLineBreakMode.byTruncatingTail
                        labTitlevalue.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                        let value = "\(self.CurrencySymbol)"+"\(TaxAmount)"
                        labTitlevalue.text = "\(value)"
                        labTitlevalue.textAlignment = NSTextAlignment.right
                        headerView.addSubview(labTitlevalue)
                        feildsY = feildsY+labTitlevalue.frame.size.height+10
                    }
                    if let ShippingAmount = order["shipping_amount"] as? Int
                    {
                        let labTitle = createLabel(CGRect(x:10,y:feildsY,width:self.headerView.bounds.size.width/3,height:15), text: "", alignment: .left, textColor: textColorMedium)
                        labTitle.numberOfLines = 0
                        labTitle.lineBreakMode = NSLineBreakMode.byTruncatingTail
                        labTitle.textColor = textColorDark
                        labTitle.layer.borderColor = navColor.cgColor
                        labTitle.font = UIFont(name: fontName, size: FONTSIZENormal)
                        labTitle.text = NSLocalizedString("Shipping Amount",  comment: "")
                        headerView.addSubview(labTitle)
                        
                        
                        let labTitlevalue = createLabel(CGRect(x:self.headerView.bounds.size.width/3+10, y:feildsY,width:((self.headerView.bounds.size.width/3)*2)-20 , height:20), text: " ", alignment: .left, textColor: textColorDark)
                        labTitlevalue.numberOfLines = 0
                        labTitlevalue.lineBreakMode = NSLineBreakMode.byTruncatingTail
                        labTitlevalue.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                        let value = "\(self.CurrencySymbol)"+"\(ShippingAmount)"
                        labTitlevalue.text = "\(value)"
                        labTitlevalue.textAlignment = NSTextAlignment.right
                        headerView.addSubview(labTitlevalue)
                        feildsY = feildsY+labTitlevalue.frame.size.height+10
                    }
                    if let DeliveryTime = order["delivery_time"] as? String
                    {
                        let labTitle = createLabel(CGRect(x:10,y:feildsY,width:self.headerView.bounds.size.width/3,height:15), text: "", alignment: .left, textColor: textColorMedium)
                        labTitle.numberOfLines = 0
                        labTitle.lineBreakMode = NSLineBreakMode.byTruncatingTail
                        labTitle.textColor = textColorDark
                        labTitle.layer.borderColor = navColor.cgColor
                        labTitle.font = UIFont(name: fontName, size: FONTSIZENormal)
                        labTitle.text = NSLocalizedString("Delivery Time",  comment: "")
                        headerView.addSubview(labTitle)
                        
                        
                        let labTitlevalue = createLabel(CGRect(x:self.headerView.bounds.size.width/3+10, y:feildsY,width:((self.headerView.bounds.size.width/3)*2)-20 , height:20), text: " ", alignment: .left, textColor: textColorDark)
                        labTitlevalue.numberOfLines = 0
                        labTitlevalue.lineBreakMode = NSLineBreakMode.byTruncatingTail
                        labTitlevalue.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                        labTitlevalue.text = "\(DeliveryTime)"
                        headerView.addSubview(labTitlevalue)
                        labTitlevalue.textAlignment = NSTextAlignment.right
                        feildsY = feildsY+labTitlevalue.frame.size.height+10
                    }
                    if let IPAddress = order["ip_address"] as? String
                    {
                        let labTitle = createLabel(CGRect(x:10,y:feildsY,width:self.headerView.bounds.size.width/3,height:15), text: "", alignment: .left, textColor: textColorMedium)
                        labTitle.numberOfLines = 0
                        labTitle.lineBreakMode = NSLineBreakMode.byTruncatingTail
                        labTitle.textColor = textColorDark
                        labTitle.layer.borderColor = navColor.cgColor
                        labTitle.font = UIFont(name: fontName, size: FONTSIZENormal)
                        labTitle.text = NSLocalizedString("IP Address",  comment: "")
                        headerView.addSubview(labTitle)
                        
                        
                        let labTitlevalue = createLabel(CGRect(x:self.headerView.bounds.size.width/3+10, y:feildsY,width:((self.headerView.bounds.size.width/3)*2)-20 , height:20), text: " ", alignment: .left, textColor: textColorDark)
                        labTitlevalue.numberOfLines = 0
                        labTitlevalue.lineBreakMode = NSLineBreakMode.byTruncatingTail
                        labTitlevalue.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                        
                        let str = "\(IPAddress)"
                        let properString = str.removingPercentEncoding
                        
                        
                        labTitlevalue.text = properString
                        labTitlevalue.textAlignment = NSTextAlignment.right
                        headerView.addSubview(labTitlevalue)
                        feildsY = feildsY+labTitlevalue.frame.size.height+10
                    }
                }
                if let order = self.orderDic["payment"] as? NSDictionary
                {
                    feildsY = feildsY+5
                    let lineView = UIView(frame: CGRect(x:0, y:feildsY,width:UIScreen.main.bounds.width, height:1))
                    lineView.backgroundColor = aafBgColor
                    headerView.addSubview(lineView)
                    feildsY = feildsY+10
                    if let label = order["label"] as? NSString
                    {
                        let labTitle = createLabel(CGRect(x:10,y:feildsY,width:self.headerView.bounds.size.width-120,height:15), text: "", alignment: .left, textColor: textColorDark)
                        labTitle.numberOfLines = 0
                        labTitle.lineBreakMode = NSLineBreakMode.byTruncatingTail
                        labTitle.textColor = textColorDark
                        labTitle.layer.borderColor = navColor.cgColor
                        labTitle.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                        labTitle.text = "\(label)"
                        headerView.addSubview(labTitle)
                        feildsY = feildsY+labTitle.frame.size.height+10
                    }
                    if let PaymentMethod = order["payment_method"] as? NSString
                    {
                        let labTitle = createLabel(CGRect(x:10,y:feildsY,width:self.headerView.bounds.size.width/3,height:15), text: "", alignment: .left, textColor: textColorMedium)
                        labTitle.numberOfLines = 0
                        labTitle.lineBreakMode = NSLineBreakMode.byTruncatingTail
                        labTitle.textColor = textColorDark
                        labTitle.layer.borderColor = navColor.cgColor
                        labTitle.font = UIFont(name: fontName, size: FONTSIZENormal)
                        labTitle.text = NSLocalizedString("Payment Method",  comment: "")
                        headerView.addSubview(labTitle)
                        
                        
                        let labTitlevalue = createLabel(CGRect(x:self.headerView.bounds.size.width/3+10, y:feildsY,width:((self.headerView.bounds.size.width/3)*2)-20 , height:20), text: " ", alignment: .left, textColor: textColorDark)
                        labTitlevalue.numberOfLines = 0
                        labTitlevalue.lineBreakMode = NSLineBreakMode.byTruncatingTail
                        labTitlevalue.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                        labTitlevalue.text = "\(PaymentMethod)"
                        labTitlevalue.textAlignment = NSTextAlignment.right
                        headerView.addSubview(labTitlevalue)
                        feildsY = feildsY+labTitlevalue.frame.size.height+10
                    }
                    if let chequeno = order["cheque_no"] as? Int
                    {
                        let labTitle = createLabel(CGRect(x:10,y:feildsY,width:self.headerView.bounds.size.width/3,height:15), text: "", alignment: .left, textColor: textColorMedium)
                        labTitle.numberOfLines = 0
                        labTitle.lineBreakMode = NSLineBreakMode.byTruncatingTail
                        labTitle.textColor = textColorDark
                        labTitle.layer.borderColor = navColor.cgColor
                        labTitle.font = UIFont(name: fontName, size: FONTSIZENormal)
                        labTitle.text = NSLocalizedString("Cheque No",  comment: "")
                        headerView.addSubview(labTitle)
                        
                        
                        let labTitlevalue = createLabel(CGRect(x:self.headerView.bounds.size.width/3+10, y:feildsY,width:((self.headerView.bounds.size.width/3)*2)-20 , height:20), text: " ", alignment: .left, textColor: textColorDark)
                        labTitlevalue.numberOfLines = 0
                        labTitlevalue.lineBreakMode = NSLineBreakMode.byTruncatingTail
                        labTitlevalue.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                        labTitlevalue.text = "\(chequeno)"
                        labTitlevalue.textAlignment = NSTextAlignment.right
                        headerView.addSubview(labTitlevalue)
                        feildsY = feildsY+labTitlevalue.frame.size.height+10
                    }
                    if let accountholdername = order["account_holdername"] as? NSString
                    {
                        let labTitle = createLabel(CGRect(x:10,y:feildsY,width:self.headerView.bounds.size.width/3,height:15), text: "", alignment: .left, textColor: textColorMedium)
                        labTitle.numberOfLines = 0
                        labTitle.lineBreakMode = NSLineBreakMode.byTruncatingTail
                        labTitle.textColor = textColorDark
                        labTitle.layer.borderColor = navColor.cgColor
                        labTitle.font = UIFont(name: fontName, size: FONTSIZENormal)
                        labTitle.text = NSLocalizedString("Account Holder Name",  comment: "")
                        headerView.addSubview(labTitle)
                        
                        
                        let labTitlevalue = createLabel(CGRect(x:self.headerView.bounds.size.width/3+10, y:feildsY,width:((self.headerView.bounds.size.width/3)*2)-20 , height:20), text: " ", alignment: .left, textColor: textColorDark)
                        labTitlevalue.numberOfLines = 0
                        labTitlevalue.lineBreakMode = NSLineBreakMode.byTruncatingTail
                        labTitlevalue.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                        labTitlevalue.text = "\(accountholdername)"
                        labTitlevalue.textAlignment = NSTextAlignment.right
                        headerView.addSubview(labTitlevalue)
                        feildsY = feildsY+labTitlevalue.frame.size.height+10
                    }
                    if let accountno = order["account_no"] as? Int
                    {
                        let labTitle = createLabel(CGRect(x:10,y:feildsY,width:self.headerView.bounds.size.width/3,height:15), text: "", alignment: .left, textColor: textColorMedium)
                        labTitle.numberOfLines = 0
                        labTitle.lineBreakMode = NSLineBreakMode.byTruncatingTail
                        labTitle.textColor = textColorDark
                        labTitle.layer.borderColor = navColor.cgColor
                        labTitle.font = UIFont(name: fontName, size: FONTSIZENormal)
                        labTitle.text = NSLocalizedString("Account Number",  comment: "")
                        headerView.addSubview(labTitle)
                        
                        
                        let labTitlevalue = createLabel(CGRect(x:self.headerView.bounds.size.width/3+10, y:feildsY,width:((self.headerView.bounds.size.width/3)*2)-20 , height:20), text: " ", alignment: .left, textColor: textColorDark)
                        labTitlevalue.numberOfLines = 0
                        labTitlevalue.lineBreakMode = NSLineBreakMode.byTruncatingTail
                        labTitlevalue.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                        labTitlevalue.text = "\(accountno)"
                        labTitlevalue.textAlignment = NSTextAlignment.right
                        headerView.addSubview(labTitlevalue)
                        feildsY = feildsY+labTitlevalue.frame.size.height+10
                    }
                    if let rountingnumber = order["rounting_number"] as? Int
                    {
                        let labTitle = createLabel(CGRect(x:10,y:feildsY,width:self.headerView.bounds.size.width/3,height:15), text: "", alignment: .left, textColor: textColorMedium)
                        labTitle.numberOfLines = 0
                        labTitle.lineBreakMode = NSLineBreakMode.byTruncatingTail
                        labTitle.textColor = textColorDark
                        labTitle.layer.borderColor = navColor.cgColor
                        labTitle.font = UIFont(name: fontName, size: FONTSIZENormal)
                        labTitle.text = NSLocalizedString("Bank Rounting Number",  comment: "")
                        headerView.addSubview(labTitle)
                        
                        
                        let labTitlevalue = createLabel(CGRect(x:self.headerView.bounds.size.width/3+10, y:feildsY,width:((self.headerView.bounds.size.width/3)*2)-20 , height:20), text: " ", alignment: .left, textColor: textColorDark)
                        labTitlevalue.numberOfLines = 0
                        labTitlevalue.lineBreakMode = NSLineBreakMode.byTruncatingTail
                        labTitlevalue.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                        labTitlevalue.text = "\(rountingnumber)"
                        labTitlevalue.textAlignment = NSTextAlignment.right
                        headerView.addSubview(labTitlevalue)
                        feildsY = feildsY+labTitlevalue.frame.size.height+10
                    }
                    
                }
                if let order = self.orderDic["shipping"] as? NSDictionary
                {
                    feildsY = feildsY+5
                    let lineView = UIView(frame: CGRect(x:0, y:feildsY,width:UIScreen.main.bounds.width, height:1))
                    lineView.backgroundColor = aafBgColor
                    headerView.addSubview(lineView)
                    feildsY = feildsY+10
                    if let label = order["label"] as? NSString
                    {
                        let labTitle = createLabel(CGRect(x:10,y:feildsY,width:self.headerView.bounds.size.width-120,height:15), text: "", alignment: .left, textColor: textColorDark)
                        labTitle.numberOfLines = 0
                        labTitle.lineBreakMode = NSLineBreakMode.byTruncatingTail
                        labTitle.textColor = textColorDark
                        labTitle.layer.borderColor = navColor.cgColor
                        labTitle.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                        labTitle.text = "\(label)"
                        headerView.addSubview(labTitle)
                        feildsY = feildsY+labTitle.frame.size.height+10
                    }
                    if let ShippingMethod = order["name"] as? NSString
                    {
                        let labTitle = createLabel(CGRect(x:10,y:feildsY,width:self.headerView.bounds.size.width/3,height:15), text: "", alignment: .left, textColor: textColorMedium)
                        labTitle.numberOfLines = 0
                        labTitle.lineBreakMode = NSLineBreakMode.byTruncatingTail
                        labTitle.textColor = textColorDark
                        labTitle.layer.borderColor = navColor.cgColor
                        labTitle.font = UIFont(name: fontName, size: FONTSIZENormal)
                        labTitle.text = NSLocalizedString("Shipping Method",  comment: "")
                        headerView.addSubview(labTitle)
                        
                        
                        let labTitlevalue = createLabel(CGRect(x:self.headerView.bounds.size.width/3+10, y:feildsY,width:((self.headerView.bounds.size.width/3)*2)-20 , height:20), text: " ", alignment: .left, textColor: textColorDark)
                        labTitlevalue.numberOfLines = 0
                        labTitlevalue.lineBreakMode = NSLineBreakMode.byTruncatingTail
                        labTitlevalue.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                        labTitlevalue.text = "\(ShippingMethod)"
                        labTitlevalue.textAlignment = NSTextAlignment.right
                        headerView.addSubview(labTitlevalue)
                        feildsY = feildsY+labTitlevalue.frame.size.height+10
                    }
                    
                }
                headerView.frame.size.height = feildsY
                
            }
            
            
            feildsY = headerView.frame.size.height
            let headerLabel = createLabel(CGRect(x:10, y:feildsY+5, width:UIScreen.main.bounds.width-20 , height:40), text: "", alignment:NSTextAlignment.left, textColor: textColorMedium)
            headerLabel.numberOfLines = 0
            headerLabel.font = UIFont(name: fontBold, size: FONTSIZEMedium)
            headerLabel.text = storeName
            headerLabel.backgroundColor = UIColor.clear
            tableViewHeader.addSubview(headerLabel)
            
            tableViewHeader.frame = CGRect(x:0, y:0, width:self.view.bounds.size.width, height:headerLabel.frame.size.height+headerLabel.frame.origin.y)
            tableViewHeader.backgroundColor = UIColor.clear//aafBgColor//UIColor.white
            headerHeight = tableViewHeader.frame.size.height+10
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
        var FeildY = CGFloat()
        
        let tableViewFooter = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 50))
        if let Notearr = dic["form"] as? NSArray
        {
            
            let txtViewNote = createTextView(CGRect(x:10, y:10, width:view.bounds.width-20, height:30), borderColor: borderColorLight , corner: true)
            txtViewNote.backgroundColor = UIColor.clear
            txtViewNote.textColor = textColorDark
            txtViewNote.font = UIFont(name: fontName, size: FONTSIZESmall)
            self.automaticallyAdjustsScrollViewInsets = false
            txtViewNote.isEditable = false
            txtViewNote.layer.borderColor = borderColorLight.cgColor;
            txtViewNote.layer.borderWidth = 1.0;
            txtViewNote.layer.cornerRadius = 5.0;
            txtViewNote.tag = section
            let notedic = Notearr[0] as! NSDictionary
            txtViewNote.text = notedic["label"] as! String
            tableViewFooter.addSubview(txtViewNote)
            FeildY = txtViewNote.frame.size.height + txtViewNote.frame.origin.y + 10

        }
        else
        {
             FeildY = 10.0
        }

        
        if let total = dic["subTotal"] as? Float
        {
            let totalLabel = createLabel(CGRect(x:10, y:FeildY , width:UIScreen.main.bounds.width-20 , height:15), text: "", alignment:NSTextAlignment.right, textColor: textColorDark)
            totalLabel.numberOfLines = 0
            totalLabel.font = UIFont(name: fontBold, size: FONTSIZENormal)
            var totalvalue = gettwoFractionDigits(FractionDigit:"\(total)")
            totalvalue = "\(self.CurrencySymbol)"+"\(totalvalue)"
            if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
                let defaults = UserDefaults.standard
                if let name = defaults.object(forKey: "Currency")
                {
                    let price = gettwoFractionDigits(FractionDigit: "\(total)")
                    let changePrice = (defaults.object(forKey: "PriceRate") as! Float) * Float(price)!
                    let showPrice = (String(format:"%.2f", changePrice))
                    
                    totalvalue =  "\(getCurrencySymbol(name as! String)) \(showPrice)"
                    totalLabel.text = String(format: NSLocalizedString("Total: %@", comment: ""),totalvalue)
                    
                }
            }
            else{
               totalLabel.text = String(format: NSLocalizedString("Total: %@", comment: ""),totalvalue)
            }
            
           // totalLabel.text = String(format: NSLocalizedString("Total: %@", comment: ""),totalvalue)
            tableViewFooter.addSubview(totalLabel)
            FeildY = totalLabel.frame.size.height + totalLabel.frame.origin.y + 10
        }

        if var shipingname = dic["shipping_method"] as? String
        {
            let shippingLabel = createLabel(CGRect(x:10, y:FeildY, width:UIScreen.main.bounds.width-20 , height:15), text: "", alignment:NSTextAlignment.right, textColor: textColorDark)
            shippingLabel.numberOfLines = 0
            shippingLabel.font = UIFont(name: fontBold, size: FONTSIZENormal)
            //shipingname = "\(shipingname)" + ": "
            shipingname = NSLocalizedString("Shipping Cost: ", comment: "")
            var shipingprice = ""
            var shipingprice1 = ""
            if let price = dic["shipping_method_price"] as? Float {
                shipingprice = "\(price)"
                shipingprice1 = gettwoFractionDigits(FractionDigit:"\(price)")
            }
            else if let price = dic["shipping_method_price"] as? NSNumber {
                shipingprice = "\(price)"
                shipingprice1 = gettwoFractionDigits(FractionDigit:"\(price)")
            }
            
            if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
                let defaults = UserDefaults.standard
                if let name = defaults.object(forKey: "Currency")
                {
                    let price = gettwoFractionDigits(FractionDigit: "\(shipingprice)")
                    let changePrice = (defaults.object(forKey: "PriceRate") as! Float) * Float(price)!
                    let showPrice = (String(format:"%.2f", changePrice))
                    
                    shipingprice1 =  "\(getCurrencySymbol(name as! String)) \(showPrice)"
                    
                }
            }
            else{
                shipingprice1 = "\(self.CurrencySymbol)"+"\(shipingprice1)"
            }
            
           // shipingprice1 = "\(self.CurrencySymbol)"+"\(shipingprice1)"
            shippingLabel.text =   "\(shipingname)" + "\(shipingprice1)"
            tableViewFooter.addSubview(shippingLabel)
            FeildY = shippingLabel.frame.size.height + shippingLabel.frame.origin.y + 10
        }
        if let tax = dic["tax"] as? Float
        {
            let taxLabel = createLabel(CGRect(x:10, y:FeildY , width:UIScreen.main.bounds.width-20 , height:15), text: "", alignment:NSTextAlignment.right, textColor: textColorDark)
            taxLabel.numberOfLines = 0
            taxLabel.font = UIFont(name: fontBold, size: FONTSIZENormal)
            var taxvalue = gettwoFractionDigits(FractionDigit:"\(tax)")
            
            if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
                let defaults = UserDefaults.standard
                if let name = defaults.object(forKey: "Currency")
                {
                    let price = gettwoFractionDigits(FractionDigit: "\(tax)")
                    let changePrice = (defaults.object(forKey: "PriceRate") as! Float) * Float(price)!
                    let showPrice = (String(format:"%.2f", changePrice))
                    
                    taxvalue =  "\(getCurrencySymbol(name as! String)) \(showPrice)"
                    
                }
            }
            else{
                taxvalue = "\(self.CurrencySymbol)"+"\(taxvalue)"
            }
            
           // taxvalue = "\(self.CurrencySymbol)"+"\(taxvalue)"
            taxLabel.text = String(format: NSLocalizedString("Tax: %@", comment: ""),taxvalue)
            tableViewFooter.addSubview(taxLabel)
            FeildY = taxLabel.frame.size.height + taxLabel.frame.origin.y + 10
        }
        
        if let tax = dic["totalVat"] as? Float
        {
            let taxLabel = createLabel(CGRect(x:10, y:FeildY , width:UIScreen.main.bounds.width-20 , height:15), text: "", alignment:NSTextAlignment.right, textColor: textColorDark)
            taxLabel.numberOfLines = 0
            taxLabel.font = UIFont(name: fontBold, size: FONTSIZENormal)
            var taxvalue = gettwoFractionDigits(FractionDigit:"\(tax)")
            
            if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
                let defaults = UserDefaults.standard
                if let name = defaults.object(forKey: "Currency")
                {
                    let price = gettwoFractionDigits(FractionDigit: "\(tax)")
                    let changePrice = (defaults.object(forKey: "PriceRate") as! Float) * Float(price)!
                    let showPrice = (String(format:"%.2f", changePrice))
                    
                    taxvalue =  "\(getCurrencySymbol(name as! String)) \(showPrice)"
                    
                }
            }
            else{
                taxvalue = "\(self.CurrencySymbol)"+"\(taxvalue)"
            }
           // taxvalue = "\(self.CurrencySymbol)"+"\(taxvalue)"
            taxLabel.text = String(format: NSLocalizedString("Vat: %@", comment: ""),taxvalue)
            tableViewFooter.addSubview(taxLabel)
            FeildY = taxLabel.frame.size.height + taxLabel.frame.origin.y + 10
        }

        if self.orderDic["directPayment"] as? Bool == false
        {
            if let coupon = self.orderDic["coupon"] as? NSDictionary
            {
                let couponLabel = createLabel(CGRect(x:10, y:FeildY , width:UIScreen.main.bounds.width-20 , height:15), text: "", alignment:NSTextAlignment.right, textColor: textColorDark)
                couponLabel.numberOfLines = 0
                couponLabel.font = UIFont(name: fontBold, size: FONTSIZENormal)
                
                let value = coupon["value"] as! Float
                var couponvalue = gettwoFractionDigits(FractionDigit:"\(value)")
                
                if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
                    let defaults = UserDefaults.standard
                    if let name = defaults.object(forKey: "Currency")
                    {
                        let price = gettwoFractionDigits(FractionDigit: "\(value)")
                        let changePrice = (defaults.object(forKey: "PriceRate") as! Float) * Float(price)!
                        let showPrice = (String(format:"%.2f", changePrice))
                        
                        couponvalue =  "-\(getCurrencySymbol(name as! String)) \(showPrice)"
                        
                    }
                }
                else{
                    couponvalue = "-"+"\(self.CurrencySymbol)"+"\(couponvalue)"
                }
                
               // couponvalue = "-"+"\(self.CurrencySymbol)"+"\(couponvalue)"
                var name = coupon["coupon_code"]
                name = "\(name!)" + ":" + " " + "\(couponvalue)"
                couponLabel.text = "\(name!)"
                tableViewFooter.addSubview(couponLabel)
                FeildY = couponLabel.frame.size.height + couponLabel.frame.origin.y + 10
            }
            
        }
        else
        {
            if let coupon = dic["coupon"] as? NSDictionary
            {
                let couponLabel = createLabel(CGRect(x:10, y:FeildY , width:UIScreen.main.bounds.width-20 , height:15), text: "", alignment:NSTextAlignment.right, textColor: textColorDark)
                couponLabel.numberOfLines = 0
                couponLabel.font = UIFont(name: fontBold, size: FONTSIZENormal)
                
                let value = coupon["value"] as! Float
                var couponvalue = gettwoFractionDigits(FractionDigit:"\(value)")
                
                if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
                    let defaults = UserDefaults.standard
                    if let name = defaults.object(forKey: "Currency")
                    {
                        let price = gettwoFractionDigits(FractionDigit: "\(value)")
                        let changePrice = (defaults.object(forKey: "PriceRate") as! Float) * Float(price)!
                        let showPrice = (String(format:"%.2f", changePrice))
                        
                        couponvalue =  "-\(getCurrencySymbol(name as! String)) \(showPrice)"
                        
                    }
                }
                else{
                    couponvalue = "-"+"\(self.CurrencySymbol)"+"\(couponvalue)"
                }
                
               // couponvalue = "-"+"\(self.CurrencySymbol)"+"\(couponvalue)"
                var name = coupon["coupon_code"]
                name = "\(name!)" + ":" + " " + "\(couponvalue)"
                couponLabel.text = "\(name!)"
                tableViewFooter.addSubview(couponLabel)
                FeildY = couponLabel.frame.size.height + couponLabel.frame.origin.y + 10
            }
        }

        tableViewFooter.frame = CGRect(x:0, y:0, width:self.view.bounds.size.width, height:FeildY)
        tableViewFooter.backgroundColor = tableViewBgColor
        footerHeight = tableViewFooter.frame.size.height+10
        return footerHeight
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
            //CreateFooter(dic)
            footerHeight = 0.0001
            let tableViewFooter = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 50))
            var FeildY = CGFloat()
            if let Notearr = dic["form"] as? NSArray
            {
                
                let txtViewNote = createTextView(CGRect(x:10, y:10, width:view.bounds.width-20, height:40), borderColor: borderColorMedium , corner: true)
                txtViewNote.backgroundColor = UIColor.clear
                txtViewNote.textColor = textColorMedium
                txtViewNote.font = UIFont(name: fontName, size: FONTSIZENormal)
                self.automaticallyAdjustsScrollViewInsets = false
                txtViewNote.layer.borderColor = borderColorMedium.cgColor;
                txtViewNote.layer.borderWidth = 1.0;
                txtViewNote.layer.cornerRadius = 3.0;
                txtViewNote.delegate = self
                txtViewNote.tag = section
                let notedic = Notearr[0] as! NSDictionary
                let name = notedic["name"] as! String
                txtViewNote.text = notedic["label"] as! String
                for (key,value) in orderNotedic
                {
                    if key == name
                    {
                        txtViewNote.text = value
                    }
                }
                
                tableViewFooter.addSubview(txtViewNote)
                FeildY = txtViewNote.frame.size.height + txtViewNote.frame.origin.y + 10
                
                
            }
            else
            {
                FeildY = 10.0
            }
            
            if let total = dic["subTotal"] as? Float
            {
                let totalLabel = createLabel(CGRect(x:10, y:FeildY , width:UIScreen.main.bounds.width-20 , height:15), text: "", alignment:NSTextAlignment.right, textColor: textColorDark)
                totalLabel.numberOfLines = 0
                totalLabel.font = UIFont(name: fontBold, size: FONTSIZENormal)
                var totalvalue = gettwoFractionDigits(FractionDigit:"\(total)")
                
                if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
                    let defaults = UserDefaults.standard
                    if let name = defaults.object(forKey: "Currency")
                    {
                        let price = gettwoFractionDigits(FractionDigit: "\(total)")
                        let changePrice = (defaults.object(forKey: "PriceRate") as! Float) * Float(price)!
                        let showPrice = (String(format:"%.2f", changePrice))
                        
                        totalvalue =  "\(getCurrencySymbol(name as! String)) \(showPrice)"
                        
                    }
                }
                else{
                   totalvalue = "\(self.CurrencySymbol)"+"\(totalvalue)"
                }
                
               // totalvalue = "\(self.CurrencySymbol)"+"\(totalvalue)"
                totalLabel.text = String(format: NSLocalizedString("Total: %@", comment: ""),totalvalue)
                tableViewFooter.addSubview(totalLabel)
                FeildY = totalLabel.frame.size.height + totalLabel.frame.origin.y + 10
            }
            if var shipingname = dic["shipping_method"] as? String
            {
                let shippingLabel = createLabel(CGRect(x:10, y:FeildY, width:UIScreen.main.bounds.width-20 , height:15), text: "", alignment:NSTextAlignment.right, textColor: textColorDark)
                shippingLabel.numberOfLines = 0
                shippingLabel.font = UIFont(name: fontBold, size: FONTSIZENormal)
                shipingname = NSLocalizedString("Shipping Cost: ", comment: "")
                var shipingprice = ""
                var shipingprice1 = ""
                if let price = dic["shipping_method_price"] as? Float {
                    shipingprice = "\(price)"
                    shipingprice1 = gettwoFractionDigits(FractionDigit:"\(price)")
                }
                else if let price = dic["shipping_method_price"] as? NSNumber {
                    shipingprice = "\(price)"
                    shipingprice1 = gettwoFractionDigits(FractionDigit:"\(price)")
                }
                if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
                    let defaults = UserDefaults.standard
                    if let name = defaults.object(forKey: "Currency")
                    {
                        let price = gettwoFractionDigits(FractionDigit: "\(shipingprice)")
                        let changePrice = (defaults.object(forKey: "PriceRate") as! Float) * Float(price)!
                        let showPrice = (String(format:"%.2f", changePrice))
                        
                        shipingprice1 =  "\(getCurrencySymbol(name as! String)) \(showPrice)"
                        
                    }
                }
                else{
                    shipingprice1 = "\(self.CurrencySymbol)"+"\(shipingprice1)"
                }
                
               // shipingprice1 = "\(self.CurrencySymbol)"+"\(shipingprice1)"
                shippingLabel.text =   "\(shipingname)" + "\(shipingprice1)"
                tableViewFooter.addSubview(shippingLabel)
                FeildY = shippingLabel.frame.size.height + shippingLabel.frame.origin.y + 10
            }
            if let tax = dic["tax"] as? Float
            {
                let taxLabel = createLabel(CGRect(x:10, y:FeildY , width:UIScreen.main.bounds.width-20 , height:15), text: "", alignment:NSTextAlignment.right, textColor: textColorDark)
                taxLabel.numberOfLines = 0
                taxLabel.font = UIFont(name: fontBold, size: FONTSIZENormal)
                var taxvalue = gettwoFractionDigits(FractionDigit:"\(tax)")
                
                if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
                    let defaults = UserDefaults.standard
                    if let name = defaults.object(forKey: "Currency")
                    {
                        let price = gettwoFractionDigits(FractionDigit: "\(tax)")
                        let changePrice = (defaults.object(forKey: "PriceRate") as! Float) * Float(price)!
                        let showPrice = (String(format:"%.2f", changePrice))
                        
                        taxvalue =  "\(getCurrencySymbol(name as! String)) \(showPrice)"
                        
                    }
                }
                else{
                    taxvalue = "\(self.CurrencySymbol)"+"\(taxvalue)"
                }
                
              //  taxvalue = "\(self.CurrencySymbol)"+"\(taxvalue)"
                taxLabel.text = String(format: NSLocalizedString("Tax: %@", comment: ""),taxvalue)
                tableViewFooter.addSubview(taxLabel)
                FeildY = taxLabel.frame.size.height + taxLabel.frame.origin.y + 10
            }
            
            if let tax = dic["totalVat"] as? Float
            {
                let taxLabel = createLabel(CGRect(x:10, y:FeildY , width:UIScreen.main.bounds.width-20 , height:15), text: "", alignment:NSTextAlignment.right, textColor: textColorDark)
                taxLabel.numberOfLines = 0
                taxLabel.font = UIFont(name: fontBold, size: FONTSIZENormal)
                var taxvalue = gettwoFractionDigits(FractionDigit:"\(tax)")
                
                if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
                    let defaults = UserDefaults.standard
                    if let name = defaults.object(forKey: "Currency")
                    {
                        let price = gettwoFractionDigits(FractionDigit: "\(tax)")
                        let changePrice = (defaults.object(forKey: "PriceRate") as! Float) * Float(price)!
                        let showPrice = (String(format:"%.2f", changePrice))
                        
                        taxvalue =  "\(getCurrencySymbol(name as! String)) \(showPrice)"
                        
                    }
                }
                else{
                
                taxvalue = "\(self.CurrencySymbol)"+"\(taxvalue)"
                }
                taxLabel.text = String(format: NSLocalizedString("Total VAT: %@", comment: ""),taxvalue)
                tableViewFooter.addSubview(taxLabel)
                FeildY = taxLabel.frame.size.height + taxLabel.frame.origin.y + 10
            }
            if self.orderDic["directPayment"] as? Bool == false
            {
                if let coupon = self.orderDic["coupon"] as? NSDictionary
                {
                    let couponLabel = createLabel(CGRect(x:10, y:FeildY , width:UIScreen.main.bounds.width-20 , height:15), text: "", alignment:NSTextAlignment.right, textColor: textColorDark)
                    couponLabel.numberOfLines = 0
                    couponLabel.font = UIFont(name: fontBold, size: FONTSIZENormal)
                    
                    let value = coupon["value"] as! Float
                    var couponvalue = gettwoFractionDigits(FractionDigit:"\(value)")
                    
                    if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
                        let defaults = UserDefaults.standard
                        if let name = defaults.object(forKey: "Currency")
                        {
                            let price = gettwoFractionDigits(FractionDigit: "\(value)")
                            let changePrice = (defaults.object(forKey: "PriceRate") as! Float) * Float(price)!
                            let showPrice = (String(format:"%.2f", changePrice))
                            
                            couponvalue =  "-\(getCurrencySymbol(name as! String)) \(showPrice)"
                            
                        }
                    }
                    else{
                    
                    couponvalue = "-"+"\(self.CurrencySymbol)"+"\(couponvalue)"
                    }
                    var name = coupon["coupon_code"]
                    name = "\(name!)" + ":" + " " + "\(couponvalue)"
                    couponLabel.text = "\(name!)"
                    tableViewFooter.addSubview(couponLabel)
                    FeildY = couponLabel.frame.size.height + couponLabel.frame.origin.y + 10
                }
                
            }
            else
            {
                if let coupon = dic["coupon"] as? NSDictionary
                {
                    let couponLabel = createLabel(CGRect(x:10, y:FeildY , width:UIScreen.main.bounds.width-20 , height:15), text: "", alignment:NSTextAlignment.right, textColor: textColorDark)
                    couponLabel.numberOfLines = 0
                    couponLabel.font = UIFont(name: fontBold, size: FONTSIZENormal)
                    
                    let value = coupon["value"] as! Float
                    var couponvalue = gettwoFractionDigits(FractionDigit:"\(value)")
                    
                    if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
                        let defaults = UserDefaults.standard
                        if let name = defaults.object(forKey: "Currency")
                        {
                            let price = gettwoFractionDigits(FractionDigit: "\(value)")
                            let changePrice = (defaults.object(forKey: "PriceRate") as! Float) * Float(price)!
                            let showPrice = (String(format:"%.2f", changePrice))
                            
                            couponvalue =  "-\(getCurrencySymbol(name as! String)) \(showPrice)"
                            
                        }
                    }
                    else{
                    
                    couponvalue = "-"+"\(self.CurrencySymbol)"+"\(couponvalue)"
                    }
                    var name = coupon["coupon_code"]
                    name = "\(name!)" + ":" + " " + "\(couponvalue)"
                    couponLabel.text = "\(name!)"
                    tableViewFooter.addSubview(couponLabel)
                    FeildY = couponLabel.frame.size.height + couponLabel.frame.origin.y + 10
                }
            }
            
            
            
            tableViewFooter.frame = CGRect(x:0, y:0, width:self.view.bounds.size.width, height:FeildY)
            tableViewFooter.backgroundColor = UIColor.white//aafBgColor//UIColor.white
            footerHeight = tableViewFooter.frame.size.height+10
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
        let cell = orderReviewTableView.dequeueReusableCell(withIdentifier: "CellThree", for: indexPath as IndexPath)as! OrderReviewTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.backgroundColor = UIColor.white//tableViewBgColor
        cell.profileFieldLabel.frame = CGRect(x:cell.labTitle.frame.origin.x, y:cell.labTitle.frame.origin.y + cell.labTitle.bounds.height + 8 , width:UIScreen.main.bounds.width - 20 , height:0)
        cell.profileFieldLabel.text = ""
        cell.profileFieldLabel.isHidden = true
        let arr = self.storedic.allKeys
        let index = arr[indexPath.section] as! NSString
        let dic = self.storedic["\(index)"] as! NSDictionary
        if let productarr = dic["products"] as? NSArray
        {
            let dic = productarr[indexPath.row] as! NSDictionary
            cell.labTitle.text = dic["title"] as? String

            if let quantity = dic["quantity"] as? Int
            {
                cell.labQuantity.text = NSLocalizedString("Quantity", comment: "")
                cell.labQuantityvalue.text = "\(quantity)"
                
            }
            if let price = dic["unitPrice"] as? AnyObject
            {
                cell.labPrice.text = NSLocalizedString("Price", comment: "")
                var value = ""
                if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
                    let defaults = UserDefaults.standard
                    if let name = defaults.object(forKey: "Currency")
                    {
                        let price = gettwoFractionDigits(FractionDigit: "\(price as? Float ?? Float(price as? Double ?? 0.0))")
                        let changePrice = (defaults.object(forKey: "PriceRate") as! Float) * Float(price)!
                        let showPrice = (String(format:"%.2f", changePrice))
                        
                        value =  "\(getCurrencySymbol(name as! String)) \(showPrice)"
                        
                    }
                }
                else{
                    value = "\(self.CurrencySymbol)"+"\(price)"
                }
               // let value = "\(self.CurrencySymbol)"+"\(price)"
                cell.labPricevalue.text = "\(value)"
                
            }
            //For showing SKU value in case of myorder
            if iscomingFrom == "MYorders"
            {
                cell.labSku.isHidden = false
                cell.labSkuvalue.isHidden = false
                if let sku = dic["product_sku"] as? String
                {
                    cell.labSku.text = NSLocalizedString("SKU", comment: "")
                    cell.labSkuvalue.text = sku
                    
                }
                else
                {
                    cell.labSku.text = NSLocalizedString("SKU", comment: "")
                    cell.labSkuvalue.text = "-"
                }

            }

            if let subtotal = dic["price"] as? AnyObject
            {
                cell.labSubTotal.text = NSLocalizedString("SubTotal", comment: "")
                var value = ""
                if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
                    let defaults = UserDefaults.standard
                    if let name = defaults.object(forKey: "Currency")
                    {
                        let price = gettwoFractionDigits(FractionDigit: "\(subtotal as? Float ?? Float(subtotal as? Double ?? 0.0))")
                        let changePrice = (defaults.object(forKey: "PriceRate") as! Float) * Float(price)!
                        let showPrice = (String(format:"%.2f", changePrice))
                        
                        value =  "\(getCurrencySymbol(name as! String)) \(showPrice)"
                        
                    }
                }
                else{
                    value = "\(self.CurrencySymbol)"+"\(subtotal )"
                }
                // value = "\(self.CurrencySymbol)"+"\(subtotal)"
                cell.labSubTotalvalue.text = "\(value)"
                
            }

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
                
                cell.labPrice.frame = CGRect(x:cell.labTitle.frame.origin.x,y:cell.profileFieldLabel.frame.origin.y+cell.profileFieldLabel.frame.size.height+5,width:50, height:15)
                cell.labPricevalue.frame = CGRect(x:UIScreen.main.bounds.width-120,y:cell.profileFieldLabel.frame.origin.y+cell.profileFieldLabel.frame.size.height+5,width:110, height:15)
                
                cell.labQuantity.frame = CGRect(x:cell.labTitle.frame.origin.x,y:cell.labPrice.frame.origin.y+cell.labPrice.frame.size.height+10,width:70,height:15)
                cell.labQuantityvalue.frame = CGRect(x:UIScreen.main.bounds.width-120,y:cell.labPrice.frame.origin.y+cell.labPrice.frame.size.height+10,width:110, height:15)
                
                
                cell.labSku.frame = CGRect(x:cell.labTitle.frame.origin.x,y:cell.labQuantity.frame.origin.y+cell.labQuantity.frame.size.height+10,width:(UIScreen.main.bounds.width-20),height:15)
                cell.labSkuvalue.frame  = CGRect(x:UIScreen.main.bounds.width-120,y:cell.labQuantity.frame.origin.y+cell.labQuantity.frame.size.height+10,width:110, height:15)
                
                if iscomingFrom == "MYorders"
                {
                    cell.labSubTotal.frame = CGRect(x:cell.labTitle.frame.origin.x,y:cell.labSkuvalue.frame.origin.y+cell.labSkuvalue.frame.size.height+10,width:(UIScreen.main.bounds.width-20),height:15)
                    cell.labSubTotalvalue.frame  = CGRect(x:UIScreen.main.bounds.width-120,y:cell.labSkuvalue.frame.origin.y+cell.labSkuvalue.frame.size.height+10,width:110, height:15)
                }
                else
                {
                    cell.labSubTotal.frame = CGRect(x:cell.labTitle.frame.origin.x,y:cell.labQuantity.frame.origin.y+cell.labQuantity.frame.size.height+10,width:(UIScreen.main.bounds.width-20),height:15)
                    cell.labSubTotalvalue.frame = CGRect(x:UIScreen.main.bounds.width-120,y:cell.labQuantity.frame.origin.y+cell.labQuantity.frame.size.height+10,width:110, height:15)
                }
                
                dynamicHeight = 70
                if dynamicHeight < (cell.labSubTotal.frame.origin.y + cell.labSubTotal.bounds.height)
                {
                    dynamicHeight = cell.labSubTotal.frame.origin.y + cell.labSubTotal.bounds.height+10
                    cell.lineView.frame.origin.y = dynamicHeight
                    
                }
            }
            else
            {
                dynamicHeight = 70
                cell.labPrice.frame = CGRect(x:cell.labTitle.frame.origin.x,y:cell.profileFieldLabel.frame.origin.y+cell.profileFieldLabel.frame.size.height+5,width:50, height:15)
                cell.labPricevalue.frame = CGRect(x:UIScreen.main.bounds.width-120,y:cell.profileFieldLabel.frame.origin.y+cell.profileFieldLabel.frame.size.height+5,width:110, height:15)
                
                cell.labQuantity.frame = CGRect(x:cell.labTitle.frame.origin.x,y:cell.labPrice.frame.origin.y+cell.labPrice.frame.size.height+10,width:70,height:15)
                cell.labQuantityvalue.frame = CGRect(x:UIScreen.main.bounds.width-120,y:cell.labPrice.frame.origin.y+cell.labPrice.frame.size.height+10,width:110, height:15)
                
                
                cell.labSku.frame = CGRect(x:cell.labTitle.frame.origin.x,y:cell.labQuantity.frame.origin.y+cell.labQuantity.frame.size.height+10,width:(UIScreen.main.bounds.width-20),height:15)
                cell.labSkuvalue.frame  = CGRect(x:UIScreen.main.bounds.width-120,y:cell.labQuantity.frame.origin.y+cell.labQuantity.frame.size.height+10,width:110, height:15)
                
                if iscomingFrom == "MYorders"
                {
                    cell.labSubTotal.frame = CGRect(x:cell.labTitle.frame.origin.x,y:cell.labSkuvalue.frame.origin.y+cell.labSkuvalue.frame.size.height+10,width:(UIScreen.main.bounds.width-20),height:15)
                    cell.labSubTotalvalue.frame  = CGRect(x:UIScreen.main.bounds.width-120,y:cell.labSkuvalue.frame.origin.y+cell.labSkuvalue.frame.size.height+10,width:110, height:15)
                }
                else
                {
                    cell.labSubTotal.frame = CGRect(x:cell.labTitle.frame.origin.x,y:cell.labQuantity.frame.origin.y+cell.labQuantity.frame.size.height+10,width:(UIScreen.main.bounds.width-20),height:15)
                    cell.labSubTotalvalue.frame = CGRect(x:UIScreen.main.bounds.width-120,y:cell.labQuantity.frame.origin.y+cell.labQuantity.frame.size.height+10,width:110, height:15)
                }
                
                if dynamicHeight < (cell.labSubTotal.frame.origin.y + cell.labSubTotal.bounds.height)
                {
                    dynamicHeight = cell.labSubTotal.frame.origin.y + cell.labSubTotal.bounds.height+10
                    cell.lineView.frame.origin.y = dynamicHeight
                    
                }
            }


        }
        return cell
        
    }
    
    // Handle Blog Table Cell Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    // MARK: Textview Delegate
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool
    {
        let absoluteframe = textView.convert(textView.frame, to: UIApplication.shared.keyWindow)
        offset = self.orderReviewTableView.contentOffset
        if absoluteframe.origin.y > 300
        {
            UIView.animate(withDuration:0.3) { () -> Void in
                let diff = absoluteframe.origin.y-270
                self.orderReviewTableView.contentOffset.y += diff
            }

            
        }
        
        if textView.text == NSLocalizedString("Write a note for your order from this Store.",  comment: "")
        {
            textView.text = ""
        }
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n")
        {
                UIView.animate(withDuration:0.3) { () -> Void in
                    textView.resignFirstResponder()
                    self.orderReviewTableView.contentOffset.y = self.offset.y

                }
            
            return false
        }
        
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    {
        if textView.text == ""
        {
            textView.text = NSLocalizedString("Write a note for your order from this Store.",  comment: "")
        }
        
        let arr = self.storedic.allKeys
        let index = arr[textView.tag]
        let dic = self.storedic["\(index)"] as! NSDictionary
        
        if let notearr = dic["form"] as? NSArray
        {
            let notedic = notearr[0] as! NSDictionary
            let key = notedic["name"] as! String
            
            if textView.text == NSLocalizedString("Write a note for your order from this Store.",  comment: "")
            {
                orderNotedic["\(key)"] = ""
            }
            else
            {
                orderNotedic["\(key)"] = textView.text
            }
            
        }
    }
    
    func CreateFooter(dic:NSDictionary)
    {
        let tableViewFooter = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 50))
        var FeildY = CGFloat()
        if let _ = dic["totalAmountFields"] as? NSDictionary
        {
            
            let profileFieldLabel = createLabel(CGRect(x:10,y:10 ,width:UIScreen.main.bounds.width-20 , height:20), text: "", alignment:NSTextAlignment.right, textColor: textColorDark)
            profileFieldLabel.numberOfLines = 0
            profileFieldLabel.textColor = textColorDark
            profileFieldLabel.font = UIFont(name: fontBold, size: FONTSIZEMedium)

            if let grandTotal = dic["grandTotal"] as? Float {
                var grand = gettwoFractionDigits(FractionDigit:"\(grandTotal)")
                
            if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
            let defaults = UserDefaults.standard
            if let name = defaults.object(forKey: "Currency")
            {
            let price = gettwoFractionDigits(FractionDigit: "\(grandTotal)")
            let changePrice = (defaults.object(forKey: "PriceRate") as! Float) * Float(price)!
            let showPrice = (String(format:"%.2f", changePrice))
            
            grand =  "\(getCurrencySymbol(name as! String)) \(showPrice)"
            
            }
            }
            else{
            grand = "\(self.CurrencySymbol)"+"\(grand)"
            }
                
                profileFieldLabel.text = String(format: NSLocalizedString("Grand Total: %@", comment: ""),grand)
            }

            tableViewFooter.addSubview(profileFieldLabel)
            
            FeildY = profileFieldLabel.frame.size.height+profileFieldLabel.frame.origin.y+10
        }
        
        if iscomingFrom != "MYorders"
        {
            let bacgoundView = createView(CGRect(x:0, y:FeildY, width:self.view.bounds.width, height:50), borderColor: borderColorClear, shadow: false)
            bacgoundView.backgroundColor = UIColor.white
            tableViewFooter.addSubview(bacgoundView)
            
            
            let btnprivatePurchase = createButton(CGRect(x:10,y:10,width:20, height:30), title: "", border: false,bgColor: false, textColor: textColorMedium)
            btnprivatePurchase.isHidden = false
            btnprivatePurchase.tag = 1000
            btnprivatePurchase.backgroundColor = UIColor.clear
            btnprivatePurchase.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
            let profileFieldString = String(format: NSLocalizedString("%@", comment: ""), "\u{f046}")
            btnprivatePurchase.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZEExtraLarge)
            btnprivatePurchase.addTarget(self, action: #selector(OrderReviewViewController.pressedCheckBox), for: UIControl.Event.touchUpInside)
            btnprivatePurchase.isSelected = true
            checkoutDic["is_private_order"] = "1"
            btnprivatePurchase.setTitle("\(profileFieldString)", for: UIControl.State.normal)
            bacgoundView.addSubview(btnprivatePurchase)
            
            
            
            let privatePurchaseLabel = createLabel(CGRect(x:btnprivatePurchase.frame.size.width+btnprivatePurchase.frame.origin.x,y:15 , width:UIScreen.main.bounds.width-(btnprivatePurchase.frame.size.width+btnprivatePurchase.frame.origin.x+10) , height:20), text: "", alignment:NSTextAlignment.left, textColor: textColorMedium)
            privatePurchaseLabel.numberOfLines = 0
            privatePurchaseLabel.font = UIFont(name: fontBold, size: FONTSIZENormal)
            
            if let isprivatearr = dic["form"] as? NSArray
            {
                let isprivatedic = isprivatearr[0] as! NSDictionary
                if let label = isprivatedic["label"] as? String
                {
                    privatePurchaseLabel.text = label
                }
            }
            bacgoundView.addSubview(privatePurchaseLabel)
            FeildY = bacgoundView.frame.size.height+bacgoundView.frame.origin.y+10
            
        }
        tableViewFooter.frame = CGRect(x:0, y:0, width:self.view.bounds.size.width, height:FeildY)
        tableViewFooter.backgroundColor = tableViewBgColor//aafBgColor//UIColor.white//tableViewBgColor//UIColor.white
        self.orderReviewTableView.tableFooterView  = tableViewFooter
        
        
    }

    @objc func PlaceOrderAction(sender:UIButton)
    {
        
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork()
        {
            view.isUserInteractionEnabled = false
//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            
            //Set Parameters & path for Sign Up Form
            var parameter = [String:String]()
            var path = ""
            parameter = ["":""]
            
            if iscomingFrom != "MYorders"
            {
                for key in orderNotedic.keys {
                    checkoutDic[key] = orderNotedic[key]
                }
                parameter = checkoutDic
                parameter["store_id"] = Store_id
                parameter["billingAddress_id"] = String(bilingid)
                if shippingid != nil {
                    parameter["shippingAddress_id"] = String(shippingid)
                }
               // parameter["shippingAddress_id"] = String(shippingid)
                path = "sitestore/checkout/validating-order"
                // Logout user
                if logoutUser == true
                {
                    if logoutCartarr.count>0
                    {
                        // Convert core data array into json object
                        parameter["productsData"] = GetjsonObject(data:logoutCartarr)
                    }
                    
                }
            }

            
            // Send Server Request to Sign Up Form
            post(parameter,url: path , method: "POST") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    self.view.alpha = 1.0
                    self.view.isUserInteractionEnabled = true
                    if msg
                    {
                        manageCartUpdate = true
                        iscomingfrom = "orderReview"
                        couponDIC.removeAll()
                        if let dic = succeeded["body"] as? NSDictionary
                        {
                            if let productIds = dic["productids"] as? NSArray
                            {
                                if productIds.count>0
                                {
                                    for i in 0 ..< productIds.count
                                    {
                                        let productId = productIds[i] as! Int
                                        self.DeleteFromCoreData(index: productId)
                                    }
                                    
                                }
                                showToast(message:NSLocalizedString("Your order placed sucessfully.", comment: ""), controller: self)
                                self.popAfterDelay = true
                                self.createTimer(self)

                                
                            }
                            if let url = dic["payment_url"] as? String
                            {
                                
                                let presentedVC = ExternalWebViewController()
                                presentedVC.url = url
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let navigationController = UINavigationController(rootViewController: presentedVC)
                                self.present(navigationController, animated: true, completion: nil)
                            }

                        }
                        else
                        {
                            showToast(message:NSLocalizedString("Your order placed sucessfully.", comment: ""), controller: self)
                            self.popAfterDelay = true
                            self.createTimer(self)
                   
                        }
                        getCartCount()
                    }
                    else
                    {
                        let a = validation
                        signupValidation.removeAll(keepingCapacity: false)
                        signupValidationKeyValue.removeAll(keepingCapacity: false)
                        
                        for (key,value) in a
                        {
                            signupValidation.append(value as AnyObject)
                            signupValidationKeyValue.append(key as AnyObject)
                            
                        }
                        
                        let count = signupValidation.count
                        if count > 0
                        {
                             showToast(message:"\(signupValidation[0] as! String).\n", controller: self)
                        }
                        else
                        {
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                        }
                    }
                })
            }
        }
        
    }
    func createTimer(_ target: AnyObject){
        timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  #selector(stopTimer), userInfo: nil, repeats: false)
    }
    // MARK: Getting Checkout Form
    func browseorderReview()
    {
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork()
        {
//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            
            //Set Parameters & path for Sign Up Form
            var parameter = [String:String]()
            var path = ""
            parameter = ["":""]
            
            if iscomingFrom == "MYorders"
            {
                path = url
            }
            else
            {
                if couponDIC.count>0
                {
                    checkoutDic.merge(couponDIC)
                    parameter = checkoutDic
                }
                else
                {
                    parameter = checkoutDic
                }
                parameter["store_id"] = Store_id
                parameter["billingAddress_id"] = String(bilingid)
                if shippingid != nil {
                parameter["shippingAddress_id"] = String(shippingid)
                }
                path = "sitestore/checkout/validating-order"
                // Logout user
                if logoutUser == true
                {
                    if logoutCartarr.count>0
                    {
                        // Convert core data array into json object
                        parameter["productsData"] = GetjsonObject(data:logoutCartarr)
                    }
                    
                }
            }

            
            // Send Server Request for Sign Up Form
            post(parameter, url: path, method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        // On Success Add Value to Form Array & Values to formValue Array
                        Form.removeAll(keepingCapacity: false)
                        
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                        }
                        
                        if let dic = succeeded["body"] as? NSDictionary
                        {
                            self.orderDic = dic
                            if let dic = self.orderDic["stores"] as? NSMutableDictionary
                            {
                                self.storedic = dic
                            }
                            if let StrCurrency = self.orderDic["currency"] as? String
                            {
                                self.CurrencySymbol = getCurrencySymbol(StrCurrency)
                            }
                            if self.iscomingFrom == "MYorders"
                            {
                                self.createHeader()
                            }
                            
                            self.orderReviewTableView.reloadData()
                            self.CreateFooter(dic: dic)
                        }
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
    // Get record from core data into array
    func GetrecartData()
    {
        let results = GetallRecord()
        if results.count>0
        {
            for result: Any in results
            {
                let data = (result as AnyObject).value(forKey: "added_products")
                let output = NSKeyedUnarchiver.unarchiveObject(with: data as! Data)
                if let dict = output as? NSDictionary
                {
                    logoutCartarr.add(dict)
                    
                }
                
            }
            
        }
    }
    func createHeader()
    {
        headerView = createView( CGRect(x:PADING, y:5,width:(UIScreen.main.bounds.width - 2*PADING) , height:30), borderColor: borderColorMedium, shadow: false)
        headerView.layer.shadowColor = shadowColor.cgColor
        headerView.layer.shadowOpacity = shadowOpacity
        headerView.layer.shadowRadius = shadowRadius
        headerView.layer.shadowOffset = shadowOffset
        self.orderReviewTableView.addSubview(headerView)
        var feildsY = CGFloat()
        feildsY = 5.0
        if let  billing_address = self.orderDic["billing_address"] as? NSArray
        {
            for i in 0 ..< billing_address.count
            {
               let value = billing_address[i]
               let labTitle = createLabel(CGRect(x:10, y:feildsY,width:(headerView.bounds.width - 20) , height:20), text: " ", alignment: .left, textColor: textColorDark)
                labTitle.numberOfLines = 0
                labTitle.lineBreakMode = NSLineBreakMode.byTruncatingTail
                if i == 0
                {
                    labTitle.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                }
                else
                {
                    labTitle.font = UIFont(name: fontName, size: FONTSIZEMedium)
                }
                labTitle.text = "\(value)"
                headerView.addSubview(labTitle)
                labTitle.sizeToFit()
                feildsY = feildsY+labTitle.frame.size.height+10

            }
            
        }
        if let  shipping_address = self.orderDic["shipping_address"] as? NSArray
        {
            feildsY = feildsY+5
            let lineView = UIView(frame: CGRect(x:0, y:feildsY,width:(UIScreen.main.bounds).width, height:1))
            lineView.backgroundColor = aafBgColor
            headerView.addSubview(lineView)
           feildsY = feildsY+10
            for i in 0 ..< shipping_address.count
            {
                let value = shipping_address[i]
                let labTitle = createLabel(CGRect(x:10, y:feildsY,width:(headerView.bounds.width
                    - 20) , height:20), text: " ", alignment: .left, textColor: textColorDark)
                labTitle.numberOfLines = 0
                labTitle.lineBreakMode = NSLineBreakMode.byTruncatingTail
                if i == 0
                {
                    labTitle.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                }
                else
                {
                    labTitle.font = UIFont(name: fontName, size: FONTSIZEMedium)
                }
                labTitle.text = "\(value)"
                headerView.addSubview(labTitle)
                labTitle.sizeToFit()
                feildsY = feildsY+labTitle.frame.size.height+10
                
            }
            
        }
        if let order = self.orderDic["order"] as? NSDictionary
        {
            feildsY = feildsY+5
            let lineView = UIView(frame: CGRect(x:0, y:feildsY,width:(UIScreen.main.bounds).width, height:1))
            lineView.backgroundColor = aafBgColor
            headerView.addSubview(lineView)
            feildsY = feildsY+10
            if let label = order["label"] as? NSString
            {
                let labTitle = createLabel(CGRect(x:10,y:feildsY,width:self.headerView.bounds.size.width-120,height:15), text: "", alignment: .left, textColor: textColorDark)
                labTitle.numberOfLines = 0
                labTitle.lineBreakMode = NSLineBreakMode.byTruncatingTail
                labTitle.textColor = textColorDark
                labTitle.layer.borderColor = navColor.cgColor
                labTitle.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                labTitle.text = "\(label)"
                headerView.addSubview(labTitle)
                feildsY = feildsY+labTitle.frame.size.height+10
            }
            if let OrderDate = order["order_date"] as? NSString
            {
                let labTitle = createLabel(CGRect(x:10,y:feildsY,width:self.headerView.bounds.size.width/3,height:15), text: "", alignment: .left, textColor: textColorMedium)
                labTitle.numberOfLines = 0
                labTitle.lineBreakMode = NSLineBreakMode.byTruncatingTail
                labTitle.textColor = textColorDark
                labTitle.layer.borderColor = navColor.cgColor
                labTitle.font = UIFont(name: fontName, size: FONTSIZENormal)
                labTitle.text = NSLocalizedString("Order Date",  comment: "")
                headerView.addSubview(labTitle)
                
                
                let labTitlevalue = createLabel(CGRect(x:self.headerView.bounds.size.width/3+10, y:feildsY,width:((self.headerView.bounds.size.width/3)*2)-20 , height:20), text: " ", alignment: .left, textColor: textColorDark)
                labTitlevalue.numberOfLines = 0
                labTitlevalue.lineBreakMode = NSLineBreakMode.byTruncatingTail
                labTitlevalue.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                let date = dateDifferenceWithEventTime("\(OrderDate)")
                var DateC = date.components(separatedBy: ",")
                var tempInfo = "\(DateC[1]) \(DateC[0]) \(DateC[2])"
                if DateC.count > 3{
                    tempInfo += " at \(DateC[3])"
                    labTitlevalue.text = "\(tempInfo)"
                }
                
                labTitlevalue.textAlignment = NSTextAlignment.right
                headerView.addSubview(labTitlevalue)
                feildsY = feildsY+labTitlevalue.frame.size.height+10
            }
            if let OrderStatus = order["order_status"] as? NSString
            {
                let labTitle = createLabel(CGRect(x:10,y:feildsY,width:self.headerView.bounds.size.width/3,height:15), text: "", alignment: .left, textColor: textColorMedium)
                labTitle.numberOfLines = 0
                labTitle.lineBreakMode = NSLineBreakMode.byTruncatingTail
                labTitle.textColor = textColorDark
                labTitle.layer.borderColor = navColor.cgColor
                labTitle.font = UIFont(name: fontName, size: FONTSIZENormal)
                labTitle.text = NSLocalizedString("Order Status",  comment: "")
                headerView.addSubview(labTitle)
                
                
                let labTitlevalue = createLabel(CGRect(x:self.headerView.bounds.size.width/3+10, y:feildsY,width:((self.headerView.bounds.size.width/3)*2)-20 , height:20), text: " ", alignment: .left, textColor: textColorDark)
                labTitlevalue.numberOfLines = 0
                labTitlevalue.lineBreakMode = NSLineBreakMode.byTruncatingTail
                labTitlevalue.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                labTitlevalue.text = "\(OrderStatus)"
                labTitlevalue.textAlignment = NSTextAlignment.right
                headerView.addSubview(labTitlevalue)
                feildsY = feildsY+labTitlevalue.frame.size.height+10
            }
            if let TaxAmount = order["tax_amount"] as? Int
            {
                let labTitle = createLabel(CGRect(x:10,y:feildsY,width:self.headerView.bounds.size.width/3,height:15), text: "", alignment: .left, textColor: textColorMedium)
                labTitle.numberOfLines = 0
                labTitle.lineBreakMode = NSLineBreakMode.byTruncatingTail
                labTitle.textColor = textColorDark
                labTitle.layer.borderColor = navColor.cgColor
                labTitle.font = UIFont(name: fontName, size: FONTSIZENormal)
                labTitle.text = NSLocalizedString("Tax Amount",  comment: "")
                headerView.addSubview(labTitle)
                
                
                let labTitlevalue = createLabel(CGRect(x:self.headerView.bounds.size.width/3+10, y:feildsY,width:((self.headerView.bounds.size.width/3)*2)-20 , height:20), text: " ", alignment: .left, textColor: textColorDark)
                labTitlevalue.numberOfLines = 0
                labTitlevalue.lineBreakMode = NSLineBreakMode.byTruncatingTail
                labTitlevalue.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                let value = "\(self.CurrencySymbol)"+"\(TaxAmount)"
                labTitlevalue.text = "\(value)"
                labTitlevalue.textAlignment = NSTextAlignment.right
                headerView.addSubview(labTitlevalue)
                feildsY = feildsY+labTitlevalue.frame.size.height+10
            }
            if let ShippingAmount = order["shipping_amount"] as? Int
            {
                let labTitle = createLabel(CGRect(x:10,y:feildsY,width:self.headerView.bounds.size.width/3,height:15), text: "", alignment: .left, textColor: textColorMedium)
                labTitle.numberOfLines = 0
                labTitle.lineBreakMode = NSLineBreakMode.byTruncatingTail
                labTitle.textColor = textColorDark
                labTitle.layer.borderColor = navColor.cgColor
                labTitle.font = UIFont(name: fontName, size: FONTSIZENormal)
                labTitle.text = NSLocalizedString("Shipping Amount",  comment: "")
                headerView.addSubview(labTitle)
                
                
                let labTitlevalue = createLabel(CGRect(x:self.headerView.bounds.size.width/3+10, y:feildsY,width:((self.headerView.bounds.size.width/3)*2)-20 , height:20), text: " ", alignment: .left, textColor: textColorDark)
                labTitlevalue.numberOfLines = 0
                labTitlevalue.lineBreakMode = NSLineBreakMode.byTruncatingTail
                labTitlevalue.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                let value = "\(self.CurrencySymbol)"+"\(ShippingAmount)"
                labTitlevalue.text = "\(value)"
                labTitlevalue.textAlignment = NSTextAlignment.right
                headerView.addSubview(labTitlevalue)
                feildsY = feildsY+labTitlevalue.frame.size.height+10
            }
            if let DeliveryTime = order["delivery_time"] as? String
            {
                let labTitle = createLabel(CGRect(x:10,y:feildsY,width:self.headerView.bounds.size.width/3,height:15), text: "", alignment: .left, textColor: textColorMedium)
                labTitle.numberOfLines = 0
                labTitle.lineBreakMode = NSLineBreakMode.byTruncatingTail
                labTitle.textColor = textColorDark
                labTitle.layer.borderColor = navColor.cgColor
                labTitle.font = UIFont(name: fontName, size: FONTSIZENormal)
                labTitle.text = NSLocalizedString("Delivery Time",  comment: "")
                headerView.addSubview(labTitle)
                
                
                let labTitlevalue = createLabel(CGRect(x:self.headerView.bounds.size.width/3+10, y:feildsY,width:((self.headerView.bounds.size.width/3)*2)-20 , height:20), text: " ", alignment: .left, textColor: textColorDark)
                labTitlevalue.numberOfLines = 0
                labTitlevalue.lineBreakMode = NSLineBreakMode.byTruncatingTail
                labTitlevalue.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                labTitlevalue.text = "\(DeliveryTime)"
                headerView.addSubview(labTitlevalue)
                labTitlevalue.textAlignment = NSTextAlignment.right
                feildsY = feildsY+labTitlevalue.frame.size.height+10
            }
            if let IPAddress = order["ip_address"] as? String
            {
                let labTitle = createLabel(CGRect(x:10,y:feildsY,width:self.headerView.bounds.size.width/3,height:15), text: "", alignment: .left, textColor: textColorMedium)
                labTitle.numberOfLines = 0
                labTitle.lineBreakMode = NSLineBreakMode.byTruncatingTail
                labTitle.textColor = textColorDark
                labTitle.layer.borderColor = navColor.cgColor
                labTitle.font = UIFont(name: fontName, size: FONTSIZENormal)
                labTitle.text = NSLocalizedString("IP Address",  comment: "")
                headerView.addSubview(labTitle)
                
                
                let labTitlevalue = createLabel(CGRect(x:self.headerView.bounds.size.width/3+10, y:feildsY,width:((self.headerView.bounds.size.width/3)*2)-20 , height:20), text: " ", alignment: .left, textColor: textColorDark)
                labTitlevalue.numberOfLines = 0
                labTitlevalue.lineBreakMode = NSLineBreakMode.byTruncatingTail
                labTitlevalue.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                
                let str = "\(IPAddress)"
                let properString = str.removingPercentEncoding
                labTitlevalue.text = properString
                labTitlevalue.textAlignment = NSTextAlignment.right
                headerView.addSubview(labTitlevalue)
                feildsY = feildsY+labTitlevalue.frame.size.height+10
            }
        }
        if let order = self.orderDic["payment"] as? NSDictionary
        {
            feildsY = feildsY+5
            let lineView = UIView(frame: CGRect(x:0, y:feildsY,width:UIScreen.main.bounds.width, height:1))
            lineView.backgroundColor = aafBgColor
            headerView.addSubview(lineView)
            feildsY = feildsY+10
            if let label = order["label"] as? NSString
            {
                let labTitle = createLabel(CGRect(x:10,y:feildsY,width:self.headerView.bounds.size.width-120,height:15), text: "", alignment: .left, textColor: textColorDark)
                labTitle.numberOfLines = 0
                labTitle.lineBreakMode = NSLineBreakMode.byTruncatingTail
                labTitle.textColor = textColorDark
                labTitle.layer.borderColor = navColor.cgColor
                labTitle.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                labTitle.text = "\(label)"
                headerView.addSubview(labTitle)
                feildsY = feildsY+labTitle.frame.size.height+10
            }
            if let PaymentMethod = order["payment_method"] as? NSString
            {
                let labTitle = createLabel(CGRect(x:10,y:feildsY,width:self.headerView.bounds.size.width/3,height:15), text: "", alignment: .left, textColor: textColorMedium)
                labTitle.numberOfLines = 0
                labTitle.lineBreakMode = NSLineBreakMode.byTruncatingTail
                labTitle.textColor = textColorDark
                labTitle.layer.borderColor = navColor.cgColor
                labTitle.font = UIFont(name: fontName, size: FONTSIZENormal)
                labTitle.text = NSLocalizedString("Payment Method",  comment: "")
                headerView.addSubview(labTitle)
                
                
                let labTitlevalue = createLabel(CGRect(x:self.headerView.bounds.size.width/3+10, y:feildsY,width:((self.headerView.bounds.size.width/3)*2)-20 , height:20), text: " ", alignment: .left, textColor: textColorDark)
                labTitlevalue.numberOfLines = 0
                labTitlevalue.lineBreakMode = NSLineBreakMode.byTruncatingTail
                labTitlevalue.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                labTitlevalue.text = "\(PaymentMethod)"
                labTitlevalue.textAlignment = NSTextAlignment.right
                headerView.addSubview(labTitlevalue)
                feildsY = feildsY+labTitlevalue.frame.size.height+10
            }
            if let chequeno = order["cheque_no"] as? Int
            {
                let labTitle = createLabel(CGRect(x:10,y:feildsY,width:self.headerView.bounds.size.width/3,height:15), text: "", alignment: .left, textColor: textColorMedium)
                labTitle.numberOfLines = 0
                labTitle.lineBreakMode = NSLineBreakMode.byTruncatingTail
                labTitle.textColor = textColorDark
                labTitle.layer.borderColor = navColor.cgColor
                labTitle.font = UIFont(name: fontName, size: FONTSIZENormal)
                labTitle.text = NSLocalizedString("Cheque No",  comment: "")
                headerView.addSubview(labTitle)
                
                
                let labTitlevalue = createLabel(CGRect(x:self.headerView.bounds.size.width/3+10, y:feildsY,width:((self.headerView.bounds.size.width/3)*2)-20 , height:20), text: " ", alignment: .left, textColor: textColorDark)
                labTitlevalue.numberOfLines = 0
                labTitlevalue.lineBreakMode = NSLineBreakMode.byTruncatingTail
                labTitlevalue.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                labTitlevalue.text = "\(chequeno)"
                labTitlevalue.textAlignment = NSTextAlignment.right
                headerView.addSubview(labTitlevalue)
                feildsY = feildsY+labTitlevalue.frame.size.height+10
            }
            if let accountholdername = order["account_holdername"] as? NSString
            {
                let labTitle = createLabel(CGRect(x:10,y:feildsY,width:self.headerView.bounds.size.width/3,height:15), text: "", alignment: .left, textColor: textColorMedium)
                labTitle.numberOfLines = 0
                labTitle.lineBreakMode = NSLineBreakMode.byTruncatingTail
                labTitle.textColor = textColorDark
                labTitle.layer.borderColor = navColor.cgColor
                labTitle.font = UIFont(name: fontName, size: FONTSIZENormal)
                labTitle.text = NSLocalizedString("Account Holder Name",  comment: "")
                headerView.addSubview(labTitle)
                
                
                let labTitlevalue = createLabel(CGRect(x:self.headerView.bounds.size.width/3+10, y:feildsY,width:((self.headerView.bounds.size.width/3)*2)-20 , height:20), text: " ", alignment: .left, textColor: textColorDark)
                labTitlevalue.numberOfLines = 0
                labTitlevalue.lineBreakMode = NSLineBreakMode.byTruncatingTail
                labTitlevalue.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                labTitlevalue.text = "\(accountholdername)"
                labTitlevalue.textAlignment = NSTextAlignment.right
                headerView.addSubview(labTitlevalue)
                feildsY = feildsY+labTitlevalue.frame.size.height+10
            }
            if let accountno = order["account_no"] as? Int
            {
                let labTitle = createLabel(CGRect(x:10,y:feildsY,width:self.headerView.bounds.size.width/3,height:15), text: "", alignment: .left, textColor: textColorMedium)
                labTitle.numberOfLines = 0
                labTitle.lineBreakMode = NSLineBreakMode.byTruncatingTail
                labTitle.textColor = textColorDark
                labTitle.layer.borderColor = navColor.cgColor
                labTitle.font = UIFont(name: fontName, size: FONTSIZENormal)
                labTitle.text = NSLocalizedString("Account Number",  comment: "")
                headerView.addSubview(labTitle)
                
                
                let labTitlevalue = createLabel(CGRect(x:self.headerView.bounds.size.width/3+10, y:feildsY,width:((self.headerView.bounds.size.width/3)*2)-20 , height:20), text: " ", alignment: .left, textColor: textColorDark)
                labTitlevalue.numberOfLines = 0
                labTitlevalue.lineBreakMode = NSLineBreakMode.byTruncatingTail
                labTitlevalue.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                labTitlevalue.text = "\(accountno)"
                labTitlevalue.textAlignment = NSTextAlignment.right
                headerView.addSubview(labTitlevalue)
                feildsY = feildsY+labTitlevalue.frame.size.height+10
            }
            if let rountingnumber = order["rounting_number"] as? Int
            {
                let labTitle = createLabel(CGRect(x:10,y:feildsY,width:self.headerView.bounds.size.width/3,height:15), text: "", alignment: .left, textColor: textColorMedium)
                labTitle.numberOfLines = 0
                labTitle.lineBreakMode = NSLineBreakMode.byTruncatingTail
                labTitle.textColor = textColorDark
                labTitle.layer.borderColor = navColor.cgColor
                labTitle.font = UIFont(name: fontName, size: FONTSIZENormal)
                labTitle.text = NSLocalizedString("Bank Rounting Number",  comment: "")
                headerView.addSubview(labTitle)
                
                
                let labTitlevalue = createLabel(CGRect(x:self.headerView.bounds.size.width/3+10, y:feildsY,width:((self.headerView.bounds.size.width/3)*2)-20 , height:20), text: " ", alignment: .left, textColor: textColorDark)
                labTitlevalue.numberOfLines = 0
                labTitlevalue.lineBreakMode = NSLineBreakMode.byTruncatingTail
                labTitlevalue.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                labTitlevalue.text = "\(rountingnumber)"
                labTitlevalue.textAlignment = NSTextAlignment.right
                headerView.addSubview(labTitlevalue)
                feildsY = feildsY+labTitlevalue.frame.size.height+10
            }

        }
        if let order = self.orderDic["shipping"] as? NSDictionary
        {
            feildsY = feildsY+5
            let lineView = UIView(frame:CGRect(x:0, y:feildsY,width:UIScreen.main.bounds.width,height:1))
            lineView.backgroundColor = aafBgColor
            headerView.addSubview(lineView)
            feildsY = feildsY+10
            if let label = order["label"] as? NSString
            {
                let labTitle = createLabel(CGRect(x:10,y:feildsY,width:self.headerView.bounds.size.width-120,height:15), text: "", alignment: .left, textColor: textColorDark)
                labTitle.numberOfLines = 0
                labTitle.lineBreakMode = NSLineBreakMode.byTruncatingTail
                labTitle.textColor = textColorDark
                labTitle.layer.borderColor = navColor.cgColor
                labTitle.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                labTitle.text = "\(label)"
                headerView.addSubview(labTitle)
                feildsY = feildsY+labTitle.frame.size.height+10
            }
            if let ShippingMethod = order["name"] as? NSString
            {
                let labTitle = createLabel(CGRect(x:10,y:feildsY,width:self.headerView.bounds.size.width/3,height:15), text: "", alignment: .left, textColor: textColorMedium)
                labTitle.numberOfLines = 0
                labTitle.lineBreakMode = NSLineBreakMode.byTruncatingTail
                labTitle.textColor = textColorDark
                labTitle.layer.borderColor = navColor.cgColor
                labTitle.font = UIFont(name: fontName, size: FONTSIZENormal)
                labTitle.text = NSLocalizedString("Shipping Method",  comment: "")
                headerView.addSubview(labTitle)
                
                
                let labTitlevalue = createLabel(CGRect(x:self.headerView.bounds.size.width/3+10, y:feildsY,width:((self.headerView.bounds.size.width/3)*2)-20 , height:20), text: " ", alignment: .left, textColor: textColorDark)
                labTitlevalue.numberOfLines = 0
                labTitlevalue.lineBreakMode = NSLineBreakMode.byTruncatingTail
                labTitlevalue.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                labTitlevalue.text = "\(ShippingMethod)"
                labTitlevalue.textAlignment = NSTextAlignment.right
                headerView.addSubview(labTitlevalue)
                feildsY = feildsY+labTitlevalue.frame.size.height+10
            }
            
        }
        headerView.frame.size.height = feildsY
    }
    // MARK: Submit Form
    @objc func pressedCheckBox(sender : UIButton)
    {
        if sender.isSelected == true
        {
            sender.isSelected = false
            let   profileString = String(format: NSLocalizedString("%@", comment: ""), "\u{f096}")
            sender.setTitle("\(profileString)", for: UIControl.State.normal)
            checkoutDic["is_private_order"] = "0"
        }
        else
        {
            sender.isSelected = true
            let   profileString = String(format: NSLocalizedString("%@", comment: ""), "\u{f046}")
            sender.setTitle("\(profileString)", for: UIControl.State.normal)
            checkoutDic["is_private_order"] = "1"
        }
    }
    
    // Delete product from core data in case of logout user
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
                        }
                        catch _
                        {
                        }
                    }
                }
            }
        }

    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        
    }
    
}
