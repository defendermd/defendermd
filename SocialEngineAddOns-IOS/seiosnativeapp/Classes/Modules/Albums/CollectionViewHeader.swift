//
//  CollectionViewHeader.swift
//  seiosnativeapp
//
//  Created by bigstep_macbook_air on 2/12/19.
//  Copyright © 2019 bigstep. All rights reserved.
//

import UIKit

class CollectionViewHeader: UICollectionReusableView {
    var view: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        view = UIView()
        view.frame = self.frame
        addSubview(view)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
