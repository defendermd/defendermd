//
//  NWCalendarMonthView.swift
//  NWCalendarDemo
//
//  Created by Nicholas Wargnier on 7/24/15.
//  Copyright (c) 2015 Nick Wargnier. All rights reserved.
//

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

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}

fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l <= r
    default:
        return !(rhs < lhs)
    }
}



protocol NWCalendarMonthViewDelegate {

    func didSelectDay(_ dayView: NWCalendarDayView, notifyDelegate: Bool)
    func selectDay(_ dayView: NWCalendarDayView)
}

class NWCalendarMonthView: UIView {
    fileprivate let kRowCount: CGFloat     = 6
    fileprivate let kNumberOfDaysPerWeek   = 7
    
    var delegate: NWCalendarMonthViewDelegate?
    
    var month        : DateComponents!
    var dayViewHeight: CGFloat!
    var columnWidths :[CGFloat]?
    var numberOfWeeks: Int!
    
    var dayViewsDict = Dictionary<String, NWCalendarDayView>()
    
    var dayViews:Set<NWCalendarDayView> {
        return Set(dayViewsDict.values)

    }
    
    var isCurrentMonth: Bool! = false {
        didSet {
            if isCurrentMonth == true {
                for dayView in dayViews {
                    dayView.isActiveMonth = true
                }
                
            } else {
                for dayView in dayViews {
                    dayView.isActiveMonth = false
                }
                
            }
        }
    }
    
    var disabledDates:[DateComponents]? {
        didSet {
            if let dates = disabledDates {
                for disabledDate in dates {
                    let key = dayViewKeyForDay(disabledDate)
                    let dayView = dayViewsDict[key]
                    dayView?.isEnabled = false
                }
            }

        }

    }
    
    var availableDates:[DateComponents]? {
        didSet {
            if let availableDates = self.availableDates {
                for dayView in dayViews {
                    if availableDates.contains(dayView.day! as DateComponents) {
                        dayView.isEnabled = true
                    } else {
                        dayView.isEnabled = false
                    }
                }
            }
        }
    }
    
    var selectedDates:[DateComponents]? {
        didSet {
            if let dates = selectedDates {
                for selectedDate in dates {
                    let key = dayViewKeyForDay(selectedDate)
                    if let dayView = dayViewsDict[key] {
                        delegate?.selectDay(dayView)
                    }
                    
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(month: DateComponents, width: CGFloat, height: CGFloat) {
        self.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
        backgroundColor = UIColor.clear
        dayViewHeight = frame.height/kRowCount
        self.month = month
        calculateColumnWidths()
        createDays()
        numberOfWeeks = ((month as NSDateComponents).calendar! as NSCalendar).range(of: .weekOfMonth, in: .month, for: (month as NSDateComponents).date!).length
    }
    
    func disableMonth() {
        for dayView in dayViews {
            dayView.isEnabled = false
        }

    }
    
    func dayViewForDay(_ day: DateComponents) -> NWCalendarDayView? {
        let dayViewKey = dayViewKeyForDay(day)
        return dayViewsDict[dayViewKey]
    }
    

}

// MARK: - Layout
extension NWCalendarMonthView {
    func createDays() {
        var day = DateComponents()
        day.calendar = month.calendar
        day.day = 1
        day.month = month.month
        day.year = month.year
        
        
        let firstDate = day.calendar?.date(from: day)
        day = firstDate!.nwCalendarView_dayWithCalendar(month.calendar!)
        
        let numberOfDaysInMonth = ((day as NSDateComponents).calendar as NSCalendar?)?.range(of: .day, in: .month, for: (day as NSDateComponents).date!).length
        
        var startColumn = day.weekday! - (day as NSDateComponents).calendar!.firstWeekday
        if startColumn < 0 {
            startColumn += kNumberOfDaysPerWeek

        }
        
        var nextDayViewOrigin = CGPoint.zero
        for column in 0 ..< startColumn {
            nextDayViewOrigin.x += columnWidths![column]
        }


        repeat {
            for column in startColumn ..< kNumberOfDaysPerWeek {
                if day.month == month.month {
                    let dayView = createDayView(nextDayViewOrigin, width: columnWidths![column])
                    dayView.delegate = self
                    dayView.setDayForDay(day)
                    let dayViewKey = dayViewKeyForDay(day)
                    dayViewsDict[dayViewKey] = dayView
                    addSubview(dayView)
                }
                
                day.day = day.day! + 1
                
                nextDayViewOrigin.x += columnWidths![column]
                
                if day.day > numberOfDaysInMonth {
                    break
                }
            }
            
            nextDayViewOrigin.x = 0
            nextDayViewOrigin.y += dayViewHeight
            startColumn = 0
        } while (day.day <= numberOfDaysInMonth)
        
    }
    
    func createDayView(_ origin: CGPoint, width: CGFloat)-> NWCalendarDayView {
        var dayFrame = CGRect.zero
        dayFrame.origin = origin
        dayFrame.size.width = width
        dayFrame.size.height = dayViewHeight

        return NWCalendarDayView(frame: dayFrame)
    }
    
    func calculateColumnWidths() {
        columnWidths = NWCalendarCache.sharedCache.objectForKey(kNumberOfDaysPerWeek as AnyObject) as? [CGFloat]
        if columnWidths == nil {
            let columnCount:CGFloat = CGFloat(kNumberOfDaysPerWeek)
            let width      :CGFloat = floor(bounds.size.width / CGFloat(columnCount))
            var remainder  :CGFloat = bounds.size.width - (width * CGFloat(columnCount))
            var padding    :CGFloat = 1
            
            columnWidths = [CGFloat](repeating: width, count: kNumberOfDaysPerWeek)
            
            if remainder > columnCount {
                padding = ceil(remainder/columnCount)
            }
            
            
            for (index, _) in (columnWidths!).enumerated() {
                columnWidths![index] = width + padding
                
                remainder -= padding
                if remainder < 1 {
                    break
                }
            }
            NWCalendarCache.sharedCache.setObjectForKey(columnWidths! as AnyObject, key: kNumberOfDaysPerWeek as AnyObject)
        }
        
    }
    
    func dayViewKeyForDay(_ day: DateComponents) -> String {
        return String(day.month!) + "/" + String(day.day!) + "/" + String(day.year!)
    }

}

// MARK: - Touch Handling
extension NWCalendarMonthView {

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in subviews {
            if !subview.isHidden && subview.alpha > 0 && subview.isUserInteractionEnabled && subview.point(inside: convert(point, to: subview), with: event) {
                return true
            }
        }
        return false

    }
}

// MARK: - NWCalendarDayViewDelegate
extension NWCalendarMonthView: NWCalendarDayViewDelegate {

    func dayButtonPressed(_ dayView: NWCalendarDayView) {
        delegate?.didSelectDay(dayView, notifyDelegate: true)
    }

}
