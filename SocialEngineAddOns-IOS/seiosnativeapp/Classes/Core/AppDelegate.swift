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
//  AppDelegate.swift

import UIKit
import CoreData
import UserNotifications
import AVFoundation
import MediaPlayer
import Kingfisher
import Firebase
import FirebaseMessaging
import Fabric
import PushKit

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

let reachability = Reachability()!
var auth_user:Bool!
var oauth_secret:String!
var displayName:String!
var coverImage:String!
var coverImageBackgorund:String!
var enabledModules :NSArray! = []
var isChannelEnable : Bool = true
var isPlaylistEnable : Bool = true
var context:NSManagedObjectContext!
var logoutUser:Bool!
var refreshMenu:Bool = false
var currentUserId :Int = 0
var oauth_token:String! = ""
var device_token_id : String! = ""
var device_uuid : String! = ""
var device_voip_token : String = ""
var dashboardRefreshInteger : Int = 0
var browseAsGuest = false
var ios_version : String!
var isOTPEnableplugin: Int = 0
var firstCompletionTime = true
var arrRecentSearchOptions = [String]()
//let kMapsAPIKey = "AIzaSyB7oOFvRUnqAmYj-Pe9B8KUNFZ7ffmIkX4"
let kMapsAPIKey = "AIzaSyC3aV5YJDASbdHaUQppnlekizpTWn0ywsI"

