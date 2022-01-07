//
//  videoListTableViewCell.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 19/06/17.
//  Copyright © 2017 bigstep. All rights reserved.
//

import UIKit

class videoListTableViewCell: UITableViewCell {

    var cellView: UIView!
    var contentImage:UIImageView!
    var contentName:UILabel!
    var ownerName:UILabel!
    var videoDuration:UILabel!
    var btncross: UIButton!
    var contentSelection: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    // Initialize Variable for Comments Table Cell
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Configure the view for the selected state
        

        if(UIDevice.current.userInterfaceIdiom == .pad){
            cellView = createView(CGRect(x: 0, y: 0 ,width: UIScreen.main.bounds.width , height: 73), borderColor: textColorclear, shadow: false)
        }else{
            cellView = createView( CGRect(x: 0, y: 0,width: UIScreen.main.bounds.width , height: 73), borderColor: textColorclear, shadow: false)
        }
        cellView.isUserInteractionEnabled = true
        self.addSubview(cellView)
 
        contentImage = createImageView(CGRect(x: 5, y: 3, width: UIScreen.main.bounds.width*0.4, height: 70), border: false)
        contentImage.layer.cornerRadius = cornerRadiusSmall
        contentImage.layer.masksToBounds = true
        contentImage.contentMode = UIView.ContentMode.scaleAspectFill
        contentImage.image = UIImage(named: "user_profile_image.png")
        cellView.addSubview(contentImage)
        
        contentSelection = createButton(CGRect(x: 5, y: 3, width: UIScreen.main.bounds.width*0.4, height: 70), title: "", border: false,bgColor: false, textColor: textColorLight)
        
        contentSelection.setBackgroundColor(textColorclear, forUIControlState: UIControl.State.normal)
        //setBackgroundColor(textColorclear, UIControl.State: .normal)
        cellView.addSubview(contentSelection)
        
        
        videoDuration = createLabel(CGRect(x: (contentImage.bounds.width - 40), y: 0, width: 35,height: 20), text: "", alignment: .center, textColor: textColorLight)
        videoDuration.font = UIFont(name: fontName, size: FONTSIZESmall)
        videoDuration.backgroundColor = UIColor.black
        videoDuration.text = "02:25:23"
        contentImage.addSubview(videoDuration)
        
        contentName = createLabel(CGRect(x: getRightEdgeX(inputView: contentImage) + 10, y: 0, width: (cellView.bounds.width - getRightEdgeX(inputView: contentImage)-40), height: 20), text: "", alignment: .left, textColor: textColorDark)
        contentName.numberOfLines = 2
        contentName.lineBreakMode = .byWordWrapping
        contentName.text = ""
        contentName.font = UIFont(name: fontBold, size: FONTSIZEMedium)
        cellView.addSubview(contentName)
        
        ownerName = createLabel(CGRect(x: getRightEdgeX(inputView: contentImage) + 10, y: getBottomEdgeY(inputView: contentName), width: (cellView.bounds.width - getRightEdgeX(inputView: contentImage)-40), height: 20), text: "", alignment: .left, textColor: textColorMedium)
        ownerName.numberOfLines = 0
        ownerName.text = ""
        ownerName.font = UIFont(name: fontBold, size: FONTSIZESmall)
        ownerName.lineBreakMode = .byTruncatingTail
        cellView.addSubview(ownerName)
        
        btncross  = createButton(CGRect(x: cellView.frame.size.width - 30,y: cellView.frame.origin.y, width: 20, height: 20), title: crossIcon, border: false,bgColor: false,textColor: textColorMedium)
        btncross.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZELarge)
        btncross.isHidden = true
        cellView.addSubview(btncross)
       
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
