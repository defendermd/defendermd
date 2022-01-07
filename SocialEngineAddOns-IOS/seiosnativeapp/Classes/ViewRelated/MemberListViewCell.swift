//
//  MemberListViewCell.swift
//  seiosnativeapp
//
//  Created by bigstep_macbook_air on 16/11/18.
//  Copyright © 2018 bigstep. All rights reserved.
//

import UIKit
class MemberListViewCell: UITableViewCell{
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
       // setupViews()
      
    }
    
    var profileImage: UIImageView = {
        var image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.layer.masksToBounds = false
        image.clipsToBounds = true
        return image
    }()
    
    var containerView: UIView = {
        var view = UIView()
        return view
    }()
    
  var cellView = UIView()
    
    var cellSpacing: UIView = {
        var space = UIView()
        return space
    }()
    
    var userName: UILabel = {
        var name = UILabel()
        name.font = UIFont.systemFont(ofSize: 18)
        return name
    }()
    
    var locationLabel: UILabel = {
        var location = UILabel()
        location.font = UIFont.systemFont(ofSize: 12)
        location.textColor = UIColor.gray
        return location
    }()
    var friendName: UILabel = {
        var name = UILabel()
        name.font = UIFont.systemFont(ofSize: 18)
        return name
    }()
    
    var mutualFriendsLabel: UILabel = {
        var friends = UILabel()
        friends.font = UIFont.systemFont(ofSize: 12)
        friends.textColor = UIColor.gray
        return friends
    }()
    var msgButton : UIButton = {
        var button = UIButton()
        button.setBackgroundImage(UIImage(named: "thirdController"), for: .normal)
        return button
    }()
    
    var verifyIcon : UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "verify_icon")
        image.contentMode = .scaleAspectFill
        image.layer.masksToBounds = false
        image.clipsToBounds = true
        return image
    }()
    
   var optionMenu = UIButton()
    
    
    var friendRequestButton: UIButton = {
        var button = UIButton()
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
//
//        button.layer.shadowColor = UIColor(red: 190/255, green: 190/255, blue: 190/255, alpha: 1.0).cgColor
//        button.layer.shadowOffset = CGSize(width: 0, height: 4)
//        button.layer.shadowOpacity = 1.0
//        button.layer.shadowRadius = 6.0
//        button.layer.masksToBounds = false
        return button
    }()
   
    
    override func layoutSubviews() {
        super.layoutSubviews()
        cellView.frame = CGRect(x: 7.5, y: 5, width: self.bounds.width - 15, height: self.bounds.height - 10)
        cellView.backgroundColor = UIColor.white
        addSubview(cellView)
        cellView.layer.shadowColor = UIColor(red: 190/255, green: 190/255, blue: 190/255, alpha: 1.0).cgColor
        cellView.layer.shadowOpacity = 2
        cellView.layer.shadowOffset = CGSize.zero
        cellView.layer.shadowRadius = 3
        cellView.addSubview(profileImage)
        let profileFrame = CGRect(x: 10, y: 25, width: 60, height: 60)
        profileImage.frame = profileFrame
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        
        verifyIcon.frame = CGRect(x: getRightEdgeX(inputView: profileImage) - 23, y: getBottomEdgeY(inputView: profileImage) - 23, width: 20, height: 20)
        verifyIcon.layer.cornerRadius = 10
        cellView.addSubview(verifyIcon)
        
        cellView.addSubview(containerView)
        let containerFrame = CGRect(x: Int(getRightEdgeX(inputView: profileImage)+8), y: 25, width: Int(self.bounds.width - getRightEdgeX(inputView: profileImage) + 5), height: Int(self.bounds.height - 25))
        containerView.frame = containerFrame
        setContainerView()

    }
    
    func setContainerView()
    {
     containerView.addSubview(userName)
        let nameframe = CGRect(x: 10, y: 0, width: 200, height: 20)
        userName.frame = nameframe
        containerView.addSubview(locationLabel)
        let locationFrame = CGRect(x: 10, y: getBottomEdgeY(inputView: userName) + 5, width: containerView.frame.width - 115, height: 15)
        locationLabel.frame = locationFrame
        containerView.addSubview(mutualFriendsLabel)
        mutualFriendsLabel.frame = CGRect(x: 10, y: getBottomEdgeY(inputView: locationLabel) + 5, width: 150, height: 15)
        
        containerView.addSubview(friendRequestButton)
//        friendRequestButton.frame = CGRect(x: containerView.frame.width - 115, y: containerView.frame.height - 50, width: 80, height: 30)
//        friendRequestButton.layer.cornerRadius = friendRequestButton.frame.height/2
        friendRequestButton.frame = CGRect(x: Int(getRightEdgeX(inputView: locationLabel) + 30), y: Int(getBottomEdgeY(inputView: userName) - 5), width: 25, height: 25)
        containerView.addSubview(friendName)
        friendName.frame = CGRect(x: 10, y: getBottomEdgeY(inputView: userName) - 5, width: containerView.frame.width - 115, height: 20)
        msgButton.frame = CGRect(x: getRightEdgeX(inputView: friendName) + 10, y: 12, width: 25, height: 25)
        optionMenu.frame = CGRect(x: getRightEdgeX(inputView: msgButton) + 10, y: 12, width: 25, height: 25)
        
    
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    }