// UniversalLink
var UniversalLinkClickUrl: String = ""
var universalLinkdic = NSDictionary()
var notificationData : [AnyHashable:Any]?
var isChannelizeAvailable = false
var signUplayoutType : Bool = false


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    let pushRegistry = PKPushRegistry(queue: DispatchQueue.main)
    // Universal Link Dictionary
    
    func universalLinkKeys()
    {
        if reachability.connection != .none {
            // Reset Objects
            // Send Server Request to Browse Notifications Entries
            post([String:String](), url: "deep-linking", method: "POST") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    if msg{
                        if let body = succeeded["body"] as? NSDictionary
                        {
                            universalLinkdic = body
                        }
                    }
                    else{
                        print("Universal Link Error")
                    }
                })
            }
        }else{
            // No Internet Connection Message
            print("Universal Link Network Error")
        }
    }
    
    func checkLiveTimeSetting(){
        let url1 = "get-settings"
        
        let dic = [String : String]()
        
        let method1 = "GET"
        
        post(dic , url: "\(url1)", method: method1) { (succeeded, msg) -> () in
            DispatchQueue.main.async(execute: {
                
                if msg{
                    
                    if let body = succeeded["body"] as? NSDictionary{
                       
                        if let setting = body["sitequicksignup"] as? NSDictionary{
                            signUplayoutType = (setting["isQuickSignUp"] as! Bool)
                        }
                    }
                    
                    
                }
                    
                else{
                    // Handle Server Side Error
                    if succeeded["message"] != nil{
                         print("error =====")
                       // self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                    }
                }
            })
        }
    }
    
    func application(_ application: UIApplication, continue userActivity:
        NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            let url = userActivity.webpageURL!
            UniversalLinkClickUrl = url.absoluteString
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UniversalLink"), object: nil)
        }
        if baseController != nil{
            baseController.selectedIndex = 0
        }
    
        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        checkLiveTimeSetting()
        if let info = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? [AnyHashable : Any] {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                if info[AnyHashable("gcm.notification.type")] as? String != nil || info["type"] != nil{
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "appNotification"), object: nil, userInfo: info)
                }
                else
                {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "massNotification"), object: nil, userInfo: info)
                }
            }
        }
        
        universalLinkKeys()
        // UniversalLink
        if  let activityDictionary = launchOptions?[UIApplication.LaunchOptionsKey.userActivityDictionary] as? [AnyHashable: Any]
        {
            if let activity = activityDictionary["UIApplicationLaunchOptionsUserActivityKey"] as? NSUserActivity
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    if activity.activityType == NSUserActivityTypeBrowsingWeb {
                        let url = activity.webpageURL!
                        UniversalLinkClickUrl = url.absoluteString
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UniversalLink"), object: nil)
                    }
                }
            }
        }
        
        UserDefaults.standard.removeObject(forKey: "arrGetStoryCreate")
        UserDefaults.standard.removeObject(forKey: "arrGetFeedPostMenus")
        
       
        
        if apiServerKey.isEmpty {
            fatalError("Please provide an API Key using kMapsAPIKey")
        }
        GMSServices.provideAPIKey(apiServerKey)

        if #available(iOS 10.0, *)
        {
            let center = UNUserNotificationCenter.current()
            center.delegate = self
            let types: UNAuthorizationOptions = [UNAuthorizationOptions.badge, UNAuthorizationOptions.alert, UNAuthorizationOptions.sound]
            center.requestAuthorization(options: types, completionHandler: { (granted, error) in
                //print(granted)
                if (granted){
                    DispatchQueue.main.async(execute: {
                        UIApplication.shared.registerForRemoteNotifications()
                    })
                }
            })

        }
        else
        {
            let types: UIUserNotificationType = [UIUserNotificationType.badge, UIUserNotificationType.alert, UIUserNotificationType.sound]
            let settings: UIUserNotificationSettings = UIUserNotificationSettings( types: types, categories: nil )
            application.registerUserNotificationSettings( settings )
            application.registerForRemoteNotifications()
            // Fallback on earlier versions
        }

        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        {
            ios_version = version
        }
        else
        {
            ios_version = "1.5"
        }
        
        UIDevice.current.isBatteryMonitoringEnabled = true
        print("battery")
        print(UIDevice.current.batteryLevel)
        let userDefaults = UserDefaults(suiteName: "\(shareGroupname)")
        userDefaults!.set(ios_version, forKey: "ios_version")
        userDefaults!.set(baseUrl, forKey: "baseUrl")
        userDefaults!.set(oauth_consumer_secret, forKey: "oauth_consumer_secret")
        userDefaults!.set(oauth_consumer_key, forKey: "oauth_consumer_key")
        userDefaults!.synchronize()
        // Override point for customization after application launch.
        _ = UserDefaults.standard.object(forKey: "menuRefreshLimit") as? String
        // make the status bar white
        application.statusBarStyle = isWhiteBackground == 1 ? .default : .lightContent
        menuRefreshConter = 0

        let sharedApplication = UIApplication.shared
        sharedApplication.delegate?.window??.tintColor = buttonColor


        UINavigationBar.appearance().barStyle = UIBarStyle.default

        UINavigationBar.appearance().barTintColor = buttonColor
        UINavigationBar.appearance().tintColor = textColorPrime
        UINavigationBar.appearance().isTranslucent = true
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : textColorPrime, NSAttributedString.Key.font: UIFont(name: fontName, size: FONTSIZELarge + 3.0)!]

        FirebaseApp.configure()
        Fabric.sharedSDK().debug = true
        Messaging.messaging().delegate = self
        
        //Bundle.main.load()
        let moduleName = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
        if let channelizeClass = NSClassFromString(moduleName + "." + "ChannelizeHelper") as? ChannelizeHelperDelegates.Type{
            channelizeClass.configureChannelize()
            if channelizeClass.checkAndSetCallModule(){
                channelizeClass.configureVoiceVideo()
                pushRegistry.delegate = self
                pushRegistry.desiredPushTypes = [.voIP]
            } else {
                
            }
        }
        
        if #available(iOS 11.0, *) {
            UINavigationBar.appearance(whenContainedInInstancesOf: [UIDocumentBrowserViewController.self]).tintColor = nil
        }
        
        // Get Data From Core Data
        getDataFromCoredata()
        StoreReviewHelper.incrementAppOpenedCount()
        
        #if compiler(>=5.1)
        if #available(iOS 13.0, *) {
            // Always adopt a light interface style.
            window?.overrideUserInterfaceStyle = .light
        }
        #endif
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.tokenRefreshNotification), name: NSNotification.Name.InstanceIDTokenRefresh, object: nil)
        
        if isChannelizeAvailable{
            if oauth_token != nil || oauth_token == ""{
                if UserDefaults.standard.value(forKey: "pmAccessToken") == nil || UserDefaults.standard.value(forKey: "pmAccessToken") as? String == ""{
                    let userDefaults = UserDefaults(suiteName: "\(shareGroupname)")
                    userDefaults?.removeObject(forKey: "oauth_token")
                    auth_user = false
                    oauth_token = nil
                }
            }
        }
        
        
        if (logoutUser == true)
        {

            return ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        }
        else
        {

            return true
        }
    }
    func applicationWillResignActive(_ application: UIApplication) {
        AppEvents.activateApp()
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        application.applicationIconBadgeNumber = totalNotificationCount
        let moduleName = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
        if let channelizeClass = NSClassFromString(moduleName + "." + "ChannelizeHelper") as? ChannelizeHelperDelegates.Type{
            channelizeClass.setUserOffline(completion: {(status,error) in
                if let offlineStatus = status{
                    if offlineStatus{
                        print("Channelize User set as Offline ")
                    }
                }
            })
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        //        reachability.stopNotifier()
        //        NSNotificationCenter.defaultCenter().removeObserver(self, name: ReachabilityChangedNotification, object: nil)
        let moduleName = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
        if let channelizeClass = NSClassFromString(moduleName + "." + "ChannelizeHelper") as? ChannelizeHelperDelegates.Type{
            channelizeClass.setUserOffline(completion: {(status,error) in
                if let offlineStatus = status{
                    if offlineStatus{
                        print("Channelize User set as Offline ")
                    }
                }
            })
        }
    }
    
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        
        //print("didReceiveMemoryWarning")
        let cache = KingfisherManager.shared.cache
        // Clear memory cache right away.
        cache.clearMemoryCache()
        // Clear disk cache. This is an async operation.
        cache.clearDiskCache()
        // Clean expired or size exceeded disk cache. This is an async operation.
        cache.cleanExpiredDiskCache()
        
    }
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        ReachabilityManager.shared.stopMonitoring()
        
        let moduleName = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
        if let channelizeClass = NSClassFromString(moduleName + "." + "ChannelizeHelper") as? ChannelizeHelperDelegates.Type{
            channelizeClass.setUserOnline(completion: {(status,error) in
                if let offlineStatus = status{
                    if offlineStatus{
                        print("Channelize User set as Online ")
                    }
                }
            })
            channelizeClass.getMessageCount(completion: {(count) in
                messageCount = count
                if messageIndex > 0{
                    baseController.tabBar.items?[messageIndex].badgeValue = messageCount > 0 ? "\(messageCount)" : nil
                }
            })
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        //        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reachabilityChanged:", name: ReachabilityChangedNotification, object: reachability)
        //        reachability.startNotifier()
        //*************

        firstCompletionTime = true
        application.applicationIconBadgeNumber = totalNotificationCount
        arrGlobalFacebookAds.removeAll()
        ReachabilityManager.shared.startMonitoring()
        
        let moduleName = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
        if let channelizeClass = NSClassFromString(moduleName + "." + "ChannelizeHelper") as? ChannelizeHelperDelegates.Type{
            channelizeClass.setUserOnline(completion: {(status,error) in
                if let offlineStatus = status{
                    if offlineStatus{
                        print("Channelize User set as Online ")
                    }
                }
            })
        }
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        let defaults = UserDefaults.standard
        if defaults.value(forKey: "imagePicked") != nil {
            defaults.removeObject(forKey: "imagePicked")
        }
        self.saveContext()
    }

    func getDataFromCoredata()
    {
        context = managedObjectContext!
        
        let request: NSFetchRequest<UserInfo>
        
        if #available(iOS 10.0, *){
            request = UserInfo.fetchRequest() as! NSFetchRequest<UserInfo>
        }else{
            request = NSFetchRequest(entityName: "UserInfo")
        }
        
        request.returnsObjectsAsFaults = false
        
        let results = try? context.fetch(request)
        if(results?.count>0)
        {
            for result: AnyObject in results!
            {
                if let token = result.value(forKey: "oauth_token") as? String
                {
                    oauth_token = token
                    
                    
                    let userDefaults = UserDefaults(suiteName: "\(shareGroupname)")
                    userDefaults!.set(oauth_token, forKey: "oauth_token")
                    
                    if let auth_secret = result.value(forKey: "oauth_secret") as? String
                    {
                        oauth_secret = auth_secret
                        let userDefaults = UserDefaults(suiteName: "\(shareGroupname)")
                        userDefaults!.set(oauth_secret, forKey: "oauth_secret")
                    }
                    
                    if let displayCoverImage = result.value(forKey: "cover_image") as? String{
                        coverImage = displayCoverImage
                    }
                    if let displayUserName = result.value(forKey: "display_name") as? String{
                        displayName = displayUserName
                    }
                    if let tempCurrentUserId = result.value(forKey: "user_id") as? Int{
                        currentUserId = tempCurrentUserId
                    }
            
                    auth_user = true
                    logoutUser = false
                    refreshMenu = true

                }
            }
            do
            {
                try context.save()
            }
            catch _ {
            }
        }
        else
        {
            auth_user = false
            logoutUser = true
            refreshMenu = true
        }
    
    }
    // fetching the device token
    func application( _ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data ) {
        
        
        var deviceTokenString: String
        if #available(iOS 10.0, *){
            deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
            print(deviceTokenString)
        }else{
            let characterSet: CharacterSet = CharacterSet( charactersIn: "<>" )
            
            deviceTokenString = ( deviceToken.description as NSString ).trimmingCharacters( in: characterSet ).replacingOccurrences( of: " ", with: "" ) as String
        }
