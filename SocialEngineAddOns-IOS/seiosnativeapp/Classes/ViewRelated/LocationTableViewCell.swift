//
//  LocationTableViewCell.swift
//  seiosnativeapp
//
//  Created by bigstep on 01/04/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit

class LocationTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // Define Variable for Custom Table Cell
    var imgUser:UIImageView!
    var title : UILabel!
    var subTitle :UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Configure the view for the selected state
        
        imgUser = createImageView(CGRect(x: 5, y: 5, width: 35, height: 35), border: false)
        self.addSubview(imgUser)
        
        // Title
        title = createLabel(CGRect( x: imgUser.bounds.width + 10, y: 0,width: (UIScreen.main.bounds.width - (imgUser.bounds.width + 15)) , height: 30), text: " ", alignment: .left, textColor: textColorDark)
        title.numberOfLines = 1
        title.font = UIFont(name: fontBold, size: FONTSIZENormal)
        self.addSubview(title)
        
        // Title
        subTitle = createLabel(CGRect( x: imgUser.bounds.width + 10, y: title.bounds.height - 10 ,width: (UIScreen.main.bounds.width - (imgUser.bounds.width + 15)) , height: 20), text: " ", alignment: .left, textColor: textColorMedium)
        subTitle.numberOfLines = 1
        subTitle.font = UIFont(name: fontName, size: FONTSIZESmall)
        subTitle.isHidden = true
        self.addSubview(subTitle)
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
