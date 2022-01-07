//
//  SwiftExampleViewController.swift
//  SimpleChat
//
//  Created by Logan Wright on 11/15/14.
//  Copyright (c) 2014 Logan Wright. All rights reserved.
//


import UIKit
var currentUserMessage:Bool = false
var attachPhotoImage = [UIImage]()
var attachmentMessageLink : Bool = false
var conversationVar:Bool = false
var linkUrl : String! = ""
var videoUrl : String!
var videoId : String!
var isSendMessage:Int = 1
class ConverstationViewController: UIViewController, LGChatControllerDelegate {
    var conversation_id = 1
    var converstationTableView:UITableView!
    var isPageRefresing = false
    var showSpinner = true
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var conversation = [AnyObject]()            // For response come from Server
    var dynamicHeight:CGFloat = 100              // Dynamic Height fort for Cell
    var refresher:UIRefreshControl!             // Pull to refrresh
    var updateScrollFlag = true                 // Paginatjion Flag
    var conversationTitle : UILabel!
    var msgBodyText : UITextView!
    var sendButton: UIButton!
    var imaged : UIImage!
    var keyboard_height: CGFloat!
    var messagePostView : UIView!
    var subject: String!
    var displaysendername:String!
    var recepientsCount:Int! = 0
    var count = 3
    var i = 0
    var auth_View: String = ""
    var leftBarButtonItem : UIBarButtonItem!
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.white
        super.viewDidLoad()
        conversationVar = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(ConverstationViewController.showMsg), name: NSNotification.Name(rawValue: "isSendMessage"), object: nil)
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(ConverstationViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem

        
        if self.displaysendername != nil {
            self.title = self.displaysendername
        }
  
        self.browseConversations()
    }
    
    @objc func goBack() {
        filePathArray.removeAll(keepingCapacity: false)
        _ = self.navigationController?.popViewController(animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if(conversationVar == true){
            _ = self.navigationController?.popViewController(animated: false)
        }
    }
    
    @objc func showMsg()
    {
        UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("You do not have permission to send message",  comment: ""), duration: 3, position: CSToastPositionCenter)
    }
    
    // MARK: Launch Chat Controller
    func browseConversations(){
        
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {
            // showSpinner = false
            if (showSpinner)
            {
                activityIndicatorView.center = view.center
                self.view.addSubview(activityIndicatorView)
                activityIndicatorView.startAnimating()
            }
            var path = ""
            var parameters = [String:String]()
            // Set Parameters for Browse/MyBlog
            path = "messages/view"
            parameters = ["page":"\(pageNumber)" , "limit": "\(limit)", "id":"\(conversation_id)"]
            
            // Set Parameters for Search
            if searchDic.count > 0 {
                parameters.merge(searchDic)
            }
            
            // Send Server Request to Browse Blog Entries
            post(parameters, url: path, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    if msg
                    {
                        //self.conversation.removeAll(keepingCapacity: false)
                        if let response = succeeded["body"] as? NSDictionary{
                            print(response)
                            
                            //self.showSpinner = true
                            
                            if let conversationns = response["conversation"] as? NSDictionary{
                                if let recepients = conversationns["recipients"] as? Int {
                                    self.recepientsCount = recepients
                                }
                                if let isSendMsg = conversationns["isSendMessage"] as? Int {
                                    isSendMessage = isSendMsg
                                }
                            }
                            
                            if(self.recepientsCount > 2){
                                self.title = self.displaysendername + "(+" + String(self.recepientsCount) + " Participants)"
                            }
                            else{
                                self.title = self.displaysendername
                            }
                            
                            if response["messages"] != nil{
                                if let message = response["messages"] as? NSArray {
                                    self.conversation = self.conversation + (message as [AnyObject])
                                    
                                }
                            }
                            
                            if response["totalItemCount"] != nil{
                                self.totalItems = response["totalItemCount"] as! Int
                            }
                        }
                        self.isPageRefresing = false
                        
                        if self.totalItems == self.conversation.count
                        {
                            self.showSpinner = true
                            activityIndicatorView.stopAnimating()
                            self.launchChatController()
                            
                        }
                        else
                        {
                            self.showSpinner = false
                            self.getAllMessage()
                        }
                        
                    }else{
                        // Handle Server Error
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                        }
                    }
                })
            }
        }else{
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self)
        }
        
    }
    
    func getAllMessage()
    {
        if self.totalItems != self.conversation.count
        {
            self.pageNumber += 1
            self.browseConversations()
        }
    }
    
    func launchChatController() {
        conversationVar = true

        var attachment:NSDictionary! = [:]
        let chatController = LGChatController()
        
        for i in stride(from: 0, to: conversation.count, by: 1){
            var conversationInfo:NSDictionary
            var user_id :Int!
            conversationInfo = conversation[i] as! NSDictionary
            var message:NSDictionary
            message = conversationInfo["message"] as! NSDictionary
            if conversationInfo["attachment"] != nil{
                attachment = conversationInfo["attachment"] as! NSDictionary
            }
            var sender:NSDictionary
            sender = conversationInfo["sender"] as! NSDictionary
            conversation_id = message["conversation_id"] as! Int
            chatController.conversation_id = message["conversation_id"] as! Int
            user_id = message["user_id"] as! Int
            var tempString = ""
            if let _ = message["body"] as? String{
                let bodyMsg = message["body"] as? String
                if let tempDecription = bodyMsg{
                    tempString =  tempDecription.html2String as String
                    if conversationInfo["attachment"] == nil{
                        if let subString = tempDecription.subString(after: "=\"", before: "\">")
                        {
                            attachment = ["image": subString, "description": "", "title": ""]
                        }
                    }
                }                
            }

            else  if let _ = message["body"] as? Int{

                let bodyMsg2 = (message["body"] as? Int)!
                let  bodyMsg = String(bodyMsg2)
                tempString = bodyMsg
            }
            let messageDate = message["date"] as? String
            let postedOn = dateDifference(messageDate!)

            
            let imageString = sender["image_normal"] as! String
            
            if(self.recepientsCount > 1){
                chatController.title = self.displaysendername + "(+" + String(self.recepientsCount) + " Participants)"
                self.title = self.displaysendername + "(+" + String(self.recepientsCount) + " Participants)"
            }
            else{
                chatController.title = self.displaysendername
                self.title = self.displaysendername
            }
            
            if (currentUserId == (sender["user_id"] as! Int)){
                currentUserMessage = true
                let helloWorldd = LGChatMessage(content: "\(tempString)", sentBy: .User, date: "\(postedOn)",imageUrl : "\(imageString)", userId: user_id,attachment:attachment)
                chatController.messages += [helloWorldd]
                
            }else{
                currentUserMessage = false
                let helloWorld = LGChatMessage(content: "\(tempString)", sentBy: .Opponent, date: "\(postedOn)",imageUrl : "\(imageString)", userId: user_id,attachment:attachment)
                chatController.messages += [helloWorld]
            }
        }
        
        
        chatController.delegate = self
        self.navigationController?.pushViewController(chatController, animated: false)
        
    }
    
    // MARK: LGChatControllerDelegate
    
    func chatController(_ chatController: LGChatController, didAddNewMessage message: LGChatMessage) {
        var path = ""
        var parameters = [String:String]()
        path = "messages/view"
        mediaType = "image"
        if let privacy = UserDefaults.standard.string(forKey: "privacy"){
            auth_View = privacy
        }else{
            auth_View = "everyone"
        }
        
        parameters = ["page":"\(pageNumber)" , "limit": "\(limit)", "id":"\(conversation_id)", "body":"\(message.content)"]
        
        if(attachmentMessageLink == true){
            if attachPhotoImage.count > 0 {
                filePathArray.removeAll(keepingCapacity: false)
                parameters["type"] = "photo"
                parameters["post_attach"] = "1"
                filePathArray = saveFileInDocumentDirectory(attachPhotoImage)
                attachmentMessageLink = false
                attachPhotoImage.removeAll(keepingCapacity: false)
                
                
                postActivityForm(parameters as Dictionary<String, AnyObject>, url: path, filePath: filePathArray , filePathKey: "photo", SinglePhoto: true){ (succeeded, msg) -> () in
                        DispatchQueue.main.async(execute: {
                           activityIndicatorView.stopAnimating()
                            
                            if msg{
                                
                                for path in filePathArray{
                                    removeFileFromDocumentDirectoryAtPath(path)
                                }
                                filePathArray.removeAll(keepingCapacity: false)
                            }
                        })

                }
                
            }
                
            else if linkUrl != ""{
                parameters["type"] = "link"
                parameters["uri"] = linkUrl
                parameters["post_attach"] = "1"
                
                linkUrl = ""
                attachmentMessageLink = false
                
                activityPost(parameters as Dictionary<String, AnyObject>, url: path, method: "POST") { (succeeded, msg) -> () in
                    DispatchQueue.main.async(execute: {
                        activityIndicatorView.stopAnimating()
                    })
                    
                }
                
                
            }
            else if videoUrl != ""{

                parameters["video_id"] = videoId
                parameters["type"] = "video"
                parameters["post_attach"] = "1"
                videoUrl = ""
                attachmentMessageLink = false
                activityPost(parameters as Dictionary<String, AnyObject>, url: path, method: "POST") { (succeeded, msg) -> () in
                    DispatchQueue.main.async(execute: {
                        activityIndicatorView.stopAnimating()
                    })

                }
                
            }
        }
        else{
            post(parameters, url: path, method: "POST") {
                
                (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    
                })
                
            }
        }
        
    }
    
    func shouldChatController(_ chatController: LGChatController, addMessage message: LGChatMessage) -> Bool {
        
        /*
         Use this space to prevent sending a message, or to alter a message.  For example, you might want to hold a message until its successfully uploaded to a server.
         */
        return true
    }
    
}

extension StringProtocol where Index == String.Index {
    func subString(after: String, before: String? = nil, options: String.CompareOptions = []) -> SubSequence? {
        guard let lowerBound = range(of: after, options: options)?.upperBound else { return nil }
        guard let before = before,
            let upperbound = self[lowerBound..<endIndex].range(of: before, options: options)?.lowerBound else {
                return self[lowerBound...]
        }
        return self[lowerBound..<upperbound]
    }
}
