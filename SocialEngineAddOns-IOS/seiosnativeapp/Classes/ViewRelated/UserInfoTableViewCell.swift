/*
 * Copyright (c) 2016 BigStep Technologies Private Limited.
 *
 * You may not use this file except in compliance with the
 * SocialEngineAddOns License Agreement.
 * You may obtain a copy of the License at:
 * https://www.socialengineaddons.com/ios-app-license
 * The full copyright and license information is also mentioned
 * in the LICENSE file that was distributed with this
 * source code.
 */

import UIKit

class UserInfoTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    var cellView: UIView!
    var label1 : UILabel!
    var label2 : TTTAttributedLabel!
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        label1 = UILabel(frame: CGRect(x: 5, y: 10, width: 100, height: 20))
        label1.numberOfLines = 0
        label1.textColor = textColorDark
        label1.font = UIFont(name: fontName, size: 13)
        self.addSubview(label1)
        
        // Description
        label2 = TTTAttributedLabel(frame: CGRect(x: 120, y: 12,width: self.bounds.width-120 , height: 20))
        label2.numberOfLines = 0
        label2.textColor = textColorMedium
        label2.font = UIFont(name: fontName, size: 13)
        self.addSubview(label2)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
