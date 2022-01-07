//
//  CouponDetailView.swift
//  seiosnativeapp
//
//  Created by Bigstep IOS on 8/12/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit
var configArray = Dictionary<String, String>()

class AdsReportViewController: UIView, UITextFieldDelegate {
    
    var origin_labelheight_y : CGFloat = 0
    var addDescription : TTTAttributedLabel!
    var label1 : UIButton!
    var label3 : UIButton!
    var otherReasonText : UITextField!
    var done : UIButton!
    var viewLine : UIView!
    var btnSubmit : UIButton!
    var undo : UIButton!
    var adsType : Int!
    var parametersNeedToAdd = Dictionary<String, String>()
    
    override init(frame: CGRect) {
        super.init(frame : frame)
        self.backgroundColor = UIColor.white
        self.alpha = 1.0
        self.isOpaque = false
        
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowOffset = shadowOffset
        self.layer.cornerRadius = 3
        
        
        
    }
    func showMenu(dic : NSDictionary, parameters : Dictionary<String, String>, view : UIViewController){
        
        parametersNeedToAdd = parameters
        var i = 0
        for (_,v) in dic{
            if "\(v)" != "Other"
            {
                configArray["\(i)"] = "\(v)"
                i = i + 1
            }
        }
        configArray["\(i)"] = "Other"

        
        var addDescriptionDetailString  = ""
        addDescriptionDetailString = NSLocalizedString("Report Ad", comment: "")
        addDescription = TTTAttributedLabel(frame:CGRect(x: PADING+5 , y:origin_labelheight_y + 5 , width: self.bounds.width-10, height: 40))
        addDescription.numberOfLines = 0
        addDescription.textAlignment = .center
        //addDescription.longPressLabel()
        addDescription.linkAttributes = [kCTForegroundColorAttributeName:textColorDark]
        addDescription.textColor = textColorDark
        addDescription.font = UIFont(name: fontBold, size: FONTSIZELarge+4)
        self.addDescription.tag = 1001
        self.addSubview(addDescription)
        
        self.addDescription.setText(addDescriptionDetailString, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
            
            let boldFont = CTFontCreateWithName((fontBold as CFString?)!, FONTSIZELarge+4, nil)
            let range = (addDescriptionDetailString as NSString).range(of: addDescriptionDetailString)
            mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range)
            mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorDark , range: range)
            return mutableAttributedString
        })
        

        
        origin_labelheight_y = origin_labelheight_y + self.addDescription.bounds.height + 10
        
        viewLine = createView(CGRect(x: PADING+10 , y:origin_labelheight_y , width: self.bounds.width-25, height: 1), borderColor: navColor , shadow: false)
        viewLine.backgroundColor = navColor
        self.addSubview(viewLine)
        
        origin_labelheight_y = origin_labelheight_y + viewLine.bounds.height + 12
        
        for (k,v) in configArray.sorted(by: { $0.0 < $1.0 }){
            
            self.label1 = createButton(CGRect(x:4 * PADING,y:origin_labelheight_y,width:200 , height:25), title: "\u{f10c}", border: false,bgColor: false, textColor: navColor)
            self.label1.isHidden = false
            self.label1.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZELarge)
            self.label1.tag = Int(k)!
            self.label1.addTarget(view, action:Selector(("pressedAd:")), for: UIControl.Event.touchUpInside)
            self.label1.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
//            self.addSubview(self.label1)

