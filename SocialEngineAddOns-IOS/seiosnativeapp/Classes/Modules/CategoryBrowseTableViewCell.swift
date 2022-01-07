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
    
    //Variables for column 1
    var cellView: UIView!
    var categoryImageView : UIImageView!
    var bottomImageView : UIImageView!
    var categoryName : UILabel!
    var classifiedPrice : UILabel!
    var menu: UIButton!
    var contentSelection:UIButton!
    var borderView : UIView!
    
    //Variables for column 2
    var cellView1: UIView!
    var categoryImageView1 : UIImageView!
    var bottomImageView1 : UIImageView!
    var categoryName1 : UILabel!
    var classifiedPrice1 : UILabel!
    var menu1: UIButton!
    var contentSelection1:UIButton!
    var borderView1 : UIView!
    
    //Variables for column 3
    var cellView2: UIView!
    var categoryImageView2 : UIImageView!
    var bottomImageView2 : UIImageView!
    var categoryName2 : UILabel!
    var classifiedPrice2 : UILabel!
    var menu2: UIButton!
    var contentSelection2:UIButton!
    var borderView2 : UIView!
    
    //Variables for column 4, for ipad only
    var cellView3: UIView!
    var categoryImageView3 : UIImageView!
    var bottomImageView3 : UIImageView!
    var categoryName3 : UILabel!
    var classifiedPrice3 : UILabel!
    var menu3: UIButton!
    var contentSelection3:UIButton!
    var borderView3 : UIView!
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    
    // Initialize Variable for Comments Table Cell
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Configure the view for the selected state
        
        var size:CGFloat = 0;
        
        if(UIDevice.current.userInterfaceIdiom == .pad){
            size = (UIScreen.main.bounds.width - (5 * PADING))/3
        }else{
            size = (UIScreen.main.bounds.width - (2 * PADING))/3
        }
        
        // LHS
        if(UIDevice.current.userInterfaceIdiom == .pad){
            cellView = createView( CGRect(x: 2*PADING, y: 0, width: size - 2*PADING, height: 100), borderColor: borderColorMedium, shadow: false)
        }else{
            cellView = createView( CGRect(x: 2*PADING , y: 5, width: size - 2*PADING, height: 100), borderColor: borderColorMedium, shadow: false)
        }
        
        cellView.layer.shadowColor = shadowColor.cgColor
        cellView.layer.shadowOpacity = shadowOpacity
        cellView.layer.shadowRadius = shadowRadius
        cellView.layer.shadowOffset = shadowOffset
        cellView.backgroundColor = UIColor.clear
        cellView.isHidden = true
        self.addSubview(cellView)
        
        categoryImageView = createImageView(CGRect(x: cellView.bounds.width/2 - 15, y: cellView.bounds.height/4 - contentPADING, width: 30, height: 30), border: true)
        

        categoryImageView.contentMode = UIView.ContentMode.scaleAspectFit
        categoryImageView.layer.masksToBounds = true
        categoryImageView.isUserInteractionEnabled = true
        categoryImageView.backgroundColor = UIColor.clear //lightGray//navColor
        categoryImageView.layer.borderWidth = 1
        categoryImageView.layer.masksToBounds = false
        categoryImageView.layer.borderColor = UIColor.clear.cgColor
        categoryImageView.image = UIImage(named: "category_icon.png")
        //categoryImageView.layer.cornerRadius = categoryImageView.frame.height/2
        categoryImageView.clipsToBounds = true
        cellView.addSubview(categoryImageView)
        
        categoryName = createLabel(CGRect(x: 5, y: categoryImageView.frame.origin.y + categoryImageView.bounds.height + contentPADING, width: cellView.frame.size.width-10, height: 40), text: "", alignment: .left, textColor: UIColor.black)
        categoryName.numberOfLines = 0
        categoryName.font = UIFont(name: fontBold, size: FONTSIZESmall)
        categoryName.textAlignment = NSTextAlignment.center
        categoryName.isHidden = true
        categoryName.lineBreakMode = NSLineBreakMode.byWordWrapping
        cellView.addSubview(categoryName)
        
        contentSelection = createButton(CGRect(x: 0, y: 0, width: cellView.bounds.width, height: cellView.bounds.height), title: "", border: false,bgColor: false, textColor: UIColor.clear)
        contentSelection.layer.borderColor = UIColor.clear.cgColor
        contentSelection.backgroundColor = UIColor.clear
        
        cellView.addSubview(contentSelection)
        
        
        // Centre
        if(UIDevice.current.userInterfaceIdiom == .pad){
            cellView1 = createView( CGRect(x: (2 * PADING) + size  , y: 0, width: size - 2*PADING , height: 100), borderColor: borderColorMedium, shadow: false)
        }else{
            cellView1 = createView( CGRect(x: (2 * PADING) + size  , y: 5, width: size - 2*PADING , height: 100), borderColor: borderColorMedium, shadow: false)
        }
        
        cellView1.layer.shadowColor = shadowColor.cgColor
        cellView1.layer.shadowOpacity = shadowOpacity
        cellView1.layer.shadowRadius = shadowRadius
        cellView1.layer.shadowOffset = shadowOffset
        cellView1.backgroundColor = UIColor.clear
        cellView1.isHidden = true
        self.addSubview(cellView1)
        

        categoryImageView1 = createImageView(CGRect(x: cellView1.bounds.width/2 - 15, y: cellView1.bounds.height/4 - contentPADING, width: 30, height: 30), border: true)
        categoryImageView1.contentMode = UIView.ContentMode.scaleAspectFit
        categoryImageView1.layer.masksToBounds = true
        categoryImageView1.isUserInteractionEnabled = true
        categoryImageView1.image = UIImage(named: "category_icon.png")
        categoryImageView1.backgroundColor = UIColor.clear
        categoryImageView1.layer.borderWidth = 1
        categoryImageView1.layer.masksToBounds = false
        categoryImageView1.layer.borderColor = UIColor.clear.cgColor

        categoryImageView1.clipsToBounds = true
        cellView1.addSubview(categoryImageView1)
        
        categoryName1 = createLabel(CGRect(x: 5, y: categoryImageView1.frame.origin.y + categoryImageView1.bounds.height + contentPADING, width: cellView1.frame.size.width-10, height: 40), text: "", alignment: .left, textColor: UIColor.black)
        categoryName1.numberOfLines = 0
        categoryName1.font = UIFont(name: fontBold, size: FONTSIZESmall)
        categoryName1.textAlignment = NSTextAlignment.center
        categoryName1.isHidden = true
        categoryName1.lineBreakMode = NSLineBreakMode.byWordWrapping
        cellView1.addSubview(categoryName1)
        
        contentSelection1 = createButton(CGRect(x: 0, y: 0, width: cellView1.bounds.width, height: cellView1.bounds.height), title: "", border: false,bgColor: false, textColor: UIColor.clear)
        contentSelection1.backgroundColor = UIColor.clear
        contentSelection1.layer.borderColor = UIColor.clear.cgColor
        cellView1.addSubview(contentSelection1)
        
        
        // RHS
        if(UIDevice.current.userInterfaceIdiom == .pad){
            cellView2 = createView( CGRect(x: (2 * PADING) + (2 * size), y: 0, width: size - 2*PADING, height: 100), borderColor: borderColorMedium, shadow: false)
        }else{
            cellView2 = createView( CGRect(x: (2 * PADING) + (2 * size), y: 5, width: size - 2*PADING, height: 100), borderColor: borderColorMedium, shadow: false)
        }
        
        cellView2.layer.shadowColor = shadowColor.cgColor
        cellView2.layer.shadowOpacity = shadowOpacity
        cellView2.layer.shadowRadius = shadowRadius
        cellView2.layer.shadowOffset = shadowOffset
        cellView2.backgroundColor = UIColor.clear
        cellView2.isHidden = true
        self.addSubview(cellView2)
        
        
        categoryImageView2 = createImageView(CGRect(x: cellView2.bounds.width/2 - 15, y: cellView2.bounds.height/4 - contentPADING, width: 30, height: 30), border: true)
        
        categoryImageView2.contentMode = UIView.ContentMode.scaleAspectFit
        categoryImageView2.layer.masksToBounds = true
        categoryImageView2.isUserInteractionEnabled = true
        categoryImageView2.backgroundColor = UIColor.clear
        categoryImageView2.image = UIImage(named: "category_icon.png")
        categoryImageView2.layer.borderWidth = 1
        categoryImageView2.layer.masksToBounds = false
        categoryImageView2.layer.borderColor = UIColor.clear.cgColor

        categoryImageView2.clipsToBounds = true
        cellView2.addSubview(categoryImageView2)
        
        categoryName2 = createLabel(CGRect(x: 5, y: categoryImageView2.frame.origin.y + categoryImageView2.bounds.height + contentPADING, width: cellView1.frame.size.width-10, height: 40), text: "", alignment: .left, textColor: UIColor.black)
        categoryName2.numberOfLines = 0
        categoryName2.font = UIFont(name: fontBold, size: FONTSIZESmall)
        categoryName2.textAlignment = NSTextAlignment.center
        categoryName2.isHidden = true
        categoryName2.lineBreakMode = NSLineBreakMode.byWordWrapping
        cellView2.addSubview(categoryName2)
        
        contentSelection2 = createButton(CGRect(x: 0, y: 0, width: cellView2.bounds.width, height: cellView2.bounds.height), title: "", border: false, bgColor: false, textColor: UIColor.clear)
        contentSelection2.backgroundColor = UIColor.clear
        contentSelection2.layer.borderColor = UIColor.clear.cgColor
        cellView2.addSubview(contentSelection2)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
