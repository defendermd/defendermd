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
//  NetworkConnection.swift
//  SocailEngineDemoForSwift
//

import UIKit
import Foundation
import MobileCoreServices
import CoreData
import NVActivityIndicatorView

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}


let frameActivityIndicator = CGRect(x: 0, y: 0, width: 28, height: 28)
let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)

//var spinner:UIActivityIndicatorView = UIActivityIndicatorView()
let session = URLSession.shared
var userInteraction = true
var userInteractionOff = true
//var filterSearchFlag = false
// MARK: - Create Server Connection Here for Every Request
func post(_ params : Dictionary<String, String>, url : String, method:String , postCompleted : @escaping (_ succeeded:NSDictionary , _ msg: Bool) -> ())
{
    
    var dic = Dictionary<String, String>()

    if(logoutUser == false){
        dic["oauth_token"] = oauth_token
        dic["oauth_secret"] = oauth_secret
    }
    dic["oauth_consumer_secret"] = "\(oauth_consumer_secret)"
    dic["oauth_consumer_key"] = "\(oauth_consumer_key)"
    
    if ios_version != nil && ios_version != "" {
        dic["_IOS_VERSION"] = ios_version
    }
    
    if url == "sitestore/create" {
        dic["package_id"] = "1"
    }
    
    dic["ios"] = "1"
    dic["language"] = "\( (Locale.current as NSLocale).object(forKey: NSLocale.Key.languageCode)!)"
    
    // Create Query String for GET Request with URL
    
    //finalurl = NSURL(string : baseUrl+url)!
    //let url1 : NSString = baseUrl+url+buildQueryString(fromDictionary:dic) as NSString
    //let urlStr : NSString = url1.addingPercentEscapes(using: String.Encoding.utf8.rawValue)! as NSString
    //finalurl  = NSURL(string: urlStr as String)! as URL
    //finalurl = URL(string : baseUrl+url+buildQueryString(fromDictionary:param))! as NSURL
    //  finalurl = NSURL(string : baseUrl+url+buildQueryString(fromDictionary:param) as String)! as URL
    
    // Create Request URL
    var finalurl : URL

    finalurl = URL(string: baseUrl+url+buildQueryString(fromDictionary:dic))!
    print(params)
    if method == "POST"{
        if url == "login"
        {
            dic["subscriptionForm"] = "1"
        }
        finalurl = URL(string: baseUrl+url+buildQueryString(fromDictionary:dic))!
    }else if method == "PUT"{
        dic.update(params)
        finalurl = URL(string: baseUrl+url+buildQueryString(fromDictionary:dic))!
    }else if method == "DELETE"{
        dic.update(params)
        finalurl = URL(string: baseUrl+url+buildQueryString(fromDictionary:dic))!
    }
    else
    {
        dic.update(params)
        finalurl = URL(string: baseUrl+url+buildQueryString(fromDictionary:dic))!
    }

    //    let request = NSMutableURLRequest(url: finalurl, cachePolicy:
    //        NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData,
    //        timeoutInterval: 45.0)
    
    
    let request = NSMutableURLRequest(url: finalurl)
    request.httpMethod = method
    request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
    
    print("==========================")
    print(URL(string: baseUrl+url+buildQueryString(fromDictionary:dic))!)
    print("==========================")
    
    if (request.httpMethod == "POST")
    {
        // Create String from Dictionary for POST Request
        let str = stringFromDictionary(params)
//        request.httpBody = (str as NSString).data(using: String.Encoding.utf8.rawValue)
        request.httpBody = str.data(using: .utf8)
    
    }
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    createServerRequest(request as URLRequest, postCompleted: { (succeeded, msg) -> () in
        postCompleted(succeeded, msg)
    })
    
}

func AgoraPost(_ params : Dictionary<String, String>, url : String, method:String , postCompleted : @escaping (_ succeeded:NSDictionary , _ msg: Bool) -> ())
{
    
    var dic = Dictionary<String, String>()
    
    dic.update(params)
    // Create Request URL
    var finalurl : URL
    
    
    finalurl = URL(string: baseServerUrl+url+buildQueryString(fromDictionary:dic))!
    
    print("==========================")
    //
    
    print(finalurl)
    
    //
    print("==========================")
    
 
    let request = NSMutableURLRequest(url: finalurl)
    request.httpMethod = method
    request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
    
    if (request.httpMethod == "POST")
    {
        // Create String from Dictionary for POST Request
        let str = stringFromDictionary(dic)
        //        request.httpBody = (str as NSString).data(using: String.Encoding.utf8.rawValue)
        request.httpBody = str.data(using: .utf8)
        
    }
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    createServerRequest(request as URLRequest, postCompleted: { (succeeded, msg) -> () in
        postCompleted(succeeded, msg)
    })
    
}


func postAutoSearch(_ params : Dictionary<String, String>, url : String, method:String , postCompleted : @escaping (_ succeeded:NSDictionary , _ msg: Bool) -> ())
{
    
    var dic = Dictionary<String, String>()
    
    if(logoutUser == false){
        dic["oauth_token"] = oauth_token
        dic["oauth_secret"] = oauth_secret
    }
    dic["oauth_consumer_secret"] = "\(oauth_consumer_secret)"
    dic["oauth_consumer_key"] = "\(oauth_consumer_key)"
    if ios_version != nil && ios_version != "" {
        dic["_IOS_VERSION"] = ios_version
        
    }
    
    dic["ios"] = "1"
    dic["language"] = "\( (Locale.current as NSLocale).object(forKey: NSLocale.Key.languageCode)!)"
    dic.update(params)
    // Create Request URL
    var finalurl : URL
    
    // Create Query String for GET Request with URL
    finalurl = URL(string: baseUrl+url+buildQueryString(fromDictionary:dic))!
    if method == "POST"{
        finalurl = URL(string: baseUrl+url+buildQueryString(fromDictionary:dic))!
    }else if method == "PUT"{
        finalurl = URL(string: baseUrl+url+buildQueryString(fromDictionary:dic))!
    }else if method == "DELETE"{
        finalurl = URL(string: baseUrl+url+buildQueryString(fromDictionary:dic))!
    }

    if url != "notifications/new-updates"// && url != "advancedactivity/feeds"
    {
      print("==========================")
    
      print(finalurl)
    
      print("==========================")
    }
    //    let request = NSMutableURLRequest(url: finalurl, cachePolicy:
    //        NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData,
    //        timeoutInterval: 45.0)
    let request = NSMutableURLRequest(url: finalurl)
    request.httpMethod = method
    request.cachePolicy = URLRequest.CachePolicy.useProtocolCachePolicy
    
    if (request.httpMethod == "POST")
    {
        // Create String from Dictionary for POST Request
        let str = stringFromDictionary(dic)
        request.httpBody = (str as NSString).data(using: String.Encoding.utf8.rawValue)
        
    }
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    createServerRequestForAutoSearch(request as URLRequest, postCompleted: { (succeeded, msg) -> () in
        postCompleted(succeeded, msg)
    })
    
}

