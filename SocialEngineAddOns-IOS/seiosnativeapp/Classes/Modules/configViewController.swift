///*
//* Copyright (c) 2016 BigStep Technologies Private Limited.
//*
//* You may not use this file except in compliance with the
//* SocialEngineAddOns License Agreement.
//* You may obtain a copy of the License at:
//* https://www.socialengineaddons.com/ios-app-license
//* The full copyright and license information is also mentioned
//* in the LICENSE file that was distributed with this
//* source code.
//*/
//
//
////
//// ConfigrationFormViewController.swift
////  seiosnativeapp
////
//
//
//import UIKit
//
//class ConfigrationFormViewController: UIViewController, UIWebViewDelegate, TTTAttributedLabelDelegate,UITextViewDelegate{
//    // Variable for Blog Detail Form
//    
//    //    var subjectId : Int!
//    //    var mytitle : String!
//    //    var detailWebView = UITextView()
//    //    var label1 : String!
//    //
//    var product_id : Int!
//    var productConfigName = Dictionary<String,String>()//[:]
//    
//    var configArrayValue : NSArray!
//    var scrollView : UIScrollView!
//    var configView : UIView!
//    var label1 : TTTAttributedLabel!
//    var label3 : TTTAttributedLabel!//UIButton!
//    var multioption : NSDictionary!
//    var configArrayValueChange : NSMutableArray!
//    var labelKey : String!
//    var labelDesc : String!
//    
//    var labelKey2 : String!
//    var labelDesc2 : String!
//    var profileFieldString = ""
//    var profileFieldString2 = ""
//    var origin_labelheight_y2 : CGFloat = 0
//    var origin_labelheight_y : CGFloat = 0
//    
//    // Initialize Class Object
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view.
//        searchDic.removeAll(keepCapacity: false)
//        view.backgroundColor = bgColor
//        
//        let leftNavView = UIView(frame: CGRectMake(0, 0, 44, 44))
//        leftNavView.backgroundColor = UIColor.clearColor()
//        let tapView = UITapGestureRecognizer(target: self, action: Selector("goBack"))
//        leftNavView.addGestureRecognizer(tapView)
//        
//        
//        let backIconImageView = createImageView(CGRectMake(0,12,22,22), border: false)
//        backIconImageView.image = UIImage(named: "back_icon")
//        leftNavView.addSubview(backIconImageView)
//        
//        if footerDashboard == false {
//            let barButtonItem = UIBarButtonItem(customView: leftNavView)
//            self.navigationItem.leftBarButtonItem = barButtonItem
//        }
//        
//        configArrayValueChange = configArrayValue as! NSMutableArray
//        
//        scrollView = UIScrollView(frame: view.bounds)
//        scrollView.backgroundColor = bgColor
//        scrollView.delegate = self
//        scrollView.bounces = false
//        scrollView.contentSize = view.bounds.size
//        scrollView.sizeToFit()
//        view.addSubview(scrollView)
//        
//        
//        configView = createView(CGRectMake(0,  5, CGRectGetWidth(view.bounds), 30), borderColor: UIColor.lightGrayColor(), shadow: true)
//        configView.backgroundColor = UIColor.whiteColor()//UIColor(red: 229/255.0, green: 229/255.0, blue: 229/255.0, alpha: 1.0)
//        configView.hidden = false
//        configView.tag = 1000
//        scrollView.addSubview(configView)
//        
//        
//        label1 = TTTAttributedLabel(frame:CGRectMake(PADING,10,CGRectGetWidth(self.view.bounds)/2 - PADING , 30) )
//        label3 = TTTAttributedLabel(frame:CGRectMake(PADING,10,CGRectGetWidth(self.view.bounds)/2 - PADING , 30) )
//        //        label3.numberOfLines = 0
//        //        label3.numberOfLines = 0
//        //        label3.textColor = textColorDark
//        //       label3.backgroundColor = UIColor.whiteColor()//aafBgColor
//        //        label3.layer.borderWidth = 1.0
//        //       label3.layer.borderColor = textColorMedium.CGColor
//        //      label3.font = UIFont(name: "FontAwesome", size: 16)
//        //       label3.numberOfLines = 0
//        //       label3.lineBreakMode = NSLineBreakMode.ByWordWrapping
//        label1.hidden = true
//        label3.hidden = true
//        
//        configView.addSubview(label1)
//        configView.addSubview(label3)
//        
//    }
//    
//    override func viewDidAppear(animated: Bool) {
//        
//        //self.title = NSLocalizedString("Info", comment: "")
//        navigationController?.navigationBar.hidden = false
//        self.navigationController?.navigationBar.setBackgroundImage(imagefromColor(navColor), forBarMetrics: .Default)
//        self.navigationController?.navigationBar.shadowImage = imagefromColor(navColor)
//        self.navigationController?.navigationBar.translucent = true
//        self.navigationController?.navigationBar.tintColor = textColorLight
//    }
//    
//    override func viewWillAppear(animated: Bool) {
//        configArrayValueChange = configArrayValue as! NSMutableArray
//        
//        self.title = NSLocalizedString("Select Configuration", comment: "")
//        //                for ob in scrollView.subviews{
//        //                    if ob.tag == 1000{
//        //                        ob.removeFromSuperview()
//        //                    }
//        //                }
//        
//        browseConfigurations()
//        
//        
//    }
//    
//    override func viewDidDisappear(animated: Bool) {
//        navigationController?.navigationBar.hidden = false
//        self.navigationController?.navigationBar.setBackgroundImage(imagefromColor(navColor), forBarMetrics: .Default)
//        self.navigationController?.navigationBar.shadowImage = imagefromColor(navColor)
//        self.navigationController?.navigationBar.translucent = true
//        self.navigationController?.navigationBar.tintColor = textColorLight
//    }
//    
//    
//    
//    
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    func browseConfigurations(){
//        origin_labelheight_y = 0.0
//        
//        
//        
//        
//        if  configArrayValueChange.count > 0{
//            
//            var typeName = ""
//            var i = 0
//            for configValue in configArrayValueChange {
//                
//                if let dic = configValue as? NSDictionary {
//                    print("configValue")
//                    print(configValue)
//                    if  let type = dic["type"] as? String{
//                        //                        if productConfigName.count == 0{
//                        if type == "select" || type == "radio"{
//                            self.label1 = TTTAttributedLabel(frame:CGRectMake(2 * PADING,origin_labelheight_y + 5,CGRectGetWidth(self.view.bounds)/2 - 2 * PADING , 30) )
//                            self.label1.textColor = textColorDark
//                            self.label1.hidden = false
//                            //                            labelKey = (("Title" as? String)! + ": ")
//                            self.label1.backgroundColor = UIColor.whiteColor()//aafBgColor
//                            
//                            self.label1.font = UIFont(name: fontNormal, size: 16)
//                            self.label1.numberOfLines = 0
//                            self.label1.lineBreakMode = NSLineBreakMode.ByWordWrapping
//                            labelDesc = dic["label"] as? String
//                            if type == "radio"{
//                                typeName = (dic["title"] as? String)!
//                                profileFieldString = (dic["title"] as? String)!
//                            }
//                            else{
//                                typeName = (dic["label"] as? String)!
//                                profileFieldString = (dic["label"] as? String)!
//                            }
//                            self.label1.text = profileFieldString
//                            self.label1.setText(profileFieldString , afterInheritingLabelAttributesAndConfiguringWithBlock: { (mutableAttributedString: NSMutableAttributedString!) -> NSMutableAttributedString! in
//                                
//                                let boldFont1 = CTFontCreateWithName(fontNormal, 16, nil)
//                                
//                                let range1 = (self.profileFieldString as NSString).rangeOfString(self.profileFieldString as String)
//                                mutableAttributedString.addAttribute(kCTFontAttributeName as String, value: boldFont1, range: range1)
//                                mutableAttributedString.addAttribute(kCTForegroundColorAttributeName as String, value:textColorMedium , range: range1)
//                                
//                                
//                                return mutableAttributedString
//                            })
//                            
//                            self.label1.sizeToFit()
//                            if self.label1.frame.size.width < 100{
//                                self.label1.frame.size.width = 100
//                            }
//                            self.label1.frame.size.height = 30
//                            //                            origin_labelheight_y  = origin_labelheight_y + CGRectGetHeight(self.label1.bounds) + 10
//                            
//                            self.configView.addSubview(self.label1)
//                            
//                            
//                            
//                            //
//                            
//                            if productConfigName.count == 0{
//                                
//                                //                             for(k,v) in productConfigName{
//                                
//                                
//                                
//                                self.label3 = TTTAttributedLabel(frame:CGRectMake(self.label1.frame.origin.x + CGRectGetWidth(self.label1.bounds) + (2 * PADING),origin_labelheight_y + 5,CGRectGetWidth(view.bounds) - ( self.label1.frame.origin.x + CGRectGetWidth(self.label1.bounds) + (2 * PADING)    ) , 30) )
//                                self.label3.textColor = textColorDark
//                                self.label3.hidden = false
//                                self.label3.backgroundColor = UIColor.whiteColor()//aafBgColor
//                                self.label3.layer.borderWidth = 1.0
//                                self.label3.layer.borderColor = textColorMedium.CGColor
//                                self.label3.font = UIFont(name: "FontAwesome", size: 16)
//                                self.label3.numberOfLines = 0
//                                self.label3.lineBreakMode = NSLineBreakMode.ByWordWrapping
//                                self.label3.tag = i
//                                self.label3.delegate = self
//                                if productConfigName.count != 0{
//                                    for(k,v) in productConfigName{
//                                        if k  == typeName{
//                                            profileFieldString2 = NSLocalizedString("\(v)"  , comment: "")
//                                        }
//                                        //                                else{
//                                        //                                    profileFieldString2 = NSLocalizedString("-----Select----"  , comment: "")
//                                        //                                }
//                                    }
//                                    
//                                }
//                                else{
//                                    profileFieldString2 = NSLocalizedString("-----Select----"  , comment: "")
//                                }
//                                
//                                print("profileFieldString2")
//                                print(profileFieldString2)
//                                //                            self.productConfigName["\(dic["label"] as? String)"] != nil{
//                                
//                                //                            }
//                                //                            profileFieldString2 = NSLocalizedString("-----Select----"  , comment: "")//String(format: NSLocalizedString(" ----Select----  %@ ", comment: ""), "\u{f150}")//NSLocalizedString("-----Select----"  , comment: "")
//                                //                            self.label3.text = profileFieldString2
//                                self.label3.setText(profileFieldString2 , afterInheritingLabelAttributesAndConfiguringWithBlock: { (mutableAttributedString: NSMutableAttributedString!) -> NSMutableAttributedString! in
//                                    
//                                    let boldFont1 = CTFontCreateWithName("FontAwesome", 16, nil)
//                                    
//                                    let range1 = (self.profileFieldString2 as NSString).rangeOfString(self.profileFieldString2 as String)
//                                    mutableAttributedString.addAttribute(kCTFontAttributeName as String, value: boldFont1, range: range1)
//                                    mutableAttributedString.addAttribute(kCTForegroundColorAttributeName as String, value:textColorMedium , range: range1)
//                                    
//                                    
//                                    return mutableAttributedString
//                                })
//                                let range = (profileFieldString2 as NSString).rangeOfString(profileFieldString2 as String)
//                                //                            let range = (profileFieldString2 as NSString).rangeOfString(NSLocalizedString(" ",  comment: " --Select--"))
//                                if  dic["multiOptions"]  != nil{
//                                    
//                                    //                                       multioption
//                                    
//                                    
//                                }
//                                //                            ["multioption" : dic["multiOptions"] as! NSDictionary
//                                if dic["multiOptions"] != nil{
//                                    self.label3.addLinkToTransitInformation(["multioption" : dic["multiOptions"] as! NSDictionary,"type" : "config", "tag" : i,"name" : (dic["name"] as? String)!,"typeName" : typeName], withRange:range)
//                                }
//                                else{
//                                    self.label3.addLinkToTransitInformation(["type" : "config", "tag" : i,"name" : (dic["name"] as? String)!], withRange:range)
//                                }
//                                //                            }
//                                
//                                self.label3.sizeToFit()
//                                self.label3.frame.size.width = self.label3.frame.size.width + 5
//                                //                            if self.label3.frame.size.width !={
//                                
//                                //self.label3.frame.size.width = 130
//                                //                            }
//                                //
//                                self.label3.frame.size.height = 30
//                                if label3.frame.size.width < 200{
//                                    label3.frame.size.width = 200
//                                }
//                                // we apply condition here
//                                if CGRectGetHeight(self.label3.bounds) >  CGRectGetHeight(self.label1.bounds) {
//                                    origin_labelheight_y  = origin_labelheight_y + CGRectGetHeight(self.label3.bounds) + 10
//                                }
//                                else{
//                                    origin_labelheight_y  = origin_labelheight_y + CGRectGetHeight(self.label1.bounds) + 10
//                                    
//                                }
//                                self.configView.addSubview(self.label3)
//                                //
//                                
//                                
//                            }
//                            else{
//                                
//                                //                                for(k,v) in
//                                
//                                
//                            }
//                            
//                            
//                            
//                        }
//                        
//                        //                        }
//                        if type == "multi_checkbox"{
//                            if dic["multiOptions"] != nil{
//                                var j = i
//                                if let options = dic["multiOptions"] as? NSDictionary{
//                                    for (k,v) in options{
//                                        print("option")
//                                        print(k)
//                                        print(v)
//                                        if let valueofoption = v as? NSDictionary{
//                                            
//                                            
//                                            
//                                            self.label1 = TTTAttributedLabel(frame:CGRectMake(2 * PADING,origin_labelheight_y + 15,CGRectGetWidth(self.view.bounds)/2 - 2 * PADING , 30) )
//                                            self.label1.textColor = textColorDark
//                                            self.label1.hidden = false
//                                            //                            labelKey = (("Title" as? String)! + ": ")
//                                            self.label1.backgroundColor = UIColor.whiteColor()//aafBgColor
//                                            
//                                            self.label1.font = UIFont(name: "FontAwesome", size: 16)
//                                            self.label1.numberOfLines = 0
//                                            self.label1.lineBreakMode = NSLineBreakMode.ByWordWrapping
//                                            self.label1.delegate = self
//                                            let value  = (valueofoption["label"] as! String)
//                                            profileFieldString = String(format: NSLocalizedString(" %@ \(value)  ", comment: ""), "\u{f096}")
//                                            
//                                            self.label1.text = profileFieldString
//                                            self.label1.setText(profileFieldString , afterInheritingLabelAttributesAndConfiguringWithBlock: { (mutableAttributedString: NSMutableAttributedString!) -> NSMutableAttributedString! in
//                                                
//                                                let boldFont1 = CTFontCreateWithName("FontAwesome", 16, nil)
//                                                
//                                                let range1 = (self.profileFieldString as NSString).rangeOfString(self.profileFieldString as String)
//                                                mutableAttributedString.addAttribute(kCTFontAttributeName as String, value: boldFont1, range: range1)
//                                                mutableAttributedString.addAttribute(kCTForegroundColorAttributeName as String, value:textColorMedium , range: range1)
//                                                
//                                                
//                                                return mutableAttributedString
//                                            })
//                                            let range = (profileFieldString as NSString).rangeOfString(profileFieldString as String)
//                                            
//                                            self.label1.addLinkToTransitInformation(["type" : "checkbox", "tag" : j], withRange:range)
//                                            
//                                            self.label1.sizeToFit()
//                                            
//                                            self.label1.frame.size.height = 30
//                                            origin_labelheight_y  = origin_labelheight_y + CGRectGetHeight(self.label1.bounds) + 10
//                                            
//                                            self.configView.addSubview(self.label1)
//                                            
//                                            
//                                            
//                                            
//                                            
//                                            
//                                        }
//                                        j = j + 1
//                                    }
//                                }
//                            }
//                            
//                        }
//                        
//                        
//                    }
//                    
//                }
//                i = i + 1
//                
//            }
//            
//            self.configView.frame.size.height = origin_labelheight_y + 10
//            
//            
//            
//        }
//        
//        
//        
//    }
//    
//    func goBack()
//    {
//        self.navigationController?.popViewControllerAnimated(false)
//    }
//    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithTransitInformation components: [NSObject : AnyObject]!) {
//        let type = components["type"] as! String
//        
//        switch(type){
//            
//        case "config":
//            
//            print(components["tag"] as! Int)
//            //            print(components["multioption"] as! NSDictionary)
//            
//            if let multioption = components["multioption"] as? NSDictionary{
//                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
//                
//                
//                for(k,v) in multioption{
//                    
//                    print("k")
//                    print(k)
//                    //                    print("v")
//                    //                    print(v)
//                    if v is String {
//                        
//                        alertController.addAction(UIAlertAction(title: (v as! String), style: .Default, handler:{ (UIAlertAction) -> Void in
//                            
//                            
//                            
//                            
//                            
//                        }))
//                        
//                    }
//                    if v is NSDictionary {
//                        
//                        
//                        alertController.addAction(UIAlertAction(title: (v["label"] as! String), style: .Default, handler:{ (UIAlertAction) -> Void in
//                            
//                            label.frame.size.width = CGRectGetWidth(self.view.bounds) - ( label.frame.origin.x - 2 * PADING)
//                            self.productConfigName["\(components["typeName"] as! String)"] = "\(v["label"] as! String)"
//                            print(self.productConfigName)
//                            //                        label.text = v["label"] as? String
//                            let configValue  = NSLocalizedString("  \(v["label"] as! String)", comment: "")//NSLocalizedString("-----Select----"  , comment: "")//String(format: NSLocalizedString("  \(v["label"] as! String)  %@ ", comment: ""), "\u{f150}")//NSLocalizedString("-----Select----"  , comment: "")
//                            //                            self.label3.text = profileFieldString2
//                            label.setText(configValue , afterInheritingLabelAttributesAndConfiguringWithBlock: { (mutableAttributedString: NSMutableAttributedString!) -> NSMutableAttributedString! in
//                                
//                                let boldFont1 = CTFontCreateWithName("FontAwesome", 16, nil)
//                                
//                                let range1 = (configValue as NSString).rangeOfString(configValue as String)
//                                mutableAttributedString.addAttribute(kCTFontAttributeName as String, value: boldFont1, range: range1)
//                                mutableAttributedString.addAttribute(kCTForegroundColorAttributeName as String, value:textColorMedium , range: range1)
//                                
//                                
//                                return mutableAttributedString
//                            })
//                            label.sizeToFit()
//                            //
//                            label.frame.size.height = 30
//                            //                         label.frame.size.width = label.frame.size.width + 5
//                            if label.frame.size.width < 200{
//                                label.frame.size.width = 200
//                            }
//                            
//                            
//                            let range = (configValue as NSString).rangeOfString(configValue as String)
//                            //                        label.addLinkToTransitInformation(["type" : "config", "tag" : label.tag], withRange:range)
//                            //                        if components["multiOptions"] != nil{
//                            label.addLinkToTransitInformation(["multioption" : multioption ,"type" : "config", "tag" : label.tag,"name" : (components["name"] as? String)!,"typeName" :(components["typeName"] as? String)!], withRange:range)
//                            //                        }
//                            //
//                            
//                            
//                            /// response
//                            
//                            if reachability.isReachable() {
//                                removeAlert()
//                                
//                                
//                                
//                                var dic = Dictionary<String, String>()
//                                dic = ["\(components["name"] as! String)": "\(k)","product_id": "\(self.product_id)"]
//                                let method = "GET"
//                                
//                                
//                                
//                                
//                                // Send Server Request to Explore Page Contents with Page_ID
//                                post(dic, url: "sitestore/product/variation-option", method: method) { (succeeded, msg) -> () in
//                                    dispatch_async(dispatch_get_main_queue(), {
//                                        spinner.stopAnimating()
//                                        
//                                        if msg{
//                                            
//                                            let nameField : String!
//                                            if let response = succeeded["body"] as? NSDictionary
//                                            {
//                                                
//                                                if var field = response["field"] as? NSDictionary{
//                                                    if let nameOfField = field["name"] as? String{
//                                                        nameField = nameOfField
//                                                        if  self.configArrayValueChange.count > 0{
//                                                            var  i = 0
//                                                            for var configValue in self.configArrayValueChange {
//                                                                if let dic = configValue as? NSDictionary {
//                                                                    if  let name = dic["name"] as? String{
//                                                                        if nameField != nil{
//                                                                            if  name == nameField{
//                                                                                //                                                                    configValue = field
//                                                                                self.configArrayValueChange[i] = field
//                                                                            }
//                                                                            else{
//                                                                                self.configArrayValueChange[i] = configValue
//                                                                            }
//                                                                            
//                                                                        }
//                                                                        
//                                                                    }
//                                                                    
//                                                                    
//                                                                    
//                                                                }
//                                                                i = i + 1
//                                                            }
//                                                            //                                                for ob in self.scrollView.subviews{
//                                                            //                                                        if ob.tag == 1000{
//                                                            //                                                            ob.removeFromSuperview()
//                                                            //                                                        }
//                                                            //                                                    }
//                                                            
//                                                            self.browseConfigurations()
//                                                            
//                                                        }
//                                                        
//                                                        
//                                                        
//                                                        //
//                                                        
//                                                    }
//                                                    
//                                                }
//                                                //                                            print(response)
//                                                print("configArrayValue")
//                                                print(self.configArrayValueChange)
//                                                //
//                                                //                                             print("configArrayValue")
//                                                //                                            print(self.configArrayValue)
//                                                
//                                                
//                                                //
//                                                //                                                if let options = field["multiOptions"] as? NSDictionary{
//                                                //                                                    print(options)
//                                                //                                                }
//                                                //
//                                                //
//                                                //                                            }
//                                                
//                                            }
//                                            // On Success Update Page Detail
//                                            // Update Page Detail
//                                            if succeeded["message"] != nil{
//                                                self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
//                                            }
//                                            //                                        updateAfterAlert = false
//                                            //                                        self.productResponse.removeAll(keepCapacity: false)
//                                            //                                        self.popularproductResponse.removeAll(keepCapacity: false)
//                                            //                                        self.myproductResponse.removeAll(keepCapacity: false)
//                                            //                                        self.browseEntries()
//                                        }
//                                            
//                                        else{
//                                            // Handle Server Side Error
//                                            if succeeded["message"] != nil{
//                                                self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
//                                            }
//                                        }
//                                    })
//                                }
//                                
//                            }else{
//                                // No Internet Connection Message
//                                self.view.makeToast(network_status_msg, duration: 5, position: "bottom")
//                            }
//                            
//                            
//                            
//                            
//                            /// response
//                            
//                            
//                            
//                            
//                        }))
//                        
//                        
//                    }
//                    
//                    
//                }
//                if  (UIDevice.currentDevice().userInterfaceIdiom == .Phone){
//                    alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .Cancel, handler:nil))
//                }else{
//                    // Present Alert as! Popover for iPad
//                    alertController.modalPresentationStyle = UIModalPresentationStyle.Popover
//                    let popover = alertController.popoverPresentationController
//                    popover?.sourceView = UIButton()
//                    popover?.sourceRect = CGRectMake(view.bounds.width/2, view.bounds.height/2 , 1, 1)
//                    popover?.permittedArrowDirections = UIPopoverArrowDirection()
//                }
//                self.presentViewController(alertController, animated:true, completion: nil)
//                
//                
//            }
//            
//            
//            
//            //               case "poll":
//            //            let presentedVC = PollProfileViewController()
//            //            if( components["id"] is String ){
//            //                presentedVC.pollId =  Int(components["id"]! as! String)
//            //            }
//            //            else  if( components["id"] is NSNumber ){
//            //                presentedVC.pollId =   components["id"] as! Int
//            //            }
//            //            self.navigationController?.pushViewController(presentedVC, animated: false)
//            break
//            
//        case "checkbox":
//            
//            print( components["tag"] as! Int)
//            
//        default:
//            print("default")
//            
//            
//            
//        }
//        
//        
//        
//    }
//    
//}
