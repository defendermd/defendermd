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
//  Message.swift
//  seiosnativeapp
//

import Foundation

class Message {
    
    var message:NSDictionary!
    var sender:NSDictionary!
    var recipient:NSDictionary!
    
    // Initialize Message Dictionary For Comments
    init(dictionary:NSDictionary) {
        message = dictionary["message"] as? NSDictionary
        sender = dictionary["sender"] as? NSDictionary
        recipient = dictionary["recipient"] as? NSDictionary
    }
    
    // Add Comments in Message from Server Response
    class func loadMessages(_ membersArray:NSArray) -> [Message]
    {
        var messages:[Message] = []
        for obj:Any in membersArray {
            let messageDictionary = obj as! NSDictionary
            let message = Message(dictionary: messageDictionary)
            messages.append(message)
        }
        return messages
    }
    
    class func loadMessagesfromDictionary(_ messagesDic:NSDictionary) -> [Message]
    {
        var messages:[Message] = []
        let messageDictionary = messagesDic as NSDictionary
        let message = Message(dictionary: messageDictionary)
        messages.append(message)
        return messages
    }
    
}
