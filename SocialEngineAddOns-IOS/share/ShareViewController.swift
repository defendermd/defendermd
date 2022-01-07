//
//  ShareViewController.swift
//  socialengineapp
//
//  Created by Vidit Paliwal on 13/07/16.
//  Copyright © 2016 bigstep. All rights reserved.
//
import UIKit
import Social
import MobileCoreServices
import Foundation
import CoreData
import QuartzCore

var baseUrl1 = ""
var oauth_consumer_secret1 = ""
var oauth_consumer_key1 = ""
var ios_version1 : String!
let logoutUser1 = false
var oauth_secret1:String! = ""
var oauth_token1:String! = ""

class ShareViewController: SLComposeServiceViewController{
    
    var selectedImage : UIImage?
    var shareText : String!
    var shareType : String!
    var linkUrlShare : String!
    var allPhotos = [UIImage]()
    var filePathArray = [String]()
    var video_id = "0"
    var videoAttachmentMode = false
    var linkAttachmentMode = false
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let userDefaults = UserDefaults(suiteName: "group.com.ssodrujestvo.mobileapp.share")
        userDefaults?.synchronize()
        if let oauthsecret = userDefaults!.object(forKey: "oauth_secret") as? String {
            oauth_secret1 = oauthsecret
        }
        if let oauthtoken = userDefaults!.object(forKey: "oauth_token") as? String {
            oauth_token1 = oauthtoken
           
        }
        if let iosversion = userDefaults!.object(forKey: "ios_version") as? String {
            ios_version1 = iosversion
        }

