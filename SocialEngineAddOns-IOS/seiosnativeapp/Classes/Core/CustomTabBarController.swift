//
//  CustomTabBarController.swift
//  seiosnativeapp
//
//  Created by bigstep on 07/06/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController {
    
    var shouldRotate: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        UITabBar.appearance().backgroundColor = UIColor.white
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font:UIFont(name: fontName, size: FONTSIZELarge - 5.0)!], for: UIControl.State())
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor : buttonColor], for: UIControl.State.selected)
        UITabBar.appearance().clipsToBounds = true
        UITabBar.appearance().tintColor = buttonColor
        tabBar.layer.borderWidth = 0.3
        tabBar.layer.borderColor = UIColor(red:0.0/255.0, green:0.0/255.0, blue:0.0/255.0, alpha:0.2).cgColor
        tabBar.clipsToBounds = true
    }
    override var shouldAutorotate : Bool { //allow the subviews accessing the tabBarController to set whether they should rotate or not
        return self.shouldRotate
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
//        if self.selectedIndex == 4 {
//            let yourView = self.viewControllers![self.selectedIndex] as! UINavigationController
//            yourView .popToRootViewController(animated: false)
//        }
        guard let items = tabBar.items else { return }
        print("the selected index is : \(String(describing: items.index(of: item)))")
        
        if let index = items.index(of: item) {
            if index == messageIndex {
                if let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController{
                    let moduleName = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
                    if let channelizeClass = NSClassFromString(moduleName + "." + "ChannelizeHelper") as? ChannelizeHelperDelegates.Type{
                        if channelizeClass.getChannelizeCurrentUserId() != nil{
                            channelizeClass.performChannelizeLaunch(navigationController: navigationController, data: nil)
                        } else{
                            if let pmAccessToken = UserDefaults.standard.value(forKey: "pmAccessToken") as? String{
                                channelizeClass.updateChannelizeToken(token: pmAccessToken)
                                let userId = currentUserId
                                let stringId = String(describing: userId)
                                channelizeClass.getUserObjectWithId(userId: stringId, completion: {(user,error) in
                                    if let error = error{
                                        print("Fail to get User Object with error \(error ?? "")")
                                    } else if let user = user{
                                        channelizeClass.initializeRealmObjects()
                                        channelizeClass.updateUserObject(userObject: user, token: pmAccessToken)
                                        channelizeClass.performChannelizeLaunch(navigationController: navigationController, data: nil)
                                    }
                                    
                                })
                            }
                        }
                    }
                }
            }
        }
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return [.portrait]
    }
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        if #available(iOS 11.0, *) {
            tabBar.invalidateIntrinsicContentSize()

        }else{
            var tabFrame            = tabBar.frame
            tabFrame.size.height    = 45
            tabFrame.origin.y       = view.frame.size.height - 45
            tabBar.frame            = tabFrame
        }
        // For changing TabBar icon color
        if let items = tabBar.items {
            for item in items {
                item.title = nil
                item.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0);
                if let image = item.image {
                    item.image = image.imageWithColor(tintColor: UIColor(red: 96/255 , green: 96/255 , blue: 96/255, alpha: 1.0)).withRenderingMode(.alwaysOriginal)
                }
            }
        }
    }
}

