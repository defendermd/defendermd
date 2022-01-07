//
//  MarqueeLabel.swift
//
//  Created by Charles Powell on 8/6/14.
//  Copyright (c) 2015 Charles Powell. All rights reserved.
//

import UIKit
import QuartzCore


open class MarqueeLabel: UILabel, CAAnimationDelegate {
    
    /**
     An enum that defines the types of `MarqueeLabel` scrolling
     
     - LeftRight: Scrolls left first, then back right to the original position.
     - RightLeft: Scrolls right first, then back left to the original position.
     - Continuous: Continuously scrolls left (with a pause at the original position if animationDelay is set).
     - ContinuousReverse: Continuously scrolls right (with a pause at the original position if animationDelay is set).
     */
    public enum `Type` {
        case leftRight
        case rightLeft
        case continuous
        case continuousReverse
    }
    
    //
    // MARK: - Public properties
    //
    
    /**
    Defines the direction and method in which the `MarqueeLabel` instance scrolls.
    `MarqueeLabel` supports four types of scrolling: `MLLeftRight`, `MLRightLeft`, `MLContinuous`, and `MLContinuousReverse`.
    
    Given the nature of how text direction works, the options for the `marqueeType` property require specific text alignments
    and will set the textAlignment property accordingly.
    
    - `MLLeftRight` type is ONLY compatible with a label text alignment of `NSTextAlignmentLeft`.
    - `MLRightLeft` type is ONLY compatible with a label text alignment of `NSTextAlignmentRight`.
    - `MLContinuous` does not require a text alignment (it is effectively centered).
    - `MLContinuousReverse` does not require a text alignment (it is effectively centered).
    
    Defaults to `MLContinuous`.
    
    - SeeAlso: Type
    - SeeAlso: textAlignment
    */
    open var type: Type = .continuous {
        didSet {
            if type == oldValue {
                return
            }
            updateAndScroll()
        }
    }
    
    /**
     Specifies the animation curve used in the scrolling motion of the labels.
     Allowable options:
     
     - `UIViewAnimationOptionCurveEaseInOut`
     - `UIViewAnimationOptionCurveEaseIn`
     - `UIViewAnimationOptionCurveEaseOut`
     - `UIViewAnimationOptionCurveLinear`
     
     Defaults to `UIViewAnimationOptionCurveEaseInOut`.
     */
    open var animationCurve: UIView.AnimationCurve = .linear
    
    /**
     A boolean property that sets whether the `MarqueeLabel` should behave like a normal `UILabel`.
     
     When set to `true` the `MarqueeLabel` will behave and look like a normal `UILabel`, and  will not begin any scrolling animations.
     Changes to this property take effect immediately, removing any in-flight animation as well as any edge fade. Note that `MarqueeLabel`
     will respect the current values of the `lineBreakMode` and `textAlignment`properties while labelized.
     
     To simply prevent automatic scrolling, use the `holdScrolling` property.
     
     Defaults to `false`.
     
     - SeeAlso: holdScrolling
     - SeeAlso: lineBreakMode
     @warning The label will not automatically scroll when this property is set to `YES`.
     @warning The UILabel default setting for the `lineBreakMode` property is `NSLineBreakByTruncatingTail`, which truncates
     the text adds an ellipsis glyph (...). Set the `lineBreakMode` property to `NSLineBreakByClipping` in order to avoid the
     ellipsis, especially if using an edge transparency fade.
     */
    @IBInspectable open var labelize: Bool = false {
        didSet {
            if labelize != oldValue {
                updateAndScroll()
            }
        }
    }
    
    /**
     A boolean property that sets whether the `MarqueeLabel` should hold (prevent) automatic label scrolling.
     
     When set to `true`, `MarqueeLabel` will not automatically scroll even its text is larger than the specified frame,
     although the specified edge fades will remain.
     
     To set `MarqueeLabel` to act like a normal UILabel, use the `labelize` property.
     
     Defaults to `false`.
     
     - SeeAlso: labelize
     @warning The label will not automatically scroll when this property is set to `YES`.
     */
    @IBInspectable open var holdScrolling: Bool = false {
        didSet {
            if holdScrolling != oldValue {
                if oldValue == true && !(awayFromHome || labelize || tapToScroll ) && labelShouldScroll() {
                    beginScroll()
                }
            }
        }
    }
    
    /**
     A boolean property that sets whether the `MarqueeLabel` should only begin a scroll when tapped.
     
     If this property is set to `true`, the `MarqueeLabel` will only begin a scroll animation cycle when tapped. The label will
     not automatically being a scroll. This setting overrides the setting of the `holdScrolling` property.
     
     Defaults to `false`.
     
     @warning The label will not automatically scroll when this property is set to `false`.
     - SeeAlso: holdScrolling
     */
    @IBInspectable open var tapToScroll: Bool = false {
        didSet {
            if tapToScroll != oldValue {
                if tapToScroll {
//                    let tapRecognizer = UITapGestureRecognizer(target: self, action: Selector(MarqueeLabel.labelWasTapped()))
//                    self.addGestureRecognizer(tapRecognizer)
                    isUserInteractionEnabled = true
                } else {
                    if let recognizer = self.gestureRecognizers!.first as UIGestureRecognizer? {
                        self.removeGestureRecognizer(recognizer)
                    }
                    isUserInteractionEnabled = false
                }
            }
        }
    }
    
    /**
     A read-only boolean property that indicates if the label's scroll animation has been paused.
     
     - SeeAlso: pauseLabel
     - SeeAlso: unpauseLabel
     */
    open var isPaused: Bool {
        return (sublabel.layer.speed == 0.0)
    }
    
    /**
     A boolean property that indicates if the label is currently away from the home location.
     
     The "home" location is the traditional location of `UILabel` text. This property essentially reflects if a scroll animation is underway.
     */
    open var awayFromHome: Bool
    {

        if let presentationLayer = sublabel.layer.presentation(){
            return !(presentationLayer.position.x == homeLabelFrame.origin.x)
        }
       return false
    }
    
    /**
     The `MarqueeLabel` scrolling speed may be defined by one of two ways:
     - Rate(CGFloat): The speed is defined by a rate of motion, in units of points per second.
     - Duration(CGFloat): The speed is defined by the time to complete a scrolling animation cycle, in units of seconds.
     
     Each case takes an associated `CGFloat` value, which is the rate/duration desired.
     */
    public enum SpeedLimit {
        case rate(CGFloat)
        case duration(CGFloat)
        
        var value: CGFloat {
            switch self {
            case .rate(let rate):
                return rate
            case .duration(let duration):
                return duration
            }
        }
    }
    
    /**
     Defines the speed of the `MarqueeLabel` scrolling animation.
     
     The speed is set by specifying a case of the `SpeedLimit` enum along with an associated value.
     
     - SeeAlso: SpeedLimit
     */
    open var speed: SpeedLimit = .duration(7.0) {
        didSet {
            switch (speed, oldValue) {
            case (.rate(let a), .rate(let b)) where a == b:
                return
            case (.duration(let a), .duration(let b)) where a == b:
                return
            default:
                updateAndScroll()
            }
        }
    }
    
    // @available attribute seems to cause SourceKit to crash right now
    // @available(*, deprecated = 2.6, message = "Use speed property instead")
    open var scrollDuration: CGFloat? {
        get {
            switch speed {
            case .duration(let duration): return duration
            case .rate(_): return nil
            }
        }
        set {
            if let duration = newValue {
                speed = .duration(duration)
            }
        }
    }
    
