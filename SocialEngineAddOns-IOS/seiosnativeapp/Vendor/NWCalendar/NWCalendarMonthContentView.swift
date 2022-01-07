//
//  NWCalendarMonthContentView.swift
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

fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l <= r
    default:
        return !(rhs < lhs)
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



protocol NWCalendarMonthContentViewDelegate {

  func didChangeFromMonthToMonth(_ fromMonth: DateComponents, toMonth: DateComponents)
  func didSelectDate(_ fromDate: DateComponents, toDate: DateComponents)

}

class NWCalendarMonthContentView: UIScrollView {
    fileprivate let unitFlags: NSCalendar.Unit = [.year, .month, .day, .weekday, .calendar]
    fileprivate let kCurrentMonthOffset = 50
    
    var monthContentViewDelegate:NWCalendarMonthContentViewDelegate?
    
    var presentMonth         : DateComponents!
    var monthViewsDict   = Dictionary<String, NWCalendarMonthView>()
    var monthViews    : [NWCalendarMonthView] = []
    
    var dayViewHeight       : CGFloat             = 44
    var pastEnabled                               = true
    var presentMonthIndex   : Int!                = 0
    var selectionRangeLength: Int!                = 0
    var selectedDayViews    : [NWCalendarDayView] = []
    var lastMonthOrigin     : CGFloat?
    
    var maxMonth            : DateComponents?
    var maxMonths           : Int! = 0 {
        didSet {
            if maxMonths > 0 {
                let date = (Calendar.usLocaleCurrentCalendar() as NSCalendar).date(byAdding: .month, value: maxMonths, to: presentMonth.date!, options: [])!
                let month = date.nwCalendarView_monthWithCalendar(presentMonth.calendar!)
                maxMonth = month
            }
        }
    }
    var futureEnabled: Bool {
        return maxMonths == 0
    }
    
    var disabledDatesDict: [String: [DateComponents]] = [String: [DateComponents]]()
    var disabledDates:[Date]? {
        didSet {
            if let dates = disabledDates {
                for date in dates {
                    let comp = (Calendar.usLocaleCurrentCalendar() as NSCalendar).components([.year, .month, .day, .weekday, .calendar], from: date)
                    let key = monthViewKeyForMonth(comp)
                    if var compArray = disabledDatesDict[key] {
                        compArray.append(comp)
                        disabledDatesDict[key] = compArray
                    } else {
                        let compArray:[DateComponents] = [comp]
                        disabledDatesDict[key] = compArray
                    }
                }
            }
        }
    }
    
    var selectedDatesDict: [String: [DateComponents]] = [String: [DateComponents]]()
    var selectedDates: [Date]? {
        didSet {
            if let dates = selectedDates {
                for date in dates {
                    let comp = (Calendar.usLocaleCurrentCalendar() as NSCalendar).components([.year, .month, .day, .weekday, .calendar], from: date)
                    let key = monthViewKeyForMonth(comp)
                    if var compArray = selectedDatesDict[key] {
                        compArray.append(comp)
                        selectedDatesDict[key] = compArray
                    } else {
                        let compArray:[DateComponents] = [comp]
                        selectedDatesDict[key] = compArray
                    }
                }
            }
        }
    }
    
    var showOnlyAvailableDates = false
    var availableDatesDict: [String: [DateComponents]] = [String: [DateComponents]]()
    var availableDates: [Date]? {
        didSet {
            if let dates = availableDates {
                showOnlyAvailableDates = true
                for date in dates {
                    let comp = (Calendar.usLocaleCurrentCalendar() as NSCalendar).components([.year, .month, .day, .weekday, .calendar], from: date)
                    let key = monthViewKeyForMonth(comp)
                    if var compArray = availableDatesDict[key] {
                        compArray.append(comp)
                        availableDatesDict[key] = compArray
                    } else {
                        let compArray:[DateComponents] = [comp]
                        availableDatesDict[key] = compArray
                    }
                }
            }

        }
    }
    
