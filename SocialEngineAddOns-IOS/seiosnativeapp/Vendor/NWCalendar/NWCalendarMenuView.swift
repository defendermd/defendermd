//
//  NWCalendarMenuView.swift
//  NWCalendarDemo
//
//  Created by Nicholas Wargnier on 7/23/15.
//  Copyright (c) 2015 Nick Wargnier. All rights reserved.
//

import UIKit

protocol NWCalendarMenuViewDelegate {
  func prevMonthPressed()
  func nextMonthPressed()
}

class NWCalendarMenuView: UIView {
  fileprivate let kDayColor = UIColor(red:0.475, green:0.475, blue:0.475, alpha: 1)

  fileprivate let kDayFont  = UIFont.init(name: "Avenir-Roman", size: 14)

  
  var delegate         : NWCalendarMenuViewDelegate?
  var monthSelectorView: NWCalendarMonthSelectorView!
  var days             : [String]  = []
  var sectionHeight    : CGFloat {
    return frame.height/2
  }
  
  init() {
    super.init(frame: .zero)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = UIColor.white

    monthSelectorView = NWCalendarMonthSelectorView(frame: CGRect(x: 0, y: 0, width: frame.width, height: sectionHeight))
    monthSelectorView.prevButton.addTarget(self, action: #selector(NWCalendarMenuView.prevMonthPressed(_:)), for: .touchUpInside)
    monthSelectorView.nextButton.addTarget(self, action: #selector(NWCalendarMenuView.nextMonthPressed(_:)), for: .touchUpInside)
    addSubview(monthSelectorView)
    
    setupDays()
    setupDayLabels()
  }
  
  func setupDays() {
    let dateFormatter = DateFormatter()
    days = dateFormatter.shortWeekdaySymbols as [String]
  }
  
  
  func setupDayLabels() {
    let width = frame.width / 7
    let height = sectionHeight
    
    var x:CGFloat = 0
    let y:CGFloat = monthSelectorView.frame.maxY
    
    for i in 0..<7 {
      x = CGFloat(i) * width
      createDayLabel(x, y: y, width: width, height: height, day: days[i])
    }
    
  }
  
  func createDayLabel(_ x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, day: String) {
    let dayLabel = UILabel(frame: CGRect(x: x, y: y, width: width, height: height))
    dayLabel.textAlignment = .center
    dayLabel.text = day.uppercased()
    dayLabel.font = kDayFont
    dayLabel.textColor = kDayColor
    addSubview(dayLabel)
  }
  
}


// MARK: NWCalendarMonthSelectorView Actions
extension NWCalendarMenuView {
  @objc func prevMonthPressed(_ sender: AnyObject) {
    delegate?.prevMonthPressed()
  }
  
  @objc func nextMonthPressed(_ sender: AnyObject) {
    delegate?.nextMonthPressed()
  }
}