//            self.label3 = createButton(CGRect(x:self.label1.frame.origin.x + self.label1.bounds.width + (2 * PADING),y:origin_labelheight_y, width:150 , height:25), title: "\(v)", border: false,bgColor: false, textColor: textColorDark)
            self.label3 = createButton(CGRect(x: 20 + (4 * PADING),y:origin_labelheight_y, width:150 , height:25), title: "\(v)", border: false,bgColor: false, textColor: textColorDark)
            self.label3.isHidden = false
            self.label3.titleLabel?.font = UIFont(name: fontName, size: FONTSIZELarge)
            self.label3.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
            if self.label3.bounds.height >  self.label1.bounds.height {
                origin_labelheight_y  = origin_labelheight_y + self.label3.bounds.height + 12
            }
            else{
                origin_labelheight_y  = origin_labelheight_y + self.label1.bounds.height + 12
            }
            self.label3.tag = 1003
            self.addSubview(self.label3)
            self.addSubview(self.label1)
            
        }
        
        otherReasonText = createTextField(CGRect(x: 4 * PADING, y: origin_labelheight_y - 5, width: self.bounds.width - (4 * PADING ), height: 30), borderColor: borderColorClear , placeHolderText:  NSLocalizedString("Type your reason here...",  comment: ""), corner: true)
        otherReasonText.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Type your reason here...",  comment: ""), attributes: [NSAttributedString.Key.foregroundColor: placeholderColor])
        otherReasonText.font =  UIFont(name: fontBold, size: FONTSIZEMedium)
        otherReasonText.delegate = self
        otherReasonText.backgroundColor = UIColor.white
        otherReasonText.autocorrectionType = UITextAutocorrectionType.no
        otherReasonText.isHidden = true
        self.otherReasonText.tag = 1004
        self.addSubview(self.otherReasonText)
        
        origin_labelheight_y  = origin_labelheight_y + self.otherReasonText.bounds.height + 15
        
        self.done = createButton(CGRect(x:15, y:origin_labelheight_y , width:self.bounds.width/2 - 20 , height:40), title:  NSLocalizedString("Submit",  comment: ""), border: true,bgColor: true, textColor: textColorPrime)
        self.done.isHidden = true
        self.done.tag = 1000
        self.done.backgroundColor = navColor
        done.layer.shadowColor = navColor.cgColor
        done.layer.borderColor = navColor.cgColor
        done.layer.cornerRadius = cornerRadiusSmall
        self.done.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZEMedium)
       // self.done.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
        self.addSubview(self.done)
        self.done.addTarget(view, action:Selector(("removeOtherReason")), for: UIControl.Event.touchUpInside)
        
        self.undo = createButton(CGRect(x:self.bounds.width/2.0 + 5,y:origin_labelheight_y ,width:self.bounds.width/2 - 20 , height:40), title: NSLocalizedString("Cancel",  comment: ""), border: true,bgColor: true, textColor: textColorPrime)
//        self.undo.setImage(UIImage(named: "cross")!.maskWithColor(color: textColorDark), for: UIControl.State())
        self.undo.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZEMedium)
       // self.undo.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        self.undo.addTarget(view, action: Selector(("doneAfterReportSelect")), for: UIControl.Event.touchUpInside)
        self.undo.tag = 1002
        undo.layer.shadowColor = navColor.cgColor
        undo.layer.borderColor = navColor.cgColor
        undo.layer.cornerRadius = cornerRadiusSmall
        self.addSubview(self.undo)
        
        self.btnSubmit = createButton(CGRect(x:15, y:origin_labelheight_y , width:self.bounds.width/2 - 20 , height:40), title:  NSLocalizedString("Submit",  comment: ""), border: true,bgColor: true, textColor: textColorPrime)
      //  self.btnSubmit.isHidden = true
        self.btnSubmit.tag = 1005
        self.btnSubmit.isUserInteractionEnabled = false
        self.btnSubmit.backgroundColor = navColor
        self.btnSubmit.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZEMedium)
        btnSubmit.layer.shadowColor = navColor.cgColor
        btnSubmit.layer.borderColor = navColor.cgColor
        btnSubmit.layer.cornerRadius = cornerRadiusSmall
      //  self.btnSubmit.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
        self.addSubview(self.btnSubmit)
        self.btnSubmit.addTarget(view, action:Selector(("submitReasonPressed")), for: UIControl.Event.touchUpInside)
        self.btnSubmit.alpha = 0.3
        
        origin_labelheight_y  = origin_labelheight_y + self.label3.bounds.height + 15
        self.frame.size.height = origin_labelheight_y + 15
        
    }
    func doneAfterReportSelect(_ sender : UIButton)
    {
    
        
    }
    private func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        if textView.textColor == placeholderColor {
            textView.text = nil
            textView.textColor = textColorDark
            
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.endEditing(true)
        return true;
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
