import UIKit
import Foundation

class NWCalendarMonthSelectorView: UIView {
  fileprivate let kPrevButtonImage:UIImage! = UIImage(named: "NWCalendar-prev-month")
  fileprivate let kNextButtonImage:UIImage! = UIImage(named: "NWCalendar-next-month")
  fileprivate let kMonthColor:UIColor!      = UIColor(red:0.475, green:0.475, blue:0.475, alpha: 1)
  fileprivate let kMonthFont:UIFont!        = UIFont(name: "Avenir-Medium", size: 16)
  fileprivate let kSeperatorColor:UIColor!  = UIColor(red:0.973, green:0.973, blue:0.973, alpha: 1)
  fileprivate let kSeperatorWidth:CGFloat!  = 1.5
  
  var prevButton: UIButton!
  var nextButton: UIButton!
  var monthLabel: UILabel!
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    let buttonWidth = floor(frame.width/7)
    prevButton = UIButton(frame: CGRect(x: 0, y: 0, width: buttonWidth, height: frame.height))
    prevButton.setImage(kPrevButtonImage, for: UIControl.State())

    nextButton = UIButton(frame: CGRect(x: frame.width-buttonWidth, y: 0, width: buttonWidth, height: frame.height))
    nextButton.setImage(kNextButtonImage, for: UIControl.State())

    monthLabel = UILabel(frame: CGRect(x: buttonWidth, y: 0, width: frame.width-(2*buttonWidth), height: frame.height))
    monthLabel.textAlignment = .center
    monthLabel.textColor = kMonthColor
    monthLabel.font = kMonthFont
    monthLabel.text = "January 2015"
    
    addSubview(prevButton)
    addSubview(nextButton)
    addSubview(monthLabel)
    
    addSeperator(0)
    addSeperator(frame.height-kSeperatorWidth)
  }
  
  
  fileprivate func addSeperator(_ y: CGFloat) {
    let seperator = CALayer()
    seperator.backgroundColor = kSeperatorColor.cgColor
    seperator.frame = CGRect(x: 0, y: y, width: frame.width, height: kSeperatorWidth)
    layer.addSublayer(seperator)
  }
}

extension NWCalendarMonthSelectorView {
  func updateMonthLabelForMonth(_ month: DateComponents) {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM yyyy"
    let date = (month as NSDateComponents).calendar?.date(from: month)
    monthLabel.text = formatter.string(from: date!)
  }
}