    var currentMonthView: NWCalendarMonthView!
    {
        return monthViews[currentPage]
    }
    
    
    var monthViewOrigins: [CGFloat] = []
    var currentPage:Int!
        {

        didSet(oldPage)
        {

            if currentPage == oldPage
            {
                return
                
            }
            let oldMonthView = monthViews[oldPage]
            
            monthContentViewDelegate?.didChangeFromMonthToMonth(oldMonthView.month as DateComponents, toMonth: currentMonthView.month as DateComponents)
            UIView.animate(withDuration: 0.3, animations: {
                self.currentMonthView.isCurrentMonth = true
                oldMonthView.isCurrentMonth = false
            })
            
            if oldPage < currentPage
            {
                appendMonthIfNeeded()
            }
            else
            {
                // TODO: Prepend for past
                
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        delegate = self
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        decelerationRate = UIScrollView.DecelerationRate.fast
        presentMonthIndex = kCurrentMonthOffset
        dayViewHeight = frame.height / 6
        currentPage = kCurrentMonthOffset
        
    }
    
    convenience init(month: DateComponents, frame: CGRect) {
        self.init(frame: frame)
        presentMonth = month
    }
    
    func createCalendar() {
        setupMonths(presentMonth)
    }
    
    func setupMonths(_ month: DateComponents)
    {
        for monthOffset in stride(from: -kCurrentMonthOffset, through: 7, by: 1){
            var offsetMonth = (month as NSDateComponents).copy() as! DateComponents
            offsetMonth.month = offsetMonth.month! + monthOffset
            
            
            offsetMonth = ((offsetMonth as NSDateComponents).calendar! as NSCalendar).components(unitFlags, from: (offsetMonth as NSDateComponents).date!)
            createMonthViewForMonth(offsetMonth)
        }
        
        
        scrollToOffset(monthViewOrigins[kCurrentMonthOffset], animated: false)

    }
    
}

// MARK: - Navigation
extension NWCalendarMonthContentView
{
    func nextMonth()
    {
        if !futureEnabled && lastMonthOrigin != nil
        {
            if monthViewOrigins[currentPage+1] <= lastMonthOrigin
            {
                currentPage = currentPage+1
                scrollToOffset(monthViewOrigins[currentPage], animated:true)
            }
        }
        else
        {
            let totalMonths = monthViews.count-1
            currentPage = min(currentPage+1, totalMonths)
            scrollToOffset(monthViewOrigins[currentPage], animated:true)
        }
        
    }
    
    func prevMonth()
    {
        currentPage = currentPage-1
        pastEnabled = true
        scrollToOffset(monthViewOrigins[currentPage], animated:true)
    }
    
    func scrollToOffset(_ yOffset: CGFloat, animated: Bool)
    {
        setContentOffset(CGPoint(x: 0, y: yOffset), animated: animated)
    }

    func scrollToDate(_ dateComps: DateComponents, animated: Bool)
    {

        let key = monthViewKeyForMonth(dateComps)
        
        if let monthView = monthViewsDict[key]
        {
            if let index = monthViews.index(of: monthView)
            {
                //        if monthViewOrigins[index] <= lastMonthOrigin
                //        {
                currentPage = index
                scrollToOffset(monthViewOrigins[currentPage], animated: animated)
                //}
            }
        }
    }

}

// MARK: - Layout
extension NWCalendarMonthContentView {

    func createMonthViewForMonth(_ month: DateComponents) {
        var overlapOffset:CGFloat = 0
        var lastMonthMaxY:CGFloat = 0
        if monthViews.count > 0 {
            let lastMonthView = monthViews[monthViews.count-1]
            lastMonthMaxY = lastMonthView.frame.maxY
            
            if lastMonthView.numberOfWeeks == 6 || monthStartsOnFirstDayOfWeek(month) {
                overlapOffset = dayViewHeight
            } else {
                overlapOffset = dayViewHeight * 2
            }
        }
        
        // Create & Position Month View
        let monthView = cachedOrCreateMonthViewForMonth(month)
        
        monthView.frame.origin.y = lastMonthMaxY - overlapOffset
        monthViewOrigins.append(monthView.frame.origin.y)
        
        contentSize.height = lastMonthMaxY
        
        if !futureEnabled {
            if monthIsEqualToMaxMonth(monthView.month as DateComponents) {
                lastMonthOrigin = monthView.frame.origin.y
            } else if monthIsGreaterThanMaxMonth(monthView.month as DateComponents) {
                monthView.disableMonth()
            }
            
        }
        
        
        if monthIsEqualToPresentMonth(month) {
            monthView.isCurrentMonth = true
        }
        
        let key = monthViewKeyForMonth(month)
        if let disabledArray = disabledDatesDict[key] {
            monthView.disabledDates = disabledArray
        }
        
        if let availableArray = availableDatesDict[key] {
            monthView.availableDates = availableArray
        } else if showOnlyAvailableDates {
            monthView.availableDates = []
        }
        
        if let selectedArray = selectedDatesDict[key] {
            monthView.selectedDates = selectedArray
        }


    }
    
    func appendMonthIfNeeded() {
        if currentPage >= monthViews.count - 3 {
            var newMonth = monthViews.last?.copy() as! DateComponents
            newMonth.month = newMonth.month! + 1
            createMonthViewForMonth((newMonth as NSDateComponents).date!.nwCalendarView_monthWithCalendar((newMonth as NSDateComponents).calendar!))
        }
    }
    
    func monthIsEqualToPresentMonth(_ month: DateComponents) -> Bool {
        return month.month == presentMonth.month && month.year == presentMonth.year
    }
    
    func monthIsGreaterThanMaxMonth(_ month: DateComponents) -> Bool {
        return month.year > maxMonth?.year || (month.month > maxMonth?.month && maxMonth?.year <= month.year)
    }
    
    func monthIsEqualToMaxMonth(_ month: DateComponents) -> Bool {
        return maxMonth!.month == month.month && maxMonth!.year == month.year
    }


}

// MARK: - Caching
extension NWCalendarMonthContentView {

    func monthStartsOnFirstDayOfWeek(_ month: DateComponents) -> Bool{
        let month = ((month as NSDateComponents).calendar! as NSCalendar).components(unitFlags, from: (month as NSDateComponents).date!)
        return (month.weekday! - (month as NSDateComponents).calendar!.firstWeekday) == 0
    }
    
    func monthViewKeyForMonth(_ month: DateComponents) -> String {
        let month = ((month as NSDateComponents).calendar as NSCalendar?)?.components([.year, .month], from: (month as NSDateComponents).date!)
        return "\(String(describing: month!.year)).\(String(describing: month!.month))"
    }
    
    func cachedOrCreateMonthViewForMonth(_ month: DateComponents) -> NWCalendarMonthView {
        let month = ((month as NSDateComponents).calendar as NSCalendar?)?.components(unitFlags, from: (month as NSDateComponents).date!)
        let monthViewKey = monthViewKeyForMonth(month!)
        var monthView = monthViewsDict[monthViewKey]
        
        if monthView == nil {
            monthView = NWCalendarMonthView(month: month!, width: bounds.width, height: bounds.height)
            monthViewsDict[monthViewKey] = monthView
            monthViews.append(monthView!)
            monthView?.delegate = self
            addSubview(monthView!)
        }
        
        return monthView!
        
    }
}


// MARK: - UIScrollViewDelegate
extension NWCalendarMonthContentView: UIScrollViewDelegate {


    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // Disable scrolling to past
        if !pastEnabled {
            let presentMonthOrigin = monthViewOrigins[presentMonthIndex]
            if scrollView.contentOffset.y < presentMonthOrigin{
                setContentOffset(CGPoint(x: 0, y: presentMonthOrigin), animated: false)
            }

        }
        
        // Disable scrolling to future beyond max month
        if !futureEnabled && lastMonthOrigin != nil {
            if scrollView.contentOffset.y > lastMonthOrigin {
                setContentOffset(CGPoint(x: 0, y: lastMonthOrigin!), animated: false)
            }
        }
        

    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let currentOrigin = monthViewOrigins[currentPage]
        
        var targetOffset = targetContentOffset.pointee.y
        
        if targetOffset < currentOrigin-dayViewHeight {
            currentPage = (pastEnabled == false) ? max(currentPage-1, presentMonthIndex) : max(currentPage-1, 0) as Int?
            targetOffset = monthViewOrigins[currentPage]
        } else if targetOffset > currentOrigin+dayViewHeight {
            
            if !futureEnabled && lastMonthOrigin != nil {
                if monthViewOrigins[currentPage+1] <= lastMonthOrigin {
                    currentPage = currentPage+1
                }
            } else {
                currentPage = min(currentPage+1, monthViews.count-1)
            }
            
            targetOffset = monthViewOrigins[currentPage]
        } else {
            targetOffset = currentOrigin
        }
        
        targetContentOffset.pointee = CGPoint(x: 0, y: targetOffset)
    }

}


// MARK: - NWCalendarMonthViewDelegate
extension NWCalendarMonthContentView: NWCalendarMonthViewDelegate {
    func didSelectDay(_ dayView: NWCalendarDayView, notifyDelegate: Bool) {
        if selectionRangeLength > 0 {
            
            var day = (dayView.day as NSDateComponents?)?.copy() as! DateComponents
            
            for _ in 0..<selectionRangeLength {
                day = (day as NSDateComponents).date!.nwCalendarView_dayWithCalendar((day as NSDateComponents).calendar!)
                let month = (day as NSDateComponents).date!.nwCalendarView_monthWithCalendar((day as NSDateComponents).calendar!)
                let monthViewKey = monthViewKeyForMonth(month)
                let monthView = monthViewsDict[monthViewKey]
                let dayView = monthView?.dayViewForDay(day)
                
                if let unwrappedDayView = dayView {
                    selectDay(unwrappedDayView)
                }
                
                
                day.day = day.day! + 1
            }
            
            
            day.day = day.day! - 1
            day = (day as NSDateComponents).date!.nwCalendarView_dayWithCalendar((day as NSDateComponents).calendar!)
            
            if notifyDelegate {
                changeMonthIfNeeded(dayView.day! as DateComponents, toDay: day)
                monthContentViewDelegate?.didSelectDate(dayView.day! as DateComponents, toDate: day)
            }
            
        }
    }
    
    func selectDay(_ dayView: NWCalendarDayView) {
        dayView.isSelected = true
        selectedDayViews.append(dayView)
    }
    
    

    
    func changeMonthIfNeeded(_ fromDay: DateComponents, toDay: DateComponents) {
        if fromDay.month < currentMonthView.month.month && fromDay.year <= currentMonthView.month.year{
            prevMonth()
        } else if fromDay.month! > currentMonthView.month.month! && fromDay.year! >= currentMonthView.month.year! {
            nextMonth()
        } else if fromDay.year > currentMonthView.month.year {
            nextMonth()
        } else if fromDay.year < currentMonthView.month.year {
            prevMonth()
        }
    }
    

}


