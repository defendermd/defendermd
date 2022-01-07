//
//  fbAdsView.swift
//  seiosnativeapp
//
//  Created by bigstep on 12/11/19.
//  Copyright © 2019 bigstep. All rights reserved.
//

import Foundation
import UIKit

class FbAdsView: UIView {
    var nativeAd: FBNativeAd?
    var adChoicesView: FBAdChoicesView?
    var adiconview: UIImageView?
    var adTitleLabel: UILabel?
    var adImageView: FBMediaView?
    var adCallToActionButton: UIButton?
    var adBodyLabel: UILabel?
    var adSocialContextLabel: UILabel?
    var adSocialSiteLabel: UILabel?
    var viewController: UIViewController?
    
    init(frame: CGRect, nativeAd: FBNativeAd, viewController: UIViewController) {
        super.init(frame: frame)
        self.nativeAd = nativeAd
        self.viewController = viewController
        fetchAds(self.nativeAd!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fetchAds(_ nativeAd: FBNativeAd)
    {
        self.backgroundColor = UIColor.white
        self.tag = 1001001
        
        adChoicesView = FBAdChoicesView(frame: CGRect(x: self.frame.size.width-5, y: 5, width: 10, height: 15))
        adChoicesView?.nativeAd = nativeAd
        adChoicesView?.updateFrameFromSuperview()
        self.addSubview(self.adChoicesView!)
        
        self.adiconview = UIImageView(frame: CGRect(x: 5, y: 5, width: 60, height: 60))
        self.addSubview(self.adiconview!)
        
        adTitleLabel = UILabel(frame: CGRect(x: (self.adiconview?.bounds.width)! + 10 , y: 10, width: self.bounds.width-((self.adiconview?.bounds.width)! + 55), height: 40))
        adTitleLabel?.numberOfLines = 0
        adTitleLabel?.textColor = textColorDark
        adTitleLabel?.font = UIFont(name: fontBold, size: FONTSIZENormal)
        adTitleLabel?.text = nativeAd.advertiserName
        adTitleLabel?.sizeToFit()
        self.addSubview(adTitleLabel!)
        
        adSocialContextLabel = UILabel(frame: CGRect(x: (self.adiconview?.bounds.width)! + 10 , y: getBottomEdgeY(inputView: adTitleLabel!) + 5, width: self.bounds.width-((self.adiconview?.bounds.width)! + 55), height: 30))
        adSocialContextLabel?.numberOfLines = 1
        adSocialContextLabel?.textColor = textColorDark
        adSocialContextLabel?.font = UIFont(name: fontNormal, size: FONTSIZENormal)
        adSocialContextLabel?.text = nativeAd.sponsoredTranslation
        adSocialContextLabel?.sizeToFit()
        self.addSubview(adSocialContextLabel!)
        
        adImageView = FBMediaView(frame: CGRect(x: 0 , y: (self.adiconview?.bounds.height)! + 10 + (self.adiconview?.frame.origin.y)!, width: self.bounds.width, height: 170))
        self.adImageView?.clipsToBounds = true
        self.addSubview(adImageView!)
        
        adSocialSiteLabel = UILabel(frame: CGRect(x: 10 , y: (adImageView?.bounds.height)! + 10 + (adImageView?.frame.origin.y)!, width: self.bounds.width-((self.adiconview?.bounds.width)! + 55), height: 30))
        adSocialSiteLabel?.numberOfLines = 0
        adSocialSiteLabel?.textColor = textColorDark
        adSocialSiteLabel?.textAlignment = .left
        adSocialSiteLabel?.font = UIFont(name: fontNormal, size: FONTSIZENormal)
        adSocialSiteLabel?.text = nativeAd.socialContext
        adSocialSiteLabel?.sizeToFit()
        self.addSubview(adSocialSiteLabel!)
        
        
        adBodyLabel = UILabel(frame: CGRect(x: 10 , y: (adImageView?.bounds.height)! + 10 + (adImageView?.frame.origin.y)! + (adSocialSiteLabel?.bounds.height)! , width: self.bounds.width-120, height: 60))
        if let _ = nativeAd.bodyText {
            adBodyLabel?.text = nativeAd.bodyText
        }
        
        adBodyLabel?.numberOfLines = 0
        adBodyLabel?.textColor = textColorDark
        adBodyLabel?.textAlignment = .left
        adBodyLabel?.font = UIFont(name: fontName, size: FONTSIZENormal)
        self.addSubview(adBodyLabel!)
        
        adCallToActionButton = UIButton(frame:CGRect(x: self.bounds.width-100,y: (self.adImageView?.bounds.height)! + 25 + (self.adImageView?.frame.origin.y)! + (adSocialSiteLabel?.bounds.height)!, width: 95, height: 30))
        
        adCallToActionButton?.setTitle(
            nativeAd.callToAction, for: UIControl.State())
        
        adCallToActionButton?.titleLabel?.font = UIFont(name: fontBold , size: FONTSIZESmall)
        adCallToActionButton?.titleLabel?.textColor = UIColor.blue//navColor
        adCallToActionButton?.backgroundColor = UIColor(red: 59/255 , green: 89/255 , blue: 152/255, alpha: 1.0)//UIColor.red//navColor 59,89,152
        adCallToActionButton?.layer.cornerRadius = 4; // this value vary as per your desire
        adCallToActionButton?.clipsToBounds = true
        self.addSubview(adCallToActionButton!)
        
        self.adTitleLabel?.nativeAdViewTag = FBNativeAdViewTag.title
        self.adBodyLabel?.nativeAdViewTag = FBNativeAdViewTag.body;
        self.adSocialSiteLabel?.nativeAdViewTag = FBNativeAdViewTag.socialContext;
        self.adCallToActionButton?.nativeAdViewTag = FBNativeAdViewTag.callToAction;
        
        nativeAd.registerView(forInteraction: self, mediaView: adImageView!, iconImageView: adiconview!, viewController: viewController)
        
    }
}
