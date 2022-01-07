//
//  SegmentedProgressBar.swift
//  seiosnativeapp
//
//  Created by BigStep on 30/08/18.
//  Copyright © 2018 bigstep. All rights reserved.
//

import Foundation
import UIKit

protocol SegmentedProgressBarDelegate: class {
    func segmentedProgressBarChangedIndex(index: Int)
    func segmentedProgressBarChangedIndexOnRewind(index: Int)
    func segmentedProgressBarFinished()
}

class SegmentedProgressBar: UIView {
    
    weak var delegate: SegmentedProgressBarDelegate?
    var topColor = UIColor.gray {
        didSet {
            self.updateColors()
        }
    }
    var bottomColor = UIColor.gray.withAlphaComponent(0.25) {
        didSet {
            self.updateColors()
        }
    }
    var padding: CGFloat = 2.0
    var isPaused: Bool = false {
        didSet {
            if isPaused {
                for segment in segments {
                    let layer = segment.topSegmentView.layer
                    let pausedTime = layer.convertTime(CACurrentMediaTime(), from: nil)
                    layer.speed = 0.0
                    layer.timeOffset = pausedTime
                }
            } else {
                let segment = segments[currentAnimationIndex]
                let layer = segment.topSegmentView.layer
                layer.makeAnimationsPersistent()
                currentSegment = segment
                let pausedTime = layer.timeOffset
                layer.speed = 1.0
                layer.timeOffset = 0.0
                layer.beginTime = 0.0
                let timeSincePause = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
                layer.beginTime = timeSincePause
            }
        }
    }
    
    var segments = [Segment]()
    var duration: TimeInterval = 5
    private var hasDoneLayout = false // hacky way to prevent layouting again
    var currentAnimationIndex = 0
    var currentSegment = Segment()
    init(numberOfSegments: Int, duration: TimeInterval = 5.0) {
        self.duration = duration
        super.init(frame: CGRect.zero)
        
        for _ in 0..<numberOfSegments {
            let segment = Segment()
            addSubview(segment.bottomSegmentView)
            addSubview(segment.topSegmentView)
            segments.append(segment)
        }
        self.updateColors()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if hasDoneLayout {
            return
        }
        let width = (frame.width - (padding * CGFloat(segments.count - 1)) ) / CGFloat(segments.count)
        for (index, segment) in segments.enumerated() {
            let segFrame = CGRect(x: CGFloat(index) * (width + padding), y: 0, width: width, height: frame.height)
            segment.bottomSegmentView.frame = segFrame
            segment.topSegmentView.frame = segFrame
            segment.topSegmentView.frame.size.width = 0
            
//            let cr = frame.height / 2
//            segment.bottomSegmentView.layer.cornerRadius = cr
//            segment.topSegmentView.layer.cornerRadius = cr
        }
        hasDoneLayout = true
    }
    
    func startAnimation() {
        print("startAnimation")
        layoutSubviews()
        animate()
    }
    
    private func animate(animationIndex: Int = 0) {
        if animationIndex != 0
        {
            for seg in 0..<animationIndex
            {
                let currentSegment = segments[seg]
                currentSegment.topSegmentView.frame.size.width = currentSegment.bottomSegmentView.frame.width
                currentSegment.topSegmentView.layer.removeAllAnimations()
            }
        }
        let nextSegment = segments[animationIndex]
        currentAnimationIndex = animationIndex
        self.isPaused = false // no idea why we have to do this here, but it fixes everything :D
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveLinear, animations: {
            nextSegment.topSegmentView.frame.size.width = nextSegment.bottomSegmentView.frame.width
        }) { (finished) in
            if !finished {
                print("animate not finished")
                return
            }
            print("animate finished")
            let newIndex = self.currentAnimationIndex + 1
            if newIndex < self.segments.count {
                self.delegate?.segmentedProgressBarChangedIndex(index: newIndex)
            } else {
                self.delegate?.segmentedProgressBarFinished()
            }
            
        }
    }
    
    private func updateColors() {
        for segment in segments {
            segment.topSegmentView.backgroundColor = topColor
            segment.bottomSegmentView.backgroundColor = bottomColor
        }
    }
    
    func next() {
        let newIndex = self.currentAnimationIndex + 1
        if newIndex < self.segments.count {
            print("next")
            self.animate(animationIndex: newIndex)
        }
    }
    func nextReWind() {
        let newIndex = self.currentAnimationIndex - 1
        if newIndex < self.segments.count {
            if newIndex > 0
            {
                print("nextReWind 1")
                self.animate(animationIndex: newIndex)
            }
            else
            {
                print("nextReWind 2")
                self.animate(animationIndex: 0)
            }
        }
    }
    
    func skip() {
        for seg in 0...currentAnimationIndex
        {
            let currentSegment = segments[seg]
            currentSegment.topSegmentView.frame.size.width = currentSegment.bottomSegmentView.frame.width
            currentSegment.topSegmentView.layer.removeAllAnimations()
        }
//        let currentSegment = segments[currentAnimationIndex]
//        currentSegment.topSegmentView.frame.size.width = currentSegment.bottomSegmentView.frame.width
//        currentSegment.topSegmentView.layer.removeAllAnimations()
        let newIndex = self.currentAnimationIndex + 1
        if newIndex < self.segments.count {
            self.delegate?.segmentedProgressBarChangedIndex(index: newIndex)
        } else {
            self.delegate?.segmentedProgressBarFinished()
        }
    }
    
    func skipCurrent() {
        if currentAnimationIndex < self.segments.count
        {
            let currentSegment = segments[currentAnimationIndex - 1]
            currentSegment.topSegmentView.frame.size.width = currentSegment.bottomSegmentView.frame.width
            currentSegment.topSegmentView.layer.removeAllAnimations()
            self.delegate?.segmentedProgressBarChangedIndex(index: self.currentAnimationIndex)
        
        }
        else
        {
            self.delegate?.segmentedProgressBarFinished()
        }
    
    }

    func rewind() {
        let currentSegment = segments[currentAnimationIndex]
        currentSegment.topSegmentView.layer.removeAllAnimations()
        currentSegment.topSegmentView.frame.size.width = 0
        let newIndex = max(currentAnimationIndex - 1, 0)
        let prevSegment = segments[newIndex]
        prevSegment.topSegmentView.frame.size.width = 0
        self.delegate?.segmentedProgressBarChangedIndexOnRewind(index: newIndex)
        
    }
    func rewindCurrent() {
        let currentSegment = segments[currentAnimationIndex]
        currentSegment.topSegmentView.layer.removeAllAnimations()
        currentSegment.topSegmentView.frame.size.width = 0
        let newIndex = max(currentAnimationIndex, 0)
        let prevSegment = segments[newIndex]
        prevSegment.topSegmentView.frame.size.width = 0
        self.delegate?.segmentedProgressBarChangedIndexOnRewind(index: newIndex)
        
    }
}
class Segment {
    let bottomSegmentView = UIView()
    let topSegmentView = UIView()
    init() {
    }
}
