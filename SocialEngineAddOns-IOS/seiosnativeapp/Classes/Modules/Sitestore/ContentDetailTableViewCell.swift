//
//  ContentDetailTableViewCell.swift
//  seiosnativeapp
//
//  Created by bigstep on 20/10/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit

class ContentDetailTableViewCell: UITableViewCell {

    var labTitle : UILabel!
    var labId : UILabel!
    var lineView: UIView!
    var labdate : UILabel!
    var labstatus : UILabel!
    var labService : UILabel!
    var labNotes : UILabel!
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ isSelected: Bool, animated: Bool) {
        super.setSelected(isSelected, animated: animated)

        // Configure the view for the isSelected state
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Title
        
        labTitle = createLabel(CGRect(x:10, y:10,width:(UIScreen.main.bounds.width)-150 , height:20), text: " ", alignment: .left, textColor: textColorDark)
        labTitle.numberOfLines = 0
        labTitle.lineBreakMode = NSLineBreakMode.byTruncatingTail
        labTitle.font = UIFont(name: fontName, size: FONTSIZENormal)
        labTitle.text = ""
        self.contentView.addSubview(labTitle)
        
        labId = createLabel(CGRect(x:labTitle.frame.origin.x+labTitle.frame.size.width+10,y:labTitle.frame.origin.y,width:(UIScreen.main.bounds.width)-(labTitle.frame.size.width + labTitle.frame.origin.x+20) ,height:20), text: " ", alignment: .left, textColor: textColorDark)
        labId.numberOfLines = 0
        labId.lineBreakMode = NSLineBreakMode.byTruncatingTail
        labId.font = UIFont(name: fontBold, size: FONTSIZENormal)
        labId.textAlignment = NSTextAlignment.right
        labId.text = ""
        self.contentView.addSubview(labId)
        
        
        
        labdate = createLabel(CGRect(x:labTitle.frame.origin.x,y:labTitle.frame.origin.y+labTitle.frame.size.height,width:(UIScreen.main.bounds.width) , height:15), text: " ", alignment: .left, textColor: textColorMedium)
        labdate.numberOfLines = 0
        labdate.lineBreakMode = NSLineBreakMode.byTruncatingTail
        labdate.font = UIFont(name: fontName, size: FONTSIZESmall)
        labdate.text = ""
        self.contentView.addSubview(labdate)
        
        
        labstatus = createLabel(CGRect(x:labTitle.frame.origin.x,y:labdate.frame.origin.y+labdate.frame.size.height,width:(UIScreen.main.bounds.width) , height:15), text: " ", alignment: .left, textColor: textColorMedium)
        labstatus.numberOfLines = 0
        labstatus.lineBreakMode = NSLineBreakMode.byTruncatingTail
        labstatus.font = UIFont(name: fontName, size: FONTSIZESmall)
        labstatus.text = ""
        self.contentView.addSubview(labstatus)
        
        labService = createLabel(CGRect(x:labTitle.frame.origin.x,y:labstatus.frame.origin.y+labstatus.frame.size.height,width:(UIScreen.main.bounds.width) , height:15), text: " ", alignment: .left, textColor: textColorMedium)
        labService.numberOfLines = 0
        labService.lineBreakMode = NSLineBreakMode.byTruncatingTail
        labService.font = UIFont(name: fontName, size: FONTSIZESmall)
        labService.text = ""
        self.contentView.addSubview(labService)
        
        labNotes = createLabel(CGRect(x:labTitle.frame.origin.x,y:labService.frame.origin.y+labService.frame.size.height,width:(UIScreen.main.bounds.width)-(2*labTitle.frame.origin.x) ,height:15), text: "", alignment: .left, textColor: textColorMedium)
        labNotes.backgroundColor = UIColor.clear
        labNotes.numberOfLines = 0
        labNotes.lineBreakMode = NSLineBreakMode.byTruncatingTail
        labNotes.textColor = textColorMedium
        labNotes.font = UIFont(name: fontName, size: FONTSIZESmall)
        self.contentView.addSubview(labNotes)
        
        lineView = UIView(frame:CGRect(x:0, y:labNotes.frame.size.height+labNotes.frame.origin.y+10,width:(UIScreen.main.bounds).width-labTitle.frame.origin.x, height:1))
        lineView.backgroundColor = aafBgColor
        self.addSubview(lineView)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}
