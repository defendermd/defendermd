//
//  MemberMatrixViewCell.swift
//  seiosnativeapp
//
//  Created by bigstep_macbook_air on 06/11/18.
//  Copyright © 2018 bigstep. All rights reserved.
//

import UIKit
import Kingfisher
class MemberMatrixViewCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        if logoutUser {
            profileImage.frame = CGRect(x:(Int(self.bounds.width) - Int(self.bounds.width - 80))/2, y: (Int(self.bounds.height) - Int(self.bounds.height - 80))/2, width: Int(self.bounds.width - 80), height: Int(self.bounds.width - 80))
        }
        else {
            profileImage.frame = CGRect(x: 50, y: 10, width: Int(self.bounds.width - 100), height: Int(self.bounds.width - 100))
        }
        profileImage.backgroundColor = .white
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        profileImage.contentMode = .scaleAspectFill
        profileImage.layer.masksToBounds = false
        profileImage.clipsToBounds = true
        addSubview(profileImage)
        
        addSubview(nameLabel)
        let nameFrame = CGRect(x: 5, y: getBottomEdgeY(inputView: profileImage) + 10, width: self.bounds.width - 10, height: 30)
        nameLabel.frame = nameFrame
        
        addSubview(locationLabel)
        let locationFrame = CGRect(x: 5, y: getBottomEdgeY(inputView: nameLabel) + 5, width: nameLabel.frame.width - 10, height: 15)
        locationLabel.frame = locationFrame
        
        addSubview(mutualFriendsLabel)
        let mutualFrame = CGRect(x: 5, y: getBottomEdgeY(inputView: locationLabel), width: nameLabel.frame.width - 10, height: 15)
        mutualFriendsLabel.frame = mutualFrame
        
        addSubview(friendRequest)
        let friendRequestFrame = CGRect(x: 25 , y: getBottomEdgeY(inputView: mutualFriendsLabel) + 10, width: self.bounds.width - 50, height: 30)
        friendRequest.frame = friendRequestFrame
        friendRequest.layer.cornerRadius = friendRequestFrame.size.height/2
        
        addSubview(verifyIcon)
        let verifyIconFrame = CGRect(x: getRightEdgeX(inputView: profileImage) - 25, y: getBottomEdgeY(inputView: profileImage) - 25, width: 20, height: 20)
        let originalImage = UIImage(named: "verify_icon")
        let tintedImage =  originalImage?.withRenderingMode(.alwaysTemplate)
        verifyIcon.setImage(originalImage, for: .normal)
        verifyIcon.tintColor = buttonColor
        verifyIcon.frame = verifyIconFrame
        verifyIcon.isHidden = true
        verifyIcon.layer.cornerRadius = verifyIcon.frame.width / 2
        
        
    }
    
    var profileImage: UIImageView = {
        let profile = UIImageView()
        return profile
    }()
    
    var nameLabel: UILabel = {
        let name = UILabel()
        name.font = UIFont.systemFont(ofSize: 20)
        name.numberOfLines = 1
        name.textAlignment = .center
        return name
    }()
    
    var locationLabel: UILabel = {
        let location = UILabel()
        location.font = UIFont.systemFont(ofSize: 12)
        location.numberOfLines = 1
        location.textColor = UIColor.gray
        location.textAlignment = .center
        return location
    }()
    
    var mutualFriendsLabel: UILabel = {
        let mutualFriends = UILabel()
        mutualFriends.font = UIFont.systemFont(ofSize: 12)
        mutualFriends.numberOfLines = 1
        mutualFriends.textColor = UIColor.gray
        mutualFriends.textAlignment = .center
        return mutualFriends
    }()
    
    var friendRequest: UIButton = {
        let button = UIButton()
        button.setTitleColor(buttonColor, for: .normal)
        button.backgroundColor = UIColor.white
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.layer.borderColor = buttonColor.cgColor
        button.layer.borderWidth = 1
        return button
    }()
    
    var verifyIcon: UIButton = {
        let icon = UIButton()
        icon.isHidden = true
        return icon
    }()
    
   
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



