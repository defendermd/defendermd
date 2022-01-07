//
//  StoreReviewHelper.swift
//  seiosnativeapp
//
//  Created by Vidit Paliwal on 28/05/18.
//  Copyright © 2018 bigstep. All rights reserved.
//

import Foundation
import StoreKit
import UIKit

let Defaults = UserDefaults.standard

struct UserDefaultsKeys
{
    static let APP_OPENED_COUNT = "APP_OPENED_COUNT"
}

class StoreReviewHelper : UIViewController
{
    static func incrementAppOpenedCount ()
    {
        guard var appOpenCount = Defaults.value(forKey: UserDefaultsKeys.APP_OPENED_COUNT) as? Int else {
            Defaults.set(1, forKey: UserDefaultsKeys.APP_OPENED_COUNT)
            return
        }
        
        appOpenCount += 1
        Defaults.set(appOpenCount, forKey: UserDefaultsKeys.APP_OPENED_COUNT)
        
    }
}
