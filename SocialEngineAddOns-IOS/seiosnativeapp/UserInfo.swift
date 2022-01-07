//
//  UserInfo.swift
//  seiosnativeapp
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


import Foundation
import CoreData

@objc(UserInfo)
class UserInfo: NSManagedObject {

    @NSManaged var oauth_token: String
    @NSManaged var cover_image: String
    @NSManaged var display_name: String
    @NSManaged var user_id: Int
    @NSManaged var oauth_secret: String

}
