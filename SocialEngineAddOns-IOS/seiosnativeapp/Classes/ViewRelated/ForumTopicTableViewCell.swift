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

//
//  ForumTopicTableViewCell.swift
//  seiosnativeapp
//

import UIKit
import WebKit

class ForumTopicTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    var cellView: UIView!
    var ownerInfo :TTTAttributedLabel!
    var ownerIcon:UIImageView!
    var detail = WKWebView()
    var menu : UIButton!
    var editDetail :TTTAttributedLabel!
    
    // Initialize Variable for Table Cell
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        cellView = createView(CGRect(x: 5, y: 0,width: UIScreen.main.bounds.width-10 ,height: 110), borderColor: UIColor.clear, shadow: false)
        self.addSubview(cellView)
        
        // Icon Size
        if  (UIDevice.current.userInterfaceIdiom == .phone){
            ownerIcon = createImageView(CGRect(x: 5, y: 10, width: 50, height: 50), border: true)
        }else{
            ownerIcon = createImageView(CGRect(x: 5, y: 10, width: 50, height: 50), border: true)
        }
        
        ownerIcon.layer.borderWidth = 2.5
        ownerIcon.layer.masksToBounds = true
        ownerIcon.layer.cornerRadius = ownerIcon.frame.size.width / 2;
        cellView.addSubview(ownerIcon)
        
        // Description
        ownerInfo = TTTAttributedLabel(frame: CGRect(x: ownerIcon.bounds.width + 10, y: 20,width: (cellView.bounds.width - (ownerIcon.bounds.width + 55)) , height: 35))
        ownerInfo.numberOfLines = 0
        ownerInfo.linkAttributes = [kCTForegroundColorAttributeName:textColorMedium]
        ownerInfo.textColor = textColorMedium
        ownerInfo.font = UIFont(name: fontName, size: 13)
        cellView.addSubview(ownerInfo)
        
        
        detail = WKWebView(frame: CGRect(x: 5 ,y: ownerIcon.bounds.height + ownerIcon.frame.origin.y + 15, width: cellView.bounds.width - 10,height:0))
        detail.scrollView.isScrollEnabled = false
        detail.isUserInteractionEnabled = false
        detail.scrollView.bounces = false
        detail.backgroundColor = tableViewBgColor//UIColor.red
        detail.translatesAutoresizingMaskIntoConstraints = false
        cellView.addSubview(detail)
        
        
        menu = createButton(CGRect( x: cellView.bounds.width - 40, y: 15, width: 40, height: 40), title: moreIcon, border: false, bgColor: false, textColor: textColorMedium)
        menu.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZEExtraLarge)
        menu.isHidden = true
        cellView.addSubview(menu)
        
        editDetail = TTTAttributedLabel(frame :  CGRect( x: 10,y: ownerIcon.bounds.height + ownerIcon.frame.origin.y + 10, width: cellView.bounds.width - (ownerIcon.bounds.width + 20) , height: 30))
        editDetail.textColor = UIColor.blue//textColorMedium
        editDetail.numberOfLines = 0
        editDetail.font = UIFont(name: fontName, size: FONTSIZESmall)
        cellView.addSubview(editDetail)
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
