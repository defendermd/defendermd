//
//  NWCalendarView.swift
//  NWCalendarDemo
//
//  Created by Nicholas Wargnier on 7/23/15.
//  Copyright (c) 2015 Nick Wargnier. All rights reserved.
//

import UIKit

@objc protocol NWCalendarViewDelegate {
  @objc optional func didChangeFromMonthToMonth(_ fromMonth: DateComponents, toMonth: DateComponents)
  @objc optional func didSelectDate(_ fromDate: DateComponents, toDate: DateComponents)
}


open class NWCalendarView: UIView {
  fileprivate let kMenuHeightPercentage:CGFloat = 0.256
  
  weak var delegate: NWCalendarViewDelegate?
  
  var menuView          : NWCalendarMenuView!
  var monthContentView  : NWCalendarMonthContentView!
  var visibleMonth      : DateComponents! {
    didSet {
      updateMonthLabel(visibleMonth)
    }
  }
  
  open var selectionRangeLength: Int? {
    didSet {
      monthContentView.selectionRangeLength = selectionRangeLength
    }
  }
  
  open var disabledDates:[Date]? {
    didSet {
      monthContentView.disabledDates = disabledDates
    }
  }
  
  open var maxMonths: Int? {
    didSet {
      monthContentView.maxMonths = maxMonths
    }
  }
  
  open var selectedDates: [Date]? {
    didSet {
      monthContentView.selectedDates = selectedDates
    }
  }
  
  open var availableDates: [Date]? {
    didSet {
      monthContentView.availableDates = availableDates
    }
  }
  
  // MARK: Initialization
  override public init(frame: CGRect) {
    super.init(frame: frame)
    
    commonInit()
  }
  
  // IB Init
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
   
    commonInit()
  }
  
  func commonInit() {
    clipsToBounds = true
    
    let unitFlags: NSCalendar.Unit = [.year, .month, .day, .weekday, .calendar]
    visibleMonth = (Calendar.usLocaleCurrentCalendar() as NSCalendar).components(unitFlags, from: Date())
    
    visibleMonth.day = 1
    
    let menuHeight = floor(frame.height*kMenuHeightPercentage)
    menuView = NWCalendarMenuView(frame: CGRect(x: 0, y: 0, width: frame.width, height: menuHeight))
    menuView.delegate = self
    
    let monthContentViewHeight = frame.height - menuHeight
    let monthContentViewY = menuView.frame.maxY
    monthContentView = NWCalendarMonthContentView(month: visibleMonth, frame: CGRect(x: 0, y: monthContentViewY, width: frame.width, height: monthContentViewHeight))
    monthContentView.clipsToBounds = true
    monthContentView.monthContentViewDelegate = self
    
    addSubview(menuView)
    addSubview(monthContentView)
    
    updateMonthLabel(visibleMonth)
  }
  
  open func createCalendar() {
    monthContentView.createCalendar()
  }
  
  
  open func scrollToDate(_ date: Date, animated: Bool) {
    let comp = (Calendar.usLocaleCurrentCalendar() as NSCalendar).components([.year, .month, .day, .weekday, .calendar], from: date)
    
    if maxMonths != nil && !monthContentView.monthIsGreaterThanMaxMonth(comp) {
      updateMonthLabel(comp)
      monthContentView.scrollToDate(comp, animated: animated)
    }

  }
}

// MARK - NWCalendarMonthSelectorView
extension NWCalendarView {
  func updateMonthLabel(_ month: DateComponents) {
    if menuView != nil {
      menuView.monthSelectorView.updateMonthLabelForMonth(month)
    }
  }
}


// MARK: - NWCalendarMenuViewDelegate
extension NWCalendarView: NWCalendarMenuViewDelegate {
  func prevMonthPressed() {
    monthContentView.prevMonth()
  }
  
  func nextMonthPressed() {
    monthContentView.nextMonth()
  }
}

// MARK: - NWCalendarMonthContentViewDelegate
extension NWCalendarView: NWCalendarMonthContentViewDelegate {
  func didChangeFromMonthToMonth(_ fromMonth: DateComponents, toMonth: DateComponents) {
    visibleMonth = toMonth
    delegate?.didChangeFromMonthToMonth?(fromMonth, toMonth: toMonth)
  }
  
  func didSelectDate(_ fromDate: DateComponents, toDate: DateComponents) {
    delegate?.didSelectDate?(fromDate, toDate: toDate)
  }
}
