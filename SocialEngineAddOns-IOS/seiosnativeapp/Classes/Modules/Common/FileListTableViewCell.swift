//
//  FileListTableViewCell.swift
//  seiosnativeapp
//
//  Created by Vidit Paliwal on 13/03/18.
//  Copyright © 2018 bigstep. All rights reserved.
//

import Foundation
import UIKit

class FileListTableViewCell: UITableViewCell
{
    var fileTitle : UILabel!
    var cellView : UIView!
    var downloadTitle : UILabel!
    var extensionTitle : UILabel!
    var statusTtile : UILabel!
    var btnMenu : UIButton!
    var lineView:UIView!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        cellView = createView(CGRect(x: 0, y: 0, width: (UIScreen.main.bounds.width), height: 230), borderColor: borderColorMedium, shadow: false)
        cellView.layer.borderWidth = 0.0
        cellView.backgroundColor = UIColor.clear
        cellView.isUserInteractionEnabled = true
        self.addSubview(cellView)
        
        fileTitle = createLabel(CGRect(x: 20, y: 20, width: cellView.frame.size.width-20, height: 40), text: "Title", alignment: .left, textColor: textColorDark)
        fileTitle.font = UIFont(name: fontName, size: 16)
        fileTitle.textAlignment = NSTextAlignment.left
        fileTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
        fileTitle.numberOfLines = 1
        fileTitle.backgroundColor = UIColor.clear
        //fileTitle.sizeToFit()
        cellView.addSubview(fileTitle)
        
        downloadTitle = createLabel(CGRect(x: 20, y: 60, width: cellView.frame.size.width-20, height: 40), text: "Max Downloads", alignment: .left, textColor: textColorDark)
        downloadTitle.font = UIFont(name: fontName, size: 16)
        downloadTitle.textAlignment = NSTextAlignment.left
        downloadTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
        downloadTitle.numberOfLines = 1
        downloadTitle.backgroundColor = UIColor.clear
        //downloadTitle.sizeToFit()
        cellView.addSubview(downloadTitle)
        
        extensionTitle = createLabel(CGRect(x: 20, y: 100, width: cellView.frame.size.width-20, height: 40), text: "File Extension", alignment: .left, textColor: textColorDark)
        extensionTitle.font = UIFont(name: fontName, size: 16)
        extensionTitle.textAlignment = NSTextAlignment.left
        extensionTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
        extensionTitle.numberOfLines = 1
        extensionTitle.backgroundColor = UIColor.clear
        //extensionTitle.sizeToFit()
        cellView.addSubview(extensionTitle)
        
        statusTtile = createLabel(CGRect(x: 20, y: 140, width: cellView.frame.size.width-20, height: 40), text: "Status", alignment: .left, textColor: textColorDark)
        statusTtile.font = UIFont(name: fontName, size: 16)
        statusTtile.textAlignment = NSTextAlignment.left
        statusTtile.lineBreakMode = NSLineBreakMode.byWordWrapping
        statusTtile.numberOfLines = 1
        statusTtile.backgroundColor = UIColor.clear
        //statusTtile.sizeToFit()
        cellView.addSubview(statusTtile)
        
        btnMenu = createButton(CGRect(x: cellView.frame.size.width/2-20, y: 180, width: 40, height: 40), title: "", border: false, bgColor: false, textColor: textColorMedium)
        btnMenu.setImage(UIImage(named: "blackoption"), for: UIControl.State())
        btnMenu.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZESmall)
        cellView.addSubview(btnMenu)
        
        lineView = createView(CGRect(x: 0,y: cellView.frame.size.height-1,width: cellView.frame.size.width,height: 1), borderColor: borderColorMedium, shadow: false)
        lineView.layer.borderWidth = 0.0
        lineView.backgroundColor = borderColorDark
        cellView.addSubview(lineView)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
