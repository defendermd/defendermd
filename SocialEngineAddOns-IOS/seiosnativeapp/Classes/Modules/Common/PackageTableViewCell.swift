//
//  PackageTableViewCell.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 18/05/16.
//  Copyright © 2016 bigstep. All rights reserved.


import UIKit

class PackageTableViewCell: UITableViewCell
{
    var cellView:UIView!
    var lbltitle:UILabel!
    var btnmenu:UIButton!
    var lineView:UIView!

    override func awakeFromNib()
    {
        super.awakeFromNib()
        
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        cellView = createView( CGRect(x: 0, y: 0,width: (UIScreen.main.bounds.width) , height: 60), borderColor: borderColorMedium, shadow: false)
        cellView.layer.borderWidth = 0.0
        self.addSubview(cellView)
        cellView.backgroundColor = UIColor.clear
        cellView.isUserInteractionEnabled = true
        
        
        
        lbltitle = createLabel(CGRect(x: 20, y: 20, width: cellView.frame.size.width-80, height: 39), text: "Pay $1 for Paid and Free Tickets shjgfdvds fhdbs fdshfbds fdsbf ds f ds g", alignment: .left, textColor: textColorDark)
        lbltitle.font = UIFont(name: fontName, size: 16)
        lbltitle.textAlignment = NSTextAlignment.left
        lbltitle.lineBreakMode = NSLineBreakMode.byWordWrapping
        lbltitle.numberOfLines = 0
        lbltitle.backgroundColor = UIColor.clear
        lbltitle.sizeToFit()
        cellView.addSubview(lbltitle)
        
         
        btnmenu = createButton(CGRect(x: cellView.frame.size.width-50,y: cellView.frame.origin.y,width: 25,height: 25), title: "", border: false,bgColor: false, textColor: textColorMedium)
        btnmenu.setImage(UIImage(named: "blackoption"), for: UIControl.State())
        btnmenu.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZESmall)
        //btnmenu.backgroundColor = UIColor.red
        cellView.addSubview(btnmenu)
        
        lineView = createView(CGRect(x: 0,y: cellView.frame.size.height-1,width: cellView.frame.size.width,height: 1), borderColor: borderColorMedium, shadow: false)
        lineView.layer.borderWidth = 0.0
        lineView.backgroundColor = borderColorMedium
        cellView.addSubview(lineView)
        
        
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

    }

}