    // @available attribute seems to cause SourceKit to crash right now
    // @available(*, deprecated = 2.6, message = "Use speed property instead")
    open var scrollRate: CGFloat? {
        get {
            switch speed {
            case .duration(_): return nil
            case .rate(let rate): return rate
            }
        }
        set {
            if let rate = newValue {
                speed = .rate(rate)
            }
        }
    }
    
    /**
     A buffer (offset) between the leading edge of the label text and the label frame.
     
     This property adds additional space between the leading edge of the label text and the label frame. The
     leading edge is the edge of the label text facing the direction of scroll (i.e. the edge that animates
     offscreen first during scrolling).
     
     Defaults to `0`.
     
     - Note: The value set to this property affects label positioning at all times (including when `labelize` is set to `true`),
     including when the text string length is short enough that the label does not need to scroll.
     - Note: For Continuous-type labels, the smallest value of `leadingBuffer`, `trailingBuffer`, and `fadeLength`
     is used as spacing between the two label instances. Zero is an allowable value for all three properties.
     
     - SeeAlso: trailingBuffer
     */
    @IBInspectable open var leadingBuffer: CGFloat = 0.0 {
        didSet {
            if leadingBuffer != oldValue {
                updateAndScroll()
            }
        }
    }
    
    /**
     A buffer (offset) between the trailing edge of the label text and the label frame.
     
     This property adds additional space (buffer) between the trailing edge of the label text and the label frame. The
     trailing edge is the edge of the label text facing away from the direction of scroll (i.e. the edge that animates
     offscreen last during scrolling).
     
     Defaults to `0`.
     
     - Note: The value set to this property has no effect when the `labelize` property is set to `true`.
     
     - Note: For Continuous-type labels, the smallest value of `leadingBuffer`, `trailingBuffer`, and `fadeLength`
     is used as spacing between the two label instances. Zero is an allowable value for all three properties.
     
     - SeeAlso: leadingBuffer
     */
    @IBInspectable open var trailingBuffer: CGFloat = 0.0 {
        didSet {
            if trailingBuffer != oldValue {
                updateAndScroll()
            }
        }
    }
    
    /**
     The length of transparency fade at the left and right edges of the frame.
     
     This propery sets the size (in points) of the view edge transparency fades on the left and right edges of a `MarqueeLabel`. The
     transparency fades from an alpha of 1.0 (fully visible) to 0.0 (fully transparent) over this distance. Values set to this property
     will be sanitized to prevent a fade length greater than 1/2 of the frame width.
     
     Defaults to `0`.
     */
    @IBInspectable open var fadeLength: CGFloat = 0.0 {
        didSet {
            if fadeLength != oldValue {
                applyGradientMask(fadeLength, animated: true)
                updateAndScroll()
            }
        }
    }
    
    /**
     The length of delay in seconds that the label pauses at the completion of a scroll.
     */
    @IBInspectable open var animationDelay: CGFloat = 1.0
    
    //
    // MARK: - Class Functions and Helpers
    //
    
    /**
    Convenience method to restart all `MarqueeLabel` instances that have the specified view controller in their next responder chain.
    
    - Parameter controller: The view controller for which to restart all `MarqueeLabel` instances.
    
    - Warning: View controllers that appear with animation (such as from underneath a modal-style controller) can cause some `MarqueeLabel` text
    position "jumping" when this method is used in `viewDidAppear` if scroll animations are already underway. Use this method inside `viewWillAppear:`
    instead to avoid this problem.
    
    - Warning: This method may not function properly if passed the parent view controller when using view controller containment.
    
    - SeeAlso: restartLabel
    - SeeAlso: controllerViewDidAppear:
    - SeeAlso: controllerViewWillAppear:
    */
    class func restartLabelsOfController(_ controller: UIViewController) {
        MarqueeLabel.notifyController(controller, message: .Restart)
    }
    
    /**
     Convenience method to restart all `MarqueeLabel` instances that have the specified view controller in their next responder chain.
     
     Alternative to `restartLabelsOfController`. This method is retained for backwards compatibility and future enhancements.
     
     - Parameter controller: The view controller that will appear.
     - SeeAlso: restartLabel
     - SeeAlso: controllerViewDidAppear
     */
    class func controllerViewWillAppear(_ controller: UIViewController) {
        MarqueeLabel.restartLabelsOfController(controller)
    }
    
    /**
     Convenience method to restart all `MarqueeLabel` instances that have the specified view controller in their next responder chain.
     
     Alternative to `restartLabelsOfController`. This method is retained for backwards compatibility and future enhancements.
     
     - Parameter controller: The view controller that did appear.
     - SeeAlso: restartLabel
     - SeeAlso: controllerViewWillAppear
     */
    class func controllerViewDidAppear(_ controller: UIViewController) {
        MarqueeLabel.restartLabelsOfController(controller)
    }
    
    /**
     Labelizes all `MarqueeLabel` instances that have the specified view controller in their next responder chain.
     
     The `labelize` property of all recognized `MarqueeLabel` instances will be set to `true`.
     
     - Parameter controller: The view controller for which all `MarqueeLabel` instances should be labelized.
     - SeeAlso: labelize
     */
    class func controllerLabelsLabelize(_ controller: UIViewController) {
        MarqueeLabel.notifyController(controller, message: .Labelize)
    }
    
    /**
     De-labelizes all `MarqueeLabel` instances that have the specified view controller in their next responder chain.
     
     The `labelize` property of all recognized `MarqueeLabel` instances will be set to `false`.
     
     - Parameter controller: The view controller for which all `MarqueeLabel` instances should be de-labelized.
     - SeeAlso: labelize
     */
    class func controllerLabelsAnimate(_ controller: UIViewController) {
        MarqueeLabel.notifyController(controller, message: .Animate)
    }
    
    
    //
    // MARK: - Initialization
    //
    
    /**
    Returns a newly initialized `MarqueeLabel` instance with the specified scroll rate and edge transparency fade length.
    
    - Parameter frame: A rectangle specifying the initial location and size of the view in its superview's coordinates. Text (for the given font, font size, etc.) that does not fit in this frame will automatically scroll.
    - Parameter pixelsPerSec: A rate of scroll for the label scroll animation. Must be non-zero. Note that this will be the peak (mid-transition) rate for ease-type animation.
    - Parameter fadeLength: A length of transparency fade at the left and right edges of the `MarqueeLabel` instance's frame.
    - Returns: An initialized `MarqueeLabel` object or nil if the object couldn't be created.
    - SeeAlso: fadeLength
    */
    init(frame: CGRect, rate: CGFloat, fadeLength fade: CGFloat) {
        speed = .rate(rate)
        fadeLength = CGFloat(min(fade, frame.size.width/2.0))
        super.init(frame: frame)
        setup()
    }
    
