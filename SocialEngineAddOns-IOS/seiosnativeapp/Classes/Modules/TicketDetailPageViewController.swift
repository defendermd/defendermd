//
//  TicketDetailPageViewController.swift
//  seiosnativeapp
//
//  Created by Bigstep IOS on 1/11/18.
//  Copyright © 2018 bigstep. All rights reserved.
//

import UIKit

class TicketDetailPageViewController: UIViewController , UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate{
    
    var eventtitle : String = ""
    var locationtitle : String = ""
    var startdatetitle : String = ""
    var enddatetitle : String = ""
    var eventid : Int = 0
    var status : String = ""
    
    var scrollView = UIScrollView()
    var view1 = UIView() // Event information view with labels
    var label1 = UILabel()
    var label2 = UILabel()
    var label3 = UILabel()
    
    var view2 = UIView() // View for occurance dates
    
    var view3 = UIView() // View for ticket information
    var view4 = UIView() // Subview for ticket information
    var tab1 = UILabel()
    var tab2 = UILabel()
    var tab3 = UILabel()
    
    var view5 = UIView() // Coupon and order summary view with labels
    var label6 = UILabel()
    var coupontextfield = UITextField()
    var couponButton = UIButton()
    var label24 = UILabel()
    var label25 = UILabel()
    var label26 = UILabel()
    var label27 = UILabel()
    
    var label28 = UILabel()
    var label29 = UILabel()
    var label30 = UILabel()
    var label31 = UILabel()
    var BooknowButton = UIButton()
    
    var filterButton = UIButton() // occurence date button
    var filterButton1 = UIButton() // occurence date button
    
    var dateTableView:UITableView!
    var quantityTableView:UITableView!
    
    var orderResponse = NSDictionary()
    var datearray = [AnyObject]() // Store occurance date array
    var ticketMax :Int = 0
    
    var blackScreen = UIView()
    var couponDetailView = CouponDetailView()
    
    var navtitle : UILabel!
    var keyBoardHeight1 :  CGFloat = 0
    var tapGesture = UITapGestureRecognizer()
    var button = UIButton()
    
    var canShowBookNow : Int  = 0 // For check alteast 1 ticket is selected or not
    var tagg : Int = 0 // Store more info button tag
    var discount : CGFloat = 0.0
    var tax : CGFloat = 0.0
    var parameters = [String:String]()
    var subtotal : CGFloat = 0.0
    
