//
//  InviteMemberTableViewCell.swift
//  seiosnativeapp
//
//  Created by Bigstep IOS on 2/15/17.
//  Copyright © 2017 bigstep. All rights reserved.
//

import UIKit

class InviteMemberTableViewCell: UITableViewCell {
    
    var memberName: UILabel!
    var memberContact: UILabel!
    var inviteButton: UIButton!
    var mainView: UIView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!)
    {
        //First Call Super
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        mainView = createView(CGRect(x: 0.0, y: 5.0, width: UIScreen.main.bounds.width, height: self.frame.size.height), borderColor: .clear, shadow: false)
        mainView.backgroundColor = UIColor.white
        self.addSubview(mainView)
        
        memberName = createLabel(CGRect(x: 5.0, y: 10.0, width: UIScreen.main.bounds.width - (UIScreen.main.bounds.width*0.25 + 10), height: 20), text: "", alignment: .left, textColor: textColorDark)
        memberName.font = UIFont(name: fontName, size: FONTSIZELarge)
        mainView.addSubview(memberName)
        
        memberContact = createLabel(CGRect(x: 5.0, y: getBottomEdgeY(inputView: memberName), width: memberName.frame.size.width, height: 20), text: "", alignment: NSTextAlignment.left, textColor: textColorMedium)
        memberContact.font = UIFont(name: fontName, size: FONTSIZENormal)
        mainView.addSubview(memberContact)
        
        inviteButton = createButton(CGRect(x: UIScreen.main.bounds.width * 0.75, y: 15, width: UIScreen.main.bounds.width*0.25 - 5, height: 30), title: NSLocalizedString("Invite", comment: ""), border: false, bgColor: true, textColor: textColorPrime)
        mainView.addSubview(inviteButton)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