    /**
     Returns a newly initialized `MarqueeLabel` instance with the specified scroll rate and edge transparency fade length.
     
     - Parameter frame: A rectangle specifying the initial location and size of the view in its superview's coordinates. Text (for the given font, font size, etc.) that does not fit in this frame will automatically scroll.
     - Parameter scrollDuration: A scroll duration the label scroll animation. Must be non-zero. This will be the duration that the animation takes for one-half of the scroll cycle in the case of left-right and right-left marquee types, and for one loop of a continuous marquee type.
     - Parameter fadeLength: A length of transparency fade at the left and right edges of the `MarqueeLabel` instance's frame.
     - Returns: An initialized `MarqueeLabel` object or nil if the object couldn't be created.
     - SeeAlso: fadeLength
     */
    init(frame: CGRect, duration: CGFloat, fadeLength fade: CGFloat) {
        speed = .duration(duration)
        fadeLength = CGFloat(min(fade, frame.size.width/2.0))
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    /**
     Returns a newly initialized `MarqueeLabel` instance.
     
     The default scroll duration of 7.0 seconds and fade length of 0.0 are used.
     
     - Parameter frame: A rectangle specifying the initial location and size of the view in its superview's coordinates. Text (for the given font, font size, etc.) that does not fit in this frame will automatically scroll.
     - Returns: An initialized `MarqueeLabel` object or nil if the object couldn't be created.
     */
    convenience public override init(frame: CGRect) {
        self.init(frame: frame, duration:7.0, fadeLength:0.0)
    }
    
    fileprivate func setup() {
        // Create sublabel
        sublabel = UILabel(frame: self.bounds)
        sublabel.tag = 700
        sublabel.layer.anchorPoint = CGPoint.zero
        
        // Add sublabel
        addSubview(sublabel)
        
        // Configure self
        super.clipsToBounds = true
        super.numberOfLines = 1
        
        // Add notification observers
        // Custom class notifications
        
        NotificationCenter.default.addObserver(self, selector: #selector(MarqueeLabel.restartForViewController(_:)), name: NSNotification.Name(rawValue: MarqueeKeys.Restart.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MarqueeLabel.labelizeForController(_:)), name: NSNotification.Name(rawValue: MarqueeKeys.Labelize.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MarqueeLabel.animateForController(_:)), name: NSNotification.Name(rawValue: MarqueeKeys.Animate.rawValue), object: nil)
        // UIApplication state notifications
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("MarqueeLabel.restartLabel"), name: UIApplicationDidBecomeActiveNotification, object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("MarqueeLabel.shutdownLabel"), name: UIApplication.didEnterBackgroundNotificationNotification, object: nil)
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        forwardPropertiesToSublabel()
    }
    
    fileprivate func forwardPropertiesToSublabel() {
        /*
        Note that this method is currently ONLY called from awakeFromNib, i.e. when
        text properties are set via a Storyboard. As the Storyboard/IB doesn't currently
        support attributed strings, there's no need to "forward" the super attributedString value.
        */
        
        // Since we're a UILabel, we actually do implement all of UILabel's properties.
        // We don't care about these values, we just want to forward them on to our sublabel.
        let properties = ["baselineAdjustment", "enabled", "highlighted", "highlightedTextColor",
            "minimumFontSize", "shadowOffset", "textAlignment",
            "userInteractionEnabled", "adjustsFontSizeToFitWidth",
            "lineBreakMode", "numberOfLines"]
        
        // Iterate through properties
        sublabel.text = super.text
        sublabel.font = super.font
        sublabel.textColor = super.textColor
        sublabel.backgroundColor = super.backgroundColor ?? UIColor.clear
        sublabel.shadowColor = super.shadowColor
        sublabel.shadowOffset = super.shadowOffset
        for prop in properties {
            let value: AnyObject! = super.value(forKey: prop) as AnyObject?
            sublabel.setValue(value, forKeyPath: prop)
        }
    }
    
    //
    // MARK: - MarqueeLabel Heavy Lifting
    //
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        updateAndScroll(true)
    }
    
    override open func willMove(toWindow newWindow: UIWindow?) {
        if newWindow == nil {
            shutdownLabel()
        }
    }
    
    override open func didMoveToWindow() {
        if self.window == nil {
            shutdownLabel()
        } else {
            updateAndScroll()
        }
    }
    
    fileprivate func updateAndScroll() {
        updateAndScroll(true)
    }
    
    fileprivate func updateAndScroll(_ shouldBeginScroll: Bool) {
        // Check if scrolling can occur
        if !labelReadyForScroll() {
            return
        }
        
        // Calculate expected size
        let expectedLabelSize = sublabelSize()
        
        // Invalidate intrinsic size
        invalidateIntrinsicContentSize()
        
        // Move label to home
        returnLabelToHome()
        
        // Check if label should scroll
        // Note that the holdScrolling propery does not affect this
        if !labelShouldScroll() {
            // Set text alignment and break mode to act like a normal label
            sublabel.textAlignment = NSTextAlignment.center
            sublabel.lineBreakMode = super.lineBreakMode
            
           // var unusedFrame = CGRect.zero
            var labelFrame = CGRect.zero
            
            switch type {
            case .continuousReverse, .rightLeft:

               // (unusedFrame, labelFrame) = bounds.divided(atDistance: leadingBuffer, from: CGRectEdge.maxXEdge)
                labelFrame = labelFrame.integral
            default:
                labelFrame = CGRect(x: leadingBuffer, y: 0.0, width: bounds.size.width - leadingBuffer, height: bounds.size.height).integral
            }
            //print(unusedFrame)
            homeLabelFrame = labelFrame
            awayOffset = 0.0
            
            // Remove an additional sublabels (for continuous types)
            repliLayer.instanceCount = 1;
            
            // Set the sublabel frame to calculated labelFrame
            sublabel.frame = labelFrame
            
            // Configure fade
            applyGradientMask(fadeLength, animated: !labelize)
            
            return
        }
        
        // Label DOES need to scroll
        
        // Spacing between primary and second sublabel must be at least equal to leadingBuffer, and at least equal to the fadeLength
        let minTrailing = max(max(leadingBuffer, trailingBuffer), fadeLength)
        
        switch type {
        case .continuous, .continuousReverse:
            if (type == .continuous) {
                homeLabelFrame = CGRect(x: leadingBuffer, y: 0.0, width: expectedLabelSize.width, height: bounds.size.height).integral
                awayOffset = -(homeLabelFrame.size.width + minTrailing)
            } else { // .ContinuousReverse
                homeLabelFrame = CGRect(x: bounds.size.width - (expectedLabelSize.width + leadingBuffer), y: 0.0, width: expectedLabelSize.width, height: bounds.size.height).integral
                awayOffset = (homeLabelFrame.size.width + minTrailing)
            }
            
            // Set frame and text
            sublabel.frame = homeLabelFrame
            
            // Configure replication
            repliLayer.instanceCount = 2
            repliLayer.instanceTransform = CATransform3DMakeTranslation(-awayOffset, 0.0, 0.0)
            
        case .rightLeft:
            homeLabelFrame = CGRect(x: bounds.size.width - (expectedLabelSize.width + leadingBuffer), y: 0.0, width: expectedLabelSize.width, height: bounds.size.height).integral
            awayOffset = (expectedLabelSize.width + trailingBuffer + leadingBuffer) - bounds.size.width
            
            // Set frame and text
            sublabel.frame = homeLabelFrame
            
            // Remove any replication
            repliLayer.instanceCount = 1
            
            // Enforce text alignment for this type
            sublabel.textAlignment = NSTextAlignment.center
            
        case .leftRight:
            homeLabelFrame = CGRect(x: leadingBuffer, y: 0.0, width: expectedLabelSize.width, height: expectedLabelSize.height).integral
            awayOffset = bounds.size.width - (expectedLabelSize.width + leadingBuffer + trailingBuffer)
            
            // Set frame and text
            sublabel.frame = homeLabelFrame
            
            // Remove any replication
            self.repliLayer.instanceCount = 1
            
            // Enforce text alignment for this type
            sublabel.textAlignment = NSTextAlignment.center
            
            // Default case not required
        }
        
        // Recompute the animation duration
        animationDuration = {
            switch self.speed {
            case .rate(let rate):
                return CGFloat(fabs(self.awayOffset) / rate)
            case .duration(let duration):
                return duration
            }
            }()
        
        // Configure gradient for current condition
        applyGradientMask(fadeLength, animated: !self.labelize)
        
        if !tapToScroll && !holdScrolling && shouldBeginScroll {
            beginScroll()
        }
    }
    