        if let baseUrl = userDefaults!.object(forKey: "baseUrl") as? String {
            baseUrl1 = baseUrl
        }
        if let oauthconsumersecret = userDefaults!.object(forKey: "oauth_consumer_secret") as? String {
            oauth_consumer_secret1 = oauthconsumersecret
        }
        if let oauthconsumerkey = userDefaults!.object(forKey: "oauth_consumer_key") as? String {
            oauth_consumer_key1 = oauthconsumerkey
        }
    }
    
    
    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }
    
    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
        if oauth_token1 == "" && oauth_secret1 == ""{
            //print("logout user")
            let alertController = UIAlertController(title: "Message", message:
                "You are not signed in, please sign in first.", preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: { (UIAlertAction) -> Void in
                
                self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
            }))
            
            self.present(alertController, animated: true, completion: nil)
            
            
        }
        else
        {
            if let content = extensionContext!.inputItems[0] as? NSExtensionItem {
                let contentTypeImage = kUTTypeImage as String
                let contentTypeUrl = kUTTypeURL as String
                let contentTypeText = kUTTypeText as String
                let contentTypeVideo = kUTTypeMovie as String
                // Verify the provider is valid
                if let contents = content.attachments as? [NSItemProvider] {
                    // look for images
                    if contents.count > 1{
                        for attachment in contents {
                            if attachment.hasItemConformingToTypeIdentifier(contentTypeUrl) {
                                shareType = "Url"
                                shareText = self.contentText
                                attachment.loadItem(forTypeIdentifier: contentTypeUrl, options: nil) { data, error in
                                    self.linkUrlShare = "\(data!)"
                                    self.shareExtension()
                                }
                                break
                            }
                            
                        }
                    }
                    else{
                        let attachment = contents[0]
                        
                        if attachment.hasItemConformingToTypeIdentifier(contentTypeVideo)
                        {
                            attachment.loadItem(forTypeIdentifier: contentTypeVideo, options: nil, completionHandler: { (data,error) in
                                
                                print(data.debugDescription)
                                print(error!.localizedDescription)
                                
                            })
                        }
                        
                        if attachment.hasItemConformingToTypeIdentifier(contentTypeImage) {
                            shareType = "Image"
                            shareText = self.contentText
                            attachment.loadItem(forTypeIdentifier: contentTypeImage, options: nil) { data, error in
                                
//                                switch data
//                                {
//                                case let image as UIImage:
//                                    let image2 = fixOrientation(img: image)
//                                    self.selectedImage = image2
//                                case let data as Data:
//                                    self.selectedImage = UIImage(data: data)
//                                case let url as URL:
//                                    let imageData = try! Data(contentsOf: url)
//                                    let image3 = UIImage(data: imageData)
//                                    self.selectedImage = fixOrientation(img: image3!)
//                                case let url as NSURL:
//                                    let imageData = try! Data(contentsOf: url as URL)
//                                    let image4 = UIImage(data: imageData)
//                                    self.selectedImage = fixOrientation(img: image4!)
//                                default:
//                                    print("Unexpected data:", type(of: data))
//                                }
//
//                                let url = data as! URL
//                                print(url)
                                //guard let imageData = try? Data(contentsOf: url) else {
                                 //   return
                                //}
                                //self.selectedImage = UIImage(data: imageData)
                                
                                let url = data as! URL
                                if let imageData = try? Data(contentsOf: url) {
                                    self.selectedImage = UIImage(data: imageData)
                                    self.selectedImage = fixOrientation(img: self.selectedImage!)
                                    self.allPhotos.removeAll(keepingCapacity: false)
                                    self.allPhotos.append(self.selectedImage!)
                                }
                                self.shareExtension()
                                
//                                self.allPhotos.removeAll(keepingCapacity: false)
//                                self.allPhotos.append(self.selectedImage!)
//                                self.shareExtension()
                                
                            }
                        }
                        if attachment.hasItemConformingToTypeIdentifier(contentTypeUrl) {
                            shareType = "Url"
                            shareText = self.contentText
                            attachment.loadItem(forTypeIdentifier: contentTypeUrl, options: nil) { data, error in
                                let url = data as! URL
                                self.linkUrlShare = url.absoluteString
                                let checkUrl = self.getVideoType(url: self.linkUrlShare)
                                if checkUrl
                                {
                                    var parameters = [String:AnyObject]()
                                    //parameters = ["body": "\(self.shareText!)" as AnyObject,"auth_view": "everyone" as AnyObject]
                                    parameters["uri"] = "\(self.linkUrlShare!)" as AnyObject?
                                    parameters["share_link"] = "1" as AnyObject?
                                    activityPost(parameters, url: "advancedactivity/feeds/attach-link", method: "POST") { (succeeded, msg) -> () in
                                        DispatchQueue.main.async(execute: {
                                            if msg
                                            {
                                                var title = ""
                                                var description = ""
                                                if let response = succeeded["body"] as? NSDictionary
                                                {
                                                    if let video_id = response["video_id"] as? Int
                                                    {
                                                        self.video_id = String(video_id)
                                                        self.videoAttachmentMode = true
                                                        //self.shareExtension()
                                                    }
                                                    if let temp_title = response["title"] as? String{
                                                        title = temp_title
                                                    }
                                                    if let temp_description = response["description"] as? String{
                                                        description = temp_description
                                                    }
                                                    if (title != "" || description != "") && self.videoAttachmentMode == false
                                                    {
                                                        self.linkAttachmentMode = true
                                                        //self.shareExtension()
                                                    }
                                                    
                                                    
                                                }
                                                print(succeeded)
                                            }
                                        })
                                        
                                    }
                                }
                                else
                                {
                                   self.shareExtension()
                                }
                                
                            }
                        }
                        if attachment.hasItemConformingToTypeIdentifier(contentTypeText) {
                            shareType = "Text"
                            shareText = self.contentText
                            if shareText != ""
                            {
                                if let url = URL(string: shareText)
                                {
                                    self.linkUrlShare = url.absoluteString
                                    var parameters = [String:AnyObject]()
                                    parameters["uri"] = "\(linkUrlShare!)" as AnyObject?
                                    //parameters = ["body": "\(self.shareText!)" as AnyObject,"auth_view": "everyone" as AnyObject]
                                    parameters["share_link"] = "1" as AnyObject?
                                    activityPost(parameters, url: "advancedactivity/feeds/attach-link", method: "POST") { (succeeded, msg) -> () in
                                        DispatchQueue.main.async(execute: {
                                            if msg
                                            {
                                                if let response = succeeded["body"] as? NSDictionary
                                                {
                                                    if let video_id = response["video_id"] as? Int
                                                    {
                                                        self.video_id = String(video_id)
                                                        self.videoAttachmentMode = true
                                                        self.shareExtension()
                                                    }
                                                }
                                                print(succeeded)
                                            }
                                            else
                                            {
                                                // Handle Server Side Error
                                                if succeeded["message"] != nil
                                                {
                                                }
                                            }
                                        })
                                        
                                    }
                                }
                                else
                                {
                                    self.shareExtension()
                                }
                            }
                            
                        }
                    }
                }
            }
            // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
            self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
            
        }

    }
    func shareExtension(){
        var auth_View:String!
        let userDefaults = UserDefaults(suiteName: "group.com.ssodrujestvo.mobileapp.share")
        if let privacy = userDefaults!.object(forKey: "auth_view") as? String{
            auth_View = privacy
        }else{
            auth_View = "everyone"
        }
        
        var parameters = [String:AnyObject]()
        parameters = ["body": "\(shareText!)" as AnyObject,"auth_view": auth_View as AnyObject]
        
        if shareType == "Url" && shareType != ""{
            parameters["post_attach"] = "1" as AnyObject?
            parameters["uri"] = "\(linkUrlShare!)" as AnyObject?
//            if linkUrlShare.range(of: "youtube") != nil
//            {
//                parameters["type"] = "video" as AnyObject?
//                parameters["type"] = "1" as AnyObject?
//                parameters["video_id"] = "112" as AnyObject?
//            }
//            else
//            {
                parameters["type"] = "link" as AnyObject?
            //}
            
            
        }
        if videoAttachmentMode == true
        {
            print(video_id)
            parameters["video_id"] = video_id as AnyObject?
            parameters["type"] = "video" as AnyObject?
            parameters["post_attach"] = "1" as AnyObject?
            parameters["uri"] = "\(linkUrlShare!)" as AnyObject
            shareType = "Url"
        }
        
        if linkAttachmentMode == true && (linkUrlShare != nil && linkUrlShare != "")
        {
            parameters["post_attach"] = "1" as AnyObject?
            parameters["uri"] = linkUrlShare as AnyObject?
            parameters["type"] = "link" as AnyObject?
            shareType = "Url"
            
        }

        
        if shareType == "Image" && shareType != ""{
            parameters["post_attach"] = "1" as AnyObject?
            parameters["type"] = "photo" as AnyObject?
            
            if allPhotos.count>0{
                filePathArray.removeAll(keepingCapacity: false)
                filePathArray = saveFileInDocumentDirectory(allPhotos as [AnyObject])
                
            }
            
        }
        print(parameters)
        
        if shareType == "Text" || shareType == "Url"{
            activityPost(parameters, url: "advancedactivity/feeds/post", method: "POST") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    if msg
                    {
                        
                        //print("success")
                    }else{
                        // Handle Server Side Error
                        if succeeded["message"] != nil{
                            //                                self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                        }
                    }
                })
                
            }
        }
        if shareType == "Image"{
            postActivityForm(parameters,
                             url: "advancedactivity/feeds/post", filePath: filePathArray , filePathKey: "photo", SinglePhoto: true){ (succeeded, msg) -> () in
                                DispatchQueue.main.async(execute: {
                                    
                                    
                                    if msg{
                                        //print("success")
                                        for path in self.filePathArray{
                                            removeFileFromDocumentDirectoryAtPath(path)
                                        }
                                        self.filePathArray.removeAll(keepingCapacity: false)
                                        
                                    }else{
                                        // Handle Server Side Error
                                        if succeeded["message"] != nil{
                                            
                                        }
                                    }
                                })
            }
            
        }
    }
    
    
    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }
    
    func getVideoType(url: String) -> Bool
    {
        let validDomains = ["www.youtube.com","youtube.com","youtu.be","googlevideo.com","m.youtube.com","m.youtu.be","vimeo.com","www.dailymotion.com","dailymotion.com"]
        let urlToCheck = URL(string: url)
        let host = urlToCheck?.host
        if validDomains.contains(host!)
        {
            return true
        }
        else
        {
            return false
        }
    }
    
}
