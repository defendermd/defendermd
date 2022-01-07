//
//  OrderedTicketViewController.swift
//  seiosnativeapp
//
//  Created by Bigstep IOS on 1/10/18.
//  Copyright © 2018 bigstep. All rights reserved.
//

import UIKit

var backtoorder : Int = 0
class OrderedTicketViewController: UIViewController , UIScrollViewDelegate{
    
    var scrollView = UIScrollView()
    var view1 = UIView() // ordered for view with labels
    var label1 = UILabel()
    var label2 = UILabel()
    var label3 = UILabel()
    
    
    var view2 = UIView() // ordered by view with labels
    var label4 = UILabel()
    var label5 = UILabel()
    var label6 = UILabel()
    
    var view3 = UIView() // Payment information view with labels
    var label7 = UILabel()
    var label8 = UILabel()
    var label9 = UILabel()
    var label10 = UILabel()
    var label11 = UILabel()
    var label12 = UILabel()
    var label13 = UILabel()
    var label14 = UILabel()
    var label15 = UILabel()
    var label16 = UILabel()
    var label17 = UILabel()
    var label18 = UILabel()
    var label19 = UILabel()
    var label20 = UILabel()
    var label21 = UILabel()
    var label22 = UILabel()
    var label23 = UILabel()
    
    var view4 = UIView() //  View of order detail with labels
    var view5 = UIView() // Subview of Payment information view with labels
    var tab1 = UILabel()
    var tab2 = UILabel()
    var tab3 = UILabel()
    var tab4 = UILabel()
    var label24 = UILabel()
    
    
    var view6 = UIView() //  View of order Summary with labels
    var label25 = UILabel()
    var label26 = UILabel()
    var label27 = UILabel()
    var label28 = UILabel()
    var label29 = UILabel()
    var label30 = UILabel()
    var label31 = UILabel()
    
    var orderResponse = NSDictionary()
    var navtitle : UILabel!
    
    var orderedid : Int = 487
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = tableViewBgColor
        if let navigationBar = self.navigationController?.navigationBar
        {
            navigationBar.topItem?.title = "Order Id #\(orderedid)"//addSubview(navtitle)
            
            let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            leftNavView.backgroundColor = UIColor.clear
            let tapView = UITapGestureRecognizer(target: self, action: #selector(OrderedTicketViewController.goBack))
            leftNavView.addGestureRecognizer(tapView)
            let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
            backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
            leftNavView.addSubview(backIconImageView)
            
            let barButtonItem = UIBarButtonItem(customView: leftNavView)
            self.navigationItem.leftBarButtonItem = barButtonItem
        }
        
        design()
    }
    
    @objc func goBack(){
        _ = self.navigationController?.popViewController(animated: false)
    }
    
