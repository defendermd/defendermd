//
//  LiveUserTableViewCell.swift
//  seiosnativeapp
//
//  Created by bigstep on 30/11/18.
//  Copyright © 2018 bigstep. All rights reserved.
//

import UIKit

class LiveUserTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var viewerTitle : TTTAttributedLabel!
    var viewerImage = UIImageView()
    var lineView = UIView()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        if  (UIDevice.current.userInterfaceIdiom == .phone){
            //            author_photo = createButton(CGRect(x: 5, y: 5, width: 40, height: 40), title: "", border: true, bgColor: false, textColor: textColorLight)
            viewerImage = createImageView(CGRect(x: 5, y: 6, width: 40, height: 40), border: true)
            
            
        }else{
            //            author_photo = createButton(CGRect(x: 5, y: 5, width: 50, height: 50), title: "", border: true, bgColor: false, textColor: textColorLight)
            viewerImage = createImageView(CGRect(x: 5, y: 6, width: 50, height: 50), border: true)
            
        }
        
        viewerImage.layer.borderColor = bgColor.cgColor
        viewerImage.layer.borderWidth = 0.5
        
        self.addSubview(viewerImage)
        
        viewerTitle = TTTAttributedLabel(frame:CGRect(x: viewerImage.bounds.width+15, y: 16, width: self.bounds.width-(viewerImage.bounds.width+15), height: 20))
        viewerTitle.numberOfLines = 0
        viewerTitle.linkAttributes = [kCTForegroundColorAttributeName:textColorDark]
        viewerTitle.font = UIFont.systemFont(ofSize: FONTSIZENormal)
        self.addSubview(viewerTitle)
        
        lineView = UIView(frame: CGRect(x: 0,y: 55,width: (UIScreen.main.bounds).width,height: 3))
        lineView.backgroundColor = tableViewBgColor
        
        self.addSubview(lineView)
        lineView.isHidden = true
        
        
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