// MARK: - Create Server Connection Here for Every Request
func postGetContactList(_ params : Dictionary<String, String>, paramUrl:String, url : String, method:String , postCompleted : @escaping (_ succeeded:NSDictionary , _ msg: Bool) -> ())
{
    
    var dic = Dictionary<String, String>()
    
    if(logoutUser == false){
        dic["oauth_token"] = oauth_token
        dic["oauth_secret"] = oauth_secret
    }
    dic["oauth_consumer_secret"] = "\(oauth_consumer_secret)"
    dic["oauth_consumer_key"] = "\(oauth_consumer_key)"
    if ios_version != nil && ios_version != "" {
        dic["_IOS_VERSION"] = ios_version
        
    }
    
    if url == "sitestore/create" {
        dic["package_id"] = "1"
    }
    
    dic["ios"] = "1"
    dic["language"] = "\( (Locale.current as NSLocale).object(forKey: NSLocale.Key.languageCode)!)"
    dic.update(params)
    // Create Request URL
    var finalurl : URL
    
    // Create Query String for GET Request with URL
    
    //finalurl = NSURL(string : baseUrl+url)!
    //let url1 : NSString = baseUrl+url+buildQueryString(fromDictionary:dic) as NSString
    //let urlStr : NSString = url1.addingPercentEscapes(using: String.Encoding.utf8.rawValue)! as NSString
    //finalurl  = NSURL(string: urlStr as String)! as URL
    //finalurl = URL(string : baseUrl+url+buildQueryString(fromDictionary:param))! as NSURL
    //  finalurl = NSURL(string : baseUrl+url+buildQueryString(fromDictionary:param) as String)! as URL
    
    
    finalurl = URL(string: baseUrl+url+buildQueryString(fromDictionary:dic))!
    if method == "POST"{
        finalurl = URL(string: baseUrl+url+buildQueryString(fromDictionary:dic))!
    }else if method == "PUT"{
        finalurl = URL(string: baseUrl+url+buildQueryString(fromDictionary:dic))!
    }else if method == "DELETE"{
        finalurl = URL(string: baseUrl+url+buildQueryString(fromDictionary:dic))!
    }
    
    print("==========================")
    
    print(finalurl)
    
    print("==========================")
    
    
    //    let request = NSMutableURLRequest(url: finalurl, cachePolicy:
    //        NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData,
    //        timeoutInterval: 45.0)
    let request = NSMutableURLRequest(url: finalurl)
    request.httpMethod = method
    request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
    
    if (request.httpMethod == "POST")
    {

            let finalReplace = paramUrl.replacingOccurrences(of: "\\", with: "")
            let str = "emails=\(finalReplace)"
            request.httpBody = str.data(using: .utf8)

    }
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    createServerRequest(request as URLRequest, postCompleted: { (succeeded, msg) -> () in
        postCompleted(succeeded, msg)
    })
    
}

func postSetting(_ params : Dictionary<String, String>, paramUrl:String, keyName:String,url : String, method:String , postCompleted : @escaping (_ succeeded:NSDictionary , _ msg: Bool) -> ())
{
    
    var dic = Dictionary<String, String>()
    
    if(logoutUser == false){
        dic["oauth_token"] = oauth_token
        dic["oauth_secret"] = oauth_secret
    }
    dic["oauth_consumer_secret"] = "\(oauth_consumer_secret)"
    dic["oauth_consumer_key"] = "\(oauth_consumer_key)"
    if ios_version != nil && ios_version != "" {
        dic["_IOS_VERSION"] = ios_version
        
    }
    
    if url == "sitestore/create" {
        dic["package_id"] = "1"
    }
    
    dic["ios"] = "1"
    dic["language"] = "\( (Locale.current as NSLocale).object(forKey: NSLocale.Key.languageCode)!)"
    dic.update(params)
    // Create Request URL
    var finalurl : URL
    
    // Create Query String for GET Request with URL
    
    //finalurl = NSURL(string : baseUrl+url)!
    //let url1 : NSString = baseUrl+url+buildQueryString(fromDictionary:dic) as NSString
    //let urlStr : NSString = url1.addingPercentEscapes(using: String.Encoding.utf8.rawValue)! as NSString
    //finalurl  = NSURL(string: urlStr as String)! as URL
    //finalurl = URL(string : baseUrl+url+buildQueryString(fromDictionary:param))! as NSURL
    //  finalurl = NSURL(string : baseUrl+url+buildQueryString(fromDictionary:param) as String)! as URL
    
    
    finalurl = URL(string: baseUrl+url+buildQueryString(fromDictionary:dic))!
    if method == "POST"{
        finalurl = URL(string: baseUrl+url+buildQueryString(fromDictionary:dic))!
    }else if method == "PUT"{
        finalurl = URL(string: baseUrl+url+buildQueryString(fromDictionary:dic))!
    }else if method == "DELETE"{
        finalurl = URL(string: baseUrl+url+buildQueryString(fromDictionary:dic))!
    }
    
    print("==========================")
    
    print(finalurl)
    
    print("==========================")
    
    
    //    let request = NSMutableURLRequest(url: finalurl, cachePolicy:
    //        NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData,
    //        timeoutInterval: 45.0)
    let request = NSMutableURLRequest(url: finalurl)
    request.httpMethod = method
    request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
    
    if (request.httpMethod == "POST")
    {
        
        let finalReplace = paramUrl.replacingOccurrences(of: "\\", with: "")
        let str = "\(keyName)=\(finalReplace)"
        request.httpBody = str.data(using: .utf8)
        
    }
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    createServerRequest(request as URLRequest, postCompleted: { (succeeded, msg) -> () in
        postCompleted(succeeded, msg)
    })
    
}


func postFromBody(_ params : Dictionary<String, AnyObject>, paramUrl:String, keyName:String,url : String, method:String , postCompleted : @escaping (_ succeeded:NSDictionary , _ msg: Bool) -> ())
{
    var dic = Dictionary<String, AnyObject>()
    
    if(logoutUser == false){
        
        dic["oauth_token"] = oauth_token as AnyObject?
        dic["oauth_secret"] = oauth_secret as AnyObject?
        
    }
    dic["oauth_consumer_secret"] = "\(oauth_consumer_secret)" as AnyObject?
    dic["oauth_consumer_key"] = "\(oauth_consumer_key)" as AnyObject?
    dic["language"] = "\( (Locale.current as NSLocale).object(forKey: NSLocale.Key.languageCode)!)" as AnyObject?
    if ios_version != nil && ios_version != "" {
        dic["_IOS_VERSION"] = ios_version as AnyObject?
    }
    
    if url == "sitestore/create" {
        dic["package_id"] = "1" as AnyObject?
    }
    
    dic["ios"] = "1" as AnyObject?
    dic["language"] = "\( (Locale.current as NSLocale).object(forKey: NSLocale.Key.languageCode)!)" as AnyObject?
    dic.update(params)
    // Create Request URL
    var finalurl : URL
    
   
    finalurl = URL(string: baseUrl+url+activityBuildQueryString(fromDictionary:dic))!
    if method == "POST"{
        finalurl = URL(string: baseUrl+url+activityBuildQueryString(fromDictionary:dic))!
    }else if method == "PUT"{
        finalurl = URL(string: baseUrl+url+activityBuildQueryString(fromDictionary:dic))!
    }else if method == "DELETE"{
        finalurl = URL(string: baseUrl+url+activityBuildQueryString(fromDictionary:dic))!
    }
    
    let request = NSMutableURLRequest(url: finalurl)
    request.httpMethod = method
    request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
    
    let finalReplace = paramUrl.replacingOccurrences(of: "\\", with: "")
    dic["\(keyName)"] = "\(finalReplace)" as AnyObject

    if (request.httpMethod == "POST") {
        // Create String from Dictionary for POST Request
        let str = activityStringFromDictionary(dic)
        request.httpBody = (str as NSString).data(using: String.Encoding.utf8.rawValue)
    }
    
//    if (request.httpMethod == "POST")
//    {
//
//        let finalReplace = paramUrl.replacingOccurrences(of: "\\", with: "")
//        let str = "\(keyName)=\(finalReplace)"
//        request.httpBody = str.data(using: .utf8)
//
//    }
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    createServerRequest(request as URLRequest, postCompleted: { (succeeded, msg) -> () in
        postCompleted(succeeded, msg)
    })
    
}