    // Defination of all views with labels
    func design()
    {
        let Padding : CGFloat = 10
        
        scrollView  = UIScrollView(frame: CGRect(x:0,y:0,width:view.bounds.width,height: view.bounds.height))
        scrollView.backgroundColor = tableViewBgColor//UIColor.gray
        scrollView.delegate = self //as? UIScrollViewDelegate
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 4.0
        scrollView.zoomScale = 1.0
        view.addSubview(scrollView)
        
        view1 = UIView(frame:CGRect(x:0,y:0, width:view.bounds.width, height: 70))
        view1.backgroundColor = UIColor.white
        scrollView.addSubview(view1)
        
        label1 = createLabel(CGRect(x:Padding, y:5,width:(view.bounds.width - (2*Padding)) , height:20), text: NSLocalizedString("Ordered For ", comment: ""), alignment: .left, textColor: textColorDark)
        label1.numberOfLines = 0
        label1.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label1.font = UIFont(name: fontName, size: FONTSIZEMedium)
        view1.addSubview(label1)
        
        label2 = createLabel(CGRect(x:Padding, y:getBottomEdgeY(inputView: label1),width:(view.bounds.width - 20) , height:20), text: " ", alignment: .left, textColor: textColorDark)
        label2.numberOfLines = 0
        label2.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label2.font = UIFont(name: fontBold, size: FONTSIZEMedium)
        view1.addSubview(label2)
        
        label3 = createLabel(CGRect(x:Padding, y:getBottomEdgeY(inputView: label2),width:(view.bounds.width - 20) , height:20), text: " ", alignment: .left, textColor: textColorMedium)
        label3.numberOfLines = 0
        label3.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label3.font = UIFont(name: fontName, size: FONTSIZEMedium)
        view1.addSubview(label3)
        
        view2 = UIView(frame:CGRect(x:0,y:getBottomEdgeY(inputView: view1) + 5, width:view.bounds.width, height: 70))
        view2.backgroundColor = UIColor.white
        scrollView.addSubview(view2)
        
        label4 = createLabel(CGRect(x:Padding, y:5,width:(view.bounds.width - (2*Padding)) , height:20), text: NSLocalizedString("Ordered by ", comment: ""), alignment: .left, textColor: textColorDark)
        label4.numberOfLines = 0
        label4.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label4.font = UIFont(name: fontName, size: FONTSIZEMedium)
        view2.addSubview(label4)
        
        label5 = createLabel(CGRect(x:Padding, y:getBottomEdgeY(inputView: label1),width:(view.bounds.width - 20) , height:20), text: " ", alignment: .left, textColor: textColorDark)
        label5.numberOfLines = 0
        label5.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label5.font = UIFont(name: fontBold, size: FONTSIZEMedium)
        view2.addSubview(label5)
        
        label6 = createLabel(CGRect(x:Padding, y:getBottomEdgeY(inputView: label2),width:(view.bounds.width - 20) , height:20), text: " ", alignment: .left, textColor: textColorMedium)
        label6.numberOfLines = 0
        label6.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label6.font = UIFont(name: fontName, size: FONTSIZEMedium)
        view2.addSubview(label6)
        
        view3 = UIView(frame:CGRect(x:0,y:getBottomEdgeY(inputView: view2) + 5, width:view.bounds.width, height: 210))
        view3.backgroundColor = UIColor.white
        scrollView.addSubview(view3)
        
        label7 = createLabel(CGRect(x:Padding, y:5,width:(view.bounds.width - 20) , height:40), text: NSLocalizedString("Payment Information", comment: ""), alignment: .left, textColor: textColorDark)
        label7.numberOfLines = 0
        label7.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label7.font = UIFont(name: fontBold, size: FONTSIZEMedium)
        view3.addSubview(label7)
        
        label8 = createLabel(CGRect(x:Padding, y:getBottomEdgeY(inputView: label7),width:(view.bounds.width - 20)/2 , height:20), text: NSLocalizedString("Payment Method", comment: ""), alignment: .left, textColor: textColorMedium)
        label8.numberOfLines = 0
        label8.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label8.font = UIFont(name: fontName, size: FONTSIZEMedium)
        view3.addSubview(label8)
        
        label9 = createLabel(CGRect(x:getRightEdgeX(inputView: label8) + 5, y:getBottomEdgeY(inputView: label7),width:(view.bounds.width - 20)/2 , height:20), text: " ", alignment: .left, textColor: textColorMedium)
        label9.numberOfLines = 0
        label9.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label9.font = UIFont(name: fontName, size: FONTSIZEMedium)
        view3.addSubview(label9)
        
        label10 = createLabel(CGRect(x:Padding, y:getBottomEdgeY(inputView: label8),width:(view.bounds.width - 20)/2 , height:20), text: NSLocalizedString("Order Date", comment: ""), alignment: .left, textColor: textColorMedium)
        label10.numberOfLines = 0
        label10.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label10.font = UIFont(name: fontName, size: FONTSIZEMedium)
        view3.addSubview(label10)
        
        label11 = createLabel(CGRect(x:getRightEdgeX(inputView: label10) + 5, y:getBottomEdgeY(inputView: label8),width:(view.bounds.width - 20)/2 , height:20), text: " ", alignment: .left, textColor: textColorMedium)
        label11.numberOfLines = 0
        label11.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label11.font = UIFont(name: fontName, size: FONTSIZEMedium)
        view3.addSubview(label11)
        
        label12 = createLabel(CGRect(x:Padding, y:getBottomEdgeY(inputView: label10),width:(view.bounds.width - 20)/2 , height:20), text: NSLocalizedString("Order Status", comment: ""), alignment: .left, textColor: textColorMedium)
        label12.numberOfLines = 0
        label12.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label12.font = UIFont(name: fontName, size: FONTSIZEMedium)
        view3.addSubview(label12)
        
        label13 = createLabel(CGRect(x:getRightEdgeX(inputView: label12) + 5, y:getBottomEdgeY(inputView: label10),width:(view.bounds.width - 20)/2 , height:20), text: " ", alignment: .left, textColor: textColorMedium)
        label13.numberOfLines = 0
        label13.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label13.font = UIFont(name: fontName, size: FONTSIZEMedium)
        view3.addSubview(label13)
        
        label14 = createLabel(CGRect(x:Padding, y:getBottomEdgeY(inputView: label12),width:(view.bounds.width - 20)/2 , height:20), text: NSLocalizedString("Commission Type", comment: ""), alignment: .left, textColor: textColorMedium)
        label14.numberOfLines = 0
        label14.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label14.font = UIFont(name: fontName, size: FONTSIZEMedium)
        view3.addSubview(label14)
        
        label15 = createLabel(CGRect(x:getRightEdgeX(inputView: label14) + 5, y:getBottomEdgeY(inputView: label12),width:(view.bounds.width - 20) , height:20), text: " ", alignment: .left, textColor: textColorMedium)
        label15.numberOfLines = 0
        label15.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label15.font = UIFont(name: fontName, size: FONTSIZEMedium)
        view3.addSubview(label15)
        
        label16 = createLabel(CGRect(x:Padding, y:getBottomEdgeY(inputView: label14),width:(view.bounds.width - 20)/2 , height:20), text: NSLocalizedString("Commission Rate", comment: ""), alignment: .left, textColor: textColorMedium)
        label16.numberOfLines = 0
        label16.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label16.font = UIFont(name: fontName, size: FONTSIZEMedium)
        view3.addSubview(label16)
        
        label17 = createLabel(CGRect(x:getRightEdgeX(inputView: label16) + 5, y:getBottomEdgeY(inputView: label14),width:(view.bounds.width - 20)/2 , height:20), text: " ", alignment: .left, textColor: textColorMedium)
        label17.numberOfLines = 0
        label17.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label17.font = UIFont(name: fontName, size: FONTSIZEMedium)
        view3.addSubview(label17)
        
        label18 = createLabel(CGRect(x:Padding, y:getBottomEdgeY(inputView: label16),width:(view.bounds.width - 20)/2 , height:20), text: NSLocalizedString("Commission Amount", comment: ""), alignment: .left, textColor: textColorMedium)
        label18.numberOfLines = 0
        label18.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label18.font = UIFont(name: fontName, size: FONTSIZEMedium)
        view3.addSubview(label18)
        
        label19 = createLabel(CGRect(x:getRightEdgeX(inputView: label18) + 5, y:getBottomEdgeY(inputView: label16),width:(view.bounds.width - 20) , height:20), text: " ", alignment: .left, textColor: textColorMedium)
        label19.numberOfLines = 0
        label19.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label19.font = UIFont(name: fontName, size: FONTSIZEMedium)
        view3.addSubview(label19)
        
        label20 = createLabel(CGRect(x:Padding, y:getBottomEdgeY(inputView: label18),width:(view.bounds.width - 20)/2 , height:20), text: NSLocalizedString("Tax Amount", comment: ""), alignment: .left, textColor: textColorMedium)
        label20.numberOfLines = 0
        label20.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label20.font = UIFont(name: fontName, size: FONTSIZEMedium)
        view3.addSubview(label20)
        
        label21 = createLabel(CGRect(x:getRightEdgeX(inputView: label20) + 5, y:getBottomEdgeY(inputView: label18),width:(view.bounds.width - 20)/2 , height:20), text: " ", alignment: .left, textColor: textColorMedium)
        label21.numberOfLines = 0
        label21.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label21.font = UIFont(name: fontName, size: FONTSIZEMedium)
        view3.addSubview(label21)
        
        label22 = createLabel(CGRect(x:Padding, y:getBottomEdgeY(inputView: label20),width:(view.bounds.width - 20)/2 , height:20), text: NSLocalizedString("Tax Payer ID No(TIN)", comment: ""), alignment: .left, textColor: textColorMedium)
        label22.numberOfLines = 0
        label22.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label22.font = UIFont(name: fontName, size: FONTSIZEMedium)
        view3.addSubview(label22)
        
        label23 = createLabel(CGRect(x:getRightEdgeX(inputView: label22) + 5, y:getBottomEdgeY(inputView: label20),width:(view.bounds.width - 20)/2 , height:20), text: " ", alignment: .left, textColor: textColorMedium)
        label23.numberOfLines = 0
        label23.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label23.font = UIFont(name: fontName, size: FONTSIZEMedium)
        view3.addSubview(label23)
        
        view4 = UIView(frame:CGRect(x:0,y:getBottomEdgeY(inputView: view3) + 5, width:view.bounds.width, height: 50))
        view4.backgroundColor = UIColor.white
        // view4.isHidden = true
        scrollView.addSubview(view4)
        
        label28 = createLabel(CGRect(x:Padding, y:5,width:(view.bounds.width - 20) , height:40), text: NSLocalizedString("Order Details ", comment: ""), alignment: .left, textColor: textColorDark)
        label28.numberOfLines = 0
        label28.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label28.font = UIFont(name: fontBold, size: FONTSIZEMedium)
        view4.addSubview(label28)
        
        view6 = UIView(frame:CGRect(x:0,y:getBottomEdgeY(inputView: view4) + 5, width:view.bounds.width, height: 110))
        view6.backgroundColor = UIColor.white
        scrollView.addSubview(view6)
        
        label24 = createLabel(CGRect(x:Padding, y:5,width:(view.bounds.width - 20) , height:40), text: NSLocalizedString("Order Summery ", comment: ""), alignment: .left, textColor: textColorDark)
        label24.numberOfLines = 0
        label24.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label24.font = UIFont(name: fontBold, size: FONTSIZEMedium)
        view6.addSubview(label24)
        
        let width1:CGFloat = 60
        
        label25 = createLabel(CGRect(x:Padding, y:getBottomEdgeY(inputView: label24),width:(view.bounds.width - 20)/2 - width1, height:20), text: "Subtotal ", alignment: .left, textColor: textColorMedium)
        label25.numberOfLines = 0
        label25.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label25.font = UIFont(name: fontName, size: FONTSIZEMedium)
        view6.addSubview(label25)
        
        label26 = createLabel(CGRect(x:Padding, y:getBottomEdgeY(inputView: label25),width:(view.bounds.width - 20)/2 - width1 , height:20), text: "Tax ", alignment: .left, textColor: textColorMedium)
        label26.numberOfLines = 0
        label26.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label26.font = UIFont(name: fontName, size: FONTSIZEMedium)
        view6.addSubview(label26)
        
        label27 = createLabel(CGRect(x:Padding, y:getBottomEdgeY(inputView: label26),width:(view.bounds.width - 20)/2 - width1 , height:20), text: "Grand Total ", alignment: .left, textColor: textColorDark)
        label27.numberOfLines = 0
        label27.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label27.font = UIFont(name: fontBold, size: FONTSIZEMedium)
        view6.addSubview(label27)
        
        
        label29 = createLabel(CGRect(x:getRightEdgeX(inputView: label25), y:getBottomEdgeY(inputView: label24),width:(view.bounds.width - 20)/2 - width1 , height:20), text: " ", alignment: .left, textColor: textColorMedium)
        label29.numberOfLines = 0
        label29.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label29.font = UIFont(name: fontName, size: FONTSIZEMedium)
        view6.addSubview(label29)
        
        label30 = createLabel(CGRect(x:getRightEdgeX(inputView: label26), y:getBottomEdgeY(inputView: label25),width:(view.bounds.width - 20)/2 - width1 , height:20), text: "", alignment: .left, textColor: textColorMedium)
        label30.numberOfLines = 0
        label30.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label30.font = UIFont(name: fontName, size: FONTSIZEMedium)
        view6.addSubview(label30)
        
        label31 = createLabel(CGRect(x:getRightEdgeX(inputView: label27), y:getBottomEdgeY(inputView: label26),width:(view.bounds.width - 20)/2 - width1 , height:20), text: "", alignment: .left, textColor: textColorDark)
        label31.numberOfLines = 0
        label31.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label31.font = UIFont(name: fontBold, size: FONTSIZEMedium)
        view6.addSubview(label31)
        
        
        scrollView.isHidden = true
        scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: getBottomEdgeY(inputView: view6))
 
