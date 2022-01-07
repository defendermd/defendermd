//
//  MyOrderTableViewCell.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 22/09/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit

class MyOrderTableViewCell: UITableViewCell {

    var labOrderID : UILabel!
    var labPrice : UILabel!
    var lineView: UIView!
    var labdate : UILabel!
    var labstatus : UILabel!
    var labdownloads : UILabel!
    var labremaings : UILabel!
    var btnView :UIButton!
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ isSelected: Bool, animated: Bool)
    {
        super.setSelected(isSelected, animated: animated)
        
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Title

        labOrderID = createLabel(CGRect(x:10, y:10,width:(UIScreen.main.bounds.width)-150 , height:20), text: " ", alignment: .left, textColor: textColorDark)
        labOrderID.numberOfLines = 0
        labOrderID.lineBreakMode = NSLineBreakMode.byTruncatingTail
        labOrderID.font = UIFont(name: fontName, size: FONTSIZENormal)
        labOrderID.text = "Order No 5748547"
        self.contentView.addSubview(labOrderID)
        
        labPrice = createLabel(CGRect(x:labOrderID.frame.origin.x+labOrderID.frame.size.width+10,y:labOrderID.frame.origin.y,width:(UIScreen.main.bounds.width)-(labOrderID.frame.size.width + labOrderID.frame.origin.x+20) , height:20), text: " ", alignment: .left, textColor: textColorDark)
        labPrice.numberOfLines = 0
        labPrice.lineBreakMode = NSLineBreakMode.byTruncatingTail
        labPrice.font = UIFont(name: fontBold, size: FONTSIZENormal)
        labPrice.textAlignment = NSTextAlignment.right
        labPrice.text = "$ 250"
        self.contentView.addSubview(labPrice)
        
        btnView = createButton(CGRect(x:UIScreen.main.bounds.width-80,y:labPrice.frame.origin.y+labPrice.frame.size.height, width:70, height:30), title: "-", border: false, bgColor: false, textColor: textColorPrime)
        btnView.setTitle("View", for: UIControl.State.normal)
        
        btnView.titleLabel?.font = UIFont(name: fontBold , size: FONTSIZESmall)
        btnView.titleLabel?.textColor = textColorPrime
        btnView.backgroundColor = navColor
        btnView.layer.cornerRadius = 2; // this value vary as per your desire
        btnView.clipsToBounds = true
        self.contentView.addSubview(btnView)
        
        
        labdate = createLabel(CGRect(x:labOrderID.frame.origin.x,y:labOrderID.frame.origin.y+labOrderID.frame.size.height,width:(UIScreen.main.bounds.width) , height:15), text: " ", alignment: .left, textColor: textColorMedium)
        labdate.numberOfLines = 0
        labdate.lineBreakMode = NSLineBreakMode.byTruncatingTail
        labdate.font = UIFont(name: fontName, size: FONTSIZESmall)
        labdate.text = "August 21,2016 8.48 PM HST"
        self.contentView.addSubview(labdate)
        
        
        labstatus = createLabel(CGRect(x:labOrderID.frame.origin.x,y:labdate.frame.origin.y+labdate.frame.size.height,width:(UIScreen.main.bounds.width) , height:15), text: " ", alignment: .left, textColor: textColorMedium)
        labstatus.numberOfLines = 0
        labstatus.lineBreakMode = NSLineBreakMode.byTruncatingTail
        labstatus.font = UIFont(name: fontName, size: FONTSIZESmall)
        labstatus.text = "Payment Pending"
        self.contentView.addSubview(labstatus)
        
        labdownloads = createLabel(CGRect(x:labOrderID.frame.origin.x,y:labPrice.frame.origin.y+labPrice.frame.size.height,width:90 , height:15), text: " ", alignment: .left, textColor: textColorMedium)
        labdownloads.numberOfLines = 1
        labdownloads.lineBreakMode = NSLineBreakMode.byTruncatingTail
        labdownloads.font = UIFont(name: fontName, size: FONTSIZESmall)
        labdownloads.isHidden = true
        self.contentView.addSubview(labdownloads)
        
        labremaings = createLabel(CGRect(x:labdownloads.frame.origin.x+labdownloads.frame.size.width+10,y:labPrice.frame.origin.y+labPrice.frame.size.height,width:(UIScreen.main.bounds.width-100) , height:15), text: " ", alignment: .left, textColor: textColorMedium)
        labremaings.numberOfLines = 0
        labremaings.lineBreakMode = NSLineBreakMode.byTruncatingTail
        labremaings.font = UIFont(name: fontName, size: FONTSIZESmall)
        labremaings.isHidden = true
        self.contentView.addSubview(labremaings)
        
        
        
        lineView = UIView(frame: CGRect(x:0, y:btnView.frame.size.height+btnView.frame.origin.y+10,width:(UIScreen.main.bounds).width, height:1))
        lineView.backgroundColor = aafBgColor
        self.addSubview(lineView)
    
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