func encodeValue(_ string: String) -> String? {
    guard let unescapedString = string.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed) else { return nil }
    return unescapedString
}


func shippingPost(_ params : Dictionary<String, String>, url : String, method:String , postCompleted : @escaping (_ succeeded:NSDictionary , _ msg: Bool) -> ())
{
    
    var dic = Dictionary<String, String>()
    
    if(logoutUser == false){
        dic["oauth_token"] = oauth_token
        dic["oauth_secret"] = oauth_secret
    }
    dic["oauth_consumer_secret"] = "\(oauth_consumer_secret)"
    dic["oauth_consumer_key"] = "\(oauth_consumer_key)"
    if ios_version != nil && ios_version != "" {
        dic["_IOS_VERSION"] = ios_version
        
    }
    
    if url == "sitestore/create" {
        dic["package_id"] = "1"
    }
    
    dic["ios"] = "1"
    dic["language"] = "\( (Locale.current as NSLocale).object(forKey: NSLocale.Key.languageCode)!)"
    dic.update(params)
    // Create Request URL
    var finalurl : URL
    
    // Create Query String for GET Request with URL
    
    //finalurl = NSURL(string : baseUrl+url)!
    let url1 : NSString = baseUrl+url+buildQueryString(fromDictionary:dic) as NSString
    let urlStr : NSString = url1.addingPercentEscapes(using: String.Encoding.utf8.rawValue)! as NSString
    finalurl  = NSURL(string: urlStr as String)! as URL
    //finalurl = URL(string : baseUrl+url+buildQueryString(fromDictionary:param))! as NSURL
    //  finalurl = NSURL(string : baseUrl+url+buildQueryString(fromDictionary:param) as String)! as URL
    
    
    /*finalurl = URL(string: baseUrl+url+buildQueryString(fromDictionary:dic))!
    if method == "POST"{
        finalurl = URL(string: baseUrl+url+buildQueryString(fromDictionary:dic))!
    }else if method == "PUT"{
        finalurl = URL(string: baseUrl+url+buildQueryString(fromDictionary:dic))!
    }else if method == "DELETE"{
        finalurl = URL(string: baseUrl+url+buildQueryString(fromDictionary:dic))!
    }
     */
    print("==========================")
    
    print(finalurl)
    
    print("==========================")
    
    
    //    let request = NSMutableURLRequest(url: finalurl, cachePolicy:
    //        NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData,
    //        timeoutInterval: 45.0)
    let request = NSMutableURLRequest(url: finalurl)
    request.httpMethod = method
    request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
    
    if (request.httpMethod == "POST")
    {
        // Create String from Dictionary for POST Request
        let str = stringFromDictionary(dic)
        request.httpBody = (str as NSString).data(using: String.Encoding.utf8.rawValue)
        
    }
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    createServerRequest(request as URLRequest, postCompleted: { (succeeded, msg) -> () in
        postCompleted(succeeded, msg)
    })
    
}


func activityPostTag(_ params : Dictionary<String, AnyObject>, url : String, method:String , postCompleted : @escaping (_ succeeded:NSDictionary , _ msg: Bool) -> ()) {
    
    var dic = Dictionary<String, AnyObject>()
    
    if(logoutUser == false){
        
        dic["oauth_token"] = oauth_token as AnyObject?
        dic["oauth_secret"] = oauth_secret as AnyObject?
        
    }
    dic["oauth_consumer_secret"] = "\(oauth_consumer_secret)" as AnyObject?
    dic["oauth_consumer_key"] = "\(oauth_consumer_key)" as AnyObject?
    dic["language"] = "\( (Locale.current as NSLocale).object(forKey: NSLocale.Key.languageCode)!)" as AnyObject?
    if ios_version != nil && ios_version != "" {
        dic["_IOS_VERSION"] = ios_version as AnyObject?
    }
    dic.update(params)
    // Create Request URL
    var finalurl : URL
    
    // Create Query String for GET Request with URL
    finalurl = URL(string: baseUrl+url+activityBuildQueryString(fromDictionary:dic))!
    
    if method == "POST"{
        finalurl = URL(string: baseUrl+url+activityBuildQueryString(fromDictionary:dic))!
    }else if method == "PUT"{
        finalurl = URL(string: baseUrl+url)!
    }
    let request = NSMutableURLRequest(url: finalurl)
    request.httpMethod = method
        if (request.httpMethod == "POST") {
        // Create String from Dictionary for POST Request
        let str = activityStringFromDictionary(dic)
        request.httpBody = (str as NSString).data(using: String.Encoding.utf8.rawValue)
    }
    request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
    request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
    
    print("==========================")
    
    print(finalurl)
    
    print("==========================")
    createServerRequest(request as URLRequest, postCompleted: { (succeeded, msg) -> () in
        postCompleted(succeeded, msg)
    })
    
}

// MARK: - Create Server Connection Here for Every Request For Activity Posts
func activityPost(_ params : Dictionary<String, AnyObject>, url : String, method:String , postCompleted : @escaping (_ succeeded:NSDictionary , _ msg: Bool) -> ()) {
    
    var dic = Dictionary<String, AnyObject>()
    
    if(logoutUser == false){
        
        dic["oauth_token"] = oauth_token as AnyObject?
        dic["oauth_secret"] = oauth_secret as AnyObject?
        
    }
    dic["oauth_consumer_secret"] = "\(oauth_consumer_secret)" as AnyObject?
    dic["oauth_consumer_key"] = "\(oauth_consumer_key)" as AnyObject?
    dic["language"] = "\( (Locale.current as NSLocale).object(forKey: NSLocale.Key.languageCode)!)" as AnyObject?
    if ios_version != nil && ios_version != "" {
        dic["_IOS_VERSION"] = ios_version as AnyObject?
    }
    dic.update(params)
    // Create Request URL
    var finalurl : URL
    
    // Create Query String for GET Request with URL
    finalurl = URL(string: baseUrl+url+activityBuildQueryString(fromDictionary:dic))!
    
    if method == "POST"{
        finalurl = URL(string: baseUrl+url+activityBuildQueryString(fromDictionary:dic))!
    }else if method == "PUT"{
        finalurl = URL(string: baseUrl+url)!
    }
    
    //print(finalurl)
    let request = NSMutableURLRequest(url: finalurl)
    request.httpMethod = method
    if (request.httpMethod == "POST") {
        // Create String from Dictionary for POST Request
        let str = activityStringFromDictionary(dic)
        request.httpBody = (str as NSString).data(using: String.Encoding.utf8.rawValue)
    }
   
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    
    print("==========================")
    
    print(finalurl)
    
    print("==========================")
    createServerRequest(request as URLRequest, postCompleted: { (succeeded, msg) -> () in
        postCompleted(succeeded, msg)
    })
    
}

