//
//  StoryPreviewController.swift
//  seiosnativeapp
//
//  Created by BigStep on 30/08/18.
//  Copyright © 2018 bigstep. All rights reserved.
//

import UIKit
import AVKit
import Kingfisher
import Photos

var spb: SegmentedProgressBar!

class StoryPreviewController: UIViewController , SegmentedProgressBarDelegate, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    
    //    var spb: SegmentedProgressBar!
    @IBOutlet weak var viewLeftTap: UIView!
    @IBOutlet weak var viewRightTap: UIView!
    @IBOutlet weak var viewVideo: UIView!
    @IBOutlet weak var imgViewStory: UIImageView!
    @IBOutlet weak var viewSegment: UIView!
    @IBOutlet weak var imgViewVideoOverlay: UIImageView!
    
    @IBOutlet weak var lblReplyIcon: UILabel!
    @IBOutlet weak var viewBottomContainerReply: UIView!
    @IBOutlet weak var viewBottomContainerViewCount: UIView!
    @IBOutlet weak var viewBottomContainer: UIView!
    @IBOutlet weak var viewContainerProfile: UIView!
    
    @IBOutlet weak var txtTemp: UITextView!
    @IBOutlet weak var viewTransText: UIView!
    
    @IBOutlet weak var btnClosePreview: UIButton!
    @IBOutlet weak var viewTableOptionContainer: UIControl!
    
    @IBOutlet weak var btnStoryOption: UIButton!
    @IBOutlet weak var imgViewProfile: DesignableImageView!
    @IBOutlet weak var lblTimeAgo: UILabel!
    
    @IBOutlet weak var btnViewCountIcon: UIButton!
    @IBOutlet weak var lblViewCount: UILabel!
    @IBOutlet weak var btnViewCount: UIButton!
    
    @IBOutlet weak var lblTitleName: UILabel!
    @IBOutlet weak var tblStoryOptions: UITableView!
    
    @IBOutlet weak var viewTableStoryHeight: NSLayoutConstraint!
    @IBOutlet weak var viewTableStory: UIView!
    @IBOutlet weak var btnReply: UIButton!
    @IBOutlet weak var btnReplyIcon: UIButton!
    
    @IBOutlet weak var btnAddStoryIcon: UIButton!
    @IBOutlet weak var lblAddStoryTitle: UILabel!
    @IBOutlet weak var btnAddStory: UIButton!
    
    @IBOutlet weak var txtViewStory: ReadMoreTextView!
    //Story Setting
    
    @IBOutlet weak var viewContainerView: UIView!
    @IBOutlet weak var viewContainerSubView: UIView!
    @IBOutlet weak var viewContainerStorySetting: UIView!
    @IBOutlet weak var viewTableHeight: NSLayoutConstraint!
    @IBOutlet weak var tblPrivacy: UITableView!
    @IBOutlet weak var lblPrivacy: UILabel!
    @IBOutlet weak var txtViewStorySetting: UITextView!
    @IBOutlet weak var lblDescriptionStorySetting: UILabel!
    @IBOutlet weak var viewContainerTableView: UIControl!
    @IBOutlet weak var scrollViewStorySetting: UIScrollView!
    @IBOutlet weak var lblPrivacyAction: UILabel!
    @IBOutlet weak var viewContainerStorySettingTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var tblBottomStorySettingConstraint: NSLayoutConstraint!
    var placeholderLabel : UILabel!
    var arrGetStoryCreate = [CustomFeedPostMenuData]()
    let cellIdentifier = "cell"
    
    //Reply Story
    @IBOutlet weak var viewContainerReplyStory: UIView!
    @IBOutlet weak var lblReplyStory: UILabel!
    @IBOutlet weak var txtViewReply: UITextView!
    var placeholderLabelReply : UILabel!
    
    //Report
    @IBOutlet weak var viewContainerReport: UIView!
    @IBOutlet weak var lblDescriptionReport: UILabel!
    @IBOutlet weak var txtReport: UITextView!
    @IBOutlet weak var lblReporType: UILabel!
    @IBOutlet weak var lblSpam: UILabel!
    
    
    //StoryViewCount
    
    @IBOutlet weak var viewContainerViewCount: UIView!
    @IBOutlet weak var viewCountNoData: UIView!
    @IBOutlet weak var imgViewCountNoData: UIImageView!
    @IBOutlet weak var lblViewCountNoData: UILabel!
    @IBOutlet weak var tblViewCount: UITableView!
    
    @IBOutlet weak var viewContainerTopProfile: UIView!
    
    @IBOutlet weak var imgStoryOptionIcon: UIImageView!
    
    @IBOutlet weak var imgStoryCrossIcon: UIImageView!
    
    @IBOutlet weak var lblMemberViewCount: UILabel!
    @IBOutlet weak var viewmemberViewCount: UIView!
    var isImageVideoReady = 0
    var isImageReadyToPlayButtonClicked = 0
    var rightBarButtonItem : UIBarButtonItem!
    var marqueeHeader : MarqueeLabel!
    var lblDescriptionReportKey = ""
    var lblCategoryKey = ""
    var placeholderLabelReport : UILabel!
    var arrGetStoryReport = [CustomFeedPostMenuData]()
    var strReportKey = ""
    var isKeyReportOrPrivacyUpdate = false
    var arrStoriesOption = [[String : Any]]()
    var currentlySelectedStory = StoriesBrowseData()
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var playbackLikelyToKeepUpKeyPathObserver: NSKeyValueObservation?
    var timeObserverToken: Any?
    var storyId = 0
    var arrStoryIds = [Int]()
    var arrViewCount = [StoriesBrowseData]()
    var arrStoriesData = [StoriesBrowseData]()
    var gestureLong: UILongPressGestureRecognizer!
    var tapRight: UITapGestureRecognizer!
    var tapLeft: UITapGestureRecognizer!
    var leftSwipe: UISwipeGestureRecognizer!
    var rightSwipe: UISwipeGestureRecognizer!
    var time = 0.0
    var index = 0
    var isRewind = false
    var currentStoryIdIndex = 0
    var currentStoryDataIndex = 0
    var strURLReport = ""
    var isMuteStory = false
    var isMovingController = false
    var isAppComingFromBackGround = false
    var isAppComingFromBackGroundDoneOnce = false
    var timeSincePause = 0
    var isTapUsedAfterBackGround = false
    var taskBackgroundToForeground : DispatchWorkItem?
    var animationDurationPeriod : Timer? = nil {
        willSet {
            animationDurationPeriod?.invalidate()
        }
    }
    var timeSinceEnterBeforeForeGround = 0
    var isVideoReadyToPlay = false
    var isViewOffTheScreen = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        lblAddStoryTitle.text = NSLocalizedString("Add to Story",comment: "")
        lblReplyIcon.text = NSLocalizedString("Reply",comment: "")
        
        btnReplyIcon.setImage(UIImage(named: "reply-icon-63152")!.maskWithColor(color: .white), for: .normal)
        tapLeft = UITapGestureRecognizer(target: self, action: #selector(tappedViewLeft))
        tapLeft.delegate = self
        tapLeft.cancelsTouchesInView = false
        viewLeftTap.addGestureRecognizer(tapLeft)
        
        tapRight = UITapGestureRecognizer(target: self, action: #selector(tappedViewRight))
        tapRight.delegate = self
        tapRight.cancelsTouchesInView = false
        viewRightTap.addGestureRecognizer(tapRight)
        
        leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        leftSwipe.direction = .left
        rightSwipe.direction = .right
        self.view.addGestureRecognizer(leftSwipe)
        self.view.addGestureRecognizer(rightSwipe)
        
        tapLeft.require(toFail: leftSwipe)
        tapRight.require(toFail: rightSwipe)
        
        gestureLong = UILongPressGestureRecognizer(target: self, action:  #selector(longPressTapped))
        gestureLong.delegate = self
        gestureLong.minimumPressDuration = 0.15
        self.view.addGestureRecognizer(gestureLong)
        
        self.tblStoryOptions.dataSource = self
        self.tblStoryOptions.delegate = self
        tblStoryOptions.tableFooterView = UIView()
        //viewTableStory.dropShadow()
        currentStoryIdIndex = 0
        
        if isMuteStory
        {
            //API_getMuteStoryPreViewList()
            storyId = arrStoryIds[currentStoryIdIndex]
            API_getStoryPreViewList()
        }
        else
        {
            storyId = arrStoryIds[currentStoryIdIndex]
            API_getStoryPreViewList()
        }
        viewContainerTopProfile.gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.7).cgColor]
        viewContainerTopProfile.gradientLayer.gradient = GradientPoint.bottomTop.draw()
        
        //  viewContainerProfile.gradientLayer.colors = [UIColor.clear.cgColor, UIColor.lightGray.withAlphaComponent(0.15).cgColor]
        //  viewContainerProfile.gradientLayer.gradient = GradientPoint.bottomTop.draw()
        
        viewBottomContainer.gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.7).cgColor]
        viewBottomContainer.gradientLayer.gradient = GradientPoint.topBottom.draw()
        
        storySettingUI()
        
    }
    
    @objc func appMovedToBackground() {
        self.view.endEditing(true)
        pauseCountDownTimer()
        taskBackgroundToForeground?.cancel()
        isTapUsedAfterBackGround = false
        isAppComingFromBackGroundDoneOnce = true
        isAppComingFromBackGround = true
        if viewContainerStorySetting.isHidden == false || viewContainerViewCount.isHidden == false || viewContainerReplyStory.isHidden == false || viewContainerReport.isHidden == false
        {
            //  pauseCountDownTimer()
            if spb != nil
            {
                spb.isPaused = true
                if self.player?.timeControlStatus == .playing && self.viewVideo.isHidden == false {
                    self.player?.pause()
                }
            }
            
        }
        else
        {
            // pauseCountDownTimer()
            if spb != nil
            {
                if self.gestureLong.isEnabled == true
                {
                    spb.isPaused = true
                }
                if self.player?.timeControlStatus == .playing && self.viewVideo.isHidden == false {
                    self.player?.pause()
                }
            }
        }
        
    }
    @objc func applicationDidBecomeActive() {
        // ////print("applicationDidBecomeActive")
        if isAppComingFromBackGroundDoneOnce
        {
            isAppComingFromBackGroundDoneOnce = false
            if viewContainerStorySetting.isHidden == false || viewContainerViewCount.isHidden == false || viewContainerReplyStory.isHidden == false || viewContainerReport.isHidden == false || viewTableOptionContainer.isHidden == false
            {
                if spb != nil
                {
                    let timeT = self.currentlySelectedStory.duration == 0 ? 5 : self.currentlySelectedStory.duration
                    timeSincePause = abs(timeSinceEnterBeforeForeGround - timeT)
                    //  ////print("Story setting timeSincePause==\(timeSincePause)")
                }
                
            }
            else
            {
                if spb != nil
                {
                    if self.gestureLong.isEnabled == true
                    {
                        spb.isPaused = false
                        let timeT = self.currentlySelectedStory.duration == 0 ? 5 : self.currentlySelectedStory.duration
                        //    ////print("Background timer duration==\(timeT)")
                        timeSincePause = abs(timeSinceEnterBeforeForeGround - timeT)
                        //                        ////print("timeSinceEnterBeforeForeGround == \(timeSinceEnterBeforeForeGround)")
                        //                        ////print("nowPuase Remaining == \(timeSincePause)")
                        ////print("applicationDidBecomeActive == 1")
                        resumeCountDownTimer()
                        taskBackgroundToForeground = DispatchWorkItem {
                            if self.isTapUsedAfterBackGround == false
                            {
                                self.pauseCountDownTimer()
                                self.currentStoryDataIndex += 1
                                if self.currentStoryDataIndex < self.arrStoriesData.count
                                {
                                    self.updateDataOfArray(index: self.currentStoryDataIndex, isRewind: false)
                                }
                                else
                                {
                                    self.segmentFinshed()
                                }
                            }
                            
                        }
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(timeSincePause), execute: taskBackgroundToForeground!)
                    }
                    if self.player?.timeControlStatus == .paused && self.viewVideo.isHidden == false {
                        self.player?.play()
                    }
                    
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isViewOffTheScreen = false
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        
        if viewContainerViewCount.isHidden == false
        {
            if let navigationBar = self.navigationController?.navigationBar {
                let firstFrame = CGRect(x: 70, y: 0, width: navigationBar.frame.width - 140, height: navigationBar.frame.height)
                marqueeHeader = MarqueeLabel(frame: firstFrame)
                marqueeHeader.tag = 101
                marqueeHeader.setDefault()
                self.marqueeHeader.text = "Members who viewed your story"
                self.marqueeHeader.textColor = textColorPrime
                navigationBar.addSubview(marqueeHeader)
            }
        }
        else
        {
            UIApplication.shared.isStatusBarHidden = true
            self.navigationController?.isNavigationBarHidden = true
            if isMovingController
            {
                isMovingController = false
                if spb != nil
                {
                    if player?.timeControlStatus == .playing && viewVideo.isHidden == false {
                        videoStop()
                    }
                    spb.rewindCurrent()
                }
            }
        }
        self.tabBarController?.tabBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isViewOffTheScreen = true
        let storiesBrowseData = NSKeyedArchiver.archivedData(withRootObject: arrGetStoryCreate)
        UserDefaults.standard.set(storiesBrowseData, forKey: "arrGetStoryCreate")
        NotificationCenter.default.removeObserver(self)
        pauseCountDownTimer()
        taskBackgroundToForeground?.cancel()
        if viewContainerViewCount.isHidden == false
        {
            if marqueeHeader != nil
            {
                self.marqueeHeader.text = ""
                removeMarqueFroMNavigaTion(controller: self)
            }
        }
        else
        {
            UIApplication.shared.isStatusBarHidden = false
            self.navigationController?.isNavigationBarHidden = false
        }
        self.tabBarController?.tabBar.isHidden = false
  
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let timeObserverToken = timeObserverToken {
            player?.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
        
        player?.pause()
        videoStop()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    func updateUIHiddenViews()
    {
        UIApplication.shared.isStatusBarHidden = true
        gestureLong.isEnabled = true
        tapRight.isEnabled = true
        tapLeft.isEnabled = true
        leftSwipe.isEnabled = true
        rightSwipe.isEnabled = true
        self.navigationController?.isNavigationBarHidden = true
        setViewHideShow(view: viewContainerView, hidden: true)
        setViewHideShow(view: viewContainerStorySetting, hidden: true)
        setViewHideShow(view: viewContainerReplyStory, hidden: true)
        setViewHideShow(view: viewContainerReport, hidden: true)
        setViewHideShow(view: viewContainerViewCount, hidden: true)
    }
    
    // MARK: - Segment Action
    func segmentedProgressBarChangedIndex(index: Int) {
        // ////print("Now showing index: \(index)")
        videoStop()
        taskBackgroundToForeground?.cancel()
        updateUIHiddenViews()
        pauseCountDownTimer()
        updateDataOfArray(index: index, isRewind: false)
    }
    func segmentedProgressBarChangedIndexOnRewind(index: Int)
    {
        taskBackgroundToForeground?.cancel()
        updateUIHiddenViews()
        pauseCountDownTimer()
        updateDataOfArray(index: index, isRewind: true)
    }
    func segmentedProgressBarFinished() {
        videoStop()
        taskBackgroundToForeground?.cancel()
        updateUIHiddenViews()
        segmentFinshed()
    }
    func segmentFinshed()
    {
        isKeyReportOrPrivacyUpdate = false
        pauseCountDownTimer()
        self.currentStoryIdIndex = self.currentStoryIdIndex + 1
        if self.currentStoryIdIndex < self.arrStoryIds.count {
            storyId = arrStoryIds[currentStoryIdIndex]
            imgViewVideoOverlay.image = nil
            imgViewStory.image = nil
            videoStop()
            viewSegment.subviews.forEach({ $0.removeFromSuperview() })
            self.view.slideInFromRight()
            if isMuteStory
            {
                //API_getMuteStoryPreViewList()
            }
            else
            {
                API_getStoryPreViewList()
            }
        }
        else
        {
            self.navigationController?.popViewController(animated: true)
        }
    }
    //MARK:- Data Handling Methods
    func playSegmentAnimation(time : Double, index : Int, isRewind : Bool)
    {
        spb.duration = TimeInterval(time)
        ////print("initialiseCountDownTimer == 1")
        initialiseCountDownTimer()
        if index == 0
        {
            spb.startAnimation()
            self.gestureLong.isEnabled = true
        }
        else
        {
            if isRewind
            {
                spb.nextReWind()
            }
            else
            {
                spb.next()
            }
            self.gestureLong.isEnabled = true
        }
        
    }
    func initialiseCountDownTimer()
    {
        timeSinceEnterBeforeForeGround = 0
        animationDurationPeriod?.invalidate()
        animationDurationPeriod = nil
        if animationDurationPeriod == nil
        {
            animationDurationPeriod = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true)
        }
    }
    func pauseCountDownTimer()
    {
        animationDurationPeriod?.invalidate()
        animationDurationPeriod = nil
        
    }
    func resumeCountDownTimer()
    {
        animationDurationPeriod?.invalidate()
        animationDurationPeriod = nil
        if animationDurationPeriod == nil
        {
            animationDurationPeriod = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true)
        }
    }
    @objc func updateTime(){
        timeSinceEnterBeforeForeGround += 1
        ////print("Playing execution time===\(timeSinceEnterBeforeForeGround)")
    }
    func updateUIData()
    {
        lblTitleName.text = currentlySelectedStory.owner_title
        lblTimeAgo.text = dateDifference(currentlySelectedStory.create_date)
        imgViewProfile.kf.indicatorType = .activity
        if let url = URL(string: currentlySelectedStory.owner_image_icon)
        {
            imgViewProfile.kf.indicatorType = .activity
            (imgViewProfile.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
            imgViewProfile.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                
            })
        }
        if currentlySelectedStory.isStoryDeleted == 0
        {
            imgStoryOptionIcon.isHidden = false
            btnStoryOption.isHidden = false
            btnViewCount.isHidden = false
            btnViewCountIcon.isHidden = false
            lblViewCount.isHidden = false
            arrStoriesOption = currentlySelectedStory.gutterMenu
            viewTableStoryHeight.constant = CGFloat(arrStoriesOption.count * 44)
            tblStoryOptions.reloadData()
        }
        else
        {
            imgStoryOptionIcon.isHidden = true
            btnStoryOption.isHidden = true
            btnViewCount.isHidden = true
            btnViewCountIcon.isHidden = true
            lblViewCount.isHidden = true
        }
        viewBottomContainer.isHidden = false
        if currentlySelectedStory.owner_id == currentUserId
        {
            viewBottomContainerViewCount.isHidden = false
            viewBottomContainerReply.isHidden = true
            lblViewCount.text = "\(currentlySelectedStory.view_count)"
            
        }
        else
        {
            viewBottomContainerViewCount.isHidden = true
            if currentlySelectedStory.isSendMessage == 1
            {
                if currentlySelectedStory.isStoryDeleted == 0
                {
                    viewBottomContainer.isHidden = false
                    viewBottomContainerReply.isHidden = false
                }
                else
                {
                    viewBottomContainer.isHidden = true
                    viewBottomContainerReply.isHidden = true
                }
                
            }
            else
            {
                viewBottomContainer.isHidden = true
                viewBottomContainerReply.isHidden = true
            }
            
        }
        if currentlySelectedStory.description_Stories.length != 0
        {
            txtViewStorySetting.text = currentlySelectedStory.description_Stories
            placeholderLabel.isHidden = !txtViewStorySetting.text.isEmpty
            txtViewStory.isHidden = false
            viewTransText.isHidden = false
            txtViewStory.text = currentlySelectedStory.description_Stories
            txtTemp.text = currentlySelectedStory.description_Stories
            txtViewStorySetting.text = nil
            let readMoreTextAttributes: [NSAttributedString.Key: Any] = [
                NSAttributedString.Key.foregroundColor: UIColor.white,
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)
            ]
            var strTextMore = ""
            var strTextLess = ""
            let numLines = txtTemp.numberOfLines()
            if numLines > 3
            {
                strTextMore = NSLocalizedString(" ...Read more",comment: "")
                strTextLess = NSLocalizedString("  Read less",comment: "")
            }
            txtViewStory.textAlignment = .center
            txtViewStory.attributedReadMoreText = NSAttributedString(string: strTextMore, attributes: readMoreTextAttributes)
            txtViewStory.attributedReadLessText = NSAttributedString(string: strTextLess, attributes: readMoreTextAttributes)
            txtViewStory.maximumNumberOfLines = 3
            txtViewStory.shouldTrim = true
        }
        else
        {
            txtViewStorySetting.text = nil
            txtViewStory.text = nil
            txtViewStory.isHidden = true
            viewTransText.isHidden = true
        }
    }
    func updateDataOfArray(index: Int, isRewind : Bool)
    {
        taskBackgroundToForeground?.cancel()
        activityIndicatorView.stopAnimating()
        self.isImageReadyToPlayButtonClicked = 0
        self.isImageVideoReady = 0
        self.imgViewStory.isHidden = false
        imgViewVideoOverlay.image = nil
        self.currentStoryDataIndex = index
        self.gestureLong.isEnabled = false
        currentlySelectedStory = arrStoriesData[self.currentStoryDataIndex]
        setPrivacyKey(privacy: currentlySelectedStory.privacy)
        updateUIData()
        setViewHideShow(view: viewTableOptionContainer, hidden: true)
        self.index = index
        self.isRewind = isRewind
        if currentlySelectedStory.videoUrl.length == 0
        {
            if let url = URL(string: currentlySelectedStory.image)
            {
                viewVideo.isHidden = true
                imgViewStory.kf.indicatorType = .activity
                (imgViewStory.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                imgViewStory.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                    if index == self.index
                    {
                        if error != nil
                        {
                            let alert = UIAlertController(title: NSLocalizedString("Error",comment: ""), message: NSLocalizedString("Image can't be loaded.",comment: ""), preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                                self.isImageReadyToPlayButtonClicked = 0
                                self.playSegmentAnimation(time: 5, index: self.index, isRewind: self.isRewind)
                            }))
                        }
                        else
                        {
                            ////print("Index value===\(self.index)")
                            ////print("currentStoryDataIndex value===\(self.currentStoryDataIndex)")
                            self.isImageVideoReady = 1
                            if self.isImageReadyToPlayButtonClicked == 0
                            {
                                let timeT = self.currentlySelectedStory.duration == 0 ? 5 : self.currentlySelectedStory.duration
                                self.playSegmentAnimation(time: Double(timeT), index: self.index, isRewind: self.isRewind)
                            }
                        }
                    }
                    
                })
            }
        }
        else
        {
            //  time = Double(Double(currentlySelectedStory.duration) + 0.5)
            if let url = URL(string: currentlySelectedStory.imgVideoOverlay)
            {
                imgViewVideoOverlay.kf.indicatorType = .activity
                (imgViewVideoOverlay.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                imgViewVideoOverlay.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                })
            }
            
            if let url = URL(string: currentlySelectedStory.image)
            {
                imgViewStory.kf.indicatorType = .activity
                (imgViewStory.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                imgViewStory.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                    if index == self.index
                    {
                        self.view.addSubview(activityIndicatorView)
                        activityIndicatorView.center = self.view.center
                        activityIndicatorView.startAnimating()
                        
                        self.viewVideo.isHidden = false
                        self.playVideo(strURL: self.currentlySelectedStory.videoUrl)
                    }
                })
            }
        }
    }
    
    
    // MARK: - Video Play Method
    func videoStop()
    {
        playbackLikelyToKeepUpKeyPathObserver?.invalidate()
        playbackLikelyToKeepUpKeyPathObserver = nil
        if let timeObserverToken = timeObserverToken {
            player?.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
        playerLayer?.player?.pause()
        playerLayer?.removeFromSuperlayer()
        playerLayer?.player = nil
        player = nil
    }
    
    func playVideo(strURL : String)
    {
        videoStop()
        guard let videoURL = URL(string: strURL)
            else {
                ////print("Invalid url ===\(strURL)")
                let alert = UIAlertController(title: NSLocalizedString("Error",comment: ""), message: NSLocalizedString("Can not play this video.",comment: ""), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                    self.isImageReadyToPlayButtonClicked = 0
                    self.playSegmentAnimation(time: 0, index: self.index, isRewind: self.isRewind)
                }))
                self.present(alert, animated: true, completion: nil)
                return
        }
        player = AVPlayer(url: videoURL)
        player?.actionAtItemEnd = .none
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = viewVideo.bounds
        playerLayer?.backgroundColor = UIColor.clear.cgColor
        playerLayer?.videoGravity = .resizeAspect
        viewVideo.layer.addSublayer(playerLayer!)
        viewVideo.layer.backgroundColor = UIColor.clear.cgColor
        viewVideo.alpha = 0.0
        self.view.bringSubviewToFront(spb)
        // player?.automaticallyWaitsToMinimizeStalling = false
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.duckOthers)
        }
        catch {
            // report for an error
        }
        player?.play()
        isVideoReadyToPlay = false
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1.0/60.0, preferredTimescale: Int32(NSEC_PER_SEC)), queue: DispatchQueue.main) { [unowned self] (time) in
            
            if self.isViewOffTheScreen == false
            {
                if self.player?.currentItem?.status == AVPlayerItem.Status.readyToPlay {
                    //                if let isPlaybackLikelyToKeepUp = self?.player?.currentItem?.isPlaybackLikelyToKeepUp, isPlaybackLikelyToKeepUp == true {
                    if self.isVideoReadyToPlay == false
                    {
                        if let duration = self.player?.currentItem?.duration ,
                            !duration.isIndefinite
                        {
                            self.isVideoReadyToPlay = true
                            self.time = duration.seconds
                            self.timerAction()
                        }
                        
                    }
                    
                    //                }
                }
            }
            else
            {
                self.playerLayer?.player?.pause()
                self.playerLayer?.removeFromSuperlayer()
                self.playerLayer?.player = nil
               // self.player = nil
                if let timeObserverToken = self.timeObserverToken {
                    self.player?.removeTimeObserver(timeObserverToken)
                    self.timeObserverToken = nil
                }
            }        
            
            }
        // Register as an observer of the player item's status property
        self.playbackLikelyToKeepUpKeyPathObserver = player?.currentItem?.observe(\.status, options:  [.new, .old], changeHandler: { (playerItem, change) in
            if playerItem.status == .readyToPlay {
                
            }
            else if playerItem.status == .failed
            {
                activityIndicatorView.stopAnimating()
                ////print("playbackLikelyToKeepUpKeyPathObserver failed")
                let alert = UIAlertController(title: NSLocalizedString("Error",comment: ""), message: NSLocalizedString("Can not play this video.",comment: ""), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                    self.isImageReadyToPlayButtonClicked = 0
                    self.playSegmentAnimation(time: 0, index: self.index, isRewind: self.isRewind)
                }))
                self.present(alert, animated: true, completion: nil)
            }
        })
        
        
    }
    // called every time interval from the timer
    @objc func timerAction() {
        viewVideo.alpha = 1.0
        imgViewStory.image = nil
        imgViewStory.isHidden = true
        self.isImageVideoReady = 1
        activityIndicatorView.stopAnimating()
        if self.isImageReadyToPlayButtonClicked == 0
        {
            self.playSegmentAnimation(time: self.time, index: self.index, isRewind: self.isRewind)
        }
        else
        {
            self.player?.pause()
        }
    }
    var playerVideoReady:Bool
    {
        let timeRange = player?.currentItem?.loadedTimeRanges.first as? CMTimeRange
        guard let duration = timeRange?.duration else { return false }
        let timeLoaded = Double(duration.value) / Double(duration.timescale) // value/timescale = seconds
        var margin = self.time
        
        switch self.time {
        case 1..<2:
            margin = 0
        case 2..<3:
            margin = 1
        case 3..<4:
            margin = 2
        case 4..<5:
            margin = 3
        default:
            margin = 4
        }
        
        let loaded = timeLoaded > margin
        // ////print(timeLoaded)
        return player?.currentItem!.status == .readyToPlay && loaded
    }
    // MARK: - Long Press Action
    @objc func longPressTapped(sender : UILongPressGestureRecognizer) {
        if spb != nil
        {
            if sender.state == .began {
                if spb.isPaused != true
                {
                    pauseCountDownTimer()
                    spb.isPaused = true
                    if self.player?.timeControlStatus == .playing && self.viewVideo.isHidden == false {
                        self.player?.pause()
                    }
                }
                setViewHideShow(view: viewContainerProfile, hidden: true)
                setViewHideShow(view: viewBottomContainer, hidden: true)
            }
            else if sender.state == .ended {
                if spb.isPaused != false
                {
                    resumeCountDownTimer()
                    spb.isPaused = false
                    if player?.timeControlStatus == .paused && viewVideo.isHidden == false {
                        player?.play()
                    }
                }
                setViewHideShow(view: viewContainerProfile, hidden: false)
                setViewHideShow(view: viewBottomContainer, hidden: false)
            }
        }
    }
    // MARK: - TapGesture
    @objc func tappedViewLeft() {
        if spb != nil //&& self.gestureLong.isEnabled == true
        {
            isTapUsedAfterBackGround = true
            if self.isImageVideoReady == 1
            {
                if player?.timeControlStatus == .playing && viewVideo.isHidden == false {
                    videoStop()
                }
                spb.rewind()
            }
            else
            {
                ////print("tappedViewLeft Index value===\(self.index)")
                self.imgViewVideoOverlay.kf.cancelDownloadTask()
                self.imgViewStory.kf.cancelDownloadTask()
                self.playSegmentAnimation(time: 0, index: self.index, isRewind: self.isRewind)
                spb.rewind()
            }
        }
        
    }
    @objc func tappedViewRight() {
        if spb != nil //&& self.gestureLong.isEnabled == true
        {
            isTapUsedAfterBackGround = true
            if self.isImageVideoReady == 1
            {
                if player?.timeControlStatus == .playing && viewVideo.isHidden == false {
                    videoStop()
                }
                spb.skip()
            }
            else
            {
                self.imgViewVideoOverlay.kf.cancelDownloadTask()
                self.imgViewStory.kf.cancelDownloadTask()
                self.playSegmentAnimation(time: 0, index: self.index, isRewind: self.isRewind)
            }
            
        }
    }
    func methodSwipeLeft()
    {
        pauseCountDownTimer()
        self.currentStoryIdIndex = self.currentStoryIdIndex + 1
        ////print("Swipe Left index == \(currentStoryIdIndex)")
        if self.currentStoryIdIndex < self.arrStoryIds.count {
            storyId = arrStoryIds[currentStoryIdIndex]
            imgViewStory.image = nil
            imgViewVideoOverlay.image = nil
            videoStop()
            viewSegment.subviews.forEach({ $0.removeFromSuperview() })
            self.view.slideInFromRight()
            if isMuteStory
            {
                //API_getMuteStoryPreViewList()
            }
            else
            {
                API_getStoryPreViewList()
            }
        }
        else
        {
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    // MARK: - Swipe Methods
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        
        //self.view.fadeOut()
        if (sender.direction == .left) {
            methodSwipeLeft()
        }
        
        if (sender.direction == .right) {
            pauseCountDownTimer()
            self.currentStoryIdIndex = self.currentStoryIdIndex - 1
            if currentStoryIdIndex < 0
            {
                self.navigationController?.popViewController(animated: true)
                return
            }
            
            
            ////print("Swipe Right index == \(currentStoryIdIndex)")
            if self.currentStoryIdIndex < self.arrStoryIds.count {
                storyId = arrStoryIds[currentStoryIdIndex]
                imgViewStory.image = nil
                imgViewVideoOverlay.image = nil
                videoStop()
                viewSegment.subviews.forEach({ $0.removeFromSuperview() })
                self.view.slideInFromLeft()
                if isMuteStory
                {
                    //API_getMuteStoryPreViewList()
                }
                else
                {
                    API_getStoryPreViewList()
                }
            }
            else
            {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    //    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    //        return true
    //    }
    
    func setViewHideShow(view: UIView, hidden: Bool) {
        UIView.transition(with: view, duration: 0.3, options: .transitionCrossDissolve, animations: {
            view.isHidden = hidden
        })
    }
    
    func updateStorySettingAPICalling()
    {
        txtViewStory.isHidden = false
        viewTransText.isHidden = false
        txtViewStory.text = nil
        txtViewStory.text = currentlySelectedStory.description_Stories
        txtTemp.text = currentlySelectedStory.description_Stories
        let readMoreTextAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)
        ]
        var strTextMore = ""
        var strTextLess = ""
        let numLines = txtTemp.numberOfLines()
        if numLines > 3
        {
            strTextMore = NSLocalizedString(" ...Read more",comment: "")
            strTextLess = NSLocalizedString("  Read less",comment: "")
        }
        
        txtViewStory.attributedReadMoreText = NSAttributedString(string: strTextMore, attributes: readMoreTextAttributes)
        txtViewStory.attributedReadLessText = NSAttributedString(string: strTextLess, attributes: readMoreTextAttributes)
        txtViewStory.maximumNumberOfLines = 3
        txtViewStory.shouldTrim = true
        
        if self.isAppComingFromBackGround == true
        {
            self.isAppComingFromBackGround = false
            self.backGroundUIUpdate()
        }
        else
        {
            self.resetUI()
        }
    }
    //MARK:- Gesture Delegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is UIButton {
            return false
        }
        else if touch.view is UITextView{
            if touch.view is ReadMoreTextView
            {
                return true
            }
            return false
        }
        if touch.view?.isDescendant(of: tblStoryOptions) == true {
            return false
        }
        if touch.view?.isDescendant(of: tblPrivacy) == true {
            return false
        }
        if touch.view?.isDescendant(of: txtViewStorySetting) == true {
            return false
        }
        if touch.view?.isDescendant(of: txtViewReply) == true {
            return false
        }
        if touch.view?.isDescendant(of: txtReport) == true {
            return false
        }
        if touch.view?.isDescendant(of: viewContainerTableView) == true {
            return false
        }
        if touch.view?.isDescendant(of: viewContainerView) == true {
            return false
        }
        if touch.view?.isDescendant(of: viewContainerSubView) == true {
            return false
        }
        if touch.view?.isDescendant(of: viewContainerReport) == true {
            return false
        }
        if touch.view?.isDescendant(of: viewContainerStorySetting) == true {
            return false
        }
        if touch.view?.isDescendant(of: viewContainerReplyStory) == true {
            return false
        }
        return true
    }
    
    // MARK: TABLEVIEW DATASOURCE and DELEGATES
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tblViewCount
        {
            return arrViewCount.count
        }
        else if viewContainerReport.isHidden == false
        {
            return arrGetStoryReport.count
        }
        else if viewContainerStorySetting.isHidden == false
        {
            return arrGetStoryCreate.count
        }
        else
        {
            return arrStoriesOption.count
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == tblViewCount
        {
            return 70
        }
        else
        {
            return 44
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tblViewCount
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! StoryTableViewCell
            cell.selectionStyle = .none
            let customModel = arrViewCount[indexPath.row]
            cell.lblStoryViewName.text = customModel.owner_title
            cell.lblStoryViewName.textColor = .black
            
            cell.imgStoryView.kf.indicatorType = .activity
            if let url = URL(string: customModel.image)
            {
                cell.imgStoryView.kf.indicatorType = .activity
                (cell.imgStoryView.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                cell.imgStoryView.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                    
                })
            }
            
            
            
            return cell
        }
        else if viewContainerReport.isHidden == false
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! StoryTableViewCell
            cell.selectionStyle = .none
            let customModel = arrGetStoryReport[indexPath.row]
            if let label = cell.lblTitle
            {
                label.text = customModel.value
                label.textColor = textColorMedium
            }
            //  cell.lblTitle.textColor = textColorMedium
            if let imgCheck = cell.imgCheck
            {
                if customModel.isSelected == 1
                {
                    imgCheck.isHidden = false
                    imgCheck.image = UIImage(named: "StoryIcons_Right")
                    imgCheck.backgroundColor = navColor
                }
                else
                {
                    imgCheck.isHidden = true
                }
            }
            
            return cell
        }
        else if viewContainerStorySetting.isHidden == false
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! StoryTableViewCell
            cell.selectionStyle = .none
            let customModel = arrGetStoryCreate[indexPath.row]
            if let label = cell.lblTitle
            {
                label.text = customModel.value
                label.textColor = textColorMedium
            }
            //            cell.lblTitle.textColor = textColorMedium
            if let imgCheck = cell.imgCheck
            {
                if customModel.isSelected == 1
                {
                    imgCheck.isHidden = false
                    imgCheck.image = UIImage(named: "StoryIcons_Right")
                    imgCheck.backgroundColor = navColor
                }
                else
                {
                    imgCheck.isHidden = true
                }
            }
            
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! StoryTableViewCell
            cell.selectionStyle = .none
            let customModel = arrStoriesOption[indexPath.row]
            // cell.viewShadow.dropShadow()
            cell.lblTitleStoryOption.text = customModel["label"] as? String
            cell.lblTitleStoryOption.textColor = textColorDark
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == tblViewCount
        {
            isMovingController = true
            let customModel = arrViewCount[indexPath.row]
            let presentedVC = ContentActivityFeedViewController()
            presentedVC.strProfileImageUrl = customModel.image
            presentedVC.strUserName = customModel.owner_title
            presentedVC.subjectType = "user"
            presentedVC.subjectId = "\(customModel.owner_id)"
            self.navigationController?.pushViewController(presentedVC, animated: true)
        }
        else if viewContainerReport.isHidden == false
        {
            isKeyReportOrPrivacyUpdate = true
            for (index,customModel) in arrGetStoryReport.enumerated() {
                customModel.isSelected = 0
                arrGetStoryReport.remove(at: index)
                arrGetStoryReport.insert(customModel, at: index)
            }
            let customModel = arrGetStoryReport[indexPath.row]
            customModel.isSelected = 1
            strReportKey = customModel.key
            lblSpam.text = customModel.value
            arrGetStoryReport.remove(at: indexPath.row)
            arrGetStoryReport.insert(customModel, at: indexPath.row)
            setViewHideShow(view: viewContainerTableView, hidden: true)
        }
        else  if viewContainerStorySetting.isHidden == false
        {
            isKeyReportOrPrivacyUpdate = true
            for (index,customModel) in arrGetStoryCreate.enumerated() {
                customModel.isSelected = 0
                arrGetStoryCreate.remove(at: index)
                arrGetStoryCreate.insert(customModel, at: index)
            }
            let customModel = arrGetStoryCreate[indexPath.row]
            customModel.isSelected = 1
            strPrivacykey = customModel.key
            lblPrivacyAction.text = customModel.value
            arrGetStoryCreate.remove(at: indexPath.row)
            arrGetStoryCreate.insert(customModel, at: indexPath.row)
            currentlySelectedStory.privacy = strPrivacykey
            arrStoriesData[self.currentStoryDataIndex] = currentlySelectedStory
            
            setViewHideShow(view: viewContainerTableView, hidden: true)
        }
        else
        {
            setViewHideShow(view: viewTableOptionContainer, hidden: true)
            let customModel = arrStoriesOption[indexPath.row]
            let label = customModel["name"] as! String
            if label == "delete" {
                let alert = UIAlertController(title: NSLocalizedString("Delete Entry",comment: ""), message: NSLocalizedString("Are you sure that you want to delete this entry?",comment: ""), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: { action in
                    self.videoImageStatusCheck()
                }))
                alert.addAction(UIAlertAction(title: NSLocalizedString("Delete",comment: ""), style: .default, handler: { action in
                    self.API_callStoryDelete(url: customModel["url"] as! String, method: "DELETE")
                }))
                self.present(alert, animated: true, completion: nil)
                
            }
            else if label == "save"
            {
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAsset(from: self.imgViewStory.image!)
                }, completionHandler: { success, error in
                    
                })
                showToast(message: NSLocalizedString("Your photo will be saved in gallery.",comment: ""), controller: self, onView: false, time: 2.0)
                self.videoImageStatusCheck()
            }
            else if label == "save_video"
            {
                DispatchQueue.global(qos: .background).async {
                    if let url = URL(string: self.currentlySelectedStory.videoUrl),
                        let urlData = NSData(contentsOf: url) {
                        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                        let filePath="\(documentsPath)/\(url.lastPathComponent)"
                        DispatchQueue.main.async {
                            urlData.write(toFile: filePath, atomically: true)
                            PHPhotoLibrary.shared().performChanges({
                                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: filePath))
                            }) { completed, error in
                                if completed {
                                    ////print("Video is saved!")
                                }
                            }
                        }
                    }
                }
                showToast(message: NSLocalizedString("Your video will be saved in gallery.",comment: ""), controller: self, onView: false, time: 2.0)
                self.videoImageStatusCheck()
            }
            else if label == "setting"
            {
                ////print("setting==\(timeSinceEnterBeforeForeGround)")
                let timeT = self.currentlySelectedStory.duration == 0 ? 5 : self.currentlySelectedStory.duration
                timeSincePause = abs(timeSinceEnterBeforeForeGround - timeT)
                ////print("Story setting timeSincePause==\(timeSincePause)")
                
                if marqueeHeader != nil
                {
                    self.marqueeHeader.text = ""
                    removeMarqueFroMNavigaTion(controller: self)
                }
                if self.isImageReadyToPlayButtonClicked != 1
                {
                    pauseCountDownTimer()
                    spb.isPaused = true
                    if self.player?.timeControlStatus == .playing && self.viewVideo.isHidden == false {
                        self.player?.pause()
                    }
                }
                UIApplication.shared.isStatusBarHidden = false
                self.navigationController?.isNavigationBarHidden = false
                self.navigationItem.rightBarButtonItem = rightBarButtonItem
                viewContainerStorySettingTopConstraint.constant = TOPPADING
                if DeviceType.IS_IPHONE_X
                {
                    tblBottomStorySettingConstraint.constant = 20
                }
                gestureLong.isEnabled = false
                tapRight.isEnabled = false
                tapLeft.isEnabled = false
                leftSwipe.isEnabled = false
                rightSwipe.isEnabled = false
                txtViewStorySetting.text = currentlySelectedStory.description_Stories
                self.title = NSLocalizedString("Story Settings",comment: "")
                setViewHideShow(view: viewContainerStorySetting, hidden: false)
                setViewHideShow(view: viewContainerView, hidden: false)
                strURLReport = customModel["url"] as! String
                viewTableHeight.constant = CGFloat(arrGetStoryCreate.count * 44)
            }
            else if label == "report"
            {
                if marqueeHeader != nil
                {
                    self.marqueeHeader.text = ""
                    removeMarqueFroMNavigaTion(controller: self)
                }
                
                if self.isImageReadyToPlayButtonClicked != 1
                {
                    pauseCountDownTimer()
                    spb.isPaused = true
                    if self.player?.timeControlStatus == .playing && self.viewVideo.isHidden == false {
                        self.player?.pause()
                    }
                }
                
                gestureLong.isEnabled = false
                tapRight.isEnabled = false
                tapLeft.isEnabled = false
                leftSwipe.isEnabled = false
                rightSwipe.isEnabled = false
                UIApplication.shared.isStatusBarHidden = false
                self.navigationController?.isNavigationBarHidden = false
                self.navigationItem.rightBarButtonItem = rightBarButtonItem
                viewContainerStorySettingTopConstraint.constant = TOPPADING
                if DeviceType.IS_IPHONE_X
                {
                    tblBottomStorySettingConstraint.constant = 20
                }
                txtReport.text = nil
                self.title = NSLocalizedString("New Report",comment: "")
                setViewHideShow(view: viewContainerReport, hidden: false)
                setViewHideShow(view: viewContainerView, hidden: false)
                strURLReport = customModel["url"] as! String
                if arrGetStoryReport.count == 0
                {
                    API_getReport(url: strURLReport)
                }
            }
            else if label == "mute"
            {
                if isMuteStory
                {
                    
                    let alert = UIAlertController(title: NSLocalizedString("Unmute Story", comment: ""), message: NSLocalizedString("Are you sure that you want to unmute this person?", comment: ""), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: { action in
                        self.videoImageStatusCheck()
                    }))
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Unmute", comment: ""), style: .default, handler: { action in
                        self.API_getMuteUnMute(url: customModel["url"] as! String, isMute: false)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
                else
                {
                    let alert = UIAlertController(title: NSLocalizedString("Mute Story", comment: ""), message: NSLocalizedString("You'll stop seeing their Stories, but can still see their status update in feeds.", comment: ""), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: { action in
                        self.videoImageStatusCheck()
                    }))
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Mute", comment: ""), style: .default, handler: { action in
                        self.API_getMuteUnMute(url: customModel["url"] as! String, isMute: true)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func videoImageStatusCheck()
    {
        if self.isAppComingFromBackGround == true
        {
            //resumeCountDownTimer()
            ////print("videoImageStatusCheck == 1")
            self.isAppComingFromBackGround = false
            if self.player?.timeControlStatus == .paused && self.viewVideo.isHidden == false {
                self.player?.play()
            }
            spb.isPaused = false
            delay(Double(timeSincePause)) {
                self.currentStoryDataIndex += 1
                if self.currentStoryDataIndex < self.arrStoriesData.count
                {
                    self.updateDataOfArray(index: self.currentStoryDataIndex, isRewind: false)
                }
                else
                {
                    self.segmentFinshed()
                }
                
            }
        }
        else
        {
            if self.isImageReadyToPlayButtonClicked == 1 && self.isImageVideoReady == 1
            {
                self.isImageReadyToPlayButtonClicked = 0
                if self.currentlySelectedStory.videoUrl.length != 0
                {
                    self.imgViewStory.isHidden = true
                    activityIndicatorView.stopAnimating()
                    if self.player?.timeControlStatus == .paused && self.viewVideo.isHidden == false {
                        self.player?.play()
                    }
                    self.playSegmentAnimation(time: self.time, index: self.index, isRewind: self.isRewind)
                }
                else
                {
                    let timeT = self.currentlySelectedStory.duration == 0 ? 5 : self.currentlySelectedStory.duration
                    self.playSegmentAnimation(time: Double(timeT), index: self.index, isRewind: self.isRewind)
                }
            }
            else
            {
                if spb != nil
                {
                    ////print("videoImageStatusCheck == 2")
                    // resumeCountDownTimer()
                    spb.isPaused = false
                    if player?.timeControlStatus == .paused && viewVideo.isHidden == false {
                        player?.play()
                    }
                }
            }
        }
        
    }
    //MARK:- IBActions
    
    @IBAction func btnStoryOptionsAction(_ sender: UIButton)
    {
        taskBackgroundToForeground?.cancel()
        if spb != nil
        {
            if self.gestureLong.isEnabled == true
            {
                pauseCountDownTimer()
                isImageReadyToPlayButtonClicked = 0
                spb.isPaused = true
                if self.player?.timeControlStatus == .playing && self.viewVideo.isHidden == false {
                    self.player?.pause()
                }
                
            }
            else
            {
                isImageReadyToPlayButtonClicked = 1
                
            }
            setViewHideShow(view: viewTableOptionContainer, hidden: false)
        }
    }
    @IBAction func btnCloseStoryAction(_ sender: UIButton) {
        videoStop()
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func btnTapProfileAction(_ sender: UIButton)
    {
        
        if spb != nil
        {
            if self.gestureLong.isEnabled == true
            {
                pauseCountDownTimer()
                spb.isPaused = true
                if self.player?.timeControlStatus == .playing && self.viewVideo.isHidden == false {
                    self.player?.pause()
                }
                isImageReadyToPlayButtonClicked = 0
                isMovingController = true
                let presentedVC = ContentActivityFeedViewController()
                presentedVC.strProfileImageUrl = currentlySelectedStory.owner_image_icon
                presentedVC.strUserName = currentlySelectedStory.owner_title
                presentedVC.subjectType = "user"
                presentedVC.subjectId = "\(currentlySelectedStory.owner_id)"
                self.navigationController?.pushViewController(presentedVC, animated: true)
                
            }
            
        }
        
    }
    
    @IBAction func btnViewCountAction(_ sender: UIButton) {
        taskBackgroundToForeground?.cancel()
        pauseCountDownTimer()
        if spb != nil
        {
            if self.gestureLong.isEnabled == true
            {
                
                isImageReadyToPlayButtonClicked = 0
                spb.isPaused = true
                if self.player?.timeControlStatus == .playing && self.viewVideo.isHidden == false {
                    self.player?.pause()
                }
                UIApplication.shared.isStatusBarHidden = false
                self.navigationController?.isNavigationBarHidden = false
                self.navigationItem.rightBarButtonItem = nil
                self.title = nil
                self.viewContainerStorySettingTopConstraint.constant = TOPPADING
                
                if let navigationBar = self.navigationController?.navigationBar {
                    let firstFrame = CGRect(x: 70, y: 0, width: navigationBar.frame.width - 140, height: navigationBar.frame.height)
                    marqueeHeader = MarqueeLabel(frame: firstFrame)
                    marqueeHeader.tag = 101
                    marqueeHeader.setDefault()
                    self.marqueeHeader.text = NSLocalizedString("Members who viewed your story",comment: "")
                    self.marqueeHeader.textColor = textColorPrime
                    navigationBar.addSubview(marqueeHeader)
                }
                viewCountNoData.isHidden = true
                self.setViewHideShow(view: self.viewContainerViewCount, hidden: false)
                self.setViewHideShow(view: self.viewContainerView, hidden: false)
                API_getViewCount()
                
            }
            
        }
        
    }
    
    @IBAction func btnReplyAction(_ sender: UIButton) {
        taskBackgroundToForeground?.cancel()
        pauseCountDownTimer()
        
        if spb != nil
        {
            if self.gestureLong.isEnabled == true
            {
                isImageReadyToPlayButtonClicked = 0
                spb.isPaused = true
                if self.player?.timeControlStatus == .playing && self.viewVideo.isHidden == false {
                    self.player?.pause()
                }
                
            }
            else
            {
                isImageReadyToPlayButtonClicked = 1
                
            }
            
        }
        UIApplication.shared.isStatusBarHidden = false
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        viewContainerStorySettingTopConstraint.constant = TOPPADING
        if DeviceType.IS_IPHONE_X
        {
            tblBottomStorySettingConstraint.constant = 20
        }
        self.title = NSLocalizedString("Reply to story",comment: "")
        setViewHideShow(view: viewContainerReplyStory, hidden: false)
        setViewHideShow(view: viewContainerView, hidden: false)
        
    }
    
    @IBAction func btnAddNextStoryAction(_ sender: UIButton) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc  = storyboard.instantiateViewController(withIdentifier: "StoryController") as! StoryController
        self.navigationController?.pushViewController(vc, animated: false)
        
    }
    
    @IBAction func hideTableViewOption(_ sender: Any) {
        setViewHideShow(view: viewTableOptionContainer, hidden: true)
        self.videoImageStatusCheck()
        
    }
    
    
    @IBAction func btnReportListAction(_ sender: UIButton)
    {
        self.view.endEditing(true)
        viewTableHeight.constant = CGFloat(arrGetStoryReport.count * 44)
        tblPrivacy.reloadData()
        setViewHideShow(view: viewContainerTableView, hidden: false)
    }
    
    @IBAction func btnprivacyAction(_ sender: UIButton) {
        self.view.endEditing(true)
        viewTableHeight.constant = CGFloat(arrGetStoryCreate.count * 44)
        tblPrivacy.reloadData()
        setViewHideShow(view: viewContainerTableView, hidden: false)
    }
    
    
    @IBAction func btnHidePrivayTable(_ sender: Any) {
        setViewHideShow(view: viewContainerTableView, hidden: true)
    }
    
    func setPrivacyKey(privacy : String)
    {
        for (index,customModel) in arrGetStoryCreate.enumerated() {
            if customModel.key == privacy
            {
                customModel.isSelected = 1
                strPrivacykey = customModel.key
                lblPrivacyAction.text = customModel.value
            }
            else
            {
                customModel.isSelected = 0
            }
            arrGetStoryCreate[index] = customModel
        }
    }
    
    //MARK:- SubViews UI
    func reportUI()
    {
        txtReport.delegate = self
        txtReport.textColor = textColorDark
        txtReport.font = UIFont(name: fontName, size: FONTSIZENormal)
        
        lblReporType.textColor = textColorMedium
        lblReporType.font = UIFont(name: fontBold, size: FONTSIZENormal)
        lblReporType.text = NSLocalizedString("Type",comment: "")
        
        lblDescriptionReport.textColor = textColorMedium
        lblDescriptionReport.font = UIFont(name: fontBold, size: FONTSIZENormal)
        lblDescriptionReport.text = NSLocalizedString("Description",comment: "")
        
        lblSpam.textColor = textColorMedium
        lblSpam.font = UIFont(name: fontBold, size: FONTSIZENormal)
        
        placeholderLabelReport = UILabel()
        placeholderLabelReport.text = NSLocalizedString("Description",comment: "")
        placeholderLabelReport.font = txtReport.font
        placeholderLabelReport.sizeToFit()
        txtReport.addSubview(placeholderLabelReport)
        placeholderLabelReport.frame.origin = CGPoint(x: 5, y: (txtReport.font?.pointSize)! / 2)
        placeholderLabelReport.textColor = textColorMedium
        placeholderLabelReport.isHidden = !txtReport.text.isEmpty
        
    }
    func storySettingUI()
    {
        CreateNavigation()
        reportUI()
        viewContainerView.isHidden = true
        viewContainerReport.isHidden = true
        viewContainerReplyStory.isHidden = true
        viewContainerStorySetting.isHidden = true
        viewContainerViewCount.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        scrollViewStorySetting.keyboardDismissMode = .onDrag
        
        txtViewStorySetting.text = currentlySelectedStory.description_Stories
        txtViewStorySetting.delegate = self
        txtViewStorySetting.textColor = textColorDark
        txtViewStorySetting.font = UIFont(name: fontName, size: FONTSIZENormal)
        
        lblPrivacy.textColor = textColorMedium
        lblPrivacy.font = UIFont(name: fontBold, size: FONTSIZENormal)
        lblPrivacy.text = NSLocalizedString("View Privacy",comment: "")
        
        lblDescriptionStorySetting.textColor = textColorMedium
        lblDescriptionStorySetting.font = UIFont(name: fontBold, size: FONTSIZENormal)
        lblDescriptionStorySetting.text = NSLocalizedString("Description",comment: "")
        
        lblPrivacyAction.textColor = textColorDark
        lblPrivacyAction.font = UIFont(name: fontName, size: FONTSIZENormal)
        
        placeholderLabel = UILabel()
        placeholderLabel.text = NSLocalizedString("Description",comment: "")
        placeholderLabel.font = txtViewStorySetting.font
        placeholderLabel.sizeToFit()
        txtViewStorySetting.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (txtViewStorySetting.font?.pointSize)! / 2)
        placeholderLabel.textColor = textColorMedium
        placeholderLabel.isHidden = !txtViewStorySetting.text.isEmpty
        
        if let storiesBrowseData = UserDefaults.standard.object(forKey: "arrGetStoryCreate") as? Data {
            if let arrStoriesDataTemp = NSKeyedUnarchiver.unarchiveObject(with: storiesBrowseData) as? [CustomFeedPostMenuData] {
                arrGetStoryCreate = arrStoriesDataTemp.sorted(by: { $0.value < $1.value })
            }
        }
        for (index, item) in arrGetStoryCreate.enumerated()
        {
            if item.value == NSLocalizedString("Everyone",comment: "")
            {
                arrGetStoryCreate.remove(at: index)
                arrGetStoryCreate.insert(item, at: 0)
            }
            else if item.value == NSLocalizedString("Friends & Networks",comment: "")
            {
                arrGetStoryCreate.remove(at: index)
                arrGetStoryCreate.insert(item, at: 2 < arrGetStoryCreate.count ? 2 : arrGetStoryCreate.count - 1)
            }
            else if item.value == NSLocalizedString("Friends Only",comment: "")
            {
                arrGetStoryCreate.remove(at: index)
                arrGetStoryCreate.insert(item, at: 1 < arrGetStoryCreate.count ? 1 : arrGetStoryCreate.count - 1)
            }
        }
        
        self.tblPrivacy.dataSource = self
        self.tblPrivacy.delegate = self
        tblPrivacy.tableFooterView = UIView()
        
        txtViewReply.delegate = self
        txtViewReply.textColor = textColorDark
        txtViewReply.font = UIFont(name: fontName, size: FONTSIZENormal + 2)
        
        lblReplyStory.textColor = textColorDark
        lblReplyStory.font = UIFont(name: fontBold, size: FONTSIZENormal + 2)
        lblReplyStory.text = NSLocalizedString("Reply to Story",comment: "")
        
        placeholderLabelReply = UILabel()
        placeholderLabelReply.text = NSLocalizedString("Message",comment: "")
        placeholderLabelReply.font = txtViewReply.font
        placeholderLabelReply.sizeToFit()
        txtViewReply.addSubview(placeholderLabelReply)
        placeholderLabelReply.frame.origin = CGPoint(x: 5, y: (txtViewReply.font?.pointSize)! / 2)
        placeholderLabelReply.textColor = textColorMedium
        
        self.tblViewCount.dataSource = self
        self.tblViewCount.delegate = self
        tblViewCount.tableFooterView = UIView()
        lblViewCountNoData.textColor = navColor
        imgViewCountNoData.image = UIImage(named: "eyeIconCount")!.maskWithColor(color: navColor)
        
    }
    func CreateNavigation()
    {
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(backButtonContainer))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        
        let rightNavView = UIView(frame: CGRect(x: 0, y: 0, width: 22, height: 44))
        rightNavView.backgroundColor = UIColor.clear
        let tapViewRight = UITapGestureRecognizer(target: self, action: #selector(backButtonContainerActionData))
        rightNavView.addGestureRecognizer(tapViewRight)
        let backIconImageViewRight = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageViewRight.image = UIImage(named: "StoryIcons_Right")!.maskWithColor(color: textColorPrime)
        rightNavView.addSubview(backIconImageViewRight)
        
        rightBarButtonItem = UIBarButtonItem(customView: rightNavView)
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        
    }
    func backGroundUIUpdate()
    {
        UIApplication.shared.isStatusBarHidden = true
        gestureLong.isEnabled = true
        tapRight.isEnabled = true
        tapLeft.isEnabled = true
        leftSwipe.isEnabled = true
        rightSwipe.isEnabled = true
        self.navigationController?.isNavigationBarHidden = true
        setViewHideShow(view: viewContainerView, hidden: true)
        setViewHideShow(view: viewContainerStorySetting, hidden: true)
        setViewHideShow(view: viewContainerReplyStory, hidden: true)
        setViewHideShow(view: viewContainerReport, hidden: true)
        setViewHideShow(view: viewContainerViewCount, hidden: true)
        ////print("backGroundUIUpdate == 1")
        resumeCountDownTimer()
        if self.player?.timeControlStatus == .paused && self.viewVideo.isHidden == false {
            self.player?.play()
        }
        spb.isPaused = false
        delay(Double(timeSincePause)) {
            self.currentStoryDataIndex += 1
            if self.currentStoryDataIndex < self.arrStoriesData.count
            {
                self.updateDataOfArray(index: self.currentStoryDataIndex, isRewind: false)
            }
            else
            {
                self.segmentFinshed()
            }
            
        }
    }
    
    //MARK:- Navigation Bar Actions
    @objc func backButtonContainer(){
        self.view.endEditing(true)
        if viewContainerViewCount.isHidden == false
        {
            if marqueeHeader != nil
            {
                self.marqueeHeader.text = ""
                removeMarqueFroMNavigaTion(controller: self)
            }
            if isMovingController
            {
                resetUI()
                isMovingController = false
                if spb != nil
                {
                    if player?.timeControlStatus == .playing && viewVideo.isHidden == false {
                        videoStop()
                    }
                    spb.rewindCurrent()
                }
            }
            else
            {
                if isAppComingFromBackGround == true
                {
                    isAppComingFromBackGround = false
                    backGroundUIUpdate()
                }
                else
                {
                    resetUI()
                }
            }
        }
        else
        {
            if isAppComingFromBackGround == true
            {
                isAppComingFromBackGround = false
                backGroundUIUpdate()
            }
            else
            {
                resetUI()
            }
        }
    }
    @objc func backButtonContainerActionData(){
        self.view.endEditing(true)
        if viewContainerStorySetting.isHidden == false
        {
            currentlySelectedStory.description_Stories = txtViewStorySetting.text
            if currentlySelectedStory.description_Stories.length != 0 || isKeyReportOrPrivacyUpdate == true
            {
                self.API_postSettings(url: strURLReport, method: "POST")
            }
            else
            {
                if isAppComingFromBackGround == true
                {
                    isAppComingFromBackGround = false
                    backGroundUIUpdate()
                }
                else
                {
                    resetUI()
                }
            }
        }
        else if viewContainerReplyStory.isHidden == false
        {
            if txtViewReply.text.length != 0
            {
                API_sendReply()
            }
            else
            {
                if isAppComingFromBackGround == true
                {
                    isAppComingFromBackGround = false
                    backGroundUIUpdate()
                }
                else
                {
                    resetUI()
                }
            }
        }
        else if viewContainerReport.isHidden == false
        {
            if txtReport.text.length != 0 || isKeyReportOrPrivacyUpdate == true
            {
                self.API_postReport(url: strURLReport, method: "POST")
            }
            else
            {
                if isAppComingFromBackGround == true
                {
                    isAppComingFromBackGround = false
                    backGroundUIUpdate()
                }
                else
                {
                    resetUI()
                }
            }
        }
        
        
    }
    func resetUI()
    {
        UIApplication.shared.isStatusBarHidden = true
        gestureLong.isEnabled = true
        tapRight.isEnabled = true
        tapLeft.isEnabled = true
        leftSwipe.isEnabled = true
        rightSwipe.isEnabled = true
        self.navigationController?.isNavigationBarHidden = true
        setViewHideShow(view: viewContainerView, hidden: true)
        setViewHideShow(view: viewContainerStorySetting, hidden: true)
        setViewHideShow(view: viewContainerReplyStory, hidden: true)
        setViewHideShow(view: viewContainerReport, hidden: true)
        setViewHideShow(view: viewContainerViewCount, hidden: true)
        videoImageStatusCheck()
    }
    //MARK:- KeyBoard Handling Methods
    @objc func keyboardWillShow(notification: NSNotification) {
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.scrollViewStorySetting.contentInset
        if DeviceType.IS_IPHONE_X
        {
            contentInset.bottom = keyboardFrame.size.height + 120
        }
        else
        {
            contentInset.bottom = keyboardFrame.size.height + 80
        }
        
        scrollViewStorySetting.contentInset = contentInset
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollViewStorySetting.contentInset = contentInset
    }
    
    //MARK:- TextView Delegate
    func textViewDidChange(_ textView: UITextView) {
        if textView == txtViewStorySetting
        {
            txtViewStorySetting.text = textView.text
            placeholderLabel.isHidden = !textView.text.isEmpty
        }
        else if textView == txtViewReply
        {
            txtViewReply.text = textView.text
            placeholderLabelReply.isHidden = !textView.text.isEmpty
        }
        else if textView == txtReport
        {
            txtReport.text = textView.text
            placeholderLabelReport.isHidden = !textView.text.isEmpty
        }
    }
    
    // MARK: - API Methods
    func API_getStoryPreViewList()
    {
        //self.view.fadeIn()
        if Reachabable.isConnectedToNetwork()
        {
            txtViewStory.isHidden = true
            txtViewStory.text = nil
            lblTitleName.text = nil
            lblTimeAgo.text = nil
            imgViewProfile.image = nil
            viewBottomContainer.isHidden = true
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            let parameters = [String:String]()
            post(parameters, url: "advancedactivity/story/view/\(storyId)", method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    //                    self.view.fadeIn()
                    activityIndicatorView.stopAnimating()
                    if msg {
                        
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self, onView: false, time: 2.0)
                            
                        }
                        
                        if let arrTemp = succeeded["body"] as? [AnyObject]
                        {
                            //print(arrTemp)
                            self.arrStoriesData.removeAll()
                            for dicDataValue in arrTemp
                            {
                                let data = StoriesBrowseData()
                                data.isSendMessage = dicDataValue["isSendMessage"] as? Int ?? 0
                                data.story_id = dicDataValue["story_id"] as? Int ?? 0
                                data.owner_id = dicDataValue["owner_id"] as? Int ?? 0
                                data.photo_id = dicDataValue["photo_id"] as? Int ?? 0
                                data.file_id = dicDataValue["file_id"] as? Int ?? 0
                                data.duration = dicDataValue["duration"] as? Int ?? 0
                                data.view_count = dicDataValue["view_count"] as? Int ?? 0
                                data.comment_count = dicDataValue["comment_count"] as? Int ?? 0
                                data.mute_story = dicDataValue["mute_story"] as? Int ?? 0
                                data.status = dicDataValue["status"] as? Int ?? 0
                                data.total_stories = dicDataValue["total_stories"] as? Int ?? 0
                                data.owner_type_Stories = dicDataValue["owner_type"] as? String ?? ""
                                data.privacy = dicDataValue["privacy"] as? String ?? ""
                                data.description_Stories = dicDataValue["description"] as? String ?? ""
                                data.owner_title = dicDataValue["owner_title"] as? String ?? ""
                                data.image = dicDataValue["image"] as? String ?? ""
                                data.content_url = dicDataValue["content_url"] as? String ?? ""
                                data.owner_image_icon = dicDataValue["owner_image"] as? String ?? ""
                                data.videoUrl = dicDataValue["videoUrl"] as? String ?? ""
                                data.create_date = dicDataValue["create_date"] as? String ?? ""
                                if let dicGutter = dicDataValue["gutterMenu"] as? [[String : Any]]
                                {
                                    data.gutterMenu = dicGutter
                                }
                                if let dicVideo = dicDataValue["video_overlay_image"] as? [String : Any]
                                {
                                    data.imgVideoOverlay = dicVideo["url"] as? String ?? ""
                                }
                                self.arrStoriesData.append(data)
                            }
                            if self.arrStoriesData.count != 0
                            {
                                self.imgViewVideoOverlay.image = nil
                                self.imgViewStory.image = nil
                                self.videoStop()
                                self.viewSegment.subviews.forEach({ $0.removeFromSuperview() })
                                self.currentStoryDataIndex = 0
                                let currentlySelectedStory = self.arrStoriesData[self.currentStoryDataIndex]
                                let duration = currentlySelectedStory.duration
                                spb = SegmentedProgressBar(numberOfSegments: self.arrStoriesData.count, duration: duration == 0 ? 5 : TimeInterval(duration) )
                                spb.frame = CGRect(x: 0, y: 0, width: self.viewSegment.frame.width, height: 3)
                                spb.delegate = self
                                spb.topColor = UIColor.white
                                spb.bottomColor = UIColor.white.withAlphaComponent(0.50)
                                spb.padding = 4
                                //spb.dropShadowLight()
                                self.viewSegment.addSubview(spb)
                                self.updateDataOfArray(index: self.currentStoryDataIndex, isRewind: false)
                                
                            }
                            
                        }
                        else
                        {
                            // Handle Server Error
                            if succeeded["message"] != nil && enabledModules.contains("suggestion")
                            {
                                showToast(message: succeeded["message"] as! String, controller: self, onView: false, time: 2.0)
                                
                            }
                        }
                    }
                    else{
                        // Handle Server Side Error
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                    }
                })
                
            }
        }
        else
        {
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self, onView: false, time: 2.0)
        }
    }
    func API_callStoryDelete(url : String, method : String)
    {
        if Reachabable.isConnectedToNetwork()
        {
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            btnClosePreview.isUserInteractionEnabled = false
            let parameters = [String:String]()
            post(parameters, url: url, method: method) { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    self.btnClosePreview.isUserInteractionEnabled = true
                    activityIndicatorView.stopAnimating()
                    if msg {
                        if succeeded["message"] != nil{
                            if method == "DELETE"
                            {
                                showToast(message: NSLocalizedString("Your entry has been deleted successfully.",comment: ""), controller: self, onView: false, time: 2.0)
                            }
                            else
                            {
                                showToast(message: succeeded["message"] as! String, controller: self, onView: false, time: 2.0)
                            }
                            
                        }
                        isViewWillAppearCall = 3
                        if self.currentStoryDataIndex == self.arrStoriesData.count - 1
                        {
                            self.methodSwipeLeft()
                        }
                        else
                        {
                            self.isImageReadyToPlayButtonClicked = 0
                            self.currentlySelectedStory.isStoryDeleted = 1
                            self.arrStoriesData[self.currentStoryDataIndex] = self.currentlySelectedStory
                            if self.player?.timeControlStatus == .playing && self.viewVideo.isHidden == false {
                                self.videoStop()
                            }
                            spb.skip()
                        }
                    }
                    else{
                        // Handle Server Side Error
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self, onView: false, time: 2.0)
                        }
                    }
                })
                
            }
        }
        else
        {
            // No Internet Connection Message
             showToast(message: network_status_msg, controller: self, onView: false, time: 2.0)
        }
    }
    func API_postSettings(url : String, method : String)
    {
        if Reachabable.isConnectedToNetwork()
        {
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            var parameters = [String:String]()
            parameters = ["description" : txtViewStorySetting.text, "privacy" : strPrivacykey]
            //  ////print(parameters)
            post(parameters, url: url, method: method) { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg {
                        self.currentlySelectedStory.description_Stories = self.txtViewStorySetting.text
                        self.updateStorySettingAPICalling()
                    }
                    else{
                        // Handle Server Side Error
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self, onView: false, time: 2.0)
                        }
                    }
                })
                
            }
        }
        else
        {
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self, onView: false, time: 2.0)
        }
    }
    
    func API_postReport(url : String, method : String)
    {
        if Reachabable.isConnectedToNetwork()
        {
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            var parameters = [String:String]()
            parameters = ["description" : txtReport.text, lblCategoryKey : strReportKey, "id" : "\(currentlySelectedStory.story_id)", "type" : "advancedactivity_story"]
            //  ////print(parameters)
            post(parameters, url: url, method: method) { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg {
                        showToast(message: NSLocalizedString("Report successfully submitted.",comment: ""), controller: self, onView: false, time: 2.0)
                        if self.isAppComingFromBackGround == true
                        {
                            self.isAppComingFromBackGround = false
                            self.backGroundUIUpdate()
                        }
                        else
                        {
                            self.resetUI()
                        }
                    }
                    else{
                        // Handle Server Side Error
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self, onView: false, time: 2.0)
                        }
                    }
                })
                
            }
        }
        else
        {
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self, onView: false, time: 2.0)
        }
    }
    func API_getReport(url : String)
    {
        if Reachabable.isConnectedToNetwork()
        {
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            let parameters = [String:String]()
            post(parameters, url: url, method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg {
                        // On Success Update Report Form
                        
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self, onView: false, time: 2.0)
                        }
                        
                        if succeeded["body"] != nil{
                            if let response = succeeded["body"] as? NSArray{
                                self.arrGetStoryReport.removeAll()
                                for dic in (response as? [[String:Any]])! {
                                    
                                    let form = dic
                                    for (key, value) in form {
                                        
                                        if key == "type"
                                        {
                                            if value as! String == "Select"{
                                                self.lblCategoryKey = dic["name"] as! String
                                                if let menu = dic["multiOptions"] as? NSDictionary{
                                                    for (keyM, valueM) in menu
                                                    {
                                                        let data = CustomFeedPostMenuData()
                                                        data.key = "\(keyM)"
                                                        data.value = "\(valueM)"
                                                        self.arrGetStoryReport.append(data)
                                                    }
                                                }
                                                if let valueSelected = dic["value"] as? String{
                                                    for (index,data) in self.arrGetStoryReport.enumerated()
                                                    {
                                                        if data.key == valueSelected
                                                        {
                                                            self.lblSpam.text = data.value
                                                            data.isSelected = 1
                                                            self.arrGetStoryReport[index] = data
                                                            self.strReportKey = data.key
                                                        }
                                                    }
                                                }
                                                
                                            }
                                            if value as! String == "Textarea"{
                                                self.lblDescriptionReport.text = dic["label"] as? String
                                                // self.lblDescriptionReportKey = key as! String
                                            }
                                        }
                                        
                                    }
                                    
                                }
                            }
                            
                        }
                        
                        
                        
                    }
                    else{
                        // Handle Server Side Error
                        if succeeded["message"] != nil{
                           showToast(message: succeeded["message"] as! String, controller: self, onView: false, time: 2.0)
                        }
                    }
                })
                
            }
        }
        else
        {
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self, onView: false, time: 2.0)
        }
    }
    func API_sendReply()
    {
        if Reachabable.isConnectedToNetwork()
        {
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            var path = ""
            var parameters = [String:String]()
            path = "messages/compose"
            //            parameters = ["isStory":"1" ,"post_attach":"1" , "title": "", "toValues":"\(currentlySelectedStory.owner_id)", "body":txtViewReply.text]
            parameters = ["isStory":"1" ,"post_attach":"1" ,"toValues":"\(currentlySelectedStory.owner_id)", "body":txtViewReply.text, "title": "", "story_id": "\(currentlySelectedStory.story_id)"]
            //      ////print(parameters)
            post(parameters, url: path, method: "POST") {
                
                (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    if msg
                    {
                        activityIndicatorView.stopAnimating()
                        showToast(message: NSLocalizedString("You have successfully replied to this story.",comment: ""), controller: self, onView: false, time: 2.0)
                        if self.isAppComingFromBackGround == true
                        {
                            self.isAppComingFromBackGround = false
                            self.backGroundUIUpdate()
                        }
                        else
                        {
                            self.resetUI()
                        }
                    }
                    else{
                        // Handle Server Side Error
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self, onView: false, time: 2.0)
                        }
                    }
                    
                })
                
            }
            
        }
        else
        {
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self, onView: false, time: 2.0)
        }
    }
    func API_getViewCount()
    {
        self.arrViewCount.removeAll()
        self.tblViewCount.reloadData()
        if Reachabable.isConnectedToNetwork()
        {
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            let path = "advancedactivity/story/get-viewer/\(currentlySelectedStory.story_id)"
            var parameters = [String:String]()
            parameters = ["limit": "50"]
            
            // ////print(parameters)
            post(parameters, url: path, method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg {
                        // On Success Update Report Form
                        //    ////print(succeeded)
                        
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self, onView: false, time: 2.0)
                        }
                        
                        if let dict = succeeded["body"] as? [String:AnyObject], let arrTemp = dict["response"] as? [AnyObject]
                        {
                            for dicDataValue in arrTemp
                            {
                                let data = StoriesBrowseData()
                                
                                data.owner_id = dicDataValue["user_id"] as? Int ?? 0
                                data.owner_title = dicDataValue["displayname"] as? String ?? ""
                                data.image = dicDataValue["image"] as? String ?? ""
                                self.arrViewCount.append(data)
                            }
                            self.tblViewCount.reloadData()
                        }
                        if self.arrViewCount.count == 0
                        {
                            self.viewCountNoData.isHidden = false
                            self.tblViewCount.isHidden = true
                            self.viewmemberViewCount.isHidden = true
                        }
                        else
                        {
                            self.viewCountNoData.isHidden = true
                            self.tblViewCount.isHidden = false
                            self.viewmemberViewCount.isHidden = false
                            if self.arrViewCount.count == 1
                            {
                                self.lblMemberViewCount.text = NSLocalizedString("1 member found",comment: "")
                            }
                            else
                            {
                                self.lblMemberViewCount.text = "\(self.arrViewCount.count) \(NSLocalizedString("members found", comment: ""))"
                            }
                        }
                        
                    }
                    else{
                        self.viewCountNoData.isHidden = false
                        // Handle Server Side Error
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self, onView: false, time: 2.0)
                        }
                    }
                })
                
            }
        }
        else
        {
            self.viewCountNoData.isHidden = false
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self, onView: false, time: 2.0)
        }
    }
    func API_getMuteUnMute(url : String, isMute : Bool)
    {
        if Reachabable.isConnectedToNetwork()
        {
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            self.btnClosePreview.isUserInteractionEnabled = false
            var parameters = [String:String]()
            if isMute
            {
                parameters = ["is_mute" : "1"]
            }
            else
            {
                parameters = ["is_mute" : "0"]
            }
            post(parameters, url: url, method: "POST") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    self.btnClosePreview.isUserInteractionEnabled = true
                    if msg {
                        if succeeded["message"] != nil{
                            if self.isMuteStory
                            {
                                isViewWillAppearCall = 5
                                showToast(message: NSLocalizedString("This user has been unmuted successfully.",comment: ""), controller: self, onView: false, time: 2.0)
                            }
                            else
                            {
                                isViewWillAppearCall = 6
                                 showToast(message: "\(self.currentlySelectedStory.owner_title.capitalized) \(NSLocalizedString("has been Muted. You will no longer see story from this person.", comment: ""))", controller: self, onView: false, time: 2.0)
                            }
                            
                        }
                        if self.currentStoryDataIndex == self.arrStoriesData.count - 1
                        {
                            self.methodSwipeLeft()
                        }
                        else
                        {
                            self.isImageReadyToPlayButtonClicked = 0
                            self.currentlySelectedStory.isStoryDeleted = 1
                            self.arrStoriesData[self.currentStoryDataIndex] = self.currentlySelectedStory
                            if self.player?.timeControlStatus == .playing && self.viewVideo.isHidden == false {
                                self.videoStop()
                            }
                            spb.skip()
                        }
                    }
                    else{
                        // Handle Server Side Error
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self, onView: false, time: 2.0)
                        }
                    }
                })
                
            }
        }
        else
        {
            // No Internet Connection Message
           showToast(message: network_status_msg, controller: self, onView: false, time: 2.0)
        }
    }
    
    func API_getMuteStoryPreViewList()
    {
        //self.view.fadeIn()
        if Reachabable.isConnectedToNetwork()
        {
            txtViewStory.isHidden = true
            txtViewStory.text = nil
            lblTitleName.text = nil
            lblTimeAgo.text = nil
            imgViewProfile.image = nil
            viewBottomContainer.isHidden = true
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            let parameters = [String:String]()
            post(parameters, url: "advancedactivity/stories/mutestory-browse", method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    //                    self.view.fadeIn()
                    if msg {
                        
                        if succeeded["message"] != nil{
                           showToast(message: succeeded["message"] as! String, controller: self, onView: false, time: 2.0)
                            
                        }
                        if let response = succeeded["body"] as? [String : AnyObject], let arrTemp = response["response"] as? [AnyObject]
                        {
                            // ////print(arrTemp)
                            self.arrStoriesData.removeAll()
                            for dicDataValue in arrTemp
                            {
                                let data = StoriesBrowseData()
                                data.isSendMessage = dicDataValue["isSendMessage"] as? Int ?? 0
                                data.story_id = dicDataValue["story_id"] as? Int ?? 0
                                data.owner_id = dicDataValue["owner_id"] as? Int ?? 0
                                data.photo_id = dicDataValue["photo_id"] as? Int ?? 0
                                data.file_id = dicDataValue["file_id"] as? Int ?? 0
                                data.duration = dicDataValue["duration"] as? Int ?? 0
                                data.view_count = dicDataValue["view_count"] as? Int ?? 0
                                data.comment_count = dicDataValue["comment_count"] as? Int ?? 0
                                data.mute_story = dicDataValue["mute_story"] as? Int ?? 0
                                data.status = dicDataValue["status"] as? Int ?? 0
                                data.total_stories = dicDataValue["total_stories"] as? Int ?? 0
                                data.owner_type_Stories = dicDataValue["owner_type"] as? String ?? ""
                                data.privacy = dicDataValue["privacy"] as? String ?? ""
                                data.description_Stories = dicDataValue["description"] as? String ?? ""
                                data.owner_title = dicDataValue["owner_title"] as? String ?? ""
                                data.image = dicDataValue["image"] as? String ?? ""
                                data.content_url = dicDataValue["content_url"] as? String ?? ""
                                data.owner_image_icon = dicDataValue["owner_image"] as? String ?? ""
                                data.videoUrl = dicDataValue["videoUrl"] as? String ?? ""
                                data.create_date = dicDataValue["create_date"] as? String ?? ""
                                if let dicGutter = dicDataValue["gutterMenu"] as? [[String : Any]]
                                {
                                    data.gutterMenu = dicGutter
                                }
                                self.arrStoriesData.append(data)
                            }
                            if self.arrStoriesData.count != 0
                            {
                                self.currentStoryDataIndex = 0
                                let currentlySelectedStory = self.arrStoriesData[self.currentStoryDataIndex]
                                let duration = currentlySelectedStory.duration
                                spb = SegmentedProgressBar(numberOfSegments: self.arrStoriesData.count, duration: duration == 0 ? 5 : TimeInterval(duration) )
                                spb.frame = CGRect(x: 0, y: 0, width: self.viewSegment.frame.width, height: 4)
                                spb.delegate = self
                                spb.topColor = UIColor.white
                                spb.bottomColor = UIColor.white.withAlphaComponent(0.25)
                                spb.padding = 2
                                //spb.dropShadowLight()
                                self.viewSegment.addSubview(spb)
                                self.updateDataOfArray(index: self.currentStoryDataIndex, isRewind: false)
                                
                            }
                            
                        }
                        else
                        {
                            // Handle Server Error
                            if succeeded["message"] != nil && enabledModules.contains("suggestion")
                            {
                                showToast(message: succeeded["message"] as! String, controller: self, onView: false, time: 2.0)
                                
                            }
                        }
                    }
                    else{
                        // Handle Server Side Error
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self, onView: false, time: 2.0)
                        }
                    }
                })
                
            }
        }
        else
        {
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self, onView: false, time: 2.0)
        }
    }
}

