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


class Comment {
    
    let author_image:String?
    let author_title:String?
    var comment_body:AnyObject!
    let comment_date:String?
    let comment_id:Int?
    let delete:NSDictionary!
    var like: NSMutableDictionary!
    let user_id : Int!
    let likeCount:Int!
    let stickerImage : NSDictionary?
    let tags : NSArray!
    let attachmentType : String?
    let wordStyle : NSArray!
    
    // Initialize Comment Dictionary For Comments
    init(dictionary:NSDictionary) {
        author_image = dictionary["author_image"] as? String
        author_title = dictionary["author_title"] as? String
        if let comment = dictionary["comment_body"] as? String
        {
            comment_body = comment as AnyObject
        }
        if let comment = dictionary["comment_body"] as? Int
        {
            comment_body = comment as AnyObject
        }
        //comment_body = dictionary["comment_body"] as? String as AnyObject!
        comment_date = dictionary["comment_date"] as? String
        comment_id = dictionary["comment_id"] as? Int
        delete = dictionary["delete"] as? NSDictionary
        like = dictionary["like"] as? NSMutableDictionary
        user_id = dictionary["user_id"] as? Int
        stickerImage = dictionary["attachment"] as? NSDictionary
        likeCount = dictionary["like_count"] as? Int
        tags = dictionary["userTag"] as? NSArray
        attachmentType =  dictionary["attachment_type"] as? String
        wordStyle = dictionary["wordStyle"] as? NSArray
    }
    
    // Add Comments in Comment from Server Response
    class func loadComments(_ commentsArray:NSArray) -> [Comment]
    {
        var comments:[Comment] = []
        for obj:Any in commentsArray {
            let commentDictionary = obj as! NSDictionary
            let comment = Comment(dictionary: commentDictionary)
            comments.append(comment)
        }
        return comments
    }
    
    class func loadCommentsfromDictionary(_ commentsDic:NSDictionary) -> [Comment]
    {
        var comments:[Comment] = []
        let commentDictionary = commentsDic as NSDictionary
        let comment = Comment(dictionary: commentDictionary)
        comments.append(comment)
        
        return comments
    }
    
}
