//
//  ManageCartCell.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 23/08/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit

class ManageCartCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ isSelected: Bool, animated: Bool) {
        super.setSelected(isSelected, animated: animated)
        
        // Configure the view for the isSelected state
    }
    
    // Define Variable for Custom Table Cell
    var imgUser:UIImageView!
    var labTitle : UILabel!
    var errorLabel : UILabel!
    var labPrice : UILabel!
    var labSubTotal : UILabel!
    
    var lineView: UIView!
    var lineView1: UIView!
    var btnMinus:UIButton!
    var btnPlus :UIButton!
    var labQuantity : UILabel!
    var profileFieldLabel : TTTAttributedLabel!
    
    // Initialize Variable for Custom Table Cell
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = UITableViewCell.SelectionStyle.blue
        
        errorLabel = createLabel(CGRect(x:10,y:5,width:UIScreen.main.bounds.width-20,height:10), text: "", alignment: .left, textColor: UIColor.red)
        errorLabel.numberOfLines = 0
        errorLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
        errorLabel.font = UIFont(name: fontName, size: 9)
        self.addSubview(errorLabel)
        // Icon Size
        
        imgUser = createImageView(CGRect(x:5, y:20, width:50, height:50), border: true)
        imgUser.image = UIImage(named: "user_profile_image.png")
        imgUser.layer.masksToBounds = true
        self.addSubview(imgUser)
        
        // Title
        labTitle = createLabel(CGRect(x:imgUser.bounds.width + 10, y:20,width:(UIScreen.main.bounds.width - (imgUser.bounds.width + 15)) , height:20), text: " ", alignment: .left, textColor: textColorDark)
        labTitle.numberOfLines = 0
        labTitle.lineBreakMode = NSLineBreakMode.byTruncatingTail
        labTitle.font = UIFont(name: fontName, size: FONTSIZELarge)
        
        self.addSubview(labTitle)
        
        labPrice = createLabel(CGRect(x:labTitle.frame.origin.x,y:labTitle.frame.origin.y+labTitle.frame.size.height+5,width:80 , height:20), text: " ", alignment: .left, textColor: textColorMedium)
        labPrice.numberOfLines = 0
        labPrice.lineBreakMode = NSLineBreakMode.byTruncatingTail
        labPrice.font = UIFont(name: fontName, size: FONTSIZENormal)
        self.addSubview(labPrice)
        
        
        btnMinus = createButton(CGRect(x:labPrice.frame.origin.x+labPrice.frame.size.width+10, y:labTitle.frame.origin.y+labTitle.frame.size.height+5, width:20 , height:20), title: "-", border: false, bgColor: false, textColor: textColorMedium)
        
        btnMinus.titleLabel?.font =  UIFont(name: fontName, size:FONTSIZEExtraLarge)
        btnMinus.layer.cornerRadius = 0.5 * btnMinus.bounds.size.width
        btnMinus.layer.borderWidth = 1
        btnMinus.layer.borderColor = textColorMedium.cgColor
        btnMinus.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
        self.addSubview(btnMinus)
        
        labQuantity = createLabel(CGRect(x:btnMinus.frame.origin.x+btnMinus.frame.size.width,y:btnMinus.frame.origin.y+3,width:25,height:15), text: "2", alignment: .left, textColor: textColorMedium)
        labQuantity.numberOfLines = 0
        labQuantity.lineBreakMode = NSLineBreakMode.byTruncatingTail
        labQuantity.font = UIFont(name: fontName, size: FONTSIZENormal)
        labQuantity.textAlignment = NSTextAlignment.center
        self.addSubview(labQuantity)
        
        btnPlus = createButton(CGRect(x:labQuantity.frame.origin.x+labQuantity.frame.size.width, y:labTitle.frame.origin.y+labTitle.frame.size.height+5, width:20 , height:20), title: "+", border: false, bgColor: false, textColor: textColorMedium)
        btnPlus.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
        btnPlus.titleLabel?.font =  UIFont(name: fontName, size:FONTSIZEExtraLarge)
        btnPlus.layer.cornerRadius = 0.5 * btnMinus.bounds.size.width
        btnPlus.layer.borderWidth = 1
        btnPlus.layer.borderColor = textColorMedium.cgColor
        btnPlus.titleEdgeInsets = UIEdgeInsets(top: -5,left: 0,bottom: 0,right: 0)
        self.addSubview(btnPlus)
        
        labSubTotal = createLabel(CGRect(x:btnPlus.frame.origin.x+btnPlus.frame.size.width+5,y:btnMinus.frame.origin.y+3,width:(UIScreen.main.bounds.width-(btnPlus.frame.origin.x+btnPlus.frame.size.width+10)),height:15), text: "", alignment: .left, textColor: textColorMedium)
        labSubTotal.numberOfLines = 0
        labSubTotal.lineBreakMode = NSLineBreakMode.byTruncatingTail
        labSubTotal.font = UIFont(name: fontName, size: FONTSIZENormal)
        labSubTotal.textAlignment = NSTextAlignment.right
        self.addSubview(labSubTotal)
        
        
        profileFieldLabel = TTTAttributedLabel(frame:CGRect(x:imgUser.bounds.width + 10, y:btnPlus.frame.origin.y + btnPlus.bounds.height + 8  , width:UIScreen.main.bounds.width - (imgUser.bounds.width+10) , height:0) )
        profileFieldLabel.numberOfLines = 0
        profileFieldLabel.textColor = textColorMedium
        profileFieldLabel.layer.borderColor = navColor.cgColor
        //profileFieldLabel.delegate = self
        self.addSubview(profileFieldLabel)
        profileFieldLabel.isHidden = true
        
        lineView = UIView(frame: CGRect(x:0, y:imgUser.frame.size.height+imgUser.frame.origin.y+10,width:(UIScreen.main.bounds).width, height:1))
        lineView.backgroundColor = aafBgColor
        self.addSubview(lineView)
        lineView.isHidden = false
        
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
