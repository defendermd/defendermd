//
//  AlbumCollectionViewCell.swift
//  seiosnativeapp
//
//  Created by bigstep_macbook_air on 1/31/19.
//  Copyright © 2019 bigstep. All rights reserved.
//

import Foundation
import UIKit
class AlbumCollectionViewCell: UICollectionViewCell {
    var albumCoverView = UIImageView()
    var albumTitleLabel = UILabel()
    var albumPhotoCount = UILabel()
    var plusIcon = UIImageView()
    var gifImageView = UIImageView()
    var menu = UIButton()
    let titleHeight = 30
    let photoCountHeight = 20
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        self.backgroundColor = .white
    }
    
    func setupView() {
      
        albumCoverView.frame = CGRect(x: 0, y: 0, width: Int(self.frame.width), height: Int(self.frame.height) - (titleHeight + photoCountHeight))
        addSubview(albumCoverView)
        albumCoverView.layer.cornerRadius = 13
        albumCoverView.layer.masksToBounds = false
        albumCoverView.clipsToBounds = true
        albumCoverView.layer.borderWidth = 1
        albumCoverView.contentMode = .scaleAspectFill
        albumCoverView.layer.borderColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0).cgColor
        
        albumTitleLabel.frame = CGRect(x: -4, y: Int(getBottomEdgeY(inputView: albumCoverView)+1), width: Int(self.frame.width), height: titleHeight)
        albumTitleLabel.font = UIFont.systemFont(ofSize: 18)
        albumTitleLabel.textAlignment = .left
        
        addSubview(albumTitleLabel)
        
        albumPhotoCount.frame = CGRect(x: 0, y: Int(getBottomEdgeY(inputView: albumTitleLabel)-3), width: Int(self.frame.width), height: photoCountHeight)
        albumPhotoCount.font = UIFont.systemFont(ofSize: 12)
        addSubview(albumPhotoCount)
        albumPhotoCount.textAlignment = .left
    
        plusIcon.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        plusIcon.center = albumCoverView.center
        let originalImage = UIImage(named: "plusIcon")
        let tintedImage =  originalImage?.withRenderingMode(.alwaysTemplate)
        plusIcon.image = tintedImage
        plusIcon.tintColor = buttonColor
        addSubview(plusIcon)
        
         menu = createButton(CGRect(x: self.bounds.width - 40,y: 0,width: 40, height: 40), title: "\u{f141}", border: false,bgColor: false, textColor: textColorLight)
        //        menu1.setImage(UIImage(named: "icon-option.png"), forState: .normal)
        menu.titleLabel?.font =  UIFont(name: "FontAwesome", size:30.0)
        menu.isHidden = false
        menu.layer.shadowColor = shadowColor.cgColor
        menu.layer.shadowOpacity = shadowOpacity
        menu.layer.shadowRadius = shadowRadius
        menu.layer.shadowOffset = shadowOffset
        addSubview(menu)
        
        gifImageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        gifImageView.center = albumCoverView.center
        gifImageView.image = UIImage(named: "gifIcon")
        addSubview(gifImageView)
        gifImageView.isHidden = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
