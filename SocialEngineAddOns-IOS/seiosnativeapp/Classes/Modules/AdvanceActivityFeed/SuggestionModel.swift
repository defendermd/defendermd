//
//  SuggestionModel.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 17/12/17.
//  Copyright © 2017 bigstep. All rights reserved.
//

import Foundation

class SuggestionModel {
    
    var user_id : Int?
    var image:String?               // For Feed Subject Image
    var displayname:String?                  // For Feed MainContent
    var location:String?
    var friendship_type:String?                // Feed Creation Time
    var mutualfriendCount:Int?                    // Feed Like Count
    
    init(dictionary:NSDictionary) {
        user_id = (dictionary["user_id"] ) as? Int
        image = (dictionary["image"]) as? String
        displayname = (dictionary["displayname"])  as? String
        location = (dictionary["location"]) as? String
        friendship_type = (dictionary["friendship_type"]) as? String
        mutualfriendCount = (dictionary["mutualfriendCount"]) as? Int


    }
    class func loadsuggetionFromArray(_ suggetionArray:NSArray) -> [SuggestionModel]
    {
        var suggetions:[SuggestionModel] = []
        for obj:Any in suggetionArray {
        let suggetionDictionary = obj as! NSDictionary
        let suggetionUser = SuggestionModel(dictionary: suggetionDictionary)
        suggetions.append(suggetionUser)
        }
        return suggetions
    }
    

}

