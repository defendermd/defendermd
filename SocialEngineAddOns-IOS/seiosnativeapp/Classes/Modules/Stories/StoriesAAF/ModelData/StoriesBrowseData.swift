//
//  StoriesBrowseData.swift
//  seiosnativeapp
//
//  Created by BigStep on 08/08/18.
//  Copyright © 2018 bigstep. All rights reserved.
//

import UIKit

class StoriesBrowseData: NSObject, NSCoding {

    var story_id: Int = 0
    var owner_id: Int = 0
    var owner_type_Stories: String = ""
    var photo_id: Int = 0
    var file_id: Int = 0
    var duration: Int = 0
    var privacy: String = ""
    var description_Stories: String = ""
    var view_count: Int = 0
    var comment_count: Int = 0
    var mute_story: Int = 0
    var status: Int = 0
    var type: Int = 0
    var owner_title: String = ""
    var image: String = ""
    var content_url: String = ""
    var owner_image_icon: String = ""
    var total_stories: Int = 0
    var videoUrl: String = ""
    var imgVideoOverlay: String = ""
    var owner_type: String = ""
    var create_date: String = ""
    var isViewLoading : Int = 0
    var isStoryDeleted : Int = 0
    var isSendMessage = 0
    var gutterMenu = [[String : Any]]()
    var isMute: Int = 0
    
    override init() {}

    required init(coder decoder: NSCoder) {
        self.isMute = decoder.decodeInteger(forKey: "isMute")
        self.isSendMessage = decoder.decodeInteger(forKey: "isSendMessage")
        self.isStoryDeleted = decoder.decodeInteger(forKey: "isStoryDeleted")
        self.isViewLoading = decoder.decodeInteger(forKey: "isViewLoading")
        self.story_id = decoder.decodeInteger(forKey: "story_id")
        self.owner_id = decoder.decodeInteger(forKey: "owner_id")
        self.photo_id = decoder.decodeInteger(forKey: "photo_id")
        self.file_id = decoder.decodeInteger(forKey: "file_id")
        self.view_count = decoder.decodeInteger(forKey: "view_count")
        self.comment_count = decoder.decodeInteger(forKey: "comment_count")
        self.mute_story = decoder.decodeInteger(forKey: "mute_story")
        self.status = decoder.decodeInteger(forKey: "status")
        self.type = decoder.decodeInteger(forKey: "type")
        self.total_stories = decoder.decodeInteger(forKey: "total_stories")
        self.owner_type_Stories = decoder.decodeObject(forKey: "owner_type_Stories") as? String ?? ""
        self.privacy = decoder.decodeObject(forKey: "privacy") as? String ?? ""
        self.owner_title = decoder.decodeObject(forKey: "owner_title") as? String ?? ""
        self.image = decoder.decodeObject(forKey: "image") as? String ?? ""
        self.content_url = decoder.decodeObject(forKey: "content_url") as? String ?? ""
        self.owner_image_icon = decoder.decodeObject(forKey: "owner_image_icon") as? String ?? ""
        self.videoUrl = decoder.decodeObject(forKey: "videoUrl") as? String ?? ""
        self.imgVideoOverlay = decoder.decodeObject(forKey: "imgVideoOverlay") as? String ?? ""
        self.owner_type = decoder.decodeObject(forKey: "owner_type") as? String ?? ""
        self.create_date = decoder.decodeObject(forKey: "create_date") as? String ?? ""
        self.gutterMenu = decoder.decodeObject(forKey: "gutterMenu") as? [[String : Any]] ?? [[:]]
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(isMute, forKey: "isMute")
        coder.encode(isSendMessage, forKey: "isSendMessage")
        coder.encode(isStoryDeleted, forKey: "isStoryDeleted")
        coder.encode(isViewLoading, forKey: "isViewLoading")
        coder.encode(story_id, forKey: "story_id")
        coder.encode(owner_id, forKey: "owner_id")
        coder.encode(photo_id, forKey: "photo_id")
        coder.encode(file_id, forKey: "file_id")
        coder.encode(view_count, forKey: "view_count")
        coder.encode(comment_count, forKey: "comment_count")
        coder.encode(mute_story, forKey: "mute_story")
        coder.encode(status, forKey: "status")
        coder.encode(type, forKey: "type")
        coder.encode(total_stories, forKey: "total_stories")
        coder.encode(owner_type_Stories, forKey: "owner_type_Stories")
        coder.encode(privacy, forKey: "privacy")
        coder.encode(owner_title, forKey: "owner_title")
        coder.encode(image, forKey: "image")
        coder.encode(content_url, forKey: "content_url")
        coder.encode(owner_image_icon, forKey: "owner_image_icon")
        coder.encode(videoUrl, forKey: "videoUrl")
        coder.encode(imgVideoOverlay, forKey: "imgVideoOverlay")
        coder.encode(owner_type, forKey: "owner_type")
        coder.encode(create_date, forKey: "create_date")
        coder.encode(gutterMenu, forKey: "gutterMenu")
    }
}

class CustomFeedPostMenuData: NSObject, NSCoding {
    
    var key: String = ""
    var value: String = ""
    var isSelected = 0
    
    override init() {}
    
    required init(coder decoder: NSCoder) {
        self.key = decoder.decodeObject(forKey: "key") as? String ?? ""
        self.value = decoder.decodeObject(forKey: "value") as? String ?? ""
        self.isSelected = decoder.decodeInteger(forKey: "isSelected")
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(key, forKey: "key")
        coder.encode(value, forKey: "value")
        coder.encode(isSelected, forKey: "isSelected")
    }
    
}
