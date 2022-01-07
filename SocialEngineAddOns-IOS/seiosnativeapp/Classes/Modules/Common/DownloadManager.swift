//
//  DownloadManager.swift
//  TableDownloadProgress
//
//  Created by Basheer on 23/8/17.
//  Copyright © 2017 Basheer. All rights reserved.
//

import Foundation
import UIKit

protocol QuickContentDelegate{
    func quickContentUpdateRequest(index : Int)
}

extension URLSession {
    func getSessionDescription () -> Int {
        // row id
        return Int(self.sessionDescription!)!
    }
    
    func getDebugDescription () -> Int {
        // table id
        return Int(self.debugDescription)!
    }
}

class DownloadManager : NSObject, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {

    static var shared = DownloadManager()
    var identifier : Int = -1
    var tableId : Int = -1
    typealias ProgressHandler = (Int, Int, Float) -> ()
    
    var responseData = NSMutableData()
    var filePathArrayTemp = [String]()
    var quickContentDelegate : QuickContentDelegate!
    
    var onProgress : ProgressHandler? {
        didSet {
            if onProgress != nil {
                let _ = activate()
            }
        }
    }
    
    override init() {
        super.init()
    }
    
    func activate() -> URLSession {
        //let config = URLSessionConfiguration.background(withIdentifier: "\(Bundle.main.bundleIdentifier!).background.\(NSUUID.init())")
        let config = URLSessionConfiguration.default
        config.allowsCellularAccess = true
        config.requestCachePolicy = .useProtocolCachePolicy        
        let urlSession = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
        urlSession.sessionDescription = String(identifier)
        urlSession.accessibilityHint = String(tableId)
        return urlSession
    }
    