    func sublabelSize() -> CGSize {
        // Bound the expected size
        let maximumLabelSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        // Calculate the expected size
        var expectedLabelSize = sublabel.sizeThatFits(maximumLabelSize)
        // Sanitize width to 5461.0 (largest width a UILabel will draw on an iPhone 6S Plus)
        expectedLabelSize.width = min(expectedLabelSize.width, 5461.0)
        
        // Adjust to own height (make text baseline match normal label)
        expectedLabelSize.height = bounds.size.height
        return expectedLabelSize
    }
    
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        var fitSize = sublabel.sizeThatFits(size)
        fitSize.width += leadingBuffer
        return fitSize
    }
    
    //
    // MARK: - Animation Handling
    //
    
    fileprivate func labelShouldScroll() -> Bool {
        // Check for nil string
        if sublabel.text == nil {
            return false
        }
        
        // Check for empty string
        if sublabel.text!.isEmpty {
            return false
        }
        
        // Check if the label string fits
        let labelTooLarge = (sublabelSize().width + leadingBuffer) > self.bounds.size.width
        let animationHasDuration = speed.value > 0.0
        return (!labelize && labelTooLarge && animationHasDuration)
    }
    
    fileprivate func labelReadyForScroll() -> Bool {
        // Check if we have a superview
        if superview == nil {
            return false
        }
        
        // Check if we are attached to a window
        if window == nil {
            return false
        }
        
        // Check if our view controller is ready
        let viewController = firstAvailableViewController()
        if viewController != nil {
            if !viewController!.isViewLoaded {
                return false
            }
        }
        
        return true
    }
    
    fileprivate func beginScroll() {
        beginScroll(true)
    }
    
    fileprivate func beginScroll(_ delay: Bool) {
        switch self.type {
        case .leftRight, .rightLeft:
            scrollAway(animationDuration, delay: animationDelay)
        default:
            scrollContinuous(animationDuration, delay: animationDelay)
        }
    }
    
    fileprivate func returnLabelToHome() {
        // Remove any gradient animation
        maskLayer?.removeAllAnimations()
        
        // Remove all sublabel position animations
        sublabel.layer.removeAllAnimations()
    }
    
    // Define animation completion closure type
    fileprivate typealias MLAnimationCompletion = (_ finished: Bool) -> ()
    
    fileprivate func scroll(_ interval: CGFloat, delay: CGFloat = 0.0, scroller: Scroller, fader: CAKeyframeAnimation?) {
        var scroller = scroller
        // Check for conditions which would prevent scrolling
        if !labelReadyForScroll() {
            return
        }
        
        // Call pre-animation hook
        labelWillBeginScroll()
        
        // Start animation transactions
        CATransaction.begin()
        let transDuration = transactionDurationType(type, interval: interval, delay: delay)
        CATransaction.setAnimationDuration(transDuration)
        
        // Create gradient animation, if needed
        let gradientAnimation: CAKeyframeAnimation?
        if fadeLength > 0.0 {
            // Remove any setup animation, but apply final values
            if let setupAnim = maskLayer?.animation(forKey: "setupFade") as? CABasicAnimation, let finalColors = setupAnim.toValue as? [CGColor] {
                maskLayer?.colors = finalColors
            }
            maskLayer?.removeAnimation(forKey: "setupFade")
            
            // Generate animation if needed
            if let previousAnimation = fader {
                gradientAnimation = previousAnimation
            } else {
                gradientAnimation = keyFrameAnimationForGradient(fadeLength, interval: interval, delay: delay)
            }
            
            // Apply scrolling animation
            maskLayer?.add(gradientAnimation!, forKey: "gradient")
        } else {
            // No animation needed
            gradientAnimation = nil
        }
        
        let completion = CompletionBlock<MLAnimationCompletion>({ (finished: Bool) -> () in
            guard finished else {
                // Do not continue into the next loop
                return
            }
            
            // Call returned home function
            self.labelReturnedToHome(true)
            
            // Check to ensure that:
            // 1) We don't double fire if an animation already exists
            // 2) The instance is still attached to a window - this completion block is called for
            //    many reasons, including if the animation is removed due to the view being removed
            //    from the UIWindow (typically when the view controller is no longer the "top" view)
            guard self.window != nil else {
                return
            }
            
            guard self.sublabel.layer.animation(forKey: "position") == nil else {
                return
            }
            
            // Begin again, if conditions met
            if (self.labelShouldScroll() && !self.tapToScroll && !self.holdScrolling) {
                // Perform completion callback
                self.scroll(interval, delay: delay, scroller: scroller, fader: gradientAnimation)
            }
        })
        
        // Call scroller
        let scrolls = scroller.generate(interval, delay: delay)
        
        // Perform all animations in scrolls
        for (index, scroll) in scrolls.enumerated() {
            let layer = scroll.layer
            let anim = scroll.anim
            
            // Add callback to single animation
            if index == 0 {
                anim.setValue(completion as AnyObject, forKey: MarqueeKeys.CompletionClosure.rawValue)
                anim.delegate = self
            }
            
            // Add animation
            layer.add(anim, forKey: "position")
        }
        
        CATransaction.commit()
    }
    
    fileprivate func scrollAway(_ interval: CGFloat, delay: CGFloat = 0.0) {
        // Create scroller, which defines the animation to perform
        let homeOrigin = homeLabelFrame.origin
        let awayOrigin = offsetCGPoint(homeLabelFrame.origin, offset: awayOffset)
        let scroller = Scroller(generator: {(interval: CGFloat, delay: CGFloat) -> [(layer: CALayer, anim: CAKeyframeAnimation)] in
            // Create animation for position
            let values: [NSValue] = [
                NSValue(cgPoint: homeOrigin), // Start at home
                NSValue(cgPoint: homeOrigin), // Stay at home for delay
                NSValue(cgPoint: awayOrigin), // Move to away
                NSValue(cgPoint: awayOrigin), // Stay at away for delay
                NSValue(cgPoint: homeOrigin)  // Move back to home
            ]
            
            let layer = self.sublabel.layer
            let anim = self.keyFrameAnimationForProperty("position", values: values, interval: interval, delay: delay)
            
            return [(layer: layer, anim: anim)]
        })
        
        // Scroll
        scroll(interval, delay: delay, scroller: scroller, fader: nil)
    }
    
    
    fileprivate func scrollContinuous(_ interval: CGFloat, delay: CGFloat) {
        // Create scroller, which defines the animation to perform
        let homeOrigin = homeLabelFrame.origin
        let awayOrigin = offsetCGPoint(homeLabelFrame.origin, offset: awayOffset)
        let scroller = Scroller(generator: { (interval: CGFloat, delay: CGFloat) -> [(layer: CALayer, anim: CAKeyframeAnimation)] in
            // Create animation for position
            let values: [NSValue] = [
                NSValue(cgPoint: homeOrigin), // Start at home
                NSValue(cgPoint: homeOrigin), // Stay at home for delay
                NSValue(cgPoint: awayOrigin)  // Move to away
            ]
            
            // Generate animation
            let layer = self.sublabel.layer
            let anim = self.keyFrameAnimationForProperty("position", values: values, interval: interval, delay: delay)
            
            
            return [(layer: layer, anim: anim)]
        })
        
        // Scroll
        scroll(interval, delay: delay, scroller: scroller, fader: nil)
    }
    
    fileprivate func applyGradientMask(_ fadeLength: CGFloat, animated: Bool) {
        // Remove any in-flight animations
        maskLayer?.removeAllAnimations()
        
        // Check for zero-length fade
        if (fadeLength <= 0.0) {
            removeGradientMask()
            return
        }
        
        // Configure gradient mask without implicit animations
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        // Determine if gradient mask needs to be created
        let gradientMask: CAGradientLayer
        if let currentMask = self.maskLayer {
            // Mask layer already configured
            gradientMask = currentMask
        } else {
            // No mask exists, create new mask
            gradientMask = CAGradientLayer()
            gradientMask.shouldRasterize = true
            gradientMask.rasterizationScale = UIScreen.main.scale
            gradientMask.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradientMask.endPoint = CGPoint(x: 1.0, y: 0.5)
            // Adjust stops based on fade length
            let leftFadeStop = fadeLength/self.bounds.size.width
            let rightFadeStop = fadeLength/self.bounds.size.width

            
            gradientMask.locations = [0.0, NSNumber(value: Float(leftFadeStop)), NSNumber(value: Float((1.0 - rightFadeStop))), 1.0]

        }
        
        // Set up colors
        let transparent = UIColor.clear.cgColor
        let opaque = UIColor.black.cgColor
        
        // Set mask
        self.layer.mask = gradientMask
        
        gradientMask.bounds = self.layer.bounds
        gradientMask.position = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        
        // Determine colors for non-scrolling label (i.e. at home)
        let adjustedColors: [CGColor]
        let trailingFadeNeeded = self.labelShouldScroll()
        
        switch (type) {
        case .continuousReverse, .rightLeft:
            adjustedColors = [(trailingFadeNeeded ? transparent : opaque), opaque, opaque, opaque]
            
            // .MLContinuous, .MLLeftRight
        default:
            adjustedColors = [opaque, opaque, opaque, (trailingFadeNeeded ? transparent : opaque)]
            break
        }
        
        if (animated) {
            // Finish transaction
            CATransaction.commit()
            
            // Create animation for color change
            let colorAnimation = GradientAnimation(keyPath: "colors")
            colorAnimation.fromValue = gradientMask.colors
            colorAnimation.toValue = adjustedColors
            colorAnimation.fillMode = CAMediaTimingFillMode.forwards
            colorAnimation.isRemovedOnCompletion = false
            colorAnimation.delegate = self
            gradientMask.add(colorAnimation, forKey: "setupFade")
        } else {
            gradientMask.colors = adjustedColors
            CATransaction.commit()
        }
    }
    
    fileprivate func removeGradientMask() {
        self.layer.mask = nil
    }
    
    fileprivate func keyFrameAnimationForGradient(_ fadeLength: CGFloat, interval: CGFloat, delay: CGFloat) -> CAKeyframeAnimation {
        // Setup
        let values: [[CGColor]]
        let keyTimes: [CGFloat]
        let transp = UIColor.clear.cgColor
        let opaque = UIColor.black.cgColor
        
        // Create new animation
        let animation = CAKeyframeAnimation(keyPath: "colors")
        
        // Get timing function
        let timingFunction = timingFunctionForAnimationCurve(animationCurve)
        
        // Define keyTimes
        switch (type) {
        case .leftRight, .rightLeft:
            // Calculate total animation duration
            let totalDuration = 2.0 * (delay + interval)
            keyTimes =
                [
                    0.0,                                                // 1) Initial gradient
                    delay/totalDuration,                                // 2) Begin of LE fade-in, just as scroll away starts
                    (delay + 0.4)/totalDuration,                        // 3) End of LE fade in [LE fully faded]
                    (delay + interval - 0.4)/totalDuration,             // 4) Begin of TE fade out, just before scroll away finishes
                    (delay + interval)/totalDuration,                   // 5) End of TE fade out [TE fade removed]
                    (delay + interval + delay)/totalDuration,           // 6) Begin of TE fade back in, just as scroll home starts
                    (delay + interval + delay + 0.4)/totalDuration,     // 7) End of TE fade back in [TE fully faded]
                    (totalDuration - 0.4)/totalDuration,                // 8) Begin of LE fade out, just before scroll home finishes
                    1.0                                                 // 9) End of LE fade out, just as scroll home finishes
            ]
            
            // .MLContinuous, .MLContinuousReverse
        default:
            // Calculate total animation duration
            let totalDuration = delay + interval
            
            // Find when the lead label will be totally offscreen
            let offsetDistance = awayOffset
            let startFadeFraction = fabs((sublabel.bounds.size.width + leadingBuffer) / offsetDistance)
            // Find when the animation will hit that point
            let startFadeTimeFraction = timingFunction.durationPercentageForPositionPercentage(startFadeFraction, duration: totalDuration)
            let startFadeTime = delay + CGFloat(startFadeTimeFraction) * interval
            
            keyTimes = [
                0.0,                                        // Initial gradient
                delay/totalDuration,                        // Begin of fade in
                (delay + 0.2)/totalDuration,                // End of fade in, just as scroll away starts
                startFadeTime/totalDuration,                // Begin of fade out, just before scroll home completes
                (startFadeTime + 0.1)/totalDuration,        // End of fade out, as scroll home completes
                1.0                                         // Buffer final value (used on continuous types)
            ]
            break
        }
        
        // Define values
        // Get current layer values

        let mask = maskLayer?.presentation()
        let currentValues = mask?.colors as? [CGColor]

        
        switch (type) {
        case .continuousReverse:
            values = [
                currentValues ?? [transp, opaque, opaque, opaque],           // Initial gradient
                [transp, opaque, opaque, opaque],           // Begin of fade in
                [transp, opaque, opaque, transp],           // End of fade in, just as scroll away starts
                [transp, opaque, opaque, transp],           // Begin of fade out, just before scroll home completes
                [transp, opaque, opaque, opaque],           // End of fade out, as scroll home completes
                [transp, opaque, opaque, opaque]            // Final "home" value
            ]
            break
            
        case .rightLeft:
            values = [
                currentValues ?? [transp, opaque, opaque, opaque],           // 1)
                [transp, opaque, opaque, opaque],           // 2)
                [transp, opaque, opaque, transp],           // 3)
                [transp, opaque, opaque, transp],           // 4)
                [opaque, opaque, opaque, transp],           // 5)
                [opaque, opaque, opaque, transp],           // 6)
                [transp, opaque, opaque, transp],           // 7)
                [transp, opaque, opaque, transp],           // 8)
                [transp, opaque, opaque, opaque]            // 9)
            ]
            break
            
        case .continuous:
            values = [
                currentValues ?? [opaque, opaque, opaque, transp],           // Initial gradient
                [opaque, opaque, opaque, transp],           // Begin of fade in
                [transp, opaque, opaque, transp],           // End of fade in, just as scroll away starts
                [transp, opaque, opaque, transp],           // Begin of fade out, just before scroll home completes
                [opaque, opaque, opaque, transp],           // End of fade out, as scroll home completes
                [opaque, opaque, opaque, transp]            // Final "home" value
            ]
            break
            
        case .leftRight:
            values = [
                currentValues ?? [opaque, opaque, opaque, transp],           // 1)
                [opaque, opaque, opaque, transp],           // 2)
                [transp, opaque, opaque, transp],           // 3)
                [transp, opaque, opaque, transp],           // 4)
                [transp, opaque, opaque, opaque],           // 5)
                [transp, opaque, opaque, opaque],           // 6)
                [transp, opaque, opaque, transp],           // 7)
                [transp, opaque, opaque, transp],           // 8)
                [opaque, opaque, opaque, transp]            // 9)
            ]
            break
        }
        
        animation.values = values
        animation.keyTimes = keyTimes as [NSNumber]?
        animation.timingFunctions = [timingFunction, timingFunction, timingFunction, timingFunction]
        
        return animation
    }
    
    fileprivate func keyFrameAnimationForProperty(_ property: String, values: [NSValue], interval: CGFloat, delay: CGFloat) -> CAKeyframeAnimation {
        // Create new animation
        let animation = CAKeyframeAnimation(keyPath: property)
        
        // Get timing function
        let timingFunction = timingFunctionForAnimationCurve(animationCurve)
        
        // Calculate times based on marqueeType
        let totalDuration: CGFloat
        switch (type) {
        case .leftRight, .rightLeft:
            //NSAssert(values.count == 5, @"Incorrect number of values passed for MLLeftRight-type animation")
            totalDuration = 2.0 * (delay + interval)
            let initialDelay = NSNumber(value: Float(delay/totalDuration))
            let animationToAway = NSNumber(value: Float((delay + interval)/totalDuration))
            let delayAtAway = NSNumber(value: Float((delay + interval + delay)/totalDuration))
            // Set up keyTimes
            animation.keyTimes = [
                0.0,                                            // Initial location, home
                initialDelay,                            // Initial delay, at home
                animationToAway,               // Animation to away
                delayAtAway,       // Delay at away
                1.0                                             // Animation to home
            ]
            
            animation.timingFunctions = [
                timingFunction,
                timingFunction,
                timingFunction,
                timingFunction
            ]
            
            // .Continuous
            // .ContinuousReverse
        default:
            //NSAssert(values.count == 3, @"Incorrect number of values passed for MLContinous-type animation")
            totalDuration = delay + interval
            let initialDelay = NSNumber(value: Float(delay/totalDuration))
            // Set up keyTimes
            animation.keyTimes = [
                0.0,                        // Initial location, home
                initialDelay,        // Initial delay, at home
                1.0                         // Animation to away
            ]
            
            animation.timingFunctions = [
                timingFunction,
                timingFunction
            ]
        }
        
        // Set values
        animation.values = values
        
        return animation
    }
    
    fileprivate func timingFunctionForAnimationCurve(_ curve: UIView.AnimationCurve) -> CAMediaTimingFunction {
        let timingFunction: String?
        
        switch curve {
        case .easeIn:
            timingFunction = CAMediaTimingFunctionName.easeIn.rawValue
        case .easeInOut:
            timingFunction = CAMediaTimingFunctionName.easeInEaseOut.rawValue
        case .easeOut:
            timingFunction = CAMediaTimingFunctionName.easeOut.rawValue
        default:
            timingFunction = CAMediaTimingFunctionName.linear.rawValue
        }
        
        return CAMediaTimingFunction(name: CAMediaTimingFunctionName(rawValue: timingFunction!))
    }
    
    fileprivate func transactionDurationType(_ labelType: Type, interval: CGFloat, delay: CGFloat) -> TimeInterval {
        switch (labelType) {
        case .leftRight, .rightLeft:
            return TimeInterval(2.0 * (delay + interval))
        default:
            return TimeInterval(delay + interval)
        }
    }
    
    open func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if anim is GradientAnimation {
            if let setupAnim = maskLayer?.animation(forKey: "setupFade") as? CABasicAnimation, let finalColors = setupAnim.toValue as? [CGColor] {
                maskLayer?.colors = finalColors
            }
            // Remove regardless, since we set removeOnCompletion = false
            maskLayer?.removeAnimation(forKey: "setupFade")
        } else {
            let completion = anim.value(forKey: MarqueeKeys.CompletionClosure.rawValue) as? CompletionBlock<MLAnimationCompletion>
            completion?.f(flag)
        }
    }
    
    
    //
    // MARK: - Private details
    //
    
    fileprivate var sublabel = UILabel()
    fileprivate var animationDuration: CGFloat = 0.0
    
    fileprivate var homeLabelFrame = CGRect.zero
    fileprivate var awayOffset: CGFloat = 0.0
    
    override open class var layerClass : AnyClass {
        return CAReplicatorLayer.self
    }
    
    fileprivate var repliLayer: CAReplicatorLayer {
        return self.layer as! CAReplicatorLayer
    }
    
    fileprivate var maskLayer: CAGradientLayer? {
        return self.layer.mask as! CAGradientLayer?
    }
    
    override open func draw(_ layer: CALayer, in ctx: CGContext) {
        // Do NOT call super, to prevent UILabel superclass from drawing into context
        // Label drawing is handled by sublabel and CAReplicatorLayer layer class
        
        // Draw only background color
        if let bgColor = backgroundColor {
            ctx.setFillColor(bgColor.cgColor);
            ctx.fill(layer.bounds);
        }
    }
    
    fileprivate enum MarqueeKeys: String {
        case Restart = "MLViewControllerRestart"
        case Labelize = "MLShouldLabelize"
        case Animate = "MLShouldAnimate"
        case CompletionClosure = "MLAnimationCompletion"
    }
    
    class fileprivate func notifyController(_ controller: UIViewController, message: MarqueeKeys) {
        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: message.rawValue), object: nil, userInfo: ["controller" : controller])
    }
    
    @objc open func restartForViewController(_ notification: Foundation.Notification) {
        if let controller = (notification as NSNotification).userInfo?["controller"] as? UIViewController {
            if controller === self.firstAvailableViewController() {
                self.restartLabel()
            }
        }
    }
    
    @objc open func labelizeForController(_ notification: Foundation.Notification) {
        if let controller = (notification as NSNotification).userInfo?["controller"] as? UIViewController {
            if controller === self.firstAvailableViewController() {
                self.labelize = true
            }
        }
    }
    
    @objc open func animateForController(_ notification: Foundation.Notification) {
        if let controller = (notification as NSNotification).userInfo?["controller"] as? UIViewController {
            if controller === self.firstAvailableViewController() {
                self.labelize = false
            }
        }
    }
    
    
    //
    // MARK: - Label Control
    //
    
    /**
    Overrides any non-size condition which is preventing the receiver from automatically scrolling, and begins a scroll animation.
    
    Currently the only non-size conditions which can prevent a label from scrolling are the `tapToScroll` and `holdScrolling` properties. This
    method will not force a label with a string that fits inside the label bounds (i.e. that would not automatically scroll) to begin a scroll
    animation.
    
    Upon the completion of the first forced scroll animation, the receiver will not automatically continue to scroll unless the conditions
    preventing scrolling have been removed.
    
    - Note: This method has no effect if called during an already in-flight scroll animation.
    
    - SeeAlso: restartLabel
    */
    open func triggerScrollStart() {
        if labelShouldScroll() && !awayFromHome {
            beginScroll()
        }
    }
    
    /**
     Immediately resets the label to the home position, cancelling any in-flight scroll animation, and restarts the scroll animation if the appropriate conditions are met.
     
     - SeeAlso: resetLabel
     - SeeAlso: triggerScrollStart
     */
    open func restartLabel() {
        // Shutdown the label
        shutdownLabel()
        // Restart scrolling if appropriate
        if labelShouldScroll() && !tapToScroll && !holdScrolling {
            beginScroll()
        }
    }
    
    /**
     Resets the label text, recalculating the scroll animation.
     
     The text is immediately returned to the home position, and the scroll animation positions are cleared. Scrolling will not resume automatically after
     a call to this method. To re-initiate scrolling, use either a call to `restartLabel` or make a change to a UILabel property such as text, bounds/frame,
     font, font size, etc.
     
     - SeeAlso: restartLabel
     */
    open func resetLabel() {
        returnLabelToHome()
        homeLabelFrame = CGRect.null
        awayOffset = 0.0
    }
    
    /**
     Immediately resets the label to the home position, cancelling any in-flight scroll animation.
     
     The text is immediately returned to the home position. Scrolling will not resume automatically after a call to this method.
     To re-initiate scrolling use a call to `restartLabel` or `triggerScrollStart`, or make a change to a UILabel property such as text, bounds/frame,
     font, font size, etc.
     
     - SeeAlso: restartLabel
     - SeeAlso: triggerScrollStart
     */
    open func shutdownLabel() {
        // Bring label to home location
        returnLabelToHome()
        // Apply gradient mask for home location
        applyGradientMask(fadeLength, animated: false)
    }
    
    /**
     Pauses the text scrolling animation, at any point during an in-progress animation.
     
     - Note: This method has no effect if a scroll animation is NOT already in progress. To prevent automatic scrolling on a newly-initialized label prior to its presentation onscreen, see the `holdScrolling` property.
     
     - SeeAlso: holdScrolling
     - SeeAlso: unpauseLabel
     */
    open func pauseLabel() {
        // Prevent pausing label while not in scrolling animation, or when already paused
        guard (!isPaused && awayFromHome) else {
            return
        }
        
        // Pause sublabel position animations
        let labelPauseTime = sublabel.layer.convertTime(CACurrentMediaTime(), from: nil)
        sublabel.layer.speed = 0.0
        sublabel.layer.timeOffset = labelPauseTime
        
        // Pause gradient fade animation
        let gradientPauseTime = maskLayer?.convertTime(CACurrentMediaTime(), from:nil)
        maskLayer?.speed = 0.0
        maskLayer?.timeOffset = gradientPauseTime!
    }
    
    /**
     Un-pauses a previously paused text scrolling animation. This method has no effect if the label was not previously paused using `pauseLabel`.
     
     - SeeAlso: pauseLabel
     */
    open func unpauseLabel() {
        // Only unpause if label was previously paused
        guard (isPaused) else {
            return
        }
        
        // Unpause sublabel position animations
        let labelPausedTime = sublabel.layer.timeOffset
        sublabel.layer.speed = 1.0
        sublabel.layer.timeOffset = 0.0
        sublabel.layer.beginTime = 0.0
        sublabel.layer.beginTime = sublabel.layer.convertTime(CACurrentMediaTime(), from:nil) - labelPausedTime
        
        // Unpause gradient fade animation
        let gradientPauseTime = maskLayer?.timeOffset
        maskLayer?.speed = 1.0
        maskLayer?.timeOffset = 0.0
        maskLayer?.beginTime = 0.0
        maskLayer?.beginTime = maskLayer!.convertTime(CACurrentMediaTime(), from:nil) - gradientPauseTime!
    }
    
    open func labelWasTapped(_ recognizer: UIGestureRecognizer) {
        if labelShouldScroll() && !awayFromHome {
            beginScroll(true)
        }
    }
    
    /**
     Called when the label animation is about to begin.
     
     The default implementation of this method does nothing. Subclasses may override this method in order to perform any custom actions just as
     the label animation begins. This is only called in the event that the conditions for scrolling to begin are met.
     */
    open func labelWillBeginScroll() {
        // Default implementation does nothing - override to customize
        return
    }
    
    /**
     Called when the label animation has finished, and the label is at the home position.
     
     The default implementation of this method does nothing. Subclasses may override this method in order to perform any custom actions jas as
     the label animation completes, and before the next animation would begin (assuming the scroll conditions are met).
     
     - Parameter finished: A Boolean that indicates whether or not the scroll animation actually finished before the completion handler was called.
     
     - Warning: This method will be called, and the `finished` parameter will be `NO`, when any property changes are made that would cause the label
     scrolling to be automatically reset. This includes changes to label text and font/font size changes.
     */
    open func labelReturnedToHome(_ finished: Bool) {
        // Default implementation does nothing - override to customize
        return
    }
    
    //
    // MARK: - Modified UILabel Functions/Getters/Setters
    //
    
    #if os(iOS)
    override open func forBaselineLayout() -> UIView {
    // Use subLabel view for handling baseline layouts
    return sublabel
    }
    
    open override var forLastBaselineLayout: UIView {
    // Use subLabel view for handling baseline layouts
    return sublabel
    }
    #endif
    
    open override var text: String? {
        get {
            return sublabel.text
        }
        
        set {
            if sublabel.text == newValue {
                return
            }
            sublabel.text = newValue
            updateAndScroll()
            super.text = text
        }
    }
    
    open override var attributedText: NSAttributedString? {
        get {
            return sublabel.attributedText
        }
        
        set {
            if sublabel.attributedText == newValue {
                return
            }
            sublabel.attributedText = newValue
            updateAndScroll()
            super.attributedText = attributedText
        }
    }
    
    open override var font: UIFont! {
        get {
            return sublabel.font
        }
        
        set {
            if sublabel.font == newValue {
                return
            }
            sublabel.font = newValue
            super.font = newValue
            
            updateAndScroll()
        }
    }
    
    open override var textColor: UIColor! {
        get {
            return sublabel.textColor
        }
        
        set {
            sublabel.textColor = newValue
            super.textColor = newValue
        }
    }
    
    open override var backgroundColor: UIColor? {
        get {
            return sublabel.backgroundColor
        }
        
        set {
            sublabel.backgroundColor = newValue
            super.backgroundColor = newValue
        }
    }
    
    open override var shadowColor: UIColor? {
        get {
            return sublabel.shadowColor
        }
        
        set {
            sublabel.shadowColor = newValue
            super.shadowColor = newValue
        }
    }
    
    open override var shadowOffset: CGSize {
        get {
            return sublabel.shadowOffset
        }
        
        set {
            sublabel.shadowOffset = newValue
            super.shadowOffset = newValue
        }
    }
    
    open override var highlightedTextColor: UIColor? {
        get {
            return sublabel.highlightedTextColor
        }
        
        set {
            sublabel.highlightedTextColor = newValue
            super.highlightedTextColor = newValue
        }
    }
    
    open override var isHighlighted: Bool {
        get {
            return sublabel.isHighlighted
        }
        
        set {
            sublabel.isHighlighted = newValue
            super.isHighlighted = newValue
        }
    }
    
    open override var isEnabled: Bool {
        get {
            return sublabel.isEnabled
        }
        
        set {
            sublabel.isEnabled = newValue
            super.isEnabled = newValue
        }
    }
    
    open override var numberOfLines: Int {
        get {
            return super.numberOfLines
        }
        
        set {
            // By the nature of MarqueeLabel, this is 1
            super.numberOfLines = 1
        }
    }
    
    open override var adjustsFontSizeToFitWidth: Bool {
        get {
            return super.adjustsFontSizeToFitWidth
        }
        
        set {
            // By the nature of MarqueeLabel, this is false
            super.adjustsFontSizeToFitWidth = false
        }
    }
    
    open override var minimumScaleFactor: CGFloat {
        get {
            return super.minimumScaleFactor
        }
        
        set {
            super.minimumScaleFactor = 0.0
        }
    }
    
    open override var baselineAdjustment: UIBaselineAdjustment {
        get {
            return sublabel.baselineAdjustment
        }
        
        set {
            sublabel.baselineAdjustment = newValue
            super.baselineAdjustment = newValue
        }
    }
    
    open override var intrinsicContentSize : CGSize {
        var content = sublabel.intrinsicContentSize
        content.width += leadingBuffer
        return content
    }
    
    
    //
    // MARK: - Support
    //
    
    fileprivate func offsetCGPoint(_ point: CGPoint, offset: CGFloat) -> CGPoint {
        return CGPoint(x: point.x + offset, y: point.y)
    }
    
    //
    // MARK: - Deinit
    //
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}


