
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

class PhotoViewer {
    
    let photo_id:Int?
    let album_id:Int?
    var image:String?
    let loading_flag:Bool?
    let photo_title:String?
    let photo_description:String?
    var is_like:Bool?
    var comment_count:Int?
    var likes_count:Int?
    let menu:NSArray?
    let description:String?
    let reactions :NSDictionary?
    var my_feed_reaction : NSDictionary?
    var feed_reaction : NSDictionary?
    let tags : NSArray?
    var photoUrl : String?
    var photoUrlForAlbum : String?
    
    // Initialize Comment Dictionary For Comments
    init(dictionary:NSDictionary) {
        
        photo_id = dictionary["photo_id"] as? Int
        album_id = dictionary["album_id"] as? Int
        image = ""
        if let url = dictionary["image"] as? String{
            image = url
        }else{
            if dictionary["image_main"] is NSDictionary{
                if let dic = dictionary["image_main"]  as? NSDictionary{
                    image = dic["src"] as? String
                }
            }else{
                if let tempImageUrl = dictionary["image_main"] as? String{
                    image = tempImageUrl
                }
            }
            
        }
        
        loading_flag = false
        photoUrl = dictionary["uri"] as? String
        photoUrlForAlbum = dictionary["content_url"] as? String
        photo_title = dictionary["title"]    as? String
        photo_description = dictionary["description"]    as? String
        is_like = dictionary["is_like"]    as? Bool
        
        comment_count = dictionary["comment_count"] as? Int
        if let _ = dictionary["like_count"]{
            likes_count = dictionary["like_count"] as? Int
        }
        else if let _ = dictionary["likes_count"] {
            likes_count = dictionary["likes_count"] as? Int
        }
        menu = dictionary["menu"] as? NSArray
        description = dictionary["description"] as? String
        
        reactions = dictionary["reactions"] as? NSDictionary
        
        if let _ = reactions?["feed_reactions"]{
            feed_reaction = reactions?["feed_reactions"] as? NSDictionary
        }
        if let _ = reactions?["my_feed_reaction"]{
            my_feed_reaction = reactions?["my_feed_reaction"] as? NSDictionary
        }
        tags = dictionary["tags"] as? NSArray
    }
    
    
    // Add Photos in PhotoViewer from Server Response
    class func loadPhotosInfo(_ photosArray:NSArray) -> [PhotoViewer]
    {
        var photos:[PhotoViewer] = []
        for obj:Any in photosArray {
            let photoViewerDictionary = obj as! NSDictionary
            let photo = PhotoViewer(dictionary: photoViewerDictionary)
            photos.append(photo)
        }
        return photos
    }
    
    class func loadPhotosInfoDictionary(_ PhotosDic:NSDictionary) -> [PhotoViewer]
    {
        var Photos:[PhotoViewer] = []
        // for obj:AnyObject in commentsDic {
        let photoDictionary = PhotosDic as NSDictionary
        let Photo = PhotoViewer(dictionary: photoDictionary)
        Photos.append(Photo)
        //  }
        return Photos
    }
    
    class func getDictionaryFromPhotoViewer(_ photosArrayViewer : [PhotoViewer])
    {
        allPhotos.removeAll()
        for value in photosArrayViewer
        {
            let newDictionary:NSMutableDictionary = [:]
            newDictionary["image"] = value.image
            newDictionary["loading_flag"] = value.loading_flag
            newDictionary["photo_id"] = value.photo_id
            newDictionary["album_id"] = value.album_id
            newDictionary["description"] = value.photo_description
            newDictionary["comment_count"] = value.comment_count
            newDictionary["menu"] = value.menu
            newDictionary["title"] = value.photo_title
            newDictionary["tags"] = value.tags
            newDictionary["description"] = value.description
            newDictionary["is_like"] = value.is_like
            newDictionary["like_count"] = value.likes_count
            newDictionary["reactions"] = value.reactions
            newDictionary["feed_reactions"] = value.feed_reaction
            newDictionary["my_feed_reaction"] = value.my_feed_reaction
            newDictionary["tags"] = value.tags
            newDictionary["uri"] = value.photoUrl
            allPhotos.append(newDictionary)
        }
    }
    
}