//func post(_ params : Dictionary<String, String>, url : String, method:String , postCompleted : @escaping (_ succeeded:NSDictionary , _ msg: Bool) -> ())
// MARK: - Create Server Connection Here for Every Request For Post Form
func postForm(_ params : Dictionary<String, String>, url : String, filePath:[String], filePathKey:String ,SinglePhoto:Bool, postCompleted : @escaping (_ succeeded:NSDictionary , _ msg: Bool) -> ())
{
    var dic = Dictionary<String, String>()
    if(logoutUser == false){
        dic["oauth_token"] = oauth_token
        dic["oauth_secret"] = oauth_secret
    }
    dic["oauth_consumer_secret"] = "\(oauth_consumer_secret)"
    dic["oauth_consumer_key"] = "\(oauth_consumer_key)"
    dic["language"] = "\( (Locale.current as NSLocale).object(forKey: NSLocale.Key.languageCode)!)"
    if ios_version != nil && ios_version != "" {
        dic["_IOS_VERSION"] = ios_version
    }
    dic.update(params)
    
    var finalurl : URL
    
    // Create Query String for GET Request with URL
    finalurl = URL(string: baseUrl+url+buildQueryString(fromDictionary:dic))!
    print(finalurl)
    
    let request = createRequest(params, url: finalurl, path: filePath, filePathKey: filePathKey,SinglePhoto: SinglePhoto)
    //print(request)
    createServerRequest(request, postCompleted: { (succeeded, msg) -> () in
        postCompleted(succeeded, msg)
    })
}

// MARK: - Create Server Connection Here for Every Request For Post Activity Forms
func postActivityForm(_ params : Dictionary<String, AnyObject>, url : String, filePath:[String], filePathKey:String ,SinglePhoto:Bool, postCompleted : @escaping (_ succeeded:NSDictionary , _ msg: Bool) -> ()){
    
    var dic = Dictionary<String, AnyObject>()
    
    if(logoutUser == false){
        dic["oauth_token"] = oauth_token as AnyObject?
        dic["oauth_secret"] = oauth_secret as AnyObject?
    }
    dic["oauth_consumer_secret"] = "\(oauth_consumer_secret)" as AnyObject?
    dic["oauth_consumer_key"] = "\(oauth_consumer_key)" as AnyObject?
    dic["language"] = "\( (Locale.current as NSLocale).object(forKey: NSLocale.Key.languageCode)!)" as AnyObject?
    if ios_version != nil && ios_version != "" {
        dic["_IOS_VERSION"] = ios_version as AnyObject?
        
    }
    dic.update(params)
    print(dic)
    let request = createActivityRequest(dic, url: url, path: filePath, filePathKey: filePathKey,SinglePhoto: SinglePhoto)
    print(request)
    createServerRequest(request, postCompleted: { (succeeded, msg) -> () in
        postCompleted(succeeded, msg)
    })
}
func createServerRequest(_ request:URLRequest, postCompleted : @escaping (_ succeeded:NSDictionary , _ msg: Bool) -> ()){
    
    //  if userInteractionOff {
    // UIApplication.sharedApplication().beginIgnoringInteractionEvents()
    // }
    //Create Session Request
    let urlconfig = URLSessionConfiguration.default
    urlconfig.timeoutIntervalForRequest = 1500
    urlconfig.timeoutIntervalForResource = 1500
    let session = URLSession(configuration: urlconfig)
    userInteraction = false
    let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
        
        // if userInteractionOff{
        //  UIApplication.sharedApplication().endIgnoringInteractionEvents()
        // }
        userInteraction = true
        
        //        var err: NSError!
        var response:Dictionary<String, AnyObject> = [:]
        // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
        if(error != nil)
        {
            response["message"] = nil
            postCompleted(response as NSDictionary, false)
        }
        else
        {
            // The JSONObjectWithData constructor didn't return an error. But, we should still
            // check and make sure that json has a value using optional binding.
            do
            {
                if let json = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                {
                    
                    var status : Bool!
                    
                    if json["success"] != nil {
                        print("server calling=====\(json)")
                        if json["success"] as! Bool == true {
                            status = true
                            if json["sid"] != nil {
                                print("sid value \(json["sid"] as! String )")
                                sidValue = json["sid"] as! String
                            }
                            
                            postCompleted(response as NSDictionary, status)
                        }
                    }
                    
                    if (json["status_code"] != nil)
                    {
                        
                        switch(json["status_code"] as! Int)
                        {
                            
                        case 200:
                            if json["body"] != nil{
                                if( json["body"] is NSDictionary ){
                                    response["body"] = json["body"] as! NSDictionary
                                }else if ( json["body"] is NSArray ){
                                    response["body"] = json["body"] as! NSArray
                                }else if ( json["body"] is String ){
                                    response["body"] = json["body"] as! String as AnyObject?
                                }else if ( json["body"] is Int ){
                                    response["body"] = json["body"] as! Int as AnyObject?
                                }
                                
                            }
                            status = true
                        case 201:
                            if json["message"] != nil{
                                response["message"] = json["message"] as! String as AnyObject?
                            }
                            status = true
                        case 204:
                            if json["body"] != nil
                            {
                                response["body"] = json["body"] as! NSDictionary
                            }
                            response["message"] = NSLocalizedString("Your action has been performed successfully.",  comment: "") as AnyObject?
                            status = true
                            
                        case 400, 401 , 404, 500:
                            
                            ////print("status code =====\(json["status_code"] as! Int)")
                            if json["message"] != nil
                            {
                                validation = [:]
                                if (json["message"] is String)
                                {
                                    response["message"] = json["message"] as! String as AnyObject?
                                    
                                    if let errorcode = json["error_code"]
                                    {
                                        
                                        if errorcode as! String == "subscription_fail"
                                        {
                                            SubscriptionMessage = json["message"] as! String
                                        }
                                        else
                                        {
                                            validationMessage = json["message"] as! String
                                        }
                                    }
                                    else
                                    {
                                        validationMessage = json["message"] as! String
                                    }
                                    
                                }
                                else if (json["message"] is NSDictionary)
                                {
                                    validation = json["message"] as! NSDictionary
                                    
                                    if let errorcode = json["error_code"]
                                    {
                                        response["error_code"] = errorcode as AnyObject
                                    }
                                    
                                    let msg = json["message"] as? NSDictionary
                                    for (_,value) in msg!
                                    {
                                        response["message"] = "\(value)" as AnyObject?
                                        
                                    }
                                    if let _ = msg!["filedata"] as? String
                                    {
                                        response["message"] = msg!["filedata"] as? String as AnyObject?
                                    }
                                    if let _ = msg!["profileur"] as? String
                                    {
                                        response["message"] = msg!["profileur"] as? String as AnyObject?
                                    }
                                    if let _ = msg!["category_id"] as? String
                                    {
                                        response["message"] = msg!["category_id"] as? String as AnyObject?
                                    }
                                    
                                    
                                    if let _ =  msg!["title"] as? String
                                    {
                                        response["message"] = msg!["title"] as? String as AnyObject?
                                    }
                                    
                                    if let _ = msg!["pros"] as? String{
                                        response["message"] = msg!["pros"] as? String as AnyObject?
                                    }
                                    if let _ =  msg!["cons"] as? String{
                                        response["message"] = msg!["cons"] as? String as AnyObject?
                                        
                                    }
                                    if let _ =  msg!["body"] as? String{
                                        response["message"] = msg!["body"] as? String as AnyObject?
                                    }
                                    if let _ = msg!["password"] as? String
                                    {
                                        response["message"] = msg!["password"] as? String as AnyObject?
                                    }
                                    
                                    if let _ = msg!["group_uri"] as? String
                                    {
                                        response["message"] = msg!["group_uri"] as? String as AnyObject?
                                    }
                                    
                                    
                                    
                                }
                                else
                                {
                                    response["message"] = "Oops,Server not responding :(" as AnyObject?
                                    
                                }
                                
                            }
                            status = false
                            
                            
                        case 406 :
                            status = false
                            forceFullyLogout()
                            
                        default:
                            break
                        }
                        
                        postCompleted(response as NSDictionary, status)
                    }
                }
                else
                {
                    // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                    
                    let jsonStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    print("Error could not parse JSON2: \(String(describing: jsonStr))")
                    response["message"] = "Can't read Response from Server" as AnyObject?
                    postCompleted(response as NSDictionary , false)
                }
            }
            catch
            {
                print(error)
                print(String(data: data!, encoding: .utf8) as Any)
            }
            
            
        }
    })
    task.resume()
    session.finishTasksAndInvalidate()
    
    
}


