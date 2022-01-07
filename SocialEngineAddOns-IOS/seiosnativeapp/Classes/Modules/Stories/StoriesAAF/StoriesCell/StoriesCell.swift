//
//  StoriesCell.swift
//  seiosnativeapp
//
//  Created by BigStep on 07/08/18.
//  Copyright © 2018 bigstep. All rights reserved.
//

import UIKit

class StoriesCell: UICollectionViewCell {
    //MARK: Property
    
    @IBOutlet weak var imgStory: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var viewUserBlur: UIView!
    @IBOutlet weak var viewStory: UIView!
    
    @IBOutlet weak var imgUser: UIImageView!
    
    @IBOutlet weak var viewBlur: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }

}
