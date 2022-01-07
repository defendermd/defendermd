//
//  ChannelizeHelper.swift
//  AutomationTest
//
//  Created by Ashish-BigStep on 6/19/19.
//  Copyright © 2019 Channelize. All rights reserved.
//

import Foundation
import ChannelizeAPI
import ChannelizeUI
import Firebase

open class ChannelizeHelper: ChannelizeHelperDelegates {
    public static func updateUserObject(userObject: Any, token: String) {
        if let user = userObject as? CHUser {
            Channelize.updateUser(user: user, token: token)
        }
    }
    
    public static var instance : ChannelizeHelper = {
        let instance = ChannelizeHelper()
        return instance
    }()
    
    public static func configureChannelize(){
        Channelize.configure()
        Channelize.configureAws()
        CHUIConstants.appDefaultColor = buttonColor
        CHUIConstants.outgoingTextMessageBackgroundColor = buttonColor
        isChannelizeAvailable = true
        CHCustomOptions.enableStickerAndGifMessages = true
    }
    
    public static func performChannelizeLoginWithUserId(userId: String, accessToken: String, completion: @escaping (CHUser?,String?) -> ()){
        Channelize.login(userId: userId, accessToken: accessToken, completion: completion)
    }
    
    public static func performChannelizeLogin(email:String,password:String,completion: @escaping (Any?,String?) -> ()){
        Channelize.login(email: email, password: password, completion: completion)
    }
    
    public static func performChannelizeLaunch(navigationController: UINavigationController, data: [AnyHashable:Any]?){
        ChUI.launchChannelize(navigationController: navigationController, data: data)
    }
    
    public static func perfromRealmObjectsDeletion(){
//        let realm = try! Realm()
//        do {
//            try realm.write {
//                realm.deleteAll()
//            }
//        } catch {
//            print("Error \(error.localizedDescription)")
//        }
    }
    
    public static func performChannelizeLogout(){
        Channelize.logout(completion: {(status,errorString) in
            if status {
                InstanceID.instanceID().deleteID { (error) in
                    if let er = error {
                        print(er.localizedDescription)
                    } else {
                        print("instanceID().deleteID  success ---------------➤")
                    }
                }
            } else {
                print("Failed to Logout From Channelize")
            }
            
        })
    }
    
    public static func setUserOffline(completion: @escaping (Bool?,Error?)->()){
        Channelize.setUserOffline()
    }
    
    public static func setUserOnline(completion: @escaping (Bool?,Error?)->()){
        Channelize.setUserOnline()
    }
    
    public static func getChannelizeCurrentUserId()->String?{
        return Channelize.getCurrentUserId() == "" ? nil : Channelize.getCurrentUserId()
    }
    
    public static func updateVoipToken(token:String){
        Channelize.updateVoipToken(token: token, completion: {(status,errorString) in
            
        })
    }
    
    public static func updateFcmToken(token:String){
        Channelize.updateFcmToken(token: token, completion: {(status,errorString) in
            
        })
    }
    
    private func returnFrameWorkClass(componentType:String)->AnyClass?{
        if componentType == "UI"{
            let bundleUrl = Bundle.url(forResource: "Channelize", withExtension: "framework", subdirectory: "Frameworks", in: Bundle.main.bundleURL)
            guard bundleUrl != nil else { return nil }
            let bundle = Bundle(url: bundleUrl!)
            bundle?.load()
            let uiClass : AnyClass? = NSClassFromString("Channelize.CHMain")
            return uiClass
        } else if componentType == "API"{
            let bundleUrl = Bundle.url(forResource: "Channelize_API", withExtension: "framework", subdirectory: "Frameworks", in: Bundle.main.bundleURL)
            guard bundleUrl != nil else { return nil }
            let bundle = Bundle(url: bundleUrl!)
            bundle?.load()
            let apiClass : AnyClass? = NSClassFromString("Channelize_API.Channelize")
            return apiClass
        } else if componentType == "CALL"{
            let bundleUrl = Bundle.url(forResource: "ChannelizeCall", withExtension: "framework", subdirectory: "Frameworks", in: Bundle.main.bundleURL)
            guard bundleUrl != nil else { return nil }
            let bundle = Bundle(url: bundleUrl!)
            bundle?.load()
            let callClass : AnyClass? = NSClassFromString("ChannelizeCall.CHCall")
            return callClass
        }
        return nil
    }
    
    public static func getMessageCount(completion: @escaping (Int)->()){
        ChannelizeAPIService.getUnreadMessageCount(completion: {(count,errorString) in
            completion(count)
        })
    }
    
    public static func checkAndSetCallModule() -> Bool {
        if instance.returnFrameWorkClass(componentType: "CALL") != nil{
            CHConstants.isChannelizeCallAvailable = true
            return true
        } else{
            CHConstants.isChannelizeCallAvailable = false
            return false
        }
    }
    
    public static func getUserObjectWithId(userId: String, completion: @escaping (Any?, String?) -> ()) {
        ChannelizeAPIService.getUserInfo(userId: userId, completion: {(user,errorString) in
            completion(user,errorString)
        })
    }
    
    
    public static func getUserObjectWithId(userId: String, completion: @escaping (CHUser?,String?) -> ()){
        ChannelizeAPIService.getUserInfo(userId: userId, completion: completion)
    }
    
    public static func updateChannelizeToken(token: String){
        Channelize.updateUserToken(token: token)
    }
    
    public static func configureVoiceVideo(){
        if let returnedClass = instance.returnFrameWorkClass(componentType: "CALL"){
            if let callClass = returnedClass as? CallSDKDelegates.Type{
                callClass.configureVoiceVideo()
            }
        }
    }
    
    public static func connectChannelize(){
        Channelize.connect()
    }
    
    public static func initializeRealmObjects(){
        //AllMembers.initializeRealm()
        //AllConversations.initializeRealm()
    }
}
