//
//  CollectionViewCell.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 17/12/17.
//  Copyright © 2017 bigstep. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell{
    
    var suggestionView: UIView!
    var suggestionImageView: UIImageView!
    var suggestionDetailView: UIView!
    var contentTitle: UILabel!
    var contentDetail: UILabel!
    var addFriend: UIButton!
    var removeSuggestion: UIButton!
    var findMoreSuggestions: UIButton!
    var contentRedirectionView : UIButton!

    override func awakeFromNib() {
        
        
        suggestionView = createView(CGRect(x: 0, y: PADING, width: self.bounds.size.width, height: self.bounds.size.height - 2*PADING), borderColor: .clear, shadow: true)
        contentView.addSubview(suggestionView)
        

        suggestionImageView = createImageView(CGRect(x: 0.0, y: 0.0, width: suggestionView.frame.width, height: suggestionView.frame.height * 0.60), border: false)
        suggestionView.addSubview(suggestionImageView)
        
        // ContentSelection
        contentRedirectionView = createButton(CGRect(x: 0.0, y: 0.0, width: suggestionImageView.frame.size.width, height: suggestionImageView.frame.size.height), title: "", border: false, bgColor: false, textColor: textColorMedium)
        contentRedirectionView.titleLabel?.font = UIFont(name: fontName, size:FONTSIZESmall)
        suggestionView.addSubview(contentRedirectionView)
        
        
        suggestionDetailView = createView(CGRect(x: 0.0, y: suggestionImageView.frame.height, width: suggestionView.frame.width, height: suggestionView.frame.height * 0.40), borderColor: .clear, shadow: false)
        suggestionView.addSubview(suggestionDetailView)
        
        contentTitle = createLabel(CGRect(x: PADING + 5, y: 2, width: suggestionDetailView.frame.width - PADING, height: suggestionDetailView.frame.size.height * 0.2), text: "Test User", alignment: .left, textColor: textColorDark)
        contentTitle.font = UIFont(name: fontBold, size: FONTSIZENormal)
        suggestionDetailView.addSubview(contentTitle)
        
        
        contentDetail = createLabel(CGRect(x: PADING + 5, y: getBottomEdgeY(inputView: contentTitle), width: suggestionDetailView.frame.width - (2*PADING)-10, height: suggestionDetailView.frame.size.height * 0.2), text: "", alignment: .left, textColor: textColorMedium)
        contentDetail.font = UIFont(name: "FontAwesome", size:FONTSIZESmall)
        contentDetail.lineBreakMode = NSLineBreakMode.byTruncatingTail
        suggestionDetailView.addSubview(contentDetail)
        
        addFriend = createButton(CGRect(x: 2*PADING, y: getBottomEdgeY(inputView: contentDetail) + 5, width: suggestionDetailView.frame.width - (4*PADING), height: suggestionDetailView.frame.size.height * 0.25), title: friendReuestIcon + NSLocalizedString(" Add Friend",  comment: ""), border: true, bgColor: true, textColor: buttonColor)
        addFriend.backgroundColor = UIColor.clear
        addFriend.titleLabel?.font = UIFont(name: "FontAwesome", size:FONTSIZESmall)
        addFriend.layer.borderColor = buttonColor.cgColor
        addFriend.layer.cornerRadius = (suggestionDetailView.frame.size.height * 0.25)/5
        addFriend.layer.shouldRasterize = true
        addFriend.layer.isOpaque = true
        addFriend.layer.rasterizationScale = UIScreen.main.scale
        suggestionDetailView.addSubview(addFriend)

        
        removeSuggestion = createButton(CGRect(x: PADING, y: getBottomEdgeY(inputView: addFriend) + 4, width: suggestionDetailView.frame.width - PADING, height: suggestionDetailView.frame.size.height * 0.2), title: NSLocalizedString("Remove",  comment: ""), border: false, bgColor: false, textColor: textColorMedium)
        removeSuggestion.titleLabel?.font = UIFont(name: fontName, size:FONTSIZESmall)
        suggestionDetailView.addSubview(removeSuggestion)
        
        
        findMoreSuggestions = createButton(CGRect(x: 2*PADING, y: getBottomEdgeY(inputView: contentDetail) + 5, width: suggestionDetailView.frame.width - (4*PADING), height: suggestionDetailView.frame.size.height * 0.25), title: NSLocalizedString("Find more friends",  comment: ""), border: true, bgColor: true, textColor: buttonColor)
        findMoreSuggestions.backgroundColor = UIColor.clear
        findMoreSuggestions.titleLabel?.font = UIFont(name: "FontAwesome", size:FONTSIZESmall)
        findMoreSuggestions.layer.borderColor = buttonColor.cgColor
        findMoreSuggestions.layer.cornerRadius = (suggestionDetailView.frame.size.height * 0.25)/5
        findMoreSuggestions.layer.shouldRasterize = true
        findMoreSuggestions.layer.isOpaque = true
        findMoreSuggestions.layer.rasterizationScale = UIScreen.main.scale
        findMoreSuggestions.isHidden = true
        suggestionDetailView.addSubview(findMoreSuggestions)
    }
    

}
