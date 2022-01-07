//
//  FacebookAds.swift
//  seiosnativeapp
//
//  Created by bigstep on 12/11/19.
//  Copyright © 2019 bigstep. All rights reserved.
//

import Foundation
import UIKit
class FacebookAds : NSObject{
    static var admanager:FBNativeAdsManager?
    static var fbView: FbAdsView?
    static func showFacebookAd(viewController: FBNativeAdsManagerDelegate)
    {
        //FBAdSettings.addTestDevices(fbTestDevice)
        admanager = FBNativeAdsManager(placementID: placementID, forNumAdsRequested: 15)
        admanager?.delegate = viewController
        admanager?.mediaCachePolicy = FBNativeAdsCachePolicy.all
        admanager?.loadAds()
    }
    
    static func createAdView(nativeAd: FBNativeAd, viewController: UIViewController, adArray: inout [AnyObject], frame: CGRect) {
        fbView = FbAdsView(frame: frame, nativeAd: nativeAd, viewController: viewController)
        adArray.append(fbView!)
    }
}