class OutlinedLabel : UILabel
{
    override func draw(_ rect: CGRect)
    {
        let shadowOffset = self.shadowOffset
        let textColor = self.textColor
        
        let context = UIGraphicsGetCurrentContext()
        context!.setLineWidth(0.3)
        context!.setLineJoin(CGLineJoin.round)
        
        context!.setTextDrawingMode(CGTextDrawingMode.stroke);
        self.textColor = UIColor.white
        super.drawText(in: rect)
        
        context!.setTextDrawingMode(CGTextDrawingMode.fill)
        self.textColor = textColor
        self.shadowOffset = CGSize(width: 0, height: 0)
        super.drawText(in: rect)
        
        self.shadowOffset = shadowOffset
    }
}
extension UITextView{
    
    func numberOfLines() -> Int{
        if let fontUnwrapped = self.font{
            return Int(self.contentSize.height / fontUnwrapped.lineHeight)
        }
        return 0
    }
    
    
}

extension UIView {
    func addGradientWithColorTopToBottom(color: UIColor) {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = [UIColor.clear.cgColor, color.cgColor]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        //        gradient.isOpaque = false
        //        gradient.locations = [0.3, 1.0]
        self.layer.insertSublayer(gradient, at: 0)
    }
    func addGradientWithColorBottomToTop(color: UIColor) {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = [UIColor.clear.cgColor, color.cgColor]
        gradient.startPoint = CGPoint(x: 0.5, y: 1)
        gradient.endPoint = CGPoint(x: 0.5, y: 0)
        //        gradient.isOpaque = false
        //        gradient.locations = [0.3, 1.0]
        self.layer.insertSublayer(gradient, at: 0)
    }
}

