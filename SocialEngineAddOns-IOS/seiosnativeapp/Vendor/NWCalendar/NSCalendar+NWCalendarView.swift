//
//  NSCalendar+NWCalendarView.swift
//  NWCalendarDemo
//
//  Created by Nicholas Wargnier on 12/1/15.
//  Copyright © 2015 Nick Wargnier. All rights reserved.
//

import Foundation
import UIKit

extension Calendar {
  static func usLocaleCurrentCalendar() -> Calendar {
    let us = Locale(identifier: "en_US")
    var calendar = Calendar.current
    calendar.locale = us
    return calendar
  }
}
