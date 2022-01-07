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


//  Comment.swift
//  seiosnativeapp

import Foundation


class Notifications {
    
    let feed_title:String?
    let type:String?
    let notification_date:String?
    let notification_id:Int?
    let subject:NSDictionary!
    let object: NSDictionary!
    let params: NSDictionary!
    let read:Int!
    let show:Int!
    let object_type: String!
    let url:String!
    let actionBodyParam : NSArray!
    
    // Initialize Comment Dictionary For Comments
    init(dictionary:NSDictionary) {
        feed_title = dictionary["feed_title"] as? String
        type = dictionary["type"] as? String
        notification_date = dictionary["date"] as? String
        notification_id = dictionary["notification_id"] as? Int
        subject = dictionary["subject"] as? NSDictionary
        object = dictionary["object"] as? NSDictionary
        params = dictionary["params"] as? NSDictionary
        read = dictionary["read"] as? Int
        show = dictionary["show"] as? Int
        object_type = dictionary["object_type"] as? String
        url = dictionary["url"] as? String
        actionBodyParam = dictionary["action_type_body_params"] as? NSArray
        
    }
    
    // Add Comments in Comment from Server Response
    class func loadNotifications(_ notificationsArray:NSArray) -> [Notifications]
    {
        var notifications:[Notifications] = []
        for obj:Any in notificationsArray {
            let notificatonDictionary = obj as! NSDictionary
            let notification = Notifications(dictionary: notificatonDictionary)
            notifications.append(notification)
        }
        return notifications
    }
    
    class func loadNotificationsfromDictionary(_ notificationsDic:NSDictionary) -> [Notifications]
    {
        var notifications:[Notifications] = []
        // for obj:AnyObject in commentsDic {
        let notificationDictionary = notificationsDic as NSDictionary
        let notification = Notifications(dictionary: notificationDictionary)
        notifications.append(notification)
        //  }
        return notifications
    }
    
}
