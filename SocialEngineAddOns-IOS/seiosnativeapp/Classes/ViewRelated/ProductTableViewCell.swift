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

//
//  ClassifiedTableViewCell.swift
//  seiosnativeapp
//


import UIKit

class ProductTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var classifiedImageView : UIImageView!
    var bottomImageView : UIImageView!
    var classifiedName : UILabel!
    var actualPrice : UILabel!
    var discountedPrice : UILabel!
    var menu: UIButton!
    var contentSelection:UIButton!
    var borderView : UIView!
    var ratings : UIView!
    var ratings1 : UILabel!
    var descriptionView : UIView!
    
    var productImageView1 : UIImageView!
    var bottomImageView1 : UIImageView!
    var classifiedName1 : UILabel!
    var actualPrice1 : UILabel!
    var discountedPrice1 : UILabel!
    var menu1: UIButton!
    var contentSelection1:UIButton!
    var borderView1 : UIView!
    var descriptionView1 : UIView!
    
    //For featured and sponsored label
    var featuredLabel:UILabel!
    var sponsoredLabel:UILabel!
    var featuredLabel1:UILabel!
    var sponsoredLabel1:UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    override func prepareForReuse() {
        super.prepareForReuse()
       
    }
    
    // Initialize Variable for Comments Table Cell
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Configure the view for the selected state
        
        var size:CGFloat = 0;
        if(UIDevice.current.userInterfaceIdiom == .pad){
            size = (UIScreen.main.bounds.width - (5 * PADING))/3
        }else{
            size = (UIScreen.main.bounds.width - (4 * PADING))
        }
        
        size = (UIScreen.main.bounds.width - (2 * PADING))/2
        
        
        
        classifiedImageView = ProductsImageViewWithGradient(frame: CGRect(x:2*PADING , y:contentPADING, width:size - 2*PADING, height:150 - contentPADING))
        classifiedImageView.contentMode = UIView.ContentMode.scaleAspectFill
        classifiedImageView.layer.masksToBounds = true
        classifiedImageView.isUserInteractionEnabled = true
        classifiedImageView.backgroundColor = placeholderColor
        classifiedImageView.layer.shadowOpacity =  0.0
        self.addSubview(classifiedImageView)
        
        featuredLabel = createLabel(CGRect(x:0, y:0, width:70, height:20), text: "Featured", alignment: .center, textColor: textColorLight)
        featuredLabel.font = UIFont(name: fontName, size: FONTSIZEMedium)
        featuredLabel.backgroundColor = UIColor.init(red: 0, green: 176/255, blue: 182/255, alpha: 1)
        classifiedImageView.addSubview(featuredLabel)
        featuredLabel.isHidden = true
        
        sponsoredLabel = createLabel(CGRect(x:0, y:25, width:70, height:20), text: "Sponsored", alignment: .center, textColor: textColorLight)
        sponsoredLabel.font = UIFont(name: fontName, size: FONTSIZEMedium)
        sponsoredLabel.backgroundColor = UIColor.red
        classifiedImageView.addSubview(sponsoredLabel)
        sponsoredLabel.isHidden = true
     
        menu = createButton(CGRect(x:classifiedImageView.bounds.width - 20,y:0, width:20, height:20), title: "\u{f004}", border: false,bgColor: false, textColor: textColorLight )
        menu.titleLabel?.font = UIFont(name: "FontAwesome", size:15.0)
        menu.isHidden = true
        classifiedImageView.addSubview(menu)
        
        contentSelection = createButton(CGRect(x:0, y:35, width:classifiedImageView.bounds.width, height:classifiedImageView.bounds.height - 40), title: "", border: false,bgColor: false, textColor: UIColor.clear)
        classifiedImageView.addSubview(contentSelection)
        contentSelection.layer.borderWidth = 0.0
        
        
        descriptionView = createView(CGRect(x:2*PADING, y:150 ,width:size - 2*PADING ,height:90), borderColor: borderColorMedium, shadow: false)
         descriptionView.layer.borderWidth = 0.5
        self.addSubview(descriptionView)
        
        classifiedName = createLabel(CGRect(x:5,y:5, width:descriptionView.bounds.width-10, height:55), text: "", alignment: .left, textColor: textColorDark)
        classifiedName.numberOfLines = 2
        classifiedName.lineBreakMode = NSLineBreakMode.byWordWrapping
        classifiedName.font = UIFont(name: fontBold, size: FONTSIZENormal)
        classifiedName.textAlignment = .left
        descriptionView.addSubview(classifiedName)
        
        ratings = createView(CGRect(x:2 ,y:classifiedName.bounds.height, width:descriptionView.bounds.width, height:25), borderColor: UIColor.clear, shadow: false)
        ratings.backgroundColor = UIColor.clear
        descriptionView.addSubview(ratings)
        ratings.isHidden = true
        
        actualPrice = createLabel(CGRect(x:5 , y:ratings.frame.origin.y + ratings.bounds.height, width:70 , height:15), text: "", alignment: .left, textColor: textColorDark)
        actualPrice.numberOfLines = 1
        actualPrice.font = UIFont(name: fontName, size: FONTSIZESmall)
        descriptionView.addSubview(actualPrice)
        actualPrice.isHidden = true
    
        discountedPrice = createLabel(CGRect(x:actualPrice.frame.origin.x + actualPrice.bounds.width + 5 , y:ratings.frame.origin.y + ratings.bounds.height, width:70, height:15), text: "", alignment: .left, textColor: textColorDark)
        discountedPrice.numberOfLines = 1
        discountedPrice.font = UIFont(name: fontName, size: FONTSIZESmall)
        descriptionView.addSubview(discountedPrice)
        discountedPrice.isHidden = true
      
        productImageView1 = ProductsImageViewWithGradient(frame: CGRect(x:(2 * PADING) + size  , y:contentPADING, width:size - 2*PADING , height:150-contentPADING))
        productImageView1.contentMode = UIView.ContentMode.scaleAspectFill
        productImageView1.layer.masksToBounds = true
        productImageView1.isUserInteractionEnabled = true
        productImageView1.backgroundColor = placeholderColor
        productImageView1.layer.shadowOpacity =  0.0
        
        self.addSubview(productImageView1)
        
        //borderColorLight
        descriptionView1 = createView(CGRect(x:(2 * PADING) + size, y:150  ,width:size - 2*PADING ,height:90 ), borderColor: borderColorMedium , shadow: false)
        descriptionView1.layer.borderWidth = 0.5
        self.addSubview(descriptionView1)
        
        
        featuredLabel1 = createLabel(CGRect(x: 0, y: 12, width: 70, height: 20), text: "Featured", alignment: .center, textColor: textColorLight)
        featuredLabel1.font = UIFont(name: fontName, size: FONTSIZEMedium)
        featuredLabel1.backgroundColor = UIColor.init(red: 0, green: 176/255, blue: 182/255, alpha: 1)
        productImageView1.addSubview(featuredLabel1)
        featuredLabel1.isHidden = true
        
        sponsoredLabel1 = createLabel(CGRect(x:0, y:25, width:70, height:20), text: "Sponsored", alignment: .center, textColor: textColorLight)
        sponsoredLabel1.font = UIFont(name: fontName, size: FONTSIZEMedium)
        sponsoredLabel1.backgroundColor = UIColor.red
        productImageView1.addSubview(sponsoredLabel1)
        sponsoredLabel1.isHidden = true
        
        menu1 = createButton(CGRect(x:productImageView1.bounds.width - 20,y:0, width:20, height:20), title: "\u{f004}", border: false,bgColor: false, textColor: textColorLight )
        menu1.titleLabel?.font =  UIFont(name: "FontAwesome", size:15.0)
        menu1.isHidden = true
        productImageView1.addSubview(menu1)
        
        
        classifiedName1 = createLabel(CGRect(x:5,y:5, width:descriptionView1.bounds.width-5,height:55), text: "", alignment: .left, textColor: textColorDark)
        classifiedName1.lineBreakMode = NSLineBreakMode.byWordWrapping
        classifiedName1.numberOfLines = 2
        classifiedName1.text = "Classified"
        
        
        classifiedName1.font = UIFont(name: fontBold, size: FONTSIZENormal)
        descriptionView1.addSubview(classifiedName1)
        
        ratings1 = createLabel(CGRect(x:2 , y:classifiedName1.bounds.height, width:descriptionView1.bounds.width, height:25), text: "", alignment: .left, textColor: textColorDark)
        ratings1.numberOfLines = 0
        ratings1.font = UIFont(name: fontName, size: FONTSIZESmall)
        descriptionView1.addSubview(ratings1)
        ratings1.isHidden = true
        
        actualPrice1 = createLabel(CGRect(x:5 , y:ratings1.frame.origin.y + ratings1.bounds.height, width:70, height:15), text: "", alignment: .left, textColor: textColorDark)
        actualPrice1.numberOfLines = 1
        actualPrice1.font = UIFont(name: fontName, size: FONTSIZESmall)
        descriptionView1.addSubview(actualPrice1)
        actualPrice1.isHidden = true
       
        discountedPrice1 = createLabel(CGRect(x:actualPrice1.frame.origin.x + actualPrice1.bounds.width + 5 , y:ratings1.frame.origin.y + ratings1.bounds.height, width:70, height:15), text: "", alignment: .left, textColor: textColorDark)
        discountedPrice1.numberOfLines = 1
        discountedPrice1.font = UIFont(name: fontName, size: FONTSIZESmall)
        descriptionView1.addSubview(discountedPrice1)
        discountedPrice1.isHidden = true
        
        contentSelection1 = createButton(CGRect(x:0, y:35, width:productImageView1.bounds.width, height:productImageView1.bounds.height - 40), title: "", border: false,bgColor: false, textColor: UIColor.clear)
        contentSelection1.layer.borderWidth = 0.0
        productImageView1.addSubview(contentSelection1)
        
    }
    
    func updateRating(rating:Int, ratingCount:Int)
    {
        
        for ob in ratings.subviews
        {
            ob.removeFromSuperview()
        }
        
        var origin_x = 0 as CGFloat
        for i in stride(from: 1, through: 5, by: 1)
        {
            let rate = createButton(CGRect(x:origin_x, y:2, width:15, height:15), title: "", border: false, bgColor: false, textColor: textColorLight)
            rate.backgroundColor = UIColor.clear
            rate.setImage(UIImage(named: "graystar.png"), for: .normal )
            
            
            if i <= rating
            {
                rate.setImage(UIImage(named: "yellowStar.png"), for: .normal )
            }
            
            
            origin_x += 15
            ratings.addSubview(rate)
        }
        
    }
    func updateRating1(rating:Int, ratingCount:Int)
    {
        
        for ob in ratings1.subviews
        {
            ob.removeFromSuperview()
        }
        
        var origin_x = 0 as CGFloat
        for i in stride(from: 1, through: 5, by: 1){
            let rate = createButton(CGRect(x:origin_x,y:2 , width:15, height:15), title: "", border: false, bgColor: false, textColor: textColorLight)
            rate.backgroundColor = UIColor.clear
            rate.setImage(UIImage(named: "graystar.png"), for: .normal )
            
            
            if i <= rating
                
            {
                rate.setImage(UIImage(named: "yellowStar.png"), for: .normal )
            }
            
            origin_x += 15
            ratings1.addSubview(rate)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