//
// MARK: - Support
//

// Solution from: http://stackoverflow.com/a/24760061/580913
private class CompletionBlock<T> {
    let f : T
    init (_ f: T) { self.f = f }
}

private class GradientAnimation: CABasicAnimation {
    
}

private struct Scroller {
    typealias Scroll = (layer: CALayer, anim: CAKeyframeAnimation)
    
    init(generator gen: @escaping (_ interval: CGFloat, _ delay: CGFloat) -> [Scroll]) {
        self.generator = gen
    }
    
    let generator: (_ interval: CGFloat, _ delay: CGFloat) -> [Scroll]
    var scrolls: [Scroll]? = nil
    
    mutating func generate(_ interval: CGFloat, delay: CGFloat) -> [Scroll] {
        if let existing = scrolls {
            return existing
        } else {
            scrolls = generator(interval, delay)
            return scrolls!
        }
    }
}

private extension UIResponder {
    // Thanks to Phil M
    // http://stackoverflow.com/questions/1340434/get-to-uiviewcontroller-from-uiview-on-iphone
    
    func firstAvailableViewController() -> UIViewController? {
        // convenience function for casting and to "mask" the recursive function
        return self.traverseResponderChainForFirstViewController()
    }
    
    func traverseResponderChainForFirstViewController() -> UIViewController? {
        if let nextResponder = self.next {
            if nextResponder.isKind(of: UIViewController.self) {
                return nextResponder as? UIViewController
            } else if (nextResponder.isKind(of: UIView.self)) {
                return nextResponder.traverseResponderChainForFirstViewController()
            } else {
                return nil
            }
        }
        return nil
    }
}