    var couponarray = [AnyObject]()
    var info : String = ""
    var count : Int = 0
    var k : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.removeFromSuperview()
        if let navigationBar = self.navigationController?.navigationBar
        {
            let firstFrame = CGRect(x: (view.frame.width/3), y:5, width: view.frame.width/3, height: navigationBar.frame.height - 10)
            navtitle = UILabel(frame: firstFrame)
            navtitle.textAlignment = .center
            navtitle.font = UIFont(name: fontBold, size: FONTSIZELarge)
            navtitle.textColor = textColorPrime
            navtitle.text = NSLocalizedString("Tickets", comment: "")
            navtitle.tag = 400
            
            navigationBar.addSubview(navtitle)
            
            let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            leftNavView.backgroundColor = UIColor.clear
            let tapView = UITapGestureRecognizer(target: self, action: #selector(TicketDetailPageViewController.goBack))
            leftNavView.addGestureRecognizer(tapView)
            let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
            backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
            leftNavView.addSubview(backIconImageView)
            
            let barButtonItem = UIBarButtonItem(customView: leftNavView)
            self.navigationItem.leftBarButtonItem = barButtonItem
        }
        
        //Notification for showing/Hiding keyboard
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(TicketDetailPageViewController.keyboardWasShown),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(TicketDetailPageViewController.keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        
        // For resign keyboard on click on view anywhere
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(TicketDetailPageViewController.resignKeyboard))
        tapGesture.delegate = self
        tapGesture.cancelsTouchesInView = false;
        view.addGestureRecognizer(tapGesture)
        
        view.backgroundColor = bgColor
        
        blackScreen = UIView(frame: view.frame)
        blackScreen.backgroundColor = UIColor.black
        blackScreen.alpha = 0.0
        browseEntries()
        design()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool{
        
        if (touch.view == coupontextfield) {
            return false
            
        }
        resignKeyboard()
        return true // handle the touch
    }
    
    @objc func resignKeyboard(){
        //        scrollView.endEditing(true)
        coupontextfield.resignFirstResponder()
    }
    
    @objc func keyboardWasShown(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        keyBoardHeight1 = keyboardFrame.size.height
        // Animation On TextView Begin Editing
        UIView.animate(withDuration: 0.5, animations: {
            self.scrollView.frame.origin.y -= (self.keyBoardHeight1)
        })
    }
    
    
    @objc func keyboardWillHide(sender: NSNotification)
    {
        UIView.animate(withDuration: 0.5, animations: {
            self.scrollView.frame.origin.y += (self.keyBoardHeight1)
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true;
        
    }
    
    @objc func goBack(){
        navtitle.text = ""
        _ = self.navigationController?.popViewController(animated: false)
    }
    
    // Definations of all views and labels
    func design()
    {
        let Padding : CGFloat = 10
        let spacePadding : CGFloat = 5
        let ViewspacePadding : CGFloat = 0
        
        scrollView  = UIScrollView(frame: CGRect(x:0,y:TOPPADING,width:view.bounds.width,height: view.bounds.height - (TOPPADING + tabBarHeight)))
        scrollView.backgroundColor = tableViewBgColor
        scrollView.delegate = self //as? UIScrollViewDelegate
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 4.0
        scrollView.zoomScale = 1.0
        scrollView.isScrollEnabled = true
        view.addSubview(scrollView)
        
        view1 = UIView(frame:CGRect(x:0,y:0, width:view.bounds.width, height: 90))
        view1.backgroundColor = UIColor.white
        scrollView.addSubview(view1)
        
        label1 = createLabel(CGRect(x:Padding, y:spacePadding,width:(view.bounds.width - (2*Padding)) , height:30), text: eventtitle, alignment: .left, textColor: textColorDark)
        label1.numberOfLines = 0
        label1.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label1.font = UIFont(name: fontBold, size: FONTSIZELarge)
        view1.addSubview(label1)
        
        label2 = createLabel(CGRect(x:Padding, y:getBottomEdgeY(inputView: label1) + spacePadding,width:(view.bounds.width - 20) , height:20), text: locationtitle, alignment: .left, textColor: textColorMedium)
        label2.numberOfLines = 0
        label2.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label2.font = UIFont(name: fontBold, size: FONTSIZEMedium)
        view1.addSubview(label2)
        
        var tempInfo = ""
        let postedDate = startdatetitle
        let date = dateDifferenceWithEventTime(postedDate)
        var DateC = date.components(separatedBy: ", ")
        tempInfo += "\(DateC[1]) \(DateC[0]) \(DateC[2])"
        if DateC.count > 3{
            tempInfo += " at \(DateC[3])"
        }
        
        var tempInfo1 = ""
        let postedDate1 = enddatetitle
        let date1 = dateDifferenceWithEventTime(postedDate1)
        var DateC1 = date1.components(separatedBy: ", ")
        tempInfo1 += "\(DateC1[1]) \(DateC1[0]) \(DateC1[2])"
        if DateC1.count > 3{
            tempInfo1 += " at \(DateC1[3])"
        }
        
        label3 = createLabel(CGRect(x:Padding, y:getBottomEdgeY(inputView: label2) + spacePadding,width:(view.bounds.width - 20) , height:20), text: "\(tempInfo) - \(tempInfo1)", alignment: .left, textColor: textColorMedium)
        label3.numberOfLines = 0
        label3.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label3.font = UIFont(name: fontName, size: FONTSIZEMedium)
        view1.addSubview(label3)
        
        view2 = UIView(frame:CGRect(x:0,y:getBottomEdgeY(inputView: view1) + ViewspacePadding, width:view.bounds.width, height: 50))
        view2.backgroundColor = UIColor.white
        scrollView.addSubview(view2)
        
        filterButton = createButton(CGRect(x: Padding, y: 5, width: view.bounds.width - (30 + 2 * Padding), height: 40),title:NSLocalizedString("Occurance Dates", comment: "") , border: true, bgColor: false,textColor: textColorDark)
        filterButton.backgroundColor = UIColor.white
        filterButton.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
        filterButton.layer.cornerRadius = cornerRadiusNormal
        view2.addSubview(filterButton)
        
        filterButton1 = createButton(CGRect(x: getRightEdgeX(inputView: filterButton), y: 5, width: 30, height: 40),title:"\(searchFilterIcon)" , border: true, bgColor: false,textColor: textColorDark)
        filterButton1.backgroundColor = UIColor.white
        filterButton1.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZELarge)
        filterButton1.layer.cornerRadius = cornerRadiusNormal
        view2.addSubview(filterButton1)
        
        filterButton.addTarget(self, action: #selector(filterClick), for: .touchUpInside)
        filterButton1.addTarget(self, action: #selector(filterClick), for: .touchUpInside)
        
        view3 = UIView(frame:CGRect(x:0,y:getBottomEdgeY(inputView: view2) + ViewspacePadding, width:view.bounds.width, height: 10))
        view3.clipsToBounds = true
        view3.backgroundColor = UIColor.white
        scrollView.addSubview(view3)
        
        view5 = UIView(frame:CGRect(x:0,y:getBottomEdgeY(inputView: view3) + ViewspacePadding, width:view.bounds.width, height: 265))
        view5.backgroundColor = UIColor.white
        scrollView.addSubview(view5)
        
        label6 = createLabel(CGRect(x:Padding, y:0,width:(view.bounds.width - 20) , height:40), text: NSLocalizedString("Have Coupon ?", comment: ""), alignment: .left, textColor: textColorDark)
        label6.numberOfLines = 0
        label6.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label6.font = UIFont(name: fontBold, size: FONTSIZEMedium)
        view5.addSubview(label6)
        
        coupontextfield = createTextField(CGRect(x: Padding, y: getBottomEdgeY(inputView: label6), width: (view.bounds.width)/2, height: 50), borderColor: borderColorDark , placeHolderText:  NSLocalizedString("Enter your coupon code here...",  comment: ""), corner: false)
        coupontextfield.font =  UIFont(name: fontName, size: FONTSIZESmall)
        coupontextfield.backgroundColor = UIColor.white
        coupontextfield.delegate = self
        view5.addSubview(coupontextfield)
        
        couponButton = createButton(CGRect(x: getRightEdgeX(inputView: coupontextfield) + 10, y: getBottomEdgeY(inputView: label6), width: (view.bounds.width )/2 - (2 * Padding + 35), height: 50), title: NSLocalizedString("Apply Coupon",  comment: ""), border: false, bgColor: true, textColor: UIColor.white)
        couponButton.backgroundColor = buttonColor
        couponButton.titleLabel?.font = UIFont(name: fontName, size: FONTSIZELarge)
        couponButton.layer.cornerRadius = cornerRadiusNormal
        couponButton.addTarget(self, action: #selector(applyCopon), for: UIControl.Event.touchUpInside)
        view5.addSubview(couponButton)
        
        let width1:CGFloat = 60
        
        label24 = createLabel(CGRect(x:Padding, y:getBottomEdgeY(inputView: couponButton) + 10,width:(view.bounds.width - 20)/2 - width1, height:20), text: NSLocalizedString("subTotal ", comment: ""), alignment: .left, textColor: textColorMedium)
        label24.numberOfLines = 0
        label24.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label24.font = UIFont(name: fontName, size: FONTSIZEMedium)
        view5.addSubview(label24)
        
        label25 = createLabel(CGRect(x:Padding, y:getBottomEdgeY(inputView: label24) + 5,width:(view.bounds.width - 20)/2 - width1, height:20), text: NSLocalizedString("Discount ", comment: ""), alignment: .left, textColor: textColorMedium)
        label25.numberOfLines = 0
        label25.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label25.font = UIFont(name: fontName, size: FONTSIZEMedium)
        view5.addSubview(label25)
        
        label26 = createLabel(CGRect(x:Padding, y:getBottomEdgeY(inputView: label25) + 5,width:(view.bounds.width - 20)/2 - width1, height:20), text: "", alignment: .left, textColor: textColorMedium)
        label26.numberOfLines = 0
        label26.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label26.font = UIFont(name: fontName, size: FONTSIZEMedium)
        view5.addSubview(label26)
        
        label27 = createLabel(CGRect(x:Padding, y:getBottomEdgeY(inputView: label26) + 5,width:(view.bounds.width - 20)/2 - width1, height:20), text: NSLocalizedString("Grand Total ", comment: ""), alignment: .left, textColor: textColorDark)
        label27.numberOfLines = 0
        label27.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label27.font = UIFont(name: fontBold, size: FONTSIZEMedium)
        view5.addSubview(label27)
        
        label28 = createLabel(CGRect(x:getRightEdgeX(inputView: label27), y:getBottomEdgeY(inputView: couponButton) + 10,width:(view.bounds.width - 20) , height:20), text: NSLocalizedString(" ", comment: ""), alignment: .left, textColor: textColorMedium)
        label28.numberOfLines = 0
        label28.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label28.font = UIFont(name: fontName, size: FONTSIZEMedium)
        view5.addSubview(label28)
        
        label29 = createLabel(CGRect(x:getRightEdgeX(inputView: label27), y:getBottomEdgeY(inputView: label24) + 5,width:(view.bounds.width - 20) , height:20), text: " ", alignment: .left, textColor: textColorMedium)
        label29.numberOfLines = 0
        label29.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label29.font = UIFont(name: fontName, size: FONTSIZEMedium)
        view5.addSubview(label29)
        
        label30 = createLabel(CGRect(x:getRightEdgeX(inputView: label27), y:getBottomEdgeY(inputView: label25) + 5,width:(view.bounds.width - 20) , height:20), text: "", alignment: .left, textColor: textColorMedium)
        label30.numberOfLines = 0
        label30.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label30.font = UIFont(name: fontName, size: FONTSIZEMedium)
        view5.addSubview(label30)
        
        label31 = createLabel(CGRect(x:getRightEdgeX(inputView: label27), y:getBottomEdgeY(inputView: label26) + 5,width:(view.bounds.width - 20) , height:20), text: "", alignment: .left, textColor: textColorDark)
        label31.numberOfLines = 0
        label31.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label31.font = UIFont(name: fontBold, size: FONTSIZEMedium)
        view5.addSubview(label31)
        
        BooknowButton = createButton(CGRect(x: Padding, y: getBottomEdgeY(inputView: label27) + 7, width: (view.bounds.width )/2 - (2 * Padding + 20), height: 50), title: NSLocalizedString("Book Now",  comment: ""), border: false, bgColor: true, textColor: UIColor.white)
        BooknowButton.backgroundColor = buttonColor
        BooknowButton.layer.cornerRadius = cornerRadiusNormal
        BooknowButton.titleLabel?.font = UIFont(name: fontName, size: FONTSIZELarge)
        if status != "Event is Full"
        {
            BooknowButton.addTarget(self, action: #selector(booknow), for: UIControl.Event.touchUpInside)
        }
        else
        {
            BooknowButton.setTitle("Event is Full", for: UIControl.State.normal)
        }
        
        view5.addSubview(BooknowButton)
        
        self.dateTable()
        
        scrollView.isHidden = true
        scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: getBottomEdgeY(inputView: view5))
    }
    
    // Subview for ticket information
    func ordertable()
    {
        view4 = UIView(frame:CGRect(x:10,y:0 + 5, width:view.bounds.width - 20, height: 40))
        view4.backgroundColor = tableViewBgColor//UIColor.gray
        //  view5.isHidden = true
        view3.addSubview(view4)
        view3.addSubview(quantityTableView)
        
        let height2:CGFloat = 40
        
        tab1 = createLabel(CGRect(x:5, y:0,width:(view4.bounds.width - 20)/3 + 10, height:height2), text: NSLocalizedString("Ticket Name", comment: ""), alignment: .center, textColor: textColorDark)
        tab1.numberOfLines = 0
        tab1.lineBreakMode = NSLineBreakMode.byTruncatingTail
        tab1.font = UIFont(name: fontBold, size: FONTSIZEMedium)
        view4.addSubview(tab1)
        
        tab2 = createLabel(CGRect(x:getRightEdgeX(inputView: tab1), y:0,width:(view4.bounds.width - 20)/3 , height:height2), text: NSLocalizedString("Price", comment: ""), alignment: .center, textColor: textColorDark)
        tab2.numberOfLines = 0
        tab2.lineBreakMode = NSLineBreakMode.byTruncatingTail
        tab2.font = UIFont(name: fontBold, size: FONTSIZEMedium)
        view4.addSubview(tab2)
        
        tab3 = createLabel(CGRect(x:getRightEdgeX(inputView: tab2), y:0,width:(view4.bounds.width - 20)/3 , height:height2), text: NSLocalizedString("Quantity", comment: ""), alignment: .center, textColor: textColorDark)
        tab3.numberOfLines = 0
        tab3.lineBreakMode = NSLineBreakMode.byTruncatingTail
        tab3.font = UIFont(name: fontBold, size: FONTSIZEMedium)
        view4.addSubview(tab3)
        
        var dynheight:CGFloat = getBottomEdgeY(inputView: tab1)
        if let data = orderResponse["tickets"] as? NSArray
        {
            for i in stride(from: 0, to: data.count, by: 1){
                if let dic = data[i] as? NSDictionary{
                    
                    let padding :CGFloat = 5
                    let height1 :CGFloat = 20
                    
                    let tab1 = createLabel(CGRect(x:padding, y:dynheight + 2,width:(view4.bounds.width - 20)/3 + 10, height:30), text: "\(String(describing: dic["title"]!))", alignment: .center, textColor: textColorMedium)
                    tab1.numberOfLines = 2
                    tab1.lineBreakMode = NSLineBreakMode.byTruncatingTail
                    tab1.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                    tab1.backgroundColor = UIColor.white
                    view4.addSubview(tab1)
                    
                    let info = createButton(CGRect(x: padding, y: getBottomEdgeY(inputView: tab1), width: (view4.bounds.width - 20)/3 + 10, height: 30), title: NSLocalizedString("More Info",  comment: ""), border: false, bgColor: true, textColor: buttonColor)
                    info.backgroundColor = UIColor.white
                    info.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
                    info.tag = i
                    info.addTarget(self, action: #selector(clickonMoreinfo(_ : )), for: UIControl.Event.touchUpInside)
                    view4.addSubview(info)
                    
                    //                    let price = Stirng(dic["price"] as? CGFloat)
                    let tab2 = createLabel(CGRect(x:getRightEdgeX(inputView: tab1), y:dynheight + 2 ,width:(view4.bounds.width - 20)/3, height:40 + height1), text: "$\(dic["price"]!)", alignment: .center, textColor: textColorMedium)
                    tab2.numberOfLines = 2
                    tab2.lineBreakMode = NSLineBreakMode.byTruncatingTail
                    tab2.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                    tab2.backgroundColor = UIColor.white
                    view4.addSubview(tab2)
                    
                    let tab3 = createButton(CGRect(x:getRightEdgeX(inputView: tab2), y:dynheight + 2 ,width:(view4.bounds.width - 20)/3, height:40 + height1),title:"0" , border: false, bgColor: false,textColor: buttonColor)
                    tab3.backgroundColor = UIColor.white
                    tab3.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                    tab3.tag = i
                    tab3.addTarget(self, action: #selector(buttonclick(_ : )), for: UIControl.Event.touchUpInside)
                    view4.addSubview(tab3)
                    
                    if dic["status"] as? String == "Sold Out"
                    {
                        tab3.setTitle("Sold Out", for: UIControl.State.normal)
                    }
                    
                    
                    dynheight += 40 + 2 + height1
                }
            }
        }
        
        view4.frame.size.height += view4.frame.size.height + (dynheight - (38 + 35))
        view3.frame.size.height += view4.frame.size.height + 10
        view5.frame.origin.y += view3.frame.size.height - 8
        scrollView.contentSize.height = getBottomEdgeY(inputView: view5)
        scrollView.addSubview(view3)
        
        self.data()
    }
    
    // Declare the defination in all labels with values
    func data()
    {
        if self.datearray.count == 0
        {
            self.view2.isHidden = true
            self.view3.frame.origin.y = getBottomEdgeY(inputView: self.view1)
            self.view5.frame.origin.y = getBottomEdgeY(inputView: self.view3)
            scrollView.contentSize.height = getBottomEdgeY(inputView: view5)
        }
        
        if orderResponse["info"] != nil
        {
            info = (orderResponse["info"] as? String)!
        }
        
        if orderResponse["subTotal"] != nil
        {
            subtotal = (orderResponse["subTotal"] as? CGFloat)!
            label28.text = String(format:":  $%.2f", subtotal)
            //label28.text = ":  $\(( orderResponse["subTotal"] as? CGFloat)!)0"
        }
        
        if orderResponse["canShowBookNow"] != nil
        {
            canShowBookNow = (orderResponse["canShowBookNow"] as? Int)!
        }
        
        if orderResponse["discountPrice"] != nil
        {
            let discountPrice = orderResponse["discountPrice"] as? CGFloat ?? 0.0
            label29.text = String(format:":  $%.2f",discountPrice)
            //label29.text = ":  $\(( orderResponse["discountPrice"] as? CGFloat)!)"
        }
        
        if orderResponse["tax_rate"] != nil
        {
            let taxRate = orderResponse["tax_rate"] as? CGFloat ?? 0.0
            let roundedTaxRate = String(format:"%.2f",taxRate)
            //label26.text = String(format:"%.2f)",taxRate)
            label26.text = "Tax( \(roundedTaxRate) %) "
        }
        
        if orderResponse["tax"] != nil
        {
            let taxx = orderResponse["tax"] as? CGFloat ?? 0.0
            label30.text = String(format:":  $%.2f",taxx)
            //label30.text = ":  $\(( orderResponse["tax"] as? CGFloat)!)"
        }
        
        if orderResponse["grandTotal"] != nil
        {
            let grandTotal = orderResponse["grandTotal"] as? CGFloat ?? 0.0
            label31.text = String(format:":  $%.2f",grandTotal)
            //label31.text = ":  $\(( orderResponse["grandTotal"] as? CGFloat)!)"
        }
        
        if orderResponse["sell_starttime"] != nil
        {
            filterButton.setTitle("\((orderResponse["sell_starttime"] as? String)!)", for: UIControl.State.normal)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if placeandorder == 1
        {
            navtitle.text = ""
            placeandorder = 0
            contentFeedUpdate = false
            _ = self.navigationController?.popViewController(animated: false)
        }
    }
    
    
    // Deination of Date and quantity table
    func dateTable()
    {
        dateTableView = UITableView(frame: CGRect(x:15, y:getBottomEdgeY(inputView: view2), width:view.bounds.width - 30, height:200), style:.plain)
        dateTableView.register(TicketCustomTableViewCell.self, forCellReuseIdentifier: "Cell")
        dateTableView.dataSource = self
        dateTableView.delegate = self
        dateTableView.estimatedRowHeight = 40
        dateTableView.rowHeight = UITableView.automaticDimension
        dateTableView.backgroundColor = UIColor.clear
        dateTableView.separatorColor = UIColor.gray
        dateTableView.isHidden = true
        dateTableView.tag = 100
        dateTableView.layer.masksToBounds = true
        dateTableView.layer.shadowOffset = CGSize(width: -1, height: 1)
        dateTableView.layer.shadowRadius = 1
        dateTableView.layer.shadowOpacity = 0.5
        scrollView.addSubview(dateTableView)
        
        quantityTableView = UITableView(frame: CGRect(x:(view.bounds.width)/3 * 2, y: (50), width:(view.bounds.width)/3 - 20, height:160), style:.plain)
        quantityTableView.register(TicketCustomTableViewCell.self, forCellReuseIdentifier: "Cell")
        quantityTableView.dataSource = self
        quantityTableView.delegate = self
        quantityTableView.estimatedRowHeight = 40
        quantityTableView.rowHeight = UITableView.automaticDimension
        quantityTableView.backgroundColor = UIColor.clear//tableViewBgColor
        quantityTableView.separatorColor = UIColor.gray
        quantityTableView.isHidden = true
        quantityTableView.tag = 101
        quantityTableView.layer.masksToBounds = true
        quantityTableView.layer.shadowOffset = CGSize(width: -1, height: 1)
        quantityTableView.layer.shadowRadius = 1
        quantityTableView.layer.shadowOpacity = 0.5
        quantityTableView.bounces = false
      
    }
    
    //Click on occurance app
    @objc func filterClick()
    {
        quantityTableView.isHidden = true
        dateTableView.isHidden = false
        scrollView.bringSubviewToFront( dateTableView)
        dateTableView.reloadData()
    }
    
    @objc func buttonclick(_ sender: UIButton)
    {
        self.tagg = sender.tag
        button = sender
        if let ticket = orderResponse["tickets"] as? NSArray
        {
            if let dic = ticket[sender.tag] as? NSDictionary{
                self.ticketMax = (dic["buy_limit_max"] as? Int)!
            }
        }
        
        quantityTableView.isHidden = false
        scrollView.bringSubviewToFront( quantityTableView)
        dateTableView.isHidden = true
        quantityTableView.reloadData()
    }
    
    // Show pop up window when we click on more info button
    @objc func clickonMoreinfo(_ sender: UIButton)
    {
        button = sender
        
        if let ticket = orderResponse["tickets"] as? NSArray
        {
            if let dic = ticket[sender.tag] as? NSDictionary{
                
                hideCouponDetail()
                button.setTitle("Less Info", for: UIControl.State.normal)
                couponDetailView = CouponDetailView(frame:CGRect(x:10, y:view.bounds.height, width:view.bounds.width - 20, height:80))
                
                couponDetailView.backgroundColor = tableViewBgColor
                couponDetailView.couponStartDateLabel.isHidden = true
                couponDetailView.couponEndDateLabel.isHidden = true
                couponDetailView.couponStartDate.isHidden = true
                couponDetailView.couponEndDate.isHidden = true
                couponDetailView.couponImage.isHidden = true
                couponDetailView.couponCode.isHidden = true
                couponDetailView.couponDiscount.isHidden = true
                couponDetailView.couponUsageLimit.isHidden = true
                
                couponDetailView.couponLabel.frame = CGRect(x:10, y:10,width:(view.bounds.width ) - 30, height:30)
                couponDetailView.couponDescription.frame = CGRect(x:10, y:getBottomEdgeY(inputView: couponDetailView.couponLabel) + 5,width:(view.bounds.width ) - 30, height:30)
                
                couponDetailView.couponStartDateLabel.font = UIFont(name: fontName, size:FONTSIZEMedium)
                couponDetailView.couponDescription.font = UIFont(name: fontName, size:FONTSIZEMedium)
                couponDetailView.couponLabel.textAlignment = .center
                
                couponDetailView.couponLabel.text = NSLocalizedString("Tickets: \(String(describing: dic["quantity"]!))", comment: "")
                couponDetailView.couponDescription.text = NSLocalizedString("End date: \(String(describing: dic["sell_endtime"]!))", comment: "")
                
                couponDetailView.doneButton.addTarget(self, action: #selector(TicketDetailPageViewController.hideCouponDetail), for: UIControl.Event.touchUpInside)
                view.addSubview(couponDetailView)
                
                UIView.animate(withDuration: 0.5) { () -> Void in
                    self.couponDetailView.frame.origin.y = self.view.bounds.height/2 - self.couponDetailView.frame.height/2
                    self.blackScreen.alpha = 0.5
                }
            }
        }
        
    }
    
    // Hide pop up window
    @objc func hideCouponDetail(){
        
        button.setTitle("More Info", for: UIControl.State.normal)
        UIView.animate(withDuration:0.5) { () -> Void in
            self.couponDetailView.frame.origin.y = self.view.bounds.height
            self.blackScreen.alpha = 0.0
            self.couponDetailView.removeFromSuperview()
        }
    }
    
    // Click on book now button
    @objc func booknow()
    {
        if canShowBookNow != 0 {
            let presentedVC = BuyersTicketViewController()
            presentedVC.formTitle = NSLocalizedString("Buyer's Info", comment: "")
            presentedVC.contentType = "checkout"
            presentedVC.url = "advancedeventtickets/order/buyer-details"
            presentedVC.param = ["event_id":"\(eventid)","order_info":"\(info)"]
            presentedVC.info1 = info
            presentedVC.eventid = eventid
            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            let nativationController = UINavigationController(rootViewController: presentedVC)
            self.present(nativationController, animated:false, completion: nil)
        }
        else
        {
            showToast(message: NSLocalizedString("No tickets selected , Please select atleast one ticket to book .", comment: ""), controller: self)
        }
        
    }
    
    // Ticket data
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
            
            parameters["event_id"] = "\(eventid)"
            let path = "advancedeventtickets/tickets/tickets-buy"
            
//
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
                        self.couponEntries()
                        if succeeded["message"] != nil{
                           showToast(message: succeeded["message"] as! String, controller: self)
                            
                        }
                        
                        if let response = succeeded["body"] as? NSDictionary
                        {
                            self.orderResponse = response
                            
                            if let occurance = self.orderResponse["occurence"] as? NSArray
                            {
                                self.datearray = occurance as [AnyObject]
                            }
                            
                            if self.count == 0
                            {
                                self.count = 1
                                self.ordertable()
                            }
                            else
                            {
                                self.data()
                            }
                            
                            if self.k == 1
                            {
                                if let coupon_info = self.orderResponse["coupon_info"] as? NSDictionary
                                {
                                    if let msg = coupon_info["coupon_error_msg"] as? String{
                                        showToast(message: NSLocalizedString(msg, comment: ""), controller: self)
                                    }
                                    
                                    if let msg = coupon_info["coupon_success_msg"] as? String{
                                        showToast(message: NSLocalizedString(msg, comment: ""), controller: self)
                                        //                                    self.view.makeToast(NSLocalizedString("This coupon has been applied .", comment: ""), duration: 5, position: "bottom")
                                    }
                                }
                                
                                self.k = 0
                            }
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
    
    //Coupons data
    func couponEntries(){
        
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork()
        {
            let parameters = ["event_id":"\(eventid)"]
            let path = "/advancedeventtickets/coupons/index"
            
            post(parameters, url: path, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    
                    activityIndicatorView.stopAnimating()
                    if msg{
                        
                        if let body = succeeded["body"] as? NSDictionary
                        {
                            if let response = body["response"] as? NSArray
                            {
                                self.couponarray = response as [AnyObject]
                            }
                        }
                    }
                }
                )}
        }
    }
    
    // When we click on apply coupon button
    @objc func applyCopon()
    {
        k = 0
        
        if coupontextfield.text != "" {
            if canShowBookNow != 0 {
                for i in stride(from: 0, to: couponarray.count, by: 1){
                    if let dic = couponarray[i] as? NSDictionary{
                        
                        if let data = dic["coupon_code"] as? String
                        {
                            if data == coupontextfield.text
                            {
                                k = 1
                                parameters["coupon_code"] = coupontextfield.text
                                break
                            }
                        }
                    }
                }
            }
            else
            {
                k = 2
                showToast(message: NSLocalizedString("Please buy atleast one ticket to apply this coupon !", comment: ""), controller: self)
            }
        }
        else
        {
            k = 2
            showToast(message: NSLocalizedString("Please enter coupon code !", comment: ""), controller: self)
        }
        
        if k == 1
        {
//            self.view.makeToast(NSLocalizedString("This coupon has been applied .", comment: ""), duration: 5, position: "bottom")
            self.browseEntries()
        }
        
        if k == 0
        {
            showToast(message: NSLocalizedString("Please enter different coupon code as \((String(describing: coupontextfield.text!))) is invalid or expired.", comment: ""), controller: self)
        }
    }
    
    // MARK:  UITableViewDelegate & UITableViewDataSource
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView.tag == 100 {
            return 50
        }
        else{
            return 20
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 0.00001
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tableView.tag == 100 {
            return 50
        }
        else{
            return 42
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        if tableView.tag == 100 {
            return self.datearray.count
        }
        else
        {
            return self.ticketMax + 1
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        if tableView.tag == 100 {
            let row = indexPath.row as Int
            
            var dateInfo:NSDictionary
            
            let cell = dateTableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath) as! TicketCustomTableViewCell
            
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.backgroundColor = UIColor.white
            
            dateInfo = self.datearray[row] as! NSDictionary
            
            var tempInfo = ""
            let postedDate = dateInfo["starttime"] as? String
            let date = dateDifferenceWithEventTime(postedDate!)
            var DateC = date.components(separatedBy: ", ")
            tempInfo += "\(DateC[1]) \(DateC[0]) \(DateC[2])"
            if DateC.count > 3{
                tempInfo += " at \(DateC[3])"
            }
            
            var tempInfo1 = ""
            let postedDate1 = dateInfo["endtime"] as? String
            let date1 = dateDifferenceWithEventTime(postedDate1!)
            var DateC1 = date1.components(separatedBy: ", ")
            tempInfo1 += "\(DateC1[1]) \(DateC1[0]) \(DateC1[2])"
            if DateC1.count > 3{
                tempInfo1 += " at \(DateC1[3])"
            }
            
            cell.labTitle.frame = CGRect(x:10, y:0,width:(UIScreen.main.bounds.width - 40) , height:40)
            cell.labTitle.text = "\(tempInfo) - \(tempInfo1)"
            cell.labTitle.numberOfLines = 2
            cell.labTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
            
            return cell
        }
        else
        {
            let cell = quantityTableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath) as! TicketCustomTableViewCell
            
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.backgroundColor = UIColor.white
            
            cell.labTitle.frame = CGRect(x:0, y:0,width:quantityTableView.frame.size.width , height:40)
            cell.labTitle.text = "\(indexPath.row)"
            cell.labTitle.numberOfLines = 1
            cell.labTitle.textAlignment = .center
            cell.labTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
            
            return cell
        }
        
      //  let cell = CustomTableViewCellThree()
      //  return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        coupontextfield.text = ""
        
        if tableView.tag == 100 {
            
            let dateInfo = self.datearray[indexPath.row] as! NSDictionary
            
            var tempInfo = ""
            let postedDate = dateInfo["starttime"] as? String
            let date = dateDifferenceWithEventTime(postedDate!)
            var DateC = date.components(separatedBy: ", ")
            tempInfo += "\(DateC[1]) \(DateC[0]) \(DateC[2])"
            if DateC.count > 3{
                tempInfo += " at \(DateC[3])"
            }
            
            var tempInfo1 = ""
            let postedDate1 = dateInfo["endtime"] as? String
            let date1 = dateDifferenceWithEventTime(postedDate1!)
            var DateC1 = date1.components(separatedBy: ", ")
            tempInfo1 += "\(DateC1[1]) \(DateC1[0]) \(DateC1[2])"
            if DateC1.count > 3{
                tempInfo1 += " at \(DateC1[3])"
            }
            
            filterButton.setTitle("\(tempInfo) - \(tempInfo1)", for: UIControl.State.normal)
            
            let occurance_date = dateInfo["occurrence_id"]! as? Int
            parameters["occurrence_id"] = "\(occurance_date!)"
            dateTableView.isHidden = true
            quantityTableView.isHidden = true
            self.browseEntries()
        }
        else
        {
            if let data = orderResponse["tickets"] as? NSArray
            {
                if let dic = data[tagg] as? NSDictionary{
                    button.setTitle("\(indexPath.row)", for: .normal)
                    let ticketid = dic["ticket_id"]! as? Int
                    parameters["ticket_id_\(ticketid!)"] = "\(indexPath.row)"
                }
            }
            
            dateTableView.isHidden = true
            quantityTableView.isHidden = true
            self.browseEntries()
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
