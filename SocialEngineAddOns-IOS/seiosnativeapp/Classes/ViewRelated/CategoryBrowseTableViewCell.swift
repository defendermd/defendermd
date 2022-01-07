//
//  CategoryTableViewCell.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 07/03/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit

class CategoryBrowseTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var cellView: UIView!
    var categoryImageView : UIImageView!
    var bottomImageView : UIImageView!
    var categoryName : UILabel!
    var classifiedPrice : UILabel!
    var menu: UIButton!
    var contentSelection:UIButton!
    var borderView : UIView!
    var MusicPlays : UILabel!
    var MusicPlays1 : UILabel!
    
    var cellView1: UIView!
    var categoryImageView1 : UIImageView!
    var bottomImageView1 : UIImageView!
    var categoryName1 : UILabel!
    var classifiedPrice1 : UILabel!
    var menu1: UIButton!
    var contentSelection1:UIButton!
    var borderView1 : UIView!
    
    
    
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    
    // Initialize Variable for Comments Table Cell
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Configure the view for the selected state
        
        var size:CGFloat = 0;

        size = (CGRectGetWidth(UIScreen.mainScreen().bounds) - (2 * PADING))/2
        
        // LHS
        if(UIDevice.currentDevice().userInterfaceIdiom == .Pad){
            cellView = createView( CGRectMake(PADING, 0 ,(CGRectGetWidth(UIScreen.mainScreen().bounds)/2 - 2*PADING) , 230), borderColor: borderColorMedium, shadow: false)
        }else{
            cellView = createView( CGRectMake(2*PADING , 0, size - 2*PADING, 155), borderColor: borderColorMedium, shadow: false)
        }
        
        cellView.layer.shadowColor = shadowColor.CGColor
        cellView.layer.shadowOpacity = shadowOpacity
        cellView.layer.shadowRadius = shadowRadius
        cellView.layer.shadowOffset = shadowOffset
        cellView.backgroundColor = UIColor.clearColor()
        cellView.hidden = true
        self.addSubview(cellView)
        
        
        categoryImageView = createImageView(CGRectMake(CGRectGetWidth(cellView.bounds)/4 , CGRectGetHeight(cellView.bounds)/4, CGRectGetWidth(cellView.bounds)/2, CGRectGetHeight(cellView.bounds)/2), border: true)
        
        categoryImageView.contentMode = UIViewContentMode.ScaleAspectFit
        categoryImageView.layer.masksToBounds = true
        categoryImageView.userInteractionEnabled = true
        categoryImageView.backgroundColor = UIColor.lightGrayColor()//navColor
        categoryImageView.layer.borderWidth = 1
        categoryImageView.layer.masksToBounds = false
        categoryImageView.layer.borderColor = UIColor.clearColor().CGColor
        categoryImageView.layer.cornerRadius = categoryImageView.frame.height/2
        categoryImageView.clipsToBounds = true
        
        cellView.addSubview(categoryImageView)
        
        contentSelection = createButton(CGRectMake(0, 0, CGRectGetWidth(cellView.bounds), CGRectGetHeight(cellView.bounds)), title: "", border: false,bgColor: false, textColor: UIColor.clearColor())
        contentSelection.backgroundColor = UIColor.clearColor()
        cellView.addSubview(contentSelection)
        
        categoryName = createLabel(CGRectMake(5, categoryImageView.frame.origin.y + CGRectGetHeight(categoryImageView.bounds) + contentPADING, cellView.frame.size.width-10, CGRectGetHeight(categoryImageView.bounds)/4 - contentPADING), text: "", alignment: .Left, textColor: UIColor.blackColor())
        categoryName.numberOfLines = 0
        categoryName.font = UIFont(name: fontBold, size: FONTSIZENormal)
        categoryName.textAlignment = NSTextAlignment.Center
        categoryName.hidden = true
        categoryName.lineBreakMode = NSLineBreakMode.ByWordWrapping
        cellView.addSubview(categoryName)
        
        
        // LHS
        if(UIDevice.currentDevice().userInterfaceIdiom == .Pad){
            cellView1 = createView( CGRectMake(PADING, 0 ,(CGRectGetWidth(UIScreen.mainScreen().bounds)/2 - 2*PADING) , 230), borderColor: borderColorMedium, shadow: false)
        }else{
            cellView1 = createView( CGRectMake((2 * PADING) + size  , 0, size - 2*PADING , 155), borderColor: borderColorMedium, shadow: false)
        }
        
        cellView1.layer.shadowColor = shadowColor.CGColor
        cellView1.layer.shadowOpacity = shadowOpacity
        cellView1.layer.shadowRadius = shadowRadius
        cellView1.layer.shadowOffset = shadowOffset
        cellView1.backgroundColor = UIColor.clearColor()
        cellView1.hidden = true
        self.addSubview(cellView1)
        
        categoryImageView1 = createImageView(CGRectMake(CGRectGetWidth(cellView1.bounds)/4, CGRectGetHeight(cellView1.bounds)/4, CGRectGetWidth(cellView1.bounds)/2, CGRectGetHeight(cellView1.bounds)/2), border: true)
        categoryImageView1.contentMode = UIViewContentMode.ScaleAspectFit
        categoryImageView1.layer.masksToBounds = true
        categoryImageView1.userInteractionEnabled = true
        categoryImageView1.backgroundColor = UIColor.lightGrayColor()//navColor
        categoryImageView1.layer.borderWidth = 1
        categoryImageView1.layer.masksToBounds = false
        categoryImageView1.layer.borderColor = UIColor.clearColor().CGColor
        categoryImageView1.layer.cornerRadius = categoryImageView1.frame.height/2
        categoryImageView1.clipsToBounds = true
        
        cellView1.addSubview(categoryImageView1)
        
        categoryName1 = createLabel(CGRectMake(5, categoryImageView1.frame.origin.y + CGRectGetHeight(categoryImageView1.bounds) + contentPADING, cellView1.frame.size.width-10, CGRectGetHeight(categoryImageView1.bounds)/4 - contentPADING), text: "", alignment: .Left, textColor: UIColor.blackColor())
        categoryName1.numberOfLines = 0
        categoryName1.font = UIFont(name: fontBold, size: FONTSIZENormal)
        categoryName1.textAlignment = NSTextAlignment.Center
        categoryName1.hidden = true
        categoryName1.lineBreakMode = NSLineBreakMode.ByWordWrapping
        cellView1.addSubview(categoryName1)
        
        contentSelection1 = createButton(CGRectMake(0, 0, CGRectGetWidth(cellView.bounds), CGRectGetHeight(cellView.bounds)), title: "", border: false,bgColor: false, textColor: UIColor.clearColor())
        contentSelection1.backgroundColor = UIColor.clearColor()
        cellView1.addSubview(contentSelection1)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
