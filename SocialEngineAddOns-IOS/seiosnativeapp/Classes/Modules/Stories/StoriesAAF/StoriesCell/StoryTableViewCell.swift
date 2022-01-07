//
//  CustomTableViewCell.swift
//  seiosnativeapp
//
//  Created by BigStep on 22/08/18.
//  Copyright © 2018 bigstep. All rights reserved.
//

import UIKit

class StoryTableViewCell: UITableViewCell {

    
    @IBOutlet weak var imgCheck: UIImageView!
    @IBOutlet weak var viewShadow: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var lblTitleStoryOption: UILabel!
    
    @IBOutlet weak var imgStoryView: UIImageView!
    
    @IBOutlet weak var lblStoryViewName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
