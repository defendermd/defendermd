//
//  ChannelizeVoiceHelper.swift
//  AutomationTest
//
//  Created by Ashish-BigStep on 6/19/19.
//  Copyright © 2019 Channelize. All rights reserved.
//
import Foundation
import PushKit
import ChannelizeAPI
import ChannelizeCall

class CHVoiceVideoHelper: ChannelizeHelperDelegates {
    
    static func processSilentNotification(userInfo: [AnyHashable:Any]) {
        print("Silent Push Notification Data \(userInfo)")
        if userInfo["messageType"] as? String == "primemessenger" {
            CHCall.processCallActionNotification(userInfo: userInfo)
        }
    }
    static func checkAndSetCallModule()->Bool {
        return true
    }
    
    static func getChannelizeCurrentUserId()->String? {
        return Channelize.getCurrentUserId()
    }
}

extension AppDelegate : PKPushRegistryDelegate{
    
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        let deviceToken = pushCredentials.token.reduce("", {$0 + String(format: "%02X", $1) })
        debugPrint("Token recieved - ",deviceToken)
        //VSDK Changes
        device_voip_token = deviceToken
        Channelize.updateVoipToken(token: deviceToken, completion: {(status,errorString) in
            if status {
                print("Voip Token Updated")
            } else {
                print("Failed to Update Voip Token with error \(errorString ?? "")")
            }
        })
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType) {
        print("VOIP Notification Recieved")
        print("PayLoad Dictionary is \(payload.dictionaryPayload)")
        
        if let callId = payload.dictionaryPayload["callId"] as? String{
            if let uid = payload.dictionaryPayload["userId"] as? String{
                if let uuidString = payload.dictionaryPayload["uuid"] as? String{
                    if let uuid = UUID(uuidString: uuidString){
                        let call = CHActiveCall(uuid: uuid, callId: callId, uid: uid, isOutgoing: false)
                        call.displayName = payload.dictionaryPayload["displayName"] as? String
                        call.profileImageUrl = payload.dictionaryPayload["profileImageUrl"] as? String
                        if let callType = payload.dictionaryPayload["type"] as? String{
                            if callType == "video"{
                                call.type = .video
                            }
                        }
                        let backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
                        CHCall.showIncomingCall(call: call, completion: { _ in
                            UIApplication.shared.endBackgroundTask(
                                backgroundTaskIdentifier)
                        })
                    }
                }
            }
        }
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        print("\(#function) token invalidated")
    }
    
}
