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

//  RawFile.swift

import Foundation
import UIKit
import Photos
import CoreData
import QuartzCore
import MobileCoreServices


extension String {
    var length1: Int {
        return self.count
        //return characters.count
    }
        func stringByAppendingPathComponent1(_ path: String) -> String {
        
        let nsSt = self as NSString
        
        return nsSt.appendingPathComponent(path)
    }
}

extension Dictionary {
    mutating func update1(_ other:Dictionary) {
        for (key,value) in other {
            self.updateValue(value, forKey:key)
        }
    }
}
extension NSMutableData {
    
    /// Append string to NSMutableData
    ///
    /// Rather than littering my code with calls to `dataUsingEncoding` to convert strings to NSData, and then add that data to the NSMutableData, this wraps it in a nice convenient little extension to NSMutableData. This converts using UTF-8.
    ///
    /// - parameter string:       The string to be added to the `NSMutableData`.
    
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}

// MARK: - Create Server Connection Here for Every Request For Activity Posts
func activityPost(_ params : Dictionary<String, AnyObject>, url : String, method:String , postCompleted : @escaping (_ succeeded:NSDictionary , _ msg: Bool) -> ()) {
    
    var dic = Dictionary<String, AnyObject>()
    
    if(logoutUser1 == false){
        
        dic["oauth_token"] = "\(oauth_token1!)" as AnyObject?
        dic["oauth_secret"] = "\(oauth_secret1!)" as AnyObject?
        
    }
    dic["oauth_consumer_secret"] = "\(oauth_consumer_secret1)" as AnyObject?
    dic["oauth_consumer_key"] = "\(oauth_consumer_key1)" as AnyObject?
    dic["language"] = "\( (Locale.current as NSLocale).object(forKey: NSLocale.Key.languageCode)!)" as AnyObject?
    if ios_version1 != nil && ios_version1 != "" {
        dic["_IOS_VERSION"] = "\(ios_version1!)" as AnyObject?
    }
    dic.update1(params)
    // Create Request URL
    var finalurl : URL
    
    // Create Query String for GET Request with URL
    finalurl = URL(string: baseUrl1+url+activityBuildQueryString(fromDictionary:dic))!
    
   // if method == "POST"{
        finalurl = URL(string: baseUrl1+url+activityBuildQueryString(fromDictionary:dic))!
//    }else if method == "PUT"{
//        finalurl = URL(string: baseUrl1+url)!
//    }
    let request = NSMutableURLRequest(url: finalurl)
    request.httpMethod = method
    print(finalurl)
    
    if (request.httpMethod == "POST") {
        // Create String from Dictionary for POST Request
        let str = activityStringFromDictionary(dic)
        request.httpBody = (str as NSString).data(using: String.Encoding.utf8.rawValue)
    }
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    createServerRequest(request as URLRequest, postCompleted: { (succeeded, msg) -> () in
        postCompleted(succeeded, msg)
    })
    
}

// Generation of Query String
func activityBuildQueryString(fromDictionary parameters: [String:Any]) -> String {
    
    var urlVars = [String]()
    for (k, var v) in parameters {
        
        let characters = (CharacterSet.urlQueryAllowed as NSCharacterSet).mutableCopy() as! NSMutableCharacterSet
        
        characters.removeCharacters(in: "&")
        characters.removeCharacters(in: "+")
        
        let vAsAnyObject = v as AnyObject
        let vAfteraddingPercentEncoding = vAsAnyObject.addingPercentEncoding(withAllowedCharacters: characters as CharacterSet)
        v = vAfteraddingPercentEncoding! as String
        urlVars += [k + "=" + (v as! String)]
    }
    
    return (!urlVars.isEmpty ? "?" : "") + urlVars.joined(separator: "&")
}

   func createServerRequest(_ request:URLRequest, postCompleted : @escaping (_ succeeded:NSDictionary , _ msg: Bool) -> ()){
    
    //Create Session Request
    let urlconfig = URLSessionConfiguration.default
    urlconfig.timeoutIntervalForRequest = 180
    urlconfig.timeoutIntervalForResource = 180
    let session = URLSession(configuration: urlconfig)
    
    let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
        
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
                    
                    var status : Bool! = false
                    
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
                            if json["body"] != nil{
                                response["body"] = json["body"] as! NSDictionary
                            }
                            //                    if json["message"] != nil{
                            response["message"] = NSLocalizedString("Your action has been performed successfully.",  comment: "") as AnyObject?
                            //                    }
                            
                            status = true
                            
                        case 400, 401 , 404, 500:
                            
                            //print("status code =====\(json["status_code"] as! Int)")
                            if json["message"] != nil
                            {
                                
                                
                                if (json["message"] is String)
                                {
                                    response["message"] = json["message"] as! String as AnyObject?
                                    
                                    
                                }
                                else if (json["message"] is NSDictionary)
                                {
                                    
                                    let msg = json["message"] as? NSDictionary
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
                                    
                                    
                                    
                                    
                                }
                                    
                                else
                                {
                                    response["message"] = "Oops,Server not responding :(" as AnyObject?
                                    
                                }
                                
                            }
                            status = false
                            
                            
                        default:
                            break
                        }
                        postCompleted(response as NSDictionary, status)
                    }
                }
                else
                {
                    // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                    
                   // let jsonStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    //print("Error could not parse JSON2: \(String(describing: jsonStr))")
                    response["message"] = "Can't read Response from Server" as AnyObject?
                    postCompleted(response as NSDictionary , false)
                }
            }
            catch
            {
                //print(error)
            }
            
            
        }
    })
    
    task.resume()
    
    
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
        //print(finalReplace1)
        str += "\(key)=\(value)&"
    }
    str = String(str[..<str.index(str.startIndex, offsetBy: str.length1 - 1)])
    return str
}


