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
//  ActivityFeed.swift
//  seiosnativeapp


import Foundation
var feedMode:Int?
class ActivityFeed {
    
    
    var subject_image:String?               // For Feed Subject Image
    var feed_title:String?                  // For Feed MainContent
    var feed_createdAt:String?
    var feed_privacy:String?                // Feed Creation Time
    var feed_privacyIcon: String?
    var comment_count:Int?                  // Feed CommentCount
    var likes_count:Int?                    // Feed Like Count
    var attachment:NSArray?                 // Feed Attachments
    var attactment_Count:Int?               // Feed Total Attachment Count
    var action_id:Int?                      // Feed Action ID
    var feed_Type :String?                  // Feed Type
    var feed_menus:NSArray?                 // Feed Gutter Menus
    var feed_footer_menus:NSDictionary?     // Feed Footer Menus
    var comment:Bool?                       // CanComment
    var delete:Bool?                        // CanDelete
    var share:Bool?                         // CanShare
    var is_like:Bool?                       // Feed is_Like (Like/UnLike)
    var photo_attachment_count:Int?         // Feed Attached Photo Count
    var params:NSDictionary?                // Feed Checkin Location
    var tags:NSArray?                       // Feed Friend Tagging
    var object_id:Int?                      // Feed Friend Tagging
    var object_type:String?                 // Feed Friend Tagging
    var action_type_body_params:NSArray?
    var action_type_body:String?
    var object : NSDictionary?
     var subject_id:Int?
    var share_params_id:Int?               // For Share Feed Id
    var share_params_type:String?          // For Share Feed Type
    var hashtags : NSArray?
    var feed_reactions : NSDictionary?
    var my_feed_reaction : NSDictionary?
    var userTag : NSArray?
    var decoration : NSDictionary?
    var wordStyle : NSArray?
    var publish_date : String?
    var isNotificationTurnedOn : Bool?
    var pin_post_duration : Int?
    var isPinned : Bool?
    var attachment_content_type : String?
    

