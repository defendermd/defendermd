//
//  AppStyle.swift
//  seiosnativeapp
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


import Foundation
import UIKit



// MARK: - LoginViewController Style
// MARK: - Login Color & Border



let soundEffect = isSoundEffect()
func isSoundEffect() -> Bool {
    if isSoundEffects == 0 {
        return false
    }else{
        return true
    }
}
// GoogleAd enabled or not
let iscontentAd = isContentADenabled()
func isContentADenabled() -> Bool
{
    if ContentAD == 1
    {
        
        return true
    }
    else
    {
        return false
    }
}
// FacebookAd enabled or not
let isfacebookAd = isfacebookADenabled()
func isfacebookADenabled() -> Bool
{
    if isFacebookAd == 1
    {
        let floatVersion = (UIDevice.current.systemVersion as NSString).floatValue
        if floatVersion < 9.0
        {
            placementID = ""
            
        }
       return true
    }
    else
    {
        let floatVersion = (UIDevice.current.systemVersion as NSString).floatValue
        if floatVersion < 9.0
        {
           adUnitID = ""
        }
       return false
    }
}


let login_button_bg = UIColor(red: 0.175, green: 0.458, blue: 0.831, alpha: 1.0)
let login_button_border = UIColor.white.cgColor
let login_button_border_Width:CGFloat = 1.0
let login_button_cornerRadius:CGFloat = 3.0

//let login_textField_border = UIColor.blackColor().CGColor
let login_textField_border_width:CGFloat = 1.0
let login_textField_cornerRadius:CGFloat = 3.0

// MARK: - LoginFrameSize
let login_textField_Size = CGSize(width: 280, height: 40)
let login_button_Size = CGSize(width: 135, height: 40)


// Description Text Limit
let descriptionTextLimit = 200

let browseViewTextLimit = 30

// Placeholder Image BackgroundColor
let placeholderColor = UIColor(red: 192/255.0, green: 192/255.0, blue: 192/255.0, alpha: 1.0)//UIColor(red: 233/255.0, green: 233/255.0, blue: 233/255.0, alpha: 1.0)

// cleanBackgroundColor
let lightBgColor = UIColor.white

let dashboardCategoryBgColor = UIColor(red: 247/255.0, green: 247/255.0, blue: 247/255.0, alpha: 1.0)
let tabbedDashboardBgColor = UIColor.white

// Navigation Style
//let navColor = UIColor(red: 41/255 , green: 121/255 , blue: 255/255, alpha: 1.0) Blue color

let navColor = UIColor(red: 228/255 , green: 0/255 , blue: 70/255, alpha: 1.0) //Pink Color

let linkColor = UIColor(red: 41/255 , green: 121/255 , blue: 255/255, alpha: 1.0)

// App BgColor
let bgColor = UIColor(red: 247/255.0, green: 247/255.0, blue: 247/255.0, alpha: 1.0)

let aafBgColor = UIColor(red: 231/255.0, green: 231/255.0, blue: 231/255.0, alpha: 1.0)

// TableView BgColor
let tableViewBgColor = bgColor

// Bacground Color for all the UI element
let elementBgColor: UIColor = UIColor(red: 169/255.0, green: 92/255.0, blue: 246/255.0, alpha: 1.0)

// TableView SeparatorColor
let TVSeparatorColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)

// TableView SeparatorColor
let TVSeparatorColorClear = UIColor.clear

// TableView Cell Background Color
let cellBackgroundColor = UIColor(red: 207/255.0, green: 208/255.0, blue: 212/255.0, alpha: 1.0)

// Button Select Color
let buttonSelectColor = UIColor(red: 200/255.0, green: 200/255.0, blue: 200/255.0, alpha: 1.0) //UIColor.whiteColor()

// Button Deselec Color
let buttonDeSelectColor = UIColor.white //UIColor(red: 235/255.0, green: 235/255.0, blue: 235/255.0, alpha: 1.0)

// TabMenu BGColor
let TabMenubgColor = UIColor.white


// Heading TextColor
let HeadingTextColor:UIColor = UIColor.black
let DescriptionTextColor:UIColor = UIColor.lightGray


// Boader Width
let borderWidth:CGFloat =  1.0

