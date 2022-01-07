//
//  CommunityAdsTableViewCell.swift
//  seiosnativeapp
//
//  Created by Bigstep IOS on 10/30/18.
//  Copyright © 2018 bigstep. All rights reserved.
//

import UIKit

class CommunityAdsTableViewCell: UITableViewCell {

    var adTitleLabel:UILabel!
    var adBodyLabel:UILabel!
    var adCallToActionButton:UIButton!
    var fbView:UIView!
    var adsImage : UIImageView!
    var imageButton : UIButton!
    var adImageView1 : UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // Initialize Variable for Custom Table Cell
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            self.fbView = UIView(frame: CGRect(x:0,y: 0,width: UIScreen.main.bounds.width,height: 430))
        }
        else
        {
            self.fbView = UIView(frame: CGRect(x:0,y: 0,width: UIScreen.main.bounds.width,height: 250))
        }
        self.fbView.backgroundColor = UIColor.clear
        self.fbView.tag = 1001001
        self.addSubview(fbView)
        
        adsImage = createImageView(CGRect(x: 0, y: 0, width: 18, height: 15), border: true)
        adsImage.image = UIImage(named: "ad_badge.png")
        self.fbView.addSubview(adsImage)
        
        adTitleLabel = UILabel(frame: CGRect(x:  23,y: 10,width: self.fbView.bounds.width-(40),height: 30))
        adTitleLabel.lineBreakMode = .byTruncatingTail
        adTitleLabel.textColor = textColorDark
        adTitleLabel.font = UIFont(name: fontBold, size: FONTSIZENormal)
        
        self.fbView.addSubview(adTitleLabel)
        
        
        adCallToActionButton = UIButton(frame:CGRect(x: self.fbView.bounds.width-(30), y: 5,width: 20,height: 20))
        adCallToActionButton.setImage(UIImage(named: "cross_icon")!.maskWithColor(color: textColorDark), for: UIControl.State())
        adCallToActionButton.backgroundColor = UIColor.clear
        adCallToActionButton.layer.cornerRadius = 2; // this value vary as per your desire
        //                adCallToActionButton.clipsToBounds = true
        
        self.fbView.addSubview(adCallToActionButton)
        if  (UIDevice.current.userInterfaceIdiom == .phone)
        {
            imageButton = createButton(CGRect(x: 5,y: self.adTitleLabel.bounds.height + 10 + self.adTitleLabel.frame.origin.y,width: self.fbView.bounds.width-10,height: 150),title: "", border: false, bgColor: false, textColor: textColorLight)
        }
        else
        {
            imageButton = createButton(CGRect(x: 5,y: self.adTitleLabel.bounds.height + 10 + self.adTitleLabel.frame.origin.y,width: self.fbView.bounds.width-10,height: 300),title: "", border: false, bgColor: false, textColor: textColorLight)
        }
        
        if  (UIDevice.current.userInterfaceIdiom == .phone)
        {
            adImageView1 = createImageView(CGRect(x: 0,y: 0,width: self.fbView.bounds.width-10,height: 150), border: false)
        }
        else
        {
            adImageView1 = createImageView(CGRect(x: 0,y: 0,width: self.fbView.bounds.width-10,height: 300), border: false)
        }
        adImageView1.contentMode = UIView.ContentMode.scaleAspectFit
        adImageView1.clipsToBounds = true
      
        self.fbView.addSubview(imageButton)
        imageButton.addSubview(adImageView1)
        
        adBodyLabel = UILabel(frame: CGRect(x: 10,y: imageButton.bounds.height + 10 + imageButton.frame.origin.y,width: self.fbView.bounds.width-20,height: 40))
        adBodyLabel.lineBreakMode = .byTruncatingTail
        adBodyLabel.textColor = textColorDark
        adBodyLabel.font = UIFont(name: fontName, size: FONTSIZENormal)
        self.fbView.addSubview(adBodyLabel)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        adTitleLabel.text = ""
        adBodyLabel.text = ""
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
