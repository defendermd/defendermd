
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

// This Class is used by GroupViewController & EventViewController

class EventViewTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    var cellView: UIView!
    var contentImage:UIImageView!
    var hostImage:UIImageView!
    var hostSelection:UIButton!
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
    var gutterMenu: UIButton!
    
    var btnMembercount:UIButton!
    var lblMembercount : UILabel!
    var btnviewcount:UIButton!
    var lblviewcount : UILabel!
    var btnlikecount:UIButton!
    var lbllikecount : UILabel!
    
    var lineView : UIView!
    
    var cellView2: UIView!
    var contentImage2:UIImageView!
    var hostImage2:UIImageView!
    var hostSelection2:UIButton!
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
    var gutterMenu2: UIButton!
    var lineView2 : UIView!
    
    var btnMembercount2:UIButton!
    var lblMembercount2 : UILabel!
    var btnviewcount2:UIButton!
    var lblviewcount2 : UILabel!
    var btnlikecount2:UIButton!
    var lbllikecount2 : UILabel!
    
    var btnTittle:UIButton!
    var btnTittle2:UIButton!
    var btnDate:UIButton!
    var btnDate1:UIButton!
    
    //For featured and sponsored label
    var featuredLabel:UILabel!
    var sponsoredLabel:UILabel!
    var featuredLabel2:UILabel!
    var sponsoredLabel2:UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    
    // Initialize Variable for Comments Table Cell
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Configure the view for the selected state
        
        // LHS
        if(UIDevice.current.userInterfaceIdiom == .pad){
            cellView = createView( CGRect(x: 0, y: 0,width: (UIScreen.main.bounds.width/2) , height: 250), borderColor: borderColorMedium, shadow: false)
        }else{
            cellView = createView( CGRect(x: 0, y: 0,width: (UIScreen.main.bounds.width) , height: 250), borderColor: borderColorMedium, shadow: false)
        }
        
        
        cellView.layer.borderWidth = 0.0
        self.addSubview(cellView)
        cellView.isUserInteractionEnabled = true
        
        
        titleView = UIView( frame: CGRect(x: 70, y: 180,width: cellView.bounds.size.width-70 , height: 80))
        titleView.backgroundColor = textColorLight
        titleView.isUserInteractionEnabled = true
        self.addSubview(titleView)
        
        dateView = UIView( frame: CGRect(x: 0, y: 180,width: 70 ,height: titleView.frame.size.height))
        dateView.backgroundColor = UIColor.green//navColor
        dateView.isUserInteractionEnabled = true
        self.addSubview(dateView)
        
        
        titleLabel = createLabel(CGRect(x: 10, y: 5, width: 100, height: 30), text: "", alignment: .left, textColor: textColorDark)
        titleLabel.font = UIFont(name: fontName, size: FONTSIZENormal)
        titleView.addSubview(titleLabel)
        
        btnTittle  = createButton(CGRect(x: titleLabel.frame.origin.x,y: titleLabel.frame.origin.y-5, width: titleView.frame.size.width-120, height: titleLabel.frame.size.height), title: "", border: false,bgColor: false,textColor: UIColor.clear)
        btnTittle.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZELarge)
        titleLabel.addSubview(btnTittle)
        titleLabel.isUserInteractionEnabled = true
        
        
        
        locLabel = createLabel(CGRect(x: 10, y: 30, width: 100, height: 30), text: "", alignment: .left, textColor: textColorMedium)
        locLabel.font = UIFont(name: fontName, size: FONTSIZESmall)
        titleView.addSubview(locLabel)
        
        dateLabel = createLabel(CGRect(x: 10, y: 50, width: 100, height: 20), text: "", alignment: .left, textColor: textColorMedium)
        dateLabel.font = UIFont(name: fontName, size: FONTSIZESmall)
        //dateLabel.sizeToFit()
        titleView.addSubview(dateLabel)
        
        dateLabel1 = createLabel(CGRect(x: 20, y: (titleView.frame.size.height-60)/2, width: 50, height: 60), text: "", alignment: .left, textColor: textColorMedium)
        dateLabel1.font = UIFont(name: fontName, size: 16)
        dateLabel1.textAlignment = NSTextAlignment.center
        dateLabel1.isUserInteractionEnabled = true
        dateLabel1.backgroundColor = UIColor.clear
        dateView.addSubview(dateLabel1)
        
        btnDate  = createButton(CGRect(x: 0, y: (titleView.frame.size.height-60)/2, width: 70, height: 60), title: "", border: false,bgColor: false,textColor: textColorPrime)
        btnDate.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZELarge)
        dateLabel1.addSubview(btnDate)
        btnDate.isUserInteractionEnabled = true
        
        
        
        
        
        btnMembercount  = createButton(CGRect(x: 12,y: dateLabel.frame.size.height+dateLabel.frame.origin.y+20, width: 20, height: 20), title: "\u{f007}", border: false,bgColor: false,textColor: textColorMedium)
        btnMembercount.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZELarge)
        titleView.addSubview(btnMembercount)
        btnMembercount.isHidden = true
        
        lblMembercount = createLabel(CGRect(x: btnMembercount.frame.origin.x + btnMembercount.frame.size.width+10, y: dateLabel.frame.size.height+dateLabel.frame.origin.y+20, width: 20, height: 20), text: "20", alignment: .left, textColor: textColorMedium)
        lblMembercount.font = UIFont(name: fontName, size: 12)
        titleView.addSubview(lblMembercount)
        lblMembercount.isHidden = true
        
        btnviewcount  = createButton(CGRect(x: lblMembercount.frame.origin.x + lblMembercount.frame.size.width+20,y: dateLabel.frame.size.height+dateLabel.frame.origin.y+20, width: 20, height: 20), title: "\u{f06e}", border: false,bgColor: false,textColor: textColorMedium)
        btnviewcount.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZELarge)
        titleView.addSubview(btnviewcount)
        btnviewcount.isHidden = true
        
        lblviewcount = createLabel(CGRect(x: btnviewcount.frame.origin.x + btnviewcount.frame.size.width+10, y: dateLabel.frame.size.height+dateLabel.frame.origin.y+20, width: 20, height: 20), text: "200", alignment: .left, textColor: textColorMedium)
        lblviewcount.font = UIFont(name: fontName, size: 12)
        titleView.addSubview(lblviewcount)
        lblviewcount.isHidden = true
        
        
        
        btnlikecount  = createButton(CGRect(x: lblviewcount.frame.origin.x + lblviewcount.frame.size.width+20,y: dateLabel.frame.size.height+dateLabel.frame.origin.y+20, width: 20, height: 20), title: "\u{f164}", border: false,bgColor: false,textColor: textColorMedium)
        btnlikecount.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZELarge)
        titleView.addSubview(btnlikecount)
        btnlikecount.isHidden = true
        
        lbllikecount = createLabel(CGRect(x: btnlikecount.frame.origin.x + btnlikecount.frame.size.width+10, y: dateLabel.frame.size.height+dateLabel.frame.origin.y+20, width: 20, height: 20), text: "500", alignment: .left, textColor: textColorMedium)
        lbllikecount.font = UIFont(name: fontName, size: 12)
        titleView.addSubview(lbllikecount)
        lbllikecount.isHidden = true
        
        lineView = UIView(frame: CGRect(x: 0,y: cellView.frame.size.height,width: (UIScreen.main.bounds).width,height: 5))
        lineView.backgroundColor = tableViewBgColor
        
        self.addSubview(lineView)
        lineView.isHidden = true
        
        
        menuButton = createButton(CGRect(x: titleView.bounds.width-40, y: 5, width: 30, height: 40), title: "\u{f141}", border: false,bgColor: false,textColor: textColorMedium)
        menuButton.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZEExtraLarge)
        titleView.addSubview(menuButton)
        menuButton.isHidden = true
        
        contentImage = ContentImageViewWithGradientadvanced(frame: CGRect(x: 0, y: 0, width: cellView.bounds.width, height: 190))
        contentImage.layer.masksToBounds = true
        contentImage.contentMode = UIView.ContentMode.scaleAspectFill
        contentImage.backgroundColor = placeholderColor
        contentImage.layer.shadowColor = shadowColor.cgColor
        contentImage.layer.shadowOpacity = shadowOpacity
        contentImage.layer.shadowRadius = shadowRadius
        contentImage.layer.shadowOffset = shadowOffset
        cellView.addSubview(contentImage)
        
        
        featuredLabel = createLabel(CGRect(x: 0, y: 0, width: 70, height: 20), text: "Featured", alignment: .center, textColor: textColorLight)
        featuredLabel.font = UIFont(name: fontName, size: FONTSIZEMedium)
        featuredLabel.backgroundColor = UIColor.init(red: 0, green: 176/255, blue: 182/255, alpha: 1)
        contentImage.addSubview(featuredLabel)
        featuredLabel.isHidden = true
        
        sponsoredLabel = createLabel(CGRect(x: contentImage.bounds.width - 70, y: 0, width: 70, height: 20), text: "Sponsored", alignment: .center, textColor: textColorLight)
        sponsoredLabel.font = UIFont(name: fontName, size: FONTSIZEMedium)
        sponsoredLabel.backgroundColor = UIColor.red
        contentImage.addSubview(sponsoredLabel)
        sponsoredLabel.isHidden = true
        
        
        menu = createButton(CGRect(x: contentImage.bounds.width-30, y: 210, width: 30, height: 40), title: "\u{f141}", border: false,bgColor: false,textColor: textColorLight)
        menu.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZELarge)
        cellView.addSubview(menu)
        
        menu.isHidden = true
        
        contentSelection = createButton(cellView.frame, title: "", border: false,bgColor: false, textColor: textColorLight)
        contentSelection.frame.size.height = (cellView.frame.size.height-40)
        self.addSubview(contentSelection)
        
        gutterMenu  = createButton(CGRect(x: contentSelection.bounds.width-40,y: contentSelection.frame.origin.y, width: 45, height: 45), title: "", border: false,bgColor: false,textColor: UIColor.clear)
        gutterMenu.setImage(UIImage(named: "option"), for: UIControl.State())
        contentSelection.addSubview(gutterMenu)
        //gutterMenu.backgroundColor = UIColor.redColor()
        gutterMenu.isHidden = true
        
        
        
        
        //Set HostImage
        hostImage = createImageView(CGRect(x: cellView.bounds.width-80, y: 100, width: 70, height: 70), border: false)
        hostImage.layer.masksToBounds = false
        hostImage.backgroundColor = placeholderColor
        hostImage.layer.borderWidth = 2.0
        hostImage.layer.borderColor = borderColorLight.cgColor
        hostImage.layer.cornerRadius = hostImage.frame.height/2
        hostImage.clipsToBounds = true
        hostImage.isHidden = true
        hostImage.isUserInteractionEnabled = true
        contentSelection.addSubview(hostImage)
        
        hostSelection = createButton(CGRect(x: cellView.bounds.width-80, y: 100, width: 70, height: 70), title: "", border: false,bgColor: false, textColor:UIColor.clear)
        hostSelection.isHidden = true
        hostSelection.backgroundColor = UIColor.clear
        hostSelection.isUserInteractionEnabled = true
        contentSelection.addSubview(hostSelection)
        
        
        
        // Set
        contentName = createLabel(CGRect(x: 10, y: 110, width: (contentImage.bounds.width-20), height: 100), text: "", alignment: .left, textColor: textColorLight)
        //        contentName.layer.shadowColor = UIColor.lightGrayColor().CGColor
        //        contentName.layer.shadowOpacity = 1.0
        //        contentName.layer.shadowRadius = 4.0
        contentName.numberOfLines = 0
        contentName.font = UIFont(name: fontBold, size: FONTSIZEExtraLarge)
        contentName.layer.shadowColor = shadowColor.cgColor
        contentName.layer.shadowOpacity = shadowOpacity
        contentName.layer.shadowRadius = shadowRadius
        contentName.layer.shadowOffset = shadowOffset
        contentName.isUserInteractionEnabled = true
        cellView.addSubview(contentName)
        
        
        totalMembers = createLabel(CGRect(x: 10, y: 150, width: 100, height: 40), text: "", alignment: .left, textColor: textColorDark)
        totalMembers.font = UIFont(name: fontName, size: 12)
        cellView.addSubview(totalMembers)
        
        createdBy = TTTAttributedLabel(frame: CGRect(x: 120, y: 150, width: contentImage.bounds.width-120, height: 40))
        createdBy.textAlignment = .right
        createdBy.textColor = textColorLight
        //        createdBy.layer.shadowColor = shadowColor.CGColor
        //        createdBy.layer.shadowOpacity = shadowOpacity
        //        createdBy.layer.shadowRadius = shadowRadius
        //        createdBy.layer.shadowOffset = shadowOffset
        createdBy.font = UIFont(name: fontName, size: FONTSIZESmall)
        cellView.addSubview(createdBy)
        
        eventTime = createLabel(CGRect(x: 50, y: 152, width: contentImage.bounds.width-150, height: 20), text: "", alignment: .center, textColor: textColorDark)
        eventTime.font = UIFont(name: fontBold, size: FONTSIZEMedium)
        eventTime.textColor = UIColor.red
        cellView.addSubview(eventTime)
        
        
        menu = createButton(CGRect(x: contentImage.bounds.width-30, y: 210, width: 30, height: 40), title: "\u{f141}", border: false,bgColor: false,textColor: textColorLight)
        menu.titleLabel?.font =  UIFont(name: "FontAwesome", size:30.0)
        cellView.addSubview(menu)
        menu.isHidden = true
        //        contentSelection = createButton(CGRect(x:0, 40,(UIScreen.main.bounds.width/2) , 250), title: "", border: false,bgColor: false, textColor: textColorLight)
        //        contentSelection.frame.size.height = (cellView.frame.size.height-40)
        //        self.addSubview(contentSelection)
        
        
        menuButton = createButton(CGRect(x: cellView.bounds.width-40, y: 0, width: 40, height: 40), title: "\u{f141}", border: false,bgColor: false,textColor:textColorLight)
        menuButton.titleLabel?.font =  UIFont(name: "FontAwesome", size:30.0)
        menuButton.layer.shadowColor = shadowColor.cgColor
        menuButton.layer.shadowOpacity = shadowOpacity
        menuButton.layer.shadowRadius = shadowRadius
        menuButton.layer.shadowOffset = shadowOffset
        cellView.addSubview(menuButton)
        menuButton.isHidden = true
        
        
        if(UIDevice.current.userInterfaceIdiom == .pad){
            // RHS
            cellView2 = createView( CGRect(x: (UIScreen.main.bounds.width/2), y: 0,width: (UIScreen.main.bounds.width/2) , height: 250), borderColor: borderColorMedium, shadow: false)
            
            cellView2.layer.borderWidth = 0.0
            self.addSubview(cellView2)
            cellView2.isUserInteractionEnabled = true
            
            
            
            
            titleView2 = UIView( frame: CGRect(x: (UIScreen.main.bounds.width) / 2 + 70, y: 180,width: (UIScreen.main.bounds).width / 2 - 70 , height: 80))
            titleView2.backgroundColor = textColorLight
            titleView2.isUserInteractionEnabled = true
            self.addSubview(titleView2)
            
            dateView2 = UIView( frame: CGRect(x: (UIScreen.main.bounds.width/2), y: 180,width: 70 , height: titleView2.frame.size.height))
            dateView2.backgroundColor = navColor
            dateView2.isUserInteractionEnabled = true
            self.addSubview(dateView2)
            
            
            titleLabel2 = createLabel(CGRect(x: 10, y: 5, width: 100, height: 30), text: "", alignment: .left, textColor: textColorDark)
            titleLabel2.font = UIFont(name: fontName, size: FONTSIZENormal)
            titleLabel2.isUserInteractionEnabled = true
            titleView2.addSubview(titleLabel2)
            
            btnTittle2  = createButton(CGRect(x: titleLabel2.frame.origin.x,y: titleLabel2.frame.origin.y-5, width: titleView2.frame.size.width-120, height: titleLabel2.frame.size.height), title: "", border: false,bgColor: false,textColor: UIColor.clear)
            btnTittle2.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZELarge)
            titleLabel2.addSubview(btnTittle2)
            
            
            locLabel2 = createLabel(CGRect(x: 10, y: 30, width: 100, height: 30), text: "", alignment: .left, textColor: textColorMedium)
            locLabel2.font = UIFont(name: fontName, size: FONTSIZESmall)
            titleView2.addSubview(locLabel2)
            
            dateLabel2 = createLabel(CGRect(x: 10, y: 50, width: 100, height: 30), text: "", alignment: .left, textColor: textColorMedium)
            dateLabel2.font = UIFont(name: fontName, size: FONTSIZESmall)
            titleView2.addSubview(dateLabel2)
            
            dateLabel3 = createLabel(CGRect(x: 0,  y: (titleView2.frame.size.height-60)/2, width: 50, height: 60), text: "", alignment: .left, textColor: textColorMedium)
            dateLabel3.font = UIFont(name: fontName, size: 16)
            dateLabel3.textAlignment = NSTextAlignment.center
            dateLabel3.isUserInteractionEnabled = true
            dateView2.addSubview(dateLabel3)
            
            
            btnDate1  = createButton(CGRect(x: 0, y: (titleView2.frame.size.height-50)/2, width: 70, height: 60), title: "", border: false,bgColor: false,textColor: UIColor.clear)
            btnDate1.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZELarge)
            dateLabel3.addSubview(btnDate1)
            btnDate1.backgroundColor = UIColor.clear
            btnDate1.isUserInteractionEnabled = true
            
            
            
            
            
            btnMembercount2  = createButton(CGRect(x: 12,y: dateLabel2.frame.size.height+dateLabel2.frame.origin.y+20-30, width: 20, height: 20), title: "\u{f007}", border: false,bgColor: false,textColor: textColorMedium)
            btnMembercount2.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZELarge)
            titleView2.addSubview(btnMembercount2)
            btnMembercount2.isHidden = true
            
            lblMembercount2 = createLabel(CGRect(x: btnMembercount2.frame.origin.x + btnMembercount2.frame.size.width+10, y: dateLabel2.frame.size.height+dateLabel2.frame.origin.y+20-30, width: 20, height: 20), text: "20", alignment: .left, textColor: textColorMedium)
            lblMembercount2.font = UIFont(name: fontName, size: 12)
            titleView2.addSubview(lblMembercount2)
            lblMembercount2.isHidden = true
            
            btnviewcount2  = createButton(CGRect(x: lblMembercount2.frame.origin.x + lblMembercount2.frame.size.width+20,y: dateLabel2.frame.size.height+dateLabel2.frame.origin.y+20-30, width: 20, height: 20), title: "\u{f06e}", border: false,bgColor: false,textColor: textColorMedium)
            btnviewcount2.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZELarge)
            titleView2.addSubview(btnviewcount2)
            btnviewcount2.isHidden = true
            
            lblviewcount2 = createLabel(CGRect(x: btnviewcount2.frame.origin.x + btnviewcount2.frame.size.width+10, y: dateLabel2.frame.size.height+dateLabel2.frame.origin.y+20-30, width: 20, height: 20), text: "200", alignment: .left, textColor: textColorMedium)
            lblviewcount2.font = UIFont(name: fontName, size: 12)
            titleView2.addSubview(lblviewcount2)
            lblviewcount2.isHidden = true
            
            
            
            btnlikecount2  = createButton(CGRect(x: lblviewcount2.frame.origin.x + lblviewcount2.frame.size.width+20,y: dateLabel2.frame.size.height+dateLabel2.frame.origin.y+20-30, width: 20, height: 20), title: "\u{f164}", border: false,bgColor: false,textColor: textColorMedium)
            btnlikecount2.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZELarge)
            titleView2.addSubview(btnlikecount2)
            btnlikecount2.isHidden = true
            
            lbllikecount2 = createLabel(CGRect(x: btnlikecount2.frame.origin.x + btnlikecount2.frame.size.width+10, y: dateLabel2.frame.size.height+dateLabel2.frame.origin.y+20-30, width: 20, height: 20), text: "500", alignment: .left, textColor: textColorMedium)
            lbllikecount2.font = UIFont(name: fontName, size: 12)
            titleView2.addSubview(lbllikecount2)
            lbllikecount2.isHidden = true
            
            
            menuButton2 = createButton(CGRect(x: titleView2.bounds.width-40, y: 0, width: 30, height: 40), title: "\u{f141}", border: false,bgColor: false,textColor: textColorMedium)
            menuButton2.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZEExtraLarge)
            titleView2.addSubview(menuButton2)
            menuButton2.isHidden = true
            
            
            lineView2 = UIView(frame: CGRect(x: 0,y: 250,width: (UIScreen.main.bounds).width/2,height: 5))
            //lineView.layer.borderWidth = 7.0
            //lineView.layer.borderColor = UIColor.whiteColor().CGColor
            lineView2.backgroundColor = UIColor.white
            self.addSubview(lineView2)
            lineView2.isHidden = true
            
            
            contentImage2 = ContentImageViewWithGradientadvanced(frame: CGRect(x: 0, y: 0, width: cellView.bounds.width, height: 190))
            contentImage2.layer.masksToBounds = true
            contentImage2.backgroundColor = placeholderColor
            contentImage2.layer.shadowColor = shadowColor.cgColor
            contentImage2.layer.shadowOffset = CGSize(width: 0,height: 5);
            contentImage2.layer.shadowOpacity = 0.5;
            contentImage2.contentMode = UIView.ContentMode.scaleAspectFill
            cellView2.addSubview(contentImage2)
            
            featuredLabel2 = createLabel(CGRect(x: 0, y: 0, width: 75, height: 20), text: "Featured", alignment: .center, textColor: textColorLight)
            featuredLabel2.font = UIFont(name: fontName, size: FONTSIZEMedium)
            featuredLabel2.backgroundColor = UIColor.init(red: 0, green: 176, blue: 182, alpha: 0)
            contentImage2.addSubview(featuredLabel2)
            featuredLabel2.sizeToFit()
            featuredLabel2.isHidden = true
            
            sponsoredLabel2 = createLabel(CGRect(x: contentImage2.bounds.width - 73, y: 0, width: 70, height: 20), text: "Sponsored", alignment: .center, textColor: textColorLight)
            sponsoredLabel2.font = UIFont(name: fontName, size: FONTSIZEMedium)
            sponsoredLabel2.backgroundColor = UIColor.red
            contentImage2.addSubview(sponsoredLabel2)
            sponsoredLabel2.sizeToFit()
            sponsoredLabel2.isHidden = true
            
            contentSelection2 = createButton(cellView2.frame, title: "", border: false,bgColor: false, textColor: textColorLight)
            contentSelection2.frame.size.height = (cellView2.frame.size.height-40)
            self.addSubview(contentSelection2)
            
            
            gutterMenu2  = createButton(CGRect(x: contentSelection2.bounds.width-40,y: contentSelection2.frame.origin.y, width: 45, height: 45), title: "", border: false,bgColor: false,textColor: UIColor.clear)
            gutterMenu2.setImage(UIImage(named: "option"), for: UIControl.State())
            contentSelection2.addSubview(gutterMenu2)
            gutterMenu2.isHidden = true
            //gutterMenu2.backgroundColor = UIColor.redColor()
            
            //Set HostImage
            hostImage2 = createImageView(CGRect(x: cellView2.bounds.width-80, y: 100, width: 70, height: 70), border: false)
            hostImage2.layer.masksToBounds = false
            hostImage2.backgroundColor = placeholderColor
            hostImage2.layer.borderWidth = 2.0
            hostImage2.layer.borderColor = borderColorLight.cgColor
            hostImage2.layer.cornerRadius = hostImage2.frame.height/2
            hostImage2.clipsToBounds = true
            hostImage2.isHidden = true
            hostImage2.isUserInteractionEnabled = true
            contentSelection2.addSubview(hostImage2)
            
            hostSelection2 = createButton(CGRect(x: cellView2.bounds.width-80, y: 100, width: 70, height: 70), title: "", border: false,bgColor: false, textColor:UIColor.clear)
            hostSelection2.isHidden = true
            hostSelection.backgroundColor = UIColor.clear
            hostSelection.isUserInteractionEnabled = true
            contentSelection2.addSubview(hostSelection2)
            
            
            
            contentName2 = createLabel(CGRect(x: 10, y: 110, width: (contentImage.bounds.width-20), height: 100), text: "", alignment: .left, textColor: textColorLight)
            //        contentName2.layer.shadowColor = UIColor.lightGrayColor().CGColor
            //        contentName2.layer.shadowOpacity = 1.0
            //        contentName2.layer.shadowRadius = 4.0
            contentName2.numberOfLines = 0
            contentName2.layer.shadowColor = shadowColor.cgColor
            contentName2.layer.shadowOpacity = 0.2
            contentName2.layer.shadowRadius = shadowRadius
            contentName2.layer.shadowOffset = shadowOffset
            contentName2.font = UIFont(name: fontBold, size: FONTSIZEMedium)
            cellView2.addSubview(contentName2)
            
            menuButton2 = createButton(CGRect(x: cellView2.bounds.width-40, y: 0, width: 40, height: 40), title: "\u{f141}", border: false,bgColor: false,textColor: textColorLight)
            menuButton2.titleLabel?.font =  UIFont(name: "FontAwesome", size:30.0)
            menuButton2.layer.shadowColor = shadowColor.cgColor
            menuButton2.layer.shadowOpacity = shadowOpacity
            menuButton2.layer.shadowRadius = shadowRadius
            menuButton2.layer.shadowOffset = shadowOffset
            
            cellView2.addSubview(menuButton2)
            menuButton2.isHidden = true
            
            
            totalMembers2 = createLabel(CGRect(x: 10, y: 150, width: 100, height: 40), text: "", alignment: .left, textColor: textColorDark)
            totalMembers2.font = UIFont(name: fontName, size: FONTSIZESmall)
            cellView2.addSubview(totalMembers2)
            
            createdBy2 = TTTAttributedLabel(frame: CGRect(x: 120, y: 150, width: contentImage.bounds.width-120, height: 40))
            createdBy2.textAlignment = .right
            createdBy2.textColor = textColorLight
            //            createdBy2.layer.shadowColor = shadowColor.CGColor
            //            createdBy2.layer.shadowOpacity = shadowOpacity
            //            createdBy2.layer.shadowRadius = shadowRadius
            //            createdBy2.layer.shadowOffset = shadowOffset
            createdBy2.font = UIFont(name: fontName, size: FONTSIZESmall)
            cellView2.addSubview(createdBy2)
            
            eventTime2 = createLabel(CGRect(x: 50, y: 152, width: contentImage.bounds.width-150, height: 20), text: "", alignment: .center, textColor: textColorDark)
            eventTime2.font = UIFont(name: fontBold, size: FONTSIZEMedium)
            eventTime2.textColor = UIColor.red
            cellView2.addSubview(eventTime2)
            
            menu2 = createButton(CGRect(x: contentImage.bounds.width-30, y: 210, width: 30, height: 40), title: "\u{f141}", border: false,bgColor: false, textColor: textColorLight)
            menu2.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZELarge)
            cellView2.addSubview(menu2)
            menu2.isHidden = true
            
            //            contentSelection2 = createButton(CGRect(x:(UIScreen.main.bounds.width/2), 40,(UIScreen.main.bounds.width/2) , 250), title: "", border: false,bgColor: false, textColor: textColorLight)
            //            contentSelection2.frame.size.height = (cellView2.frame.size.height-40)
            //            self.addSubview(contentSelection2)
            
            
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