//func createServerRequest(_ request:URLRequest, postCompleted : @escaping (_ succeeded:NSDictionary , _ msg: Bool) -> ()){
//
//    //  if userInteractionOff {
//    // UIApplication.sharedApplication().beginIgnoringInteractionEvents()
//    // }
//    //Create Session Request
//    let urlconfig = URLSessionConfiguration.default
//    urlconfig.timeoutIntervalForRequest = 1500
//    urlconfig.timeoutIntervalForResource = 1500
//    let session = URLSession(configuration: urlconfig)
//    userInteraction = false
//    let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
//
//        // if userInteractionOff{
//        //  UIApplication.sharedApplication().endIgnoringInteractionEvents()
//        // }
//        userInteraction = true
//
//        //        var err: NSError!
//        var response:Dictionary<String, Any> = [:]
//        // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
//        if(error != nil)
//        {
//            response["message"] = nil
//            postCompleted(response as NSDictionary, false)
//        }
//        else
//        {
//            // The JSONObjectWithData constructor didn't return an error. But, we should still
//            // check and make sure that json has a value using optional binding.
//            do
//            {
//                let json = JSON(data as Any)
//                if json.isEmpty {
//                    print("No Response Is Coming")
//                }
//                else
//                {
//print(json)
//                    var status : Bool!
//                    if let _ = json.dictionary  {
//                        print("server calling=====\(json)")
//                        if json["success"].bool == true {
//                            status = true
//                            if json["sid"].stringValue  != ""{
//                            print("sid value \(json["sid"].stringValue )")
//                            sidValue = json["sid"].stringValue
//                            }
//
//                            postCompleted(response as NSDictionary, status)
//                        }
//                    }
//
//                    if let _ = json["status_code"].int
//                    {
//
//                        switch(json["status_code"].int)
//                        {
//
//                        case 200:
//                            if let _  = json.dictionary {
//                                if let _ = json["body"].dictionary {
//                                    response["body"] = json["body"].dictionaryObject
//                                }
//                                else if let _ = json["body"].array {
//                                    response["body"] = NSMutableArray(array: json["body"].array ?? [])
//                                }
//                                else if let _ = json["body"].string {
//                                    response["body"] = json["body"].string as AnyObject?
//                                }
//                                else if let _ = json["body"].int {
//                                   response["body"] = json["body"].int as AnyObject?
//                                }
//                            }
//                            status = true
//                        case 201:
//                            if let _ = json["message"].string {
//                                response["message"] = json["message"].string as AnyObject?
//                            }
//                            status = true
//                        case 204:
//                            if let _ = json["body"].dictionary {
//                                response["body"] = json["body"].dictionary
//                            }
//
//                            response["message"] = NSLocalizedString("Your action has been performed successfully.",  comment: "") as AnyObject?
//                            status = true
//
//                        case 400, 401 , 404, 500:
//
//                            ////print("status code =====\(json["status_code"] as! Int)")
//                            if let _ = json["message"].string {
//                                response["message"] = json["message"].string as AnyObject?
//                                if let error = json["error_code"].string {
//                                    if error == "subscription_fail" {
//                                        SubscriptionMessage = json["message"].string ?? ""
//                                    }
//                                    else {
//                                        validationMessage = json["message"].string ?? ""
//                                    }
//                                }
//                                else {
//                                    validationMessage = json["message"].string ?? ""
//                                }
//                            }
//                            else if let _ = json["message"].dictionary {
//                                validation = json["message"].dictionary! as NSDictionary
//                                if let error = json["error_code"].error {
//                                    response["error_code"] = error as AnyObject
//                                }
//                                let msg = json["message"].dictionary
//                                for (_,value) in msg!
//                                {
//                                    response["message"] = "\(value)" as AnyObject?
//
//                                }
//                                if let _ = msg?["filedata"]?.string
//                                {
//                                    response["message"] = msg?["filedata"]?.string as AnyObject?
//                                }
//                                if let _ = msg?["profileur"]?.string
//                                {
//                                    response["message"] = msg?["profileur"]?.string as AnyObject?
//                                }
//                                if let _ = msg?["category_id"]?.string
//                                {
//                                    response["message"] = msg?["category_id"]?.string as AnyObject?
//                                }
//
//
//                                if let _ =  msg?["title"]?.string
//                                {
//                                    response["message"] = msg?["title"]?.string  as AnyObject?
//                                }
//
//                                if let _ = msg?["pros"]?.string {
//                                    response["message"] = msg?["pros"]?.string as AnyObject?
//                                }
//                                if let _ =  msg?["cons"]?.string{
//                                    response["message"] = msg?["cons"]?.string as AnyObject?
//
//                                }
//                                if let _ =  msg?["body"]?.string {
//                                    response["message"] = msg?["body"]?.string as AnyObject?
//                                }
//                                if let _ = msg?["password"]?.string
//                                {
//                                    response["message"] = msg?["password"]?.string as AnyObject?
//                                }
//
//                                if let _ = msg?["group_uri"]?.string
//                                {
//                                    response["message"] = msg?["group_uri"]?.string as AnyObject?
//                                }
//
//
//
//                            }
//                            else
//                            {
//                                response["message"] = "Oops,Server not responding :(" as AnyObject?
//
//                            }
//                            status = false
//
//                        case 406 :
//                            status = false
//                            forceFullyLogout()
//
//                        default:
//                            break
//                        }
//
//                        postCompleted(response as NSDictionary, status)
//                    }
//                }
//
//            }
//        }
//    })
//    task.resume()
//    session.finishTasksAndInvalidate()
//
//
//}

