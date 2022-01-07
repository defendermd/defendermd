//
//  orderReviewTableViewCell.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 31/08/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit

class OrderReviewTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ isSelected: Bool, animated: Bool) {
        super.setSelected(isSelected, animated: animated)
        
        // Configure the view for the isSelected state
    }
    
    // Define Variable for Custom Table Cell
    var labTitle : UILabel!
    var labPrice : UILabel!
    var labTax: UILabel!
    var labQuantity : UILabel!
    var labSubTotal : UILabel!
    var labPricevalue : UILabel!
    var labQuantityvalue : UILabel!
    var labTaxvalue: UILabel!
    var labSubTotalvalue : UILabel!
    var labSku : UILabel!
    var labSkuvalue : UILabel!
    var lineView: UIView!
    var profileFieldLabel : TTTAttributedLabel!
    
    // Initialize Variable for Custom Table Cell
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = UITableViewCell.SelectionStyle.blue
        
        // Title
        labTitle = createLabel(CGRect(x:10, y:5,width:(UIScreen.main.bounds.width - 20) , height:20), text: " ", alignment: .left, textColor: textColorDark)
        labTitle.numberOfLines = 0
        labTitle.lineBreakMode = NSLineBreakMode.byTruncatingTail
        labTitle.font = UIFont(name: fontName, size: FONTSIZELarge)
        self.addSubview(labTitle)
        
        labPrice = createLabel(CGRect(x:labTitle.frame.origin.x,y:labTitle.frame.origin.y+labTitle.frame.size.height+5,width:50, height:15), text: " ", alignment: .left, textColor: textColorDark)
        labPrice.numberOfLines = 0
        labPrice.lineBreakMode = NSLineBreakMode.byTruncatingTail
        labPrice.font = UIFont(name: fontName, size: FONTSIZENormal)
        self.addSubview(labPrice)
        
        
        labPricevalue = createLabel(CGRect(x:UIScreen.main.bounds.width-120,y:labTitle.frame.origin.y+labTitle.frame.size.height+5,width:110, height:15), text: " ", alignment: .left, textColor: textColorDark)
        labPricevalue.numberOfLines = 0
        labPricevalue.lineBreakMode = NSLineBreakMode.byTruncatingTail
        labPricevalue.font = UIFont(name: fontBold, size: FONTSIZENormal)
        labPricevalue.textAlignment = NSTextAlignment.right
        self.addSubview(labPricevalue)
        
        labQuantity = createLabel(CGRect(x:labTitle.frame.origin.x,y:labPrice.frame.origin.y+labPrice.frame.size.height+10,width:70,height:15), text: "2", alignment: .left, textColor: textColorDark)
        labQuantity.numberOfLines = 0
        labQuantity.lineBreakMode = NSLineBreakMode.byTruncatingTail
        labQuantity.font = UIFont(name: fontName, size: FONTSIZENormal)
        labQuantity.textAlignment = NSTextAlignment.left
        self.addSubview(labQuantity)
        
        
        labQuantityvalue = createLabel(CGRect(x:UIScreen.main.bounds.width-120,y:labPrice.frame.origin.y+labPrice.frame.size.height+10,width:110, height:15), text: " ", alignment: .left, textColor: textColorDark)
        labQuantityvalue.numberOfLines = 0
        labQuantityvalue.lineBreakMode = NSLineBreakMode.byTruncatingTail
        labQuantityvalue.font = UIFont(name: fontBold, size: FONTSIZENormal)
        labQuantityvalue.textAlignment = NSTextAlignment.right
        self.addSubview(labQuantityvalue)
        
        
        labSku = createLabel(CGRect(x:labTitle.frame.origin.x,y:labQuantityvalue.frame.origin.y+labQuantityvalue.frame.size.height+10,width:(UIScreen.main.bounds.width-20),height:15), text: "", alignment: .left, textColor: textColorDark)
        labSku.numberOfLines = 0
        labSku.lineBreakMode = NSLineBreakMode.byTruncatingTail
        labSku.font = UIFont(name: fontName, size: FONTSIZENormal)
        labSku.textAlignment = NSTextAlignment.left
        labSku.isHidden = true
        self.addSubview(labSku)
        
        
        labSkuvalue = createLabel(CGRect(x:UIScreen.main.bounds.width-120,y:labQuantityvalue.frame.origin.y+labQuantityvalue.frame.size.height+10,width:110, height:15), text: " ", alignment: .left, textColor: textColorDark)
        labSkuvalue.numberOfLines = 0
        labSkuvalue.lineBreakMode = NSLineBreakMode.byTruncatingTail
        labSkuvalue.font = UIFont(name: fontBold, size: FONTSIZENormal)
        labSkuvalue.textAlignment = NSTextAlignment.right
        labSkuvalue.isHidden = true
        self.addSubview(labSkuvalue)
        
        
        labSubTotal = createLabel(CGRect(x:labTitle.frame.origin.x,y:labQuantityvalue.frame.origin.y+labQuantityvalue.frame.size.height+10,width:(UIScreen.main.bounds.width-20),height:15), text: "", alignment: .left, textColor: textColorDark)
        labSubTotal.numberOfLines = 0
        labSubTotal.lineBreakMode = NSLineBreakMode.byTruncatingTail
        labSubTotal.font = UIFont(name: fontName, size: FONTSIZENormal)
        labSubTotal.textAlignment = NSTextAlignment.left
        self.addSubview(labSubTotal)
        
        
        labSubTotalvalue = createLabel(CGRect(x:UIScreen.main.bounds.width-120,y:labQuantityvalue.frame.origin.y+labQuantityvalue.frame.size.height+10,width:110, height:15), text: " ", alignment: .left, textColor: textColorDark)
        labSubTotalvalue.numberOfLines = 0
        labSubTotalvalue.lineBreakMode = NSLineBreakMode.byTruncatingTail
        labSubTotalvalue.font = UIFont(name: fontBold, size: FONTSIZENormal)
        labSubTotalvalue.textAlignment = NSTextAlignment.right
        self.addSubview(labSubTotalvalue)
        
        profileFieldLabel = TTTAttributedLabel(frame:CGRect(x:labTitle.frame.origin.x, y:labSubTotal.frame.origin.y + labSubTotal.bounds.height + 8 , width:UIScreen.main.bounds.width - 20 , height:0) )
        profileFieldLabel.numberOfLines = 0
        profileFieldLabel.textColor = textColorMedium
        profileFieldLabel.layer.borderColor = navColor.cgColor
        self.addSubview(profileFieldLabel)
        profileFieldLabel.isHidden = true
        
        lineView = UIView(frame: CGRect(x:0, y:profileFieldLabel.frame.size.height+profileFieldLabel.frame.origin.y+10,width:UIScreen.main.bounds.width, height:1))
        lineView.backgroundColor = aafBgColor
        self.addSubview(lineView)
        lineView.isHidden = false
        
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}
