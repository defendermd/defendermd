//
//  ReachabilityManager.swift
//  NetworkStatusMonitor
//
//  Created by Sauvik Dolui on 18/10/16.
//  Copyright © 2016 Innofied Solution Pvt. Ltd. All rights reserved.
//

import Foundation

class ReachabilityManager: NSObject {
    
    static let shared = ReachabilityManager()  
    
    // 3. Boolean to track network reachability
    var isNetworkAvailable : Bool {
        return reachabilityStatus != .none
    }
    
    // 4. Tracks current NetworkStatus (notReachable, reachableViaWiFi, reachableViaWWAN)
    var reachabilityStatus: Reachability.Connection = .none
    
    // 5. Reachibility instance for Network status monitoring
    let reachability = Reachability()!
    
    
    
    
    /// Called whenever there is a change in NetworkReachibility Status
    ///
    /// — parameter notification: Notification with the Reachability instance
    @objc func reachabilityChanged(notification: Notification) {
        let reachability = notification.object as! Reachability
        switch reachability.connection {
        case .none:
            pauseActiveAPI()
            debugPrint("Network became unreachable")
        case .wifi:
            resumeActiveAPI()
            debugPrint("Network reachable through WiFi")
        case .cellular:
            resumeActiveAPI()
            debugPrint("Network reachable through Cellular Data")
        }
    }
    
    func pauseActiveAPI()
    {
        for (urlSession, upload) in uploadService.activeUploads
        {
            upload.task?.suspend()
            upload.isDownloading = false
            uploadService.activeUploads[urlSession] = upload
        }
    }
    func resumeActiveAPI()
    {
        for (urlSession, upload) in uploadService.activeUploads
        {
            upload.task!.resume()
            upload.isDownloading = true
            uploadService.activeUploads[urlSession] = upload
        }
    }
    /// Starts monitoring the network availability status
    func startMonitoring() {
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.reachabilityChanged),
                                               name: Notification.Name.reachabilityChanged,
                                               object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            debugPrint("Could not start reachability notifier")
        }
    }
    
    /// Stops monitoring the network availability status
    func stopMonitoring(){
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: Notification.Name.reachabilityChanged,
                                                  object: reachability)
    }
}
