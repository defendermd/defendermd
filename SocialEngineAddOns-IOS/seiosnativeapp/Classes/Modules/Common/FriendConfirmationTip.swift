//
//  FriendConfirmationTip.swift
//  seiosnativeapp
//
//  Created by bigstep_macbook_air on 7/29/19.
//  Copyright © 2019 bigstep. All rights reserved.
//

import Foundation
import UIKit
class FriendConfirmationTip: UIView {
    var userImage : CustomButton = {
        let image = CustomButton()
        return image
    }()
    var messageButton : CustomButton = {
        let button = CustomButton()
        let originalImage = UIImage(named: "thirdController")
        let tintedImage =  originalImage?.withRenderingMode(.alwaysTemplate)
        button.setImage(tintedImage, for: .normal)
        button.tintColor = .white
        button.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZEMedium)
        button.backgroundColor = buttonColor
        return button
    }()
    var confirmationLabel : UILabel = {
        let label = UILabel()
        label.textColor = textColorDark
        label.font = UIFont(name: fontBold, size: FONTSIZEMedium)
        return label
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
        self.layer.masksToBounds = false
        self.layer.cornerRadius = 4.0
        self.backgroundColor = .white
        userImage.frame = CGRect(x: 5, y: 5, width: frame.size.height - 10, height: frame.size.height - 10)
        userImage.layer.cornerRadius = (frame.size.height - 10)/2
        userImage.layer.masksToBounds = true
        userImage.contentMode =  UIView.ContentMode.scaleAspectFill
        userImage.addTarget(self, action: #selector(FriendConfirmationTip.viewProfile(sender:)), for: .touchUpInside)
        addSubview(userImage)
        
        messageButton.frame = CGRect(x: frame.size.width - (frame.size.height - 25) , y: 0, width: frame.size.height - 30, height: frame.size.height - 30)
        messageButton.frame.origin.y = (frame.size.height - messageButton.frame.size.height)/2
        messageButton.layer.cornerRadius = (frame.size.height - 30)/2
        messageButton.addTarget(self, action: #selector(FriendConfirmationTip.sendMessage(sender:)), for: .touchUpInside)
        addSubview(messageButton)
        
        confirmationLabel.frame = CGRect(x: getRightEdgeX(inputView: userImage) + 7, y: 0, width: frame.size.width - (userImage.frame.size.width + messageButton.frame.size.width + 20), height: 40)
        confirmationLabel.frame.origin.y = (frame.size.height - confirmationLabel.frame.size.height)/2
        confirmationLabel.text = "You are now friend with"
        confirmationLabel.numberOfLines = 0
        addSubview(confirmationLabel)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        
        leftSwipe.direction = .left
        rightSwipe.direction = .right
        
        self.addGestureRecognizer(leftSwipe)
        self.addGestureRecognizer(rightSwipe)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setView(hidden: Bool) {
        
        UIView.animate(withDuration: 1,delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.alpha = hidden == true ? 0 : 1
            self.isHidden = self.alpha == 1 ? false : true
        }) { (finished) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                UIView.animate(withDuration: 1,delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                    self.alpha = 0
                }) { (finished) in
                    self.removeFromSuperview()
                }
            }
        }
    }
    @objc func sendMessage(sender: CustomButton) {
        if isChannelizeAvailable{
            let data : [AnyHashable:Any] = [AnyHashable("userId"):sender.id]
            if let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController{
                let moduleName = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
                if let channelizeClass = NSClassFromString(moduleName + "." + "ChannelizeHelper") as? ChannelizeHelperDelegates.Type{
                    channelizeClass.performChannelizeLaunch(navigationController: navigationController, data: data)
                }
            }
        } else{
            fromFriendlist = true
            let presentedVC = MessageCreateController()
            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            presentedVC.userID = sender.id
            presentedVC.fromProfile = true
            presentedVC.profileName =  sender.name
            keywindow?.topViewController()!.navigationController?.pushViewController(presentedVC.self, animated: true)
        }
    }
    
    
    
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        if (sender.direction == .left) {
            UIView.animate(withDuration: 0.3, animations: {
                self.frame.origin.x -= self.frame.size.width - 50
            }) { (_) in
                self.isHidden = true
                self.frame.origin.x = 10
                self.alpha = 0
                self.removeFromSuperview()
            }
        }
        if (sender.direction == .right) {
            UIView.animate(withDuration: 0.3, animations: {
                self.frame.origin.x += self.frame.size.width + 50
            }) { (_) in
                self.isHidden = true
                self.frame.origin.x = 10
                self.alpha = 0
                self.removeFromSuperview()
            }
        }
    }
    
    @objc func viewProfile(sender: CustomButton) {
        let presentedVC = ContentActivityFeedViewController()
        print(sender.id!)
        presentedVC.subjectType = "user"
        presentedVC.subjectId = sender.id!
        searchDic.removeAll(keepingCapacity: false)
        presentedVC.fromDashboard =  false
        keywindow?.topViewController()!.navigationController?.pushViewController(presentedVC.self, animated: true)
    }
}

class CustomButton:UIButton {
    var image: UIImage?
    var name : String?
    var id : String?
    var viewController: UIViewController?
    
    convenience init(image : UIImage, name: String, id: String, viewController : UIViewController) {
        self.init(frame:CGRect.zero)
        self.image = image
        self.name = name
        self.id = id
        self.viewController = viewController
    }}
extension UIWindow {
    func topViewController() -> UIViewController? {
        var top = self.rootViewController
        while true {
            if let presented = top?.presentedViewController {
                top = presented
            } else if let nav = top as? UINavigationController {
                top = nav.visibleViewController
            } else if let tab = top as? UITabBarController {
                top = tab.selectedViewController
            } else {
                break
            }
        }
        return top
    }
}