// BoadrColor
let borderColorLight = UIColor.white
let borderColorMedium = UIColor(red: 236/255.0, green: 236/255.0, blue: 236/255.0, alpha: 1.0)
let borderColorDark = UIColor.black
let borderColorClear = UIColor.clear

// Shadow Color
let shadowColor = UIColor.lightGray

// Shadow Radius
let shadowRadius: CGFloat = 1.0

// Shadow Offset
let shadowOffset = CGSize(width: 0, height: 0.5)

// Shadow Opacity
let shadowOpacity: Float = 0.8

// Corner Radius
let cornerRadiusSmall: CGFloat = 3.0

// Corner RadiusFor Image
let cornerRadiusNormal: CGFloat = 5.0

// Button BackgroundColor
let buttonBgColor: UIColor = buttonColor

// TextColor Light
let textColorLight: UIColor = UIColor.white

// TextColor Light
let textColorMedium: UIColor = UIColor.gray

// TextColor Light
let textColorDark: UIColor =   UIColor(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1.0)


// like info
let likeInfo: UIColor =   UIColor(red: 96/255.0, green: 96/255.0, blue: 96/255.0, alpha: 1.0)

// TextColor clear
let textColorclear: UIColor =   UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.0)

// Status Box Icon's Color 
let videoIconColor: UIColor   =   UIColor(red: 222/255.0, green: 49/255.0, blue: 44/255.0, alpha: 1.0)
let PhotoIconColor: UIColor   =   UIColor(red: 137/255.0, green: 190/255.0, blue: 76/255.0, alpha: 1.0)
let CheckInIconColor: UIColor =   UIColor(red: 245/255.0, green: 21/255.0, blue: 111/255.0, alpha: 1.0)
let iconTextColor: UIColor =  UIColor(red: 41/255.0, green: 41/255.0, blue: 41/255.0, alpha: 1.0)
let tagIconColor : UIColor =   UIColor(red: 88/255.0, green: 144/255.0, blue: 255/255.0, alpha: 1.0)
let linkIconColor: UIColor   =   UIColor(red: 255/255.0, green: 123/255.0, blue: 98/255.0, alpha: 1.0)
let iconColor : UIColor = UIColor(red: 96/255 , green: 96/255 , blue: 96/255, alpha: 1.0)
let backgroundLightColor : UIColor = UIColor(red: 204/255 , green: 204/255 , blue: 204/255, alpha: 1.0)
let borderMediumColor : UIColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 0.0)
// Padding in App
let PADING = getPADING()

func getPADING() -> (CGFloat){
    var size:CGFloat = 5.0
    if(UIDevice.current.userInterfaceIdiom == .pad){
        size = 5.0
    }else{
        size = 3.0
    }
    return size
}


// Padding in App
let ImageViewPading = getImagePADING()

func getImagePADING() -> (CGFloat){
    var size:CGFloat = 0.1
    if(UIDevice.current.userInterfaceIdiom == .pad){
        size = 0.1
    }else{
        size = 0.1
    }
    return size
}

// ContentSeparatorPadding in App
let contentPADING = getContentPADING()

func getContentPADING() -> (CGFloat){
    var size:CGFloat = 10.0
    if(UIDevice.current.userInterfaceIdiom == .pad){
        size = 10.0
    }else{
        size = 6.0
    }
    return size
}

// Getting scrollview Y Postion according to ios 10 &11
let ScrollframeY = getscrollviewY()
func getscrollviewY() -> (CGFloat){
    var size:CGFloat = -64.0
    if #available(iOS 11.0, *) {
        size = 0
    }
     return size
}
// Padding in App
let TOPPADING = getTOPPADING()
func getTOPPADING() -> (CGFloat){
    var size:CGFloat = 64.0
    if(UIDevice.current.userInterfaceIdiom == .pad)
    {
        size = 74.0
    }
    else
    {
        if DeviceType.IS_IPHONE_X
        {
           size = 88.0
        }
        else{
            size = 64.0
        }
    }
    return size
}

let tabBarHeight = getTabBarHeight()
func getTabBarHeight() -> CGFloat {
    var tempHeight : CGFloat = 40.0
    if DeviceType.IS_IPHONE_X
    {
        tempHeight = 80.0
    }
    else{
        tempHeight = 40.0
    }
    return tempHeight
}

