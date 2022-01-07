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


//  FriendRequestModel.Swift
//  seiosnativeapp

import Foundation

class FriendRequestModel {
    var displayname : String?
    var profileImage : String?
    var subject_id : Int!
    
    // Initialize Comment Dictionary For wishlists
    init(dictionary:NSDictionary) {
        
        displayname = ""
        profileImage = ""
        
        if let subjectDictionary = dictionary["subject"] as? NSDictionary{
            if let subjectName = subjectDictionary["displayname"] as? String{
                displayname = subjectName
            }
            
            if let subjecctImage = subjectDictionary["image_profile"] as? String{
                profileImage = subjecctImage
            }
            
            if let subjectId = subjectDictionary["user_id"] as? Int{
                subject_id = subjectId
            }
        }
        
    }
    
    // Add wishlists in Comment from Server Response
    class func loadFriendRequests(_ friendRequestsArray:NSArray) -> [FriendRequestModel]
    {
        var friendRequests:[FriendRequestModel] = []
        for obj:Any in friendRequestsArray {
            let commentDictionary = obj as! NSDictionary
            let comment = FriendRequestModel(dictionary: commentDictionary)
            friendRequests.append(comment)
        }
        return friendRequests
    }
    
    
}
