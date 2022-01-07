//
//  NWCalendarDayView.swift
//  NWCalendarDemo
//
//  Created by Nicholas Wargnier on 7/24/15.
//  Copyright (c) 2015 Nick Wargnier. All rights reserved.
//

import Foundation
import UIKit

protocol NWCalendarDayViewDelegate {
  func dayButtonPressed(_ dayView: NWCalendarDayView)
}

class NWCalendarDayView: UIView {

  fileprivate let kDayFont             = UIFont.init(name: "Avenir-Roman", size: 14)
  fileprivate let kAvailableColor      = UIColor(red:0.475, green:0.475, blue:0.475, alpha: 1)
  fileprivate let kNotAvailableColor   = UIColor(red:0.890, green:0.890, blue:0.890, alpha: 1)
  fileprivate let kNonActiveMonthColor = UIColor(red:0.949, green:0.949, blue:0.949, alpha: 1)
  fileprivate let kActiveMonthColor    = UIColor.white
  fileprivate let kSelectedColor       = UIColor(red: 226.0/255.0, green: 226.0/255.0, blue: 226.0/255.0, alpha: 1.0)//UIColor(red:0.988, green:0.325, blue:0.341, alpha: 1)
  fileprivate let kcurrendate = UIColor(red: 192.0/255.0, green: 38.0/255.0, blue: 42.0/255.0, alpha: 1.0)
  var delegate : NWCalendarDayViewDelegate?
  var dayLabel : UILabel!
  var dayButton: UIButton!
  var date     : Date? {
    didSet {
      if let unwrappedDate = date {
        if unwrappedDate.nwCalendarView_dayIsInPast() {
          isInPast = true
        }
      }
    }
  }
  
  var day: DateComponents? {
    didSet {      
        date = (day as NSDateComponents?)?.date
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date!)

        let  currentdate = Date()
        let dateString1 = dateFormatter.string(from: currentdate)
        
        if dateString1 == dateString
        {
            dayButton.setTitle("\(day!.day!)", for: UIControl.State())
            backgroundColor = kSelectedColor
            dayButton.setTitleColor(UIColor.blue, for: UIControl.State())
            dayButton.setTitleColor(UIColor.blue, for: .disabled)

        }
        else
        {
         dayButton.setTitle("\(day!.day!)", for: UIControl.State())
        }
      
 
    }
  }
  
  var isActiveMonth = false {
    didSet {
      setNotSelectedBackgroundColor()
    }
  }
  
  var isInPast = false {
    didSet {
      isEnabled = true//!isInPast
    } 
  }
  
  var isEnabled = true {
    didSet {
      dayButton.isEnabled = isEnabled
    }
  }
  
    var isSelected = false
    {
    didSet
    {
      if isSelected
      {
        backgroundColor = kSelectedColor
        dayButton.setTitleColor(UIColor.white, for: UIControl.State())
        dayButton.setTitleColor(UIColor.white, for: .disabled)
      }
      else
      {
        setNotSelectedBackgroundColor()
        dayButton.setTitleColor(kAvailableColor, for: UIControl.State())
        dayButton.setTitleColor(kNotAvailableColor, for: .disabled)
      }
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = kNonActiveMonthColor
    
    dayButton = UIButton(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
    dayButton.titleLabel?.textAlignment = .center
    dayButton.titleLabel?.font = kDayFont
    dayButton.setTitleColor(kAvailableColor, for: UIControl.State())
    dayButton.setTitleColor(kNotAvailableColor, for: .disabled)
    dayButton.addTarget(self, action: #selector(NWCalendarDayView.dayButtonPressed(_:)), for: .touchUpInside)
    addSubview(dayButton)
  }

  @objc func dayButtonPressed(_ sender: AnyObject)
  {
    if isSelected
    {
      delegate?.dayButtonPressed(self)
    }
  }
  
  func setDayForDay(_ day: DateComponents)
  {
    self.day = (day as NSDateComponents).date!.nwCalendarView_dayWithCalendar((day as NSDateComponents).calendar!)
  }
  
  func setNotSelectedBackgroundColor()
  {
    if !isSelected
    {
      if isActiveMonth
      {
        backgroundColor = kActiveMonthColor
      }
      else
      {
        backgroundColor = kNonActiveMonthColor
      }
    }
  }
}