var currentTask:URLSessionDataTask?
func cancelTasksByUrl(tasks: [URLSessionTask]) {
    for task in tasks
    {
        task.cancel()
    }
}
func createServerRequestForAutoSearch(_ request:URLRequest, postCompleted : @escaping (_ succeeded:NSDictionary , _ msg: Bool) -> ()){

    //Create Session Request
    let urlconfig = URLSessionConfiguration.default
    urlconfig.timeoutIntervalForRequest = 30
    urlconfig.timeoutIntervalForResource = 30
    let session = URLSession(configuration: urlconfig)
   // session.invalidateAndCancel()
    userInteraction = false

    session.getTasksWithCompletionHandler
        {
            (dataTasks, uploadTasks, downloadTasks) -> Void in
            cancelTasksByUrl(tasks: dataTasks     as [URLSessionTask])
            cancelTasksByUrl(tasks: uploadTasks   as [URLSessionTask])
            cancelTasksByUrl(tasks: downloadTasks as [URLSessionTask])
    }
    var task:URLSessionDataTask!
     task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
  
        if (task !== currentTask) {
            ////print("Ignore this task")
            return
        }
        userInteraction = true
        var response:Dictionary<String, AnyObject> = [:]
        if(error != nil)
        {
            response["message"] = nil
            postCompleted(response as NSDictionary, false)
        }
        else
        {
            // The JSONObjectWithData constructor didn't return an error. But, we should still
            // check and make sure that json has a value using optional binding.
            do
            {
                if let json = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                {
                    var status : Bool!
                    if (json["status_code"] != nil)
                    {
                        switch(json["status_code"] as! Int)
                        {                            
                        case 200:
                            if json["body"] != nil{
                                if( json["body"] is NSDictionary ){
                                    response["body"] = json["body"] as! NSDictionary
                                }else if ( json["body"] is NSArray ){
                                    response["body"] = json["body"] as! NSArray
                                }else if ( json["body"] is String ){
                                    response["body"] = json["body"] as! String as AnyObject?
                                }else if ( json["body"] is Int ){
                                    response["body"] = json["body"] as! Int as AnyObject?
                                }
                                
                            }
                            status = true
                        case 201:
                            if json["message"] != nil{
                                response["message"] = json["message"] as! String as AnyObject?
                            }
                            status = true
                        case 204:
                            if json["body"] != nil
                            {
                                response["body"] = json["body"] as! NSDictionary
                            }
                            response["message"] = NSLocalizedString("Your action has been performed successfully.",  comment: "") as AnyObject?
                            status = true
                            
                        case 400, 401 , 404, 500:
                            
                            ////print("status code =====\(json["status_code"] as! Int)")
                            if json["message"] != nil
                            {
                                
                                if (json["message"] is String)
                                {
                                    response["message"] = json["message"] as! String as AnyObject?
                                    
                                    if let errorcode = json["error_code"]
                                    {
                                        if errorcode as! String == "subscription_fail"
                                        {
                                            SubscriptionMessage = json["message"] as! String
                                        }
                                        else
                                        {
                                            validationMessage = json["message"] as! String
                                        }
                                    }
                                    else
                                    {
                                        validationMessage = json["message"] as! String
                                    }
                                    
                                }
                                else if (json["message"] is NSDictionary)
                                {
                                    validation = json["message"] as! NSDictionary
                                    
                                    let msg = json["message"] as? NSDictionary
                                    for (_,value) in msg!
                                    {
                                        response["message"] = "\(value)" as AnyObject?
                                        
                                    }
                                    if let _ = msg!["filedata"] as? String
                                    {
                                        response["message"] = msg!["filedata"] as? String as AnyObject?
                                    }
                                    if let _ = msg!["profileur"] as? String
                                    {
                                        response["message"] = msg!["profileur"] as? String as AnyObject?
                                    }
                                    if let _ = msg!["category_id"] as? String
                                    {
                                        response["message"] = msg!["category_id"] as? String as AnyObject?
                                    }
                                    
                                    
                                    if let _ =  msg!["title"] as? String
                                    {
                                        response["message"] = msg!["title"] as? String as AnyObject?
                                    }
                                    
                                    if let _ = msg!["pros"] as? String{
                                        response["message"] = msg!["pros"] as? String as AnyObject?
                                    }
                                    if let _ =  msg!["cons"] as? String{
                                        response["message"] = msg!["cons"] as? String as AnyObject?
                                        
                                    }
                                    if let _ =  msg!["body"] as? String{
                                        response["message"] = msg!["body"] as? String as AnyObject?
                                    }
                                    if let _ = msg!["password"] as? String
                                    {
                                        response["message"] = msg!["password"] as? String as AnyObject?
                                    }
                                    
                                    if let _ = msg!["group_uri"] as? String
                                    {
                                        response["message"] = msg!["group_uri"] as? String as AnyObject?
                                    }
                                    
                                    
                                    
                                }
                                else
                                {
                                    response["message"] = "Oops,Server not responding :(" as AnyObject?
                                    
                                }
                                
                            }
                            status = false
                            
                            
                        case 406 :
                            status = false
                            forceFullyLogout()
                            
                        default:
                            break
                        }
                        
                        postCompleted(response as NSDictionary, status)
                    }
                }
                else
                {
                    // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                    
                    _ = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    ////print("Error could not parse JSON2: \(String(describing: jsonStr))")
                    response["message"] = "Can't read Response from Server" as AnyObject?
                    postCompleted(response as NSDictionary , false)
                }
            }
            catch
            {
                ////print(error)
                ////print(String(data: data!, encoding: .utf8) as Any)
            }
            
            
        }
    })
    currentTask = task
    task.resume()
    session.finishTasksAndInvalidate()

}
/// Create request
///
/// - parameter userid:   The userid to be passed to web service
/// - parameter password: The password to be passed to web service
/// - parameter email:    The email address to be passed to web service
///
/// - returns:         The NSURLRequest that was created

func createRequest (_ param:Dictionary<String, String>, url:URL ,path:[String],filePathKey:String, SinglePhoto:Bool) -> URLRequest {
    
    let boundary = generateBoundaryString()
    /*
     var finalurl : NSURL
    if (isCreateOrEdit)
    {
        //finalurl = NSURL(string : baseUrl+url)!
       // let url : NSString = baseUrl+url+buildQueryString(fromDictionary:param) as NSString
       // let urlStr : NSString = url.addingPercentEscapes(using: String.Encoding.utf8.rawValue)! as NSString
       // finalurl  = NSURL(string: urlStr as String)!
        
        if buildQString == "bundled"
        {
            let url1 : NSString =  baseUrl+url+buildQueryString(fromDictionary:param) as NSString
            let urlStr : NSString = url1.addingPercentEscapes(using: String.Encoding.utf8.rawValue)! as NSString
            finalurl  = NSURL(string: urlStr as String)!
        }
        else
        {
            finalurl = URL(string: baseUrl+url)! as NSURL//URL(string : baseUrl+url+buildQueryString(fromDictionary:param))! as NSURL
        }
        
      //  finalurl = NSURL(string : baseUrl+url+buildQueryString(fromDictionary:param) as String)! as URL
    }else{
        finalurl = URL(string : baseUrl+url+buildQueryString(fromDictionary:param))! as NSURL
    }
    */
        
    //let url = URL(string: baseUrl+url)!
    let request = NSMutableURLRequest(url: url)//NSMutableURLRequest(url: finalurl as URL)
    ////print("\(finalurl)")
    request.httpMethod = "POST"
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    let body = createBodyWithParameters(param,filePathKey: "\(filePathKey)", paths: path, boundary: boundary,SinglePhoto: SinglePhoto)
    request.httpBody = body
    request.addValue("\(body.count)", forHTTPHeaderField: "Content-Length")
    
    return request as URLRequest
}


