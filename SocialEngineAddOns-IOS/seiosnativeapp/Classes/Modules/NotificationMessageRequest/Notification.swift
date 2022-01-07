//
//  Comment.swift
//  seiosnativeapp
//
//  Created by bigstep on 15/01/15.
//  Copyright (c) 2015 bigstep. All rights reserved.
//

import Foundation


class Notification {
    
    let image_profile:String?
    let displayname:String?
    let menus: NSMutableDictionary!
    let notification_id : Int!
    
    // Initialize Comment Dictionary For Comments
    init(dictionary:NSDictionary) {
        image_profile = dictionary["image_profile"]    as? String
        displayname = dictionary["feed_title"]    as? String
        menus =         dictionary["menus"] as? NSMutableDictionary
        notification_id =      dictionary["notification_id"] as? Int
    }
    
    // Add Comments in Comment from Server Response
    class func loadMembers(membersArray:NSArray) -> [Notification]
    {
        var members:[Notification] = []
        for obj:AnyObject in membersArray {
            let memberDictionary = obj as NSDictionary
            let member = Notification(dictionary: memberDictionary)
            members.append(member)
        }
        return members
    }
    
    class func loadCommentsfromDictionary(membersDic:NSDictionary) -> [Notification]
    {
        var members:[Notification] = []
        // for obj:AnyObject in commentsDic {
        let memberDictionary = membersDic as NSDictionary
        let member = Notification(dictionary: memberDictionary)
        members.append(member)
        //  }
        return members
    }
    
}