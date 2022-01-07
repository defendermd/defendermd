//
//  ProductSuggestViewController.swift
//  seiosnativeapp
//
//  Created by Vidit Paliwal on 14/03/18.
//  Copyright © 2018 bigstep. All rights reserved.
//

import Foundation
import UIKit

var suggestedProducts = [String]()
var suggestedProductsIds = [String]()
var productLabels = [UILabel]()
var labelCancelButtons = [UIButton]()
var contentSizeHeight :CGFloat = 0
var labelWidth : CGFloat = 10
var labelHeight : CGFloat = 5

class ProductSuggestViewController: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource
{
    var sendMsg:UIBarButtonItem!
    var productLabel: UITextField!
    var product : String!
    var productsType : String! = ""
    var productArray : NSArray!
    var productTable: UITableView!
    var productDic : NSDictionary!
    var iscomingFrom : String = ""
    var popAfterDelay:Bool!
    var button : UIButton!
    //var navView = UIView()
    var productContainerView = UIScrollView()
    //var titleLabel = UILabel()
    var leftBarButtonItem : UIBarButtonItem!
    var storeid : String!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barTintColor = UIColor.white
        setNavigationImage(controller: self)
        popAfterDelay = false
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(ProductSuggestViewController.cancel))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ProductSuggestViewController.resignKeyboard))
        tap.delegate = self
        tap.cancelsTouchesInView = false;
        view.addGestureRecognizer(tap)
        
        
        productLabel = createTextField(CGRect(x: PADING, y: TOPPADING, width: view.bounds.width - (2 * PADING ), height: 40), borderColor: borderColorClear , placeHolderText: NSLocalizedString("Type a product name",  comment: ""), corner: true)
        productLabel.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Type a product name",  comment: ""), attributes: [NSAttributedString.Key.foregroundColor: placeholderColor])
        productLabel.addTarget(self, action: #selector(ProductSuggestViewController.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        productLabel.font =  UIFont(name: fontName, size: FONTSIZELarge)
        productLabel.backgroundColor = bgColor
        productLabel.delegate = self
        productLabel.layer.masksToBounds = true
        view.addSubview(productLabel)
        
        
//        let defaults = UserDefaults.standard
//        if let name = defaults.string(forKey: "Location")
//        {
//            productLabel.text = name
//        }
//        else if defaultlocation != nil && defaultlocation != ""
//        {
//            productLabel.text = defaultlocation
//        }
        
        let lineView1 = UIView(frame: CGRect(x: PADING,y: self.productLabel.frame.size.height+self.productLabel.frame.origin.y ,width: self.productLabel.frame.size.width,height: 0.5))
        lineView1.layer.borderWidth = 0.5
        lineView1.layer.borderColor = textColorMedium.cgColor
        self.view.addSubview(lineView1)
        
        productContainerView = UIScrollView(frame: CGRect(x:0,y:productLabel.frame.origin.y+productLabel.frame.size.height+1,width: self.view.bounds.width,height:0))
        productContainerView.backgroundColor = UIColor.white
        self.view.addSubview(productContainerView)
        
        productTable = UITableView(frame: (CGRect(x: productLabel.bounds.origin.x,y: productContainerView.frame.origin.y+productContainerView.frame.size.height+1, width: productLabel.bounds.size.width, height: view.bounds.height-(productLabel.bounds.origin.x + productLabel.frame.size.height+5 + tabBarHeight) )), style: UITableView.Style.grouped)
        productTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        productTable.contentInset = UIEdgeInsets(top: -35, left: 0, bottom: 0, right: 0)
        productTable.rowHeight = 35
        productTable.isHidden = true
        productTable.isOpaque = false
        productTable.backgroundColor = UIColor.white//tableViewBgColor
        view.addSubview(productTable)
    }
    
    @objc func stopTimer()
    {
        stop()
        
        if popAfterDelay == true
        {
            _ = navigationController?.popViewController(animated: true)
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        let navView = UIView()
        let titleLabel = UILabel()
        navView.frame = CGRect(x: 60, y: 0, width: self.view.frame.size.width-120, height: 44)
        navView.tag = 1001
        titleLabel.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width-120, height: self.navigationController!.navigationBar.frame.size.height)
        titleLabel.text = NSLocalizedString("Choose a Product",  comment: "")
        titleLabel.textColor = textColorPrime
        titleLabel.font = UIFont(name: fontName, size: 18)
        //titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.textAlignment = .center
        
        navView.addSubview(titleLabel)
        //[self.navigationController.navigationBar addSubview:view]
        self.navigationController?.navigationBar.addSubview(navView)
        
        if productLabels.count > 0
        {
            productContainerView.frame.size.height = 150
        }
        
        for labels in productLabels
        {
            let tag = String(labels.tag)
            if (suggestedProductsIds.contains(tag))
            {
                productContainerView.addSubview(labels)
                productContainerView.contentSize.height = contentSizeHeight
            }
            
        }
        for buttons in labelCancelButtons
        {
            let tag = String(buttons.tag)
            if (suggestedProductsIds.contains(tag))
            {
               productContainerView.addSubview(buttons)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //titleLabel.text = ""
        self.navigationController?.navigationBar.viewWithTag(1001)?.removeFromSuperview()
    }
    
    func openSlideMenu()
    {
        self.view.endEditing(true)
       // toggleSideMenuView()
        openSideMenu = true
    }
    
    @objc func resignKeyboard()
    {
        self.view.endEditing(true)
    }
    
    @objc func cancel()
    {
        Formbackup["product_search"] = ""
        for prod in suggestedProducts
        {
            Formbackup["product_search"] = Formbackup["product_search"] as! String+prod+", "
        }
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: TextFeild Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        
        self.view.endEditing(true)
        return true;
        
    }
    
    @objc func textFieldDidChange(_ textField: UITextField)
    {
        removeAlert()
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.center = self.view.center
        activityIndicatorView.startAnimating()
        product = productLabel.text
        var url = ""
        var parameters = ["product_search": product]
        parameters["store_id"] = self.storeid
        parameters["product_types"] = self.productsType
        //parameters["type"] = "simple,virtual"
        url = "sitestore/product/suggestproducts"
        // Send Server Request to Explore Group Contents with Group_ID
        post( parameters as! Dictionary<String, String>, url: url, method: "POST") { (succeeded, msg) -> () in
            
            DispatchQueue.main.async(execute: {
                activityIndicatorView.stopAnimating()
                
                if msg
                {
                    if succeeded["message"] != nil
                        
                    {
                        showToast(message: succeeded["message"] as! String, controller: self)
                        
                    }
                    if succeeded["body"] != nil
                    {
                        
                        if let contentInfo = succeeded["body"] as? NSDictionary
                        {
                            if let productInfos = contentInfo["response"] as? NSArray
                            {
                                if productInfos.count>0
                                {
                                    
                                    self.productArray = productInfos
                                    UIView.animate(withDuration: 0.7, delay: 0.0, options: .curveEaseOut, animations: {
                                        self.productTable.isHidden = false
                                        self.productTable.dataSource = self
                                        self.productTable.delegate = self
                                        self.productTable.frame.origin.y = self.productContainerView.frame.origin.y+self.productContainerView.frame.size.height
                                        self.productTable.reloadData()
                                        
                                    }, completion: { finished in
                                        
                                    })
                                    
                                }
                            }
                            
                        }
                    }
                    
                }
                
            })
        }
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let  char = string.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")
        
        if (isBackSpace == -92) {
            //            locLabel.text = ""
        }
        
        return true
    }
    
    // MARK:  UITableViewDelegate & UITableViewDataSource
    
    // Set Tabel Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        
        return 0.00001
        
    }
    
    // Set Tabel Header Height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        if suggestedProducts.count > 0
        {
            return 0.00001
        }
        else
        {
            return 0.00001
        }
        
    }
    
    //func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let headerView = createView(CGRect(x: PADING, y: PADING, width: view.frame.width - contentPADING, height: 40), borderColor: TVSeparatorColor, shadow: false)
