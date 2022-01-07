//
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
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    override func setSelected(selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
        
    }
    
    
    // Initialize Variable for Comments Table Cell
    override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        cellView = createView( CGRectMake(0, 0,(CGRectGetWidth(UIScreen.mainScreen().bounds)) , 200), borderColor: borderColorMedium, shadow: false)
        cellView.layer.borderWidth = 0.0
        self.addSubview(cellView)
        cellView.userInteractionEnabled = true
        
        titleLabel = createLabel(CGRectMake(10, 2, 200, 30), text: "ram", alignment: .Left, textColor: textColorDark)
        titleLabel.font = UIFont(name: fontName, size: 16)
        cellView.addSubview(titleLabel)
        
        createdAt = createLabel(CGRectMake(titleLabel.frame.origin.x, 22,200, 20), text: "", alignment: .Left, textColor: textColorMedium)
        createdAt.font = UIFont(name: fontName, size: FONTSIZESmall)
        createdAt.text = "7 days before"
        cellView.addSubview(createdAt)
        
        ratingView = createView(CGRectMake(cellView.frame.size.width-100 , 0, 75, 15), borderColor: UIColor.clearColor(), shadow: true)
        ratingView.backgroundColor = UIColor.clearColor()
        cellView.addSubview(ratingView)
        
        lblRecomnded = createLabel(CGRectMake(ratingView.frame.origin.x,ratingView.frame.origin.y+ratingView.frame.size.height+10, 60, 10), text: "Recomended", alignment: .Left, textColor: textColorMedium)
        lblRecomnded.font = UIFont(name: fontName, size: 10.0)
        cellView.addSubview(lblRecomnded)
        self.rated = true
        
        btnright = createButton(CGRectMake(lblRecomnded.frame.origin.x + lblRecomnded.frame.size.width,lblRecomnded.frame.origin.y-2,15,15), title: " \u{f00c}", border: false,bgColor: false, textColor: textColorMedium )
        
        btnright.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium)
        btnright.titleLabel?.adjustsFontSizeToFitWidth = true
        btnright.backgroundColor = UIColor.clearColor()
        cellView.addSubview(btnright)
        
        lblpros = createLabel(CGRectMake(titleLabel.frame.origin.x, 50, 40, 30), text: "Pros:", alignment: .Left, textColor: textColorDark)
        lblpros.font = UIFont(name: fontName, size:12)
        lblpros.sizeToFit()
        cellView.addSubview(lblpros)
        
        lblprostext = createLabel(CGRectMake(titleLabel.frame.origin.x+30, 50, cellView.frame.size.width-60, 30), text: "", alignment: .Left, textColor: textColorMedium)
        lblprostext.font = UIFont(name: fontName, size:12)
        //        lblprostext.text = "hdfdsfdsgfdg dfsdhfbdsf dsfds f dsfbdsfsd fds fbasdf dsf dshfbds fdsfhdsfbvd"
        lblprostext.numberOfLines = 0
        lblprostext.backgroundColor = UIColor.clearColor()
        lblprostext.sizeToFit()
        cellView.addSubview(lblprostext)
        
        
        lblcons = createLabel(CGRectMake(titleLabel.frame.origin.x,lblprostext.frame.origin.y + lblprostext.frame.size.height+20, 40, 30), text: "Cons:", alignment: .Left, textColor: textColorDark)
        lblcons.font = UIFont(name: fontName, size:12)
        lblcons.sizeToFit()
        cellView.addSubview(lblcons)
        
        
        lblconstext = createLabel(CGRectMake(titleLabel.frame.origin.x+35,lblprostext.frame.origin.y + lblprostext.frame.size.height+20, cellView.frame.size.width-65, 30), text: "", alignment: .Left, textColor: textColorMedium)
        lblconstext.font = UIFont(name: fontName, size:12)
        //        lblconstext.text = "hdfds dfhdshfds fysdgryewrwyerwefsbd cdfgs7erthds vcxvdshteuhf ncfghd"
        lblconstext.numberOfLines = 0
        lblconstext.backgroundColor = UIColor.clearColor()
        lblconstext.sizeToFit()
        cellView.addSubview(lblconstext)
        
        
        lblsummary = createLabel(CGRectMake(titleLabel.frame.origin.x,lblconstext.frame.origin.y + lblconstext.frame.size.height+20, 40, 30), text: "Summary:", alignment: .Left, textColor: textColorDark)
        lblsummary.font = UIFont(name: fontName, size:12)
        lblsummary.sizeToFit()
        cellView.addSubview(lblsummary)
        
        
        lblsummarytext = createLabel(CGRectMake(titleLabel.frame.origin.x+60,lblconstext.frame.origin.y + lblconstext.frame.size.height+20, cellView.frame.size.width-80, 30), text: "", alignment: .Left, textColor: textColorMedium)
        lblsummarytext.font = UIFont(name: fontName, size:12)
        //        lblsummarytext.text = "hdfds f dshfbsadf dfgbhdsfgd v dsthdsbfsdjuhteityheruiythds vdhtufg cxvxcghduvxc cxgdh"
        lblsummarytext.numberOfLines = 0
        lblsummarytext.backgroundColor = UIColor.clearColor()
        lblsummarytext.sizeToFit()
        cellView.addSubview(lblsummarytext)
        
        reviewMoreOptions = createButton(CGRectMake( CGRectGetWidth(cellView.bounds) - 30, lblsummarytext.frame.origin.y, 20, 30), title: "\u{f141}", border: false, bgColor: false, textColor: textColorDark)
        reviewMoreOptions.backgroundColor = UIColor.clearColor()
        reviewMoreOptions.titleLabel?.font = UIFont(name: "fontAwesome", size: FONTSIZEExtraLarge)
        cellView.addSubview(reviewMoreOptions)
        
        
        viewActivity = createView(CGRectMake(0,lblsummarytext.frame.origin.y + lblsummarytext.frame.size.height+10,cellView.frame.size.width,50), borderColor: borderColorMedium, shadow: false)
        
        viewActivity.backgroundColor = UIColor.clearColor()
        cellView.addSubview(viewActivity)
        
        //        btncomment = createButton(CGRectMake(viewActivity.frame.origin.x+20,10,20,20), title: "", border: false,bgColor: false, textColor: textColorMedium)
        //
        //        btncomment.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium)
        //        viewActivity.addSubview(btncomment)
        
        lblcomment = createLabel(CGRectMake(viewActivity.frame.origin.x+10,15, 40, 20), text: "0 Comment", alignment: .Left, textColor: navColor)
        lblcomment.font = UIFont(name: fontBold, size:15)
        lblcomment.sizeToFit()
        viewActivity.addSubview(lblcomment)
        
        btncommentaction = createButton(CGRectMake(viewActivity.frame.origin.x+10,10,60,30), title: "", border: false,bgColor: false, textColor:UIColor.clearColor())
        btncommentaction.tintColor = UIColor.clearColor()
        viewActivity.addSubview(btncommentaction)
        
        
        lblcommentstar = createLabel(CGRectMake(lblcomment.frame.origin.x+lblcomment.frame.size.width+15,5, 20, 20), text: ".", alignment: .Left, textColor: navColor)
        lblcommentstar.font = UIFont(name: fontBold, size:22)
        lblcommentstar.sizeToFit()
        viewActivity.addSubview(lblcommentstar)
        
        
        lblhelpful = createLabel(CGRectMake(lblcomment.frame.origin.x+lblcomment.frame.size.width+40,15, 40, 20), text: "Helpful", alignment: .Left, textColor: navColor)
        lblhelpful.font = UIFont(name: fontBold, size:15)
        lblhelpful.sizeToFit()
        viewActivity.addSubview(lblhelpful)
        
        lblhelpfulstar = createLabel(CGRectMake(lblhelpful.frame.origin.x+lblhelpful.frame.size.width+12,5, 20, 20), text: ".", alignment: .Left, textColor: navColor)
        lblhelpfulstar.font = UIFont(name: fontBold, size:22)
        lblhelpfulstar.sizeToFit()
        viewActivity.addSubview(lblhelpfulstar)
        
        btnhelpful = createButton(CGRectMake(lblhelpful.frame.origin.x+lblhelpful.frame.size.width+30,13,20,20), title: "\u{f164}", border: false,bgColor: false, textColor: textColorMedium)
        
        btnhelpful.setTitleColor(textColorMedium, forState: .Normal)
        btnhelpful.setTitleColor(navColor, forState: .Selected)
        
        
        btnhelpful.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium)
        viewActivity.addSubview(btnhelpful)
        
        lblhelpfulcount = createLabel(CGRectMake(btnhelpful.frame.origin.x+btnhelpful.frame.size.width+5,15, 20, 20), text: "000", alignment: .Left, textColor: navColor)
        lblhelpfulcount.font = UIFont(name: fontBold, size:15)
        lblhelpfulcount.sizeToFit()
        viewActivity.addSubview(lblhelpfulcount)
        
        
        nothelpfulcommentstar = createLabel(CGRectMake(lblhelpfulcount.frame.origin.x+lblhelpfulcount.frame.size.width,5, 20, 20), text: ".", alignment: .Left, textColor: navColor)
        nothelpfulcommentstar.font = UIFont(name: fontBold, size:22)
        nothelpfulcommentstar.sizeToFit()
        viewActivity.addSubview(nothelpfulcommentstar)
        
        
        btnNothelpful = createButton(CGRectMake(lblhelpfulcount.frame.origin.x+lblhelpfulcount.frame.size.width+20,15,20,20), title: "\u{f165}", border: false,bgColor: false, textColor: textColorMedium )
        
        btnNothelpful.setTitleColor(textColorMedium, forState: .Normal)
        btnNothelpful.setTitleColor(navColor, forState: .Selected)
        
        btnNothelpful.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium)
        viewActivity.addSubview(btnNothelpful)
        
        lblNothelpfulcount = createLabel(CGRectMake(btnNothelpful.frame.origin.x+btnNothelpful.frame.size.width+5,15, 20, 20), text: "000", alignment: .Left, textColor: navColor)
        lblNothelpfulcount.font = UIFont(name: fontBold, size:15)
        lblNothelpfulcount.sizeToFit()
        viewActivity.addSubview(lblNothelpfulcount)
        
    }
    
    
    func updateRating(rating:Int, ratingCount:Int)
    {
        
        
        for ob in ratingView.subviews
        {
            ob.removeFromSuperview()
        }
        
        var origin_x = 0 as CGFloat
        for(var i = 1 ; i <= 5; i++){
            let rate = createButton(CGRectMake(origin_x, 10, 15, 15), title: "", border: false, bgColor: false, textColor: textColorLight)
            rate.backgroundColor = UIColor.clearColor()
            rate.setImage(UIImage(named: "graystar.png"), forState: .Normal )
            
            if rated == false
            {
                rate.tag = i
                rate.addTarget(self, action: "rateAction:", forControlEvents: .TouchUpInside)
            }
            else
            {
                if i <= rating
                {
                    //                    rate.backgroundColor = UIColor.greenColor()
                    rate.setImage(UIImage(named: "yellowStar.png"), forState: .Normal )
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
