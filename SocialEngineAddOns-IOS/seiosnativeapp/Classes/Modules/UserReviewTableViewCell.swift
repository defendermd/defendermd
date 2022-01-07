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

//  UserReviewTableViewCell.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 17/02/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit

class UserReviewTableViewCell: UITableViewCell
{
    var cellView:UIView!
    var titleLabel: UILabel!
    var createdAt:UILabel!
    var createdAttbLabel : TTTAttributedLabel!
    var ratingView: UIView!
    var rated:Bool!
    var lblRecomnded: UILabel!
    var btnright:UIButton!
    var lblpros: UILabel!
    var lblprostext:UILabel!
    var lblcons: UILabel!
    var lblconstext:UILabel!
    var lblsummary: UILabel!
    var lblsummarytext:UILabel!
    var viewActivity:UIView!
    var btncomment:UIButton!
    var lblcomment:UILabel!
    var btncommentaction:UIButton!
    var lblhelpful:UILabel!
    var btnhelpful:UIButton!
    var lblhelpfulcount:UILabel!
    var btnNothelpful:UIButton!
    var lblNothelpfulcount:UILabel!
    var lblcommentstar:UILabel!
    var lblhelpfulstar:UILabel!
    var nothelpfulcommentstar:UILabel!
    var reviewMoreOptions: UIButton!
    var btnUser:UIButton!
    var fieldLabel:UILabel!
    var fieldLabel1:UILabel!
    var lblrecommend: UILabel!
    var lblrecommendtext:UILabel!
    
    
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool)
        
    {
        super.setSelected(selected, animated: animated)
        
        
    }
    
    // Initialize Variable for Comments Table Cell
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        cellView = createView( CGRect(x: 0, y: 0,width: (UIScreen.main.bounds.width) , height: 200), borderColor: borderColorMedium, shadow: false)
        cellView.layer.borderWidth = 0.0
        self.addSubview(cellView)
        cellView.isUserInteractionEnabled = true
        
        titleLabel = createLabel(CGRect(x: 10, y: 2, width: 200, height: 30), text: "ram", alignment: .left, textColor: textColorDark)
        titleLabel.font = UIFont(name: fontName, size: 16)
        cellView.addSubview(titleLabel)
        
        createdAt = createLabel(CGRect(x: titleLabel.frame.origin.x, y: 22 + 2,width: 200, height: 20), text: "", alignment: .left, textColor: textColorMedium)
        createdAt.font = UIFont(name: fontName, size: FONTSIZESmall)
        createdAt.text = "7 days before"
        cellView.addSubview(createdAt)
        
        createdAttbLabel = TTTAttributedLabel(frame:CGRect(x: titleLabel.frame.origin.x, y: 25,width: 200, height: 20) )
        createdAttbLabel.numberOfLines = 0
        createdAttbLabel.linkAttributes = [kCTForegroundColorAttributeName:UIColor.black,kCTUnderlineStyleAttributeName:NSNumber(value: false)]
        cellView.addSubview(createdAttbLabel)
        
        createdAttbLabel.isHidden = true
        
        btnUser = createButton(CGRect(x: titleLabel.frame.origin.x, y: 22,width: 200, height: 20), title: " \u{f00c}", border: false,bgColor: false, textColor: UIColor.clear )
        btnUser.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium)
        btnUser.backgroundColor = UIColor.clear
        cellView.addSubview(btnUser)
        
        ratingView = createView(CGRect(x: cellView.frame.size.width-100 , y: 0, width: 75, height: 15), borderColor: UIColor.clear, shadow: true)
        ratingView.backgroundColor = UIColor.clear
        cellView.addSubview(ratingView)
        
        lblRecomnded = createLabel(CGRect(x: ratingView.frame.origin.x,y: ratingView.frame.origin.y+ratingView.frame.size.height+10, width: 60, height: 10), text: "Recomended", alignment: .left, textColor: textColorMedium)
        
        lblRecomnded.font = UIFont(name: fontName, size: 10.0)
        cellView.addSubview(lblRecomnded)
        self.rated = true
        
        btnright = createButton(CGRect(x: lblRecomnded.frame.origin.x + lblRecomnded.frame.size.width,y: lblRecomnded.frame.origin.y-2,width: 15,height: 15), title: " \u{f00c}", border: false,bgColor: false, textColor: textColorMedium )
        
        btnright.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium)
        btnright.titleLabel?.adjustsFontSizeToFitWidth = true
        btnright.backgroundColor = UIColor.clear
        cellView.addSubview(btnright)
        
        lblpros = createLabel(CGRect(x: titleLabel.frame.origin.x, y: 50, width: 40, height: 30), text: "Pros:", alignment: .left, textColor: textColorDark)
        lblpros.font = UIFont(name: fontName, size:12)
        lblpros.sizeToFit()
        cellView.addSubview(lblpros)
        
        lblprostext = createLabel(CGRect(x: titleLabel.frame.origin.x+30, y: 50, width: cellView.frame.size.width-60, height: 30), text: "", alignment: .left, textColor: textColorMedium)
        
        lblprostext.font = UIFont(name: fontName, size:12)
        
        lblprostext.backgroundColor = UIColor.clear
        
        //lblprostext.sizeToFit()
        cellView.addSubview(lblprostext)
        
        
        lblcons = createLabel(CGRect(x: titleLabel.frame.origin.x,y: getBottomEdgeY(inputView: lblprostext) + 20, width: 40, height: 30), text: "Cons:", alignment: .left, textColor: textColorDark)
        lblcons.font = UIFont(name: fontName, size:12)
        lblcons.sizeToFit()
        cellView.addSubview(lblcons)
        
        
        lblconstext = createLabel(CGRect(x: titleLabel.frame.origin.x+35,y: getBottomEdgeY(inputView: lblprostext) + 20, width: cellView.frame.size.width-65, height: 30), text: "", alignment: .left, textColor: textColorMedium)
        lblconstext.font = UIFont(name: fontName, size:12)
        //        lblconstext.text = "hdfds dfhdshfds fysdgryewrwyerwefsbd cdfgs7erthds vcxvdshteuhf ncfghd"
        //lblconstext.numberOfLines = 0
        lblconstext.backgroundColor = UIColor.clear
        //lblconstext.sizeToFit()
        cellView.addSubview(lblconstext)
        
        lblsummary = createLabel(CGRect(x:titleLabel.frame.origin.x, y:getBottomEdgeY(inputView: lblconstext) + 20, width:40, height:30), text: "Summary:", alignment: .left, textColor: textColorDark)
        
        lblsummary.font = UIFont(name: fontName, size:12)
        lblsummary.sizeToFit()
        cellView.addSubview(lblsummary)
        
        lblsummarytext = createLabel(CGRect(x:titleLabel.frame.origin.x, y:getBottomEdgeY(inputView: lblsummary) + 5, width:cellView.frame.size.width - titleLabel.frame.origin.x - 10, height:30), text: "", alignment: .left, textColor: textColorMedium)
        
        lblsummarytext.font = UIFont(name: fontName, size:12)
        lblsummarytext.backgroundColor = UIColor.clear
        cellView.addSubview(lblsummarytext)
        
        lblrecommend = createLabel(CGRect(x: titleLabel.frame.origin.x,y: lblsummarytext.frame.origin.y + lblsummarytext.frame.size.height+20, width: 40, height: 30), text: "Members Recommendation:", alignment: .left, textColor: textColorDark)
        lblrecommend.font = UIFont(name: fontName, size:12)
        lblrecommend.sizeToFit()
        lblrecommend.isHidden = true
        cellView.addSubview(lblrecommend)
        
        
        lblrecommendtext = createLabel(CGRect(x: cellView.frame.size.width-155,y: lblconstext.frame.origin.y + lblconstext.frame.size.height+20, width: 50, height: 30), text: "", alignment: .left, textColor: textColorMedium)
        lblrecommendtext.font = UIFont(name: fontName, size:12)
        lblrecommendtext.backgroundColor = UIColor.clear
        lblrecommendtext.isHidden = true
        cellView.addSubview(lblrecommendtext)
        
        let yValue = lblsummarytext.frame.origin.y + lblsummarytext.frame.size.height + 50 + lblrecommendtext.frame.size.height 
        viewActivity = createView(CGRect(x: 0, y: yValue, width: cellView.frame.size.width,height: 50), borderColor: borderColorMedium, shadow: false)
        
        viewActivity.backgroundColor = UIColor.clear
        cellView.addSubview(viewActivity)
        
        //        btncomment = createButton(CGRect(x:viewActivity.frame.origin.x+20,10,20,20), title: "", border: false,bgColor: false, textColor: textColorMedium)
        //
        //        btncomment.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium)
        //        viewActivity.addSubview(btncomment)
        
        
        reviewMoreOptions = createButton(CGRect( x: cellView.bounds.width - 45, y: 10, width: 40, height: 30), title: "\u{f141}", border: false, bgColor: false, textColor: textColorDark)
        reviewMoreOptions.backgroundColor = UIColor.clear
        reviewMoreOptions.titleLabel?.font = UIFont(name: "fontAwesome", size: FONTSIZEExtraLarge)
        reviewMoreOptions.isHidden = true
        viewActivity.addSubview(reviewMoreOptions)
        
        lblcomment = createLabel(CGRect(x: viewActivity.frame.origin.x+10,y: 15, width: 40, height: 20), text: "0 Comment", alignment: .left, textColor: navColor)
        if logoutUser == true{
            lblcomment.textColor = textColorMedium
        }
        lblcomment.font = UIFont(name: fontBold, size:15)
        lblcomment.sizeToFit()
        viewActivity.addSubview(lblcomment)
        
        btncommentaction = createButton(CGRect(x: viewActivity.frame.origin.x+10,y: 10,width: 60,height: 30), title: "", border: false,bgColor: false, textColor:UIColor.clear)
        btncommentaction.tintColor = UIColor.clear
        viewActivity.addSubview(btncommentaction)
        
        
        lblcommentstar = createLabel(CGRect(x: lblcomment.frame.origin.x+lblcomment.frame.size.width+15,y: 5, width: 20, height: 20), text: ".", alignment: .left, textColor: navColor)
        
        lblcommentstar.font = UIFont(name: fontBold, size:22)
        lblcommentstar.sizeToFit()
  //      viewActivity.addSubview(lblcommentstar)
        
        
        lblhelpful = createLabel(CGRect(x: lblcomment.frame.origin.x+lblcomment.frame.size.width+30,y: 15, width: 40, height: 20), text: "Helpful", alignment: .left, textColor: navColor)
        lblhelpful.font = UIFont(name: fontBold, size:15)
        lblhelpful.sizeToFit()
        viewActivity.addSubview(lblhelpful)
        
        lblhelpfulstar = createLabel(CGRect(x: lblhelpful.frame.origin.x+lblhelpful.frame.size.width+12,y: 5, width: 20, height: 20), text: ".", alignment: .left, textColor: navColor)
        lblhelpfulstar.font = UIFont(name: fontBold, size:22)
        lblhelpfulstar.sizeToFit()
        viewActivity.addSubview(lblhelpfulstar)
        
        btnhelpful = createButton(CGRect(x: lblhelpfulstar.frame.origin.x+lblhelpfulstar.frame.size.width+5,y: 13,width: 60,height: 20), title: "", border: false,bgColor: false, textColor: textColorMedium)
        
        btnhelpful.setTitleColor(textColorMedium, for: UIControl.State())
        btnhelpful.setTitleColor(navColor, for: .selected)
        
        btnhelpful.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium)
        viewActivity.addSubview(btnhelpful)
        
        lblhelpfulcount = createLabel(CGRect(x: btnhelpful.frame.origin.x+btnhelpful.frame.size.width+5,y: 15, width: 20, height: 20), text: "0", alignment: .left, textColor: navColor)
        lblhelpfulcount.font = UIFont(name: fontBold, size:15)
        lblhelpfulcount.sizeToFit()
        viewActivity.addSubview(lblhelpfulcount)
        
        
        nothelpfulcommentstar = createLabel(CGRect(x: lblhelpfulcount.frame.origin.x+lblhelpfulcount.frame.size.width,y: 5, width: 20, height: 20), text: ".", alignment: .left, textColor: navColor)
        nothelpfulcommentstar.font = UIFont(name: fontBold, size:22)
        nothelpfulcommentstar.sizeToFit()
        viewActivity.addSubview(nothelpfulcommentstar)
        
        
        btnNothelpful = createButton(CGRect(x: lblhelpfulcount.frame.origin.x+lblhelpfulcount.frame.size.width+20,y: 15,width: 20,height: 20), title: "\u{f165}", border: false,bgColor: false, textColor: textColorMedium )
        
        btnNothelpful.setTitleColor(textColorMedium, for: UIControl.State())
        btnNothelpful.setTitleColor(navColor, for: .selected)
        
        btnNothelpful.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium)
        viewActivity.addSubview(btnNothelpful)
        
        lblNothelpfulcount = createLabel(CGRect(x: btnNothelpful.frame.origin.x+btnNothelpful.frame.size.width+5,y: 15, width: 20, height: 20), text: "0", alignment: .left, textColor: navColor)
        lblNothelpfulcount.font = UIFont(name: fontBold, size:15)
        lblNothelpfulcount.sizeToFit()
        viewActivity.addSubview(lblNothelpfulcount)
        
    }
    
    
    func updateRating(_ rating:Int, ratingCount:Int)
    {
        
        
        for ob in ratingView.subviews
        {
            ob.removeFromSuperview()
        }
        
        var origin_x = 0 as CGFloat
        
        for i in stride(from: 1, through: 5, by: 1){
            
            let rate = createButton(CGRect(x: origin_x, y: 10, width: 15, height: 15), title: "", border: false, bgColor: false, textColor: textColorLight)
            rate.backgroundColor = UIColor.clear
            rate.setImage(UIImage(named: "graystar.png"), for: UIControl.State() )
            
            if rated == false
            {
                rate.tag = i
                rate.addTarget(self, action: Selector(("rateAction:")), for: .touchUpInside)
                
            }
            else
            {
                if i <= rating
                {
                    rate.setImage(UIImage(named: "yellowStar.png"), for: UIControl.State() )
                }
                
            }
            origin_x += 15
            ratingView.addSubview(rate)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