        browseEntries()
    }
    
    //For order detail
    func ordredetail()
    {
        let bodydata = self.orderResponse
        
        
        view5 = UIView(frame:CGRect(x:10,y:getBottomEdgeY(inputView: label28) + 5, width:view.bounds.width - 20, height: 20))
        view5.backgroundColor = tableViewBgColor
        view4.addSubview(view5)
        
        tab1 = createLabel(CGRect(x:0, y:0,width:(view5.bounds.width - 20)/4 + 10, height:40), text: NSLocalizedString("Ticket", comment: ""), alignment: .center, textColor: textColorDark)
        tab1.numberOfLines = 0
        tab1.lineBreakMode = NSLineBreakMode.byTruncatingTail
        tab1.font = UIFont(name: fontBold, size: FONTSIZEMedium)
        view5.addSubview(tab1)
        
        tab2 = createLabel(CGRect(x:getRightEdgeX(inputView: tab1), y:0,width:(view5.bounds.width - 20)/4 , height:40), text: NSLocalizedString("Price", comment: ""), alignment: .center, textColor: textColorDark)
        tab2.numberOfLines = 0
        tab2.lineBreakMode = NSLineBreakMode.byTruncatingTail
        tab2.font = UIFont(name: fontBold, size: FONTSIZEMedium)
        view5.addSubview(tab2)
        
        tab3 = createLabel(CGRect(x:getRightEdgeX(inputView: tab2), y:0,width:(view5.bounds.width - 20)/4 , height:40), text: NSLocalizedString("Quantity", comment: ""), alignment: .center, textColor: textColorDark)
        tab3.numberOfLines = 0
        tab3.lineBreakMode = NSLineBreakMode.byTruncatingTail
        tab3.font = UIFont(name: fontBold, size: FONTSIZEMedium)
        view5.addSubview(tab3)
        
        tab4 = createLabel(CGRect(x:getRightEdgeX(inputView: tab3), y:0,width:(view5.bounds.width - 20)/4 - 10, height:40), text: NSLocalizedString("Subtotal", comment: ""), alignment: .center, textColor: textColorDark)
        tab4.numberOfLines = 0
        tab4.lineBreakMode = NSLineBreakMode.byTruncatingTail
        tab4.font = UIFont(name: fontBold, size: FONTSIZEMedium)
        view5.addSubview(tab4)
        
        var dynheight:CGFloat = getBottomEdgeY(inputView: tab1)
        if let data = bodydata["tickets"] as? NSArray
        {
            for i in stride(from: 0, to: data.count, by: 1){
                if let dic = data[i] as? NSDictionary{
                    
                    let padding :CGFloat = 5
                    
                    let tab1 = createLabel(CGRect(x:padding, y:dynheight + 2,width:(view5.bounds.width - 20)/4 + 10, height:40), text: "\(String(describing: dic["title"]!))", alignment: .center, textColor: textColorDark)
                    tab1.numberOfLines = 2
                    tab1.lineBreakMode = NSLineBreakMode.byTruncatingTail
                    tab1.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                    tab1.backgroundColor = UIColor.white
                    view5.addSubview(tab1)
                    
                    //                        let price = dic["price"] as? CGFloat
                    let tab2 = createLabel(CGRect(x:getRightEdgeX(inputView: tab1), y:dynheight + 2,width:(view5.bounds.width - 20)/4, height:40), text: "", alignment: .center, textColor: textColorDark)
                    if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
                        let defaults = UserDefaults.standard
                        if let name = defaults.object(forKey: "Currency")
                        {
                            let changePrice = (defaults.object(forKey: "PriceRate") as! Float) * Float(truncating: (dic["price"]! as AnyObject) as! NSNumber)
                            let showPrice = (String(format:"%.2f", changePrice))
                            
                            tab2.text =  "\(getCurrencySymbol(name as! String)) \(showPrice)"
                            
                        }
                    }
                    else{
                       tab2.text = "$\(dic["price"]!)"
                    }
                    tab2.numberOfLines = 2
                    tab2.lineBreakMode = NSLineBreakMode.byTruncatingTail
                    tab2.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                    tab2.backgroundColor = UIColor.white
                    view5.addSubview(tab2)
                    
                    let tab3 = createLabel(CGRect(x:getRightEdgeX(inputView: tab2), y:dynheight + 2,width:(view5.bounds.width - 20)/4, height:40), text: "\(String(describing: dic["quantity"]!))", alignment: .center, textColor: textColorDark)
                    tab3.numberOfLines = 2
                    tab3.lineBreakMode = NSLineBreakMode.byTruncatingTail
                    tab3.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                    tab3.backgroundColor = UIColor.white
                    view5.addSubview(tab3)
                    
                    
                    let tab4 = createLabel(CGRect(x:getRightEdgeX(inputView: tab3), y:dynheight + 2,width:(view5.bounds.width - 20)/4 , height:40), text:"", alignment: .center, textColor: textColorDark)
                    if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
                        let defaults = UserDefaults.standard
                        if let name = defaults.object(forKey: "Currency")
                        {
                            let changePrice = (defaults.object(forKey: "PriceRate") as! Float) * Float(truncating: (dic["subTotal"]! as AnyObject) as! NSNumber)
                            let showPrice = (String(format:"%.2f", changePrice))
                            
                            tab4.text =  "\(getCurrencySymbol(name as! String)) \(showPrice)"
                            
                        }
                    }
                    else{
                        tab4.text = "$\(dic["subTotal"]!)"
                    }
                    tab4.numberOfLines = 2
                    tab4.lineBreakMode = NSLineBreakMode.byTruncatingTail
                    tab4.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                    tab4.backgroundColor = UIColor.white
                    view5.addSubview(tab4)
                    
                    dynheight += 40 + 2
                }
            }
        }
        view5.frame.size.height += view5.frame.size.height + (dynheight - 38)
        view4.frame.size.height += view5.frame.size.height + 10
        view6.frame.origin.y += view5.frame.size.height + 10
        label24.frame.origin.y =  5
        label25.frame.origin.y = getBottomEdgeY(inputView: label24)
        label26.frame.origin.y = getBottomEdgeY(inputView: label25)
        label27.frame.origin.y = getBottomEdgeY(inputView: label26)
        label29.frame.origin.y = getBottomEdgeY(inputView: label24)
        label30.frame.origin.y = getBottomEdgeY(inputView: label25)
        label31.frame.origin.y = getBottomEdgeY(inputView: label26)
        scrollView.contentSize.height = getBottomEdgeY(inputView: view6) + 20
        scrollView.addSubview(view6)
    }
    
    // Filled data of all labels with values
    func data()
    {
        let bodydata = self.orderResponse
        self.ordredetail()
        if bodydata["event_title"] != nil
        {
            label2.text = bodydata["event_title"] as? String
        }
        
        if bodydata["creation_date"] != nil
        {
            var tempInfo = ""
            let postedDate = bodydata["occurrence_starttime"] as? String
            let date = dateDifferenceWithEventTime(postedDate!)
            var DateC = date.components(separatedBy: ", ")
            tempInfo += "\(DateC[1]) \(DateC[0]) \(DateC[2])"
            if DateC.count > 3{
                tempInfo += " at \(DateC[3])"
            }
            
            var tempInfo1 = ""
            let postedDate1 = bodydata["occurrence_endtime"] as? String
            let date1 = dateDifferenceWithEventTime(postedDate1!)
            var DateC1 = date1.components(separatedBy: ", ")
            tempInfo1 += "\(DateC1[1]) \(DateC1[0]) \(DateC1[2])"
            if DateC1.count > 3{
                tempInfo1 += " at \(DateC1[3])"
            }
            
            label3.text = "\(tempInfo) - \(tempInfo1)"
        }
        
        if bodydata["user_title"] != nil
        {
            label5.text = bodydata["user_title"] as? String
        }
        
        if bodydata["user_email"] != nil
        {
            label6.text = bodydata["user_email"] as? String
        }
        
        if bodydata["payment_method"] != nil
        {
            label9.text = ": \((bodydata["payment_method"] as? String)!)"
        }
        
        if bodydata["creation_date"] != nil
        {
            var tempInfo = ""
            let postedDate = bodydata["creation_date"] as? String
            let date = dateDifferenceWithEventTime(postedDate!)
            var DateC = date.components(separatedBy: ", ")
            tempInfo += "\(DateC[1]) \(DateC[0]) \(DateC[2])"
            if DateC.count > 3{
                tempInfo += " at \(DateC[3])"
            }
            
            label11.text = ": \(tempInfo)"
        }
        
        if bodydata["order_status_text"] != nil
        {
            label13.text = ": \((bodydata["order_status_text"] as? String)!)"
        }
        
        if bodydata["commission_type"] != nil
        {
            label15.text = ": \((bodydata["commission_type"] as? String)!)"
        }
        
        if bodydata["commission_rate"] != nil
        {
            label17.text = ": \((bodydata["commission_rate"] as? String)!)"
        }
        
        if bodydata["commission_value"] != nil
        {
            label19.text = ": \((bodydata["commission_value"] as? CGFloat)!)"
        }
        
        if bodydata["tax_amount"] != nil
        {
            if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
                let defaults = UserDefaults.standard
                if let name = defaults.object(forKey: "Currency")
                {
                    let changePrice = (defaults.object(forKey: "PriceRate") as! Float) * Float(truncating: (bodydata["tax_amount"] as AnyObject) as! NSNumber)
                    let showPrice = (String(format:"%.2f", changePrice))
                    
                    label21.text =  "\(getCurrencySymbol(name as! String)) \(showPrice)"
                    
                }
            }
            else{
                label21.text = ": $\((bodydata["tax_amount"] as? CGFloat)!)"
            }
            
            if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
                let defaults = UserDefaults.standard
                if let name = defaults.object(forKey: "Currency")
                {
                    let changePrice = (defaults.object(forKey: "PriceRate") as! Float) * Float(truncating: (bodydata["tax_amount"] as AnyObject) as! NSNumber)
                    let showPrice = (String(format:"%.2f", changePrice))
                    
                    label30.text =  "\(getCurrencySymbol(name as! String)) \(showPrice)"
                    
                }
            }
            else{
                label30.text = " : $\((bodydata["tax_amount"] as? CGFloat)!)"
            }
            
            
        }
        
        
        if bodydata["tax_id_no"] != nil
        {
            label23.text = ": \((bodydata["tax_id_no"] as? Int)!)"
            label22.isHidden = false
        }
        else
        {
            label22.isHidden = true
        }
        
        if bodydata["sub_total"] != nil
        {
            if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
                let defaults = UserDefaults.standard
                if let name = defaults.object(forKey: "Currency")
                {
                    let changePrice = (defaults.object(forKey: "PriceRate") as! Float) * Float(truncating: (bodydata["sub_total"] as AnyObject) as! NSNumber)
                    let showPrice = (String(format:"%.2f", changePrice))
                    
                    label29.text =  "\(getCurrencySymbol(name as! String)) \(showPrice)"
                    
                }
            }
            else{
            label29.text = " : $\((bodydata["sub_total"] as? CGFloat)!)"
            }
        }
        
        if bodydata["grand_total"] != nil
        {
            if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
                let defaults = UserDefaults.standard
                if let name = defaults.object(forKey: "Currency")
                {
                    let changePrice = (defaults.object(forKey: "PriceRate") as! Float) * Float(truncating: (bodydata["grand_total"] as AnyObject) as! NSNumber)
                    let showPrice = (String(format:"%.2f", changePrice))
                    
                    label31.text =  "\(getCurrencySymbol(name as! String)) \(showPrice)"
                    
                }
            }
            else{
            label31.text = " : $\((bodydata["grand_total"] as? CGFloat)!)"
            }
        }
    }
    
    // Get response from api
    func browseEntries(){
        
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork()
        {
            
            // Reset Objects
            for ob in view.subviews{
                if ob.tag == 1000{
                    ob.removeFromSuperview()
                }
            }
            
            let parameters = ["order_id":"\(orderedid)"]
            let path = "advancedeventtickets/order/view"
            
            
//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            
            // Send Server Request to Browse Blog Entries
            post(parameters, url: path, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    
                    activityIndicatorView.stopAnimating()
                    if msg{
                        
                        self.scrollView.isHidden = false
                        
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                        }
                        
                        if let response = succeeded["body"] as? NSDictionary
                        {
                            
                            self.orderResponse = response
                            self.data()
                        }
                    }
                    else
                    {
                        
                        // Handle Server Error
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