// Padding for main navigation menu
let NavButtonHeight = getButtonHeight1()
func getButtonHeight1() -> (CGFloat){
    var size:CGFloat = 50.0
    if(UIDevice.current.userInterfaceIdiom == .pad){
        size = 55.0
    }else{
        size = 50.0
    }
    return size / 1.0 //fontSizeScale()
}
// Padding in App
let ButtonHeight = getButtonHeight()

func getButtonHeight() -> (CGFloat){
    var size:CGFloat = 50.0
    if(UIDevice.current.userInterfaceIdiom == .pad){
        size = 45.0
    }else{
        size = 40.0
    }
    return size / 1.0 //fontSizeScale()
}

// Font Size in App

let FONTSIZEExtraLarge = getFONTSIZEExtraLarge()

func getFONTSIZEExtraLarge() -> (CGFloat){
    var size:CGFloat!
    if(UIDevice.current.userInterfaceIdiom == .pad){
        size = extraLargeFontSize + 10
    }else{
        size = extraLargeFontSize + 5
    }
    return size / 1.0 //fontSizeScale()
}

let FONTSIZELarge = getFONTSIZELarge()
func getFONTSIZEVeryLarge() -> (CGFloat){
    let size:CGFloat = veryLargeFontSize
    //    if(UIDevice.currentDevice().userInterfaceIdiom == .Pad){
    //        size = 24.0
    //    }else{
    //        size = 20.0
    //    }
    return size / 1.0 //fontSizeScale()
}
let FONTSIZEVeryLarge = getFONTSIZEVeryLarge()


func getFONTSIZELarge() -> (CGFloat){
    var size:CGFloat!
    if(UIDevice.current.userInterfaceIdiom == .pad){
        size = largeFontSize + 2
    }else{
        size = largeFontSize
    }
    return size / 1.0 //fontSizeScale()
}


let FONTSIZEMedium = getFONTSIZEMedium()

func getFONTSIZEMedium() -> (CGFloat){
    var size:CGFloat!
    if(UIDevice.current.userInterfaceIdiom == .pad){
        size = mediumFontSize + 2
    }else{
        size = mediumFontSize + 0.5
    }
    return size / 1.0 //fontSizeScale()
}


let FONTSIZENormal = getFONTSIZENormal()

func getFONTSIZENormal() -> (CGFloat){
    var size:CGFloat!
    if(UIDevice.current.userInterfaceIdiom == .pad){
        size = normalFontSize + 2
    }else{
        size = normalFontSize
    }
    return size / 1.0 //fontSizeScale()
}


let FONTSIZESmall = getFONTSIZESmall()

func getFONTSIZESmall() -> (CGFloat){
    var size:CGFloat!
    if(UIDevice.current.userInterfaceIdiom == .pad){
        size = smallFontSize + 1
    }else{
        size = smallFontSize
    }
    return size / 1.0 //fontSizeScale()
}

let FONTSIZEVerySmall = getFONTSIZEVerySmall()

func getFONTSIZEVerySmall() -> (CGFloat){
    var size:CGFloat!
    if(UIDevice.current.userInterfaceIdiom == .pad){
        size = verySmallFontSize + 1
    }else{
        size = verySmallFontSize
    }
    return size / 1.0 //fontSizeScale()
}

func animationEffectOnButton(_ sender:UIButton){
    sender.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
    UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveLinear], animations: { () -> Void in
        sender.transform = CGAffineTransform.identity
        }) { (animationCompleted: Bool) -> Void in
    }
    
}

func animationEffectWithImageOnButton(_ sender:UIButton){
    sender.imageView?.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
    UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveLinear], animations: { () -> Void in
        sender.imageView?.transform = CGAffineTransform.identity
        }) { (animationCompleted: Bool) -> Void in
    }
}



let fontName = "HelveticaNeue" //"ArialMT"//"BebasNeueRegular"
let fontBold = "HelveticaNeue-Bold"//"HelveticaNeue-Medium"//"Arial-BoldMT"//"BebasNeueBold"
let iConfontName = "fontawesome"
let fontNormal = "HelveticaNeue"