func saveFileInDocumentDirectory(_ images :[AnyObject]) ->([String]){
    var getImagePath = [String]()
    let fileManager = FileManager.default
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
    var i = 0
    for image in images{
        i += 1
        var filename = ""
            let tempImageString = randomStringWithLength(8)
            filename = "\(tempImageString)\(i).png"
        let filePathToWrite = "\(paths)/\(filename)"
        if fileManager.fileExists(atPath: filePathToWrite){
            removeFileFromDocumentDirectoryAtPath(filePathToWrite)
        }
        
        var imageData: Data!
       
            imageData =  (image as! UIImage).jpegData(compressionQuality: 0.7)
         fileManager.createFile(atPath: filePathToWrite, contents: imageData, attributes: nil)
        getImagePath.append(paths.stringByAppendingPathComponent1("\(filename)"))
        
    }
    
    return getImagePath;
}

func randomStringWithLength (_ len : Int) -> NSString {
    let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let randomString : NSMutableString = NSMutableString(capacity: len)
    for _ in 0 ..< len {
        let length = UInt32 (letters.length)
        let rand = arc4random_uniform(length)
        randomString.appendFormat("%C", letters.character(at: Int(rand)))
    }
    return randomString
}

///
func removeFileFromDocumentDirectoryAtPath(_ getImagePath:String){
    
    let fileManager = FileManager.default
    if (fileManager.fileExists(atPath: getImagePath))
    {
        do {
            try fileManager.removeItem(atPath: getImagePath)
        } catch _ {
        }
    }
    else
    {
        //print("FILE NOT AVAILABLE, write new");
    }
    
}

// MARK: - Create Server Connection Here for Every Request For Post Activity Forms
func postActivityForm(_ params : Dictionary<String, AnyObject>, url : String, filePath:[String], filePathKey:String ,SinglePhoto:Bool, postCompleted : @escaping (_ succeeded:NSDictionary , _ msg: Bool) -> ()){
    
    var dic = Dictionary<String, AnyObject>()
    
    if(logoutUser1 == false){
        dic["oauth_token"] = "\(oauth_token1!)" as AnyObject?
        dic["oauth_secret"] = "\(oauth_secret1!)" as AnyObject?
    }
    dic["oauth_consumer_secret"] = "\(oauth_consumer_secret1)" as AnyObject?
    dic["oauth_consumer_key"] = "\(oauth_consumer_key1)" as AnyObject?
    dic["language"] = "\( (Locale.current as NSLocale).object(forKey: NSLocale.Key.languageCode)!)" as AnyObject?
    if ios_version1 != nil && ios_version1 != "" {
        dic["_IOS_VERSION"] = "\(ios_version1!)" as AnyObject?
        
    }
    dic.update1(params)
    print(url)
    let request = createActivityRequest(dic, url: url, path: filePath, filePathKey: filePathKey,SinglePhoto: SinglePhoto)
    //print(request)
    createServerRequest(request, postCompleted: { (succeeded, msg) -> () in
        postCompleted(succeeded, msg)
    })
}


func createActivityRequest (_ param:Dictionary<String, AnyObject>, url:String ,path:[String],filePathKey:String, SinglePhoto:Bool) -> URLRequest {
    
    let boundary = generateBoundaryString()
    
    let url = URL(string: baseUrl1+url)!
    //print(url)
    let request = NSMutableURLRequest(url: url)
    
        request.httpMethod = "POST"
       
    
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    
    let body = createActivityBodyWithParameters(param,filePathKey: "\(filePathKey)", paths: path, boundary: boundary,SinglePhoto: SinglePhoto)
    request.httpBody = body
    request.addValue("\(body.count)", forHTTPHeaderField: "Content-Length")
    
    return request as URLRequest
}
////

func generateBoundaryString() -> String {
    return "Boundary-\(UUID().uuidString)"
}
func createActivityBodyWithParameters(_ parameters: Dictionary<String, AnyObject>, filePathKey: String?, paths: [String]?, boundary: String,SinglePhoto:Bool) -> Data {
    //print("filePathKey " + filePathKey!)
    
    let body = NSMutableData()
    
    if parameters.count != 0 {
        for (key, value) in parameters {
            body.appendString("\r\n--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString("\(value)")
        }
    }
    
    
    var i = 0;
    if paths != nil {
        for path in paths! {
            i += 1;
            let filename = (path as NSString).lastPathComponent
            //print("filename " + filename)
            let data = try? Data(contentsOf: URL(fileURLWithPath: path))
            //print("data length " + String(describing: data?.count))
            let mimetype = mimeTypeForPath(path)
            //print("mime Type " + String(mimetype))
            body.appendString("\r\n--" + boundary + "\r\n")
            if SinglePhoto {
                body.appendString("Content-Disposition: form-data; name=\"" + filePathKey! + "\"; filename=\"" + filename + "\"\r\n")
                //print("Content-Disposition: form-data; name=\"" + filePathKey! + "\"; filename=\"" + filename + "\"\r\n")
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


func mimeTypeForPath(_ path: String) -> String {
    let pathExtension = (path as NSString).pathExtension
    
    if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue() {
        if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
            return mimetype as NSString as String
        }
    }
    return "application/octet-stream";
    
    
}

func fixOrientation(img:UIImage) -> UIImage {
    
    if (img.imageOrientation == UIImage.Orientation.up) {
        return img;
    }
    UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale);
    let rect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
    img.draw(in: rect)
    let normalizedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext();
    return normalizedImage;
    
}


