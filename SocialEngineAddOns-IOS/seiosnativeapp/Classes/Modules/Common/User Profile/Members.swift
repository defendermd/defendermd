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
//  Members.swift
//  seiosnativeapp
//

import Foundation


class Members {
    
    var image_profile:String?
    var image_normal:String?
    var displayname:String?
    var username:String?
    var delete:NSDictionary!
    var menus: NSMutableDictionary!
    var user_id : Int!
    var age: Int!
    var mutualFriendCount: Int!
    var location: String!
    var memberStatus: Int!
    var isVerified : Int!
    var latitude = 0.0
    var longitude = 0.0
    var mapData : NSDictionary!
    var is_member_verified: Int!

    
    // Initialize Comment Dictionary For Comments
    init(dictionary:NSDictionary) {
        image_profile = dictionary["image_profile"]    as? String
        image_normal = dictionary["image_normal"]    as? String
        displayname = dictionary["displayname"]    as? String
        username = dictionary["username"]    as? String
        menus =         dictionary["menus"] as? NSMutableDictionary
        mapData = dictionary["mapData"] as? NSDictionary
        user_id =      dictionary["user_id"] as? Int
        is_member_verified = dictionary["is_member_verified"] as? Int
        
        if let lat = dictionary["latitude"] as? Double{
            latitude = lat
        }
        if let lang = dictionary["longitude"] as? Double{
            longitude = lang
        }
        
        if dictionary["age"] as? Int != nil{
            age = dictionary["age"] as? Int
        }
        
        if dictionary["mutualFriendCount"] as? Int != nil{
            mutualFriendCount = dictionary["mutualFriendCount"] as? Int
        }
        
        if dictionary["location"] as? String != nil && dictionary["location"] as? String != ""{
            location = dictionary["location"] as? String
        }
        
        if dictionary["memberStatus"] as? Int != nil{
            memberStatus = dictionary["memberStatus"] as? Int
        }
        if dictionary["isVerified"] as? Int != nil{
            isVerified = dictionary["isVerified"] as? Int
        }
    }
    
    // Add Comments in Comment from Server Response
    class func loadMembers(_ membersArray:NSArray) -> [Members]
    {
        var members:[Members] = []
        for obj:Any in membersArray {
            let memberDictionary = obj as! NSDictionary
            let member = Members(dictionary: memberDictionary)
            members.append(member)
        }
        return members
    }
    
    class func loadCommentsfromDictionary(_ membersDic:NSDictionary) -> [Members]
    {
        var members:[Members] = []
        // for obj:AnyObject in commentsDic {
        let memberDictionary = membersDic as NSDictionary
        let member = Members(dictionary: memberDictionary)
        members.append(member)
        //  }
        return members
    }
    
}
