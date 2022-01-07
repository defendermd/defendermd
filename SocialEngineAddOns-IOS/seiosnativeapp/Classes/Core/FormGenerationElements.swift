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

//  FormGenerationElements.swift

import Foundation
import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}


// MARK: - Create Form Elements
var hideIndexFormArray = [Int]()
var defaultCategory : String!
var defaultrepeatid : String!
var defaultsubsubCategory : String!
var defaultsubCategory : String!
var defaultHostType : String = ""
var tittleText : String!
var isonline:Int!
var isheader:Bool = true
var istitleheader:Bool = true
var filterSearchFlag: Bool = false
var tagArray = [String]()
var termPrivacyUrl : String! = ""

// Creation Of UIView
func createView(_ frame:CGRect, borderColor:UIColor, shadow:Bool)-> UIView{
    let view = UIView(frame: frame)
    view.layer.borderColor = borderColor.cgColor
    view.layer.borderWidth = 1.0
    view.backgroundColor =  UIColor.white
    if shadow {
        view.layer.shadowColor = shadowColor.cgColor
        view.layer.shadowOffset = shadowOffset
        view.layer.shadowRadius = shadowRadius
        view.layer.shadowOpacity = shadowOpacity
    }
    
    return view
}


// Creation Of Label
func createLabel(_ frame:CGRect, text:String, alignment: NSTextAlignment, textColor:UIColor)-> UILabel {
    let label = UILabel(frame: frame)
    label.text = text
    label.textAlignment = alignment
    label.lineBreakMode = NSLineBreakMode.byWordWrapping
    label.textColor = textColor
    return label
}

// Creation Of TextField
func createTextField(_ frame:CGRect, borderColor: UIColor, placeHolderText: String, corner: Bool ) -> UITextField{
    let textField = UITextField(frame: frame)
    textField.placeholder = placeHolderText
    textField.backgroundColor = UIColor.white
    textField.layer.borderColor = borderColor.cgColor
    textField.layer.borderWidth = borderWidth
    textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 20))
    textField.leftViewMode  = UITextField.ViewMode.always
    if corner{
        textField.layer.cornerRadius = cornerRadiusSmall
    }
    textField.textColor = UIColor.black
    return textField
}
// Creation Of Animated TextField on login page
func createSkyTextField(_ frame:CGRect, borderColor: UIColor, placeHolderText: String ,corner: Bool) -> UITextField{
    
    let textField = SkyFloatingLabelTextField(frame: frame)
    textField.placeholder = placeHolderText
    textField.backgroundColor = textColorLight
    textField.layer.borderColor = borderColor.cgColor
    textField.layer.borderWidth = borderWidth
    textField.font = UIFont(name: "fontAwesome", size: FONTSIZEMedium)
    textField.tintColor = elementBgColor // the color of the blinking cursor
    textField.textColor = textColorDark
    textField.lineColor = textColorLight
    textField.selectedTitleColor = buttonColor
    textField.selectedLineColor = textColorLight
    textField.errorColor = UIColor.red
    textField.lineHeight = 0.5 // bottom line height in points
    textField.selectedLineHeight = 0.5
    return textField
}

// Creation Of TextView
func createTextView(_ frame:CGRect, borderColor: UIColor, corner: Bool) -> UITextView{
    let textView = UITextView(frame: frame)
    textView.layer.borderColor = borderColor.cgColor
    textView.layer.borderWidth = borderWidth
    textView.font =  UIFont(name: "", size: FONTSIZENormal)
    if corner{
        textView.layer.cornerRadius = cornerRadiusSmall
    }
    textView.textColor = UIColor.black
    return textView
}

func createTextViewVerticleContent(_ frame:CGRect, borderColor: UIColor, corner: Bool) -> VerticallyCenteredTextView{
    let textView = VerticallyCenteredTextView(frame: frame)
    textView.layer.borderColor = borderColor.cgColor
    textView.layer.borderWidth = borderWidth
    textView.font =  UIFont(name: "", size: FONTSIZENormal)
    if corner{
        textView.layer.cornerRadius = cornerRadiusSmall
    }
    textView.textColor = UIColor.black
    return textView
}

// Creation Of Button
func createButton(_ frame:CGRect, title:String, border:Bool, bgColor: Bool ,textColor: UIColor)->UIButton{
    let button = UIButton(frame:frame )
    button.setTitle(title, for: UIControl.State())
    button.setTitleColor(textColor, for: UIControl.State())
    if (bgColor){
        button.backgroundColor = buttonBgColor
    }
    if (border){
        button.layer.borderColor = textColorMedium.cgColor
        button.layer.borderWidth = borderWidth
        
    }
    return button
}


// Creation Of Navigation Button
func createNavigationButton(_ frame:CGRect, title:String, border:Bool, selected:Bool)->UIButton{
    let button = UIButton(frame:frame )
    button.setTitle(title, for: UIControl.State())
    button.setTitleColor(textColorMedium, for: UIControl.State())
    button.backgroundColor = tableViewBgColor
    if selected == true
    {//buttonColor
        button.setTitleColor(buttonColor, for: UIControl.State())
        let bottomBorder = UIView(frame: CGRect(x: 0, y: button.frame.size.height - 2.0, width: button.frame.size.width , height: 2))
        bottomBorder.backgroundColor = buttonColor
        bottomBorder.tag = 1000
        button.addSubview(bottomBorder)
    }
    else
    {
        let bottomBorder = UIView(frame: CGRect(x: 0, y: button.frame.size.height - 0.7, width: button.frame.size.width, height: 0.7))
        bottomBorder.backgroundColor = textColorMedium
        bottomBorder.tag = 1001
        button.addSubview(bottomBorder)
    }
    return button
}

// Creation Of ImageView
func createImageView(_ frame:CGRect,border:Bool)->UIImageView{
    let imageView = UIImageView(frame:frame )
    if border{
        imageView.layer.borderColor = borderColorMedium.cgColor
        imageView.layer.borderWidth = borderWidth
    }
    return imageView
}
/*
func createTextFormElement(textDictionary : Dictionary<String, AnyObject>) -> Dictionary<String, AnyObject>
{
    var returnElement = Dictionary<String, AnyObject>()
    returnElement["key"] = textDictionary["name"] as? String as AnyObject?
    returnElement["title"] = textDictionary["label"] as? String as AnyObject?
    if let description = textDictionary["description"] as? String
    {
        returnElement["footer"] = description as AnyObject?
    }
    if isCreateOrEdit
    {
        let key = textDictionary["name"] as? String
        if (Formbackup[key!] != nil)
        {
            returnElement["default"] = Formbackup[key!] as AnyObject?
        }
        else
        {
            returnElement["default"] = "" as AnyObject?
        }
    }
    if !isCreateOrEdit
    {
        let key = textDictionary["name"] as? String
        if (Formbackup[key!] != nil)
        {
            returnElement["default"] = Formbackup[key!] as AnyObject?
        }
        else if (formValue[key!] != nil)
        {
            returnElement["default"] = formValue[key!] as AnyObject?
        }
        else
        {
            returnElement["default"] = "" as AnyObject?
        }
    }
    return returnElement
}

func createCheckboxFormElement(checkboxDictionary : Dictionary<String, AnyObject>) -> Dictionary<String, AnyObject>
{
    var returnElement = Dictionary<String, AnyObject>()
    returnElement["type"] = "option" as AnyObject?
    returnElement["key"] = checkboxDictionary["name"] as? String as AnyObject?
    returnElement["title"] = checkboxDictionary["label"] as? String as AnyObject?
    if let description = checkboxDictionary["description"] as? String
    {
        returnElement["footer"] = description as AnyObject?
    }
    if isCreateOrEdit
    {
        let key = checkboxDictionary["name"] as? String
        if (Formbackup[key!] != nil)
        {
            returnElement["default"] = Formbackup[key!] as AnyObject?
        }
        else if let value = checkboxDictionary["value"] as? Int
        {
            returnElement["default"] = value as AnyObject?
        }
        else
        {
            returnElement["default"] = false as AnyObject?
        }
    }
    if !isCreateOrEdit
    {
        let key = checkboxDictionary["name"] as? String
        if(Formbackup[key!] != nil)
        {
            returnElement["default"] = Formbackup[key!] as AnyObject?
        }
        else if (formValue[key!] != nil)
        {
            returnElement["default"] = formValue[key!] as AnyObject?
        }
        else if let value = checkboxDictionary["value"] as? Int
        {
            returnElement["default"] = value as AnyObject?
        }
        else
        {
            returnElement["default"] = false as AnyObject?
        }
    }
    return returnElement
}

func createSelectRadioFormElement(dictionary : Dictionary<String,AnyObject>) -> Dictionary<String,AnyObject>
{
    var returnElement = Dictionary<String,AnyObject>()
    returnElement["cell"] = "FXFormOptionPickerCell" as AnyObject?
    returnElement["key"] = dictionary["name"] as? String as AnyObject?
    returnElement["title"] = dictionary["label"] as? String as AnyObject?
    if let description = dictionary["description"] as? String
    {
        returnElement["footer"] = description as AnyObject?
    }
    if let option = dictionary["multiOptions"] as? NSArray
    {
        if option.count > 0
        {
            if isCreateOrEdit
            {
                let key = dictionary["name"] as? String
                if(Formbackup[key!] != nil)
                {
                    returnElement["default"] = Formbackup[key!] as AnyObject?
                }
                else
                {
                    returnElement["default"] = "" as AnyObject?
                }
            }
            else if !isCreateOrEdit
            {
                let key = dictionary["name"] as? String
                if (Formbackup[key!] != nil)
                {
                    returnElement["default"] = Formbackup[key!] as AnyObject?
                }
                else if (formValue[key!] != nil)
                {
                    let id = formValue[key!] as AnyObject?
                    returnElement["default"] = option[id! as! Int] as AnyObject?
                }
                else
                {
                    returnElement["default"] = "" as AnyObject?
                }
            }
            returnElement["options"] = option
        }
    }
    else if let option = dictionary["multiOptions"] as? NSDictionary
    {
        var options = [AnyObject]()
        let array = option.allKeys.sorted(by: { (key1, key2) -> Bool in
            (key1 as! String) < (key2 as! String)
        })
        for index in array
        {
            options.append(option["\(index)"]! as AnyObject)
        }
        let key = dictionary["name"] as? String
        if isCreateOrEdit
        {
            if (Formbackup[key!] != nil)
            {
                returnElement["default"] = Formbackup[key!] as AnyObject?
            }
            else if let value = dictionary["value"] as? String
            {
                returnElement["default"] = option["\(value)"] as AnyObject?
            }
            else
            {
                returnElement["default"] = "" as AnyObject?
            }
        }
        else if !isCreateOrEdit
        {
            if (Formbackup[key!] != nil)
            {
                returnElement["default"] = Formbackup[key!] as AnyObject?
            }
            else if (formValue[key!] != nil)
            {
                returnElement["default"] = formValue[key!] as AnyObject?
            }
            else
            {
                returnElement["default"] = "" as AnyObject?
            }
        }
        returnElement["options"] = options as AnyObject?
    }
    
    return returnElement
}

func createMulticheckBoxFormElement(formDictionary : Dictionary<String,AnyObject>) -> [AnyObject]
{
    var returnElement = [AnyObject]()
    var options = [AnyObject]()
    var element = Dictionary<String,AnyObject>()
    if let option = formDictionary["multiOptions"] as? NSDictionary
    {
        let array = option.allKeys.sorted(by: { (key1, key2) -> Bool in
            (key1 as! String) < (key2 as! String)
        })
        for index in array
        {
            options.append(option["\(index)"]! as AnyObject)
            element["key"] = option["\(index)"]! as AnyObject?
            element["title"] = option["\(index)"]! as AnyObject?
            element["type"] = "option" as AnyObject?
            let key = option["\(index)"] as! String
            if(Formbackup[key] != nil)
            {
                element["default"] = Formbackup[key] as AnyObject?
            }
            else
            {
                element["default"] = "" as AnyObject?
            }
            returnElement.append(element as AnyObject)
        }
    }
    return returnElement
}

func createSubmitFormElement(formDictionary: Dictionary<String,AnyObject>) -> Dictionary<String,AnyObject>
{
    var returnElement = Dictionary<String,AnyObject>()
    returnElement["header"] = "" as AnyObject?
    returnElement["title"] = formDictionary["label"] as? String as AnyObject?
    returnElement["action"] = "submitForm:" as AnyObject?
    return returnElement
}

func createTextareaFormElement(formDictionary: Dictionary<String,AnyObject>) -> Dictionary<String,AnyObject>
{
    var returnElement = Dictionary<String,AnyObject>()
    returnElement["type"] = "longtext" as AnyObject?
    returnElement["key"] = formDictionary["name"] as? String as AnyObject?
    returnElement["title"] = formDictionary["lable"] as? String as AnyObject?
    if let description = returnElement["description"] as? String
    {
        returnElement["footer"] = description as AnyObject?
    }
    let key = formDictionary["name"] as? String
    if isCreateOrEdit
    {
        if (Formbackup[key!] != nil)
        {
            returnElement["default"] = Formbackup[key!] as AnyObject?
        }
        else if (formValue[key!] != nil)
        {
            returnElement["default"] = formValue[key!] as AnyObject?
        }
        else
        {
            returnElement["default"] = "" as AnyObject?
        }
    }
    else if !isCreateOrEdit
    {
        if (Formbackup[key!] != nil)
        {
            returnElement["default"] = Formbackup[key!] as AnyObject?
        }
        else if (formValue[key!] != nil)
        {
            returnElement["default"] = formValue[key!] as AnyObject?
        }
        else
        {
            returnElement["default"] = "" as AnyObject?
        }
    }
    return returnElement
}

func createDateFormElement(formDictionary: Dictionary<String,AnyObject>) -> Dictionary<String,AnyObject>
{
    var returnElement = Dictionary<String,AnyObject>()
    returnElement["type"] = "datetime" as AnyObject?
    returnElement["title"] = formDictionary["label"] as? String as AnyObject?
    returnElement["key"] = formDictionary["name"] as? String as AnyObject?
    if let description = formDictionary["description"] as? String
    {
        returnElement["footer"] = description as AnyObject?
    }
    let key = formDictionary["name"] as! String
    if isCreateOrEdit
    {
        if(Formbackup[key] != nil)
        {
            returnElement["default"] = Formbackup[key] as AnyObject?
        }
        else
        {
            returnElement["default"] = "" as AnyObject?
        }
    }
    else if !isCreateOrEdit
    {
        if(Formbackup[key] != nil)
        {
            returnElement["default"] = Formbackup[key] as AnyObject?
        }
        if formValue[key] is NSString
        {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            returnElement["default"] = dateFormatter.date(from: formValue.value(forKey: key) as! NSString as String) as AnyObject?
        }
        else
        {
            returnElement["default"] = "" as AnyObject?
        }
    }
    return returnElement
}

func createLabelFormElement(formDictionary: Dictionary<String,AnyObject>) -> Dictionary<String,AnyObject>
{
    var returnElement = Dictionary<String,AnyObject>()
    returnElement["type"] = "Label" as AnyObject?
    returnElement["title"] = formDictionary["label"] as? String as AnyObject?
    returnElement["key"] = formDictionary["name"] as? String as AnyObject?
    return returnElement
}

func createFileFormElement(formDictionary: Dictionary<String,AnyObject>) -> Dictionary<String,AnyObject>
{
    var returnElement = Dictionary<String,AnyObject>()
    returnElement["key"] = formDictionary["name"] as? String as AnyObject?
    returnElement["title"] = formDictionary["label"] as? String as AnyObject?
    if multiplePhotoSelection == true
    {
        returnElement["class"] = "UploadPhotosViewController" as AnyObject?
    }
    else
    {
        returnElement["type"] = "image" as AnyObject?
    }
    let key = formDictionary["name"] as! String
    if isCreateOrEdit
    {
        if(Formbackup[key] != nil)
        {
            returnElement["default"] = Formbackup[key] as AnyObject?
        }
        else
        {
            returnElement["default"] = "" as AnyObject?
        }
    }
    return returnElement
    
}

func createButtonFormElement(formDictionary: Dictionary<String,AnyObject>) -> Dictionary<String,AnyObject>
{
    var returnElement = Dictionary<String,AnyObject>()
    returnElement["title"] = formDictionary["label"] as AnyObject?
    returnElement["action"] = "submitForm:" as AnyObject?
    if let description = formDictionary["description"] as? String
    {
        returnElement["header"] = description as AnyObject?
    }
    else
    {
        returnElement["header"] = "" as AnyObject?
    }
    return returnElement
}

func createFloatFormElement(formDictionary: Dictionary<String,AnyObject>) -> Dictionary<String,AnyObject>
{
    var returnElement = Dictionary<String,AnyObject>()
    returnElement["key"] = formDictionary["name"] as? String as AnyObject?
    returnElement["header"] = "" as AnyObject?
    returnElement["title"] = formDictionary["label"] as? String as AnyObject?
    returnElement["type"] = "float" as AnyObject?
    return returnElement
}

func createIntegerFormElement(formDictionary: Dictionary<String,AnyObject>) -> Dictionary<String,AnyObject>
{
    var returnElement = Dictionary<String,AnyObject>()
    returnElement["type"] = "integer" as AnyObject?
    returnElement["key"] = formDictionary["name"] as? String as AnyObject?
    returnElement["header"] = "" as AnyObject?
    returnElement["title"] = formDictionary["label"] as? String as AnyObject?
    return returnElement
}

func createRatingFormElement(formDictionary: Dictionary<String,AnyObject>) -> Dictionary<String,AnyObject>
{
    var returnElement = Dictionary<String,AnyObject>()
    returnElement["type"] = "rateview" as AnyObject?
    returnElement["key"] = formDictionary["name"] as? String as AnyObject?
    returnElement["title"] = formDictionary["label"] as? String as AnyObject?
    returnElement["action"] = "getRating:" as AnyObject?
    let key = formDictionary["name"] as! String
    if (formValue[key] != nil)
    {
        returnElement["default"] = formValue[key] as AnyObject?
    }
    return returnElement
}

func createHiddenFormElement(formDictionary: Dictionary<String,AnyObject>) -> Dictionary<String,AnyObject>
{
    var returnElement = Dictionary<String,AnyObject>()
    returnElement["type"] = "option" as AnyObject?
    returnElement["key"] = formDictionary["name"] as? String as AnyObject?
    returnElement["title"] = formDictionary["label"] as? String as AnyObject?
    let key = formDictionary["name"] as! String
    if isCreateOrEdit
    {
       if (Formbackup[key] != nil)
       {
        returnElement["default"] = Formbackup[key] as AnyObject?
       }
       else
       {
        returnElement["default"] = "" as AnyObject?
       }
    }
    else if !isCreateOrEdit
    {
        if (Formbackup[key] != nil)
        {
            returnElement["default"] = Formbackup[key] as AnyObject?
        }
        else if (formValue[key] != nil)
        {
            returnElement["default"] = formValue[key] as AnyObject?
        }
        else
        {
            returnElement["default"] = "" as AnyObject?
        }
    }
    return returnElement
}

func createSliderFormElement(formDictionary: Dictionary<String,AnyObject>) -> Dictionary<String,AnyObject>
{
    var returnElement = Dictionary<String,AnyObject>()
    returnElement["title"] = formDictionary["label"] as? String as AnyObject?
    returnElement["key"] = formDictionary["name"] as? String as AnyObject?
    let key = formDictionary["name"] as! String
    if isCreateOrEdit
    {
        if (Formbackup[key] != nil)
        {
            returnElement["default"] = Formbackup[key] as AnyObject?
        }
        else
        {
            returnElement["default"] = "" as AnyObject?
        }
    }
    return returnElement
}
*/

// MARK: - Create FXForm Input Array

// Generate FXForm Array to create All Forms from Dictionary come from Server

