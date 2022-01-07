//
//  ChannelizeHelperDelegates.swift
//  seiosnativeapp
//
//  Created by Ashish-BigStep on 7/29/19.
//  Copyright © 2019 bigstep. All rights reserved.
//

import Foundation

public protocol ChannelizeHelperDelegates{
    static func configureChannelize()
    static func getMessageCount(completion: @escaping (Int)->())
    static func checkAndSetCallModule()->Bool
    static func updateFcmToken(token:String)
    static func updateVoipToken(token:String)
    static func getChannelizeCurrentUserId()->String?
    static func setUserOnline(completion: @escaping (Bool?,Error?)->())
    static func setUserOffline(completion: @escaping (Bool?,Error?)->())
    static func performChannelizeLogout()
    static func performChannelizeLaunch(navigationController:UINavigationController,data:[AnyHashable:Any]?)
    static func updateChannelizeToken(token:String)
    static func updateUserObject(userObject:Any,token:String)
    static func getUserObjectWithId(userId:String,completion: @escaping (Any?,String?)->())
    static func connectChannelize()
    static func configureVoiceVideo()
    static func initializeRealmObjects()
    static func perfromRealmObjectsDeletion()
    static func performChannelizeLogin(email:String,password:String,completion: @escaping (Any?,String?) -> ())
    static func processSilentNotification(userInfo: [AnyHashable:Any])
}

public extension ChannelizeHelperDelegates {
    static func configureChannelize() { }
    static func getMessageCount(completion: @escaping (Int)->()) { }
    static func updateFcmToken(token:String) { }
    static func updateVoipToken(token:String) { }
    static func setUserOnline(completion: @escaping (Bool?,Error?)->()) { }
    static func setUserOffline(completion: @escaping (Bool?,Error?)->()) { }
    static func performChannelizeLogout() { }
    static func performChannelizeLaunch(navigationController:UINavigationController,data:[AnyHashable:Any]?) { }
    static func updateChannelizeToken(token:String) { }
    static func updateUserObject(userObject:Any,token:String) { }
    static func getUserObjectWithId(userId:String,completion: @escaping (Any?,Error?)->()) { }
    static func connectChannelize() { }
    static func configureVoiceVideo() { }
    static func initializeRealmObjects() { }
    static func perfromRealmObjectsDeletion() { }
    static func processSilentNotification(userInfo: [AnyHashable:Any]) { }
    static func performChannelizeLogin(email:String,password:String,completion: @escaping (Any?,String?) -> ()) { }
    static func getUserObjectWithId(userId:String,completion: @escaping (Any?,String?)->()) { }
}
