//
//  ActivityFeedData.swift
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

@objc(ActivityFeedData)
class ActivityFeedData: NSManagedObject {

    @NSManaged var action_Id: NSNumber
    @NSManaged var subject_Id: NSNumber
    @NSManaged var share_params_id: NSNumber
    @NSManaged var share_params_type: String
    @NSManaged var action_type_body_params: Data
    @NSManaged var attachment: Data
    @NSManaged var attachmentCount: NSNumber
    @NSManaged var canComment: NSNumber
    @NSManaged var canDelete: NSNumber
    @NSManaged var canShare: NSNumber
    @NSManaged var commentCount: NSNumber
    @NSManaged var creationDate: String
    @NSManaged var feedMenu: Data
    @NSManaged var feedTitle: String
    @NSManaged var feedType: String
    @NSManaged var isLike: NSNumber
    @NSManaged var likeCount: NSNumber
    @NSManaged var object_id: NSNumber
    @NSManaged var object_type: String
    @NSManaged var params: Data
    @NSManaged var photo_attachment_count: NSNumber
    @NSManaged var subjectAvatarImage: String
    @NSManaged var tags: Data
    @NSManaged var feed_footer_menus: Data
    @NSManaged var object: Data
    @NSManaged var action_type_body : String

}
