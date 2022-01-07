//
//  ActivityFeedData.swift
//  seiosnativeapp
//
//  Created by bigstep on 24/02/15.
//  Copyright (c) 2015 bigstep. All rights reserved.
//

import Foundation
import CoreData

class ActivityFeedData: NSManagedObject {

    @NSManaged var action_Id: NSNumber
    @NSManaged var attachment: NSData
    @NSManaged var attachmentCount: NSNumber
    @NSManaged var canComment: NSNumber
    @NSManaged var canDelete: NSNumber
    @NSManaged var canShare: NSNumber
    @NSManaged var commentCount: NSNumber
    @NSManaged var creationDate: String
    @NSManaged var feedMenu: NSData
    @NSManaged var feedTitle: String
    @NSManaged var feedType: String
    @NSManaged var isLike: NSNumber
    @NSManaged var likeCount: NSNumber
    @NSManaged var subjectAvatarImage: String

}