func createActivityRequest (_ param:Dictionary<String, AnyObject>, url:String ,path:[String],filePathKey:String, SinglePhoto:Bool) -> URLRequest {
    
    let boundary = generateBoundaryString()
    let url = URL(string: baseUrl+url)!
   // ////print(url)
   // ////print(param)
    let request = NSMutableURLRequest(url: url)
    request.httpMethod = "POST"

    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    let body = createActivityBodyWithParameters(param,filePathKey: "\(filePathKey)", paths: path, boundary: boundary,SinglePhoto: SinglePhoto)
    request.httpBody = body
    request.addValue("\(body.count)", forHTTPHeaderField: "Content-Length")
    
    return request as URLRequest
}


/// Create body of the multipart/form-data request
///
/// - parameter parameters:   The optional dictionary containing keys and values to be passed to web service
/// - parameter filePathKey:  The optional field name to be used when uploading files. If you supply paths, you must supply filePathKey, too.
/// - parameter paths:        The optional array of file paths of the files to be uploaded
/// - parameter boundary:     The multipart/form-data boundary
///
/// - returns:            The NSData of the body of the request

func createBodyWithParameters(_ parameters: Dictionary<String, String>, filePathKey: String?, paths: [String]?, boundary: String,SinglePhoto:Bool) -> Data {
    
    let body = NSMutableData()
    
    if parameters.count != 0 {
        for (key, value) in parameters {
            body.appendString("\r\n--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString("\(value)")
        }
    }
    
    
    var i = 0;
    if paths != nil
    {
        if uploadMultiplePhoto != ""{
            for path in paths!
            {
                i += 1;
                let filename = (path as NSString).lastPathComponent
                var filekeyvalueArr = filename.components(separatedBy: " ")
                ////print("filename \(filename)")
                let patharr = path.components(separatedBy: " ")
                let data = try? Data(contentsOf: URL(fileURLWithPath: patharr[0]))
                ////print("data length \(String(describing: data?.count))")
                let mimetype = mimeTypeForPath(path)
                ////print("mime Type \(mimetype)")
                body.appendString("\r\n--\(boundary)\r\n")
                if SinglePhoto {
                    body.appendString("Content-Disposition: form-data; name=\"" + filekeyvalueArr[0] + "\"; filename=\"" + filekeyvalueArr[0] + "\"\r\n")
                    
                }else{
                    body.appendString("Content-Disposition: form-data; name=\"" + filekeyvalueArr[1] + String(i) + "\"; filename=\"" + filekeyvalueArr[0] + "\"\r\n")
                }
                body.appendString("Content-Type: " + mimetype + "\r\n\r\n")
                body.append(data!)
                
            }
        }
        else{
            for path in paths!
            {
                i += 1;
                let filename = (path as NSString).lastPathComponent
                ////print("filename \(filename)")
                let data = try? Data(contentsOf: URL(fileURLWithPath: path))
                ////print("data length \(String(describing: data?.count))")
                let mimetype = mimeTypeForPath(path)
                ////print("mime Type \(mimetype)")
                body.appendString("\r\n--\(boundary)\r\n")
                if SinglePhoto
                {
                    
                    if mimetype == "image/png"
                    {
                        body.appendString("Content-Disposition: form-data; name=\"photo\"; filename=\"" + filename + "\"\r\n")
                    }
                    else
                    {
                        body.appendString("Content-Disposition: form-data; name=\"" + filePathKey! + "\"; filename=\"" + filename + "\"\r\n")
                    }
                    
                }else{
                    body.appendString("Content-Disposition: form-data; name=\"" + filePathKey! + String(i) + "\"; filename=\"" + filename + "\"\r\n")
                }
                body.appendString("Content-Type: " + mimetype + "\r\n\r\n")
                body.append(data!)
                
            }
        
        }
    }
    body.appendString("\r\n--\(boundary)\r\n")
    return body as Data
}


// Upload photo from activity feed
func createActivityBodyWithParameters(_ parameters: Dictionary<String, AnyObject>, filePathKey: String?, paths: [String]?, boundary: String,SinglePhoto:Bool) -> Data {
    ////print("filePathKey " + filePathKey!)
    let body = NSMutableData()
    if parameters.count != 0 {
        for (key, value) in parameters {
            body.appendString("\r\n--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString("\(value)")
        }
    }
    ////print(body)
    
    var i = 0;
    if paths != nil {
        let count = paths!.count
        for (index,path) in paths!.enumerated() {
            i += 1;
            let filename = (path as NSString).lastPathComponent
            ////print("filename " + filename)
            let data = try? Data(contentsOf: URL(fileURLWithPath: path))
            ////print("data length " + String(describing: data?.count))
            let mimetype = mimeTypeForPath(path)
            ////print("mime Type " + String(mimetype))
            body.appendString("\r\n--" + boundary + "\r\n")
            if SinglePhoto
            {
                if mimetype == "image/png"
                {
                    if count == 3
                    {
                        if isStoryUploadingCompleted == false
                        {
                            if index == 1
                            {
                                body.appendString("Content-Disposition: form-data; name=\"video_thumbnail\"; filename=\"" + filename + "\"\r\n")
                            }
                            else if index == 2
                            {
                                body.appendString("Content-Disposition: form-data; name=\"video_overlay_image\"; filename=\"" + filename + "\"\r\n")
                            }
                        }
                        else
                        {
                            if index == 1
                            {
                                body.appendString("Content-Disposition: form-data; name=\"photo\"; filename=\"" + filename + "\"\r\n")
                            }
                            else if index == 2
                            {
                                body.appendString("Content-Disposition: form-data; name=\"video_overlay_image\"; filename=\"" + filename + "\"\r\n")
                            }
                        }
                    }
                    else
                    {
                        if isStoryUploadingCompleted == false
                        {
                            body.appendString("Content-Disposition: form-data; name=\"video_thumbnail\"; filename=\"" + filename + "\"\r\n")
                        }
                        else
                        {
                            body.appendString("Content-Disposition: form-data; name=\"photo\"; filename=\"" + filename + "\"\r\n")
                        }
                    }
                
                }
                else
                {
                    body.appendString("Content-Disposition: form-data; name=\"" + filePathKey! + "\"; filename=\"" + filename + "\"\r\n")

                }

            }else{
                body.appendString("Content-Disposition: form-data; name=\"" + filePathKey! + String(i) + "\"; filename=\"" + filename + "\"\r\n")
            }
            body.appendString("Content-Type: " + mimetype + "\r\n\r\n")
            body.append(data!)
        }
    }
    
    body.appendString("\r\n--" + boundary + "\r\n")
    
    
    return body as Data
}



func generateBoundaryString() -> String {
    return "Boundary-\(UUID().uuidString)"
}

/// Determine mime type on the basis of extension of a file.
///
/// This requires MobileCoreServices framework.
///
/// - parameter path:         The path of the file for which we are going to determine the mime type.
///
/// - returns:            Returns the mime type if successful. Returns application/octet-stream if unable to determine mime type.

func mimeTypeForPath(_ path: String) -> String {
    let pathExtension = (path as NSString).pathExtension
    
    if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue() {
        if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
            return mimetype as NSString as String
        }
    }
    return "application/octet-stream";
    
    
}



// Create String From Dictionary
func stringFromDictionary(_ params : Dictionary<String, String>) -> String{
    
    // Create String From Parameters For POST Request
    var str = ""
    for key in params.keys {
        var value = params[key]!
        let characters = (CharacterSet.urlQueryAllowed as NSCharacterSet).mutableCopy() as! NSMutableCharacterSet
        characters.removeCharacters(in: "&")
        characters.removeCharacters(in: "+")
        value = value.addingPercentEncoding(withAllowedCharacters: characters as CharacterSet)!
        str += "\(key)=\(value)&"
    }
   // str = str.substring(to: str.index(str.startIndex, offsetBy: str.length - 1))
    if str != ""{
        str = String(str[..<str.index(str.startIndex, offsetBy: str.length - 1)])
    }
    return str
}

// Create String From Dictionary
func activityStringFromDictionary(_ params : Dictionary<String, AnyObject>) -> String{
    
    // Create String From Parameters For POST Request
    var str = ""
    for key in params.keys
    {
        var value = params[key]!
        let characters = (CharacterSet.urlQueryAllowed as NSCharacterSet).mutableCopy() as! NSMutableCharacterSet
        characters.removeCharacters(in: "&")
        characters.removeCharacters(in: "+")
        if let stringValue = value as? String
        {
            value = stringValue.addingPercentEncoding(withAllowedCharacters: characters as CharacterSet) as AnyObject
        }
        //let finalReplace1 = params[key]!.replacingOccurrences(of: "\"", with: "")
        ////print(finalReplace1)
        str += "\(key)=\(value)&"
    }
    str = String(str[..<str.index(str.startIndex, offsetBy: str.length - 1)])
    return str
}


// Generation of Query String
func buildQueryString(fromDictionary parameters: [String:String]) -> String
{
    
    // Create Query String From Parameters For GET Request
    var urlVars = [String]()
    for (var k, var v) in parameters {
        
        let characters = (CharacterSet.urlQueryAllowed as NSCharacterSet).mutableCopy() as! NSMutableCharacterSet
        characters.removeCharacters(in: "&")
        v = v.addingPercentEncoding(withAllowedCharacters: characters as CharacterSet)!
        k = k.addingPercentEncoding(withAllowedCharacters: characters as CharacterSet)!
        urlVars += [k + "=" + "\(v)"]
    }
    return (!urlVars.isEmpty ? "?" : "") + urlVars.joined(separator: "&")
}

// Generation of Query String
func activityBuildQueryString(fromDictionary parameters: [String:Any]) -> String {
    
    // Create Query String From Parameters For GET Request
    var urlVars = [String]()
    for (k, var v) in parameters {
        
        let characters = (CharacterSet.urlQueryAllowed as NSCharacterSet).mutableCopy() as! NSMutableCharacterSet
        
        characters.removeCharacters(in: "&")
        
        let vAsAnyObject = v as AnyObject
        let vAfteraddingPercentEncoding = vAsAnyObject.addingPercentEncoding(withAllowedCharacters: characters as CharacterSet)
        v = vAfteraddingPercentEncoding! as String
        
        urlVars += [k + "=" + (v as! String)]
    }
    
    return (!urlVars.isEmpty ? "?" : "") + urlVars.joined(separator: "&")
}


// Make Connection For Download Data From Server such as Image, Video, file etc.
func downloadData(_ url:URL, downloadCompleted : @escaping (_ downloadedData:Data , _ msg: Bool) -> ()){
    // Changed Code For Image View
    let request: URLRequest = URLRequest(url: url)
    let mainQueue = OperationQueue.main
    NSURLConnection.sendAsynchronousRequest(request, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
        if error == nil {
            downloadCompleted(data!, true)
        }
        else {
            ////print("Error: \(error!.localizedDescription)")
        }
    })
    
}

