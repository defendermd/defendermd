//
//  TicketCustomTableViewCell.swift
//  seiosnativeapp
//
//  Created by Bigstep IOS on 1/12/18.
//  Copyright © 2018 bigstep. All rights reserved.
//

import UIKit

class TicketCustomTableViewCell: UITableViewCell {
    
    var labTitle = UILabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = UITableViewCell.SelectionStyle.blue
        
        labTitle = createLabel(CGRect(x:0, y:0,width:100, height:20), text: "", alignment: .left, textColor: textColorDark)
        labTitle.lineBreakMode = NSLineBreakMode.byTruncatingTail
        labTitle.font = UIFont(name: fontName, size: FONTSIZEMedium)
        //        labTitle.backgroundColor = UIColor.white
        self.addSubview(labTitle)
        // Configure the view for the selected state
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
