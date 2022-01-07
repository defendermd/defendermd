//
//  LiveCommentTableViewCell.swift
//  seiosnativeapp
//
//  Created by bigstep on 28/11/18.
//  Copyright © 2018 bigstep. All rights reserved.
//

import UIKit

class LiveCommentTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var liveUserTitle : TTTAttributedLabel!
    var liveBody : TTTAttributedLabel!
    var liveUserImage = UIImageView()

   
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        if  (UIDevice.current.userInterfaceIdiom == .phone){
            //            author_photo = createButton(CGRect(x: 5, y: 5, width: 40, height: 40), title: "", border: true, bgColor: false, textColor: textColorLight)
            liveUserImage = createImageView(CGRect(x: 5, y: 5, width: 40, height: 40), border: true)
            
            
        }else{
            //            author_photo = createButton(CGRect(x: 5, y: 5, width: 50, height: 50), title: "", border: true, bgColor: false, textColor: textColorLight)
            liveUserImage = createImageView(CGRect(x: 5, y: 5, width: 50, height: 50), border: true)
            
        }
        
        liveUserImage.layer.borderColor = bgColor.cgColor
        liveUserImage.layer.borderWidth = 0.0
        
        self.addSubview(liveUserImage)
        
        liveUserTitle = TTTAttributedLabel(frame:CGRect(x: liveUserImage.bounds.width+10, y: 5, width: self.bounds.width-(liveUserImage.bounds.width+15), height: 20))
        liveUserTitle.numberOfLines = 1
        liveUserTitle.textColor = UIColor.white
        liveUserTitle.linkAttributes = [kCTForegroundColorAttributeName:UIColor.white]
        liveUserTitle.font = UIFont(name: fontBold, size: FONTSIZENormal)
        self.addSubview(liveUserTitle)
        
        liveBody = TTTAttributedLabel(frame:CGRect(x: liveUserImage.bounds.width+10, y: 26, width: self.bounds.width-(liveUserImage.bounds.width+15), height: 100))
        liveBody.font = UIFont(name: fontName, size: FONTSIZENormal )
        liveBody.textColor = UIColor.white
        liveBody.linkAttributes = [kCTForegroundColorAttributeName:UIColor.white]
        liveBody.numberOfLines = 0
        self.addSubview(liveBody)
        
    }
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
