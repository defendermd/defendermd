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


//  PageReviewModel.Swift
//  seiosnativeapp

import Foundation


class PageReviewModel {
    
    let title : String?
    var isLike : Int?
    var likeDictionary : NSMutableDictionary?
    let body : String?
    let overall_rating : Int?
    let creation_date : String?
    let owner_title : String?
    let breakdown_ratings_params : NSMutableArray?
    let pros : String?
    let cons : String?
    let summary : String?
    let comment_count : Int?
    var like_count : Int?
    let recommend : Int?
    var is_liked : Bool?
    let review_id : Int!
    let owner_id : Int?
    let recommendText : String?
    
    // Initialize Comment Dictionary For wishlists
    init(dictionary:NSDictionary) {
        
        title = dictionary["title"]    as? String
        isLike = dictionary["isLike"] as? Int
        body = dictionary["body"] as? String
        overall_rating = dictionary["overall_rating"] as? Int
        creation_date = dictionary["creation_date"] as? String
        owner_title = dictionary["owner_title"] as? String
        breakdown_ratings_params = dictionary["breakdown_ratings_params"] as? NSMutableArray
        pros = dictionary["pros"] as? String
        cons = dictionary["cons"] as? String
        summary = dictionary["summary"] as? String
        comment_count = dictionary["comment_count"] as? Int
        like_count = dictionary["like_count"] as? Int
        recommend = dictionary["recommend"] as? Int
        is_liked = dictionary["is_liked"] as? Bool
        review_id = dictionary["review_id"] as! Int
        owner_id = dictionary["owner_id"] as? Int
        recommendText = dictionary["recommend"] as? String
        
    }
    
    class func loadReview(_ reviewsArray:NSArray) -> [PageReviewModel]
    {
        var reviews:[PageReviewModel] = []
        for obj:Any in reviewsArray {
            let commentDictionary = obj as! NSDictionary
            let comment = PageReviewModel(dictionary: commentDictionary)
            reviews.append(comment)
        }
        return reviews
    }
    
    class func loadReviewFromDictionary(_ wishlistsDic:NSDictionary) -> [PageReviewModel]
    {
        var reviewsDic:[PageReviewModel] = []
        let commentDictionary = wishlistsDic as NSDictionary
        let comment = PageReviewModel(dictionary: commentDictionary)
        reviewsDic.append(comment)
        return reviewsDic
    }
    
}
