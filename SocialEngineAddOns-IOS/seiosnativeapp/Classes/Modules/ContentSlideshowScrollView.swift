//
//  ContentSlideshowScrollView.swift
//  seiosnativeapp
//
//  Created by Bigstep IOS on 8/22/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit

class ContentSlideshowScrollView: UIScrollView , UIGestureRecognizerDelegate{
    
    var contentView: UIView!
    var contentImage: UIImageView!
    var contentTitle: UILabel!
    var contentHeading: UILabel!
    var contentSelection: UIButton!
    var contentItemsCache: [AnyObject]!
    var iscomingFrom: String = ""
    var featureSponserlbl: UILabel!
    
    var adBodyLabel:UILabel!
    var cadUrl : UILabel!
    var cadTitle : UILabel!
    var ctaButton : UIButton!
    override init(frame: CGRect) {
        super.init(frame : frame)
        self.tag = 898
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
    }
    
    func browseAdsSellContent(contentItems: [AnyObject],comingFrom : String){
        
        contentItemsCache = contentItems
        iscomingFrom = comingFrom
        var i = 0
        for ob in self.subviews{
            //  if let imageView = ob as? UIImageView {
            //      if imageView.tag != 9999{
            ob.removeFromSuperview()
            //       }
            //   }
        }
        var xpoint : CGFloat = 5.0
        var widthSell : CGFloat = 0.0
        for contentItem in contentItems{
            //  xpoint  = xpoint + CGFloat(i)*self.bounds.width
            //  let xpoint = (CGFloat(i) * (self.bounds.width)) + 10
            // if contentItems.count == 1 {
            //   widthSell = CGFloat(i)*self.bounds.width
            //  }
            //            else{
            //                widthSell = self.bounds.width * 6/8
            //            }
            widthSell = self.bounds.width - 10
            contentView = createView(CGRect(x:xpoint, y:5.0, width:widthSell - 15, height:self.bounds.height - 10), borderColor: borderColorLight, shadow: true)
            
            self.addSubview(contentView)
            contentImage = createImageView(CGRect(x:5, y:0, width:contentView.bounds.width - 10, height:160), border: false)
            contentImage.layer.cornerRadius = 2.0
            contentImage.layer.shadowColor = shadowColor.cgColor
            contentImage.layer.shadowOpacity = shadowOpacity
            contentImage.layer.shadowRadius = shadowRadius
            contentImage.layer.shadowOffset = shadowOffset
            
            
            if let url1 = contentItem["imageUrl"] as? String
            {
                let url1 = NSURL(string: url1)
                contentImage.kf.indicatorType = .activity
                (contentImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                contentImage.kf.setImage(with: url1! as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                    
                })
                contentImage.contentMode = .scaleAspectFill
                contentImage.layer.masksToBounds = true
                
            }
            else
            {
                if let strurl = contentItem as? String
                {
                    if FileManager.default.fileExists(atPath: strurl) {
                        if let url = URL(string:strurl)
                        {
                            contentImage.image = UIImage(contentsOfFile: url.path)
                        }
                    }
                }
                else
                {
                    contentImage.image = nil
                    contentImage.image = imageWithImage( UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: contentImage.bounds.width)
                }
                
            }
            contentView.addSubview(contentImage)
            
            
            
            //            contentTitle = createLabel(CGRect(x:5, y:contentImage.bounds.height + 10, width:contentView.bounds.width - 10, height:20), text: " ", alignment: .center, textColor: textColorDark)
            //            contentTitle.font = UIFont(name: fontName, size: FONTSIZENormal)
            //            contentTitle.text = contentItem["cads_title"] as? String
            //            contentTitle.lineBreakMode = .byTruncatingTail
            //            contentView.addSubview(contentTitle)
            
            cadUrl = UILabel(frame: CGRect(x: 5,y: contentImage.bounds.height + 10 + contentImage.frame.origin.y,width: contentImage.bounds.width-10,height: 40))
            cadUrl.numberOfLines = 1
            cadUrl.lineBreakMode = .byTruncatingTail
            cadUrl.textColor = textColorDark
            cadUrl.font = UIFont(name: fontBold, size: 14.0)
            contentView.addSubview(cadUrl)
            
            let description1 = String(describing: contentItem["cads_url"] as! String)
            cadUrl.text = ""//description1
            cadUrl.sizeToFit()
            cadUrl.frame.size.width = contentView.bounds.width-10
            
            cadUrl.isUserInteractionEnabled = true // Remember to do this
            let tap1: UITapGestureRecognizer = UITapGestureRecognizer(
                target: self, action: #selector(didTapLabelDemo1))
            cadUrl.addGestureRecognizer(tap1)
            tap1.delegate = self
            
            cadUrl.tag = i
            
            if contentItem["cta_button"] != nil {
                ctaButton = UIButton(frame:CGRect(x: contentView.bounds.width-(80), y: cadUrl.bounds.height +  cadUrl.frame.origin.y + 7,width: 80,height: 30))
                ctaButton.setTitle(" \(contentItem["cta_button"] as! String) ", for: .normal)
                ctaButton.titleLabel?.font = UIFont(name: fontNormal, size: FONTSIZENormal)
                ctaButton.backgroundColor = buttonColor
                ctaButton.layer.cornerRadius = 4;
                ctaButton.setTitleColor(textColorPrime, for: .normal)
                ctaButton.frame.size.width = findWidthByTextFont(" \(contentItem["cta_button"] as! String) ", fontNormal, FONTSIZENormal)
                ctaButton.frame.origin.x = contentView.bounds.width-((ctaButton.frame.size.width) + 10)
                ctaButton.frame.size.height = 30
                ctaButton.isHidden = false
                if ctaButton.titleLabel?.text == "  "{
                    ctaButton.isHidden = true
                }
                ctaButton.tag = i
                
                ctaButton.addTarget(self, action: #selector(ContentSlideshowScrollView.showSellPage), for: .touchUpInside)
                contentView.addSubview(ctaButton)
            }
            else{
                ctaButton = UIButton(frame:CGRect(x: contentView.bounds.width-(82), y: cadUrl.bounds.height +  cadUrl.frame.origin.y + 7,width: 0,height: 30))
                ctaButton.isHidden = true
                contentView.addSubview(ctaButton)
            }
            cadTitle = UILabel(frame: CGRect(x: 5,y: cadUrl.bounds.height + 5 + cadUrl.frame.origin.y,width: contentView.bounds.width-(ctaButton.frame.size.width + 10),height: 40))
            cadTitle.numberOfLines = 1
            cadTitle.lineBreakMode = .byTruncatingTail
            cadTitle.textColor = textColorDark
            cadTitle.font = UIFont(name: fontBold, size: 13.0)
            contentView.addSubview(cadTitle)
            var description2 = String(describing: contentItem["cads_title"] as! String)
            cadTitle.text = description2
            cadTitle.sizeToFit()
            cadTitle.frame.size.width = contentView.bounds.width-(ctaButton.frame.size.width + 10)
            
            
            
            
            adBodyLabel = UILabel(frame: CGRect(x: 5,y: cadTitle.bounds.height + 5 + cadTitle.frame.origin.y,width: contentView.bounds.width-(ctaButton.frame.size.width + 10),height: 40))
            adBodyLabel.numberOfLines = 2
            adBodyLabel.lineBreakMode = .byTruncatingTail
            adBodyLabel.textColor = textColorDark
            adBodyLabel.textAlignment = .left
            adBodyLabel.font = UIFont(name: fontName, size: 12.0)
            contentView.addSubview(adBodyLabel)
            var description = String(describing: contentItem["cads_body"] as! String)
            description = description.replacingOccurrences(of: "<br />", with: "\n")
            description = description.replacingOccurrences(of: "\r\n", with: "")
            adBodyLabel.text = description
            adBodyLabel.sizeToFit()
            adBodyLabel.frame.size.width = ctaButton.frame.origin.x - 10
            
            
            contentSelection = createButton(contentView.frame, title: "", border: false, bgColor: false, textColor: UIColor.clear)
            //            if comingFrom != "" {
            contentSelection.addTarget(self, action: #selector(ContentSlideshowScrollView.showSellPage), for: UIControl.Event.touchUpInside)
            //            }
            contentSelection.tag = i
            self.addSubview(contentSelection)
            i += 1
            xpoint += widthSell - 10
            // xpoint = CGFloat(i)*self.bounds.width + 10
        }
        
        
        
        
        self.contentSize = CGSize(width:xpoint ,height:20)
        // self.contentOffset.x = 10
        
        //        var scrollWidth : CGFloat = 0.0
        //      //  if contentItems.count == 1 {
        //            xpoint = (CGFloat(i) * (self.bounds.width)) + 10
        //            scrollWidth = self.bounds.width - 2*xpoint
        //       // }
        ////        else{
        ////            scrollWidth = self.bounds.width * 6/8
        ////        }
        //        let widthpoint = CGFloat(i) * (scrollWidth + 10) + 10
        //        self.contentSize = CGSize(width: widthpoint, height: 20)
    }
    @objc func didTapLabelDemo1(gesture: UITapGestureRecognizer) {
        let text = (cadUrl.text)!
        let termsRange = (text as NSString).range(of: "\(text as NSString)")
        
        if gesture.didTapAttributedTextInLabel(label: cadUrl, inRange: termsRange) {
            print("Tapped terms url")
            let tagvalue = gesture.view?.tag
            var dic = contentItemsCache[tagvalue!] as! NSDictionary
            if dic["cads_url"] != nil
            {
                
                fromExternalWebView = true
                storeUpdate = false
                let presentedVC = ExternalWebViewController()
                presentedVC.url = dic["cads_url"] as? String ?? ""
                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                let navigationController = UINavigationController(rootViewController: presentedVC)
                self.parentViewController()!.navigationController?.pushViewController(presentedVC, animated: true)
            }
        } else {
            print("Tapped none")
        }
    }
    func browseSellContent(contentItems: [AnyObject],comingFrom : String){
        
        contentItemsCache = contentItems
        iscomingFrom = comingFrom
        var i = 0
        for ob in self.subviews{
            //  if let imageView = ob as? UIImageView {
            //      if imageView.tag != 9999{
            ob.removeFromSuperview()
            //       }
            //   }
        }
        for contentItem in contentItems{
            var widthSell : CGFloat = 0.0
            let xpoint = (CGFloat(i) * ((self.bounds.width * 6/8) + 10) + 10)
            if contentItems.count == 1 {
                widthSell = self.bounds.width - 2*xpoint
            }
            else{
                widthSell = self.bounds.width * 6/8
            }
            contentView = createView(CGRect(x:xpoint, y:5, width:widthSell, height:self.bounds.height - 10), borderColor: borderColorLight, shadow: true)
            
            self.addSubview(contentView)
            contentImage = createImageView(CGRect(x:0, y:0, width:contentView.bounds.width, height:contentView.bounds.height), border: false)
            contentImage.layer.cornerRadius = 2.0
            contentImage.layer.shadowColor = shadowColor.cgColor
            contentImage.layer.shadowOpacity = shadowOpacity
            contentImage.layer.shadowRadius = shadowRadius
            contentImage.layer.shadowOffset = shadowOffset
            
            
            if let url1 = contentItem["image_main"] as? String
            {
                let url1 = NSURL(string: url1)
                contentImage.kf.indicatorType = .activity
                (contentImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                contentImage.kf.setImage(with: url1! as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                    
                })
                contentImage.contentMode = .scaleAspectFill
                contentImage.layer.masksToBounds = true
                
            }
            else
            {
                if let strurl = contentItem as? String
                {
                    if FileManager.default.fileExists(atPath: strurl) {
                        if let url = URL(string:strurl)
                        {
                            contentImage.image = UIImage(contentsOfFile: url.path)
                        }
                    }
                }
                else
                {
                    contentImage.image = nil
                    contentImage.image = imageWithImage( UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: contentImage.bounds.width)
                }
                
            }
            contentView.addSubview(contentImage)
            
            
            
            contentTitle = createLabel(CGRect(x:5, y:contentImage.bounds.height + 10, width:contentView.bounds.width - 10, height:20), text: " ", alignment: .center, textColor: textColorDark)
            contentTitle.font = UIFont(name: fontName, size: FONTSIZENormal)
            contentTitle.text = contentItem["title"] as? String
            contentTitle.lineBreakMode = .byTruncatingTail
            contentView.addSubview(contentTitle)
            contentSelection = createButton(contentView.frame, title: "", border: false, bgColor: false, textColor: UIColor.clear)
            //            if comingFrom != "" {
            //            contentSelection.addTarget(self, action: #selector(ContentSlideshowScrollView.showSellPage), for: UIControl.Event.touchUpInside)
            //            }
            contentSelection.tag = i
            self.addSubview(contentSelection)
            i += 1
            
        }
        var scrollWidth : CGFloat = 0.0
        if contentItems.count == 1 {
            let xpoint = (CGFloat(i) * ((self.bounds.width * 6/8) + 10) + 10)
            scrollWidth = self.bounds.width - 2*xpoint
        }
        else{
            scrollWidth = self.bounds.width * 6/8
        }
        let widthpoint = CGFloat(i) * (scrollWidth + 10) + 10
        self.contentSize = CGSize(width: widthpoint, height: 20)
    }
    @objc func showSellPage(sender: UIButton)
    {
        
        var dic:NSDictionary!
        dic = contentItemsCache[sender.tag] as! NSDictionary
        print("syz : \(dic?["cads_url"] as? String ?? "") ==== \(dic["cads_title"] as! String)")
        // let dic = communityAdsValues[sender.tag] as? NSDictionary
        if dic?["cads_url"] != nil
        {
            
            fromExternalWebView = true
            let presentedVC = ExternalWebViewController()
            presentedVC.url = dic?["cads_url"] as? String ?? ""
            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            self.parentViewController()!.navigationController?.pushViewController(presentedVC, animated: true)
        }
    }
    
    func browseContent(contentItems: [AnyObject],comingFrom : String){
        
        contentItemsCache = contentItems
        iscomingFrom = comingFrom
        var i = 0
        for contentItem in contentItems{
            
            let xpoint = (CGFloat(i) * ((self.bounds.width * 3/8) + 10) + 10)
            contentView = createView(CGRect(x:xpoint, y:5, width:self.bounds.width * 3/8, height:self.bounds.height - 10), borderColor: borderColorLight, shadow: true)
            
            self.addSubview(contentView)
            contentImage = createImageView(CGRect(x:0, y:0, width:contentView.bounds.width, height:contentView.bounds.height - 40), border: false)
            contentImage.layer.cornerRadius = 2.0
            contentImage.layer.shadowColor = shadowColor.cgColor
            contentImage.layer.shadowOpacity = shadowOpacity
            contentImage.layer.shadowRadius = shadowRadius
            contentImage.layer.shadowOffset = shadowOffset
            contentImage.contentMode = .scaleAspectFill
            contentImage.layer.masksToBounds = true
            
            if let url1 = contentItem["image"] as? String
            {
                let url1 = NSURL(string: url1)
                contentImage.kf.indicatorType = .activity
                (contentImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                contentImage.kf.setImage(with: url1! as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                    
                })
            }
                
            else
            {
                contentImage.image = nil
                contentImage.image = imageWithImage( UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: contentImage.bounds.width)
                
            }
            contentView.addSubview(contentImage)
            
            if iscomingFrom != ""
            {
                featureSponserlbl = createLabel(CGRect(x:5, y:0, width:60, height:20), text: " ", alignment: .center, textColor: textColorLight)
                featureSponserlbl.font = UIFont(name: fontName, size: FONTSIZESmall)
                featureSponserlbl.text = NSLocalizedString("Featured",  comment: "")
                featureSponserlbl.textAlignment = .center
                featureSponserlbl.backgroundColor = buttonColor
                contentImage.addSubview(featureSponserlbl)
            }
            contentTitle = createLabel(CGRect(x:5, y:contentImage.bounds.height + 10, width:contentView.bounds.width - 10, height:20), text: " ", alignment: .center, textColor: textColorDark)
            contentTitle.font = UIFont(name: fontName, size: FONTSIZENormal)
            contentTitle.text = contentItem["title"] as? String
            contentTitle.lineBreakMode = .byTruncatingTail
            contentView.addSubview(contentTitle)
            contentSelection = createButton(contentView.frame, title: "", border: false, bgColor: false, textColor: UIColor.clear)
            contentSelection.addTarget(self, action: #selector(ContentSlideshowScrollView.showStoreProfile), for: UIControl.Event.touchUpInside)
            contentSelection.tag = i
            self.addSubview(contentSelection)
            i += 1
            
        }
        
        let widthpoint = CGFloat(i) * ((self.bounds.width * 3/8) + 10) + 10
        self.contentSize = CGSize(width: widthpoint, height: 20)
    }
    
    @objc func showStoreProfile(sender: UIButton)
    {
        
        var storeInfo:NSDictionary!
        storeInfo = contentItemsCache[sender.tag] as! NSDictionary
        
        if(storeInfo["allow_to_view"] as! Int == 1)
        {
            switch iscomingFrom {
            case "Advanced Video":
                let presentedVC = AdvanceVideoProfileViewController()
                presentedVC.videoId = storeInfo["video_id"] as! Int
                presentedVC.videoType = storeInfo["type"] as? Int
                presentedVC.subjectType = "sitevideo_channel"//"core_main_sitevideo"
                if  storeInfo["type"] as! Int == 3 || storeInfo["type"] as! Int == 2 || storeInfo["type"] as! Int == 1 {
                    presentedVC.videoUrl = storeInfo["video_url"] as! String
                }
                else{
                    presentedVC.videoUrl = storeInfo["content_url"] as! String
                }
                
                let nativationController = UINavigationController(rootViewController: presentedVC)
                nativationController.modalPresentationStyle = .fullScreen
                self.parentViewController()!.present(nativationController, animated:true, completion: nil)
                break
                
            case "Channel":
                
                if(storeInfo["allow_to_view"] as! Int == 1)
                {
                    let presentedVC = ChannelProfileViewController()
                    presentedVC.subjectId = "\(storeInfo["channel_id"]!)"
                    presentedVC.subjectType = "sitevideo_channel"//"core_main_sitevideochannel"
                    self.parentViewController()!.navigationController?.pushViewController(presentedVC, animated: true)
                    
                }
                
                break
            case "":
                let presentedVC = StoresProfileViewController()
                presentedVC.storeId = "\(storeInfo["store_id"]!)"
                presentedVC.subjectType = "sitestore_store"
                self.parentViewController()!.navigationController?.pushViewController(presentedVC, animated: true)
                break
                
            default:
                let presentedVC = StoresProfileViewController()
                presentedVC.storeId = "\(storeInfo["store_id"]!)"
                presentedVC.subjectType = "sitestore_store"
                self.parentViewController()!.navigationController?.pushViewController(presentedVC, animated: true)
            }
            
        }
        else
        {
            self.parentViewController()!.view.makeToast( NSLocalizedString("You do not have permission to view this private page.",  comment: ""), duration: 5, position: "bottom")
            
        }
        
    }
    
    func browseProducts(contentItems: [AnyObject]){
        
        contentItemsCache = contentItems
        var i = 0
        var size:CGFloat = 0;
        var origin_x:CGFloat =  PADING
        if(UIDevice.current.userInterfaceIdiom == .pad){
            size = (UIScreen.main.bounds.width - (5 * PADING))/3
        }else{
            
            
            if contentItems.count > 2{
                size = ((UIScreen.main.bounds.width) - (4 * PADING))/2 - 5
                
            }
            else{
                
                size = ((UIScreen.main.bounds.width) - (2 * PADING))/2
            }
            
        }
        for contentItem in contentItems{
            
            contentView = createView(CGRect(x:origin_x, y:2, width:size, height:170-5), borderColor: UIColor.white, shadow: true)
            self.addSubview(contentView)
            
            contentImage = createImageView(CGRect(x:PADING, y:0, width:contentView.bounds.width - 2 * PADING, height:contentView.bounds.height - ( 2 * contentPADING) - (30)), border: false)
            if let photoId = contentItem["photo_id"] as? Int{
                
                if photoId != 0{
                    let url1 = NSURL(string: contentItem["image"] as! NSString as String)
                    contentImage.kf.indicatorType = .activity
                    (contentImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    contentImage.kf.setImage(with: url1! as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                        
                    })
                    contentImage.contentMode =  UIView.ContentMode.scaleAspectFit
                }
                else{
                    contentImage.image = nil
                    contentImage.image = imageWithImage( UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: contentImage.bounds.width)
                    
                }
            }
            contentView.addSubview(contentImage)
            
            contentTitle = createLabel(CGRect(x:5, y:contentImage.frame.origin.y + contentImage.bounds.height + 5,  width:contentView.bounds.width - 10, height:30), text: "", alignment: .left, textColor: UIColor.black)
            var title = contentItem["title"] as! String
            if title.length > 30{
                title = (title as NSString).substring(to: 30-3)
                title  = title + "..."
            }
            contentTitle.text = title
            contentTitle.font = UIFont(name: fontBold, size: FONTSIZESmall)
            contentTitle.numberOfLines = 2
            contentView.addSubview(contentTitle)
            
            
            contentSelection = createButton(contentView.frame, title: "", border: false, bgColor: false, textColor: UIColor.clear)
            contentSelection.addTarget(self, action: #selector(ContentSlideshowScrollView.showProduct), for: UIControl.Event.touchUpInside)
            contentSelection.tag = i
            self.addSubview(contentSelection)
            
            i += 1
            origin_x += size
            
        }
        
        self.contentSize = CGSize(width: origin_x + (2 * PADING), height: 170-5)
        
    }
    
    @objc func showProduct(sender: UIButton){
        
        var productInfo:NSDictionary!
        productInfo = contentItemsCache[sender.tag] as! NSDictionary
        
        let presentedVC = ProductProfilePage()
        let store_id =   productInfo["store_id"] as? Int
        let product_id =   productInfo["product_id"] as? Int
        presentedVC.product_id = "\(product_id!)"
        presentedVC.store_id = store_id
        self.parentViewController()!.navigationController?.pushViewController(presentedVC, animated: true)
        
    }
    
    //    func showSellPage(sender: UIButton){
    //
    //
    //
    //        let presentedVC = ExternalWebViewController()
    //        presentedVC.url = iscomingFrom
    //        presentedVC.fromDashboard = false
    //        self.parentViewController()!.navigationController?.pushViewController(presentedVC, animated: true)
    //
    //
    //
    //    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