    // Initialize ActivityFeed Dictionary For Comments
    init(dictionary:NSDictionary) {
        
        
        if feedMode == 1{
        subject_image = (dictionary["feed"] as! NSDictionary)["feed_icon"]  as? String
        feed_title = (dictionary["feed"] as! NSDictionary)["feed_title"]  as? String
        feed_createdAt = (dictionary["feed"] as! NSDictionary)["date"]  as? String
        feed_privacy = (dictionary["feed"] as! NSDictionary)["privacy"]  as? String
            feed_privacyIcon = (dictionary["feed"] as! NSDictionary)["privacy_icon"]  as? String
        comment_count = (dictionary["feed"] as! NSDictionary)["comment_count"] as? Int
        likes_count = (dictionary["feed"] as! NSDictionary)["like_count"] as? Int
        attachment = (dictionary["feed"] as! NSDictionary)["attachment"] as? NSArray
        attachment_content_type = (dictionary["feed"] as! NSDictionary)["attachment_content_type"] as? String
        attactment_Count = (dictionary["feed"] as! NSDictionary)["attachment_count"]  as? Int
        action_id = (dictionary["feed"] as! NSDictionary)["action_id"]  as? Int
        subject_id = (dictionary["feed"] as! NSDictionary)["subject_id"]  as? Int
        feed_Type = (dictionary["feed"] as! NSDictionary)["type"]  as? String
        feed_menus = dictionary["feed_menus"]  as? NSArray
        feed_footer_menus = dictionary["feed_footer_menus"]  as? NSDictionary
        comment = dictionary["can_comment"]  as? Bool
        delete = dictionary["can_delete"]  as? Bool
        share = dictionary["can_share"]  as? Bool
        is_like = dictionary["is_like"]  as? Bool
        share_params_id = (dictionary["feed"] as! NSDictionary)["share_params_id"]  as? Int
        share_params_type = (dictionary["feed"] as! NSDictionary)["share_params_type"]  as? String
        photo_attachment_count = (dictionary["feed"] as! NSDictionary)["photo_attachment_count"]  as? Int
        params = (dictionary["feed"] as! NSDictionary)["params"]  as? NSDictionary
        tags = (dictionary["feed"] as! NSDictionary)["tags"]  as? NSArray
        object_id =  (dictionary["feed"] as! NSDictionary)["object_id"]  as? Int
        object_type = (dictionary["feed"] as! NSDictionary)["object_type"]  as? String
        action_type_body_params =  (dictionary["feed"] as! NSDictionary)["action_type_body_params"]  as? NSArray
        object = (dictionary["feed"] as! NSDictionary)["object"]  as? NSDictionary
        action_type_body = (dictionary["feed"] as! NSDictionary)["action_type_body"]  as? String
        hashtags = dictionary["hashtags"] as? NSArray
        feed_reactions = dictionary["feed_reactions"]  as? NSDictionary
        my_feed_reaction = dictionary["my_feed_reaction"]  as? NSDictionary
        userTag = (dictionary["feed"] as! NSDictionary)["userTag"] as? NSArray
        decoration = (dictionary["feed"] as! NSDictionary)["decoration"] as? NSDictionary
        wordStyle = (dictionary["feed"] as! NSDictionary)["wordStyle"] as? NSArray
        publish_date = (dictionary["feed"] as! NSDictionary)["publish_date"]  as? String
        isNotificationTurnedOn = dictionary["isNotificationTurnedOn"]  as? Bool
        pin_post_duration = dictionary["pin_post_duration"]  as? Int
        isPinned = dictionary["isPinned"]  as? Bool

            
        }
        else if feedMode == 2{
            subject_image = dictionary["subject_image"] as? String
            feed_title = dictionary["feed_title"] as? String
            feed_createdAt = dictionary["feed_createdAt"] as? String
            comment_count = dictionary["comment_count"] as? Int
            likes_count = dictionary["likes_count"] as? Int
            attachment = dictionary["attachment"] as? NSArray
            attachment_content_type = dictionary["attachment_content_type"] as? String
            attactment_Count = dictionary["attactment_Count"] as? Int
            action_id = dictionary["action_id"]  as? Int
            subject_id = dictionary["subject_id"]  as? Int
            feed_Type = dictionary["feed_Type"] as? String
            feed_menus = dictionary["feed_menus"]  as? NSArray
            feed_footer_menus = dictionary["feed_footer_menus"]  as? NSDictionary
            share_params_id = dictionary["share_params_id"]  as? Int
            share_params_type = dictionary["share_params_type"]  as? String

            comment = dictionary["comment"]  as? Bool
            delete = dictionary["delete"]  as? Bool
            share = dictionary["can_share"]  as? Bool
            is_like = dictionary["is_like"]  as? Bool
            photo_attachment_count = dictionary["photo_attachment_count"]  as? Int
            params = dictionary["params"] as? NSDictionary
            tags = dictionary["tags"] as? NSArray
            object_id = dictionary["object_id"]  as? Int
            object_type = dictionary["object_type"]  as? String
            action_type_body_params =  dictionary["action_type_body_params"]  as? NSArray
            object = (dictionary["feed"] as! NSDictionary)["object"]  as? NSDictionary
            action_type_body = (dictionary["feed"] as! NSDictionary)["action_type_body"]  as? String
            hashtags = dictionary["hashtags"] as? NSArray
            feed_reactions = dictionary["feed_reactions"]  as? NSDictionary
            my_feed_reaction = dictionary["my_feed_reaction"]  as? NSDictionary
            userTag = dictionary["userTag"] as? NSArray
            decoration = (dictionary["feed"] as! NSDictionary)["decoration"] as? NSDictionary
            wordStyle = dictionary["wordStyle"] as? NSArray
            publish_date = dictionary["publish_date"] as? String
            isNotificationTurnedOn = dictionary["isNotificationTurnedOn"]  as? Bool
            pin_post_duration = dictionary["pin_post_duration"]  as? Int
            isPinned = dictionary["isPinned"]  as? Bool
        }
    }
    
    // Add feeds in ActivityFeed from Server Response
    class func loadActivityFeedInfo(_ feedArray:NSArray) -> [ActivityFeed]
    {
        feedMode  = 1
        var feeds:[ActivityFeed] = []
        for obj:Any in feedArray {
            let activityFeedDictionary = obj as! NSDictionary
            let activityFeed = ActivityFeed(dictionary: activityFeedDictionary)
            feeds.append(activityFeed)
        }
        return feeds
    }
    
    class func loadActivityFeedInfofromDictionary(_ feedDic:NSDictionary) -> [ActivityFeed]
    {
        feedMode  = 2
        var feeds:[ActivityFeed] = []
        let activityFeedDictionary = feedDic as NSDictionary
        let activityFeed = ActivityFeed(dictionary: activityFeedDictionary)
        feeds.append(activityFeed)
        return feeds
    }

    
}
