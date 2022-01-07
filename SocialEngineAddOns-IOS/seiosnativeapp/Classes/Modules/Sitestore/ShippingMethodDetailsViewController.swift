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
// ShippingMethodDetailsViewController.swift
//  seiosnativeapp
//


import UIKit
class ShippingMethodDetailsViewController: UIViewController, TTTAttributedLabelDelegate,UITextViewDelegate{
    var dic = Dictionary<String, AnyObject>()
    
    var scrollView : UIScrollView!
    var configView : UIView!
    var label1 : TTTAttributedLabel!
    var label3 : TTTAttributedLabel!
    var multioption : NSDictionary!
    var configArrayValueChange : NSMutableArray! = []
    var configArrayIndependentFields : NSArray! = []
    var labelKey : String!
    var labelDesc : String!
    var origin_labelheight_y2 : CGFloat = 0
    var origin_labelheight_y : CGFloat = 0
    var indexValueofMultiCheckBox : Int = 0
    
    var priceAmount : CGFloat!
    var shippingMethodDetailss : NSDictionary!
    var currency : String = ""
    var totalItemCounts : Int!
    var defaultString = [String]()
    var valueofdefaultString = [String]()
    var leftBarButtonItem: UIBarButtonItem!
    // Initialize Class Object
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        defaultString  = [ "Title","Country","Regions/States","Weight Limit","Delivery Time","Dependency","Limit","Charge on","Price/Rate","Shipping Price"]
        
