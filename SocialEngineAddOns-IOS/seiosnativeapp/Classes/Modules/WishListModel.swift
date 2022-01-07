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


//  WishListModel.Swift
//  seiosnativeapp

import Foundation


class WishListModel {
    
    var listing_images_1 : String?
    var listing_images_2 : String?
    var listing_images_3 : String?
    let title : String?
    let total_item : Int?
    var isLike : Int?
    var likeDictionary : NSMutableDictionary?
    let wishlist_id : Int?
    let body : String?
    let allow_to_view : Int?
   
    // Initialize Comment Dictionary For wishlists
    init(dictionary:NSDictionary, wishlistType : String) {
        listing_images_1 = ""
        if let listingImage1 = dictionary["images_0"] as? NSDictionary{
            if let listingImage1MainImage = listingImage1["image"] as? String{
                listing_images_1 = listingImage1MainImage
            }
        }

        if let listingImage1 = dictionary["images_1"] as? NSDictionary{
            if let listingImage1MainImage = listingImage1["image"] as? String{
                listing_images_1 = listingImage1MainImage
            }
        }
        listing_images_2 = ""
        if let listingImage2 = dictionary["images_2"] as? NSDictionary{
            if let listingImage2MainImage = listingImage2["image"] as? String{
                listing_images_2 = listingImage2MainImage
            }
        }
        listing_images_3 = ""
        if let listingImage3 = dictionary["images_3"] as? NSDictionary{
            if let listingImage3MainImage = listingImage3["image"] as? String{
                listing_images_3 = listingImage3MainImage
            }
        }
        
        if let tempArray = dictionary["gutterMenu"] as? NSArray{
            for array in tempArray {
                if let dic = array as? NSMutableDictionary{
                    let titleString = dic["name"] as! String
                    if titleString.range(of: "like") != nil{
                        likeDictionary = dic
                    }
                }
            }
        }
        allow_to_view = dictionary["allow_to_view"] as? Int
        title = String(describing: dictionary["title"]!)
        total_item = dictionary["total_item"] as? Int
        isLike = dictionary["isLike"] as? Int
        if wishlistType == "diary"
        {
            wishlist_id = dictionary["diary_id"] as? Int
        }
        else{
        wishlist_id = dictionary["wishlist_id"] as? Int
        }
        body = dictionary["body"] as? String
    }
    
    // Add wishlists in Comment from Server Response
    class func loadWishLists(_ wishlistsArray:NSArray, wishlistType : String) -> [WishListModel]
    {
        var wishlists:[WishListModel] = []
        for obj:Any in wishlistsArray {
            let commentDictionary = obj as! NSDictionary
            let comment = WishListModel(dictionary: commentDictionary, wishlistType : wishlistType)
            wishlists.append(comment)
        }
        return wishlists
    }
    
    class func loadWishListsFromDictionary(_ wishlistsDic:NSDictionary, wishlistType : String) -> [WishListModel]
    {
        var wishlists:[WishListModel] = []
        // for obj:AnyObject in wishlistsDic {
        let commentDictionary = wishlistsDic as NSDictionary
        let comment = WishListModel(dictionary: commentDictionary, wishlistType : wishlistType)
        wishlists.append(comment)
        //  }
        return wishlists
    }
    
}
