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

//  RepeatEventTableViewCell.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 18/02/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit

class RepeatEventTableViewCell: UITableViewCell
{
    var cellView:UIView!
    var DateView:UIView!
    var lbldate:UILabel!
    var btnguest:UIButton!
    var btnRSVP:UIButton!
    var filterIcon:UILabel!
    var btnmenu:UIButton!
    var lineView:UIView!
    var lblnoguest:UILabel!
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
    }
    // Initialize Variable for Comments Table Cell
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        cellView = createView( CGRect(x: 0, y: 0,width: (UIScreen.main.bounds.width) , height: 100), borderColor: borderColorMedium, shadow: false)
        cellView.layer.borderWidth = 0.0
        self.addSubview(cellView)
        cellView.backgroundColor = UIColor.clear
        cellView.isUserInteractionEnabled = true
        
        
        DateView = createView( CGRect(x: 10, y: 20,width: 60,height: 60), borderColor: borderColorMedium, shadow: false)
        DateView.layer.borderWidth = 0.0
        DateView.backgroundColor = navColor
        cellView.addSubview(DateView)
        
        lbldate = createLabel(CGRect(x: 10, y: 10, width: 40, height: 40), text: "25 Feb", alignment: .left, textColor: textColorDark)
        lbldate.font = UIFont(name: fontName, size: 16)
        lbldate.textAlignment = NSTextAlignment.center
        lbldate.numberOfLines = 0
        lbldate.backgroundColor = UIColor.clear
        DateView.addSubview(lbldate)
        
        
        
        btnguest = createButton(CGRect(x: DateView.frame.origin.x+DateView.frame.size.width+30,y: DateView.frame.origin.y,width: 130,height: 20), title: "", border: false,bgColor: false, textColor: textColorDark)
        
        btnguest.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium)
        btnguest.backgroundColor = UIColor.clear
        cellView.addSubview(btnguest)
        
        
        lblnoguest = createLabel(CGRect(x: DateView.frame.origin.x+DateView.frame.size.width+30,y: btnguest.frame.origin.y+btnguest.frame.size.height/2,width: 200,height: 30), text: "No guest has joined this occurrence yet.", alignment: .left, textColor: textColorDark)
        lblnoguest.font = UIFont(name: fontName, size: FONTSIZEMedium)
        lblnoguest.textAlignment = NSTextAlignment.center
        lblnoguest.numberOfLines = 0
        lblnoguest.backgroundColor = UIColor.clear
        lblnoguest.sizeToFit()
        lblnoguest.isHidden = true
        cellView.addSubview(lblnoguest)

        

        // Create a See All Filter to perform  Filtering
        btnRSVP = createButton(CGRect(x: DateView.frame.origin.x+DateView.frame.size.width+30,y: btnguest.frame.origin.y+btnguest.frame.size.height+10,width: 150,height: 30),title: NSLocalizedString("Attending",  comment: "") , border: false, bgColor: false,textColor: textColorLight)
        btnRSVP.isEnabled = true
        btnRSVP.backgroundColor = navColor//lightBgColor
        btnRSVP.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
        btnRSVP.titleLabel!.numberOfLines = 1;
        btnRSVP.titleLabel!.adjustsFontSizeToFitWidth = true;
        
        cellView.addSubview(btnRSVP)
        
        
        // Filter Icon on Left site
        let filterIcon = createLabel(CGRect(x: btnRSVP.bounds.width - btnRSVP.bounds.height, y: 0 ,width: btnRSVP.bounds.height ,height: btnRSVP.bounds.height), text: "\u{f107}", alignment: .center, textColor: textColorLight)
        filterIcon.font = UIFont(name: "fontAwesome", size: FONTSIZELarge)
        btnRSVP.addSubview(filterIcon)
        
        
        btnmenu = createButton(CGRect(x: cellView.frame.size.width-50,y: DateView.frame.origin.y,width: 30,height: 30), title: "", border: false,bgColor: false, textColor: textColorDark)
        btnmenu.setImage(UIImage(named: "blackoption"), for: UIControl.State())
        btnmenu.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZESmall)
        //btnmenu.backgroundColor = UIColor.red
        cellView.addSubview(btnmenu)
        
        lineView = createView(CGRect(x: 0,y: 99,width: cellView.frame.size.width,height: 1), borderColor: borderColorMedium, shadow: false)
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