private extension CAMediaTimingFunction {
    
    func durationPercentageForPositionPercentage(_ positionPercentage: CGFloat, duration: CGFloat) -> CGFloat {
        // Finds the animation duration percentage that corresponds with the given animation "position" percentage.
        // Utilizes Newton's Method to solve for the parametric Bezier curve that is used by CAMediaAnimation.
        
        let controlPoints = self.controlPoints()
        let epsilon: CGFloat = 1.0 / (100.0 * CGFloat(duration))
        
        // Find the t value that gives the position percentage we want
        let t_found = solveTforY(positionPercentage, epsilon: epsilon, controlPoints: controlPoints)
        
        // With that t, find the corresponding animation percentage
        let durationPercentage = XforCurveAt(t_found, controlPoints: controlPoints)
        
        return durationPercentage
    }
    
    func solveTforY(_ y_0: CGFloat, epsilon: CGFloat, controlPoints: [CGPoint]) -> CGFloat {
        // Use Newton's Method: http://en.wikipedia.org/wiki/Newton's_method
        // For first guess, use t = y (i.e. if curve were linear)
        var t0 = y_0
        var t1 = y_0
        var f0, df0: CGFloat
        
        for _ in 0..<15 {
            // Base this iteration of t1 calculated from last iteration
            t0 = t1
            // Calculate f(t0)
            f0 = YforCurveAt(t0, controlPoints:controlPoints) - y_0
            // Check if this is close (enough)
            if (fabs(f0) < epsilon) {
                // Done!
                return t0
            }
            // Else continue Newton's Method
            df0 = derivativeCurveYValueAt(t0, controlPoints:controlPoints)
            // Check if derivative is small or zero ( http://en.wikipedia.org/wiki/Newton's_method#Failure_analysis )
            if (fabs(df0) < 1e-6) {
                break
            }
            // Else recalculate t1
            t1 = t0 - f0/df0
        }
        
        // Give up - shouldn't ever get here...I hope
        //print("MarqueeLabel: Failed to find t for Y input!")
        return t0
    }
    
