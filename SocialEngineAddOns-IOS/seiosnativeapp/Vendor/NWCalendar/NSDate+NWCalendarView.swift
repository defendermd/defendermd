//
//  NSDate+NWCalendarView.swift
//  NWCalendarDemo
//
//  Created by Nicholas Wargnier on 7/24/15.
//  Copyright (c) 2015 Nick Wargnier. All rights reserved.
//

import Foundation
import UIKit

extension Date {
  func nwCalendarView_dayWithCalendar(_ calendar: Calendar) -> DateComponents {
    return (calendar as NSCalendar).components([.year, .month, .day, .weekday, .calendar], from: self)
  }
  
  func nwCalendarView_monthWithCalendar(_ calendar: Calendar) -> DateComponents {
    return (calendar as NSCalendar).components([.calendar, .year, .month], from: self)
  }
  
  func nwCalendarView_dayIsInPast() -> Bool {
    return self.timeIntervalSinceNow <= TimeInterval(-86400)
  }
  
}
