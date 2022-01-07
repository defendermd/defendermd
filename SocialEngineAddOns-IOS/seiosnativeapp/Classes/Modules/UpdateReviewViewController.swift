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

//  UpdateReviewViewController.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 15/03/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit


class UpdateReviewViewController: UIViewController,UIGestureRecognizerDelegate,FloatRatingViewDelegate,UITextViewDelegate
{
    
    var url : String!
    var Review_id : Int!
    var tittle:String!
    
    var btnCreate:UIBarButtonItem!
    var Scrollview = UIScrollView()
    var SummaryTextview: UITextView!

    
    var OverallRatinglabel:UILabel!
    var OverallRatingView = FloatRatingView()
    
    var AmbienceRatinglabel:UILabel!
    var AmbienceRatingView = FloatRatingView()
    
    var OrganizationRatinglabel:UILabel!
    var OrganizationRatingView = FloatRatingView()
    
    var summary:String!
    var overall:Float!
    var ambience:Float!
    var organization:Float!
    var leftBarButtonItem : UIBarButtonItem!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barTintColor = UIColor.white
        self.title = NSLocalizedString("Update Review",  comment: "")
        
        
        btnCreate = UIBarButtonItem(title: "\u{f1d8}", style: UIBarButtonItem.Style.done , target:self , action: #selector(UpdateReviewViewController.send))
        
        btnCreate.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "FontAwesome", size: FONTSIZELarge)!], for: UIControl.State())
        self.navigationItem.rightBarButtonItem = btnCreate
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(UpdateReviewViewController.cancel))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem

        
        Scrollview.frame = CGRect(x: 0, y: TOPPADING, width: view.frame.size.width, height: view.frame.size.height)
        Scrollview.isUserInteractionEnabled = true
        Scrollview.backgroundColor = UIColor.clear
        Scrollview.isScrollEnabled = true
        Scrollview.isUserInteractionEnabled = true
        Scrollview.contentSize = CGSize(width: view.frame.size.width,height: 1000)
        view.addSubview(Scrollview)
        
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UpdateReviewViewController.resignKeyboard))
        tap.delegate = self
        tap.cancelsTouchesInView = false;
        Scrollview.addGestureRecognizer(tap)
        
    
        GetReview()

    }
    override func viewWillAppear(_ animated: Bool)
    {
        
    }
    override func viewWillDisappear(_ animated: Bool)
    {
       
    }
    @objc func cancel()
    {
        _ = self.navigationController?.popViewController(animated: true)
    }
    @objc func resignKeyboard()
    {
        self.view.endEditing(true)
    }
    
    // MARK: TextView Delegate
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool
    {
        
        if textView.textColor == placeholderColor
        {
            textView.text = nil
            textView.textColor = textColorDark
        }
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool
    {
        
        if textView.text.isEmpty
        {
            textView.text = NSLocalizedString("Description",  comment: "")
            textView.textColor = placeholderColor
        }
        return true
    }
    // MARK: FloatRatingViewDelegate
    
    func floatRatingView(_ ratingView: FloatRatingView, isUpdating rating:Float)
    {
        //self.liveLabel.text = NSString(format: "%.2f", self.floatRatingView.rating) as String
        self.view.endEditing(true)
     }
    
    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Float)
    {
        //self.updatedLabel.text = NSString(format: "%.2f", self.floatRatingView.rating) as String
        if ratingView.tag == 1
        {
            
        }
        else if ratingView.tag == 2
        {
            
        }
        else if ratingView.tag == 3
        {
            
        }
        
        self.view.endEditing(true)
       
    }
    func GetReview()
    {
        var parameters = [String:String]()
        parameters = ["review_id":"\(Review_id)"]
        post(parameters, url: url, method: "GET")
            {
                (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                        activityIndicatorView.stopAnimating()
                        if msg
                        {
  
                            if succeeded["body"] != nil
                            {
                                
                                if let response = succeeded["body"] as? NSDictionary
                                {
                                
                                    if let formvalue = response["formValues"] as? NSDictionary
                                    {
                                        
                                        
                                        self.SummaryTextview = createTextView(CGRect(x: 10,y: -54, width: self.view.bounds.width-20, height: 30), borderColor: borderColorClear, corner: false)
                                        self.SummaryTextview.delegate = self
                                        self.SummaryTextview.isHidden = false
                                        self.SummaryTextview.text = NSLocalizedString("Summary",  comment: "")
                                        self.SummaryTextview.font = UIFont(name: fontName, size: FONTSIZEMedium)
                                        self.SummaryTextview.textColor = placeholderColor
                                        self.SummaryTextview.backgroundColor = bgColor
                                        
                                        self.SummaryTextview.autocorrectionType = UITextAutocorrectionType.no
                                        self.Scrollview.addSubview(self.SummaryTextview)
                                        
                                        
                                        let lineView4 = UIView(frame: CGRect(x: 10,y: self.SummaryTextview.frame.size.height+self.SummaryTextview.frame.origin.y ,width: self.SummaryTextview.frame.size.width,height: 1))
                                        lineView4.layer.borderWidth = 1.0
                                        lineView4.layer.borderColor = textColorMedium.cgColor
                                        self.Scrollview.addSubview(lineView4)
                                        
                                        
                                        
                                        
                                        self.OverallRatinglabel  = createLabel(CGRect(x: lineView4.frame.origin.x,y: lineView4.frame.size.height+lineView4.frame.origin.y+10,width: lineView4.frame.size.width, height: 20), text: NSLocalizedString("Overall Rating",  comment: "") , alignment: .left, textColor: textColorDark)
                                        self.OverallRatinglabel.font = UIFont(name: fontName, size: FONTSIZEMedium)
                                        self.OverallRatinglabel.textAlignment =  NSTextAlignment.left;
                                        self.Scrollview.addSubview(self.OverallRatinglabel)
                                        
                                        
                                        // Required float rating view params
                                        self.OverallRatingView.frame = CGRect(x: self.OverallRatinglabel.frame.origin.x, y: self.OverallRatinglabel.frame.origin.y+self.OverallRatinglabel.frame.size.height, width: 95, height: 20)
                                        self.OverallRatingView.emptyImage = UIImage(named: "graystar.png")
                                        self.OverallRatingView.fullImage = UIImage(named: "yellowStar.png")
                                        // Optional params
                                        self.OverallRatingView.delegate = self
                                        self.OverallRatingView.tag = 1
                                        self.OverallRatingView.contentMode = UIView.ContentMode.scaleAspectFit
                                        self.OverallRatingView.maxRating = 5
                                        self.OverallRatingView.minRating = 0
                                        //self.floatRatingView.rating = 2.5
                                        self.OverallRatingView.editable = true
                                        self.OverallRatingView.halfRatings = true
                                        self.Scrollview.addSubview(self.OverallRatingView)
                                        
                                        
                                        
                                        self.AmbienceRatinglabel  = createLabel(CGRect(x: self.OverallRatingView.frame.origin.x,y: self.OverallRatingView.frame.size.height+self.OverallRatingView.frame.origin.y+10,width: lineView4.frame.size.width, height: 20), text: NSLocalizedString("Ambience",  comment: "") , alignment: .center, textColor: textColorDark)
                                        self.AmbienceRatinglabel.font = UIFont(name: fontName, size: FONTSIZEMedium)
                                        self.AmbienceRatinglabel.textAlignment =  NSTextAlignment.left;
                                        self.Scrollview.addSubview(self.AmbienceRatinglabel)
                                        
                                        
                                        // Required float rating view params
                                        self.AmbienceRatingView.frame = CGRect(x: self.OverallRatinglabel.frame.origin.x, y: self.AmbienceRatinglabel.frame.origin.y+self.AmbienceRatinglabel.frame.size.height, width: 95, height: 20)
                                        self.AmbienceRatingView.emptyImage = UIImage(named: "graystar.png")
                                        self.AmbienceRatingView.fullImage = UIImage(named: "yellowStar.png")
                                        // Optional params
                                        self.AmbienceRatingView.delegate = self
                                        self.AmbienceRatingView.tag = 2
                                        self.AmbienceRatingView.contentMode = UIView.ContentMode.scaleAspectFit
                                        self.AmbienceRatingView.maxRating = 5
                                        self.AmbienceRatingView.minRating = 0
                                        //self.floatRatingView.rating = 2.5
                                        self.AmbienceRatingView.editable = true
                                        self.AmbienceRatingView.halfRatings = true
                                        self.Scrollview.addSubview(self.AmbienceRatingView)
                                        
                                        
                                        
                                        self.OrganizationRatinglabel  = createLabel(CGRect(x: self.OverallRatingView.frame.origin.x,y: self.AmbienceRatingView.frame.size.height+self.AmbienceRatingView.frame.origin.y+10,width: lineView4.frame.size.width, height: 20), text: NSLocalizedString("Organization",  comment: "") , alignment: .center, textColor: textColorDark)
                                        self.OrganizationRatinglabel.font = UIFont(name: fontName, size: FONTSIZEMedium)
                                        self.OrganizationRatinglabel.textAlignment =  NSTextAlignment.left;
                                        self.Scrollview.addSubview(self.OrganizationRatinglabel)
                                        
                                        
                                        // Required float rating view params
                                        self.OrganizationRatingView.frame = CGRect(x: self.OverallRatinglabel.frame.origin.x, y: self.OrganizationRatinglabel.frame.origin.y+self.OrganizationRatinglabel.frame.size.height, width: 95, height: 20)
                                        self.OrganizationRatingView.emptyImage = UIImage(named: "graystar.png")
                                        self.OrganizationRatingView.fullImage = UIImage(named: "yellowStar.png")
                                        // Optional params
                                        self.OrganizationRatingView.delegate = self
                                        self.OrganizationRatingView.tag = 3
                                        self.OrganizationRatingView.contentMode = UIView.ContentMode.scaleAspectFit
                                        self.OrganizationRatingView.maxRating = 5
                                        self.OrganizationRatingView.minRating = 0
                                        //self.floatRatingView.rating = 2.5
                                        self.OrganizationRatingView.editable = true
                                        self.OrganizationRatingView.halfRatings = true
                                        self.Scrollview.addSubview(self.OrganizationRatingView)
                                        
                                        if formvalue["review_rate_0"] != nil
                                        {
                                            self.OverallRatingView.rating = formvalue["review_rate_0"] as! Float
                                        }
                                        if formvalue["review_rate_15"] != nil
                                        {
                                            self.AmbienceRatingView.rating = formvalue["review_rate_15"] as! Float
                                        }

                                        if formvalue["review_rate_16"] != nil
                                        {
                                            self.OrganizationRatingView.rating = formvalue["review_rate_16"] as! Float
                                        }
 

                                    }
                                }
                                
 
                                
                            }
                            else
                            {
                                showToast(message: succeeded["message"] as! String, controller: self)
                                _ = self.navigationController?.popViewController(animated: true)
                            }
                        }
                        else
                        {
                            // Handle Server Side Error
                            if succeeded["message"] != nil
                            {
                                showToast(message: succeeded["message"] as! String, controller: self)
                            }
                        }
                })
                
        }
    }
    @objc func send()
    {
        
//        spinner.center = view.center
//        spinner.hidesWhenStopped = true
//        spinner.style = UIstyle.gray
//        view.addSubview(spinner)
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.center = self.view.center
        activityIndicatorView.startAnimating()

        self.view.endEditing(true)
        var parameters = [String:String]()
        let finalString = "\(loadingIcon)"
        btnCreate.title = finalString
        
        if SummaryTextview.text == "Summary"
        {
            summary = ""
        }
        else
        {
            summary = SummaryTextview.text
        }
        
        overall = OverallRatingView.rating
        ambience = AmbienceRatingView.rating
        organization = OrganizationRatingView.rating
        if(OverallRatingView.rating != 0.0)
        {
            parameters = ["body":"\(summary)","review_rate_0":"\(overall)","review_rate_15":"\(ambience)","review_rate_16":"\(organization)","review_id":"\(Review_id)"]
            post(parameters, url: url, method: "POST")
                {
                    (succeeded, msg) -> () in
                    DispatchQueue.main.async(execute: {
                            activityIndicatorView.stopAnimating()
                            if msg
                            {
                                contentFeedUpdate = true
                                if succeeded["body"] != nil
                                {
                                    showToast(message: succeeded["message"] as! String, controller: self)
                                    _ = self.navigationController?.popViewController(animated: true)
                                    
                                }
                                else
                                {
                                    showToast(message: succeeded["message"] as! String, controller: self)
                                    _ = self.navigationController?.popViewController(animated: true)
                                }
                            }
                            else
                            {
                                // Handle Server Side Error
                                if succeeded["message"] != nil
                                {
                                    showToast(message: succeeded["message"] as! String, controller: self)
                                }
                            }
                    })
                    
            }
        }
        else
        {
            
            showToast(message: "Feild is empty", controller: self)
            
        }
        
    }


}