func forceFullypop()
{
    
    let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController
    navigationController!.popViewController(animated: false)
    
}
func forceFullyLogout(){
    if((AccessToken.current) != nil){
        let loginManager = LoginManager()
        loginManager.logOut()
    }
    
    menuRefreshConter = 0
    let defaults = UserDefaults.standard
    defaults.set("", forKey: "Location")
    defaults.setValue("", forKey: "rating")
    defaults.setValue("", forKey: "key")
    defaults.setValue("", forKey: "userEmail")
    defaults.setValue("", forKey: "userPassword")
    defaultlocation = ""
    logoutUser = true
    refreshMenu = true
    deleteAAFEntries()
    
    let request: NSFetchRequest<UserInfo>
    if #available(iOS 10.0, *) {
        request = UserInfo.fetchRequest() as! NSFetchRequest<UserInfo>
    } else {
        request = NSFetchRequest(entityName: "UserInfo")
    }
    
    request.returnsObjectsAsFaults = false
    let results = try? context.fetch(request)
    if(results?.count>0){
        for result: AnyObject in results! {
            if let _ = result.value(forKey: "oauth_token") as? String{
                context.delete(result as! NSManagedObject)
            }
        }
        do {
            try context.save()
        } catch _ {
        }
    }
    if let topController = UIApplication.topViewController() {
        if showAppSlideShow == 1 {
            let pv  = SlideShowLoginScreenViewController()
            let nativationController = UINavigationController(rootViewController: pv)
            topController.present(nativationController, animated:false, completion: nil)
            
        }
        else{
        let pv = LoginViewController()
        let nativationController = UINavigationController(rootViewController: pv)
        topController.present(nativationController, animated:false, completion: nil)
        }
        //        topController.navigationController?.pushViewController(pv, animated: false)
    }
    
}


// MARK: - Create Server Connection Here for Every Request For Activity Posts
func receiptPost(_ params : Dictionary<String, AnyObject>, receipt: AnyObject, url : String, method:String , postCompleted : @escaping (_ succeeded:NSDictionary , _ msg: Bool) -> ()) {
    
    var dic = Dictionary<String, AnyObject>()
    
    if(logoutUser == false){
        dic["oauth_token"] = oauth_token as AnyObject?
        dic["oauth_secret"] = oauth_secret as AnyObject?
    }
    dic["oauth_consumer_secret"] = "\(oauth_consumer_secret)" as AnyObject?
    dic["oauth_consumer_key"] = "\(oauth_consumer_key)" as AnyObject?
    dic["language"] = "\( (Locale.current as NSLocale).object(forKey: NSLocale.Key.languageCode)!)" as AnyObject?
    if ios_version != nil && ios_version != "" {
        
        dic["_IOS_VERSION"] = ios_version as AnyObject?
    }
    
    dic.update(params)
    // Create Request URL
    var finalurl : URL
    
    // Create Query String for GET Request with URL
    finalurl = URL(string: baseUrl+url+activityBuildQueryString(fromDictionary:dic))!
    
    //if method == "POST"{
        finalurl = URL(string: baseUrl+url+activityBuildQueryString(fromDictionary:dic))!
//    }else if method == "PUT"{
//        finalurl = URL(string: baseUrl+url)!
//    }
    let request = NSMutableURLRequest(url: finalurl)
    print(request)
    request.httpMethod = method
    dic["receipt"] = receipt
    print("receipt  \(receipt)")
    if (request.httpMethod == "POST") {
        // Create String from Dictionary for POST Request
        let str = activityStringFromDictionary(dic)
        ////print("===========actvitystr===============")
        ////print(str)
        ////print("==========================")
        request.httpBody = (str as NSString).data(using: String.Encoding.utf8.rawValue)
    }
    //    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    
    ////print("<<<<<<<<<<<<<<<<<=============final Url=============>>>>>>>>>>>>>>>>>>>>")
    ////print(finalurl)
    ////print("<<<<<<<<<<<<<<<<<<==========request body================>>>>>>>>>>>>>>>>>>>>")
    print("receipts  \(request)")
    createServerRequest(request as URLRequest, postCompleted: { (succeeded, msg) -> () in
        postCompleted(succeeded, msg)
    })
    
}

