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

//  CreateNewForm.swift
//  seiosnativeapp

import UIKit
var isCreateOrEdit = true // create -> true / edit -> false
var iscomingFromAdvEvents = false
var textstoreValue = ""


class CreateNewForm: NSObject, FXForm
{
    
    var valuesByKey = NSMutableDictionary()
    
    // Set Values for Dictionary Used in FXForm
    override func setValue(_ value: Any?, forUndefinedKey key: String)
    {
        
        if ((value) != nil)
        {
            if (conditionForm != nil) && (( conditionForm == "topicCreation") || (conditionForm == "forumEditing") || (conditionForm == "postReply" ) || ( conditionForm == "forumQuoting") || (conditionForm == "forum")){
                
                if key == "title"{
                    textstoreValue = String(describing: value!)
                }
            }

            valuesByKey[key] = value
        }
        else
        {
            valuesByKey.removeObject(forKey: key)
        }
    }
    
    override func value(forUndefinedKey key: String) -> Any?
    {
        return valuesByKey[key]
    }
    
    // Generate FXForm Field Array
    @objc public func fields() -> [AnyObject]
    {
        // Create FXForm Array from Dictionary (Response from Server)
        let getarray = generateFXFormsArrayfromDictionary(Form as NSArray) as NSArray
        return getarray as [AnyObject]
        
    }
    

    
}
