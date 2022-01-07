//
//  NativeMusicCell.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 25/07/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit

class BottomSheetCell: UITableViewCell {
    
    var imageview:UILabel!
    var imagetitle:UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    // Initialize Variable for Comments Table Cell
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Configure the view for the selected state
        
        imageview = createLabel(CGRect(x: 10, y: 0, width: 35 , height: 50), text: " ", alignment: .left, textColor: textColorLight)
        imageview.font = UIFont(name: "FontAwesome", size: FONTSIZEExtraLarge)
        imageview.isHidden = false
        self.addSubview(imageview)
        
        
        imagetitle = createLabel(CGRect(x:imageview.frame.origin.x + imageview.bounds.width + 5, y: 0, width: UIScreen.main.bounds.width - (imageview.frame.origin.x + imageview.bounds.width + 10) , height: 50), text: " ", alignment: .left, textColor: textColorLight)
        imagetitle.font = UIFont(name: fontName, size: FONTSIZELarge)
        imagetitle.isHidden = false
        self.addSubview(imagetitle)

        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