extension AVPlayer {
    var ready:Bool {
        let timeRange = currentItem?.loadedTimeRanges.first as? CMTimeRange
        guard let duration = timeRange?.duration else { return false }
        let timeLoaded = Int(duration.value) / Int(duration.timescale) // value/timescale = seconds
        let loaded = timeLoaded > 1
        // ////print(timeLoaded)
        return status == .readyToPlay && loaded
    }
}

extension UIView {
    func fadeIn() {
        // Move our fade out code from earlier
        UIView.animate(withDuration: 1.0, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0 // Instead of a specific instance of, say, birdTypeLabel, we simply set [thisInstance] (ie, self)'s alpha
        }, completion: nil)
    }
    
    func fadeOut() {
        UIView.animate(withDuration: 1.0, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.alpha = 0.0
        }, completion: nil)
    }
    
    // Name this function in a way that makes sense to you...
    // slideFromLeft, slideRight, slideLeftToRight, etc. are great alternative names
    func slideInFromLeft(duration: TimeInterval = 0.4) {
        // Create a CATransition animation
        let slideInFromLeftTransition = CATransition()
        // Customize the animation's properties
        slideInFromLeftTransition.type = CATransitionType.push
        slideInFromLeftTransition.subtype = CATransitionSubtype.fromLeft
        slideInFromLeftTransition.duration = duration
        slideInFromLeftTransition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        slideInFromLeftTransition.fillMode = CAMediaTimingFillMode.removed
        
        // Add the animation to the View's layer
        self.layer.add(slideInFromLeftTransition, forKey: "slideInFromLeftTransition")
    }
    func slideInFromRight(duration: TimeInterval = 0.4) {
        // Create a CATransition animation
        let slideInFromLeftTransition = CATransition()
        // Customize the animation's properties
        slideInFromLeftTransition.type = CATransitionType.push
        slideInFromLeftTransition.subtype = CATransitionSubtype.fromRight
        slideInFromLeftTransition.duration = duration
        slideInFromLeftTransition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        slideInFromLeftTransition.fillMode = CAMediaTimingFillMode.removed
        
        // Add the animation to the View's layer
        self.layer.add(slideInFromLeftTransition, forKey: "slideInFromRightTransition")
    }
}