    private func calculateProgress(session : URLSession,progress : Float, completionHandler : @escaping (Int, Int, Float) -> ()) {

        completionHandler(session.getSessionDescription(), Int(session.accessibilityHint!)!, progress)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        let uploadProgress: Float = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
        print("quickContentIncrementIndex== \(uploadProgress * 100)%.")
            if let onProgress = onProgress {
                calculateProgress(session: session, progress: uploadProgress, completionHandler: onProgress)
            }
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        //  print("session \(session), received response \(response)")
        completionHandler(URLSession.ResponseDisposition.allow)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        responseData.append(data as Data)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        DispatchQueue.main.async {
        for path in self.filePathArrayTemp{
            print("path removing==\(path)")
            removeFileFromDocumentDirectoryAtPath(path)
        }
        if error != nil {
            print("session \(session) occurred error \(String(describing: error?.localizedDescription))")
        } else {
            //print("session \(session) upload completed, response: \(String(describing: NSString(data: self.responseData as Data, encoding: String.Encoding.utf8.rawValue)))")
            do
            {
                if let json = try JSONSerialization.jsonObject(with: self.responseData as Data, options:JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                {
                    self.responseData = NSMutableData()
                    if (json["status_code"] != nil)
                    {
                        if (json["status_code"] as! Int == 200)
                        {
                            if json["body"] != nil{
                                
                                print(json)
                                if let dic = json["body"] as? [String : AnyObject], let activity_feed = dic["data"] as? NSArray{
                                    // Extract FeedInfo from response by ActivityFeed class
                                    let activityFeeds = ActivityFeed.loadActivityFeedInfo(activity_feed)
                                    // Update feedArray
                                    self.updateFeedsArray(feed: activityFeeds.first!, index: dic["notifyItemAt"] as? Int ?? 0)
                                }
                            }
                        }
                    }
                    
                }
            }
            catch
            {
                print(error)
                //print(String(data: data!, encoding: .utf8) as Any)
            }
        }
      }
    }
    
    
    func updateFeedsArray(feed: ActivityFeed, index: Int){
        
        let newDictionary:NSMutableDictionary = [:]
        
        if feed.action_id != nil{
            newDictionary["action_id"] = feed.action_id
        }
        if feed.feed_privacy != nil{
            newDictionary["privacy"] = feed.feed_privacy
        }
        if feed.feed_privacyIcon != nil{
            newDictionary["privacy_icon"] = feed.feed_privacyIcon
        }
        
        if feed.subject_id != nil{
            newDictionary["subject_id"] = feed.subject_id
        }
        if feed.share_params_type != nil{
            newDictionary["share_params_type"] = feed.share_params_type
        }
        if feed.share_params_id != nil{
            newDictionary["share_params_id"] = feed.share_params_id
        }
        if feed.attachment != nil{
            newDictionary["attachment"] = feed.attachment
        }
        if feed.attactment_Count != nil{
            newDictionary["attactment_Count"] = feed.attactment_Count
        }
        if feed.comment != nil{
            newDictionary["comment"] = feed.comment
        }
        if feed.delete != nil{
            newDictionary["delete"] = feed.delete
        }
        if feed.share != nil{
            newDictionary["share"] = feed.share
        }
        if feed.comment_count != nil{
            newDictionary["comment_count"] = feed.comment_count
        }
        if feed.feed_createdAt != nil{
            newDictionary["feed_createdAt"] = feed.feed_createdAt
        }
        if feed.feed_menus != nil{
            newDictionary["feed_menus"] = feed.feed_menus
        }
        if feed.feed_footer_menus != nil{
            newDictionary["feed_footer_menus"] = feed.feed_footer_menus
        }
        if feed.feed_reactions != nil{
            newDictionary["feed_reactions"] = feed.feed_reactions
        }
        if feed.my_feed_reaction != nil{
            newDictionary["my_feed_reaction"] = feed.my_feed_reaction
        }
        if feed.feed_title != nil{
            newDictionary["feed_title"] = feed.feed_title
        }
        if feed.feed_Type != nil{
            newDictionary["feed_Type"] = feed.feed_Type
        }
        if feed.is_like != nil{
            newDictionary["is_like"] = feed.is_like
        }
        if feed.likes_count != nil{
            newDictionary["likes_count"] = feed.likes_count
        }
        if feed.subject_image != nil{
            newDictionary["subject_image"] = feed.subject_image
        }
        if feed.photo_attachment_count != nil{
            newDictionary["photo_attachment_count"] = feed.photo_attachment_count
        }
        if feed.object_id != nil{
            newDictionary["object_id"] = feed.object_id
        }
        if feed.object_type != nil{
            newDictionary["object_type"] = feed.object_type
        }
        
        if feed.params != nil{
            newDictionary["params"] = feed.params
        }
        if feed.tags != nil{
            newDictionary["tags"] = feed.tags
        }
        if feed.action_type_body_params != nil{
            newDictionary["action_type_body_params"] = feed.action_type_body_params
        }
        if feed.action_type_body != nil{
            newDictionary["action_type_body"] = feed.action_type_body
        }
        if feed.object != nil{
            newDictionary["object"] = feed.object
        }
        if feed.hashtags != nil{
            newDictionary["hashtags"] = feed.hashtags
        }
        if feed.userTag != nil{
            newDictionary["userTag"] = feed.userTag
        }
        if feed.decoration != nil{
            newDictionary["decoration"] = feed.decoration
        }
        if feed.wordStyle != nil{
            newDictionary["wordStyle"] = feed.wordStyle
        }
        if feed.publish_date != nil{
            newDictionary["publish_date"] = feed.publish_date
        }
        if feed.isNotificationTurnedOn != nil{
            newDictionary["isNotificationTurnedOn"] = feed.isNotificationTurnedOn
            
        }
        
        if feed.attachment_content_type != nil{
            newDictionary["attachment_content_type"] = feed.attachment_content_type
        }
        
        if feed.pin_post_duration != nil{
            newDictionary["pin_post_duration"] = feed.pin_post_duration
        }
        if feed.isPinned != nil{
            newDictionary["isPinned"] = feed.isPinned
        }

        activityIndicatorView.stopAnimating()
        quickContentIncrementIndex -= 1
        for (indexT,dic) in feedArray.enumerated()
        {
            if let indexNotify = dic["notifyItemAt"] as? Int, indexNotify == index
            {
                feedArray[indexT] = newDictionary
                quickContentDelegate.quickContentUpdateRequest(index: indexT)
            }
        }
        
    }
    
}
