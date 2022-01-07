//
//  MessageComposeViewController.swift
//  seiosnativeapp
//
//  Created by bigstep on 20/05/15.
//  Copyright (c) 2015 bigstep. All rights reserved.
//

import UIKit

class MessageComposeViewController: UIViewController {
    
    
    var toLabel : UILabel!
    var subjectLabel : UILabel!
    var contentLabel : UILabel!
    
    var toLabelText : UITextField!
    var subjectLabelText : UITextField!
    var contentLabelText : UITextField!
    
    var submitButton : UIButton!
    
    override func viewDidLoad() {
    
        super.viewDidLoad()
        view.backgroundColor = bgColor
        self.title = "Compose Message"
        
        toLabel = createLabel(CGRectMake(PADING + 20, TOPPADING+50, 100, 20), "To", .Left, textColorDark)
        toLabel.text = "To"
        view.addSubview(toLabel)
        
        
        subjectLabel = createLabel(CGRectMake(PADING + 20, TOPPADING+120, 100, 20), "Subject", .Left, textColorDark)
        subjectLabel.text = "Subject"
        view.addSubview(subjectLabel)
        
        
        contentLabel = createLabel(CGRectMake(PADING + 20, TOPPADING+170, 100, 20), "Message", .Left, textColorDark)
        contentLabel.text = "Message"
        view.addSubview(contentLabel)
        
        
        toLabelText = createTextField(CGRectMake(PADING + 20, TOPPADING+80, CGRectGetWidth(view.bounds)/2, 40), borderColorDark, "To", true)
        
        view.addSubview(toLabelText)
        
        subjectLabelText = createTextField(CGRectMake(PADING + 20, TOPPADING+160, CGRectGetWidth(view.bounds)/2, 40), borderColorDark, "Subject", true)
        
        view.addSubview(subjectLabelText)
        
        contentLabelText = createTextField(CGRectMake(PADING + 20, TOPPADING+220, CGRectGetWidth(view.bounds) - PADING - 40, 100), borderColorDark, "Message", true)
        
        view.addSubview(contentLabelText)
        
        submitButton = createButton(CGRectMake(PADING + 20, TOPPADING+330, CGRectGetWidth(view.bounds) - PADING - 40, ButtonHeight), "Send" , true, true, textColorLight)
        
        
        view.addSubview(submitButton)
        
        
        
        
        
    }
   
    
   
}