//        device_token_id = deviceTokenString
        device_uuid = UIDevice.current.identifierForVendor?.uuidString
        
//        do {
//            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.duckOthers)
//        } catch _ {
//        }
//        do {
//            try AVAudioSession.sharedInstance().setActive(true)
//        } catch _ {
        
        Messaging.messaging().apnsToken = deviceToken

    }
    
    func application( _ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error ) {
        
        //print( error.localizedDescription )
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print("Notifications received - ",userInfo)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return ApplicationDelegate.shared.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    
    // MARK: - Reachability Changed
    
//    @objc func reachabilityChanged(_ note: Foundation.Notification) {
//        let reachability = note.object as! Reachability
//
//        if Reachabable.isConnectedToNetwork() {
//            removeAlert()
//        } else {
//        }
//    }
    

    // MARK: - Application Orientation stack
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        
        if (self.window?.rootViewController?.presentedViewController as? LoginViewController) != nil {
            return UIInterfaceOrientationMask.portrait
        }else{
            return UIInterfaceOrientationMask.allButUpsideDown
        }
        
    }
    
    
    //    func application(application: UIApplication, supportedInterfaceOrientationsForWindow window: UIWindow) -> Int {
    //
    //        if self.window?.rootViewController?.presentedViewController? is PhotoViewController {
    //            if isPresented {
    //                return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
    //            } else {
    //                return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    //            }
    //        } else {
    //             return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    //        }
    //
    //
    //
    //    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.seao.seiosnativeapp" in the application's documents Application Support directory.

        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1] as URL
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "seiosnativeapp", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
        }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("seiosnativeapp.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: [NSMigratePersistentStoresAutomaticallyOption : true , NSInferMappingModelAutomaticallyOption : true])
        } catch var error1 as NSError {
            error = error1
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
        } catch {
            fatalError()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch let error1 as NSError {
                    error = error1
                    NSLog("Unresolved error \(String(describing: error)), \(error!.userInfo)")
                }
            }
        }
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        //Handle the notification
        completionHandler([.alert,.badge,.sound])
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if userInfo["isMessenger"] != nil{
            openPrimeMessenger(contentInfo: userInfo)
        } else{
            if baseController != nil{
                baseController.selectedIndex = 0
            }
            
            if userInfo["type"] != nil{
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "appNotification"), object: nil, userInfo: userInfo)
            }else{
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "massNotification"), object: nil, userInfo: userInfo)
            }
        }
        
        //Handle the notification
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let moduleName = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
        if let channelizeClass = NSClassFromString(moduleName + "." + "CHVoiceVideoHelper") as? ChannelizeHelperDelegates.Type {
            channelizeClass.processSilentNotification(userInfo: userInfo)
        }
        
        if application.applicationState != UIApplication.State.background{
            if userInfo["type"] as? String != "call" && userInfo["type"] as? String != "voice" && userInfo["type"] as? String != "video" {
                if baseController != nil{
                    baseController.selectedIndex = 0
                }
                if userInfo["type"] != nil{
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "appNotification"), object: nil, userInfo: userInfo)
                }
                else
                {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "massNotification"), object: nil, userInfo: userInfo)
                }
            }
        }
    }
    
    
    func openPrimeMessenger(contentInfo:[AnyHashable:Any]){
        if let recipient = contentInfo["recipient"]{
            if let jsonData = (recipient as! String).data(using: .utf8){
                if let data = try? JSONSerialization.jsonObject(with: jsonData, options: []) as! [String:Any]{
                    
                    let moduleName = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
                    if let channelizeClass = NSClassFromString(moduleName + "." + "ChannelizeHelper") as? ChannelizeHelperDelegates.Type{
                        if data["recipientId"] as! String == channelizeClass.getChannelizeCurrentUserId(){
                            if let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController{
                                if(baseController == nil){
                                    notificationData = contentInfo
                                } else{
                                    channelizeClass.performChannelizeLaunch(navigationController: navigationController, data: contentInfo)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    @objc func tokenRefreshNotification(_ notification: Notification) {
        if let fcmToken = InstanceID.instanceID().token() {
            print("InstanceID token: \(fcmToken)")
            
            if reachability.connection != .none {
                // Reset Objects
                // Send Server Request to Browse Notifications Entries
                post(["device_token":"\(fcmToken)","device_uuid":"\(String(describing: device_uuid))"], url: "user/update-fcm-token", method: "POST") { (succeeded, msg) -> () in
                    DispatchQueue.main.async(execute: {
                        if msg{
                            print("Refreshed Token")
                        }
                        else{
                            print("Error")
                        }
                    })
                }
            }else{
                // No Internet Connection Message
                print("Network Error")
            }
        }
    }
}

extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        device_token_id = fcmToken
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        let moduleName = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
        if let channelizeClass = NSClassFromString(moduleName + "." + "ChannelizeHelper") as? ChannelizeHelperDelegates.Type{
            channelizeClass.updateFcmToken(token:fcmToken)
        }
        
        
    }
    // [END refresh_token]
    
    // [START ios_10_data_message]
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("Refreshed Token: \(fcmToken)")
        // Check Internet Connectivity
        if reachability.connection != .none {
            // Reset Objects
            // Send Server Request to Browse Notifications Entries
            post(["device_token":"\(fcmToken)","device_uuid":"\(String(describing: device_uuid))"], url: "user/update-fcm-token", method: "POST") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    if msg{
                        print("Refreshed Token")
                    }
                    else{
                        print("Error")
                    }
                })
            }
        }else{
            // No Internet Connection Message
            print("Network Error")
        }
    }
    // [END ios_10_data_message]
}


