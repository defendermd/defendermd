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
//  SEError.swift
//  seiosnativeapp
//

import Foundation
import UIKit

let validationMsg = createValidationLabel(CGRect(x: 0, y: 0, width: 400 , height: 40), text: "", alignment: .center, textColor: UIColor.white, bgColor: UIColor.black)
var timer = Timer()
var network_status_msg = NSLocalizedString("No Internet Connection", comment: "")

let unconditionalMessage = "Oops, Something went wrong"

// Present Custom Alert
func showCustomAlert(_ centerPoint: CGPoint, msg: String){
    validationMsg.alpha = 0.0
    let size =  findvalidationMsgSize()
    validationMsg.frame = CGRect(x: centerPoint.x, y: centerPoint.y - size.height+10, width: 0, height: 0)
    
    // Animation For Custom Alert
    UIView.animate(withDuration: 0.5, animations: {
        
        validationMsg.text = msg
        validationMsg.frame = CGRect(x: centerPoint.x-size.width/2, y: centerPoint.y - size.height*2,width: size.width , height: size.height)
        validationMsg.alpha = 1.0
        
    })
}

// Define Custom Alert Message Size
func findvalidationMsgSize()->CGSize{
    var labelSize = CGSize()
    // Define Custom Alert Size by Device
    if(UIDevice.current.userInterfaceIdiom == .pad){
        labelSize.width = 400
    }else if(UIDevice.current.userInterfaceIdiom == .phone){
        labelSize.width = 300
    }
    labelSize.height = 40
    
    return labelSize
}

// Generate Custom Alert Label
func createValidationLabel(_ frame:CGRect, text:String, alignment: NSTextAlignment, textColor:UIColor, bgColor: UIColor)-> UILabel{
    let label = UILabel(frame: frame)
    label.text = text
    label.textAlignment = alignment
    label.textColor = textColor
    label.adjustsFontSizeToFitWidth = true
    label.layer.cornerRadius = label.bounds.size.height/2.0
    label.layer.masksToBounds = true
    label.numberOfLines = 0
    label.backgroundColor = bgColor
    
    return label
}

// Create Timer
//func createTimer(_ target: AnyObject){
//  //  timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  Selector(("stopTimer")), userInfo: nil, repeats: false)
//   // timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  #selector(stopTimer), userInfo: nil, repeats: false)
//}

// Stop Timer
func stop()
{
    timer.invalidate()
    removeAlert()
}
func removeAlert(){
    // Animation For Remove Alert
    UIView.animate(withDuration: 0.5, animations: {
        validationMsg.frame = CGRect(x: validationMsg.center.x, y: validationMsg.center.y, width: 0, height: 0)
        validationMsg.alpha = 0.0
        validationMsg.removeFromSuperview()
    })

}
