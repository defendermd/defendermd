//
//  MyStoryCell.swift
//  seiosnativeapp
//
//  Created by BigStep on 08/08/18.
//  Copyright © 2018 bigstep. All rights reserved.
//

import UIKit
import KYCircularProgress

class MyStoryCell: UICollectionViewCell {

    @IBOutlet weak var imgStory: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewCircular: KYCircularProgress!
    @IBOutlet weak var btnStoryAction: UIButton!
    @IBOutlet weak var viewStory: UIView!
    var timer = Timer()
    var progress: UInt8 = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }

    func animateStopCircularView()
    {
       timer.invalidate()
       viewCircular.isHidden = true
        
        viewStory.layer.borderWidth = 1.5
        viewStory.layer.borderColor = navColor.cgColor
    }
    func animateStartCircularView()
    {
        viewStory.layer.borderWidth = 0
        viewStory.layer.borderColor = UIColor.blue.cgColor
        viewCircular.isHidden = false
        timer = Timer.scheduledTimer(timeInterval: 0.015, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
    }
    @objc func updateProgress() {
        progress = progress &+ 1
        let normalizedProgress = Double(progress) / Double(UInt8.max)
        viewCircular.progress = normalizedProgress
  }
    
}
