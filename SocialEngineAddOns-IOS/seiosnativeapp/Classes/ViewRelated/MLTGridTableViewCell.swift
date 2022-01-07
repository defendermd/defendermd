
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

import UIKit

// This Class is used in MLT Browse view

class MLTGridTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    var cellView: UIView!
    var contentImage:UIImageView!
    var contentName:UILabel!
    var totalMembers: UILabel!
    var createdBy: TTTAttributedLabel!
    var menu: UIButton!
    var eventTime :UILabel!
    var contentSelection:UIButton!
    var dateView : UIView!
    var titleView : UIView!
    var titleLabel : UILabel!
    var locLabel : UILabel!
    var dateLabel : UILabel!
    var dateLabel1 : UILabel!
    var menuButton: UIButton!
    var lineView : UIView!
    
    var cellView2: UIView!
    var contentImage2:UIImageView!
    var contentName2:UILabel!
    var totalMembers2: UILabel!
    var createdBy2: TTTAttributedLabel!
    var menu2: UIButton!
    var eventTime2 :UILabel!
    var contentSelection2:UIButton!
    var dateView2 : UIView!
    var titleView2 : UIView!
    var titleLabel2 : UILabel!
    var locLabel2 : UILabel!
    var dateLabel2 : UILabel!
    var dateLabel3 : UILabel!
    var menuButton2 : UIButton!
    var lineView2 : UIView!
    
    //VARIABLE FOR MLT PLUGIN
    var listingPriceTagLabel: UILabel!
    var listingDetailsLabel :UILabel!
    var listingDetailsLabel2 : UILabel!
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    
    // Initialize Variable for Comments Table Cell
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Configure the view for the selected state
        
        // LHS
        if(UIDevice.currentDevice().userInterfaceIdiom == .Pad){
            cellView = createView( CGRectMake(0, 0,(CGRectGetWidth(UIScreen.mainScreen().bounds)/2) , 250), borderColor: borderColorMedium, shadow: false)
        }else{
            cellView = createView( CGRectMake(0, 0,(CGRectGetWidth(UIScreen.mainScreen().bounds)) , 250), borderColor: borderColorMedium, shadow: false)
        }
        
        
        cellView.layer.borderWidth = 0.0
        self.addSubview(cellView)
        
        dateView = UIView( frame: CGRectMake(0, 180,70 , 70))
        dateView.backgroundColor = navColor
        self.addSubview(dateView)
        
        titleView = UIView( frame: CGRectMake(70, 180,CGRectGetWidth((cellView.bounds)) - 70 , 70))
        titleView.backgroundColor = UIColor.whiteColor()
        self.addSubview(titleView)
        
        
        titleLabel = createLabel(CGRectMake(10, 5, 100, 30), text: "", alignment: .Left, textColor: textColorDark)
        titleLabel.font = UIFont(name: fontName, size: 16)
        titleView.addSubview(titleLabel)
        locLabel = createLabel(CGRectMake(10, 30, 100, 30), text: "", alignment: .Left, textColor: textColorMedium)
        locLabel.font = UIFont(name: fontName, size: 12)
        titleView.addSubview(locLabel)
        dateLabel = createLabel(CGRectMake(10, 50, 100, 30), text: "", alignment: .Left, textColor: textColorMedium)
        dateLabel.font = UIFont(name: fontName, size: 12)
        titleView.addSubview(dateLabel)
        
        
        //WORK FOR MLT PLUGIN
        
        listingPriceTagLabel = createLabel(CGRectMake(10, 110, 10, 20), text: "", alignment: .Left, textColor: textColorMedium)
        listingPriceTagLabel.hidden = true
        cellView.addSubview(listingPriceTagLabel)
        
        listingDetailsLabel = createLabel(CGRectMake(10, 70, 100, 30), text: "", alignment: .Left, textColor: textColorMedium)
        listingDetailsLabel.font = UIFont(name: "FontAwesome", size: 12)
        listingDetailsLabel.hidden = true
        titleView.addSubview(listingDetailsLabel)
        
        dateLabel1 = createLabel(CGRectMake(20, 10, 50, 60), text: "", alignment: .Center, textColor: textColorMedium)
        dateLabel1.font = UIFont(name: fontName, size: 16)
        dateView.addSubview(dateLabel1)
        
        lineView = UIView(frame: CGRectMake(0,250,CGRectGetWidth((UIScreen.mainScreen().bounds)),5))
        lineView.backgroundColor = tableViewBgColor
        self.addSubview(lineView)
        lineView.hidden = true
        
        
        menuButton = createButton(CGRectMake(CGRectGetWidth(titleView.bounds)-40, 5, 30, 40), title: "\u{f141}", border: false,bgColor: false,textColor: textColorMedium)
        menuButton.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZEExtraLarge)
        titleView.addSubview(menuButton)
        menuButton.hidden = true
        
        contentImage = ContentImageViewWithGradient(frame: CGRectMake(0, 0, CGRectGetWidth(cellView.bounds), 190))
        contentImage.layer.masksToBounds = true
        contentImage.contentMode = UIViewContentMode.ScaleAspectFill
        contentImage.backgroundColor = navColor
        contentImage.layer.shadowColor = shadowColor.CGColor
        contentImage.layer.shadowOpacity = shadowOpacity
        contentImage.layer.shadowRadius = shadowRadius
        contentImage.layer.shadowOffset = shadowOffset
        cellView.addSubview(contentImage)
        
        // Set
        contentName = createLabel(CGRectMake(10, 110, (CGRectGetWidth(contentImage.bounds)-20), 100), text: "", alignment: .Left, textColor: textColorLight)
        //        contentName.layer.shadowColor = UIColor.lightGrayColor().CGColor
        //        contentName.layer.shadowOpacity = 1.0
        //        contentName.layer.shadowRadius = 4.0
        contentName.numberOfLines = 0
        contentName.font = UIFont(name: fontBold, size: FONTSIZEExtraLarge)
        contentName.layer.shadowColor = shadowColor.CGColor
        contentName.layer.shadowOpacity = shadowOpacity
        contentName.layer.shadowRadius = shadowRadius
        contentName.layer.shadowOffset = shadowOffset
        cellView.addSubview(contentName)
        
        
        totalMembers = createLabel(CGRectMake(10, 150, 100, 40), text: "", alignment: .Left, textColor: textColorDark)
        totalMembers.font = UIFont(name: fontName, size: 12)
        cellView.addSubview(totalMembers)
        
        createdBy = TTTAttributedLabel(frame: CGRectMake(120, 150, CGRectGetWidth(contentImage.bounds)-120, 40))
        createdBy.textAlignment = .Right
        createdBy.textColor = textColorLight
        //        createdBy.layer.shadowColor = shadowColor.CGColor
        //        createdBy.layer.shadowOpacity = shadowOpacity
        //        createdBy.layer.shadowRadius = shadowRadius
        //        createdBy.layer.shadowOffset = shadowOffset
        createdBy.font = UIFont(name: fontName, size: FONTSIZESmall)
        cellView.addSubview(createdBy)
        
        eventTime = createLabel(CGRectMake(50, 152, CGRectGetWidth(contentImage.bounds)-150, 20), text: "", alignment: .Center, textColor: textColorDark)
        eventTime.font = UIFont(name: fontBold, size: FONTSIZEMedium)
        eventTime.textColor = UIColor.redColor()
        cellView.addSubview(eventTime)
        
        menu = createButton(CGRectMake(CGRectGetWidth(contentImage.bounds)-30, 210, 30, 40), title: "\u{f141}", border: false,bgColor: false,textColor: textColorLight)
        menu.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZELarge)
        cellView.addSubview(menu)
        menu.hidden = true
        contentSelection = createButton(cellView.frame, title: "", border: false,bgColor: false, textColor: textColorLight)
        contentSelection.frame.size.height = (cellView.frame.size.height-40)
        self.addSubview(contentSelection)
        
        
        if(UIDevice.currentDevice().userInterfaceIdiom == .Pad){
            // RHS
            cellView2 = createView( CGRectMake((CGRectGetWidth(UIScreen.mainScreen().bounds)/2), 0,(CGRectGetWidth(UIScreen.mainScreen().bounds)/2) , 250), borderColor: borderColorMedium, shadow: false)
            cellView2.layer.borderWidth = 0.0
            self.addSubview(cellView2)
            dateView2 = UIView( frame: CGRectMake((CGRectGetWidth(UIScreen.mainScreen().bounds)/2), 180,70 , 70))
            dateView2.backgroundColor = navColor
            self.addSubview(dateView2)
            
            titleView2 = UIView( frame: CGRectMake((CGRectGetWidth(UIScreen.mainScreen().bounds)) / 2 + 70, 180,CGRectGetWidth((UIScreen.mainScreen().bounds)) / 2 - 70 , 70))
            titleView2.backgroundColor = textColorLight
            self.addSubview(titleView2)
            
            
            titleLabel2 = createLabel(CGRectMake(10, 5, 100, 30), text: "", alignment: .Left, textColor: textColorDark)
            titleLabel2.font = UIFont(name: fontName, size: 16)
            titleView2.addSubview(titleLabel2)
            
            locLabel2 = createLabel(CGRectMake(10, 30, 100, 30), text: "", alignment: .Left, textColor: textColorMedium)
            locLabel2.font = UIFont(name: fontName, size: 12)
            titleView2.addSubview(locLabel2)
            
            dateLabel2 = createLabel(CGRectMake(10, 50, 100, 30), text: "", alignment: .Left, textColor: textColorMedium)
            dateLabel2.font = UIFont(name: fontName, size: 12)
            titleView2.addSubview(dateLabel2)
            
            listingDetailsLabel2 = createLabel(CGRectMake(10, 70, 100, 30), text: "", alignment: .Left, textColor: textColorMedium)
            listingDetailsLabel2.font = UIFont(name: "FontAwesome", size: 12)
            listingDetailsLabel2.hidden = true
            titleView2.addSubview(listingDetailsLabel2)
            
            dateLabel3 = createLabel(CGRectMake(20, 10, 50, 60), text: "", alignment: .Center, textColor: textColorMedium)
            dateLabel3.font = UIFont(name: fontName, size: 16)
            dateView2.addSubview(dateLabel3)
            
            menuButton2 = createButton(CGRectMake(CGRectGetWidth(titleView2.bounds)-40, 0, 30, 40), title: "\u{f141}", border: false,bgColor: false,textColor: textColorMedium)
            menuButton2.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZEExtraLarge)
            titleView2.addSubview(menuButton2)
            menuButton2.hidden = true
            
            lineView2 = UIView(frame: CGRectMake(0,250,CGRectGetWidth((UIScreen.mainScreen().bounds))/2,5))
            //lineView.layer.borderWidth = 7.0
            //lineView.layer.borderColor = UIColor.whiteColor().CGColor
            lineView2.backgroundColor = UIColor.whiteColor()
            self.addSubview(lineView2)
            lineView2.hidden = true
            
            
            contentImage2 = ContentImageViewWithGradient(frame: CGRectMake(0, 0, CGRectGetWidth(cellView.bounds), 190))
            contentImage2.layer.masksToBounds = true
            contentImage2.backgroundColor = navColor
            contentImage2.layer.shadowColor = shadowColor.CGColor
            contentImage2.layer.shadowOffset = CGSizeMake(0,5);
            contentImage2.layer.shadowOpacity = 0.5;
            contentImage2.contentMode = UIViewContentMode.ScaleAspectFill
            cellView2.addSubview(contentImage2)
            
            contentName2 = createLabel(CGRectMake(10, 110, (CGRectGetWidth(contentImage.bounds)-20), 100), text: "", alignment: .Left, textColor: textColorLight)
            //        contentName2.layer.shadowColor = UIColor.lightGrayColor().CGColor
            //        contentName2.layer.shadowOpacity = 1.0
            //        contentName2.layer.shadowRadius = 4.0
            contentName2.numberOfLines = 0
            contentName2.layer.shadowColor = shadowColor.CGColor
            contentName2.layer.shadowOpacity = 0.2
            contentName2.layer.shadowRadius = shadowRadius
            contentName2.layer.shadowOffset = shadowOffset
            contentName2.font = UIFont(name: fontBold, size: FONTSIZEMedium)
            cellView2.addSubview(contentName2)
            
            totalMembers2 = createLabel(CGRectMake(10, 150, 100, 40), text: "", alignment: .Left, textColor: textColorDark)
            totalMembers2.font = UIFont(name: fontName, size: FONTSIZESmall)
            cellView2.addSubview(totalMembers2)
            
            createdBy2 = TTTAttributedLabel(frame: CGRectMake(120, 150, CGRectGetWidth(contentImage.bounds)-120, 40))
            createdBy2.textAlignment = .Right
            createdBy2.textColor = textColorLight
            //            createdBy2.layer.shadowColor = shadowColor.CGColor
            //            createdBy2.layer.shadowOpacity = shadowOpacity
            //            createdBy2.layer.shadowRadius = shadowRadius
            //            createdBy2.layer.shadowOffset = shadowOffset
            createdBy2.font = UIFont(name: fontName, size: FONTSIZESmall)
            cellView2.addSubview(createdBy2)
            
            eventTime2 = createLabel(CGRectMake(50, 152, CGRectGetWidth(contentImage.bounds)-150, 20), text: "", alignment: .Center, textColor: textColorDark)
            eventTime2.font = UIFont(name: fontBold, size: FONTSIZEMedium)
            eventTime2.textColor = UIColor.redColor()
            cellView2.addSubview(eventTime2)
            
            menu2 = createButton(CGRectMake(CGRectGetWidth(contentImage.bounds)-30, 210, 30, 40), title: "\u{f141}", border: false,bgColor: false, textColor: textColorLight)
            menu2.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZELarge)
            cellView2.addSubview(menu2)
            menu2.hidden = true
            contentSelection2 = createButton(cellView2.frame, title: "", border: false,bgColor: false, textColor: textColorLight)
            contentSelection2.frame.size.height = (cellView2.frame.size.height-40)
            self.addSubview(contentSelection2)
            
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