        // Do any additional setup after loading the view.
        searchDic.removeAll(keepingCapacity: false)
        view.backgroundColor = bgColor
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(ShippingMethodDetailsViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem

        scrollView = UIScrollView(frame: view.bounds)
        scrollView.backgroundColor = bgColor
        scrollView.delegate = self
        scrollView.bounces = false
        scrollView.contentSize = view.bounds.size
        scrollView.sizeToFit()
        view.addSubview(scrollView)
        
        
        configView = createView(CGRect(x:0, y: 0, width: view.bounds.width, height: 0), borderColor: UIColor.lightGray, shadow: true)
        configView.backgroundColor = UIColor.white//UIColor(red: 229/255.0, green: 229/255.0, blue: 229/255.0, alpha: 1.0)
        configView.isHidden = false
        configView.tag = 1000
        scrollView.addSubview(configView)
        
        browseConfigurations()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        setNavigationImage(controller: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = NSLocalizedString("Shipping Methods", comment: "")
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
    
    
    func browseConfigurations(){
        origin_labelheight_y2  = 0
        origin_labelheight_y  = 0
        if shippingMethodDetailss != nil{
            
            
            if let totalItem = shippingMethodDetailss["totalItemCount"]  as? Int{
                totalItemCounts = totalItem
            }
            if let SingleMethod = shippingMethodDetailss["methods"]  as? NSArray{
                
                for (_, element) in SingleMethod.enumerated(){
                    if let singlemethodDictionary = element as? NSDictionary{
                        
                        valueofdefaultString = ["","","","","","","","","",""]
                        if let title = singlemethodDictionary["title"] {
                            valueofdefaultString.insert("\(title)", at: 0)
                        }
                        
                        if let country = singlemethodDictionary["country"]{
                            valueofdefaultString.insert("\(country)", at: 1)
                        }
                        if let region = singlemethodDictionary["region"]{
                            valueofdefaultString.insert("\(region)", at: 2)
                        }
                        
                        if let weightLimit = singlemethodDictionary["weight_limit"]{
                            valueofdefaultString.insert("\(weightLimit)", at: 3)
                        }
                        
                        
                        if let deliveryTime = singlemethodDictionary["delivery_time"] {
                            valueofdefaultString.insert("\(deliveryTime)", at: 4)
                        }
                        
                        if let dependency = singlemethodDictionary["dependency"] {
                            valueofdefaultString.insert("\(dependency)", at: 5)
                            
                        }
                        if let limit = singlemethodDictionary["limit"]{
                            valueofdefaultString.insert("\(limit)", at: 6)
                        }
                        if let chargeOn = singlemethodDictionary["charge_on"]{
                            valueofdefaultString.insert("\(chargeOn)", at: 7)
                        }
                        if let priceRate = singlemethodDictionary["price_rate"] as? NSDictionary{
                            if  priceRate["type"] as? Int == 0{
                                if let amount = priceRate["value"] as? Int{
                                    var totalView = ""
                                    let formatter = NumberFormatter()
                                    formatter.numberStyle = .currency
                                    formatter.locale = NSLocale.current // This is the default
                                    formatter.currencyCode = "\(currency)"
                                    
                                    if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
                                        let defaults = UserDefaults.standard
                                        if let name = defaults.object(forKey: "Currency")
                                        {
                                            let price = gettwoFractionDigits(FractionDigit: "\(amount)")
                                            let changePrice = (defaults.object(forKey: "PriceRate") as! Float) * Float(price)!
                                            let showPrice = (String(format:"%.2f", changePrice))
                                            
                                            totalView =  "\(getCurrencySymbol(name as! String)) \(showPrice)"
                                            
                                        }
                                    }
                                    else{
                                        totalView += formatter.string(from: NSNumber(value: amount))!
                                    }
                                    
                                   // totalView += formatter.string(from: NSNumber(value: amount))! // $123"
                                    valueofdefaultString.insert("\(totalView)", at: 8)
                                    
                                }
                                
                            }
                            else{
                                if let amount = priceRate["value"] as? Int{
                                    valueofdefaultString.insert("\(amount) %", at: 8)
                                }
                                
                            }
                            
                        }
                        if let amount = singlemethodDictionary["shipping_price"] as? Int{
                            var totalView = ""
                            let formatter = NumberFormatter()
                            formatter.numberStyle = .currency
                            formatter.locale = NSLocale.current // This is the default
                            formatter.currencyCode = "\(currency)"
                            if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
                                let defaults = UserDefaults.standard
                                if let name = defaults.object(forKey: "Currency")
                                {
                                    let price = gettwoFractionDigits(FractionDigit: "\(amount)")
                                    let changePrice = (defaults.object(forKey: "PriceRate") as! Float) * Float(price)!
                                    let showPrice = (String(format:"%.2f", changePrice))
                                    
                                    totalView =  "\(getCurrencySymbol(name as! String)) \(showPrice)"
                                    
                                }
                            }
                            else{
                                totalView += formatter.string(from: NSNumber(value: amount))!
                            }
                           // totalView += formatter.string(from: NSNumber(value: amount))! // $123"
                            valueofdefaultString.insert("\(totalView)", at: 9)
                        }
                        
                        
                        self.label1 = TTTAttributedLabel(frame:CGRect(x:0,y: origin_labelheight_y + 5, width: view.bounds.width , height: 25) )
                        
                        self.label1.textColor = textColorDark
                        self.label1.isHidden = false
                        self.label1.font = UIFont(name:fontBold, size: FONTSIZELarge)
                        self.label1.numberOfLines = 0
                        self.label1.textAlignment = .center
                        self.label1.lineBreakMode = NSLineBreakMode.byWordWrapping
                        self.label1.setText("\(valueofdefaultString[0])" , afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                            
                            
                            return mutableAttributedString
                        })
                        
                        origin_labelheight_y  = origin_labelheight_y + self.label1.bounds.height + 20
                        origin_labelheight_y2  = origin_labelheight_y2 + self.label1.bounds.height + 20
                        self.configView.addSubview(self.label1)
                        
                        
                        for i in 0...9 {
                            
                            self.label1 = TTTAttributedLabel(frame:CGRect(x:2 * PADING, y:origin_labelheight_y + 5, width: 120, height: 20) )
                            self.label1.textColor = textColorDark
                            
                            self.label1.isHidden = false
                            
                            
                            self.label1.font = UIFont(name: fontNormal, size: FONTSIZEMedium)
                            self.label1.numberOfLines = 0
                            self.label1.lineBreakMode = NSLineBreakMode.byWordWrapping
                            self.label1.setText("\(defaultString[i]):" , afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                                
                                
                                return mutableAttributedString
                            })
                            
                            
                            
                            origin_labelheight_y  = origin_labelheight_y + self.label1.bounds.height + 15
                            
                            self.configView.addSubview(self.label1)
                            
                            
                            
                            self.label3 = TTTAttributedLabel(frame:CGRect(x:120 + 2 * PADING, y: origin_labelheight_y2 + 5, width: self.view.bounds.width/2 - 2 * PADING, height: 20) )
                            self.label3.textColor = textColorDark
                            self.label3.isHidden = false
                            
                            self.label3.font = UIFont(name: fontNormal, size: FONTSIZEMedium)
                            self.label3.numberOfLines = 0
                            self.label3.lineBreakMode = NSLineBreakMode.byWordWrapping
                            self.label3.setText("\(valueofdefaultString[i])" , afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                                
                                
                                return mutableAttributedString
                            })
                            
                            origin_labelheight_y2  = origin_labelheight_y2 + self.label3.bounds.height + 15
                            
                            self.configView.addSubview(self.label3)
                            
                        }
                        
                        
                        
                    }
                    
                    
                }
            }
            if origin_labelheight_y2 > origin_labelheight_y{
                self.configView.frame.size.height = origin_labelheight_y2  + 10
                self.scrollView.contentSize.height =  origin_labelheight_y2 + 10
                
            }
            else{
                self.configView.frame.size.height = origin_labelheight_y  + 10
                self.scrollView.contentSize.height =  origin_labelheight_y + 10
                
            }
            
        }
    }
    
    
    
    
    @objc func goBack()
    {
         _ = self.navigationController?.popViewController(animated: false)
    }
    
    
}