//        headerView.backgroundColor = UIColor.white
//
//        let headerLabel = createLabel(CGRect(x: PADING, y: PADING, width: view.frame.width - contentPADING, height: 40), text: "", alignment: .left, textColor: textColorDark)
//        headerLabel.font = UIFont(name: fontName, size: FONTSIZELarge)
//        headerLabel.text = Formbackup["product_search"] as? String
//        headerLabel.numberOfLines = 0
//        headerLabel.sizeToFit()
//        headerView.addSubview(headerLabel)
//        return headerView
    //}
    
    // Set TableView Section
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        
        return 35.0
        
        
    }
    
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if productArray.count>0
        {
            return productArray.count
        }
        else
        {
            return 0
        }
    }
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = UITableViewCell.SelectionStyle.blue
        let dic = productArray.object(at: (indexPath as NSIndexPath).row) as! NSDictionary
        cell.textLabel?.text = dic["label"] as? String
        
        return cell
        
    }
    
    // Handle Blog Table Cell Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        productDic = productArray.object(at: (indexPath as NSIndexPath).row) as! NSDictionary
        
        productLabel.text = productDic["label"] as? String
        let productName = productDic["label"] as? String
        let productId = productDic["id"] as? Int
        
        if !suggestedProducts.contains(productName!)
        {
            addProducts(productName: productName!, productId: productId!)
            suggestedProducts.append(productName!)
            suggestedProductsIds.append(String(productId!))
        }
        //defaultlocation = productDic["label"] as! String
        
        self.productTable.isHidden = false
        
        //defaultlocation = self.productLabel.text!
        self.view.endEditing(true)
        self.productTable.isHidden = false
        self.productTable.reloadData()

        //let defaults = UserDefaults.standard
        //defaults.set(defaultlocation, forKey: "Location")
        //self.view.makeToast("Product added to the list successfully.", duration: 2, position: "bottom")
        self.popAfterDelay = false
        createTimer(self)
        
    }
    func createTimer(_ target: AnyObject){
        timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  #selector(stopTimer), userInfo: nil, repeats: false)
    }
    func addProducts(productName : String, productId : Int)
    {
        productContainerView.frame.size.height = 150
        
        if labelWidth + (findWidthByText(productName) + 45 ) > view.bounds.width
        {
            labelWidth = 10
            labelHeight += 40
        }
        
        let label = UILabel(frame: CGRect(x:labelWidth,y:labelHeight,width:100,height:30))
        label.text = productName
        label.backgroundColor = navColor
        label.textColor = textColorPrime
        label.textAlignment = .center
        label.tag = productId
        //label.addSubview(cancel)
        label.frame.size.width = findWidthByText(productName) + 15
        productContainerView.addSubview(label)
        let widthText = findWidthByText(productName)+15
        let cancel = createButton(CGRect( x: label.frame.origin.x+label.frame.size.width, y: label.frame.origin.y, width: 30, height: 30), title: "\(cancelFriendIcon)", border: false,bgColor: false, textColor: textColorLight)
        cancel.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
        cancel.tag = productId
        cancel.addTarget(self, action: #selector(ProductSuggestViewController.removeProduct(_:)), for: .touchUpInside)
        cancel.backgroundColor = navColor
        productContainerView.addSubview(cancel)
        labelWidth += label.frame.size.width+35
        productLabels.append(label)
        labelCancelButtons.append(cancel)
        //productLabels.append(cancel)
        productContainerView.contentSize.height = labelHeight + CGFloat(35)
        contentSizeHeight = productContainerView.contentSize.height
        productTable.frame.origin.y = productContainerView.frame.origin.y+productContainerView.frame.size.height
        productTable.reloadData()
    }
    
    @objc func removeProduct(_ sender: UIButton)
    {
        let removeId = sender.tag
        for i in 0 ..< (productLabels.count) where i < productLabels.count
        {
            if removeId == productLabels[i].tag
            {
                productLabels.remove(at: i)
            }
        }
        labelCancelButtons.removeAll(keepingCapacity: false)
        
        for ob in productContainerView.subviews
        {
            if ob.tag == removeId
            {
                ob.removeFromSuperview()
                removeFromGlobalProducts(id: removeId)
                redrawLabels()
            }
            if ob.isKind(of: UIButton.self)
            {
                ob.removeFromSuperview()
            }
        }
    }
    
    func redrawLabels()
    {
        if productLabels.count == 0
        {
            productContainerView.frame.size.height = 0
            productTable.frame.origin.y = productContainerView.frame.origin.y
            labelWidth = 10
            labelHeight = 5
            return
        }
        labelWidth = 10
        labelHeight = 5
        for label in productLabels
        {
            let text = label.text!
            if labelWidth + (findWidthByText(text) + 45 ) > view.bounds.width
            {
                labelWidth = 10
                labelHeight += 40
            }
            label.frame.origin.x = labelWidth
            label.frame.origin.y = labelHeight
            labelWidth += label.frame.size.width+35
            let cancel = createButton(CGRect( x: label.frame.origin.x+label.frame.size.width, y: label.frame.origin.y, width: 30, height: 30), title: "\(cancelFriendIcon)", border: false,bgColor: false, textColor: textColorLight)
            cancel.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
            cancel.tag = label.tag
            cancel.addTarget(self, action: #selector(ProductSuggestViewController.removeProduct(_:)), for: .touchUpInside)
            cancel.backgroundColor = navColor
            productContainerView.addSubview(cancel)
            labelCancelButtons.append(cancel)
            productContainerView.contentSize.height = labelHeight + CGFloat(35)
            contentSizeHeight = productContainerView.contentSize.height
        }
    }
    
    func removeFromGlobalProducts(id: Int)
    {
        let stringId = String(id)
        for i in 0 ..< suggestedProductsIds.count where i < suggestedProductsIds.count
        {
            if stringId == suggestedProductsIds[i]
            {
                suggestedProductsIds.remove(at: i)
                suggestedProducts.remove(at: i)
                print(suggestedProductsIds)
                print(suggestedProducts)
            }
        }
    }
}
