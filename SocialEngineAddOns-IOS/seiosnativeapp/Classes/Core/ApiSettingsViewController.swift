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

//  ApiSettingsViewController.swift

import UIKit

class ApiSettingsViewController: UIViewController, UITextFieldDelegate {
    let mainView = UIView()
    var refreshCounter: UITextField!
    var submit:UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "API Settings"
        openMenu = false
        view.backgroundColor = bgColor
        
        let subViews = mainView.subviews
        for subview in subViews{
            subview.removeFromSuperview()
        }
        mainView.frame = view.frame
        mainView.backgroundColor = bgColor
        view.addSubview(mainView)
        let menu = UIBarButtonItem(title:dashboardIcon, style: UIBarButtonItem.Style.plain , target:self , action: #selector(ApiSettingsViewController.openSlideMenu))
        menu.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "FontAwesome", size: FONTSIZEExtraLarge)!], for: UIControl.State())
        self.navigationItem.leftBarButtonItem = menu
        
        
        let title = createLabel(CGRect(x: 10, y: 80, width: 300, height: 30), text: "Refresh MainMenu After Counter", alignment: .left, textColor: textColorDark)
        title.font = UIFont.boldSystemFont(ofSize: 18.0)
        mainView.addSubview(title)
        
        let subTitle = createLabel(CGRect(x: 10, y: 110, width: view.bounds.width-20, height: 60), text: "Counter is increased by 1 everytime when you change the Module \nIf Refresh MainMenu After Counter is blank/0 MainMenu is refreshed EveryTime.", alignment: .left, textColor: textColorMedium)
        subTitle.adjustsFontSizeToFitWidth = true
        subTitle.textColor = textColorMedium
        subTitle.numberOfLines = 0
        mainView.addSubview(subTitle)
        
        refreshCounter = createTextField(CGRect(x: 10, y: 175, width: view.bounds.width-20, height: 40), borderColor: borderColorMedium, placeHolderText: "Refresh Count", corner: true)
        refreshCounter.text = String(menuRefreshConterLimit)
        refreshCounter.keyboardType = UIKeyboardType.numberPad
        refreshCounter.delegate = self
        mainView.addSubview(refreshCounter)
        
        
        submit = createButton(CGRect(x: 10,y: 390 , width: 200, height: 40), title: "Save", border: true,bgColor: false, textColor: textColorDark)
        submit.backgroundColor = navColor
        submit.addTarget(self, action: #selector(ApiSettingsViewController.saveContent), for: .touchUpInside)
        mainView.addSubview(submit)
    }
    
    // Show Slide Menu
    @objc func openSlideMenu(){
        
        // Add TapGesture On Open Slide Menu
        if openMenu{
            openMenu = false
        }else{
            openMenu = true
            tapGesture = tapGestureCreation(self)
        }
        openMenuSlideOnView(mainView)
    }
    
    // Handle TapGesture On Open Slide Menu
    func handleTap(_ recognizer: UITapGestureRecognizer) {
        openMenu = false
        openMenuSlideOnView(mainView)
        mainView.removeGestureRecognizer(tapGesture)
    }
    
    
    // Generate Custom Alert Messages
    func showAlertMessage( _ centerPoint: CGPoint, msg: String){
        self.view .addSubview(validationMsg)
        showCustomAlert(centerPoint, msg: msg)
        // Initialization of Timer
       self.createTimer(self)
    }
    
    
    // Stop Timer
    @objc func stopTimer() {
        stop()
    }
    func createTimer(_ target: AnyObject){
        timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  #selector(stopTimer), userInfo: nil, repeats: false)
    }
    @objc func saveContent(){
        refreshCounter.resignFirstResponder()
        if refreshCounter.text == ""{
            refreshCounter.text = "0"
        }
        menuRefreshConterLimit = (refreshCounter.text)!
        // var userDefaults = NSUserDefaults.standardUserDefaults()
        showAlertMessage(mainView.center , msg: "Saved!")
    }
    
    
    func textField(_ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String) -> Bool {
            
            // Create an `NSCharacterSet` set which includes everything *but* the digits
            let inverseSet = CharacterSet(charactersIn:"0123456789").inverted
            
            // At every character in this "inverseSet" contained in the string,
            // split the string up into components which exclude the characters
            // in this inverse set
            let components = string.components(separatedBy: inverseSet)
            
            // Rejoin these components
            var filtered = components.joined(separator: "")
            
            // Perform BackSpace
            if string == "" && filtered.length>=1 {
                filtered = (filtered as NSString).substring(to: filtered.length-1)
            }
            
            // If the original string is equal to the filtered string, i.e. if no
            // inverse characters were present to be eliminated, the input is valid
            // and the statement returns true; else it returns false
            
            let newLength = textField.text!.length + string.length - range.length
            
            return string == filtered && newLength <= 4
            
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  
}
