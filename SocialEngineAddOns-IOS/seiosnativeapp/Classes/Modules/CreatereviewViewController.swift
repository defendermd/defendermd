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

//  CreatereviewViewController.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 14/03/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit



class CreatereviewViewController: UIViewController,UIGestureRecognizerDelegate,UITextViewDelegate,FloatRatingViewDelegate
{
    var url : String!
    var Review_id : Int!
    var tittle:String!
    
    var btnCreate:UIBarButtonItem!
    var Scrollview = UIScrollView()
    var prosTextview: UITextView!
    var consTextview: UITextView!
    var OnelinesummaryTextview: UITextView!
    var SummaryTextview: UITextView!
    var checkboxYes:UIButton!
    var checkboxNo:UIButton!
    var Yeslabel:UILabel!
    var Nolabel:UILabel!
    var Recomendedlabel:UILabel!
    var Descriptionlabel:UILabel!
    
    var OverallRatinglabel:UILabel!
    var OverallRatingView = FloatRatingView()
    
    var AmbienceRatinglabel:UILabel!
    var AmbienceRatingView = FloatRatingView()
    
    var OrganizationRatinglabel:UILabel!
    var OrganizationRatingView = FloatRatingView()
    
    
    var pros:String!
    var cons:String!
    var oneline:String!
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
        self.title = NSLocalizedString("Write a Review",  comment: "")
        
        overall = 0.0
        ambience = 0.0
        organization = 0.0
        
        btnCreate = UIBarButtonItem(title: "\u{f1d8}", style: UIBarButtonItem.Style.done , target:self , action: #selector(CreatereviewViewController.send))
        
        btnCreate.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "FontAwesome", size: FONTSIZELarge)!], for: UIControl.State())
        self.navigationItem.rightBarButtonItem = btnCreate
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(CreatereviewViewController.cancel))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem

//        
        Scrollview.frame = CGRect(x: 0, y: TOPPADING, width: view.frame.size.width, height: view.frame.size.height)
        Scrollview.isUserInteractionEnabled = true
        Scrollview.backgroundColor = UIColor.clear
        Scrollview.isScrollEnabled = true
        Scrollview.isUserInteractionEnabled = true
        Scrollview.contentSize = CGSize(width: view.frame.size.width,height: 1000)
        view.addSubview(Scrollview)
        
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CreatereviewViewController.resignKeyboard))
        tap.delegate = self
        tap.cancelsTouchesInView = false;
        Scrollview.addGestureRecognizer(tap)
        
        
        
        prosTextview = createTextView(CGRect(x: 10,y: -54, width: self.view.bounds.width-20, height: 30), borderColor: borderColorClear, corner: false)
        prosTextview.delegate = self
        prosTextview.isHidden = false
        prosTextview.text = NSLocalizedString("Pros",  comment: "")
        prosTextview.font = UIFont(name: fontName, size: FONTSIZEMedium)
        prosTextview.textColor = placeholderColor
        prosTextview.backgroundColor = bgColor
        
        prosTextview.autocorrectionType = UITextAutocorrectionType.no
        Scrollview.addSubview(prosTextview)
        
        
        let lineView1 = UIView(frame: CGRect(x: 10,y: prosTextview.frame.size.height+prosTextview.frame.origin.y ,width: prosTextview.frame.size.width,height: 1))
        lineView1.layer.borderWidth = 1.0
        lineView1.layer.borderColor = textColorMedium.cgColor
        Scrollview.addSubview(lineView1)
        
        
        consTextview = createTextView(CGRect(x: 10,y: prosTextview.frame.size.height + prosTextview.frame.origin.y + 10, width: prosTextview.bounds.width, height: 30), borderColor: borderColorClear, corner: false )
        consTextview.delegate = self
        consTextview.isHidden = false
        consTextview.text = NSLocalizedString("Cons",  comment: "")
        consTextview.font = UIFont(name: fontName, size: FONTSIZEMedium)
        consTextview.textColor = placeholderColor
        consTextview.backgroundColor = bgColor
        
        consTextview.autocorrectionType = UITextAutocorrectionType.no
        Scrollview.addSubview(consTextview)
        
        
        let lineView2 = UIView(frame: CGRect(x: 10,y: consTextview.frame.size.height+consTextview.frame.origin.y ,width: consTextview.frame.size.width,height: 1))
        lineView2.layer.borderWidth = 1.0
        lineView2.layer.borderColor = textColorMedium.cgColor
        Scrollview.addSubview(lineView2)
        
        OnelinesummaryTextview = createTextView(CGRect(x: 10,y: consTextview.frame.size.height + consTextview.frame.origin.y + 10, width: consTextview.bounds.width, height: 30), borderColor: borderColorClear, corner: false )
        OnelinesummaryTextview.delegate = self
        OnelinesummaryTextview.isHidden = false
        OnelinesummaryTextview.text = NSLocalizedString("One-line summary",  comment: "")
        OnelinesummaryTextview.font = UIFont(name: fontName, size: FONTSIZEMedium)
        OnelinesummaryTextview.textColor = placeholderColor
        OnelinesummaryTextview.backgroundColor = bgColor
        
        OnelinesummaryTextview.autocorrectionType = UITextAutocorrectionType.no
        Scrollview.addSubview(OnelinesummaryTextview)
        
        
        let lineView3 = UIView(frame: CGRect(x: 10,y: OnelinesummaryTextview.frame.size.height+OnelinesummaryTextview.frame.origin.y ,width: OnelinesummaryTextview.frame.size.width,height: 1))
        lineView3.layer.borderWidth = 1.0
        lineView3.layer.borderColor = textColorMedium.cgColor
        Scrollview.addSubview(lineView3)
        
        
        SummaryTextview = createTextView(CGRect(x: 10,y: OnelinesummaryTextview.frame.size.height + OnelinesummaryTextview.frame.origin.y + 10, width: OnelinesummaryTextview.bounds.width-20, height: 30), borderColor: borderColorClear, corner: false )
        SummaryTextview.delegate = self
        SummaryTextview.isHidden = false
        SummaryTextview.text = NSLocalizedString("Summary",  comment: "")
        SummaryTextview.font = UIFont(name: fontName, size: FONTSIZEMedium)
        SummaryTextview.textColor = placeholderColor
        SummaryTextview.backgroundColor = bgColor
        
        SummaryTextview.autocorrectionType = UITextAutocorrectionType.no
        Scrollview.addSubview(SummaryTextview)
        
        
        let lineView4 = UIView(frame: CGRect(x: 10,y: SummaryTextview.frame.size.height+SummaryTextview.frame.origin.y ,width: prosTextview.frame.size.width,height: 1))
        lineView4.layer.borderWidth = 1.0
        lineView4.layer.borderColor = textColorMedium.cgColor
        Scrollview.addSubview(lineView4)
        
        
        
        
        Recomendedlabel  = createLabel(CGRect(x: lineView4.frame.origin.x,y: lineView4.frame.size.height+lineView4.frame.origin.y+10,width: lineView4.frame.size.width, height: 20), text: NSLocalizedString("Recommended",  comment: "") , alignment: .left, textColor: textColorDark)
        Recomendedlabel.font = UIFont(name: fontName, size: FONTSIZEMedium)
        Recomendedlabel.textAlignment =  NSTextAlignment.left;
        Scrollview.addSubview(Recomendedlabel)
        
        Descriptionlabel  = createLabel(CGRect(x: Recomendedlabel.frame.origin.x,y: Recomendedlabel.frame.size.height+Recomendedlabel.frame.origin.y,width: Recomendedlabel.frame.size.width, height: 20), text: NSLocalizedString("Would you recommend  to a friend?",  comment: "") , alignment: .left, textColor: textColorMedium)
        Descriptionlabel.font = UIFont(name: fontName, size: FONTSIZEMedium)
        Descriptionlabel.textAlignment =  NSTextAlignment.left;
        Scrollview.addSubview(Descriptionlabel)
        
        checkboxYes = createButton(CGRect(x: Descriptionlabel.frame.origin.x,y: Descriptionlabel.frame.size.height+Descriptionlabel.frame.origin.y+10, width: 20 , height: 20), title: "", border: false,bgColor: false, textColor: textColorMedium )
        checkboxYes.setImage(UIImage(named: "unchecked.png"), for: UIControl.State())
        checkboxYes.setImage(UIImage(named: "checked.png"), for: UIControl.State.selected)
        checkboxYes.addTarget(self, action: #selector(CreatereviewViewController.checkboxYesAction(_:)), for: .touchUpInside)
        checkboxYes.tag = 0
        Scrollview.addSubview(checkboxYes)
        checkboxYes.isSelected = true
        
        Yeslabel  = createLabel(CGRect(x: checkboxYes.frame.origin.x+25,y: Descriptionlabel.frame.size.height+Descriptionlabel.frame.origin.y+10,width: 225, height: 20), text: NSLocalizedString("Yes",  comment: "") , alignment: .center, textColor: textColorMedium)
        Yeslabel.font = UIFont(name: fontName, size: FONTSIZEMedium)
        Yeslabel.textAlignment =  NSTextAlignment.left;
        Scrollview.addSubview(Yeslabel)
        
        
        checkboxNo = createButton(CGRect(x: checkboxYes.frame.origin.x,y: checkboxYes.frame.size.height+checkboxYes.frame.origin.y+10, width: 20 , height: 20), title: "", border: false,bgColor: false, textColor: textColorMedium)
        checkboxNo.setImage(UIImage(named: "unchecked.png"), for: UIControl.State())
        checkboxNo.setImage(UIImage(named: "checked.png"), for: UIControl.State.selected)
        checkboxNo.addTarget(self, action: #selector(CreatereviewViewController.checkboxNoAction(_:)), for: .touchUpInside)
        checkboxNo.tag = 0
        Scrollview.addSubview(checkboxNo)
        checkboxNo.isSelected = false
        
        Nolabel  = createLabel(CGRect(x: checkboxNo.frame.origin.x+25,y: checkboxYes.frame.size.height+checkboxYes.frame.origin.y+10,width: 225, height: 20), text: NSLocalizedString("No",  comment: "") , alignment: .center, textColor: textColorMedium)
        Nolabel.font = UIFont(name: fontName, size: FONTSIZEMedium)
        Nolabel.textAlignment =  NSTextAlignment.left;
        Scrollview.addSubview(Nolabel)
        
        
        OverallRatinglabel  = createLabel(CGRect(x: checkboxNo.frame.origin.x,y: Nolabel.frame.size.height+Nolabel.frame.origin.y+10,width: OnelinesummaryTextview.frame.size.width, height: 20), text: NSLocalizedString("Overall Rating",  comment: "") , alignment: .left, textColor: textColorDark)
        OverallRatinglabel.font = UIFont(name: fontName, size: FONTSIZEMedium)
        OverallRatinglabel.textAlignment =  NSTextAlignment.left;
        Scrollview.addSubview(OverallRatinglabel)
        
        
        // Required float rating view params
        OverallRatingView.frame = CGRect(x: OverallRatinglabel.frame.origin.x, y: OverallRatinglabel.frame.origin.y+OverallRatinglabel.frame.size.height, width: 95, height: 20)
        OverallRatingView.emptyImage = UIImage(named: "graystar.png")
        OverallRatingView.fullImage = UIImage(named: "yellowStar.png")
        // Optional params
        OverallRatingView.delegate = self
        OverallRatingView.tag = 1
        OverallRatingView.contentMode = UIView.ContentMode.scaleAspectFit
        OverallRatingView.maxRating = 5
        OverallRatingView.minRating = 0
        //self.floatRatingView.rating = 2.5
        OverallRatingView.editable = true
        OverallRatingView.halfRatings = true
        Scrollview.addSubview(OverallRatingView)
        
        
        
        AmbienceRatinglabel  = createLabel(CGRect(x: OverallRatingView.frame.origin.x,y: OverallRatingView.frame.size.height+OverallRatingView.frame.origin.y+10,width: OnelinesummaryTextview.bounds.width-20, height: 20), text: NSLocalizedString("Ambience",  comment: "") , alignment: .center, textColor: textColorDark)
        AmbienceRatinglabel.font = UIFont(name: fontName, size: FONTSIZEMedium)
        AmbienceRatinglabel.textAlignment =  NSTextAlignment.left;
        Scrollview.addSubview(AmbienceRatinglabel)
        
        
        // Required float rating view params
        AmbienceRatingView.frame = CGRect(x: OverallRatinglabel.frame.origin.x, y: AmbienceRatinglabel.frame.origin.y+AmbienceRatinglabel.frame.size.height, width: 95, height: 20)
        AmbienceRatingView.emptyImage = UIImage(named: "graystar.png")
        AmbienceRatingView.fullImage = UIImage(named: "yellowStar.png")
        // Optional params
        AmbienceRatingView.delegate = self
        AmbienceRatingView.tag = 2
        AmbienceRatingView.contentMode = UIView.ContentMode.scaleAspectFit
        AmbienceRatingView.maxRating = 5
        AmbienceRatingView.minRating = 0
        //self.floatRatingView.rating = 2.5
        AmbienceRatingView.editable = true
        AmbienceRatingView.halfRatings = true
        Scrollview.addSubview(AmbienceRatingView)
        
        
        
        OrganizationRatinglabel  = createLabel(CGRect(x: OverallRatingView.frame.origin.x,y: AmbienceRatingView.frame.size.height+AmbienceRatingView.frame.origin.y+10,width: OnelinesummaryTextview.bounds.width-20, height: 20), text: NSLocalizedString("Organization",  comment: "") , alignment: .center, textColor: textColorDark)
        OrganizationRatinglabel.font = UIFont(name: fontName, size: FONTSIZEMedium)
        OrganizationRatinglabel.textAlignment =  NSTextAlignment.left;
        Scrollview.addSubview(OrganizationRatinglabel)
        
        
        // Required float rating view params
        OrganizationRatingView.frame = CGRect(x: OverallRatinglabel.frame.origin.x, y: OrganizationRatinglabel.frame.origin.y+OrganizationRatinglabel.frame.size.height, width: 95, height: 20)
        OrganizationRatingView.emptyImage = UIImage(named: "graystar.png")
        OrganizationRatingView.fullImage = UIImage(named: "yellowStar.png")
        // Optional params
        OrganizationRatingView.delegate = self
        OrganizationRatingView.tag = 3
        OrganizationRatingView.contentMode = UIView.ContentMode.scaleAspectFit
        OrganizationRatingView.maxRating = 5
        OrganizationRatingView.minRating = 0
        //self.floatRatingView.rating = 2.5
        OrganizationRatingView.editable = true
        OrganizationRatingView.halfRatings = true
        Scrollview.addSubview(OrganizationRatingView)
        
        
        
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
    // MARK: Action Events
    @objc func checkboxYesAction(_ sender:UIButton!)
    {
        self.view.endEditing(true)
        DispatchQueue.main.async(execute: {
            
            if sender.isSelected == false
            {
                sender.isSelected = true;
                self.checkboxNo.isSelected = false
                
                
            }
            else
            {
                sender.isSelected = false;
                self.checkboxYes.isSelected = true
                
            }
        });
    }
    
    @objc func checkboxNoAction(_ sender:UIButton!)
    {
        self.view.endEditing(true)
        DispatchQueue.main.async(execute: {
            
            if sender.isSelected == false
            {
                sender.isSelected = true;
                self.checkboxYes.isSelected = false
                
                
            }
            else
            {
                sender.isSelected = false;
                self.checkboxYes.isSelected = true
                
            }
        });
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
            overall = ratingView.rating
        }
        else if ratingView.tag == 2
        {
            ambience = ratingView.rating
            
        }
        else if ratingView.tag == 3
        {
            organization = ratingView.rating
            
            
        }
        
        self.view.endEditing(true)
        
    }
    
    @objc func send()
    {
        self.view.endEditing(true)
        var parameters = [String:String]()
        let finalString = "\(loadingIcon)"
        btnCreate.title = finalString
        if prosTextview.text == "Pros"
        {
            pros = ""
        }
        else
        {
            pros = prosTextview.text
        }
        
        
        if consTextview.text == "Cons"
        {
            cons = ""
        }
        else
        {
            cons = consTextview.text
        }
        
        
        if OnelinesummaryTextview.text == "One-line summary"
        {
            oneline = ""
        }
        else
        {
            oneline = OnelinesummaryTextview.text
        }
        
        
        if SummaryTextview.text == "Summary"
        {
            summary = ""
        }
        else
        {
            summary = SummaryTextview.text
        }
        if(pros != "") || (cons != "") || (oneline != "") || (summary != "") || (overall != 0.0)
        {
            
            parameters = ["pros":"\(pros)","cons":"\(cons)","title":"\(oneline)","body":"\(summary)","review_rate_0":"\(overall)","review_rate_15":"\(ambience)","review_rate_16":"\(organization)"]
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
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        
    }
    
    
}