func generateFXFormsArrayfromDictionary(_ dictionary : NSArray) ->[AnyObject]
{
    // Array For FXForm Form Generation
    var formElements = [AnyObject]()
    
    /*if conditionalForm == "paymentMethod" {
        element["header"] = "" as AnyObject?
        element["title"] = "Save" as? String as AnyObject?
        element["action"] = "submitForm:" as AnyObject?
        formElements.append(element as AnyObject)
    } */
    
    
    var showHeader = true
    for key in dictionary
    {
        // Create element Dictionary for every FXForm Element
        var element = Dictionary<String, AnyObject>()
        
        if let dic = (key as? NSDictionary)
        {
            
            // Check for Type
            if(conditionalForm != nil && conditionalForm == "notificationSetting")
            {
                //MARK: conditionalForm == "notificationSetting"
                if(dic["category"] as! String != "")
                {

                    if showHeader == true
                    {
                        showHeader = false
                        element["type"] = "Label" as AnyObject?
                        element["title"] = dic["category"] as? String as AnyObject?
                        element["key"] = dic["name"] as? String as AnyObject?
                        element["header"] = NSLocalizedString("Which of the these do you want to receive email alerts about?",comment: "") as AnyObject?
                        formElements.append(element as AnyObject)
                    }
                    else
                    {
                        element["type"] = "Label" as AnyObject?
                        element["title"] = dic["category"] as? String as AnyObject?
                        element["key"] = dic["name"] as? String as AnyObject?
                        formElements.append(element as AnyObject)
                        
                    }
                    
                    if let categoryArray = dic["types"] as? NSArray
                    {
                        var element1 = Dictionary<String, AnyObject>()
                        for i in stride(from: 0, to: categoryArray.count, by: 1){
                            
                            if let CheckBoxDic = categoryArray[i] as? NSDictionary
                            {
                                
                                element1["type"] = "option" as AnyObject?
                                element1["key"] = CheckBoxDic["name"] as? String as AnyObject?
                                element1["title"] = CheckBoxDic["label"] as? String as AnyObject?
                                element1["default"] = "0" as AnyObject?
                                if let value = CheckBoxDic["value"] as? Int{
                                    element1["default"] = value as AnyObject?
                                }
                                
                                if isCreateOrEdit{
                                    let key = CheckBoxDic["name"] as? String
                                    let value = formValuearr.contains(key!)
                                    if  value
                                    {
                                        element1["default"] = 1 as AnyObject?
                                    }
                                    else
                                    {
                                        element1["default"] = 0 as AnyObject?
                                    }
                                }
                                formElements.append(element1 as AnyObject)
                            }
                            
                        }
                        
                        
                    }
                    
                }
            }
                
            // Product Creation Section
                
            else if (conditionForm != nil && conditionForm == "productType")
            {
                if dic["type"] as! String != "" || dic["Type"] as! String != ""
                {
                    if dic["type"] as! String == "help" || dic["type"] as! String == "help"
                    {
                        element["key"] = dic["name"] as? String as AnyObject?
                        element["action"] = "productHelpOpener:" as AnyObject?
                        element["title"] = dic["label"] as? String as AnyObject?
                        element["type"] = "help" as AnyObject?
                        //element["default"] = dic["value"] as AnyObject?
                        formElements.append(element as AnyObject)
                    }
                    else if dic["type"] as! String == "switch" || dic["type"] as! String == "switch"
                    {
                        element["key"] = dic["name"] as? String as AnyObject?
                        //element["action"] = "productHelpOpener:" as AnyObject?
                        element["title"] = dic["label"] as? String as AnyObject?
                        element["type"] = "switch" as AnyObject?
                        element["default"] = 0 as AnyObject?
                        formElements.append(element as AnyObject)
                    }
                    else if dic["type"] as! String == "select" || dic["type"] as! String == "Select"
                    {
                        element["cell"] = "FXFormOptionPickerCell" as AnyObject?
                        element["key"] = dic["name"] as? String as AnyObject?
                        element["title"] = dic["label"] as? String as AnyObject?
                        if let description = dic["description"] as? String
                        {
                            element["footer"] = description as AnyObject?
                        }
                        if isCreateOrEdit
                        {
                            let key = dic["name"] as? String
                            if (key != nil)
                            {
                                element["default"] = Formbackup[key!] as AnyObject?
                            }
                            else
                            {
                                element["default"] = "" as AnyObject?
                            }
                        }
                        if let _ = dic["multiOptions"] as? NSDictionary
                        {
                            var options = [AnyObject]()
                            if let option = dic["multiOptions"] as? NSDictionary
                            {
                                
                                let array2 = option.allKeys.sorted(by: { (key1, key2) -> Bool in
                                    (key1 as! String) < (key2 as! String)
                                })
                                
                                for index in array2
                                {
                                    options.append(option["\(index)"]! as AnyObject)
                                }
                                if dic["name"] as! String == "product_type"
                                {
                                    if let value = dic["value"] as? String
                                    {
                                        element["default"] = option.value(forKey: value) as AnyObject?
                                    }
                                    else
                                    {
                                        element["default"] = options[0]
                                    }
                                }
                            }
                            
                            element["options"] = options as AnyObject?
                        }
                        //element = createSelectRadioFormElement(dictionary: dic as! Dictionary<String,AnyObject>)
                        formElements.append(element as AnyObject)
                    }
                }
            }
                
            else if (conditionForm != nil) && ( conditionForm == "addNewShippingMethod" || conditionForm == "editShippingMethod2" )
            {
                if dic["type"] as! String != "" || dic["type"] as! String != ""
                {
                    if dic["type"] as! String == "Text" || dic["type"] as! String == "text"
                    {
                        
                        //element = createTextFormElement(textDictionary: (dic as! NSMutableDictionary) as! Dictionary<String, AnyObject>)
                        element["key"] = dic["name"] as? String as AnyObject?
                        if dic["name"] as? String == "url"
                        {
                            element["type"] = "url" as AnyObject?
                        }
                        element["title"] = dic["label"] as? String as AnyObject?
                        element["default"] = "" as AnyObject?
                        if isCreateOrEdit
                        {
                            let key = dic["name"] as? String
                            if (key != nil)
                            {
                                element["default"] = Formbackup.value(forKey: key!) as AnyObject?
                            }
                        }
                        else
                        {
                            let key = dic["name"] as? String
                            element["default"] = formValue[key!] as AnyObject?
                        }
                        if let description = dic["description"] as? String
                        {
                            element["footer"] = description as AnyObject?
                        }
                        formElements.append(element as AnyObject)
                    }
                    else if dic["type"] as! String == "Select" || dic["type"] as! String == "select" || dic["type"] as! String == "Radio" || dic["type"] as! String == "radio"
                    {
                        //element = createSelectRadioFormElement(dictionary: dic as! Dictionary<String,AnyObject>)
                        element["cell"] = "FXFormOptionPickerCell" as AnyObject?
                        element["key"] = dic["name"] as? String as AnyObject?
                        element["title"] = dic["label"] as? String as AnyObject?
                        if let description = dic["description"] as? String
                        {
                            element["footer"] = description as AnyObject?
                        }
                        
                        if (( dic["type"] as! String == "select" || dic["type"] as! String == "Select") && dic["name"] as! String == "country")
                        {
                            element["action"] = "listingCountryValueChanged:" as AnyObject?
                        }
                        else if (dic["name"] as! String == "all_regions")
                        {
                            element["action"] = "listingRegionValueChanged:" as AnyObject?
                            element["title"] = "Enable shipping Method for all regions" as AnyObject?
                        }
                        else if (( dic["type"] as! String == "select" || dic["type"] as! String == "Select" ) && dic["name"] as! String == "dependency")
                        {
                            element["action"] = "listingDependencyValueChanged:" as AnyObject?
                        }
                        else if (( dic["type"] as! String == "select" || dic["type"] as! String == "Select" ) && dic["name"] as! String == "handling_type")
                        {
                            element["action"] = "handlingTypeValueChanged:" as AnyObject?
                        }
                        else if (( dic["type"] as! String == "select" || dic["type"] as! String == "Select" ) && dic["name"] as! String == "ship_type")
                        {
                            element["action"] = "shippingTypeValueChanged:" as AnyObject?
                        }
                        
                        
                        
                        if let option = dic["multiOptions"] as? NSArray
                        {
                            if option.count > 0
                            {
                                if isCreateOrEdit
                                {
                                    let key = dic["name"] as? String
                                    if (key != nil)
                                    {
                                        element["default"] = Formbackup[key!] as AnyObject?
                                    }
                                    else
                                    {
                                        element["default"] = "" as AnyObject?
                                    }
                                }
                                else
                                {
                                    let key = dic["name"] as? String
                                    let id = formValue[key!] as AnyObject?
                                    element["default"] = option[id! as! Int] as AnyObject?
                                }
                                
                                element["options"] = option
                                
                            }
                        }
                            
                        else if let _ = dic["multiOptions"] as? NSDictionary
                        {
                            var options = [AnyObject]()
                            if let option = dic["multiOptions"] as? NSDictionary
                            {
                                
                                let array2 = option.allKeys.sorted(by: { (key1, key2) -> Bool in
                                    (key1 as! String) < (key2 as! String)
                                })
                                
                                for index in array2
                                {
                                    options.append(option["\(index)"]! as AnyObject)
                                }
                                
                            }
                            if isCreateOrEdit
                            {
                                let key = dic["name"] as? String
                                if (key != nil)
                                {
                                    element["default"] = Formbackup[key!] as AnyObject?
                                }
                                else
                                {
                                    element["default"] = "" as AnyObject?
                                }
                            }
                            
                            else
                            {
                                let key = dic["name"] as? String
                                element["default"] = formValue[key!] as AnyObject?
                            }
                            element["options"] = options as AnyObject?
                            
                        }
                        formElements.append(element as AnyObject)
                    }
                    else if dic["type"] as! String == "Checkbox" || dic["type"] as! String == "checkbox"
                    {
                        
                        //element = createCheckboxFormElement(checkboxDictionary: dic as! Dictionary<String, AnyObject>)
                        element["type"] = "option" as AnyObject?
                        element["key"] = dic["name"] as? String as AnyObject?
                        element["title"] = dic["label"] as? String as AnyObject?
                        if let value = dic["value"] as? Int
                        {
                            element["default"] = value as AnyObject?
                        }
                        else
                        {
                            element["default"] = false as AnyObject?
                        }
                        if isCreateOrEdit
                        {
                            let key = dic["name"] as? String
                            if (key != nil)
                            {
                                element["default"] = Formbackup[key!] as AnyObject?
                            }
                            else
                            {
                                element["default"] = "" as AnyObject?
                            }
                        }
                        else
                        {
                            let key = dic["name"] as? String
                            element["default"] = formValue[key!] as AnyObject?
                        }
                        formElements.append(element as AnyObject)
                    }
                    else if dic["type"] as! String == "MultiCheckbox" || dic["type"] as! String == "Multiselect"
                    {
                        
                        //var checkboxElements = [AnyObject]()
                        //checkboxElements = createMulticheckBoxFormElement(formDictionary: dic as! Dictionary<String,AnyObject>)
                        //for celements in checkboxElements
                        //{
                          //  element = celements as! [String : AnyObject]
                            //formElements.append(element as AnyObject)
                        //}
                        let multiOptionsDic = dic["multiOptions"] as? NSDictionary
                        var options = [AnyObject]()
                        if let option = dic["multiOptions"] as? NSDictionary
                        {
                            let array2 = option.allKeys.sorted(by: { (key1, key2) -> Bool in
                                (key1 as! String) < (key2 as! String)
                            })
                            print(array2)
                            
                            
                            for index in array2
                            {
                                
                                options.append(option["\(index)"]! as AnyObject)
                                print(options)
                                
                                element["key"] = (option["\(index)"]! as AnyObject?)
                                element["title"] = multiOptionsDic?.value(forKey: index as! String) as AnyObject?
                                let key3 = option["\(index)"] as! String
                                if key3 != nil
                                {
                                    element["default"] = Formbackup[option["\(index)"]!] as AnyObject?
                                }
                                else
                                {
                                    element["default"] = "" as AnyObject?
                                }

                                element["type"] = "option" as AnyObject?
                                formElements.append(element as AnyObject)
                                
                            }
                        }
                    }
    
                    else if dic["type"] as! String == "submit" || dic["type"] as! String == "Submit"
                    {
                        
                        //element = createSubmitFormElement(formDictionary: dic as! Dictionary<String,AnyObject>)
                        element["header"] = "" as AnyObject?
                        element["title"] = "Save Changes" as? String as AnyObject?
                        element["action"] = "submitForm:" as AnyObject?
                        formElements.append(element as AnyObject)
                    }
                }
            }
                
            else if (conditionForm != nil) && ( conditionForm == "editShippingMethod" )
            {
                if dic["type"] as! String != "" || dic["type"] as! String != ""
                {
                    if dic["type"] as! String == "Text" || dic["type"] as! String == "text"
                    {
                        element["key"] = dic["name"] as? String as AnyObject?
                        if dic["name"] as? String == "url"
                        {
                            element["type"] = "url" as AnyObject?
                        }
                        element["title"] = dic["label"] as? String as AnyObject?
                        element["default"] = "" as AnyObject?
                        let key = dic["name"] as? String
                        if ( Formbackup[key!] != nil)
                        {
                            element["default"] = Formbackup[key!] as AnyObject?
                        }
                        else if ( formValue[key!] != nil )
                        {
                            element["default"] = formValue[key!] as! AnyObject?
                        }
                        else
                        {
                            element["default"] = "" as AnyObject?
                        }
                        
                        //element["default"] = formValue[key!] as AnyObject?
                        
                        if let description = dic["description"] as? String
                        {
                            element["footer"] = description as AnyObject?
                        }
                        
                        if dic["name"] as! String == "region"
                        {
                            let regionValue = formValue["region"] as! Int
                            let regionStringValue = String(regionValue)
                            if regionStringValue == "0"
                            {
                                element["default"] = "All" as AnyObject?
                            }
                            else
                            {
                                let stateDic = fieldsDic["all_regions_no"] as! NSArray
                                let regionDic = stateDic[0] as! NSDictionary
                                let regionOption = regionDic["multiOptions"] as! NSDictionary
                                for (key,value) in regionOption
                                {
                                    if key as! String == regionStringValue
                                    {
                                        element["default"] = value as AnyObject?
                                    }
                                }
                            }
                            
                        }
                        
                        if (dic["name"] as! String == "region")
                        {
                            element["action"] = "listingRegionValueChanged:" as AnyObject?
                        }
                        
                        formElements.append(element as AnyObject)
                    }
                    else if dic["type"] as! String == "Select" || dic["type"] as! String == "select" || dic["type"] as! String == "Radio" || dic["type"] as! String == "radio"
                    {
                        element["cell"] = "FXFormOptionPickerCell" as AnyObject?
                        element["key"] = dic["name"] as? String as AnyObject?
                        element["title"] = dic["label"] as? String as AnyObject?
                        if let description = dic["description"] as? String
                        {
                            element["footer"] = description as AnyObject?
                        }
                        if (( dic["type"] as! String == "select" || dic["type"] as! String == "Select") && dic["name"] as! String == "country")
                        {
                            element["action"] = "listingCountryValueChanged:" as AnyObject?
                        }
                        else if (( dic["type"] as! String == "select" || dic["type"] as! String == "Select" ) && dic["name"] as! String == "dependency")
                        {
                            element["action"] = "listingDependencyValueChanged:" as AnyObject?
                        }
                        else if (( dic["type"] as! String == "select" || dic["type"] as! String == "Select" ) && dic["name"] as! String == "handling_type")
                        {
                            element["action"] = "handlingTypeValueChanged:" as AnyObject?
                        }
                        else if (( dic["type"] as! String == "select" || dic["type"] as! String == "Select" ) && dic["name"] as! String == "ship_type")
                        {
                            element["action"] = "shippingTypeValueChanged:" as AnyObject?
                        }
                        
                        
                        
                        if let option = dic["multiOptions"] as? NSArray
                        {
                            if option.count > 0
                            {
                                let key = dic["name"] as? String
                                if ( Formbackup[key!] != nil)
                                {
                                    element["default"] = Formbackup[key!] as AnyObject?
                                }
                                else if ( formValue[key!] != nil )
                                {
                                    let value = formValue[key!] as! Int
                                    let id = Int(value)
                                    element["default"] = option[id] as AnyObject?
                                }
                                else
                                {
                                    element["default"] = "" as AnyObject?
                                }
                            }
                                element["options"] = option
                            }

                        else if let _ = dic["multiOptions"] as? NSDictionary
                        {
                            var options = [AnyObject]()
                            if let option = dic["multiOptions"] as? NSDictionary
                            {
                                
                                let array2 = option.allKeys.sorted(by: { (key1, key2) -> Bool in
                                    (key1 as! String) < (key2 as! String)
                                })
                                
                                for index in array2
                                {
                                    options.append(option["\(index)"]! as AnyObject)
                                }
                                
                            }
                            
                            if (( dic["type"] as! String == "radio" || dic["type"] as! String == "Radio") && dic["name"] as! String == "all_regions")
                            {
                                let key = dic["name"] as? String
                                let key2 = "region"
                                
                                if ( Formbackup[key!] != nil)
                                {
                                    element["default"] = Formbackup[key!] as AnyObject?
                                }
                                else if let value = formValue[key2] as AnyObject?
                                {
                                    print(value)
                                    if value as! Int == 0
                                    {
                                        element["default"] = "No" as AnyObject?
                                    }
                                    else
                                    {
                                        element["default"] = "Yes" as AnyObject?
                                    }
                                }
                                
                            }
                            else
                            {
                                let selectOptions = dic["multiOptions"] as? NSDictionary
                                let key = dic["name"] as? String
                                
                                if ( Formbackup[key!] != nil)
                                {
                                    element["default"] = Formbackup[key!] as AnyObject?
                                }
                                else if ( formValue[key!] != nil && dic["name"] as! String != "all_regions")
                                {
                                    if let optionKey = formValue[key!] as? String
                                    {
                                      element["default"] = selectOptions?[optionKey] as AnyObject?
                                    }
                                    else if let optionKey = formValue[key!] as? Int
                                    {
                                        let option = String(optionKey)
                                        element["default"] = selectOptions?[option] as AnyObject?
                                    }
                                    //element["default"] = formValue[key!] as AnyObject?
                                }
                                else
                                {
                                    element["default"] = "" as AnyObject?
                                }
                            }
                            
                            if dic["name"] as! String != "country"
                            {
                                element["options"] = options as AnyObject?
                            }
                            
                            
                        }
                        formElements.append(element as AnyObject)
                    }
                    else if dic["type"] as! String == "Checkbox" || dic["type"] as! String == "checkbox"
                    {
                        element["type"] = "option" as AnyObject?
                        element["key"] = dic["name"] as? String as AnyObject?
                        element["title"] = dic["label"] as? String as AnyObject?
                        if let value = dic["value"] as? Int
                        {
                            element["default"] = value as AnyObject?
                        }
                        else
                        {
                            element["default"] = false as AnyObject?
                        }

                        let key = dic["name"] as? String
                        element["default"] = formValue[key!] as AnyObject?
                        formElements.append(element as AnyObject)
                    }
                    else if dic["type"] as! String == "submit" || dic["type"] as! String == "Submit"
                    {
                        element["header"] = "" as AnyObject?
                        element["title"] = "Save Changes" as? String as AnyObject?
                        element["action"] = "submitForm:" as AnyObject?
                        formElements.append(element as AnyObject)
                    }
                }
            }
                
            else if conditionalForm != nil && conditionalForm == "paymentMethod"
            {
                if dic["type"] as! String != "" || dic["type"] as! String != ""
                {
                    if dic["type"] as! String == "Text" || dic["type"] as! String == "text"
                    {
                        //element = createTextFormElement(textDictionary: dic as! Dictionary<String,AnyObject>)
                        element["key"] = dic["name"] as? String as AnyObject?
                        if dic["name"] as? String == "url"
                        {
                            element["type"] = "url" as AnyObject?
                        }
                        element["title"] = dic["label"] as? String as AnyObject?
                        element["default"] = "" as AnyObject?
                        if isCreateOrEdit
                        {
                            let key = dic["name"] as? String
                            if (formValue[key!] != nil)
                            {
                                element["default"] = formValue[key!] as AnyObject?
                            }
                            else if (Formbackup.value(forKey: key!) != nil)
                            {
                                element["default"] = Formbackup.value(forKey: key!) as AnyObject?
                            }
                            else
                            {
                                element["default"] = "" as AnyObject
                            }
                        }
                        else
                        {
                            let key = dic["name"] as? String
                            element["default"] = formValue[key!] as AnyObject?
                        }
                        if let description = dic["description"] as? String
                        {
                            element["footer"] = description as AnyObject?
                        }
                        formElements.append(element as AnyObject)
                    }
                    else if dic["type"] as! String == "Select" || dic["type"] as! String == "select" || dic["type"] as! String == "Radio" || dic["type"] as! String == "radio"
                    {
                        //element = createSelectRadioFormElement(dictionary: dic as! Dictionary<String,AnyObject>)
                        element["cell"] = "FXFormOptionPickerCell" as AnyObject?
                        element["key"] = dic["name"] as? String as AnyObject?
                        element["title"] = dic["label"] as? String as AnyObject?
                        if let description = dic["description"] as? String
                        {
                            element["footer"] = description as AnyObject?
                        }
                        
                        if let option = dic["multiOptions"] as? NSArray
                        {
                            if option.count > 0
                            {
                                if isCreateOrEdit
                                {
                                    let key = dic["name"] as? String
                                    if (key != nil)
                                    {
                                        element["default"] = Formbackup[key!] as AnyObject?
                                    }
                                    else
                                    {
                                        element["default"] = "" as AnyObject?
                                    }
                                }
                                else
                                {
                                    let key = dic["name"] as? String
                                    let id = formValue[key!] as AnyObject?
                                    element["default"] = option[id! as! Int] as AnyObject?
                                }
                                
                                element["options"] = option
                                
                            }
                        }
                            
                        else if let _ = dic["multiOptions"] as? NSDictionary
                        {
                            var options = [AnyObject]()
                            if let option = dic["multiOptions"] as? NSDictionary
                            {
                                
                                let array2 = option.allKeys.sorted(by: { (key1, key2) -> Bool in
                                    (key1 as! String) < (key2 as! String)
                                })
                                
                                for index in array2
                                {
                                    options.append(option["\(index)"]! as AnyObject)
                                }
                                
                            }
                            if isCreateOrEdit
                            {
                                let key = dic["name"] as? String
                                if (key != nil)
                                {
                                    element["default"] = Formbackup[key!] as AnyObject?
                                }
                                else
                                {
                                    element["default"] = "" as AnyObject?
                                }
                            }
                                
                            else
                            {
                                let key = dic["name"] as? String
                                element["default"] = formValue[key!] as AnyObject?
                            }
                            element["options"] = options as AnyObject?
                            
                        }
                        formElements.append(element as AnyObject)
                    }
                    
                    else if dic["type"] as! String == "Checkbox" || dic["type"] as! String == "checkbox"
                    {
                        
                        element["type"] = "switch" as AnyObject?
                        element["key"] = dic["name"] as? String as AnyObject?
                        element["title"] = dic["label"] as? String as AnyObject?
                        if let value = dic["value"] as? Int
                        {
                            element["default"] = value as AnyObject?
                        }
                        else
                        {
                            element["default"] = false as AnyObject?
                        }
                        
                        if isCreateOrEdit
                        {
                            let key = dic["name"] as? String
                            if (Formbackup.value(forKey: key!) as AnyObject? != nil)
                            {
                                element["default"] = Formbackup.value(forKey: key!) as AnyObject?
                                
                            }
                            else
                            {
                                let key = dic["name"] as? String
                                if let value =  formValue[key!] as? String
                                {
                                    let intvalue = Int(value)
                                    element["default"] = intvalue as AnyObject?
                                    
                                }
                                else
                                {
                                    element["default"] = formValue[key!] as AnyObject?
                                    
                                }
                            }
                            
                            
                        }
                        else
                        {
                            
                            let key = dic["name"] as? String
                            element["default"] = formValue[key!] as AnyObject?
                            
                            
                        }
                        //element = createCheckboxFormElement(checkboxDictionary: dic as! Dictionary<String,AnyObject>)
                        
                        formElements.append(element as AnyObject)
                        
                    }
                    
                    else if dic["type"] as! String == "submit" || dic["type"] as! String == "Submit"
                    {
                        //element = createSubmitFormElement(formDictionary: dic as! Dictionary<String,AnyObject>)
                        element["header"] = "" as AnyObject?
                        element["title"] = "Save" as? String as AnyObject?
                        element["action"] = "submitForm:" as AnyObject?
                        formElements.append(element as AnyObject)
                    }
                    else if dic["type"] as! String == "Label" || dic["type"] as! String == "label"
                    {
                        element["type"] = "Label" as AnyObject?
                        element["title"] = dic["label"] as? String as AnyObject?
                        element["key"] = dic["name"] as? String as AnyObject?
                        element["default"] = 0 as AnyObject?
                        let key = dic["name"] as? String
                        if (Formbackup.value(forKey: key!) != nil)
                        {
                            element["default"] = Formbackup.value(forKey: key!) as AnyObject?
                        }
                        if dic["name"] as! String == "cashHeading"
                        {
                            element["action"] = "showCashOnDelivery:" as AnyObject?
                        }
                        else if dic["name"] as! String == "mangopayHeading"
                        {
                            element["action"] = "showMangoFields:" as AnyObject?
                        }
                        else if dic["name"] as! String == "PaypalHeading"
                        {
                            element["action"] = "showPaypalFields:" as AnyObject?
                        }
                        else if dic["name"] as! String  == "stripHeading"
                        {
                            element["action"] = "showStripeFields:" as AnyObject?
                        }
                        else if dic["name"] as! String == "checkHeading"
                        {
                            element["action"] = "showChequeField:" as AnyObject?
                        }
                        else if dic["name"] as! String == "moneyorderHeading"
                        {
                            element["action"] = "showMoneyOrderFields:" as AnyObject?
                        }
                        formElements.append(element as AnyObject)
                    }
                    
                    else if dic["type"] as! String == "Textarea" || dic["type"] as! String == "textarea"
                    {
                        element["type"] = "longtext" as AnyObject?
                        element["key"] = dic["name"] as? String as AnyObject?
                        element["title"] = dic["label"] as? String as AnyObject?
                        element["default"] = "" as AnyObject?
                        
                        if isCreateOrEdit
                        {
                            let key = dic["name"] as? String
                            if (key != nil)
                            {
                                if formValue[key!] as AnyObject? != nil{
                                    element["default"] = formValue[key!] as AnyObject?
                                }else{
                                    element["default"] = Formbackup.value(forKey: key!) as AnyObject?
                                }
                            }
                            else
                            {
                                element["default"] = "" as AnyObject?
                            }
                        }
                        else
                        {
                            let key = dic["name"] as? String
                            element["default"] = formValue[key!] as AnyObject?
                        }
                        
                        if let description = dic["description"] as? String
                        {
                            element["footer"] = description as AnyObject?
                            
                        }
                        
                        if isCreateOrEdit
                        {
                            let key = dic["name"] as? String
                            if (key != nil && Formbackup[key!] != nil)
                            {
                                element["default"] = Formbackup[key!] as AnyObject?
                            }
                        }
                        //element = createTextareaFormElement(formDictionary: dic as! Dictionary<String,AnyObject>)
                        formElements.append(element as AnyObject)
                    }
                    
                    
                }
            }
                
            else if conditionalForm != nil && conditionalForm == "editStore2"
            {
                if dic["type"] as! String != "" || dic["type"] as! String != ""
                {
                    if dic["type"] as! String == "text" || dic["type"] as! String == "Text"
                    {
                        element["key"] = dic["name"] as? String as AnyObject?
                        if dic["name"] as? String == "url"
                        {
                            element["type"] = "url" as AnyObject?
                        }
                        element["title"] = dic["label"] as? String as AnyObject?
                        element["default"] = "" as AnyObject?
                        let key = dic["name"] as? String
                        if ( Formbackup[key!] != nil)
                        {
                            element["default"] = Formbackup[key!] as AnyObject?
                        }
                        else if ( formValue[key!] != nil )
                        {
                            element["default"] = formValue[key!] as AnyObject?
                        }
                        else
                        {
                            element["default"] = "" as AnyObject?
                        }
                        
                        if let description = dic["description"] as? String
                        {
                            element["footer"] = description as AnyObject?
                        }
                        formElements.append(element as AnyObject)
                    }
                    else if dic["type"] as! String == "Checkbox" || dic["type"] as! String == "checkbox"
                    {
                        element["type"] = "option" as AnyObject?
                        element["key"] = dic["name"] as? String as AnyObject?
                        element["title"] = dic["label"] as? String as AnyObject?
                        if let value = dic["value"] as? Int
                        {
                            element["default"] = value as AnyObject?
                        }
                        else
                        {
                            element["default"] = false as AnyObject?
                        }
                        
                        let key = dic["name"] as? String
                        element["default"] = formValue[key!] as AnyObject?
                        formElements.append(element as AnyObject)
                    }
                    else if dic["type"] as! String == "submit" || dic["type"] as! String == "Submit"
                    {
                        element["header"] = "" as AnyObject?
                        element["title"] = "Save Changes" as? String as AnyObject?
                        element["action"] = "submitForm:" as AnyObject?
                        formElements.append(element as AnyObject)
                    }
                    else if dic["type"] as! String == "Textarea" || dic["type"] as! String == "textarea"
                    {
                        element["type"] = "longtext" as AnyObject?
                        element["key"] = dic["name"] as? String as AnyObject?
                        element["title"] = dic["label"] as? String as AnyObject?
                        element["default"] = "" as AnyObject?
                        let key = dic["name"] as? String
                        element["default"] = formValue[key!] as AnyObject?
                        
                        
                        if let description = dic["description"] as? String
                        {
                            element["footer"] = description as AnyObject?
                            
                        }
                        
                        /*if isCreateOrEdit
                        {
                            let key = dic["name"] as? String
                            if (key != nil && Formbackup[key!] != nil)
                            {
                                element["default"] = Formbackup[key!] as AnyObject?
                            }
                        } */
                        
                        formElements.append(element as AnyObject)
                    }
                    else if dic["type"] as! String == "Select" || dic["type"] as! String == "select" || dic["type"] as! String == "Radio" || dic["type"] as! String == "radio"
                    {
                        element["cell"] = "FXFormOptionPickerCell" as AnyObject?
                        element["key"] = dic["name"] as? String as AnyObject?
                        element["title"] = dic["label"] as? String as AnyObject?
                        if let description = dic["description"] as? String
                        {
                            element["footer"] = description as AnyObject?
                        }
                        else if (( dic["type"] as! String == "select" || dic["type"] as! String == "Select" ) && dic["name"] as! String == "category_id")
                        {
                            element["action"] = "storeMainCategoryChanged:" as AnyObject?
                            //element["action"] = "listingDependencyValueChanged:" as AnyObject?
                        }
                        else if (( dic["type"] as! String == "select" || dic["type"] as! String == "Select" ) && dic["name"] as! String == "subcategory_id")
                        {
                            element["action"] = "storeSubCategoryChanged:" as AnyObject?
                        }
                        else if (( dic["type"] as! String == "select" || dic["type"] as! String == "Select" ) && dic["name"] as! String == "subsubcategory_id")
                        {
                            element["action"] = "storeSubSubCategoryChanged:" as AnyObject?
                        }
                        
                        if let option = dic["multiOptions"] as? NSArray
                        {
                            if option.count > 0
                            {
                                let key = dic["name"] as? String
                                if ( Formbackup[key!] != nil)
                                {
                                    element["default"] = Formbackup[key!] as AnyObject?
                                }
                                else if ( formValue[key!] != nil )
                                {
                                    let value = formValue[key!] as! Int
                                    let id = Int(value)
                                    element["default"] = option[id] as AnyObject?
                                }
                                else
                                {
                                    element["default"] = "" as AnyObject?
                                }
                            }
                            element["options"] = option
                        }
                            
                        else if let _ = dic["multiOptions"] as? NSDictionary
                        {
                            var options = [AnyObject]()
                            if let option = dic["multiOptions"] as? NSDictionary
                            {
                                
                                let array2 = option.allKeys.sorted(by: { (key1, key2) -> Bool in
                                    (key1 as! String) < (key2 as! String)
                                })
                                
                                for index in array2
                                {
                                    options.append(option["\(index)"]! as AnyObject)
                                }
                                
                            }
                            let key = dic["name"] as? String
                            
                            if ( Formbackup[key!] != nil)
                            {
                                element["default"] = Formbackup[key!] as AnyObject?
                            }
                            else if ( formValue[key!] != nil)
                            {
                                element["default"] = formValue[key!] as AnyObject?
                            }
                            else
                            {
                                element["default"] = "" as AnyObject?
                            }
                            
                            if (( dic["type"] as! String == "radio" || dic["type"] as! String == "Radio") && dic["name"] as! String == "all_regions")
                            {
                                let key = "region"
                                if let value = formValue[key] as AnyObject?
                                {
                                    if value as! _OptionalNilComparisonType == 0 as AnyObject?
                                    {
                                        element["default"] = "No" as AnyObject?
                                    }
                                    else
                                    {
                                        element["default"] = "Yes" as AnyObject?
                                    }
                                }
                                
                            }
                            
                            
                            element["options"] = options as AnyObject?
                            
                        }
                        formElements.append(element as AnyObject)
                    }
                    
                }
            }
            
            else if (conditionalForm != nil) && (conditionalForm  == "listings" || conditionalForm  == "Page" || conditionalForm  == "Review" || conditionalForm  == "products" || conditionalForm  == "ads" || conditionalForm == "sitegroup" || conditionalForm == "Advanced Video" || conditionalForm == "Channel" || conditionalForm == "Video" || conditionalForm == "StoreCreate" || conditionalForm == "shippingMethod" || conditionalForm == "paymentMethod2" || conditionalForm == "editStore" || conditionalForm == "addProduct" || conditionalForm == "editFile" || conditionalForm == "editProduct")
                
            {
                
                //MARK: conditionalForm  == "listings" || "Page" || "Review" || "sitegroup"
                if dic["type"] as! String != "" || dic["Type"] as! String != ""
                {
                    if dic["type"] as! String == "Text"
                    {
                        element["key"] = dic["name"] as? String as AnyObject?
                        if dic["name"] as? String == "url"
                        {
                            element["type"] = "url" as AnyObject?
                        }
                        
                        element["title"] = dic["label"] as? String as AnyObject?
                        element["default"] = "" as AnyObject?
                        
                        if isCreateOrEdit
                        {
                            
                            let key = dic["name"] as? String
                            if (key != nil)
                            {
                                element["default"] = Formbackup[key!] as AnyObject?
                                //element["default"] = Formbackup.value(forKey: key!) as AnyObject?
                            }
                            if dic["name"] as! String == "product_search"
                            {
                                if Formbackup["product_search"] != nil
                                {
                                    element["default"] = Formbackup["product_search"] as AnyObject?
                                }
                            }
                        }
                        
                        if globFilterValue != ""
                        {
                            if dic["name"] as! String == "search"{
                                element["default"] = globFilterValue as AnyObject?
                                
                            }
                        }
                        
                        
                        if !isCreateOrEdit
                        {
                            let key = dic["name"] as? String
                            if (Formbackup[key!] != nil)
                            {
                                element["default"] = Formbackup[key!] as AnyObject?
                            }
                            else if (formValue[key!] != nil)
                            {
                                element["default"] = formValue[key!] as AnyObject?
                            }
                            else
                            {
                                element["default"] = "" as AnyObject?
                            }
                            
                            if dic["name"] as! String == "product_search"
                            {
                                if Formbackup["product_search"] != nil
                                {
                                    element["default"] = Formbackup["product_search"] as AnyObject?
                                }
                                else if bundledGroupedProducts.length > 0
                                {
                                    bundledGroupedProducts = bundledGroupedProducts.substring(to: bundledGroupedProducts.index(before: bundledGroupedProducts.endIndex))
                                    element["default"] = bundledGroupedProducts as AnyObject?
                                }

                            }
                            
                        }
                        
                        if let description = dic["description"] as? String
                        {
                            element["footer"] = description as AnyObject?
                        }
                        
                        if (conditionalForm != nil && conditionalForm == "generalSettings")
                        {
                            let key = dic["name"] as? String
                            element["default"] = formValue[key!] as AnyObject?
                            
                        }
                        if (( conditionalForm != nil && (conditionalForm == "addProduct" || conditionalForm == "editProduct")) && dic["name"] as! String == "product_search" )
                        {
                            element["action"] = "productSearchValueChanged:" as AnyObject?
                            //element["class"] = "ProductSuggestViewController" as AnyObject?
                            if Formbackup["product_search"] != nil
                            {
                            element["default"] = Formbackup["product_search"] as AnyObject?
                            }
                            /*
                            if suggestedProducts.count > 0
                            {
                                element["default"] = suggestedProducts[0] as AnyObject?
                            } */
                            
                        }
                        
                        if conditionalForm == "listings" || conditionalForm == "Page"
                        {
                            let key = dic["name"] as? String ?? ""
                            if key == "location" || key.range(of: "location") != nil
                            {
                                element["action"] = "formLocation:" as AnyObject?
                                if isCreateOrEdit
                                {
                                    element["default"] = locationInForm as AnyObject?
                                }
                                else
                                {
                                    if locationInForm != ""
                                    {
                                        element["default"] = locationInForm as AnyObject?
                                    }
                                    else
                                    {
                                        if let value = formValue.value(forKey: key)
                                        {
                                            element["default"] = value as AnyObject?
                                        }
                                    }
                                    
                                }
                            }
                        }
                        
                        
                        formElements.append(element as AnyObject)
                        
                    }
                    else if dic["type"] as! String == "Slider"
                    {
                        element["title"] = dic["label"] as? String as AnyObject?
                        element["key"] = dic["name"] as? String as AnyObject?
                        element["default"] = "" as AnyObject?
                        
                        if isCreateOrEdit
                        {
                            let key = dic["name"] as? String
                            if (key != nil && Formbackup[key!] != nil)
                            {
                                element["default"] = Formbackup[key!] as AnyObject?
                            }
                        }
                        
                        formElements.append(element as AnyObject)
                        
                    }
                    else if dic["type"] as! String == "Hidden"
                    {
                        element["type"] = "option" as AnyObject?
                        element["key"] = dic["name"] as? String as AnyObject?
                        element["title"] = dic["label"] as? String as AnyObject?
                        
                        
                        if let value = dic["value"] as? Int
                        {
                            element["default"] = value as AnyObject?
                        }
                        else
                        {
                            element["default"] = "0" as AnyObject?
                        }
                        
                        if !isCreateOrEdit
                        {
                            let key = dic["name"] as? String
                            element["default"] = formValue[key!] as AnyObject?
                        }
                        
                        if dic["type"] as! String == "Hidden" && dic["name"] as! String == "is_online"
                        {
                            element["action"] = "fieldValueChanged:" as AnyObject?
                            
                        }
                        
                        if isCreateOrEdit
                        {
                            let key = dic["name"] as? String
                            if (key != nil)
                            {
                                element["default"] = Formbackup.value(forKey: key!) as AnyObject?
                            }
                            else
                            {
                                element["default"] = "" as AnyObject?
                                
                                
                            }
                        }
                        
                        formElements.append(element as AnyObject)
                    }
                    else if dic["type"] as! String == "Rating"
                    {
                        
                        element["type"] = "rateview" as AnyObject?
                        element["key"] = dic["name"] as? String as AnyObject?
                        element["title"]  = dic["label"] as? String as AnyObject?
                        element["action"] = "getRating:" as AnyObject?
                        
                        
                        let key = dic["name"] as? String
                        if !isCreateOrEdit {
                            
                            if key != nil
                            {
                                element["default"] = formValue[key!] as AnyObject?
                            }
                        }
                        
                        formElements.append(element as AnyObject)
                    }
                    else if dic["type"] as! String == "Integer"
                    {
                        element["type"] = "integer" as AnyObject?
                        element["key"] = dic["name"] as? String as AnyObject?
                        element["header"] = "" as AnyObject?
                        element["title"] = dic["label"] as? String as AnyObject?
                        
                        let key = dic["name"] as? String ?? ""
                        if isCreateOrEdit
                        {
                            if let val = Formbackup.value(forKey: key)
                            {
                                element["default"] = val as AnyObject?
                            }
                            else
                            {
                                element["default"] = "" as AnyObject?
                            }
                        }
                        else
                        {
                            if let val = Formbackup.value(forKey: key)
                            {
                                element["default"] = val as AnyObject?
                            }
                            else if let val = formValue.value(forKey: key)
                            {
                                element["default"] = val as AnyObject?
                            }
                            else
                            {
                                element["default"] = "" as AnyObject?
                            }
                        }
                        
                        formElements.append(element as AnyObject)
                    }

                    else if dic["type"] as! String == "File"
                    {
                        
                        element["key"] = dic["name"] as? String as AnyObject?
                        element["title"] = dic["label"] as? String as AnyObject?
                        if multiplePhotoSelection == true{
                            element["class"] = "UploadPhotosViewController" as AnyObject?
                        }
                        else
                        {
                            element["type"] = "image" as AnyObject?
                        }
                        if conditionalForm == "addProduct"
                        {
                            element["action"] = "holdValues:" as AnyObject
                        }
                        
                        if isCreateOrEdit
                        {
                            
                            let key = dic["name"] as? String
                            if key != nil
                            {
                                element["default"] = Formbackup.value(forKey: key!) as AnyObject?
                            }
                            else
                            {
                                element["default"] = "" as AnyObject?
                                
                            }
                        }
                        
                        formElements.append(element as AnyObject)
                        
                    }
                    else if dic["type"] as! String == "Float"
                    {
                        element["key"] = dic["name"] as? String as AnyObject?
                        element["header"] = "" as AnyObject?
                        element["title"] = dic["label"] as? String as AnyObject?
                        element["type"] = "float" as AnyObject?
                        
                        let key = dic["name"] as? String ?? ""
                        if isCreateOrEdit
                        {
                            if let val = Formbackup.value(forKey: key)
                            {
                                element["default"] = val as AnyObject?
                            }
                            else
                            {
                                element["default"] = "" as AnyObject?
                            }
                        }
                        else
                        {
                            if let val = Formbackup.value(forKey: key)
                            {
                                element["default"] = val as AnyObject?
                            }
                            else if let val = formValue.value(forKey: key)
                            {
                                element["default"] = val as AnyObject?
                            }
                            else
                            {
                                element["default"] = "" as AnyObject?
                            }
                        }
                        
                        formElements.append(element as AnyObject)
                    }
                    
                    else if dic["type"] as! String == "Multi_checkbox"
                    {
                        var formsval = [String]()
                        let key = dic["name"] as? String ?? ""
                        if let fvalue = formValue.value(forKey : key) as? Int
                        {
                            let val = String(fvalue)
                            formsval.append(val)
                        }
                        else if let fvalue = formValue.value(forKey : key) as? NSArray
                        {
                            for element in fvalue
                            {
                                if let val = element as? String
                                {
                                    formsval.append(val)
                                }
                                else if let val = element as? Int
                                {
                                    formsval.append(String(val))
                                }
                                
                            }
                        }
                        
                        let multiOptionsDic = dic["multiOptions"] as! NSDictionary
                        var headerShown = true
                        let counts = 2
                        for i in 0 ..< counts where i < counts
                        {
                            if headerShown == true
                            {
                                headerShown = false
                                var element1 = Dictionary<String, AnyObject>()
                                element1["key"] = dic["name"] as? String as AnyObject?
                                element1["title"] = dic["label"] as? String as AnyObject?
                                element1["type"] = "Label" as AnyObject?
                                formElements.append(element1 as AnyObject)
                            }
                            else
                            {
                                for (name, desc) in multiOptionsDic
                                {
                                    element["key"] = multiOptionsDic["\(name)"] as? String as AnyObject?
                                    element["title"] = multiOptionsDic["\(desc)"] as? String as AnyObject?
                                    element["type"] = "option" as AnyObject?
                                    element["default"] = 0 as AnyObject?
                                    
                                    if isCreateOrEdit
                                    {
                                        if let val = Formbackup.value(forKey: desc as! String)
                                        {
                                            if let checkValue = val as? Int
                                            {
                                                element["default"] = checkValue as AnyObject?
                                            }
                                        }
                                    }
                                    
                                    else
                                    {
                                        let val = String(describing : name)
                                        if formsval.contains(val)
                                        {
                                            element["default"] = 1 as AnyObject?
                                        }
                                        else
                                        {
                                            element["default"] = 0 as AnyObject?
                                        }
                                    }
                                    
                                    formElements.append(element as AnyObject)
                                }
                            }
                        }
                    }
                    else if dic["type"] as! String == "Password"
                    {
                        element["key"] = dic["name"] as? String as AnyObject?
                        // element["header"] = ""
                        if let description = dic["description"] as? String{
                            if description != ""{
                                element["footer"] = description as AnyObject?
                            }
                        }
                       // element["footer"] = dic["description"] as? String as AnyObject?
                        
                        element["title"] = dic["label"] as? String as AnyObject?
                        element["type"] = "password" as AnyObject?
                        formElements.append(element as AnyObject)
                        
                    }
                    else if dic["type"] as! String == "Button"
                    {
                        element["header"] = "" as AnyObject?
                        element["title"] = dic["label"] as? String as AnyObject?
                        element["action"] = "submitForm:" as AnyObject?
                        formElements.append(element as AnyObject)
                    }
                    else if dic["type"] as! String == "Checkbox"
                    {
                        
                        element["type"] = "option" as AnyObject?
                        element["key"] = dic["name"] as? String as AnyObject?
                        element["title"] = dic["label"] as? String as AnyObject?
                        
                        
                        if let value = dic["value"] as? Int
                        {
                            element["default"] = value as AnyObject?
                        }
                        else
                        {
                            element["default"] = false as AnyObject?
                        }
                        
                        if isCreateOrEdit
                        {
                            let key = dic["name"] as? String
                            
                            if (key != nil)
                            {
                                element["default"] = Formbackup[key!] as AnyObject?
                            }
                            else
                            {
                                element["default"] = "" as AnyObject?
                            }
                            
                        }
                        else
                        {
                            
                            let key = dic["name"] as? String
                            element["default"] = formValue[key!] as AnyObject?
                            
                            
                        }
                        
                        if dic["name"] as! String == "is_online"
                        {
                            
                            element["action"] = "fieldValueChanged:" as AnyObject?
                            
                        }
                        
                        formElements.append(element as AnyObject)
                        
                    }
                        
                    else if dic["type"] as! String == "Date"
                    {
                        element["type"] = "datetime" as AnyObject?
                        element["title"] = dic["label"] as? String as AnyObject?
                        element["key"] = dic["name"] as? String as AnyObject?
                        if isCreateOrEdit
                        {
                            let key = dic["name"] as? String
                            
                            if (key != nil)
                            {
                                element["default"] = Formbackup[key!] as AnyObject?
                            }
                            else
                            {
                                element["default"] = "" as AnyObject?
                            }
                            
                            
                        }
                        else
                        {
                            
                            let key = dic["name"] as? String
                            if formValue.value(forKey: key!) is NSString{
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                element["default"] = dateFormatter.date(from: formValue.value(forKey: key!) as! NSString as String) as AnyObject?
                                
                            }
                            
                        }
                        
                        formElements.append(element as AnyObject)
                        
                    }
                    else if (dic["type"] as! String == "Select") || (dic["type"] as! String == "Radio") || (dic["type"] as! String == "select")
                    {
                        element["cell"] = "FXFormOptionPickerCell" as AnyObject?
                        element["key"] = dic["name"] as? String as AnyObject?
                        element["title"] = dic["label"] as? String as AnyObject?
                        if let description = dic["description"] as? String
                        {
                            
                            element["footer"] = description as AnyObject?
                            
                        }
    
                        if conditionalForm == "listings" || conditionalForm == "Page" || conditionalForm == "StoreCreate" || conditionalForm == "products" || conditionalForm  == "ads" || conditionalForm == "sitegroup" || conditionalForm == "Advanced Video" || conditionalForm == "Channel" || conditionalForm == "shippingMethod" || conditionalForm == "editStore" || conditionalForm == "addProduct" || conditionalForm == "editProduct"
                        {
                            
                            
                            if ((dic["type"] as! String == "Select" || dic["type"] as! String == "select") && dic["name"] as! String == "category_id")
                            {
                                if conditionalForm == "editStore"
                                {
                                    element["action"] = "editStoreListingCategoryValueChanged:" as AnyObject?
                                }
                                else
                                {
                                    if conditionalForm == "Page" {
                                    if let isDisabled = dic["isDisable"] as? Bool , isDisabled == false  {
                                        
                                    element["action"] = "listingCategoryValueChanged:" as AnyObject?
                                       
                                       
                                    }
                                    else if let isDisabled = dic["isDisable"] as? Bool , isDisabled == true {
                                        element["action"] = "listingCategoryValueCantChanged:" as AnyObject?
                                    }
                                    else {
                                        element["action"] = "listingCategoryValueChanged:" as AnyObject?
                                        }
                                   
                                    }
                                    else {
                                       element["action"] = "listingCategoryValueChanged:" as AnyObject?
                                    }
                                
                                }
                                
                            }
                            
                            else if ((dic["type"] as! String == "Radio" || dic["type"] as! String == "select") && dic["name"] as! String == "weight_type")
                            {
                                element["action"] = "bundledProductWeightType:" as AnyObject?
                            }
                        
                            else if ((dic["type"] as! String == "Radio" || dic["type"] as! String == "select") && dic["name"] as! String == "adCancelReason")
                            {
                                element["action"] = "adsCategoryValueChanged:" as AnyObject?
                            }
                            
                            else if dic["type"] as! String == "Select" && dic["name"] as! String == "category"
                            {
                                element["action"] = "listingCategoryValueChanged:" as AnyObject?
                            }
                            else if dic["type"] as! String == "Select" &&  dic["name"] as! String == "subcategory_id"
                            {
                                if conditionalForm == "Page" {
                                if let isDisabled = dic["isDisable"] as? Bool , isDisabled == false  {
                                    
                                    element["action"] = "listingsubCategoryValueChanged:" as AnyObject?
                                }
                                else {
                                    element["action"] = "listingsubCategoryValueCantChanged:" as AnyObject?
                                    }
                                
                                }
                                else {
                                    element["action"] = "listingsubCategoryValueChanged:" as AnyObject?

                                }
                            }
                            else if dic["type"] as! String == "Select" &&  dic["name"] as! String == "subsubcategory_id"
                            {
                                element["action"] = "listingsubsubCategoryValueChanged:" as AnyObject?

                            }
                            else if dic["type"] as! String == "Radio" &&  dic["name"] as! String == "end_date_enable"
                            {
                                element["action"] = "fieldValueChanged:" as AnyObject?
                            }
                            else if dic["name"] as! String == "type" || dic["name"] as! String == "dependency"
                            {
                               element["action"] = "fieldValueChanged:" as AnyObject?
                            }
                            if conditionalForm == "addProduct" || conditionalForm == "editProduct"
                            {
                                if ((dic["type"] as! String == "Select" || dic["type"] as! String == "select" || dic["type"] as! String == "Radio" || dic["type"] as! String == "radio") && dic["name"] as! String == "discount")
                                {
                                    element["action"] = "productDiscountEnable:" as AnyObject?
                                }
                                else if ((dic["type"] as! String == "Select" || dic["type"] as! String == "select" || dic["type"] as! String == "Radio" || dic["type"] as! String == "radio") && dic["name"] as! String == "handling_type")
                                {
                                    element["action"] = "discountTypeValueChanged:" as AnyObject?
                                }
                                else if ((dic["type"] as! String == "Select" || dic["type"] as! String == "select" || dic["type"] as! String == "Radio" || dic["type"] as! String == "radio") && dic["name"] as! String == "discount_permanant")
                                {
                                    element["action"] = "discountEndDateChanged:" as AnyObject?
                                }
                                    
                                else if ((dic["type"] as! String == "Select" || dic["type"] as! String == "select" || dic["type"] as! String == "Radio" || dic["type"] as! String == "radio") && dic["name"] as! String == "stock_unlimited")
                                {
                                    element["action"] = "stockUnlimitedValueChanged:" as AnyObject?
                                }
                                    
                                else if ((dic["type"] as! String == "Select" || dic["type"] as! String == "select" || dic["type"] as! String == "Radio" || dic["type"] as! String == "radio") && dic["name"] as! String == "out_of_stock")
                                {
                                    element["action"] = "showOutOfStockYesOrNo:" as AnyObject?
                                }
                                else if ((dic["type"] as! String == "Select" || dic["type"] as! String == "select" || dic["type"] as! String == "Radio" || dic["type"] as! String == "radio") && dic["name"] as! String == "end_date_enable")
                                {
                                    element["action"] = "productEndDateValueChanged:" as AnyObject?
                                }
                            }

                        }
                        
                        if isCreateOrEdit
                        {
                            
                            let key = dic["name"] as? String
                            if (key != nil)
                            {
                                element["default"] = Formbackup[key!] as AnyObject?
                                
                            }
                            else
                            {
                                element["default"] = "" as AnyObject?
                                
                            }
                        }
                        
                        if !isCreateOrEdit
                        {
                            let key = dic["name"] as? String
                            if(key != nil)
                            {
                                element["default"] = Formbackup[key!] as AnyObject?
                            }
                            else
                            {
                                element["default"] = (formValue.value(forKey: key!) as! NSString) as String as AnyObject?
                            }
                        }
                        
                        if let option = dic["multiOptions"] as? NSArray
                        {
                            
                            let key = dic["name"] as? String
                            if(Formbackup[key!] != nil)
                            {
                                element["default"] = Formbackup[key!] as AnyObject?
                            }
                            else if (formValue[key!] != nil)
                            {
                                if let val = formValue[key!] as? String
                                {
                                    element["default"] = val as AnyObject?
                                }
                                else if let val = formValue[key!] as? Int
                                {
                                    element["default"] = option[val] as AnyObject?
//                                    let value = String(val)
//                                    element["default"] = value as AnyObject?
                                }
                            }
                            else
                            {
                                if option.count > 0
                                {
                                    if let value = dic["value"] as? String
                                    {
                                        let id = Int(value)
                                        element["default"] = option[id!] as AnyObject?
                                    }
                                    else
                                    {
                                        element["default"] = option[0] as AnyObject?
                                    }
                                }
                            }

                            element["options"] = option
                            formElements.append(element as AnyObject)
                        }
                        else if let _ = dic["multiOptions"] as? NSDictionary
                        {
                            var options = [AnyObject]()
                            if let option = dic["multiOptions"] as? NSDictionary
                            {
                                
                                let array2 = option.allKeys.sorted(by: { (key1, key2) -> Bool in
                                    (key1 as! String) < (key2 as! String)
                                })
                                
                                for index in array2
                                {
                                    options.append(option["\(index)"]! as AnyObject)
                                }
                                
                                if dic["name"] as! String == "auth_view"
                                {
                                    if let value = dic["value"] as? String
                                    {
                                        element["default"] = option.value(forKey: value) as AnyObject?
                                    }
                                    else
                                    {
                                        element["default"] = options[0]
                                    }
                                    
                                }
                                if dic["name"] as! String == "year"
                                {
                                    //element["default"] = options[3]
                                    if let value = dic["value"] as? String
                                    {
                                        element["default"] = option.value(forKey: value) as AnyObject?
                                    }
                                    else
                                    {
                                        element["default"] = options[0]
                                    }
                                    
                                }
                                else if dic["name"] as! String == "draft"
                                {
                                    if let value = dic["value"] as? String
                                    {
                                        element["default"] = option.value(forKey: value) as AnyObject?
                                    }
                                    else
                                    {
                                        element["default"] = options[1]
                                    }
                                    
                                }
                                    
                                else if dic["name"] as! String == "auth_comment"
                                {
                                    if let value = dic["value"] as? String
                                    {
                                        element["default"] = option.value(forKey: value) as AnyObject?
                                    }
                                    else
                                    {
                                        element["default"] = options[0]
                                    }
                                }
                                else if dic["name"] as! String == "svcreate"
                                {
                                    if let value = dic["value"] as? String
                                    {
                                        element["default"] = option.value(forKey: value) as AnyObject?
                                    }
                                    else
                                    {
                                        element["default"] = options[0]
                                    }
                                }
                                else if dic["name"] as! String == "spcreate"
                                {
                                    if let value = dic["value"] as? String
                                    {
                                        element["default"] = option.value(forKey: value) as AnyObject?
                                    }
                                    else
                                    {
                                        element["default"] = options[0]
                                    }
                                }
                                else if dic["name"] as! String == "smcreate"
                                {
                                    if let value = dic["value"] as? String
                                    {
                                        element["default"] = option.value(forKey: value) as AnyObject?
                                    }
                                    else
                                    {
                                        element["default"] = options[0]
                                    }
                                }
                                else if dic["name"] as! String == "secreate"
                                {
                                    if let value = dic["value"] as? String
                                    {
                                        element["default"] = option.value(forKey: value) as AnyObject?
                                    }
                                    else
                                    {
                                        element["default"] = options[0]
                                    }
                                }
                                else if dic["name"] as! String == "sdicreate"
                                {
                                    if let value = dic["value"] as? String
                                    {
                                        element["default"] = option.value(forKey: value) as AnyObject?
                                    }
                                    else
                                    {
                                        element["default"] = options[0]
                                    }
                                }
                                else if dic["name"] as! String == "sdcreate"
                                {
                                    if let value = dic["value"] as? String
                                    {
                                        element["default"] = option.value(forKey: value) as AnyObject?
                                    }
                                    else
                                    {
                                        element["default"] = options[0]
                                    }
                                }
                                else if dic["name"] as! String == "splcreate"
                                {
                                    if let value = dic["value"] as? String
                                    {
                                        element["default"] = option.value(forKey: value) as AnyObject?
                                    }
                                    else
                                    {
                                        element["default"] = options[0]
                                    }
                                }
                                else if dic["name"] as! String == "sncreate"
                                {
                                    if let value = dic["value"] as? String
                                    {
                                        element["default"] = option.value(forKey: value) as AnyObject?
                                    }
                                    else
                                    {
                                        element["default"] = options[0]
                                    }
                                }
                                else if dic["name"] as! String == "all_post"
                                {
                                    if let value = dic["value"] as? String
                                    {
                                        element["default"] = option.value(forKey: value) as AnyObject?
                                    }
                                    else
                                    {
                                        element["default"] = options[0]
                                    }
                                    
                                }
                                else if dic["name"] as! String == "auth_post"
                                {
                                    if let value = dic["value"] as? String
                                    {
                                        element["default"] = option.value(forKey: value) as AnyObject?
                                    }
                                    else
                                    {
                                        element["default"] = options[0]
                                    }
                                    
                                }
                                else if dic["name"] as! String == "auth_topic"
                                {
                                    if let value = dic["value"] as? String
                                    {
                                        element["default"] = option.value(forKey: value) as AnyObject?
                                    }
                                    else
                                    {
                                        element["default"] = options[0]
                                    }
                                    
                                }
                                else if dic["name"] as! String == "auth_photo"
                                {
                                    if let value = dic["value"] as? String
                                    {
                                        element["default"] = option.value(forKey: value) as AnyObject?
                                    }
                                    else
                                    {
                                        element["default"] = options[0]
                                    }
                                    
                                }
                                else if dic["name"] as! String == "auth_video"
                                {
                                    if let value = dic["value"] as? String
                                    {
                                        element["default"] = option.value(forKey: value) as AnyObject?
                                    }
                                    else
                                    {
                                        element["default"] = options[0]
                                    }
                                    
                                }
                                else if dic["name"] as! String == "draft"
                                {
                                    if let value = dic["value"] as? String
                                    {
                                        element["default"] = option.value(forKey: value) as AnyObject?
                                    }
                                    else
                                    {
                                        element["default"] = options[1]
                                    }
                                    
                                }
                                
                                else
                                {
                                    if dic["name"] as! String == "category_id"
                                    {
                                        if defaultCategory != nil
                                        {
                                            if Formbackup["category_id"] != nil {
                                                if Formbackup["category_id"] as! String != ""{
                                                    
                                                    element["default"] = Formbackup["category_id"] as! String as AnyObject?
                                                    
                                                    
                                                }
                                            }else{
                                                if defaultCategory != "" {
                                                element["default"] = defaultCategory as AnyObject?
                                                }
                                                else
                                                {
                                                    if formValue.value(forKey: "category_id") != nil {
                                                        element["default"] =  option.value(forKey: "\(formValue.value(forKey: "category_id")!)") as AnyObject?
                                                    }
                                                }
                                            }
                                        }
                                        else
                                        {
                                            element["default"] = option.value(forKey: "0") as AnyObject?
                                        }
                                        
                                    }
                                    if dic["name"] as! String == "subcategory_id"
                                    {
                                        if Formbackup["subcategory_id"] != nil
                                        {
                                            element["default"] = Formbackup["subcategory_id"] as AnyObject?
                                        }
                                        else
                                        {
                                            element["default"] = option.value(forKey: "0") as AnyObject?
                                        }
                                        
                                    }
                                    if dic["name"] as! String == "subsubcategory_id"
                                    {
                                        if Formbackup["subsubcategory_id"] != nil
                                        {
                                            element["default"] = Formbackup["subsubcategory_id"] as AnyObject?
                                        }
                                        else
                                        {
                                            element["default"] = option.value(forKey: "0") as AnyObject?
                                        }
                                    }
                                }
                                
                                if conditionalForm == "editStore"
                                {
                                    if dic["name"] as! String == "auth_view"
                                    {
                                        let key = dic["name"] as? String
                                        
                                        if ( Formbackup[key!] != nil)
                                        {
                                            element["default"] = Formbackup[key!] as AnyObject?
                                        }
                                        else if ( formValue[key!] != nil)
                                        {
                                            element["default"] = formValue[key!] as AnyObject?
                                        }
                                        
                                        else if let value = dic["value"] as? String
                                        {
                                            element["default"] = value as AnyObject?
                                        }
                                        else
                                        {
                                            element["default"] = options[0]
                                        }
                                        
                                    }
                                    
                                    else if dic["name"] as! String == "auth_comment"
                                    {
                                        let key = dic["name"] as? String
                                        
                                        if ( Formbackup[key!] != nil)
                                        {
                                            element["default"] = Formbackup[key!] as AnyObject?
                                        }
                                        else if ( formValue[key!] != nil)
                                        {
                                            element["default"] = formValue[key!] as AnyObject?
                                        }
                                            
                                        else if let value = dic["value"] as? String
                                        {
                                            element["default"] = value as AnyObject?
                                        }
                                        else
                                        {
                                            element["default"] = options[0]
                                        }
                                    }
                                    else if dic["name"] as! String == "svcreate"
                                    {
                                        let key = dic["name"] as? String
                                        
                                        if ( Formbackup[key!] != nil)
                                        {
                                            element["default"] = Formbackup[key!] as AnyObject?
                                        }
                                        else if ( formValue[key!] != nil)
                                        {
                                            element["default"] = formValue[key!] as AnyObject?
                                        }
                                            
                                        else if let value = dic["value"] as? String
                                        {
                                            element["default"] = value as AnyObject?
                                        }
                                        else
                                        {
                                            element["default"] = options[0]
                                        }
                                    }
                                    else if dic["name"] as! String == "spcreate"
                                    {
                                        let key = dic["name"] as? String
                                        
                                        if ( Formbackup[key!] != nil)
                                        {
                                            element["default"] = Formbackup[key!] as AnyObject?
                                        }
                                        else if ( formValue[key!] != nil)
                                        {
                                            element["default"] = formValue[key!] as AnyObject?
                                        }
                                            
                                        else if let value = dic["value"] as? String
                                        {
                                            element["default"] = value as AnyObject?
                                        }
                                        else
                                        {
                                            element["default"] = options[0]
                                        }
                                    }
                                    
                                    
                                }
                                
                                if globalCatg != ""
                                {
                                    if dic["label"] as! String == "Category"
                                    {
                                        element["default"] = "\(globalCatg)" as AnyObject?
                                    }
                                }
                                
                                if globalTypeSearch != ""
                                {
                                    element["default"] = "\(globalTypeSearch)" as AnyObject?
                                }
                                
                                
                                if filterSearchFlag == false
                                {
                                    if !isCreateOrEdit
                                    {
                                        let key = dic["name"] as? String
                                        if dic["name"] as! String == "subcategory_id"
                                        {
                                            if !(defaultsubCategory != nil && defaultsubCategory != "")
                                            {
                                                
                                                let index: AnyObject? = formValue[key!] as AnyObject?
                                                var str = ""
                                                if index != nil
                                                {
                                                    if let option = option["\(index!)"] as? String
                                                    {
                                                        str = option
                                                    }
                                                    
                                                    element["default"] = str as AnyObject?
                                                    
                                                }
                                            }
                                        }
                                        else if dic["name"] as! String == "subsubcategory_id"
                                        {
                                            if !(defaultsubsubCategory != nil && defaultsubsubCategory != "")
                                            {
                                                
                                                let index: AnyObject? = formValue[key!] as AnyObject?
                                                var str = ""
                                                if index != nil
                                                {
                                                    if let option = option["\(index!)"] as? String
                                                    {
                                                        str = option
                                                    }
                                                    
                                                    element["default"] = str as AnyObject?
                                                    
                                                }
                                            }
                                        }
                                            
                                        else if (key!.range(of: "_field_") != nil)
                                        {
                                            
                                            element["default"] = formValue[key!] as AnyObject?
                                            
                                        }
                                        else
                                        {
                                            if dic["name"] as! String == "category_id" && defaultCategory != nil //&& defaultCategory != ""
                                            {
                                                //element["default"] = defaultCategory as AnyObject?
                                            }
                                            else if dic["name"] as! String == "discount"
                                            {
                                                
                                                let key = dic["name"] as! String
                                                
                                                if ( Formbackup[key] != nil)
                                                {
                                                    element["default"] = Formbackup[key] as AnyObject?
                                                }
                                                else if formValue[key] != nil
                                                {
                                                    if let keyValue = formValue[key] as? String
                                                    {
                                                        if keyValue == "discount_1"
                                                        {
                                                            element["default"] = "Yes" as AnyObject?
                                                        }
                                                        else if keyValue == "discount_0"
                                                        {
                                                            element["default"] = "No" as AnyObject?
                                                        }
                                                    }
                                                    else if let keyValue = formValue["key"] as? Int
                                                    {
                                                        if keyValue == 1
                                                        {
                                                            element["default"] = "Yes" as AnyObject?
                                                        }
                                                        else if keyValue == 0
                                                        {
                                                            element["default"] = "No" as AnyObject?
                                                        }
                                                    }

                                                    else
                                                    {
                                                        element["default"] = "" as AnyObject?
                                                        print(element["default"]!)
                                                    }
                                                    
                                                    
                                                    
                                                }
                                            }
                                            else if dic["name"] as! String == "handling_type"
                                            {
                                                
                                                let key = dic["name"] as! String
                                                
                                                if ( Formbackup[key] != nil)
                                                {
                                                    element["default"] = Formbackup[key] as AnyObject?
                                                }
                                                else if formValue[key] != nil
                                                {
                                                    if let keyValue = formValue[key] as? String
                                                    {
                                                       if keyValue == "fixed_0"
                                                       {
                                                            element["default"] = "Fixed" as AnyObject?
                                                       }
                                                       else if keyValue == "percent_0"
                                                       {
                                                            element["default"] = "Percent" as AnyObject?
                                                       }
                                                    }
                                                    else if let keyValue = formValue[key] as? Int
                                                    {
                                                        if keyValue == 0
                                                        {
                                                            element["default"] = "Fixed" as AnyObject?
                                                        }
                                                        else if keyValue == 1
                                                        {
                                                            element["default"] = "Percent" as AnyObject?
                                                        }
                                                    }
                                                    else
                                                    {
                                                        element["default"] = "" as AnyObject?
                                                    }
                                                }
                                            }
                                            else if dic["name"] as! String == "discount_permanant"
                                            {
                                                
                                                let key = dic["name"] as! String
                                                
                                                if ( Formbackup[key] != nil)
                                                {
                                                    element["default"] = Formbackup[key] as AnyObject?
                                                }
                                                else if formValue[key] != nil
                                                {
                                                    if let keyValue = formValue[key] as? String
                                                    {
                                                        if keyValue == "discount_permanant_1"
                                                        {
                                                            element["default"] = "No end date." as AnyObject?
                                                        }
                                                        else if keyValue == "discount_permanant_0"
                                                        {
                                                            element["default"] = "End Discount on specified date" as AnyObject?
                                                        }
                                                    }
                                                    else if let keyValue = formValue[key] as? Int
                                                    {
                                                        if keyValue == 0
                                                        {
                                                            element["default"] = "End Discount on specified date" as AnyObject?
                                                        }
                                                        else if keyValue == 1
                                                        {
                                                            element["default"] = "No end date." as AnyObject?
                                                        }
                                                    }
                                                    else
                                                    {
                                                        element["default"] = "" as AnyObject?
                                                    }
                                                    
                                                    
                                                    
                                                }
                                            }
                                            else if dic["name"] as! String == "stock_unlimited"
                                            {
                                                
                                                let key = dic["name"] as! String
                                                
                                                if ( Formbackup[key] != nil)
                                                {
                                                    element["default"] = Formbackup[key] as AnyObject?
                                                }
                                                else if formValue[key] != nil
                                                {
                                                    if let keyValue = formValue[key] as? String
                                                    {
                                                        if keyValue == "stock_unlimited_0"
                                                        {
                                                            element["default"] = "No" as AnyObject?
                                                        }
                                                        else if keyValue == "stock_unlimited_1"
                                                        {
                                                            element["default"] = "Yes" as AnyObject?
                                                        }
                                                    }
                                                    else if let keyValue = formValue[key] as? Int
                                                    {
                                                        if keyValue == 0
                                                        {
                                                            element["default"] = "No" as AnyObject?
                                                        }
                                                        else if keyValue == 1
                                                        {
                                                            element["default"] = "Yes" as AnyObject?
                                                        }
                                                    }
                                                    else
                                                    {
                                                        element["default"] = "" as AnyObject?
                                                    }
                                                }
                                            }
                                            else if dic["name"] as! String == "end_date_enable"
                                            {
                                                
                                                let key = dic["name"] as! String
                                                
                                                if ( Formbackup[key] != nil)
                                                {
                                                    element["default"] = Formbackup[key] as AnyObject?
                                                }
                                                else if formValue[key] != nil
                                                {
                                                    
                                                    if formValue[key] as! Int == 1
                                                    {
                                                        element["default"] = "End Discount on specified date" as AnyObject?
                                                    }
                                                    else if formValue[key] as! Int == 0
                                                    {
                                                        element["default"] = "No end date." as AnyObject?
                                                    }
                                                    else
                                                    {
                                                        element["default"] = "" as AnyObject?
                                                    }
                                                    
                                                    
                                                    
                                                }
                                            }
                                            else if dic["name"] as! String == "out_of_stock"
                                            {
                                                
                                                let key = dic["name"] as! String
                                                
                                                if ( Formbackup[key] != nil)
                                                {
                                                    element["default"] = Formbackup[key] as AnyObject?
                                                }
                                                else if formValue[key] != nil
                                                {
                                                    if let keyValue = formValue[key] as? String
                                                    {
                                                        if keyValue == "out_of_stock_0"
                                                        {
                                                            element["default"] = "No" as AnyObject?
                                                        }
                                                        else if keyValue == "out_of_stock_1"
                                                        {
                                                            element["default"] = "Yes" as AnyObject?
                                                        }
                                                    }
                                                    else if let keyValue = formValue[key] as? Int
                                                    {
                                                        if keyValue == 0
                                                        {
                                                            element["default"] = "No" as AnyObject?
                                                        }
                                                        else if keyValue == 1
                                                        {
                                                            element["default"] = "Yes" as AnyObject?
                                                        }
                                                    }
                                                    else
                                                    {
                                                        element["default"] = "" as AnyObject?
                                                    }
                                                }
                                            }
                                            else
                                            {
                                                
                                                let index: AnyObject? = formValue[key!] as AnyObject?
                                                var str = ""
                                                if index != nil
                                                {
                                                    if let option = option["\(index!)"] as? String
                                                    {
                                                        str = option
                                                    }
                                                    
                                                    element["default"] = str as AnyObject?
                                                    
                                                }
                                                
                                            }
                                            
                                        }
                                        
                                    }
                                }
                                
                            }
                            if canEditCategory != nil
                            {
                                if canEditCategory! == 0 && dic["name"] as! String == "category_id" && conditionalForm == "editStore"
                                {
                                    print(formValue["category_id"]!)
                                    options.removeAll(keepingCapacity: false)
                                    let catId = formValue["category_id"] as! Int
                                    let option = dic["multiOptions"] as? NSDictionary
                                    options.append(option?["\(catId)"] as AnyObject)
                                    element["options"] = options as AnyObject?
                                    element["default"] = option?["\(catId)"] as AnyObject?
                                
                                }
                                else
                                {
                                    element["options"] = options as AnyObject?
                                }
                            }
                            else
                            {
                                element["options"] = options as AnyObject?
                            }
                            
                            if conditionalForm == "listings"
                            {
                                let key = dic["name"] as? String ?? ""
                                var options = NSDictionary()
                                if let dicOptions = dic["multiOptions"] as? NSArray
                                {
                                    if isCreateOrEdit
                                    {
                                        if let val = Formbackup.value(forKey: key)
                                        {
                                            element["default"] = val as AnyObject?
                                        }
                                        else if let value = dic["value"] as? String
                                        {
                                            let id = Int(value)
                                            element["default"] = dicOptions[id!] as AnyObject?
                                        }
                                        else
                                        {
                                            element["default"] = dicOptions[0] as AnyObject?
                                        }
                                    }
                                    else
                                    {
                                        if let val = Formbackup.value(forKey: key)
                                        {
                                            element["default"] = val as AnyObject?
                                        }
                                        else if let val = formValue.value(forKey: key)
                                        {
                                            element["default"] = val as AnyObject?
                                        }
                                    }
                                }
                                if let dicOptions = dic["multiOptions"] as? NSDictionary
                                {
                                    options = dicOptions
                                    if isCreateOrEdit
                                    {
                                        if let val = Formbackup.value(forKey: key)
                                        {
                                            element["default"] = val as AnyObject?
                                        }
                                        else if let value = dic["value"] as? String
                                        {
                                            element["default"] = options.value(forKey: value) as AnyObject?
                                        }
                                        else
                                        {
                                            element["default"] = "" as AnyObject
                                        }
                                        
                                    }
                                    else
                                    {
                                        if let val = Formbackup.value(forKey: key)
                                        {
                                            element["default"] = val as AnyObject?
                                        }
                                        else if let val = formValue.value(forKey: key)
                                        {
                                            element["default"] = options["\(val)"] as AnyObject?
                                        }
                                        else
                                        {
                                            element["default"] = "" as AnyObject
                                        }
                                    }
                                }
                                
                            }
                            
                            
                            formElements.append(element as AnyObject)
                            
                        }
                    }
                    /* For multiSelect Country
                    else if (dic["type"] as! String == "Multiselects")
                    {
                        element["key"] = dic["name"] as? String as AnyObject?
                        element["title"] = dic["label"] as? String as AnyObject?
                        element["options"] = dic["multiOptions"] as? NSDictionary
                        formElements.append(element as AnyObject)
                    }
                    ****/
                    else if dic["type"] as! String == "Textarea"
                    {
                        
                        if conditionalForm != nil && conditionalForm == "listings" && dic["type"] as! String == "Textarea" && dic["name"] as! String == "overview"{
                            
                            let defaults = UserDefaults.standard
                            defaults.set("Coding overview", forKey: "overviewcheck")
                            
                        }
                        else {
                            
                            element["type"] = "longtext" as AnyObject?
                            
                            if dic["name"] as? String ==  "description"
                            {
                                element["key"] = "change_description" as AnyObject?
                            }
                            else
                            {
                                element["key"] = dic["name"] as? String as AnyObject?
                            }
                            
                            element["title"] = dic["label"] as? String as AnyObject?
                            element["default"] = "" as AnyObject?
                            
                            if isCreateOrEdit
                            {
                                let key = dic["name"] as? String
                                if (key != nil)
                                {
                                    if formValue[key!] as AnyObject? != nil{
                                        element["default"] = formValue[key!] as AnyObject?
                                    }else{
                                        element["default"] = Formbackup.value(forKey: key!) as AnyObject?
                                    }
                                    
                                    
                                }
                                else
                                {
                                    element["default"] = "" as AnyObject?
                                }
                            }
                            else
                            {
                                let key = dic["name"] as? String
                                element["default"] = formValue[key!] as AnyObject?
                            }
                            
                            if let description = dic["description"] as? String
                            {
                                element["footer"] = description as AnyObject?
                                
                            }
                            
                            if isCreateOrEdit
                            {
                                let key = dic["name"] as? String
                                if (key != nil && Formbackup[key!] != nil)
                                {
                                    element["default"] = Formbackup[key!] as AnyObject?
                                }
                            }
                            
                            
                            formElements.append(element as AnyObject)
                        }
                    }
                    else if dic["type"] as! String == "Submit" || dic["type"] as! String == "submit"
                    {
                        element["header"] = "" as AnyObject?
                        
                        let defaults = UserDefaults.standard
                        
                        if let name = defaults.value(forKey: "overviewcheck")
                        {
                            if  name as! String != "" {
                                element["title"] = NSLocalizedString("Continue",comment: "") as AnyObject?
                            }
                            else {
                                element["title"] = dic["label"] as? String as AnyObject?
                            }
                        }
                        if conditionalForm == "editStore"
                        {
                            element["title"] = "Save Changes" as AnyObject?
                        }
                        if conditionalForm == "editFile"
                        {
                            element["title"] = "Save Changes" as AnyObject?
                        }
                        if conditionalForm == "editProduct"
                        {
                            element["title"] = "Save Changes" as AnyObject?
                        }
                        
                        element["action"] = "submitForm:" as AnyObject?
                        formElements.append(element as AnyObject)
                    }
                    
                    else if dic["type"] as! String == "MultiCheckbox"  || dic["type"] as! String == "Multiselect"
                    {
                        /*
                        let multiOptionsDic = dic["multiOptions"] as? NSDictionary
                        var options = [AnyObject]()
                        if let option = dic["multiOptions"] as? NSDictionary
                        {
                            let array2 = option.allKeys.sorted(by: { (key1, key2) -> Bool in
                                (key1 as! String) < (key2 as! String)
                            })
                            var i = 0
                            
                            for index in array2
                            {
                                
                                options.append(option["\(index)"]! as AnyObject)
                                
                                element["key"] = (option["\(index)"]! as AnyObject?)
                                element["title"] = multiOptionsDic?.value(forKey: index as! String) as AnyObject?
                                let key3 = option["\(index)"] as! String
                                if key3 != nil
                                {
                                    element["default"] = Formbackup[option["\(index)"]!] as AnyObject?
                                }
                                else
                                {
                                    element["default"] = "" as AnyObject?
                                }
                                element["type"] = "option" as AnyObject?
                                
                                if !isCreateOrEdit
                                {
                                    var arr = NSArray()
                                    let key = dic["name"] as? String
                                    
                                    if key != "bundle_product_type"
                                    {
                                        if formValue[key!] != nil {
                                            arr = formValue[key!] as! NSArray
                                            
                                            if arr.contains(index)
                                            {
                                                element["default"] = true as AnyObject?
                                            }
                                            else
                                            {
                                                element["default"] = false as AnyObject?
                                            }
                                            i = i+1
                                            
                                        }
                                    }
                                    
                                }
                                
                                formElements.append(element as AnyObject)
                                
                            }
                        }
                   */
                        var formsval = [String]()
                        let key = dic["name"] as? String ?? ""
                        if let fvalue = formValue.value(forKey : key) as? Int
                        {
                            let val = String(fvalue)
                            formsval.append(val)
                        }
                        else if let fvalue = formValue.value(forKey : key) as? NSArray
                        {
                            for element in fvalue
                            {
                                if let val = element as? String
                                {
                                    formsval.append(val)
                                }
                                else if let val = element as? Int
                                {
                                    formsval.append(String(val))
                                }
                                
                            }
                        }
                        
                        let multiOptionsDic = dic["multiOptions"] as! NSDictionary
                        var headerShown = true
                        let counts = 2
                        for i in 0 ..< counts where i < counts
                        {
                            if headerShown == true
                            {
                                headerShown = false
                                var element1 = Dictionary<String, AnyObject>()
                                element1["key"] = dic["name"] as? String as AnyObject?
                                element1["title"] = dic["label"] as? String as AnyObject?
                                element1["type"] = "Label" as AnyObject?
                                formElements.append(element1 as AnyObject)
                            }
                            else
                            {
                                for (name, desc) in multiOptionsDic
                                {
                                    element["key"] = multiOptionsDic["\(name)"] as? String as AnyObject?
                                    element["title"] = multiOptionsDic["\(desc)"] as? String as AnyObject?
                                    element["type"] = "option" as AnyObject?
                                    element["default"] = 0 as AnyObject?
                                    
                                    if isCreateOrEdit
                                    {
                                        if let val = Formbackup.value(forKey: desc as! String)
                                        {
                                            if let checkValue = val as? Int
                                            {
                                                element["default"] = checkValue as AnyObject?
                                            }
                                        }
                                    }
                                        
                                    else
                                    {
                                        let val = String(describing : name)
                                        if formsval.contains(val)
                                        {
                                            element["default"] = 1 as AnyObject?
                                        }
                                        else
                                        {
                                            element["default"] = 0 as AnyObject?
                                        }
                                    }
                                    
                                    formElements.append(element as AnyObject)
                                }
                            }
                        }
                    }
                    
                    else if dic["type"] as! String == "Label"
                    {
                        element["type"] = "Label" as AnyObject?
                        element["title"] = dic["label"] as? String as AnyObject?
                        element["key"] = dic["name"] as? String as AnyObject?
                        formElements.append(element as AnyObject)
                    }
                    
                }
            }
            else if (conditionalForm != nil && conditionalForm  == "advancedevents") || (conditionalForm != nil && conditionalForm  == "HostChange"  )
            {
                //MARK: conditionalForm  == "advancedevents"
                if dic["type"] as! String != "" || dic["Type"] as! String != ""
                {
                    if dic["type"] as! String == "Text"
                    {
                        element["default"] = "" as AnyObject?
                        
                        element["key"] = dic["name"] as? String as AnyObject?
                        if dic["name"] as? String == "url"
                        {
                            element["type"] = "url" as AnyObject?
                        }
                        
                        element["title"] = dic["label"] as? String as AnyObject?
                        
                        if globFilterValue != ""
                        {
                            element["default"] = globFilterValue as AnyObject?
                        }
                        
                        if isCreateOrEdit
                        {
                            let key = dic["name"] as? String
                            if (key != nil)
                            {
                                if Formbackup.value(forKey: key!) as AnyObject? != nil {
                                    element["default"] = Formbackup.value(forKey: key!) as AnyObject?
                                }
                                else
                                {
                                    let value = dic["value"] as? String
                                    if key == "host"
                                    {
                                        let defaults = UserDefaults.standard
                                        if let name = defaults.string(forKey: "userName")
                                        {
                                            element["default"] = name as AnyObject?
                                        }
                                        else
                                        {
                                           element["default"] = value as AnyObject?
                                        }
                                    }
                                    else
                                    {
                                    
                                    if (value != nil)
                                    {
                                        element["default"] = value as AnyObject?
                                    }
                                    else
                                    {
                                        element["default"] = "" as AnyObject?
                                    }
                                    }

                                }
                            }
                            else
                            {
                                element["default"] = "" as AnyObject?
                            }
                        }
                        else
                        {
                            let key = dic["name"] as? String
                            if (Formbackup.value(forKey: key!) as AnyObject? != nil)
                            {
                                element["default"] = Formbackup.value(forKey: key!) as AnyObject?
                            }
                            else
                            {
                                let key = dic["name"] as? String
                                element["default"] = formValue[key!] as AnyObject?
                            }
                        }
                        
                        if iscomingFromAdvEvents
                        {
                            let key = dic["name"] as? String
                            element["default"] = formValue[key!] as AnyObject?
                            
                        }
                        
                        if let description = dic["description"] as? String
                        {
                            if dic["name"] as? String != "location"
                            {
                                element["footer"] = description as AnyObject?
                            }
                        }
                        
                        
                        if dic["name"] as? String == "host_auto" {
                            element["action"] = "selectUserAction:" as AnyObject?
                            let defaults = UserDefaults.standard
                            if let name = defaults.string(forKey: "userName")
                            {
                                element["default"] = name as AnyObject?
                            }
                        }
                        
                        let key = dic["name"] as? String ?? ""
                        if key == "location"
                        {
                            element["action"] = "formLocation:" as AnyObject?
                            if isCreateOrEdit
                            {
                                element["default"] = locationInForm as AnyObject?
                            }
                            else
                            {
                                if locationInForm != ""
                                {
                                    element["default"] = locationInForm as AnyObject?
                                }
                                else
                                {
                                    if let value = formValue.value(forKey: key)
                                    {
                                        element["default"] = value as AnyObject?
                                    }
                                }
                                
                            }
                        }
                    
                        

                        formElements.append(element as AnyObject)
                        
                    }
                    else if dic["type"] as! String == "Hidden"
                    {
                        element["type"] = "option" as AnyObject?
                        element["key"] = dic["name"] as? String as AnyObject?
                        element["title"] = dic["label"] as? String as AnyObject?
                        
                        if let value = dic["value"] as? Int
                        {
                            element["default"] = value as AnyObject?
                        }
                        else
                        {
                            element["default"] = "0" as AnyObject?
                        }
                        
                        if isCreateOrEdit
                        {
                            let key = dic["name"] as? String
                            if (key != nil)
                            {
                                element["default"] = Formbackup.value(forKey: key!) as AnyObject?
                            }
                            else
                            {
                                element["default"] = "" as AnyObject?
                                
                            }
                        }
                        else
                        {
                            let key = dic["name"] as? String
                            element["default"] = formValue[key!] as AnyObject?
                        }
                        
                        if dic["type"] as! String == "Hidden" && dic["name"] as! String == "is_online"
                        {
                            element["action"] = "fieldValueChanged:" as AnyObject?
                            
                        }
                        formElements.append((element as AnyObject?)!)
                    }
                    else if dic["type"] as! String == "File"
                    {
                        element["key"] = dic["name"] as AnyObject?
                        element["title"] = dic["label"]  as AnyObject?
                        
                        if multiplePhotoSelection == true{
                            element["class"] = "UploadPhotosViewController" as AnyObject?
                        }else{
                            element["type"] = "image" as AnyObject?
                        }
                        
                        if isCreateOrEdit
                        {
                            let key = dic["name"] as? String
                            if (key != nil)
                            {
                                
                                element["default"] = Formbackup.value(forKey: key!) as AnyObject?
                            }
                            else
                            {
                                element["default"] = "" as AnyObject?
                                
                            }
                        }
                        formElements.append(element as AnyObject)
                    }
                    else if dic["type"] as! String == "Float"
                    {
                        element["key"] = dic["name"] as? String as AnyObject?
                        element["header"] = "" as AnyObject?
                        element["title"] = dic["label"] as? String as AnyObject?
                        element["type"] = "float" as AnyObject?
                        formElements.append(element as AnyObject)
                    }
                    else if dic["type"] as! String == "MultiCheckbox"  || dic["type"] as! String == "Multiselect"
                    {
                        let multiOptionsDic = dic["multiOptions"] as? NSDictionary
                        var options = [AnyObject]()
                        if let option = dic["multiOptions"] as? NSDictionary
                        {
                            let array2 = option.allKeys.sorted(by: { (key1, key2) -> Bool in
                                (key1 as! String) < (key2 as! String)
                            })
                            var i = 0
                            
                            for index in array2
                            {
                                i = i+1
                                options.append(option["\(index)"]! as AnyObject)
                                
                                element["key"] = (option["\(index)"]! as AnyObject?)
                                element["title"] = multiOptionsDic?.value(forKey: index as! String) as AnyObject?
                                element["type"] = "option" as AnyObject?
                                if !isCreateOrEdit
                                {
                                    let key = dic["name"] as? String
                                    let value = formValue[key!] as? NSArray
                                    if  value != nil
                                    {
                                        let arr = formValue[key!] as! NSArray
                                        if arr.contains(i)
                                        {
                                            element["default"] = true as AnyObject?
                                        }
                                        else
                                        {
                                            element["default"] = nil
                                        }
                                    }
                                }
                                
                                formElements.append(element as AnyObject)
                            }
                        }
                    }
                    else if dic["type"] as! String == "Checkbox" || dic["type"] as! String == "checkbox"
                    {
                        
                        element["type"] = "option" as AnyObject?
                        element["key"] = dic["name"] as AnyObject?
                        element["title"] = dic["label"] as AnyObject?
                        
                        if let value = dic["value"] as? Int
                        {
                            element["default"] = value as AnyObject?
                        }
                        else if let value = dic["value"] as? String
                        {
                            let intvalue = Int(value)
                            element["default"] = intvalue as AnyObject?
                        }
                        else
                        {
                            element["default"] = false as AnyObject?
                        }
                        if isCreateOrEdit
                        {
                            
                            let key = dic["name"] as? String
                            if (key != nil)
                            {
                                if let _ = Formbackup.value(forKey: key!) as AnyObject?
                                {
                                    
                                    element["default"] = Formbackup.value(forKey: key!) as AnyObject?
                                   
                                    if (Formbackup["is_online"] is Bool && Formbackup["is_online"] as! Bool == false) || (Formbackup["is_online"] is NSNumber && Formbackup["is_online"] as! NSNumber == 0)
                                    {
                                        findOptionalFormIndex("advancedevents", option: 1)
                                    }
                                    else
                                    {
                                        findOptionalFormIndex("advancedevents", option: 2)
                                    }
                                    
                                }
                            }
                            else
                            {
                                element["default"] = "" as AnyObject?
                            }
                        }
                        else
                        {
                            let key = dic["name"] as? String
                            if (Formbackup.value(forKey: key!) as AnyObject? != nil)
                            {
                                element["default"] = Formbackup.value(forKey: key!) as AnyObject?
                                
                            }
                            else
                            {
                                let key = dic["name"] as? String
                                if let value =  formValue[key!] as? String
                                {
                                    let intvalue = Int(value)
                                    element["default"] = intvalue as AnyObject?
                                    
                                }
                                else
                                {
                                    element["default"] = formValue[key!] as AnyObject?
                                    
                                }
                            }
                        }
                        
                        if dic["name"] as! String == "is_online"
                        {
                            element["action"] = "fieldValueChanged:" as AnyObject?
                            
                        }
                        if dic["name"] as! String == "host_link"
                        {
                            element["action"] = "checkBoxValueChanged:" as AnyObject?
                            
                        }
                        if dic["name"] as! String == "monthlyType"
                        {
                            element["action"] = "fieldValueChanged1:" as AnyObject?
                            
                        }
                        
                        formElements.append(element as AnyObject)
                    }
                    else if dic["type"] as! String == "Date"
                    {
                        
                        element["type"] = "datetime" as AnyObject?
                        element["title"] = dic["label"] as? String as AnyObject?
                        element["key"] = dic["name"] as? String as AnyObject?
                        
                        
                        if !isCreateOrEdit
                        {
                            let key = dic["name"] as? String
                            if (formValue[key!] != nil)
                            {
                                if formValue.value(forKey: key!) is NSString{
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                    element["default"] = dateFormatter.date(from: formValue[key!] as! NSString as String) as AnyObject?
                                }
                            }
                        }
                        if isCreateOrEdit
                        {
                            
                            let key = dic["name"] as? String
                            if (key != nil)
                            {
                                
                                element["default"] = Formbackup.value(forKey: key!) as AnyObject?
                            }
                            else
                            {
                                element["default"] = "" as AnyObject?
                                
                            }
                        }
                        formElements.append(element as AnyObject)
                        
                        
                    }
                        
                    
                        
                    /* For multiSelect Country ends ****/
                        
                    else if (dic["type"] as! String == "Select") || (dic["type"] as! String == "Radio")
                    {
                        element["cell"] = "FXFormOptionPickerCell" as AnyObject?
                        element["key"] = dic["name"] as? String as AnyObject?
                        element["title"] = dic["label"] as? String as AnyObject?
                        if let description = dic["description"] as? String
                        {
                            element["footer"] = description as AnyObject?
                        }
                        
                        if dic["type"] as! String == "Select" && dic["name"] as! String == "category_id"
                        {
                            
                            element["action"] = "categoryValueChanged:" as AnyObject?
                            
                        }
                        else if dic["type"] as! String == "Select" &&  dic["name"] as! String == "subcategory_id"
                        {
                            element["action"] = "subCategoryValueChanged:" as AnyObject?
                        }
                        else if dic["type"] as! String == "Select" &&  dic["name"] as! String == "eventrepeat_id"
                        {
                            element["action"] = "EventRepeatValueChanged:" as AnyObject?
                        }
                        else if let dicName =  dic["name"] as? String
                        {
                            if dicName == "host_type_select" {
                            element["action"] = "hostTypeChanged:" as AnyObject?
                            }
                        }
                        
                        if let option = dic["multiOptions"] as? NSArray
                        {
                            
                            if option.count > 0
                            {
                                if let value = dic["value"] as? String
                                {
                                    let id = Int(value)
                                    element["default"] = option[id!] as AnyObject?
                                }
                                else
                                {
                                    element["default"] = option[0] as AnyObject?
                                }
                                
                                element["options"] = option
                                formElements.append(element as AnyObject)
                            }
                        }
                        else if let _ = dic["multiOptions"] as? NSDictionary
                        {
                            var options = [AnyObject]()
                            if let option = dic["multiOptions"] as? NSDictionary
                            {
                                let array2 = option.allKeys.sorted(by: { (key1, key2) -> Bool in
                                    (key1 as! String) < (key2 as! String)
                                })
                                if let dicName = dic["name"] as? String {
                                    if dicName == "repeat_week" || dicName == "repeat_interval" {
                                        for i in (0 ..< array2.count)
                                        {
                                            let j = i+1
                                            options.append(option["\(j)"]! as AnyObject)
                                        }
                                        
                                        if (Formbackup.value(forKey: dic["name"] as! String) as AnyObject? != nil)
                                        {
                                            element["default"] = Formbackup.value(forKey: dic["name"] as! String) as AnyObject?
                                        }
                                    }
                                    else {
                                        for index in array2
                                        {
                                            options.append(option["\(index)"]! as AnyObject)
                                        }
                                    }
                                }
                               
                                
                                
                                if let dicName = dic["name"] as? String, dicName == "auth_view"
                                {
                                    if let value = dic["value"] as? String
                                    {
                                        element["default"] = option.value(forKey: value) as AnyObject?
                                    }
                                    else
                                    {
                                        element["default"] = options[0]
                                    }
                                    
                                }
                                else if let dicName = dic["name"] as? String, dicName == "auth_comment"
                                {
                                    if let value = dic["value"] as? String
                                    {
                                        element["default"] = option.value(forKey: value) as AnyObject?
                                    }
                                    else
                                    {
                                        element["default"] = options[0]
                                    }
                                }
                                else if let dicName = dic["name"] as? String, dicName == "auth_post"
                                {
                                    if let value = dic["value"] as? String
                                    {
                                        element["default"] = option.value(forKey: value) as AnyObject?
                                    }
                                    else
                                    {
                                        element["default"] = options[0]
                                    }
                                    
                                }
                                else if let dicName = dic["name"] as? String, dicName == "auth_topic"
                                {
                                    if let value = dic["value"] as? String
                                    {
                                        element["default"] = option.value(forKey: value) as AnyObject?
                                    }
                                    else
                                    {
                                        element["default"] = options[0]
                                    }
                                    
                                }
                                else if let dicName = dic["name"] as? String, dicName == "auth_photo"
                                {
                                    if let value = dic["value"] as? String
                                    {
                                        element["default"] = option.value(forKey: value) as AnyObject?
                                    }
                                    else
                                    {
                                        element["default"] = options[0]
                                    }
                                    
                                }
                                else if let dicName = dic["name"] as? String, dicName == "auth_video"
                                {
                                    
                                    if let value = dic["value"] as? String
                                    {
                                        element["default"] = option.value(forKey: value) as AnyObject?
                                    }
                                    else
                                    {
                                        element["default"] = options[0]
                                    }
                                    
                                }
                                else if let dicName = dic["name"] as? String, dicName == "draft"
                                {
                                    
                                    if let value = dic["value"] as? String
                                    {
                                        element["default"] = option.value(forKey: value) as AnyObject?
                                    }
                                    else
                                    {
                                        element["default"] = options[0]
                                    }
                                    
                                }
                                else if let dicName = dic["name"] as? String, dicName == "repeat_week"
                                {
                                    
                                    if let value = dic["value"] as? String
                                    {
                                        element["default"] = option.value(forKey: value) as AnyObject?
                                    }
                                    else
                                    {
                                        element["default"] = options[0]
                                    }
                                    
                                }
                                else if let dicName = dic["name"] as? String, dicName == "repeat_weekday"
                                {
                                    
                                    if let value = dic["value"] as? String
                                    {
                                        element["default"] = option.value(forKey: value) as AnyObject?
                                    }
                                    else
                                    {
                                        element["default"] = options[0]
                                    }
                                    
                                }
                                else if let dicName = dic["name"] as? String, dicName == "repeat_day"
                                {
                                    
                                    if let value = dic["value"] as? String
                                    {
                                        element["default"] = option.value(forKey: value) as AnyObject?
                                    }
                                    else
                                    {
                                        element["default"] = options[0]
                                    }
                                    
                                }
                                else if let dicName = dic["name"] as? String, dicName == "repeat_month"
                                {
                                    
                                    if let value = dic["value"] as? String
                                    {
                                        element["default"] = option.value(forKey: value) as AnyObject?
                                    }
                                    else
                                    {
                                        element["default"] = options[0]
                                    }
                                    
                                }
                                    
                                else if let dicName = dic["name"] as? String, dicName == "eventrepeat_id"
                                {
                                    if defaultrepeatid != nil && defaultrepeatid != ""
                                    {
                                        element["default"] = defaultrepeatid as AnyObject?
                                    }
                                    else
                                    {
                                        
                                        if let value = dic["value"] as? String
                                        {
                                            element["default"] = option.value(forKey: value) as AnyObject?
                                        }
                                        else
                                        {
                                            element["default"] = options[0]
                                        }
                                    }
                                    
                                    
                                }
                                else if let dicName = dic["name"] as? String, dicName == "host_type_select"
                                {
                                    
                                    if defaultHostType != ""
                                    {
                                        element["default"] = defaultHostType as AnyObject?
                                    }
                                    else
                                    {
                                        if let value = dic["value"] as? String
                                        {
                                            element["default"] = option.value(forKey: value) as AnyObject?
                                        }
                                        else
                                        {
                                            element["default"] = options[1]
                                        }
                                    }

                                    
                                }
                                else
                                {
                                    if let dicName = dic["name"] as? String, dicName == "category_id"
                                    {
                                        if defaultCategory != nil
                                        {
                                            element["default"] = defaultCategory as AnyObject?
                                        }
                                        else
                                        {
                                            element["default"] = option.value(forKey: "0") as AnyObject?
                                        }
                                        
                                    }
                                    if let dicName = dic["name"] as? String, dicName == "subcategory_id"
                                    {
                                        if defaultsubCategory != nil
                                        {
                                            element["default"] = defaultsubCategory as AnyObject?
                                        }
                                        else
                                        {
                                            element["default"] = option.value(forKey: "0") as AnyObject?
                                        }
                                        
                                    }
                                    
                                }
                                
                                if globalCatg != ""
                                {
                                    if let dicLabel = dic["label"] as? String, dicLabel == "Category"
                                    {
                                        element["default"] = "\(globalCatg)" as AnyObject?
                                    }
                                }
                                
                                if globalTypeSearch != ""
                                {
                                    element["default"] = "\(globalTypeSearch)" as AnyObject?
                                }
                                
                                
                                if !isCreateOrEdit
                                {
                                    let key = dic["name"] as? String
                                    if let dicName = dic["name"] as? String, dicName == "eventrepeat_id"
                                    {
                                        if !(defaultrepeatid != nil && defaultrepeatid != "")
                                        {
                                            let index: AnyObject? = formValue[key!] as AnyObject?
                                            var str = ""
                                            if index != nil
                                            {
                                                if let option = option["\(index!)"] as? String
                                                {
                                                    str = option
                                                }
                                                
                                                element["default"] = str as AnyObject?
                                                
                                            }
                                        }
                                    }
                                    else
                                    {
                                        
                                        if let dicName = dic["name"] as? String, dicName == "subcategory_id"
                                        {
                                            if defaultsubCategory != nil  && defaultsubCategory != ""
                                            {
                                                element["default"] = defaultsubCategory as AnyObject?
                                            }
                                            else
                                            {
                                                let index: AnyObject? = formValue[key!] as AnyObject?
                                                var str = ""
                                                if index != nil
                                                {
                                                    if let option = option["\(index!)"] as? String
                                                    {
                                                        str = option
                                                    }
                                                    
                                                    element["default"] = str as AnyObject?
                                                    
                                                }
                                                
                                            }
                                            
                                        }
                                        else
                                        {
                                            let key = dic["name"] as? String
                                            if (Formbackup.value(forKey: key!) as AnyObject? != nil)
                                            {
                                                element["default"] = Formbackup.value(forKey: key!) as AnyObject?
                                            }
                                            else
                                            {
                                                let index: AnyObject? = formValue[key!] as AnyObject?
                                                var str = ""
                                                if index != nil
                                                {
                                                    if let option = option["\(index!)"] as? String
                                                    {
                                                        str = option
                                                    }
                                                    
                                                    element["default"] = str as AnyObject?
                                                    
                                                }
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                }
                                
                            }
                            element["options"] = options as AnyObject?
                            formElements.append(element as AnyObject)
                            
                        }
                    }
                    else if let dicType = dic["type"] as? String, dicType == "Textarea"
                    {
                        if let dicType = dic["type"] as? String, dicType == "Textarea" , let dicName = dic["name"] as? String, dicName  == "overview"{
                            
                            let defaults = UserDefaults.standard
                            defaults.set("Coding overview", forKey: "overviewcheck")
                            
                        }
                        else
                        {
                            
                            element["type"] = "longtext" as AnyObject?
                            
                            if dic["name"] as? String ==  "description"
                            {
                                element["key"] = "change_description" as AnyObject?
                            }
                            else
                            {
                                element["key"] = dic["name"] as? String as AnyObject?
                                
                            }
                            
                            element["title"] = dic["label"] as? String as AnyObject?
                            
                            element["default"] = "" as AnyObject?
                            
                            if isCreateOrEdit
                            {
                                
                                let key = dic["name"] as? String
                                if (key != nil)
                                {
                                    element["default"] = Formbackup.value(forKey: key!) as AnyObject?
                                }
                                else
                                {
                                    element["default"] = "" as AnyObject?
                                    
                                }
                                
                            }
                            else
                            {
                                let key = dic["name"] as? String
                                if formValue[key!] != nil
                                {
                                    element["default"] = formValue[key!] as AnyObject?
                                }
                            }
                            
                            formElements.append(element as AnyObject)
                            
                        }
                        
                    }
                    else if dic["type"] as! String == "Submit"
                    {
                        element["header"] = "" as AnyObject?
                        element["title"] = dic["label"] as? String as AnyObject?
                        let name = dic["name"] as! String
                        switch name {
                        case "change_host" :
                            element["action"] = "changeHostAction:" as AnyObject?
                            break
                        case "add" :
                            element["action"] = "addHostAction:" as AnyObject?
                            break
                        case "cancel" :
                            element["action"] = "cancelHostAction:" as AnyObject?
                            break
                        case "cancel_host" :
                            element["action"] = "cancelHostCreationAction:" as AnyObject?
                        case "add_host" :
                            element["action"] = "addHostCreationAction:" as AnyObject?
                            break
                            
                        default:
                            let defaults = UserDefaults.standard
                            if let name = defaults.value(forKey: "overviewcheck")
                            {
                                if  name as! String != ""
                                {
                                    element["title"] = NSLocalizedString("Continue",comment: "") as AnyObject?
                                }
                            }
                            element["action"] = "submitForm:" as AnyObject?
                            break
                        }
                        formElements.append(element as AnyObject)
                    }
                    
                }
                
            }
            else if (conditionalForm != nil && conditionalForm  == "advancedeventsview")
            {
                
                if dic["type"] as! String == "MultiCheckbox"  || dic["type"] as! String == "Multiselect"  {
                    let multiOptionsDic = dic["multiOptions"] as? NSDictionary
                    var options = [AnyObject]()
                    if let option = dic["multiOptions"] as? NSDictionary
                    {
                        let array2 = option.allKeys
                        
                        for index in array2
                        {
                            
                            options.append(option["\(index)"]! as AnyObject)
                            
                            element["key"] = (option["\(index)"]! as AnyObject?)
                            element["title"] = multiOptionsDic?.value(forKey: index as! String) as AnyObject?
                            element["type"] = "option" as AnyObject?
                            let key = dic["name"] as? String
                            let value = formValue[key!] as? NSArray
                            if  value != nil
                            {
                                let arr = formValue[key!] as! NSArray
                                if arr.contains(index)
                                {
                                    element["default"] = true as AnyObject?
                                }
                                else
                                {
                                    element["default"] = nil
                                }
                            }
                            
                            formElements.append(element as AnyObject)
                        }
                    }
                }
                else if dic["type"] as! String == "Submit"
                {
                    element["header"] = "" as AnyObject?
                    element["title"] = dic["label"] as? String as AnyObject?
                    element["action"] = "submitForm:" as AnyObject?
                    formElements.append(element as AnyObject)
                }
                else if dic["type"] as! String == "Checkbox"
                {
                    element["type"] = "option" as AnyObject?
                    element["key"] = dic["name"] as? String as AnyObject?
                    element["title"] = dic["label"] as? String as AnyObject?
                    let key = dic["name"] as? String
                    let value = formValue[key!] as? Int
                    if value == 1
                    {
                        element["default"] = value as AnyObject?
                    }
                    else
                    {
                        element["default"] = false as AnyObject?
                    }
                    formElements.append(element as AnyObject)
                }
                
            }
            else if (conditionalForm != nil && conditionalForm  == "members")
            {
                //MARK: Work for AdvancedMembers search form
                if dic["type"] as! String != "" || dic["Type"] as! String != ""
                {
                    if dic["type"] as! String == "Text"
                    {
                        element["key"] = dic["name"] as? String as AnyObject?
                        
                        if dic["name"] as? String == "url"
                        {
                            element["type"] = "url" as AnyObject?
                        }
                        
                        element["title"] = dic["label"] as? String as AnyObject?
                        element["default"] = "" as AnyObject?
                        
                        if globFilterValue != ""
                        {
                            element["default"] = globFilterValue as AnyObject?
                        }
                        
                        if isCreateOrEdit
                        {
                            
                            let key = dic["name"] as? String
                            if (key != nil)
                            {
                                element["default"] = Formbackup.value(forKey: key!) as AnyObject?
                            }
                            else
                            {
                                element["default"] = "" as AnyObject?
                            }
                            
                        }else{
                            
                            let key = dic["name"] as? String
                            if (Formbackup.value(forKey: key!) as AnyObject? != nil)
                            {
                                element["default"] = Formbackup.value(forKey: key!) as AnyObject?
                            }
                            else
                            {
                                let key = dic["name"] as? String
                                element["default"] = formValue[key!] as AnyObject?
                                
                            }
                        }
                        
                        if let description = dic["description"] as? String
                        {
                            
                            if dic["name"] as? String != "location"
                            {
                                element["footer"] = description as AnyObject?
                            }
                            
                        }
                        
                        formElements.append(element as AnyObject)
                        
                        
                    }
                    else if dic["type"] as! String == "Hidden"
                    {
                        
                        element["key"] = dic["name"] as? String as AnyObject?
                        element["title"] = dic["label"] as? String as AnyObject?
                        
                        if let value = dic["value"] as? Int
                        {
                            element["default"] = value as AnyObject?
                        }
                        else
                        {
                            element["default"] = "0" as AnyObject?
                        }
                        
                        if !isCreateOrEdit
                        {
                            let key = dic["name"] as? String
                            element["default"] = formValue[key!] as AnyObject?
                        }
                        
                        if dic["name"] as! String == "advanced_search"
                        {
                            element["type"] = "option" as AnyObject?
                            if let value = dic["value"] as? Int
                            {
                                element["default"] = value as AnyObject?
                            }
                            else if let value = dic["value"] as? String
                            {
                                let intvalue = Int(value)
                                element["default"] = intvalue as AnyObject?
                            }
                            else
                            {
                                element["default"] = false as AnyObject?
                            }
                            element["action"] = "fieldValueChanged:" as AnyObject?
                            
                            formElements.append(element as AnyObject)
                            
                        }
                        
                    }
                    else if dic["type"] as! String == "Float"
                    {
                        element["key"] = dic["name"] as? String as AnyObject?
                        element["header"] = "" as AnyObject?
                        element["title"] = dic["label"] as? String as AnyObject?
                        element["type"] = "float" as AnyObject?
                        formElements.append(element as AnyObject)
                    }
                    else if dic["type"] as! String == "MultiCheckbox"  || dic["type"] as! String == "Multi_checkbox"
                    {
                        
                        let multiOptionsDic = dic["multiOptions"] as? NSDictionary
                        var options = [AnyObject]()
                        if let option = dic["multiOptions"] as? NSDictionary
                        {
                            let array2 = option.allKeys.sorted(by: { (key1, key2) -> Bool in
                                (key1 as! String) < (key2 as! String)
                            })
                            var i = 0
                            var istitleShow = true
                            
                            for index in array2
                            {
                                i = i+1
                                options.append(option["\(index)"]! as AnyObject)
                                
                                
                                element["key"] = (option["\(index)"]! as AnyObject?)
                                element["title"] = multiOptionsDic?.value(forKey: index as! String) as AnyObject?
                                element["type"] = "option" as AnyObject?
                                if istitleShow == true
                                {
                                    element["header"] = dic["label"]  as AnyObject?
                                    istitleShow = false
                                }
                                else{
                                    element.removeValue(forKey: "header")
                                }
                                
                                if !isCreateOrEdit
                                {
                                    let key = dic["name"] as? String
                                    let value = formValue[key!] as? NSArray
                                    if  value != nil
                                    {
                                        let arr = formValue[key!] as! NSArray
                                        if arr.contains(i)
                                        {
                                            element["default"] = true as AnyObject?
                                        }
                                        else
                                        {
                                            element["default"] = nil
                                        }
                                    }
                                }
                                formElements.append(element as AnyObject)
                            }
                        }
                    }
                    else if dic["type"] as! String == "Submit"
                    {
                        element["header"] = "" as AnyObject?
                        element["title"] = dic["label"] as? String as AnyObject?
                        element["action"] = "submitForm:" as AnyObject?
                        formElements.append(element as AnyObject)
                    }
                    else if dic["type"] as! String == "Checkbox"
                    {
                        element["type"] = "option" as AnyObject?
                        element["key"] = dic["name"] as? String as AnyObject?
                        element["title"] = dic["label"] as? String as AnyObject?
                        if let value = dic["value"] as? Int
                        {
                            element["default"] = value as AnyObject?
                        }
                        else if let value = dic["value"] as? String
                        {
                            let intvalue = Int(value)
                            element["default"] = intvalue as AnyObject?
                        }
                        else
                        {
                            element["default"] = false as AnyObject?
                        }
                        
                        if !isCreateOrEdit
                        {
                            let key = dic["name"] as? String
                            if (Formbackup.value(forKey: key!) as AnyObject? != nil)
                            {
                                element["default"] = Formbackup.value(forKey: key!) as AnyObject?
                            }
                            else
                            {
                                let key = dic["name"] as? String
                                if let value =  formValue[key!] as? String
                                {
                                    let intvalue = Int(value)
                                    element["default"] = intvalue as AnyObject?
                                }
                                else
                                {
                                    element["default"] = formValue[key!] as AnyObject?
                                }
                            }
                        } else {
                            
                            let key = dic["name"] as? String
                            if (key != nil)
                            {
                                if let _ = Formbackup.value(forKey: key!) as AnyObject?
                                {
                                    element["default"] = Formbackup.value(forKey: key!) as AnyObject?
                                }
                            }
                            else
                            {
                                element["default"] = "" as AnyObject?
                            }
                        }
                        formElements.append(element as AnyObject)
                    }
                    else if dic["type"] as! String == "Date"
                    {
                        
                        element["type"] = "datetime" as AnyObject?
                        element["title"] = dic["label"] as? String as AnyObject?
                        element["key"] = dic["name"] as? String as AnyObject?
                        
                        if dic["format"] != nil && dic["name"] as? String == "date"
                        {
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd"
                            let dateString = "1991-01-01"
                            element["type"] = "date" as AnyObject?
                            element["default"] = dateFormatter.date(from: dateString) as AnyObject?
                        }
                        
                        
                        if !isCreateOrEdit
                        {
                            let key = dic["name"] as? String
                            if (formValue[key!] != nil)
                            {
                                if formValue.value(forKey: key!) is NSString{
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                    element["default"] = dateFormatter.date(from: formValue[key!] as! NSString as String) as AnyObject?
                                }
                            }
                            
                        }else{
                            
                            let key = dic["name"] as? String
                            if (key != nil)
                            {
                                element["default"] = Formbackup.value(forKey: key!) as AnyObject?
                            }
                            else
                            {
                                element["default"] = "" as AnyObject?
                            }
                            
                        }
                        formElements.append(element as AnyObject)
                        
                        
                    }
                    else if (dic["type"] as! String == "Select") || (dic["type"] as! String == "Radio")
                    {
                        element["cell"] = "FXFormOptionPickerCell" as AnyObject?
                        element["key"] = dic["name"] as? String as AnyObject?
                        element["title"] = dic["label"] as? String as AnyObject?
                        if let description = dic["description"] as? String
                        {
                            element["footer"] = description as AnyObject?
                        }
                        
                        if dic["type"] as! String == "Select" && dic["name"] as! String == "profile_type"
                        {
                            
                            element["action"] = "memberProfileTypeValueChanged:" as AnyObject?
                            
                        }
                        
                        if isCreateOrEdit
                        {
                            
                            let key = dic["name"] as? String
                            if (key != nil)
                            {
                                element["default"] = Formbackup.value(forKey: key!) as AnyObject?
                            }
                            else
                            {
                                element["default"] = "" as AnyObject?
                            }
                            
                        }
                        
                        
                        if let option = dic["multiOptions"] as? NSArray
                        {
                            
                            if option.count > 0
                            {
                                element["default"] = option[0] as AnyObject?
                                if let value = dic["value"] as? String
                                {
                                    let id = Int(value)
                                    element["default"] = option[id!] as AnyObject?
                                }else if dic["name"] as? String == "network_id"{
                                    if Formbackup["network_id"] != nil{
                                        if let id = Formbackup["network_id"] as? Int{
                                            element["default"] = option[id] as AnyObject?
                                        }else if let id = Formbackup["network_id"] as? String{
                                            let tempId = Int(id)
                                            element["default"] = option[tempId!] as AnyObject?
                                        }
                                    }
                                }
                                
                                element["options"] = option
                                formElements.append(element as AnyObject)
                                
                            }
                        }
                        else if let _ = dic["multiOptions"] as? NSDictionary
                        {
                            var options = [AnyObject]()
                            if let option = dic["multiOptions"] as? NSDictionary
                            {
                                let array2 = option.allKeys.sorted(by: { (key1, key2) -> Bool in
                                    (key1 as! String) < (key2 as! String)
                                })
                                
                                for index in array2
                                {
                                    options.append(option["\(index)"]! as AnyObject)
                                }
                                
                            }
                            
                            element["options"] = options as AnyObject?
                            formElements.append(element as AnyObject)
                            
                        }
                    }
                    else if dic["type"] as! String == "Textarea"
                    {
                        element["type"] = "longtext" as AnyObject?
                        if dic["name"] as? String ==  "description"
                        {
                            element["key"] = "change_description" as AnyObject?
                        }
                        else
                        {
                            element["key"] = dic["name"] as? String as AnyObject?
                        }
                        element["title"] = dic["label"] as? String as AnyObject?
                        element["default"] = "" as AnyObject?
                        
                        if !isCreateOrEdit{
                            let key = dic["name"] as? String
                            element["default"] = formValue[key!] as AnyObject?
                        }else{
                            let key = dic["name"] as? String
                            if (key != nil)
                            {
                                element["default"] = Formbackup.value(forKey: key!) as AnyObject?
                            }
                            else
                            {
                                element["default"] = "" as AnyObject?
                            }
                        }
                        formElements.append(element as AnyObject)
                    }
                }
            }
            else if (conditionalForm != nil && conditionalForm  == "coreSearch")
            {
                //MARK: For Core Search element creation
                if dic["type"] as! String != ""
                {
                    if dic["type"] as! String == "Text"{
                        
                        element["key"] = dic["name"] as? String as AnyObject?
                        element["title"] = dic["label"] as? String as AnyObject?
                        
                        
                        
                        if dic["name"] as! String == "search"
                        {
                            if globFilterValue != ""
                            {
                                element["default"] = globFilterValue as AnyObject?
                            }
                            
                        }
                        
                        if !isCreateOrEdit{
                            let key = dic["name"] as? String
                            element["default"] = formValue[key!] as AnyObject?
                        }
                        
                        if let description = dic["description"] as? String{
                            if description != ""{
                                element["footer"] = description as AnyObject?
                            }
                        }
                        if isCreateOrEdit
                        {
                            let key = dic["name"] as? String
                            if (key != nil)
                            {
                                element["default"] = Formbackup.value(forKey: key!) as AnyObject?
                            }
                        }
                        if isCreateOrEdit
                        {
                            
                            if dic["name"]as? String == "location"
                            {
                                if location == "ab"
                                {
                                    let defaults = UserDefaults.standard
                                    if let loc = defaults.string(forKey: "Location")
                                    {
                                        element["default"] = loc as AnyObject?
                                        
                                    }
                                    else
                                    {
                                        if defaultlocation != ""
                                        {
                                            element["default"] = defaultlocation as AnyObject?
                                        }
                                    }
                                }
                                else
                                {
                                    element["default"] = "\(location)" as AnyObject?
                                }
                                
                                
                            }
                        }
                        
                        if venue_name != ""
                        {
                            if dic["name"] as! String == "venue_name" {
                                element["default"] = "\(venue_name)" as AnyObject?
                            }
                        }
                        if Siteevent_street != ""
                        {
                            if dic["name"] as! String == "Siteevent_street" {
                                element["default"] = "\(Siteevent_street)" as AnyObject?
                            }
                        }
                        
                        if siteevent_city != ""
                        {
                            if dic["name"] as! String == "siteevent_city" {
                                element["default"] = "\(siteevent_city)" as AnyObject?
                            }
                        }
                        if siteevent_state != ""
                        {
                            if dic["name"] as! String == "siteevent_state" {
                                element["default"] = "\(siteevent_state)" as AnyObject?
                            }
                        }
                        if siteevent_country != ""
                        {
                            if dic["name"] as! String == "siteevent_country" {
                                element["default"] = "\(siteevent_country)" as AnyObject?
                            }
                        }
                        if member != ""
                        {
                            if dic["name"] as! String == "member"
                            {
                                element["default"] = "\(member)" as AnyObject?
                            }
                        }
                        formElements.append(element as AnyObject)
                        
                    }
                    else if dic["type"] as! String == "Submit"{
                        element["header"] = "" as AnyObject?
                        element["title"] = dic["label"] as? String as AnyObject?
                        element["action"] = "submitForm:" as AnyObject?
                        formElements.append(element as AnyObject)
                    }
                    else if dic["type"] as! String == "Checkbox"{
                        element["type"] = "option" as AnyObject?
                        element["key"] = dic["name"] as? String as AnyObject?
                        element["title"] = dic["label"] as? String as AnyObject?
                        
                        if let value = dic["value"] as? Int{
                            element["default"] = value as AnyObject?
                        }else{
                            element["default"] = "0" as AnyObject?
                        }
                        
                        if !isCreateOrEdit{
                            let key = dic["name"] as? String
                            element["default"] = formValue[key!] as AnyObject?
                        }
                        
                        formElements.append(element as AnyObject)
                    }
                    else if (dic["type"] as! String == "Select") || (dic["type"] as! String == "Radio"){
                        //MARK: Selectbox in coreSearch
                        
                        element["cell"] = "FXFormOptionPickerCell" as AnyObject?
                        element["key"] = dic["name"] as? String as AnyObject?
                        element["title"] = dic["label"] as? String as AnyObject?
                        
                        
                        if let description = dic["description"] as? String{
                            
                            element["footer"] = description as AnyObject?
                            
                        }
                        
                        if let option = dic["multiOptions"] as? NSArray{
                            if option.count > 0 {
                                element["default"] = option[0] as AnyObject?
                                if globalCatg != ""
                                {
                                    if dic["label"] as! String == "Category" {
                                        
                                        element["default"] = "\(globalCatg)" as AnyObject?
                                        
                                    }
                                }
                                
                                element["options"] = option
                                formElements.append(element as AnyObject)
                            }
                            
                        }
                        else if let _ = dic["multiOptions"] as? NSDictionary{
                            var options = [AnyObject]()
                            
                            if globalTypeSearch != ""
                            {
                                element["default"] = "\(globalTypeSearch)" as AnyObject?
                            }
                            
                            if let option = dic["multiOptions"] as? NSDictionary
                            {
                                let array2 = option.allKeys.sorted(by: { (key1, key2) -> Bool in
                                    (key1 as! String) < (key2 as! String)
                                })
                                //let array2 = option.allKeys.sorted(by: order as! (Any, Any) -> Bool)
                                for index in array2{
                                    options.append(option["\(index)"]! as AnyObject)
                                }
                                
                                
                                if let value = dic["value"] as? String
                                {
                                    element["default"] = option[value] as AnyObject?
                                }
                                else
                                {
                                    element["default"] = options[0]
                                }
                                
                                if !isCreateOrEdit{
                                    let key = dic["name"] as? String
                                    let index: AnyObject? = formValue[key!] as AnyObject?
                                    var str = ""
                                    if index != nil {
                                        if let option = option["\(index!)"] as? String{
                                            str = option
                                        }
                                        element["default"] = str as AnyObject?
                                    }
                                }
                            }
                            
                            
                            element["options"] = options as AnyObject?
                            formElements.append(element as AnyObject)
                        }
                        
                    }
                }
            }
            else if (conditionalForm != nil && conditionalForm  == "checkout")
            {
                if dic["type"] as! String != "" || dic["Type"] as! String != ""
                {
                    if dic["type"] as! String == "Text"
                    {
                        element["key"] = dic["name"]  as AnyObject?
                        if dic["name"] as? String == "url"
                        {
                            element["type"] = "url" as AnyObject?
                        }
                        
                        element["title"] = dic["label"] as AnyObject?
                        element["default"] = "" as AnyObject?
                        let key = dic["name"] as? String
                        if (Formbackup[key!] != nil)
                        {
                            element["default"] = Formbackup[key!] as AnyObject?
                        }
                        else
                        {
                            let key = dic["name"] as? String
                            if let _ = formValue[key!]
                            {
                                element["default"] = formValue[key!] as AnyObject?
                            }
                            else
                            {
                                element["default"] = "" as AnyObject?
                            }
                            
                        }
                        
                        if iscomingFromAdvEvents
                        {
                            let key = dic["name"] as? String
                            element["default"] = formValue[key!] as AnyObject?
                            
                        }
                        
                        if (key?.contains("fname_"))!
                        {
                            let description = dic["description"] as? String
                            element["header"] = NSLocalizedString("\(description!)", comment: "") as AnyObject?
                        }
                        
                        if key == "f_name_billing"
                        {
                            element["header"] = NSLocalizedString("Billing Address", comment: "") as AnyObject?
                        }
                        else if key == "f_name_shipping"
                        {
                            element["header"] = NSLocalizedString("Shipping Address", comment: "") as AnyObject?
                        }
                        formElements.append(element as AnyObject)
                    }
                   
                    else if (dic["type"] as! String == "Submit") || dic["type"] as! String == "Button" || dic["type"] as! String == "submit"
                    {
                        
                        if let des = dic["description"] as? String
                        {
                            element["header"] = des as AnyObject?
                        }
                        else
                        {
                            element["header"] = "" as AnyObject?
                        }
                        element["title"] = dic["label"]  as AnyObject?
                        element["action"] = "submitForm:" as AnyObject?
                        formElements.append(element as AnyObject)
                    }
                    else if dic["type"] as! String == "Checkbox"
                    {
                        element["type"] = "option" as AnyObject?
                        element["key"] = dic["name"]  as AnyObject?
                        element["title"] = dic["label"] as? String as AnyObject?
                        if let value = dic["value"] as? Int
                        {
                            element["default"] = value as AnyObject?
                        }
                        else if let value = dic["value"] as? String
                        {
                            let intvalue = Int(value)
                            element["default"] = intvalue as AnyObject?
                        }
                        else
                        {
                            element["default"] = false as AnyObject?
                        }
                        if !isCreateOrEdit
                        {
                            let key = dic["name"] as? String
                            if (Formbackup[key!] != nil)
                            {
                                element["default"] = Formbackup[key!] as AnyObject?
                            }
                            else
                            {
                                let key = dic["name"] as? String
                                if let value =  formValue[key!] as? String
                                {
                                    let intvalue = Int(value)
                                    element["default"] = intvalue as AnyObject?
                                }
                                else
                                {
                                    element["default"] = formValue[key!] as AnyObject?
                                }
                                
                                
                            }
                            
                        }
                        if dic["name"] as! String == "is_online"
                        {
                            element["action"] = "fieldValueChanged:" as AnyObject?
                            
                        }
                        if dic["name"] as! String == "monthlyType"
                        {
                            element["action"] = "fieldValueChanged1:" as AnyObject?
                            
                        }
                        if dic["name"] as! String == "common"
                        {
                            element["action"] = "shippingValueChanged:" as AnyObject?
                        }
                        
                        if dic["name"] as! String == "isCopiedDetails"
                        {
                            element["action"] = "shippingValueChanged:" as AnyObject?
                        }
                        
                        if isCreateOrEdit
                        {
                            
                            let key = dic["name"] as? String
                            if (key != nil)
                            {
                                
                                if let _ = Formbackup[key!]
                                {
                                    element["default"] = Formbackup[key!] as AnyObject?
                                    if Formbackup["common"] as? Bool == false
                                    {
                                        element["default"] = 0 as AnyObject?
                                    }
                                    else
                                    {
                                        element["default"] = 1 as AnyObject?
                                    }
                                    
                                    if Formbackup["isCopiedDetails"] as? Bool == false
                                    {
                                        element["default"] = 0 as AnyObject?
                                    }
                                    else
                                    {
                                        element["default"] = 1 as AnyObject?
                                    }
                                    
                                }
                                else if (formValue[key!] != nil)
                                {
                                    if let value = formValue[key!] as? String
                                    {
                                        let value1:Int? = Int(value)
                                        element["default"] = value1 as AnyObject?
                                    }
                                    
                                }
                                
                            }
                            else
                            {
                                element["default"] = "" as AnyObject?
                            }
                            
                        }
                        formElements.append(element as AnyObject)
                    }
                    else if (dic["type"] as! String == "Select") || (dic["type"] as! String == "Radio")
                    {
                        element["cell"] = "FXFormOptionPickerCell" as AnyObject?
                        element["key"] = dic["name"]  as AnyObject?
                        element["title"] = dic["label"]  as AnyObject?
                        if let description = dic["description"] as? String
                        {
                            element["footer"] = description as AnyObject?
                        }
                        
                        if dic["type"] as! String == "Select" && dic["name"] as! String == "country_billing"
                        {
                            element["action"] = "CountryBillingValueChanged:" as AnyObject?
                            
                        }
                        else if dic["type"] as! String == "Select" && dic["name"] as! String == "country_shipping"
                        {
                            element["action"] = "CountryShipingValueChanged:" as AnyObject?
                        }
                        
                        
                        if let option = dic["multiOptions"] as? NSArray
                        {
                            
                            if option.count > 0
                            {
                                
                                if let value = dic["value"] as? String
                                {
                                    let id = Int(value)
                                    element["default"] = option[id!] as AnyObject?
                                }
                                else
                                {
                                    element["default"] = option[0] as AnyObject?
                                }
                                
                                let key = dic["name"] as? String
                                if (Formbackup[key!] != nil)
                                {
                                    element["default"] = Formbackup[key!] as AnyObject?
                                }
                                else if (formValue[key!] != nil)
                                {
                                    
                                    if let str1 = formValue[key!] as? String
                                    {
                                        if str1 != ""
                                        {
                                            var str = ""
                                            let index:Int? = Int(str1)
                                            
                                            if let optionstr = option[index!] as? String
                                            {
                                                str = optionstr
                                            }
                                            
                                            element["default"] = str as AnyObject?
                                            
                                        }
                                        
                                        
                                    }
                                    else if let intvalue = formValue[key!] as? Int
                                    {
                                        var str = ""
                                        if let optionstr = option[intvalue] as? String
                                        {
                                            str = optionstr
                                        }
                                        
                                        element["default"] = str as AnyObject?
                                    }
                                    
                                }
                                
                            }
                            
                            element["options"] = option
                            formElements.append(element as AnyObject)
                        }
                        else if let _ = dic["multiOptions"] as? NSDictionary
                        {
                            var options = [AnyObject]()
                            if let option = dic["multiOptions"] as? NSDictionary
                            {
                                let array2 = option.allKeys.sorted(by: { (key1, key2) -> Bool in
                                    (key1 as! String) < (key2 as! String)
                                })
                                for index in array2
                                {
                                    options.append(option["\(index)"]! as AnyObject)
                                }
                                
                                if options.count > 0
                                {
                                    if let value = dic["value"] as? String
                                    {
                                        element["default"] = option[value] as AnyObject?
                                    }
                                    else
                                    {
                                        element["default"] = options[0] as AnyObject?
                                    }
                                }
                                
                                
                                let key = dic["name"] as? String
                                if dic["name"] as! String == "country_billing"
                                {
                                    
                                    if (Formbackup[key!] != nil)
                                    {
                                        element["default"] = Formbackup[key!] as AnyObject?
                                    }
                                    else
                                    {
                                        let index: AnyObject? = formValue[key!] as AnyObject?
                                        var str = ""
                                        if index != nil
                                        {
                                            if let option = option["\(index!)"] as? String
                                            {
                                                str = option
                                            }
                                            
                                            element["default"] = str as AnyObject?
                                            
                                        }
                                    }
                                }
                                else
                                {
                                    if (Formbackup[key!] != nil)
                                    {
                                        element["default"] = Formbackup[key!] as AnyObject?
                                    }
                                    else
                                    {
                                        let index: AnyObject? = formValue[key!] as AnyObject?
                                        var str = ""
                                        if index != nil
                                        {
                                            if let option = option["\(index!)"] as? String
                                            {
                                                str = option
                                            }
                                            
                                            element["default"] = str as AnyObject?
                                            
                                        }
                                    }
                                    
                                }
                                
                            }
                            
                            element["options"] = options as AnyObject?
                            formElements.append((element as AnyObject?)!)
                            
                            
                        }
                    }
                    else if dic["type"] as! String == "Textarea"
                    {
                        element["type"] = "longtext" as AnyObject?
                        if dic["name"] as? String ==  "description"
                        {
                            element["key"] = "change_description" as AnyObject?
                        }
                        else
                        {
                            element["key"] = dic["name"] as? String as AnyObject?
                        }
                        element["title"] = dic["label"] as AnyObject?
                        let key = dic["name"] as? String
                        if (Formbackup[key!] != nil)
                        {
                            element["default"] = Formbackup[key!] as AnyObject?
                        }
                        else
                        {
                            let key = dic["name"] as? String
                            if let _ = formValue[key!]
                            {
                                element["default"] = formValue[key!] as AnyObject?
                            }
                            else
                            {
                                element["default"] = "" as AnyObject?
                            }
                            
                        }
                        formElements.append((element as AnyObject?)!)
                    }
                    else if dic["type"] as! String == "radio"
                    {
                        element["key"] = dic["name"]  as AnyObject?
                        element["title"] = dic["label"]  as AnyObject?
                        element["cell"] = "FXFormOptionPickerCell" as AnyObject?
                        var options = [AnyObject]()
                        if let option = dic["multiOptions"] as? NSDictionary
                        {
                            let array2 = option.allKeys.sorted(by: { (key1, key2) -> Bool in
                                (key1 as! String) < (key2 as! String)
                            })
                            for index in array2
                            {
                                
                                options.append((option["\(index)"]! as AnyObject))
                            }
                            if options.count > 0
                            {
                                if let value = dic["value"] as? String
                                {
                                    element["default"] = option[value] as AnyObject?
                                }
                                if let _ = dic["value"] as? Int
                                {
                                    element["default"] = options[0]
                                }
                            }
                            
                        }
                        element["options"] = options as AnyObject?
                        //For converting currency code to symbol
                        if let description = dic["shippingInformation"] as? String
                        {
                            let symbol = getCurrencySymbol(Currencycode as String)
                            let replaced = (description as NSString).replacingOccurrences(of: Currencycode as String, with: symbol)
                            element["footer"] = replaced as AnyObject?
                        }
                        if  dic["name"] as? String == "payment_gateway"
                        {
                            element["action"] = "PaymentMethodChanged:" as AnyObject?
                        }
                        let key = dic["name"] as? String
                        if (Formbackup[key!] != nil)
                        {
                            element["default"] = Formbackup[key!] as AnyObject?
                        }
                        formElements.append(element as AnyObject)
                        
                    }
                }
            }
            else if (conditionalForm != nil && conditionalForm  == "Stores")
            {
                if dic["type"] as! String != "" || dic["Type"] as! String != ""
                {
                    
                    if dic["type"] as! String == "Text" || dic["type"] as! String == "text"
                    {
                        element["key"] = dic["name"]  as AnyObject?
                        if dic["name"] as? String == "url"
                        {
                            element["type"] = "url" as AnyObject?
                        }
                        
                        element["title"] = dic["label"]  as AnyObject?
                        element["default"] = "" as AnyObject?
                        
                        let key = dic["name"] as? String
                        if (key != nil)
                        {
                            element["default"] = formValue[key!] as AnyObject?
                        }
                        
                        if globFilterValue != ""
                        {
                            if dic["name"] as! String == "search"{
                                element["default"] = globFilterValue as AnyObject?
                            }
                        }
                        
                        if let description = dic["description"] as? String
                        {
                            element["footer"] = description as AnyObject?
                        }
                        
                        formElements.append((element as AnyObject?)!)
                        
                    }
                    else if dic["type"] as! String == "Hidden"
                    {
                        
                        element["type"] = "option" as AnyObject?
                        element["key"] = dic["name"]  as AnyObject?
                        element["title"] = dic["label"]  as AnyObject?
                        if let value = dic["value"] as? Int
                        {
                            element["default"] = value as AnyObject?
                        }
                        else
                        {
                            element["default"] = "0" as AnyObject?
                        }
                        
                        if isCreateOrEdit
                        {
                            
                            let key = dic["name"] as? String
                            if (key != nil)
                            {
                                element["default"] = Formbackup[key!] as AnyObject?
                            }
                            else
                            {
                                element["default"] = "" as AnyObject?
                            }
                        }
                        else
                        {
                            let key = dic["name"] as? String
                            element["default"] = formValue[key!] as AnyObject?
                        }
                        
                        if dic["type"] as! String == "Hidden" && dic["name"] as! String == "is_online"
                        {
                            element["action"] = "fieldValueChanged:" as AnyObject?
                            
                        }
                        formElements.append((element as AnyObject?)!)
                    }
                    else if dic["type"] as! String == "Multi_checkbox"
                    {
                        
                        let multiOptionsDic = dic["multiOptions"] as? NSDictionary
                        var options = [AnyObject]()
                        if let option = dic["multiOptions"] as? NSDictionary
                        {
                            let array2 = option.allKeys.sorted(by: { (key1, key2) -> Bool in
                                (key1 as! String) < (key2 as! String)
                            })
                            var i = 0
                            
                            for index in array2
                            {
                                
                                options.append(option["\(index)"]! as AnyObject)
                                
                                element["key"] = (option["\(index)"]! as AnyObject?)
                                element["title"] = multiOptionsDic!["\(index)"] as AnyObject?
                                element["type"] = "option" as AnyObject?
                                if !isCreateOrEdit
                                {
                                    var arr = NSArray()
                                    let key = dic["name"] as? String
                                    
                                    if formValue[key!] != nil {
                                        arr = formValue[key!] as! NSArray
                                        
                                        if arr.contains(index)
                                        {
                                            element["default"] = true as AnyObject?
                                        }
                                        else
                                        {
                                            element["default"] = false as AnyObject?
                                        }
                                        i = i+1
                                        
                                    }
                                }
                                formElements.append(element as AnyObject)
                                
                            }
                        }
                        
                    }
                    else if dic["type"] as! String == "Submit" || dic["type"] as! String == "submit"
                    {
                        element["header"] = "" as AnyObject?
                        element["title"] = dic["label"]  as AnyObject?
                        element["action"] = "submitForm:" as AnyObject?
                        formElements.append(element as AnyObject)
                    }
                    else if dic["type"] as! String == "Checkbox" || dic["type"] as! String == "checkbox"
                    {
                        element["type"] = "option" as AnyObject?
                        element["key"] = dic["name"]  as AnyObject?
                        element["title"] = dic["label"]  as AnyObject?
                        if let value = dic["value"] as? Int
                        {
                            element["default"] = value as AnyObject?
                        }
                        else
                        {
                            element["default"] = false as AnyObject?
                        }
                        
                        let key = dic["name"] as? String
                        if (key != nil)
                        {
                            element["default"] = Formbackup[key!] as AnyObject?
                        }
                        
                        formElements.append(element as AnyObject)
                    }
                    else if dic["type"] as! String == "Date"
                    {
                        
                        element["type"] = "datetime" as AnyObject?
                        element["title"] = dic["label"]  as AnyObject?
                        element["key"] = dic["name"]  as AnyObject?
                        
                        if isCreateOrEdit
                        {
                            let key = dic["name"] as? String
                            if (key != nil)
                            {
                                element["default"] = Formbackup[key!] as AnyObject?
                            }
                            else
                            {
                                element["default"] = "" as AnyObject?
                            }
                        }
                        else
                        {
                            let key = dic["name"] as? String
                            
                            if formValue.value(forKey: key!) is NSString
                            {
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                element["default"] = dateFormatter.date(from: formValue[key!] as! NSString as String) as AnyObject?
                            }
                        }
                        
                        formElements.append(element as AnyObject)
                        
                    }
                    else if (dic["type"] as! String == "Select") || (dic["type"] as! String == "Radio") || (dic["type"] as! String == "select")
                    {
                        element["cell"] = "FXFormOptionPickerCell" as AnyObject?
                        element["key"] = dic["name"]  as AnyObject?
                        element["title"] = dic["label"]as AnyObject?
                        if let description = dic["description"] as? String
                        {
                            element["footer"] = description as AnyObject?
                        }
                        
                        
                        if ((dic["type"] as! String == "Select" || dic["type"] as! String == "select") && (dic["name"] as! String == "category_id" || dic["name"] as! String == "category"))
                        {
                            element["action"] = "storeCategoryValueChanged:"as AnyObject?
                            
                        }
                        else if dic["type"] as! String == "Select" &&  dic["name"] as! String == "subcategory_id"
                        {
                            element["action"] = "storeSubCategoryValueChanged:"as AnyObject?
                        }
                        else if dic["type"] as! String == "Select" &&  dic["name"] as! String == "subsubcategory_id"
                        {
                            element["action"] = "storeSubSubCategoryValueChanged:"as AnyObject?
                        }
                        
                        let key = dic["name"] as? String
                        if (key != nil)
                        {
                            element["default"] = Formbackup[key!]as AnyObject?
                        }
                        else
                        {
                            element["default"] = ""as AnyObject?
                        }
                        
                        if let option = dic["multiOptions"] as? NSArray
                        {
                            if option.count > 0
                            {
                                if let value = dic["value"] as? String
                                {
                                    let id = Int(value)
                                    element["default"] = option[id!] as AnyObject?
                                }
                                else
                                {
                                    element["default"] = option[0] as AnyObject?
                                }
                                
                                
                                if filterSearchFlag == true //filterSearchFlag == false
                                {
                                    if  !isCreateOrEdit
                                    {
                                        let key = dic["name"] as? String
                                        if (key!.range(of: "_field_") != nil)
                                        {
                                            
                                            element["default"] = formValue[key!] as AnyObject?
                                        }
                                            
                                        else
                                        {
                                            if dic["name"] as! String == "category_id" && defaultCategory != nil && defaultCategory != ""
                                            {
                                                element["default"] = defaultCategory as AnyObject?
                                            }
                                        }
                                        
                                        
                                    }
                                }
                                
                                element["options"] = option
                                formElements.append(element as AnyObject)
                            }
                        }
                        else if let _ = dic["multiOptions"] as? NSDictionary
                        {
                            var options = [AnyObject]()
                            
                            if let option = dic["multiOptions"] as? NSDictionary
                            {
                                
                                let array2 = option.allKeys.sorted(by: { (key1, key2) -> Bool in
                                    (key1 as! String) < (key2 as! String)
                                })
                                //let array2 = option.allKeys.sorted(by: order as! (Any, Any) -> Bool)
                                for index in array2{
                                    options.append(option["\(index)"]! as AnyObject)
                                }
                                
                                if dic["name"] as! String == "category_id"
                                {
                                    if defaultCategory != nil
                                    {
                                        if Formbackup["category_id"] != nil {
                                            if Formbackup["category_id"] as! String != ""{
                                                element["default"] = Formbackup["category_id"] as AnyObject?
                                                
                                            }
                                        }else{
                                            element["default"] = defaultCategory as AnyObject?
                                        }
                                    }
                                    else
                                    {
                                        element["default"] = option[0] as AnyObject?
                                    }
                                    
                                }
                                if dic["name"] as! String == "subcategory_id"
                                {
                                    if defaultsubCategory != nil
                                    {
                                        element["default"] = defaultsubCategory as AnyObject?
                                    }
                                    else
                                    {
                                        element["default"] = option[0] as AnyObject?
                                    }
                                    
                                }
                                if dic["name"] as! String == "subsubcategory_id"
                                {
                                    if defaultsubsubCategory != nil
                                    {
                                        element["default"] = defaultsubsubCategory as AnyObject?
                                    }
                                    else
                                    {
                                        element["default"] = option[0] as AnyObject?
                                    }
                                    
                                }
                                
                                if globalCatg != ""
                                {
                                    
                                    if dic["label"] as! String == "Category"
                                    {
                                        element["default"] = "\(globalCatg)" as AnyObject?
                                        
                                    }
                                    
                                }
                                
                                
                                if globalTypeSearch != ""
                                {
                                    element["default"] = "\(globalTypeSearch)" as AnyObject?
                                }
                                
                                
                                if filterSearchFlag == false
                                {
                                    if !isCreateOrEdit
                                    {
                                        let key = dic["name"] as? String
                                        if dic["name"] as! String == "subcategory_id"
                                        {
                                            if defaultsubCategory != nil && defaultsubCategory != ""
                                            {
                                                
                                            }
                                            else
                                            {
                                                
                                                let index: AnyObject? = formValue[key!] as AnyObject?
                                                var str = ""
                                                if index != nil
                                                {
                                                    if let option = option["\(index!)"] as? String
                                                    {
                                                        str = option
                                                    }
                                                    
                                                    element["default"] = str as AnyObject?
                                                    
                                                }
                                            }
                                        }
                                        else if dic["name"] as! String == "subsubcategory_id"
                                        {
                                            if !(defaultsubsubCategory != nil && defaultsubsubCategory != "")
                                            {
                                                let index: AnyObject? = formValue[key!] as AnyObject?
                                                var str = ""
                                                if index != nil
                                                {
                                                    if let option = option["\(index!)"] as? String
                                                    {
                                                        str = option
                                                    }
                                                    
                                                    element["default"] = str as AnyObject?
                                                    
                                                }
                                            }
                                        }
                                        else if (key!.range(of: "_field_") != nil)
                                        {
                                            
                                            element["default"] = formValue[key!]as AnyObject?
                                        }
                                        else
                                        {
                                            if dic["name"] as! String == "category_id" && defaultCategory != nil && defaultCategory != ""
                                            {
                                                element["default"] = defaultCategory as AnyObject?
                                            }
                                            else{
                                                
                                                let index: AnyObject? = formValue[key!]as AnyObject?
                                                var str = ""
                                                if index != nil
                                                {
                                                    if let option = option["\(index!)"] as? String
                                                    {
                                                        str = option
                                                    }
                                                    
                                                    element["default"] = str as AnyObject?
                                                    
                                                }
                                                
                                            }
                                            
                                        }
                                        
                                    }
                                }
                                
                            }
                            
                            element["options"] = options as AnyObject?
                            formElements.append(element as AnyObject)
                            
                        }
                    }
                    
                }
                
            }

            else
            {
                
                //MARK: For all other form elements
                if dic["type"] as! String != ""
                {
                    
                    if dic["type"] as! String == "Text"
                    {
                        element["key"] = dic["name"] as? String as AnyObject?
                        
                        if dic["name"] as? String == "url"{
                            element["type"] = "url" as AnyObject?
                            
                        }
                        
                        element["title"] = dic["label"] as? String as AnyObject?
                        
                        if textstoreValue != ""
                        {
                            element["default"] = textstoreValue as AnyObject?
                        }
                        else
                        {
                            element["default"] = "" as AnyObject?
                        }
                        
                        if dic["name"] as! String == "search"
                        {
                            if globFilterValue != ""
                            {
                                element["default"] = globFilterValue as AnyObject
                            }
                            
                        }
                        if signUplayoutType == false {
                            
                            if dic["name"] as? String == "email" || dic["name"] as? String == "emailaddress"{
                                element["type"] = "email" as AnyObject?
                               
                                
                                if appleEmail != nil && appleEmail != "" && (dic["name"] as? String == "email" || dic["name"] as? String == "emailaddress" ) {

                                    element["default"] = String(appleEmail) as AnyObject?
                                    
                                }
                            }
                            
                            if let titleString = dic["name"] as? String {
                                
                                
                                if titleString.range(of: "first_name") != nil{
                                    if appleFirstName != nil && appleFirstName != ""{
                                        
                                        element["default"] = "\(appleFirstName.capitalized)" as AnyObject?
                                    }
                                    
                                }else if titleString.range(of: "last_name") != nil{
                                    if appleLastName != nil && appleLastName != ""{
                                        element["default"] = "\(appleLastName.capitalized)" as AnyObject?
                                    }
                                    
                                }
                            }
                            
                        if dic["name"] as! String == "location" || (dic["name"] as! String).range(of: "location") != nil {
                            element["action"] = "formLocation:" as AnyObject?
                            if isCreateOrEdit
                            {
                                print(locationInForm)
                                element["default"] = locationInForm as AnyObject?
                            }
                            else
                            {
                                if locationInForm != ""
                                {
                                    print(locationInForm)
                                    element["default"] = locationInForm as AnyObject?
                                }
                                else
                                {
                                    if let value = formValue.value(forKey: dic["name"] as! String)
                                    {
                                        element["default"] = value as AnyObject?
                                    }
                                }
                                
                            }
                            
                        }
                        }
                        
                        if (conditionalForm != nil && conditionalForm == "signupAccountForm"){
                            if dic["name"] as? String == "email" || dic["name"] as? String == "emailaddress"{
                                element["type"] = "email" as AnyObject?
                                if fbEmail != nil && fbEmail != "" && (dic["name"] as? String == "email" || dic["name"] as? String == "emailaddress" ) {
                                    
                                    element["default"] = String(fbEmail) as AnyObject?
                                    
                                }
                                
                                if appleEmail != nil && appleEmail != "" && (dic["name"] as? String == "email" || dic["name"] as? String == "emailaddress" ) {
                                    
                                    element["default"] = String(appleEmail) as AnyObject?
                                    
                                }
                            }
                            
                            if let titleString = dic["name"] as? String {
                                
                                
                                if titleString.range(of: "first_name") != nil{
                                    if appleFirstName != nil && appleFirstName != ""{
                                        
                                        element["default"] = "\(appleFirstName.capitalized)" as AnyObject?
                                    }
                                    
                                }else if titleString.range(of: "last_name") != nil{
                                    if appleLastName != nil && appleLastName != ""{
                                        element["default"] = "\(appleLastName.capitalized)" as AnyObject?
                                    }
                                    
                                }
                            }
                            
                            if dic["name"] as? String == "username" {
                                if ((appleFirstName != nil && appleFirstName != "") && ((appleLastName != nil && appleLastName != ""))){
                                    let ran_val = Int(arc4random_uniform(9))
                                    let tempUserName = appleFirstName + appleLastName
                                    let tempFullUserName = tempUserName + String(ran_val)
                                    element["default"] = tempFullUserName as AnyObject?
                                    
                                }
                                
                                
                                
                                
                                
                                
                                
                            }
                            if dic["name"] as? String == "username" {
                                if ((fbFirstName != nil && fbFirstName != "") && ((fbLastName != nil && fbLastName != ""))){
                                    let ran_val = Int(arc4random_uniform(9))
                                    let tempUserName = fbFirstName + fbLastName
                                    let tempFullUserName = tempUserName + String(ran_val)
                                    element["default"] = tempFullUserName as AnyObject?
                                    
                                }
                                
                                
                            }
                            
                        }
                        else if (conditionalForm != nil && conditionalForm == "signupProfileForm"){
                            
                            if let titleString = dic["name"] as? String {
                                
                                
                                if titleString.range(of: "first_name") != nil{
                                    if fbFirstName != nil && fbFirstName != ""{
                                        
                                        element["default"] = "\(fbFirstName.capitalized)" as AnyObject?
                                    }
                                    if appleFirstName != nil && appleFirstName != ""{
                                        
                                        element["default"] = "\(appleFirstName.capitalized)" as AnyObject?
                                    }
                                    
                                    
                                }else if titleString.range(of: "last_name") != nil{
                                    if fbLastName != nil && fbLastName != ""{
                                        element["default"] = "\(fbLastName.capitalized)" as AnyObject?
                                    }
                                    if appleLastName != nil && appleLastName != ""{
                                        element["default"] = "\(appleLastName.capitalized)" as AnyObject?
                                    }
                                    
                                }
                            }
                            
                            
                        }
                        
                        //Adding header on signup
                        if (conditionalForm != nil && conditionalForm == "signupProfileForm")
                        {
                            if tempDictionary != nil
                            {
                                
                                if profilekeys.count > 0
                                {
                                    let key = dic["name"] as? String
                                    for i in 0 ..< profilekeys.count
                                    {
                                        let header = profilekeys[i]
                                        let Arrdic = tempDictionary["\(header)"] as? NSArray
                                        let firstdic = Arrdic![0] as! NSDictionary
                                        let diclabel = firstdic["name"] as! String
                                        if key == diclabel
                                        {
                                            if (header as AnyObject).contains("_metaOrder_"){
                                                var token = (header as AnyObject).components(separatedBy: "_metaOrder_")
                                                element["header"] = token[0] as AnyObject?
                                            }
                                            else{
                                                element["header"] = "\(header)" as AnyObject?
                                                
                                            }
                                            break
                                        }
                                    }
                                }
                            }
                        }
                        
                        if !isCreateOrEdit{
                            let key = dic["name"] as? String
                            element["default"] = formValue[key!] as AnyObject?
                        }
                        
                        if let description = dic["description"] as? String{
                            if description != ""{
                                element["footer"] = description as AnyObject?
                            }
                        }
                        
                        if (conditionalForm != nil && conditionalForm == "generalSettings"){
                            let key = dic["name"] as? String
                            element["default"] = formValue[key!] as AnyObject?
                        }
                        
                        if globalWishlistOwnerSearch != ""
                        {
                            
                            if dic["name"] as! String == "text" && dic["type"] as! String == "Text"{
                                element["default"] = "\(globalWishlistOwnerSearch)" as AnyObject?
                            }
                            
                        }
                        
                        if conditionalForm != nil && conditionalForm == "AddToDiary" && dic["name"]as? String == "title"
                        {
                            if istitleheader == true
                            {
                                istitleheader = false
                                element["header"] = "You can also add this Event in a new diary below:" as AnyObject?
                                
                            }
                            
                        }
                        if conditionalForm != nil && conditionalForm == "addtoplaylist" && dic["name"]as? String == "title"
                        {
                            if istitleheader == true
                            {
                                istitleheader = false
                                element["header"] = NSLocalizedString("You can also add this video in a new playlist below:", comment: "") as AnyObject?
                                
                            }
                            
                        }
                        if conditionalForm != nil && (conditionalForm == "product wishlist" || conditionalForm == "wishlist")
                        {
                            if istitleheader == true
                            {
                                istitleheader = false
                                element["header"] = createWishlistDescription as AnyObject?
                                
                            }
                            
                        }
                        
                        if isCreateOrEdit
                        {
                            
                            if dic["name"]as? String == "location"
                            {
                                if location == "ab"
                                {
                                    let defaults = UserDefaults.standard
                                    if let loc = defaults.string(forKey: "Location")
                                    {
                                        element["default"] = loc as AnyObject?
                                        
                                    }
                                    else
                                    {
                                        if defaultlocation != ""
                                        {
                                            element["default"] = defaultlocation as AnyObject?
                                        }
                                    }
                                }
                                else
                                {
                                    element["default"] = "\(location)" as AnyObject?
                                }
                            }
                        }
                        
                        if venue_name != ""
                        {
                            if dic["name"] as! String == "venue_name" {
                                element["default"] = "\(venue_name)" as AnyObject?
                            }
                        }
                        
                        if Siteevent_street != ""
                        {
                            if dic["name"] as! String == "Siteevent_street" {
                                element["default"] = "\(Siteevent_street)" as AnyObject?
                            }
                        }
                        
                        if siteevent_city != ""
                        {
                            if dic["name"] as! String == "siteevent_city" {
                                element["default"] = "\(siteevent_city)" as AnyObject?
                            }
                        }
                        
                        if siteevent_state != ""
                        {
                            if dic["name"] as! String == "siteevent_state" {
                                element["default"] = "\(siteevent_state)" as AnyObject?
                            }
                        }
                        
                        if siteevent_country != ""
                        {
                            if dic["name"] as! String == "siteevent_country" {
                                element["default"] = "\(siteevent_country)" as AnyObject?
                            }
                        }
                        
                        if member != ""
                        {
                            if dic["name"] as! String == "member"
                            {
                                element["default"] = "\(member)" as AnyObject?
                            }
                        }
                        
                        if isCreateOrEdit
                        {
                            let key = dic["name"] as? String
                            if (key != nil) && Formbackup[key!] != nil && key!.range(of: "location") == nil
                            {
                                element["default"] = Formbackup.value(forKey: key!) as AnyObject?
                            }
                        }
                        
                        formElements.append(element as AnyObject)
                        
                        if(conditionalForm != nil){
                            if conditionalForm == "poll"{
                                
                                if dic["name"] as? String == "options_15"{
                                    var element = Dictionary<String, AnyObject>()
                                    element["title"] = NSLocalizedString("Add Options", comment: "") as AnyObject?
                                    element["action"] = "addMoreOption:" as AnyObject?
                                    formElements.append(element as AnyObject)
                                }
                                
                            }
                        }
                    }
                    else if dic["type"] as! String == "Rating"
                    {
                        //element["cell"] = "FXFormstarviewCell"
                        element["type"] = "rateview" as AnyObject?
                        element["key"] = dic["name"] as? String as AnyObject?
                        element["title"]  = dic["label"] as? String as AnyObject?
                        element["action"] = "getRating:" as AnyObject?
                        
                        let key = dic["name"] as? String
                        if key != nil
                        {
                            element["default"] = formValue[key!] as AnyObject?
                        }
                        
                        formElements.append(element as AnyObject)
                    }
//                    else if dic["type"] as! String == "File"
//                    {
//
//                        element["key"] = dic["name"] as? String as AnyObject?
//                        element["title"] = dic["label"] as? String as AnyObject?
//                        if multiplePhotoSelection == true{
//                            element["class"] = "UploadPhotosViewController" as AnyObject?
//                        }
//                        else
//                        {
//                            element["type"] = "image" as AnyObject?
//                        }
//                        if conditionalForm == "addProduct"
//                        {
//                            element["action"] = "holdValues:" as AnyObject
//                        }
//
//                        if isCreateOrEdit
//                        {
//
//                            let key = dic["name"] as? String
//
//
//
//                            if key != nil && Formbackup != nil
//                            {
//                                element["default"] = Formbackup.value(forKey: key!) as AnyObject?
//                            }
//                            else
//                            {
//
//                                element["default"] = "" as AnyObject?
//
//                            }
//                            element["placeholder"] = UIImage(named : "logoImgHolder.png")
//
//
//                        }
//
//                        formElements.append(element as AnyObject)
//
//                    }
                    else if dic["type"] as! String == "File"
                    {

                        element["key"] = dic["name"] as? String as AnyObject?
                        element["title"] = dic["label"] as? String as AnyObject?
                        element["class"] = "UploadPhotosViewController" as AnyObject?
                        if multiplePhotoSelection == true
                        {
                            element["class"] = "UploadPhotosViewController" as AnyObject?
                        }
//                        else if(conditionalForm != nil && conditionalForm == "TargetForm") {
//                            element["class"] = "UploadPhotosViewController" as AnyObject?
//                       }
                        else
                        {
                            // For DocumentPicker
                            if conditionalForm == "applynow"
                            {
                                element["action"] = "pickDocument:" as AnyObject?
                                element["default"] = filename as AnyObject?
                            }
                            else if conditionalForm == "mainFile"
                            {
                                element["action"] = "pickDocument:" as AnyObject?
                                element["default"] = filename as AnyObject?
                            }
                            else if conditionalForm == "sampleFile"
                            {
                                element["action"] = "pickDocument:" as AnyObject?
                                element["default"] = filename as AnyObject?
                            }
                            else
                            {
                                element["type"] = "image" as AnyObject?
                                let key = dic["name"] as? String
                                if (conditionalForm != nil && conditionalForm == "signupAccountForm"){
                                    element["placeholder"] = UIImage(named : "add_icon_circle.png")?.maskWithColor(color: textColorDark)
                                }
                                if key != nil
                                {
                                    if Formbackup.value(forKey: key!) as AnyObject? != nil {
                                        element["default"] = Formbackup.value(forKey: key!) as AnyObject?
                                    }
                                    
                                }
                                else
                                {
                                    element["default"] = "" as AnyObject?

                                }
                            }

                        }

                        formElements.append(element as AnyObject)
                    }
                    else if dic["type"] as! String == "Float"
                    {
                        element["key"] = dic["name"] as? String as AnyObject?
                        element["header"] = "" as AnyObject?
                        element["title"] = dic["label"] as? String as AnyObject?
                        element["type"] = "float" as AnyObject?
                        formElements.append(element as AnyObject)
                    }
                    else if dic["type"] as! String == "Password"
                    {
                        element["key"] = dic["name"] as? String as AnyObject?
                        // element["header"] = ""
                        if let description = dic["description"] as? String{
                            if description != ""{
                                element["footer"] = description as AnyObject?
                            }
                        }
                      //  element["footer"] = dic["description"] as? String as AnyObject?
                        
                        element["title"] = dic["label"] as? String as AnyObject?
                        element["type"] = "password" as AnyObject?
                        formElements.append(element as AnyObject)
                        
                    }
                    else if dic["type"] as! String == "MultiCheckbox"  ||  dic["type"] as! String == "Multiselect" || dic["type"] as! String == "Multi_checkbox"
                    {
                        
                            var formsval = [String]()
                            let key = dic["name"] as? String ?? ""
                        print(MultiCheckFormValue)
                        print(key)
                        print(MultiCheckFormValue.value(forKey : key))
                        
                            if let fvalue = formValue.value(forKey : key) as? Int
                            {
                                let val = String(fvalue)
                                formsval.append(val)
                            }
                            else if let fvalue = formValue.value(forKey : key) as? NSArray
                            {
                                for element in fvalue
                                {
                                    if let val = element as? String
                                    {
                                        formsval.append(val)
                                    }
                                    else if let val = element as? Int
                                    {
                                        formsval.append(String(val))
                                    }
                                    
                                }
                            }
                        
                        if signUplayoutType {
                            if let fvalue = MultiCheckFormValue.value(forKey : key) as? NSArray
                            {
                                for element in fvalue
                                {
                                    if let val = element as? String
                                    {
                                        formsval.append(val)
                                    }
                                    else if let val = element as? Int
                                    {
                                        formsval.append(String(val))
                                    }
                                    
                                }
                            }
                        if let multiOptionsDic = dic["multiOptions"] as? NSDictionary{
                            var headerShown = true
                            
                            
                            
                            let counts = 2
                            for i in 0 ..< counts where i < counts
                            {
                                if headerShown == true
                                {
                                    headerShown = false
                                    var element1 = Dictionary<String, AnyObject>()
                                    element1["key"] = dic["name"] as? String as AnyObject?
                                    element1["title"] = dic["label"] as? String as AnyObject?
                                    element1["type"] = "Label" as AnyObject?
                                    formElements.append(element1 as AnyObject)
                                }
                                else
                                {
                                    for (name, desc) in multiOptionsDic
                                    {
                                        element["key"] = multiOptionsDic["\(name)"] as? String as AnyObject?
                                        element["title"] = multiOptionsDic["\(desc)"] as? String as AnyObject?
                                        element["type"] = "option" as AnyObject?
                                        element["default"] = 0 as AnyObject?
                                        
                                        if isCreateOrEdit
                                        {
                                            if let val = Formbackup.value(forKey: desc as! String)
                                            {
                                                if let checkValue = val as? Int
                                                {
                                                    element["default"] = checkValue as AnyObject?
                                                }
                                            }
                                        }
                                            
                                        else
                                        {
                                            print(name)
                                            print(formsval)
                                            let val = String(describing : name)
                                            if formsval.contains(val)
                                            {
                                                element["default"] = 1 as AnyObject?
                                            }
                                            else
                                            {
                                                element["default"] = 0 as AnyObject?
                                            }
                                        }
                                        
                                        formElements.append(element as AnyObject)
                                    }
                                }
                            }
                        }
                        }
                        else{
                        if let multiOptionsDic = dic["multiOptions"] as? NSDictionary
                        {
                            element["header"] = dic["label"]  as AnyObject?
                            var showheader = true
                            for (name, desc) in multiOptionsDic
                            {
                                if showheader == true
                                {
                                    showheader = false
                                    var element1 = Dictionary<String, AnyObject>()
                                    element1["key"] = dic["\(name)"] as? String as AnyObject?
                                    element1["title"] = dic["\(desc)"] as? String as AnyObject?
                                    element1["type"] = "Label" as AnyObject?
                                    if let label = dic["label"] as? String
                                    {
                                        let description = dic["description"] as! String
                                        let fulldescription = label + "\n" + description
                                        element1["title"] = fulldescription as AnyObject?
                                        if dic["type"] as! String == "MultiCheckbox" && dic["name"] as! String == "publishTypes"
                                        {
                                            let key = dic["name"] as? String
                                            let values = formValue.value(forKey: key!) as! NSDictionary
                                            if values.count > 0
                                            {
                                                let arr = values.allValues as NSArray
                                                if arr.contains(name)
                                                {
                                                    element1["default"] = 1 as AnyObject?
                                                }
                                                else
                                                {
                                                    element1["default"] = 0 as AnyObject?
                                                }

                                            }
                                        }
                                        //Adding header on signup
                                        if (conditionalForm != nil && conditionalForm == "signupProfileForm")
                                        {
                                            if tempDictionary != nil
                                            {

                                                if profilekeys.count > 0
                                                {
                                                    let key = dic["name"] as? String
                                                    for i in 0 ..< profilekeys.count
                                                    {
                                                        let header = profilekeys[i]
                                                        let Arrdic = tempDictionary["\(header)"] as? NSArray
                                                        let firstdic = Arrdic![0] as! NSDictionary
                                                        let diclabel = firstdic["name"] as! String
                                                        if key == diclabel
                                                        {
                                                            if (header as AnyObject).contains("_metaOrder_"){
                                                                var token = (header as AnyObject).components(separatedBy: "_metaOrder_")
                                                                element1["header"] = token[0] as AnyObject?
                                                            }
                                                            else{
                                                                element1["header"] = "\(header)" as AnyObject?

                                                            }
                                                            break
                                                        }
                                                    }
                                                }

                                            }
                                        }
                                        formElements.append(element1 as AnyObject)
                                    }
                                }
                                else
                                {
                                    element["key"] = multiOptionsDic["\(name)"] as? String as AnyObject?
                                    element["title"] = multiOptionsDic["\(desc)"] as? String as AnyObject?
                                    element["type"] = "option" as AnyObject?
                                    if dic["type"] as! String == "MultiCheckbox" && dic["name"] as! String == "publishTypes"
                                    {
                                        let key = dic["name"] as? String
                                        let values = formValue.value(forKey: key!) as! NSDictionary
                                        if values.count > 0
                                        {
                                            let arr = values.allValues as NSArray
                                            if arr.contains(name)
                                            {
                                                element["default"] = 1 as AnyObject?
                                            }
                                            else
                                            {
                                                element["default"] = 0 as AnyObject?
                                            }

                                        }
                                    }
                                    formElements.append(element as AnyObject)
                                }

                            }
                        }
                        }
                    }
                    else if dic["type"] as! String == "Submit"
                    {
                        element["header"] = "" as AnyObject?
                        if (conditionalForm != nil && conditionalForm == "classified") || (conditionalForm != nil && conditionalForm == "blog"){
                            element["title"] = NSLocalizedString("Continue",comment: "") as AnyObject?
                        }
                        else {
                            
                            element["title"] = dic["label"] as? String as AnyObject?
                        }
                        element["action"] = "submitForm:" as AnyObject?
                        formElements.append(element as AnyObject)
                    }
                    else if dic["type"] as! String == "Button"
                    {
                        element["header"] = "" as AnyObject?
                        element["title"] = dic["label"] as? String as AnyObject?
                        element["action"] = "submitForm:" as AnyObject?
                        formElements.append(element as AnyObject)
                    }
                    else if dic["type"] as! String == "Checkbox"
                    {
                        element["type"] = "option" as AnyObject?
                        element["key"] = dic["name"] as? String as AnyObject?
                        element["title"] = dic["label"] as? String as AnyObject?
                        if dic["label"] as? String == "This post has a photo attached. Do you want to delete it?"{
                            element["title"] = "Do You Want to Delete Attached Photo?" as AnyObject?
                        }
                        
                        if let value = dic["value"] as? Int{
                            element["default"] = value as AnyObject?
                        }else{
                            element["default"] = "0" as AnyObject?
                        }
                        
                        if let key = dic["name"] as? String
                        {
                            if let value = formValue[key] as AnyObject?
                            {
                                element["default"] = value
                            }
                        }
                        
                        if conditionalForm != nil && conditionalForm == "AddToDiary"
                        {
                            if isheader == true
                            {
                                isheader = false
                                element["header"] = "Please select the diaries in which you want to add this Event." as AnyObject?
                                
                            }
                            
                        }
                        
                        if conditionalForm != nil && conditionalForm == "addtoplaylist"
                        {
                            if isheader == true
                            {
                                isheader = false
                                element["header"] = NSLocalizedString("Please select the playlist in which you want to add this Video", comment: "") as AnyObject?
                                
                            }
                            
                        }
                        
                        if conditionalForm != nil && (conditionalForm == "product wishlist" || conditionalForm == "wishlist")
                        {
                            if isheader == true
                            {
                                isheader = false
                                element["header"] = addWishlistDescriptIon as AnyObject?
                                
                            }
                            
                        }
                        
                        formElements.append(element as AnyObject)
                    }
                    else if (dic["type"] as! String == "Date" || dic["type"] as! String == "date")
                    {
                        
                        element["type"] = "datetime" as AnyObject?
                        element["title"] = dic["label"] as? String as AnyObject?
                        element["key"] = dic["name"] as? String as AnyObject?
                        
                //        if(conditionalForm != nil && conditionalForm == "signupProfileForm"){
                        
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd"
                            
                            let dateString = ""
                            element["type"] = "date" as AnyObject?
                        if(conditionalForm != nil && conditionalForm == "TargetForm"){
                             dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                            element["type"] = "datetime" as AnyObject?
                        }
                        let key = dic["name"] as? String
                                                   
                        if (key != nil)
                        {
                            element["default"] = Formbackup[key!] as AnyObject?
                        }
                        else
                        {
                            element["default"] = "" as AnyObject?
                        }
                            
                      //  }
                
                        
                        if !isCreateOrEdit
                        {
                            if let key = dic["name"] as? String
                            {
                                if let value = formValue[key] as? String
                                {
                                    let dateValue = value.components(separatedBy: " ")
                                    let dateVal = dateValue[0]
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "yyyy-MM-dd"
                                    let defaultVal = dateFormatter.date(from: dateVal)
                                    element["default"] = defaultVal as AnyObject
                                }
                            }
                        }
 
                        formElements.append(element as AnyObject)
                        
                        
                    }
                        
                    
                    else if (dic["type"] as! String == "Select" || dic["type"] as! String == "select") || (dic["type"] as! String == "Radio")
                    {
                        //MARK: Selectbox
                        if !((conditionalForm != nil) && (conditionalForm == "Album") && (dic["label"] as! String == "Choose Album")){
                            
                            if conditionalForm != nil && conditionalForm == "ForumSearch"{
                                element["key"] = dic["name"] as? String as AnyObject?
                                element["title"] = dic["label"] as? String as AnyObject?
                                
                            }
                            else{
                                element["cell"] = "FXFormOptionPickerCell" as AnyObject?
                                element["key"] = dic["name"] as? String as AnyObject?
                                element["title"] = dic["label"] as? String as AnyObject?
                                let key = dic["name"] as? String
                                                           
                                if (key != nil)
                                {
                                    element["default"] = Formbackup[key!] as AnyObject?
                                }
                            }
                          
                            if let description = dic["description"] as? String{
                                if description != "" {
                                element["footer"] = description as AnyObject?
                                }
                            }
                            
                            if(conditionalForm != nil){
                                
                                if conditionalForm == "video" || conditionalForm == "album" || conditionalForm == "poll" || conditionalForm == "generalSettings" || conditionalForm == "Album"{
                                    
                                    if dic["type"] as! String == "Select" && (dic["name"] as! String == "type" || dic["name"] as! String == "album"){
                                        element["action"] = "fieldValueChanged:" as AnyObject?
                                        
                                    }
                                }
                                if conditionalForm == "signupAccountForm"{
                                if dic["type"] as! String == "Select" && dic["name"] as! String == "profile_type"
                                {
                                    element["action"] = "profileValueChanged:" as AnyObject?
                                }
                                    if dic["name"] as! String == "profile_type"
                                    {
                                        if defaultCategory != nil
                                        {
                                            if Formbackup["profile_type"] != nil {
                                                if Formbackup["profile_type"] as! String != ""{
                                                    element["default"] = Formbackup["profile_type"] as AnyObject?
                                                    
                                                }
                                            }else{
                                                element["default"] = defaultCategory as AnyObject?
                                            }
                                        }
                                       
                                        
                                    }
                                }
                            }
                            
                            
                            
                            if let option = dic["multiOptions"] as? NSArray{
                                
                                if option.count > 0
                                {
                                    
                                    if let value = dic["value"] as? Int
                                    {
                                        let id = Int(value)
                                        element["default"] = option[id] as AnyObject?
                                        
                                    }
                                    else
                                    {
                                       
                                        element["default"] = option[0] as AnyObject?
                                        
                                    }
                                    
                                    if globalCatg != ""
                                    {
                                        if dic["label"] as! String == "Category" {
                                            element["default"] = "\(globalCatg)" as AnyObject?
                                        }
                                    }
                                    
                                    element["options"] = option
                                    formElements.append(element as AnyObject)
                                }
                                
                            }
                            else if let _ = dic["multiOptions"] as? NSDictionary
                            {
                                var options = [AnyObject]()
                                
                                if globalTypeSearch != ""
                                {
                                    element["default"] = "\(globalTypeSearch)" as AnyObject?
                                }
                               
                                
                                if let option = dic["multiOptions"] as? NSDictionary
                                {
                                    
                                    if(conditionalForm != nil && conditionalForm == "signupProfileForm"){
                                        var appendArray = [String]()
                                        for (_,value) in option{
                                            
                                            if let val = value as? Int
                                            {
                                                let mainVal = String(val)
                                                appendArray.append(mainVal as String)
                                            }
                                            if let val = value as? String
                                            {
                                                appendArray.append(val)
                                            }
                                        }
                                        
                                        let arrayCustom =  sortArrayFunc(inputArray: appendArray)
                                        
                                        options = (arrayCustom as [AnyObject])
                                    }
                                    else if(conditionalForm != nil && conditionalForm == "TargetForm"){
                                        var appendArray = [String]()
                                        for (_,value) in option{
                                            
                                            appendArray.append(String(describing: value ))
                                        }
                                        
                                        let arrayCustom =  sortArrayFunc(inputArray: appendArray)
                                        
                                        options = (arrayCustom as [AnyObject])
                                    }
                                    else{
                                        
                                        let array2  = option.allKeys.sorted(by: { (key1, key2) -> Bool in
                                            (key1 as! String) < (key2 as! String)
                                        })
                                        
                                        for index in array2{
                                            options.append(option["\(index)"]! as AnyObject)
                                        }
                                    }
                                    
                                    if conditionalForm != nil && conditionalForm == "Diary"
                                    {
                                        
                                        if dic["name"] as! String == "auth_view"
                                        {
                                            if let value = dic["value"] as? String
                                            {
                                                element["default"] = option.value(forKey: value) as AnyObject?
                                            }
                                            else
                                            {
                                                element["default"] = options[0]
                                            }
                                            
                                        }
                                        
                                    }
                                    else if conditionalForm != nil && conditionalForm == "AddToDiary"
                                    {
                                        if dic["name"] as! String == "auth_view"
                                        {
                                            if let value = dic["value"] as? String
                                            {
                                                element["default"] = option.value(forKey: value) as AnyObject?
                                            }
                                            else
                                            {
                                                element["default"] = options[0]
                                            }
                                            
                                        }
                                        
                                    }
                                        //For fetching Gender in case of facebook login
                                    else if (conditionalForm != nil && conditionalForm == "signupProfileForm")
                                    {
                                        if fbGender != nil
                                        {
                                            
                                            let name =  dic["name"] as! String
                                            if name.range(of: "alias_gender") != nil
                                            {
                                                for (_,value) in option
                                                {
                                                    let lowerString = value as! String
                                                    if (lowerString.lowercased() == fbGender.lowercased())
                                                    {
                                                        element["default"] = lowerString as AnyObject?
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    else
                                    {
                                        
                                        if let value = dic["value"] as? String
                                        {
                                            element["default"] = option.value(forKey: value) as AnyObject?
                                        }
                                        else
                                        {
                                            if let value = dic["name"] as? String
                                            {
                                                let value1 = formValue[value] as AnyObject?
                                                if value1 != nil {
                                                    element["default"] = option.value(forKey: "\(String(describing: value1!))") as AnyObject?
                                                }
                                            }
                                            else {
                                             if !isCreateOrEdit{
                                                element["default"] = "" as AnyObject?
                                            }
                                             else{
                                                if  videoAttachFromAAF == "AAF" && dic["name"] as! String == "type" {
                                                    element["default"] = NSLocalizedString("My Device",comment: "") as AnyObject?
                                                         as AnyObject?
                                                }
                                                else{
                                                    element["default"] = option[0] as AnyObject?
                                                }
                                            }
                                            }
                                        }
                                    }
                                    
                                    if(conditionalForm != nil && conditionalForm == "TargetForm"){
                                        let key = dic["name"] as? String
                                        if (key != nil) && Formbackup[key!] != nil
                                        {
                                            element["default"] = Formbackup[key!]as AnyObject?
                                        }
                                        else
                                        {
                                            if let value = dic["value"] as? String
                                            {
                                                element["default"] = option.value(forKey: value) as AnyObject?
                                            }
                                        }
                                    }
                                    
                                    if globalCatg != ""
                                    {
                                        if dic["label"] as! String == "Category" {
                                            element["default"] = "\(globalCatg)" as AnyObject?
                                        }
                                    }
                                    
                                    if showInFilter != ""
                                    {
                                        if dic["name"] as! String == "show" {
                                            element["default"] = "\(showInFilter)" as AnyObject?
                                        }
                                    }
                                    
                                    if showEventType != ""
                                    {
                                        if dic["name"] as! String == "showEventType" {
                                            element["default"] = "\(showEventType)" as AnyObject?
                                        }
                                    }
                                    
                                    if orderBy != ""
                                    {
                                        if dic["name"] as! String == "orderBy" {
                                            element["default"] = "\(orderBy)" as AnyObject?
                                        }
                                    }
                                    
                                    if event_time != ""
                                    {
                                        if dic["name"] as! String == "event_time" {
                                            element["default"] = "\(event_time)" as AnyObject?
                                        }
                                    }
                                    
                                    if proximity != ""
                                    {
                                        if dic["name"] as! String == "proximity" {
                                            element["default"] = "\(proximity)" as AnyObject?
                                        }
                                    }
                                    
                                    if category_id != ""
                                    {
                                        if dic["name"] as! String == "category_id" {
                                            element["default"] = "\(category_id)" as AnyObject?
                                        }
                                    }
                                    
                                    if start_date != nil
                                    {
                                        if dic["name"] as! String == "start_date"
                                        {
                                            
                                            element["default"] = start_date as AnyObject?
                                        }
                                    }
                                    
                                    if end_date != nil
                                    {
                                        if dic["name"] as! String == "end_date"
                                        {
                                            element["default"] = end_date as AnyObject?
                                        }
                                    }
                                    
                                    if search_diary != ""
                                    {
                                        if dic["name"] as! String == "search_diary"
                                        {
                                            element["default"] = "\(search_diary)" as AnyObject?
                                        }
                                    }
                                    
                                    if orderby != ""
                                    {
                                        if dic["name"] as! String == "orderby" {
                                            element["default"] = "\(orderby)" as AnyObject?
                                        }
                                    }
                                    
                                    if !isCreateOrEdit{
                                        let key = dic["name"] as? String
                                        let index: AnyObject? = formValue[key!] as AnyObject?
                                        var str = ""
                                        if index != nil {
                                            if let option = option["\(index!)"] as? String{
                                                str = option
                                            }
                                            element["default"] = str as AnyObject?
                                        }
                                    }
                                }
                                
                                
                                //Adding header on signup
                                if (conditionalForm != nil && conditionalForm == "signupProfileForm")
                                {
                                    if tempDictionary != nil
                                    {
                                        
                                        if profilekeys.count > 0
                                        {
                                            let key = dic["name"] as? String
                                            for i in 0 ..< profilekeys.count
                                            {
                                                let header = profilekeys[i]
                                                let Arrdic = tempDictionary["\(header)"] as? NSArray
                                                let firstdic = Arrdic![0] as! NSDictionary
                                                let diclabel = firstdic["name"] as! String
                                                if key == diclabel
                                                {
                                                    if (header as AnyObject).contains("_metaOrder_"){
                                                        var token = (header as AnyObject).components(separatedBy: "_metaOrder_")
                                                        element["header"] = token[0] as AnyObject?
                                                    }
                                                    else{
                                                        element["header"] = "\(header)" as AnyObject?
                                                        
                                                    }
                                                    break
                                                }
                                            }
                                            
                                            
                                        }
                                        
                                    }
                                }
                                
                                element["options"] = options as AnyObject?
                                formElements.append(element as AnyObject)
                            }
                            
                        }}
                    else if dic["type"] as! String == "Textarea"
                    {
                        if conditionalForm != nil && (conditionalForm == "blog" || conditionalForm == "classified"){
                            
                            let defaults = UserDefaults.standard
                            defaults.set("Coding overview", forKey: "overviewcheck")
                            
                        }
                        else
                        {
                            
                            element["type"] = "longtext" as AnyObject?
                            
                            if dic["name"] as? String ==  "description"
                            {
                                element["key"] = "change_description" as AnyObject?
                            }
                            else
                            {
                                element["key"] = dic["name"] as? String as AnyObject?
                                
                                let defaults = UserDefaults.standard
                                
                                if let name = defaults.value(forKey: "preferenceName")
                                {
                                    
                                    element["default"] = name as! String as AnyObject?
                                }

                            }
                            element["title"] = dic["label"] as? String as AnyObject?
                            
                            if conditionForm != nil && conditionForm == "postReply"{
                                element["title"] = "Description" as AnyObject?
                            }
                            if dic["name"] as? String ==  "description"{
                            let key1 = "change_description" //dic["name"] as? String
                                if Formbackup[key1] != nil
                                {
                                    element["default"] = Formbackup.value(forKey: key1) as AnyObject?
                                }
                            }
                            
                            if !isCreateOrEdit{
                                let key = dic["name"] as? String
                                element["default"] = formValue[key!] as AnyObject?
                                let defaults = UserDefaults.standard
                                
                                if  conditionForm != nil && (conditionForm == "forumEditing"  || conditionForm == "forumQuoting"){
                                    element["title"] = "Description" as AnyObject?
                                    if let name = defaults.value(forKey: "preferenceName")
                                    {
                                        if name as! String != "" {
                                            element["default"] = name as! String as AnyObject?
                                        }
                                    }
                                }
                            }
                            
                            //Adding header on signup
                            if (conditionalForm != nil && conditionalForm == "signupProfileForm")
                            {
                                if tempDictionary != nil
                                {
                                    
                                    if profilekeys.count > 0
                                    {
                                        let key = dic["name"] as? String
                                        for i in 0 ..< profilekeys.count
                                        {
                                            let header = profilekeys[i]
                                            let Arrdic = tempDictionary["\(header)"] as? NSArray
                                            let firstdic = Arrdic![0] as! NSDictionary
                                            let diclabel = firstdic["name"] as! String
                                            if key == diclabel
                                            {
                                                if (header as AnyObject).contains("_metaOrder_"){
                                                    var token = (header as AnyObject).components(separatedBy: "_metaOrder_")
                                                    element["header"] = token[0] as AnyObject?
                                                }
                                                else{
                                                    element["header"] = "\(header)" as AnyObject?
                                                    
                                                }
                                                break
                                            }
                                        }
                                    }
                                }
                            }
                            formElements.append(element as AnyObject)
                        }
                    }
                    else if dic["type"] as! String == "Integer"
                    {
                        element["type"] = "integer" as AnyObject?
                        element["key"] = dic["name"] as? String as AnyObject?
                        element["header"] = "" as AnyObject?
                        element["title"] = dic["label"] as? String as AnyObject?
                        formElements.append(element as AnyObject)
                    }
                    else if dic["type"] as! String == "Label"
                    {
                        
                        if conditionalForm != "product wishlist" && conditionalForm != "wishlist"{
                            element["type"] = "Label" as AnyObject?
                            element["title"] = dic["label"] as? String as AnyObject?
                            element["key"] = dic["name"] as? String as AnyObject?
                            formElements.append(element as AnyObject)
                        }
                        
                        
                    }
                    else if dic["name"] as! String == "terms_url"
                    {
                        
                        element["header"] = "" as AnyObject?
                        element["title"] = "\(dic["label"]!)" as AnyObject?
                        element["action"] = "readTerms:" as AnyObject?
                        termPrivacyUrl = dic["url"] as! String
                        formElements.append(element as AnyObject)
                        
                    }
                }
            }
        }
    }
    if(conditionalForm != nil && (conditionalForm == "signupAccountForm" || conditionalForm == "signupProfileForm" || conditionalForm == "signupPhotoForm" || conditionalForm == "notificationSetting" || conditionalForm == "TargetForm" || conditionalForm == "productType")){
        
        var element = Dictionary<String, AnyObject>()
        element["header"] = "" as AnyObject?
        element["title"] = NSLocalizedString("Continue",comment: "") as AnyObject?
        element["action"] = "submitForm:" as AnyObject?
        formElements.append(element as AnyObject)
    }
    
    if conditionalForm != nil{
        if conditionalForm == "advancedevents"
        {
            let key = Formbackup["is_online"] as? Int
            if (key != nil)
            {
                if isCreateOrEdit
                {
                    if Formbackup["is_online"] as! NSNumber == 0
                    {
                        findOptionalFormIndex("advancedevents", option: 1)
                    }
                    else
                    {
                        findOptionalFormIndex("advancedevents", option: 2)
                    }
                    
                }
                else
                {
                    if !isCreateOrEdit
                    {
                        if Formbackup["is_online"] != nil{
                            if (Formbackup["is_online"] is Bool && Formbackup["is_online"] as! Bool == false) || (Formbackup["is_online"] is NSNumber && Formbackup["is_online"] as! NSNumber == 0)
                            {
                                findOptionalFormIndex("advancedevents", option: 1)
                            }
                            else
                            {
                                findOptionalFormIndex("advancedevents", option: 2)
                            }
                        }
                        
                    }
                    else
                    {
                        findOptionalFormIndex(conditionalForm, option: 1)
                    }
                    
                }
            }
            else
            {
                if !isCreateOrEdit
                {
                    
                    let key =  formValue["is_online"] as? String
                    
                    if (key != nil)
                    {
                        
                        if formValue["is_online"] as! String == "0"
                        {
                            findOptionalFormIndex("advancedevents", option: 1)
                        }
                        else
                        {
                            findOptionalFormIndex(conditionalForm, option: 2)
                        }
                    }
                    else
                    {
                        findOptionalFormIndex(conditionalForm, option: 1)
                    }
                    
                }
                else
                {
                    findOptionalFormIndex(conditionalForm, option: 1)
                }
                
                
            }
            
            let key1 = Formbackup["monthlyType"] as? Int
            if (key1 != nil)
            {
                if isCreateOrEdit
                {
                    if Formbackup["monthlyType"] as! Bool == false
                    {
                        findOptionalFormIndex1("advancedevents", option: 1)
                    }
                    else
                    {
                        findOptionalFormIndex1("advancedevents", option: 2)
                    }
                    
                }
                else
                {
                    if !isCreateOrEdit
                    {
                        if Formbackup["monthlyType"] as! Bool == false
                        {
                            findOptionalFormIndex1("advancedevents", option: 1)
                        }
                        else
                        {
                            findOptionalFormIndex1("advancedevents", option: 2)
                        }
                    }
                    else
                    {
                        findOptionalFormIndex(conditionalForm, option: 1)
                    }
                    
                }
            }
            else
            {
                
                
                if !isCreateOrEdit
                {
                    
                    let key =  formValue["monthlyType"] as? Int
                    
                    if (key != nil)
                    {
                        
                        if formValue["monthlyType"] as! Int == 0
                        {
                            findOptionalFormIndex1("advancedevents", option: 1)
                        }
                        else
                        {
                            findOptionalFormIndex1(conditionalForm, option: 2)
                        }
                    }
                    else
                    {
                        findOptionalFormIndex(conditionalForm, option: 1)
                    }
                    
                }
                else
                {
                    findOptionalFormIndex(conditionalForm, option: 1)
                }
            }
        }
        else
        {
            if videoAttachFromAAF == "AAF"
            {
                
                findOptionalFormIndex(conditionalForm, option: 2)
            }
            else
            {
                findOptionalFormIndex(conditionalForm, option: 1)
            }
        }
    }
    
    return formElements
}



func findOptionalFormIndex(_ conditionalForm: String, option:Int)
{
    
    if conditionalForm != "advancedevents"
    {
        hideIndexFormArray.removeAll(keepingCapacity: false)
    }
    
    if  conditionalForm == "video"
    {
        var index = 0;
        for element in Form{
            if let dic = element as? NSDictionary{
                if option == 1
                {
                    if (dic["name"] as! String == "filedata")
                    {
                        hideIndexFormArray.append(index)
                    }
                }
                else if option == 2
                {
                    if (dic["name"] as! String == "url")
                    {
                        hideIndexFormArray.append(index)
                    }
                }
                
            }
            index += 1
        }
    }
    if conditionalForm == "Advanced Video" || conditionalForm == "Channel" || conditionalForm == "Video"
    {
        var index = 0;
        for element in Form{
            if let dic = element as? NSDictionary{
                if option == 1
                {
                    if (dic["name"] as! String == "filedata")
                    {
                        hideIndexFormArray.append(index)
                    }
                }
                else if option == 2
                {
                    if (dic["name"] as! String == "url")
                    {
                        hideIndexFormArray.append(index)
                    }
                }
                
            }
            index += 1
        }
    }
    else if conditionalForm == "album" || conditionalForm == "Album"
    {
        var index = 0;
        for element in Form{
            if let dic = element as? NSDictionary{
                if option == 2{
                    if (dic["name"] as! String == "title") || (dic["name"] as! String == "category_id") || (dic["name"] as! String == "description") || (dic["name"] as! String == "search") {
                        hideIndexFormArray.append(index)
                    }
                }
            }
            index += 1
        }
    }
    else if conditionalForm == "poll"
    {
        var index = 0;
        for element in Form{
            if let dic = element as? NSDictionary{
                if option == 1{
                    if let name = dic["name"] as? String{
                        if (name != "options_1") && (name != "options_2"){
                            if (name.range(of: "options_") != nil) {
                                hideIndexFormArray.append(index)
                            }
                        }
                    }
                }
            }
            index += 1
        }
    }
    else if conditionalForm == "listings"
    {
        var index = 0;
        
        for element in Form
        {
            //print(Form)
            //print(element)
            if let dic = element as? NSDictionary
            {
                if option == 1
                {
                    if (dic["name"] as! String == "end_date")
                    {
                        hideIndexFormArray.append(index - 1)
                    }
                    
                }else{
                    if (dic["name"] as! String == "end_date")  {
                        if hideIndexFormArray.contains(index)
                        {
                            let valueAtIndex = hideIndexFormArray.index(of: index)
                            hideIndexFormArray.remove(at: valueAtIndex!)
                        }
                    }
                }
            }
            index = index + 1
        }
    }
    else if conditionalForm == "advancedevents"
    {
        var index = 0;
        for element in Form
        {
            if let dic = element as? NSDictionary
            {
                if option == 2
                {   if let dicName = dic["name"] as? String {
                       if dicName == "venue_name" || dicName == "location" {
                         hideIndexFormArray.append(index)
                    }
                    }
                    
                }
                else
                {
                    if let dicName = dic["name"] as? String  {
                        if dicName == "venue_name" || dicName == "location" {
                            if hideIndexFormArray.contains(index)
                            {
                                let valueatindex =  hideIndexFormArray.index(of: index)
                                hideIndexFormArray.remove(at: valueatindex!)
                            }
                        }
                    }
                  
                    
                }
                
            }
            index += 1
        }
    }
    else if conditionalForm == "members"
    {
        
        var index = 0;
        for element in Form
        {
            if let dic = element as? NSDictionary
            {
                if option == 2
                {
                    
                    if (dic["name"] as! String == "show") || (dic["name"] as! String == "network_id") || (dic["name"] as! String == "orderby") || (dic["name"] as! String == "is_online") || (dic["name"] as! String == "has_photo")
                    {
                        hideIndexFormArray.append(index)
                    }
                }
                else
                {
                    
                    if (dic["name"] as! String == "show") || (dic["name"] as! String == "network_id") || (dic["name"] as! String == "orderby") || (dic["name"] as! String == "is_online") || (dic["name"] as! String == "has_photo")
                    {
                        if hideIndexFormArray.contains(index)
                        {
                            let valueatindex =  hideIndexFormArray.index(of: index)
                            hideIndexFormArray.remove(at: valueatindex!)
                        }
                    }
                }
            }
            index += 1
        }
    }
    
}

func findOptionalFormIndex1(_ conditionalForm: String, option:Int)
{
    //hideIndexFormArray.removeAll(keepCapacity: false)
    if conditionalForm == "advancedevents"
    {
        var index = 0;
        for element in Form
        {
            if let dic = element as? NSDictionary
            {
                if option == 2
                {
                    if (dic["name"] as! String == "repeat_day")
                    {
                        
                        if hideIndexFormArray.contains(index)
                        {
                            let valueatindex =  hideIndexFormArray.index(of: index)
                            hideIndexFormArray.remove(at: valueatindex!)
                        }
                        
                    }
                    if (dic["name"] as! String == "repeat_week") || (dic["name"] as! String == "repeat_weekday")
                    {
                        
                        if !hideIndexFormArray.contains(index)
                        {
                            hideIndexFormArray.append(index)
                        }
                    }
                }
                if option == 1
                {
                    if (dic["name"] as! String == "repeat_week") || (dic["name"] as! String == "repeat_weekday")
                    {
                        if hideIndexFormArray.contains(index)
                        {
                            let valueatindex =  hideIndexFormArray.index(of: index)
                            hideIndexFormArray.remove(at: valueatindex!)
                        }
                        
                    }
                    if (dic["name"] as! String == "repeat_day")
                    {
                        if !hideIndexFormArray.contains(index)
                        {
                            hideIndexFormArray.append(index)
                        }
                        
                    }
                    
                }
                
            }
            index += 1
        }
    }
    
}

// Create Sort an Array
func order(_ s1: AnyObject, s2: AnyObject) -> Bool {
    if let str = s1 as? String{
        if let str2 = s2 as? String{
            return Int(str)<Int(str2)
        }
    }else{
    }
    return false
}


// Create Dictionary From Array
func getDictionaryFromArray(_ array:NSArray)-> NSDictionary{
    
    var dic = Dictionary<String, String>()
    var i = 0;
    for value in array{
        dic["\(i)"] = value as? String
        i += 1
    }
    
    return dic as NSDictionary
}

// Find Key For Particular Value in Dictionary (in Form Submission)
func findKeyForValue(_ str:String)->String
{
    
    //print(str)
    let keyStr = ""
    for key in Form{
        if let dic = (key as? NSDictionary){
            
            if let option = (dic["multiOptions"] as? NSDictionary){
                for (key, _ ) in option{
                    if key as! String != ""
                    {
                        var valueToString = ""
                        if let value = option["\(key)"] as? String
                        {
                            valueToString = value
                        }
                        if let value = option["\(key)"] as? Int
                        {
                            valueToString = String(value)
                        }
                        if valueToString == str
                        {
                            return key as! String
                        }
                        
                    }
                    
                }
            }
                else if let optionArray = dic["multiOptions"] as? NSArray
            {
                    var dic = Dictionary<String, String>()
                    var i = 0;
                    for value in optionArray{
                        dic["\(i)"] = value as? String
                        i += 1
                    }
                    
                    for (key,_) in dic{
                        if dic["\(key)"] == str{
                            return key as String
                        }
                    }
                }
            
        }
    }
    return keyStr
}

func findKeyForValue2(_ str:String,keyName:String)->String
{
    
    //print(str)
    let keyStr = ""
    
    for key in Form
    {
        if let dic = (key as? NSDictionary)
        {
            if dic["name"] as! String == keyName
            {
                if let option = (dic["multiOptions"] as? NSDictionary)
                {
                    for (key,value) in option
                    {
                        if key as! String != ""
                        {
                            if option["\(key)"] as! String == str
                            {
                                
                                return key as! String
                            }
                            
                        }
                        
                    }
                    
                }
                else if let optionArray = dic["multiOptions"] as? NSArray{
                    var dic = Dictionary<String, String>()
                    var i = 0;
                    for value in optionArray{
                        dic["\(i)"] = value as? String
                        i += 1
                    }
                    
                    for (key,_) in dic{
                        if dic["\(key)"] == str{
                            return key as String
                        }
                    }
                }
            }
            
        }
    }
    return keyStr
}

