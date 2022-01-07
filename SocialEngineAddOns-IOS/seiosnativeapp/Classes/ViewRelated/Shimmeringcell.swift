//
//  Shimmeringcell.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 05/05/17.
//  Copyright © 2017 bigstep. All rights reserved.
//

import UIKit

class Shimmeringcell: UITableViewCell {
    
 let textColorshimmer = UIColor(red: 227/255.0, green: 227/255.0, blue: 227/255.0, alpha: 1.0)
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    var cellView:UIView!
    var subject_photo:UIImageView!
    var title:TTTAttributedLabel!
    var createdAt: UILabel!
    var shimmerlabel1: UILabel!
    var shimmerlabel2: UILabel!
    var shimmerlabel3: UILabel!
    var shimmeringView: FBShimmeringView!
    // Initialize Variable for Custom Table Cell
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = aafBgColor
        self.selectionStyle = UITableViewCell.SelectionStyle.none
        cellView = createView(CGRect(x: 0, y: 0,width: UIScreen.main.bounds.width ,height: 165), borderColor: borderColorLight, shadow: true)
        cellView.layer.shadowColor = shadowColor.cgColor
        cellView.layer.shadowOpacity = shadowOpacity
        cellView.layer.shadowRadius = shadowRadius
        cellView.layer.shadowOffset = shadowOffset
        self.addSubview(cellView)
        
        shimmeringView = FBShimmeringView.init(frame: CGRect(x: 0, y: 0,width: cellView.frame.size.width ,height: 165))
        shimmeringView.backgroundColor = UIColor.white
        shimmeringView.contentView = cellView
        shimmeringView.isShimmering = true
        
        //Optional ShimmeringView protocal values
        //All values show are the defaults
        shimmeringView.shimmeringPauseDuration = 0.4
        shimmeringView.shimmeringAnimationOpacity = 0.5
        shimmeringView.shimmeringOpacity = 1.0
        shimmeringView.shimmeringSpeed = 230
        shimmeringView.shimmeringHighlightLength = 0.33
        shimmeringView.shimmeringDirection = FBShimmerDirection.right
        shimmeringView.shimmeringBeginFadeDuration = 0.6
        shimmeringView.shimmeringEndFadeDuration = 1.0
        self.addSubview(shimmeringView)
        
        subject_photo = createImageView(CGRect(x: 5, y: 5, width: 40, height: 40), border: true)
        subject_photo.image = UIImage(named: "")
        subject_photo.backgroundColor = textColorshimmer
        subject_photo.layer.cornerRadius = subject_photo.frame.size.width/2
        subject_photo.clipsToBounds = true
        cellView.addSubview(subject_photo)
        
        title = TTTAttributedLabel(frame:CGRect(x: subject_photo.bounds.width + 10 , y: 10, width: 60, height: 5))
        title.numberOfLines = 0
        title.linkAttributes = [kCTForegroundColorAttributeName:textColorDark]
        title.textColor = textColorDark
        title.backgroundColor = textColorshimmer
        title.font = UIFont(name: fontName, size: FONTSIZENormal)
        cellView.addSubview(title)
        
        createdAt = createLabel(CGRect(x: subject_photo.bounds.width + 10, y: 25, width: 40, height: 5), text: "", alignment: .left, textColor: textColorMedium)
        createdAt.font = UIFont(name: fontName, size: FONTSIZESmall)
        createdAt.backgroundColor = textColorshimmer
        cellView.addSubview(createdAt)
        
        shimmerlabel1 = createLabel(CGRect(x: 5, y: getBottomEdgeY(inputView: subject_photo)+20, width: cellView.frame.size.width - 100, height: 5), text: "", alignment: .left, textColor: textColorMedium)
        shimmerlabel1.font = UIFont(name: fontName, size: FONTSIZESmall)
        shimmerlabel1.backgroundColor = textColorshimmer
        cellView.addSubview(shimmerlabel1)
        
        shimmerlabel2 = createLabel(CGRect(x: 5, y: getBottomEdgeY(inputView: subject_photo)+35, width: cellView.frame.size.width - 70, height: 5), text: "", alignment: .left, textColor: textColorMedium)
        shimmerlabel2.font = UIFont(name: fontName, size: FONTSIZESmall)
        shimmerlabel2.backgroundColor = textColorshimmer
        cellView.addSubview(shimmerlabel2)
        
        shimmerlabel3 = createLabel(CGRect(x: 5, y: getBottomEdgeY(inputView: subject_photo)+50, width: cellView.frame.size.width - 120, height: 5), text: "", alignment: .left, textColor: textColorMedium)
        shimmerlabel3.font = UIFont(name: fontName, size: FONTSIZESmall)
        shimmerlabel3.backgroundColor = textColorshimmer
        cellView.addSubview(shimmerlabel3)
        
        
    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
