
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
//  PhotoViewer.swift
//  seiosnativeapp
//

import Foundation

class LikeCommentView {
    
      let reactions :NSDictionary?
    var my_feed_reaction : NSDictionary?
    var feed_reaction : NSDictionary?
    let is_like:Bool?
    var comments_count:Int?
    var likes_count:Int?
    let canComment : Int?
    // Initialize Comment Dictionary For Comments
    init(dictionary:NSDictionary) {
        
        
        reactions = dictionary["reactions"] as? NSDictionary
        
        if let _ = dictionary["feed_reactions"]{
            feed_reaction = dictionary["feed_reactions"] as? NSDictionary
        }
        if let _ = dictionary["my_feed_reaction"]{
            my_feed_reaction = dictionary["my_feed_reaction"] as? NSDictionary
        }
         is_like = dictionary["isLike"] as? Bool
        comments_count = dictionary["totalComments"] as? Int
        if let _ = dictionary["totalLikes"]
        {
            likes_count = dictionary["totalLikes"] as? Int
        }
        canComment = dictionary["canComment"] as? Int

        
        
    }
    
    
    // Add Photos in PhotoViewer from Server Response
    class func loadPhotosInfo(_ photosArray:NSArray) -> [LikeCommentView]
    {
        var photos:[LikeCommentView] = []
        for obj:Any in photosArray {
            let photoViewerDictionary = obj as! NSDictionary
            let photo = LikeCommentView(dictionary: photoViewerDictionary)
            photos.append(photo)
        }
        return photos
    }
    
    class func loadPhotosInfoDictionary(_ PhotosDic:NSDictionary) -> [LikeCommentView]
    {
        var Photos:[LikeCommentView] = []
        // for obj:AnyObject in commentsDic {
        let photoDictionary = PhotosDic as NSDictionary
        let Photo = LikeCommentView(dictionary: photoDictionary)
        Photos.append(Photo)
        return Photos
    }
    
}