    func YforCurveAt(_ t: CGFloat, controlPoints:[CGPoint]) -> CGFloat {
        let P0 = controlPoints[0]
        let P1 = controlPoints[1]
        let P2 = controlPoints[2]
        let P3 = controlPoints[3]
        
        // Per http://en.wikipedia.org/wiki/Bezier_curve#Cubic_B.C3.A9zier_curves
        let y0 = (pow((1.0 - t),3.0) * P0.y)
        let y1 = (3.0 * pow(1.0 - t, 2.0) * t * P1.y)
        let y2 = (3.0 * (1.0 - t) * pow(t, 2.0) * P2.y)
        let y3 = (pow(t, 3.0) * P3.y)
        
        return y0 + y1 + y2 + y3
    }
    
    func XforCurveAt(_ t: CGFloat, controlPoints: [CGPoint]) -> CGFloat {
        let P0 = controlPoints[0]
        let P1 = controlPoints[1]
        let P2 = controlPoints[2]
        let P3 = controlPoints[3]
        
        // Per http://en.wikipedia.org/wiki/Bezier_curve#Cubic_B.C3.A9zier_curves
        
        let x0 = (pow((1.0 - t),3.0) * P0.x)
        let x1 = (3.0 * pow(1.0 - t, 2.0) * t * P1.x)
        let x2 = (3.0 * (1.0 - t) * pow(t, 2.0) * P2.x)
        let x3 = (pow(t, 3.0) * P3.x)
        
        return x0 + x1 + x2 + x3
    }
    
    func derivativeCurveYValueAt(_ t: CGFloat, controlPoints: [CGPoint]) -> CGFloat {
        let P0 = controlPoints[0]
        let P1 = controlPoints[1]
        let P2 = controlPoints[2]
        let P3 = controlPoints[3]
        
        let dy0 = (P0.y + 3.0 * P1.y + 3.0 * P2.y - P3.y) * -3.0
        let dy1 = t * (6.0 * P0.y + 6.0 * P2.y)
        let dy2 = (-3.0 * P0.y + 3.0 * P1.y)
        
        return dy0 * pow(t, 2.0) + dy1 + dy2
    }
    
    func controlPoints() -> [CGPoint] {
        // Create point array to point to
        var point: [Float] = [0.0, 0.0]
        var pointArray = [CGPoint]()
        for i in 0...3 {
            self.getControlPoint(at: i, values: &point)
            pointArray.append(CGPoint(x: CGFloat(point[0]), y: CGFloat(point[1])))
        }
        
        return pointArray
    }
}