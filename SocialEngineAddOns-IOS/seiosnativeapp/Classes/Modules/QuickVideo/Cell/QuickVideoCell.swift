//
//  QuickVideoCell.swift
//  seiosnativeapp
//
//  Created by BigStep on 29/10/18.
//  Copyright © 2018 bigstep. All rights reserved.
//

import UIKit
import AVKit
import Kingfisher
import GradientLoadingBar

class QuickVideoCell: UITableViewCell, TTTAttributedLabelDelegate {
    
    @IBOutlet weak var viewVideo: UIView!
    @IBOutlet weak var imgViewStory: UIImageView!
    @IBOutlet weak var viewContentsContainer: UIView!
    @IBOutlet weak var txtDescReadMore: ReadMoreTextView!    
    //@IBOutlet weak var lblHashTag: OutlinedLabel!
    
    @IBOutlet weak var lblHashTag: TTTAttributedLabel!
    @IBOutlet weak var lblHashTagHeight: NSLayoutConstraint!
    @IBOutlet weak var imgSmallThumbNail: UIButton!
    @IBOutlet weak var imgVideoPause: UIImageView!
    @IBOutlet weak var txtDescReadLess: UITextView!
    @IBOutlet weak var lblTitile: UILabel!
    @IBOutlet weak var imgUserProfile: DesignableImageView!
    @IBOutlet weak var lblCommetCount: UILabel!
    @IBOutlet weak var lblLikeCount: UILabel!
    @IBOutlet weak var btnInfo: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnComments: UIButton!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var btnLike2: UIButton!    
    @IBOutlet weak var lblEndTime: UILabel!
    @IBOutlet weak var lblStartTime: UILabel!
    @IBOutlet weak var imgVideoOverLay: UIImageView!
    @IBOutlet weak var stackViewButtons: UIStackView!
    @IBOutlet weak var imgLike: UIImageView!
    
    @IBOutlet weak var lblTitleBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewProgress: UIView!
    @IBOutlet weak var viewSlider: UIView!
    @IBOutlet weak var viewContainerShare: UIView!
    @IBOutlet weak var viewContainerComments: UIView!
    @IBOutlet weak var btnSlider: UISlider!
    @IBOutlet weak var viewContainerLike: UIView!
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var playbackLikelyToKeepUpKeyPathObserver: NSKeyValueObservation?
    var timer = Timer()
    var objParent : QuickVideoDeviceVC?
    var dataModel : NSMutableDictionary?
    var index = 0
    var feedShowingFrom:String = ""
    var gradientLoadingBar: GradientLoadingBar?
    var videoDataValid = true
    var timeObserverToken: Any?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        imgVideoOverLay.isHidden = true
        imgViewStory.image = nil
        viewSlider.isHidden = true
        txtDescReadMore.shouldTrim = false
        txtDescReadMore.text = nil
        lblEndTime.text = nil
        lblStartTime.text = nil
        btnSlider.value = 0
    }
    
    func configureData(dataModel : NSMutableDictionary)
    {        
        self.dataModel = dataModel
        if player == nil
        {
            if let attachement = dataModel["attachment"] as? [AnyObject]
            {
                if attachement.count != 0
                {
                    videoDataValid =  true
                    if let dicAttachement = attachement[0] as? [String : AnyObject], let videoURL = dicAttachement["attachment_video_url"] as? String
                    {
                        playVideo(strURL: videoURL)
                    }
                }
                else
                {
                    videoDataValid = false
//                    let alertController = UIAlertController(title: "Invalid Video", message:
//                        "Video can't be played as it's corrupted.", preferredStyle: UIAlertController.Style.alert)
//                    alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel,handler: { action in
//                        self.objParent?.nextPlay()
//                    }))
//                    objParent?.present(alertController, animated: true, completion: nil)
                    return
                }
            }
        }
        self.contentView.addSubview(activityIndicatorView)
        activityIndicatorView.center = self.contentView.center
        
        
        lblStartTime.text = "00:00"
        lblEndTime.text = "00:00"
        var attachment_title = ""
        var attachment_description = ""
        if let attachmentArray = dataModel["attachment"] as? NSArray
        {
            if let feed = attachmentArray[0] as? NSDictionary{
                if let attachmetTitle = feed["title"] as? String{
                     if(attachmetTitle.caseInsensitiveCompare("video") != .orderedSame)
                     {
                        attachment_title = String(describing: attachmetTitle)
                     }
                }
                if let attachmentBody = feed["body"]{
                    if attachment_title == ""
                    {
                        attachment_title = String(describing: attachmentBody)
                        attachment_title = Emoticonizer.emoticonizeString("\(attachment_title)" as NSString) as String
                    }
                    else
                    {
                        attachment_description = String(describing: attachmentBody)
                        attachment_description = Emoticonizer.emoticonizeString("\(attachment_description)" as NSString) as String
                    }
                }
            }
        }
        if attachment_title != ""
        {
            lblTitleBottomConstraint.constant = 0
            txtDescReadMore.isHidden = false
            txtDescReadLess.isHidden = true
            
        let attrString: NSMutableAttributedString = NSMutableAttributedString(string: "\(attachment_title)")
        let boldFont = CTFontCreateWithName((fontBold as CFString?)!, FONTSIZENormal - 1, nil)
        attrString.addAttribute(NSAttributedString.Key.font, value: boldFont, range: NSMakeRange(0, attrString.length))
        attrString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSMakeRange(0, attrString.length))
        if attachment_description != ""
        {
            let descString: NSMutableAttributedString = NSMutableAttributedString(string:  String("\n\n\(attachment_description)"))
            descString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: fontName , size: FONTSIZENormal - 1)!, range: NSMakeRange(0, descString.length))
            attrString.append(descString);
        }
        txtDescReadLess.attributedText = attrString
        
        let readMoreTextAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15)
        ]
        var strTextMore = ""
        var strTextLess = ""
        let numLines = txtDescReadLess.numberOfLines()
        if numLines > 4
        {
            strTextMore = NSLocalizedString(" ...Read more",comment: "")
            strTextLess = NSLocalizedString("  Read less",comment: "")
            
            txtDescReadMore.valueDidChangeClosure = {
                let numLines = self.txtDescReadLess.numberOfLines()
                if numLines > 4
                {
                    if self.txtDescReadMore.shouldTrim
                    {
                        self.player?.play()
                        self.imgVideoPause.isHidden = true
                    }
                    else
                    {
                        self.player?.pause()
                        self.imgVideoPause.isHidden = false
                    }
                }
            }
        }
        txtDescReadMore.text = txtDescReadLess.text //dataModel.body
        txtDescReadMore.attributedReadMoreText = NSAttributedString(string: strTextMore, attributes: readMoreTextAttributes)
        txtDescReadMore.attributedReadLessText = NSAttributedString(string: strTextLess, attributes: readMoreTextAttributes)
        txtDescReadMore.maximumNumberOfLines = 4
        txtDescReadMore.shouldTrim = true
        }
        else
        {
            lblTitleBottomConstraint.constant = -34
            txtDescReadMore.isHidden = true
            txtDescReadLess.isHidden = true
        }
        if  let body_param = dataModel["action_type_body_params"] as? NSArray
        {
            if  let body1 = body_param[0] as? NSDictionary
            {
                if let body = body1["label"] as? String
                {
                    lblTitile.font =  UIFont(name: fontName, size:largeFontSize)
                    lblTitile.text = body
                }
            }
        }
        imgUserProfile.kf.indicatorType = .activity
        if let url = URL(string: dataModel["subject_image"] as? String ?? "")
        {
            imgUserProfile.kf.indicatorType = .activity
            (imgUserProfile.kf.indicator?.view as? UIActivityIndicatorView)?.color = navColor
            imgUserProfile.kf.setImage(with: url, placeholder: UIImage(named: "user_profile_image.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
            })
        }
        if let url = URL(string: dataModel["subject_image"] as? String ?? "")
        {
            imgSmallThumbNail.kf.setImage(with: url, for: .normal, placeholder: UIImage(named: "user_profile_image.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
            })
        }
        if dataModel["comment"] as? Bool == true
        {
            viewContainerLike.isHidden = false
            lblLikeCount.text = "\(dataModel["likes_count"] as? Int ?? 0)"
            if ReactionPlugin == true
            {
                let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(sender:)))
                btnLike.addGestureRecognizer(longPressRecognizer)
                
                let longPressRecognizer2 = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(sender:)))
                btnLike2.addGestureRecognizer(longPressRecognizer2)
            }
            likeUnlike()
            browseEmoji()
          viewContainerComments.isHidden = false
          lblCommetCount.text = "\(dataModel["comment_count"] as? Int ?? 0)"
             btnComments.setImage(UIImage(named: "icons_Comment")!.maskWithColor(color: .white), for: .normal)
        }
        else
        {
          viewContainerComments.isHidden = true
            viewContainerLike.isHidden = true
        }
        if dataModel["share"] as? Bool == true{
          viewContainerShare.isHidden = false
             btnShare.setImage(UIImage(named: "icons_Share")!.maskWithColor(color: .white), for: .normal)
        }
        else
        {
            viewContainerShare.isHidden = true
        }
        
        self.stackViewButtons.layoutIfNeeded()
      
        
       
       
        btnInfo.setImage(UIImage(named: "icons_Info")!.maskWithColor(color: .white), for: .normal)
        imgVideoPause.image = UIImage(named: "videoPause")!.maskWithColor(color: .white)
        imgVideoPause.isHidden = true
        
        if dataModel["hashtags"] != nil
        {
            lblHashTag.numberOfLines = 0
            lblHashTag.linkAttributes = [kCTForegroundColorAttributeName:UIColor.white]
            lblHashTag.lineBreakMode = NSLineBreakMode.byWordWrapping
            lblHashTag.isOpaque = true
            
            lblHashTagHeight.constant = 30
            lblHashTag.isHidden = false
            lblHashTag.delegate = self
            var hashtagString : String! = ""
            let hashtags = dataModel["hashtags"] as! NSArray
            hashtagString = hashtags.componentsJoined(by: " ")
            lblHashTag.text = hashtagString
            lblHashTag.font = UIFont(name: fontBold, size: FONTSIZENormal)
            if hashtags.count > 0
            {
                DispatchQueue.global(qos: .userInitiated).async {
                    for i in 0 ..< hashtags.count {
                        let range2 = (hashtagString as NSString).range(of: NSLocalizedString("\(hashtags[i])",  comment: ""))
                        self.lblHashTag.addLink(toTransitInformation: [ "type" : "hashtags", "hashtagString" : "\(hashtags[i])"], with:range2)
                    }
                    DispatchQueue.main.async {
                        
                    }
                }
                
            }
            
        }
        else
        {
            lblHashTagHeight.constant = 0
            lblHashTag.isHidden = true
        }
        
        
        btnSlider.minimumTrackTintColor = navColor
        btnSlider.maximumTrackTintColor = .white
        btnSlider.setThumbImage(UIImage(named: "sliderThumb"), for: .normal)
        btnSlider.setThumbImage(UIImage(named: "sliderThumb"), for: .highlighted)
        gradientLoadingBar = GradientLoadingBar(height: 1.5, durations: Durations(fadeIn: 0.00, fadeOut: 0.00, progress: 3.33), onView: viewProgress)
        
       // delay(0.0) {
            self.viewSlider.isHidden = true
            self.gradientLoadingBar?.show()
       // }
    }
    
    func setupGradientLayer() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientLayer.locations = [0.7, 1.2]
        viewSlider.layer.addSublayer(gradientLayer)
    }
    

    // MARK: - Video Play Method
    func videoStop()
    {
        removeVideoFinishObserver()
        self.timer.invalidate()
        player?.isMuted = true
        let seekTime = CMTime(value: 0, timescale: 1)
        player?.seek(to: seekTime)
        player?.rate = 0.0
        player?.pause()
        player?.replaceCurrentItem(with: nil)
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
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = self.bounds
    }
    
//    override func layoutSublayers(of layer: CALayer) {
//        super.layoutSublayers(of: layer)
//         playerLayer?.frame = self.bounds
//    }
    func playVideo(strURL : String)
    {
        imgViewStory.isHidden = false
        videoStop()
        guard let videoURL = URL(string: strURL)
            else {
                return
        }
        player = AVPlayer(url: videoURL)
        player?.isMuted = false
        player?.actionAtItemEnd = .pause
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.backgroundColor = UIColor.clear.cgColor
        playerLayer?.videoGravity = .resizeAspect
        viewVideo.layer.addSublayer(playerLayer!)
        playerLayer?.frame = self.bounds
        self.layoutIfNeeded()
        viewVideo.layer.backgroundColor = UIColor.clear.cgColor
        viewVideo.alpha = 0.0
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1.0/60.0, preferredTimescale: Int32(NSEC_PER_SEC)), queue: DispatchQueue.main) { [unowned self] (time) in
            if self.objParent?.isViewOffTheScreen == false
            {
            if self.player?.currentItem?.status == AVPlayerItem.Status.readyToPlay {
                if UserDefaults.standard.bool(forKey: "TikTokDemo") == true
                {
                    if self.imgVideoPause.isHidden == true
                    {
                        if let isPlaybackLikelyToKeepUp = self.player?.currentItem?.isPlaybackLikelyToKeepUp, isPlaybackLikelyToKeepUp == true {
                            activityIndicatorView.stopAnimating()

                        }
                        else
                        {
                            activityIndicatorView.startAnimating()
                        }
                    }
                }
            }
            if time.isIndefinite {
                return
            }
            self.gradientLoadingBar?.hide()
            self.viewSlider.isHidden = false
           // self?.timerObserver(time: time)
            if let duration = self.player?.currentItem?.duration ,
                !duration.isIndefinite{
                
                self.lblStartTime.text = self.convert(second: time.seconds)
                self.lblEndTime.text = self.convert(second: duration.seconds-time.seconds)
                let durationTime = CMTimeGetSeconds(duration)
                let time = CMTimeGetSeconds((self.player?.currentTime())!)
                self.btnSlider.value = Float(time / durationTime)
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
        videoFinishObserverAdd()
        if UserDefaults.standard.bool(forKey: "TikTokDemo") == true
        {
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.duckOthers)
            }
            catch {
                // report for an error
            }
            player?.play()
        }
        timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        self.playbackLikelyToKeepUpKeyPathObserver = player?.currentItem?.observe(\.status, options:  [.new, .old], changeHandler: { (playerItem, change) in
            if playerItem.status == .readyToPlay {
            }
            else if playerItem.status == .failed
            {
                self.timer.invalidate()
            }
        })
    }
    
    func playSpecificTimeVideo(strURL : String)
    {
        guard let currentTime = objParent!.currentPlayer?.currentTime().seconds, let timeScale = objParent!.currentPlayer?.currentItem?.asset.duration.timescale
            else {
                return
        }
        let time = CMTimeMakeWithSeconds(currentTime, preferredTimescale: timeScale)
        
        imgViewStory.isHidden = true
       
        guard let videoURL = URL(string: strURL)
            else {
                return
        }

        player = AVPlayer(url: videoURL)
        player?.isMuted = false
        player?.actionAtItemEnd = .pause
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.backgroundColor = UIColor.clear.cgColor
        playerLayer?.videoGravity = .resizeAspect
        viewVideo.layer.addSublayer(playerLayer!)
        playerLayer?.frame = self.bounds
        self.layoutIfNeeded()
        viewVideo.layer.backgroundColor = UIColor.clear.cgColor
        viewVideo.alpha = 0.0
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1.0/60.0, preferredTimescale: Int32(NSEC_PER_SEC)), queue: DispatchQueue.main) { [unowned self] (time) in
            if self.objParent?.isViewOffTheScreen == false
            {
            if self.player?.currentItem?.status == AVPlayerItem.Status.readyToPlay {
                if UserDefaults.standard.bool(forKey: "TikTokDemo") == true
                {
                    if self.imgVideoPause.isHidden == true
                    {
                        if let isPlaybackLikelyToKeepUp = self.player?.currentItem?.isPlaybackLikelyToKeepUp, isPlaybackLikelyToKeepUp == true {
                            activityIndicatorView.stopAnimating()
                            
                        }
                        else
                        {
                            activityIndicatorView.startAnimating()
                        }
                    }
                }
            }
            if time.isIndefinite {
                return
            }
            self.gradientLoadingBar?.hide()
            self.viewSlider.isHidden = false
            //self?.timerObserver(time: time)
            if let duration = self.player?.currentItem?.duration ,
                !duration.isIndefinite{
                
                self.lblStartTime.text = self.convert(second: time.seconds)
                self.lblEndTime.text = self.convert(second: duration.seconds-time.seconds)
                let durationTime = CMTimeGetSeconds(duration)
                let time = CMTimeGetSeconds((self.player?.currentTime())!)
                self.btnSlider.value = Float(time / durationTime)
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
        if UserDefaults.standard.bool(forKey: "TikTokDemo") == true
        {
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.duckOthers)
            }
            catch {
                // report for an error
            }
            self.player?.play()
        }

        videoFinishObserverAdd()

        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        self.playbackLikelyToKeepUpKeyPathObserver = player?.currentItem?.observe(\.status, options:  [.new, .old], changeHandler: { (playerItem, change) in
            if playerItem.status == .readyToPlay {
                self.player?.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero, completionHandler: { (finiesh) in

                })
            }
            else if playerItem.status == .failed
            {
                self.timer.invalidate()
            }
        })
        
    }
    
    func timerObserver(time: CMTime) {
        if let duration = self.player?.currentItem?.duration ,
            !duration.isIndefinite{

            self.lblStartTime.text = self.convert(second: time.seconds)
            self.lblEndTime.text = self.convert(second: duration.seconds-time.seconds)
            let durationTime = CMTimeGetSeconds(duration)
            let time = CMTimeGetSeconds((self.player?.currentTime())!)
            self.btnSlider.value = Float(time / durationTime)
        }
    }
    
    fileprivate func convert(second: Double) -> String {
        let component =  Date.dateComponentFrom(second: second + 1.0)
        if let hour = component.hour ,
            let min = component.minute ,
            let sec = component.second {
            if min >= 0, sec >= 0
            {
                let fix =  hour > 0 ? NSString(format: "%02d:", hour) : ""
                return NSString(format: "%@%02d:%02d", fix,min,sec) as String
            }
            else
            {
                return ""
            }
        } else {
            return "00:00"
        }
    }
    
    
    func videoFinishObserverAdd()
    {
        NotificationCenter.default.addObserver(self, selector:#selector(self.playerDidFinishPlaying(note:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemFailedToPlay(_:)), name: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime, object: nil)
    }
    func removeVideoFinishObserver()
    {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime, object: nil)
    }
    @objc func playerDidFinishPlaying(note: NSNotification){
       // print("Video Finished")
        objParent?.nextPlay()
    }
    @objc func playerItemFailedToPlay(_ notification: Notification) {
        let error = notification.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? Error
        print(error?.localizedDescription)
    }
    
    
    @objc func timerAction() {
        if  playerVideoReady
        {
            viewVideo.alpha = 1.0
            timer.invalidate()
            imgViewStory.isHidden = true
            if self.objParent!.currentPlayer != nil
            {
              self.objParent!.currentPlayer = nil
            }
        }
    }

    var playerVideoReady:Bool
    {
        let timeRange = player?.currentItem?.loadedTimeRanges.first as? CMTimeRange
        guard let duration = timeRange?.duration else { return false }
        let timeLoaded = Double(duration.value) / Double(duration.timescale)
        //print("timeLoaded==\(timeLoaded)")
        let loaded = timeLoaded > 0
        return player?.currentItem!.status == .readyToPlay && loaded
    }
    
    //MARK:-
    
    @IBAction func btnVideoPauseAction(_ sender: Any) {
        if player?.timeControlStatus == .paused {
            txtDescReadMore.shouldTrim = true
            player?.play()
            imgVideoPause.isHidden = true
        }
        else
        {
            player?.pause()
            imgVideoPause.isHidden = false
        }
    }
    @IBAction func btnProfileAction(_ sender: Any) {
        openProfile()
    }
    @IBAction func btnLikeAction(_ sender: Any) {
        if videoDataValid
        {
          feedMenuLike()
        }
    }

    @IBAction func btnCommentAction(_ sender: Any) {
        isViewWillAppearCallContent = 0
        if videoDataValid
        {
          openComments()
        }
    }
    @IBAction func btnShareAction(_ sender: Any) {
        if videoDataValid
        {
          player?.pause()
          feedMenuShare()
        }
    }
    @IBAction func btnSliderValueChange(_ sender: UISlider) {
        if videoDataValid
        {
            if let duration = player?.currentItem?.duration {
                let totalSeconds = CMTimeGetSeconds(duration)
                
                let value = Float64(sender.value) * totalSeconds
                
                let seekTime = CMTime(value: Int64(value), timescale: 1)
                
    //            player?.seek(to: seekTime, completionHandler: { (completedSeek) in
    //                //perhaps do something later here
    //            })
                
                player?.seek(to: seekTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
            }
        }
    }
    
    @IBAction func btnSliderTouchDownBegin(_ sender: UISlider) {
      if imgVideoPause.isHidden == true {
          player?.pause()
        }
    }
    @IBAction func btnSliderTouchEnd(_ sender: UISlider) {
        if imgVideoPause.isHidden == true {
          player?.play()
        }
    }

    @IBAction func btnInfoAction(_ sender: Any) {
        if videoDataValid
        {
            isViewWillAppearCallContent = 0
        if let attachment = dataModel!["attachment"] as? NSArray
        {
            redirectToAdvVideoProfilePageTikTok(videoId: (attachment[0] as! NSDictionary)["attachment_id"] as! Int,videoType:(attachment[0] as! NSDictionary)["attachment_video_type"] as! Int,videoUrl: (attachment[0] as! NSDictionary)["attachment_video_url"] as! String)
        }
        }
        
    }

    func redirectToAdvVideoProfilePageTikTok(videoId : Int, videoType : Int, videoUrl : String){
        isViewWillAppearCallContent = 0
        let presentedVC = AdvanceVideoProfileViewController()
        presentedVC.videoId = videoId
        presentedVC.videoType = videoType
        presentedVC.videoUrl = videoUrl
        presentedVC.delegateAdvanceVideoUI = objParent
        //objParent?.navigationController?.pushViewController(presentedVC, animated: true)
        let nativationController = UINavigationController(rootViewController: presentedVC)
        objParent?.present(nativationController, animated:true, completion: nil)
    }
    
    //MARK:- Method
    func openProfile(){
        isViewWillAppearCallContent = 0
        searchDic.removeAll(keepingCapacity: false)
        let presentedVC = ContentActivityFeedViewController()
        if let imgUrl = dataModel!["subject_image"] as? String
        {
            presentedVC.strProfileImageUrl = imgUrl
        }
        presentedVC.strUserName = lblTitile.text ?? ""
        presentedVC.subjectType = "user"
        presentedVC.fromActivity = false
        presentedVC.subjectId = "\(dataModel!["subject_id"]!)"
        objParent?.navigationController?.pushViewController(presentedVC, animated: true)
        
    }
    func openComments()
    {
        isViewWillAppearCallContent = 0
        likeCommentContent_id = "\(dataModel!["action_id"]!)"
        likeCommentContentType = "activity_action"
        let presentedVC = CommentsViewController()
        presentedVC.openCommentTextView = 1
        presentedVC.activityfeedIndex = index
        presentedVC.isComingFromTikTokPage = true
        presentedVC.activityFeedComment = true
        presentedVC.fromActivityFeed = true
        presentedVC.actionIdDelete = dataModel!["action_id"] as? Int ?? 0
        presentedVC.actionId = "\(dataModel!["action_id"]!)"
        presentedVC.reactionsIcon = []
        presentedVC.fromSingleFeed = true
        presentedVC.isComingFromAAF = true
//        if let attachement = dataModel!["attachment"] as? [AnyObject], let dicAttachement = attachement[0] as? [String : AnyObject], let imgeMain = dicAttachement["image_main"] as? [String : AnyObject],let size = imgeMain["size"] as? [String : AnyObject], let height = size["height"] as? Int
//        {
//            presentedVC.commentTabelHeight = CGFloat(height)
//        }
        if let attachement = dataModel!["attachment"] as? [AnyObject]
        {
            if attachement.count != 0
            {
                if let dicAttachement = attachement[0] as? [String : AnyObject], let imgeMain = dicAttachement["image_main"] as? [String : AnyObject],let size = imgeMain["size"] as? [String : AnyObject], let height = size["height"] as? Int
                {
                    presentedVC.commentTabelHeight = CGFloat(height)
                }
            }
            else
            {
                return
            }
        }
        
        presentedVC.commentPermission = 1 //feed["comment"] as! Int
        presentedVC.commentFeedArray =  feedArrayTikTok
        if feedShowingFrom == "ActivityFeed"
        {
            presentedVC.activityFeedComment = true
            presentedVC.userActivityFeedComment = false
            presentedVC.contentActivityFeedComment = false
            
        }
        else if feedShowingFrom == "UserFeed"
        {
            presentedVC.activityFeedComment = false
            presentedVC.userActivityFeedComment = true
            presentedVC.contentActivityFeedComment = false
        }
        else
        {
            presentedVC.activityFeedComment = false
            presentedVC.userActivityFeedComment = false
            presentedVC.contentActivityFeedComment = true
        }
        presentedVC.delegateComments = objParent
        //objParent?.present(presentedVC, animated: true, completion: nil)
        let nativationController = UINavigationController(rootViewController: presentedVC)
        objParent?.present(nativationController, animated:true, completion: nil)
    }
    func likeUnlike()
    {
        // let title = String(format: NSLocalizedString("%@", comment: ""), likeIcon)
        if ReactionPlugin == true
        {
            if let d = dataModel!["is_like"] as? Bool,d == true
            {
                if let myReaction = dataModel!["my_feed_reaction"] as? NSDictionary
                {
                    if let myIcon = myReaction["reaction_image_icon"] as? String{
                        if let url = NSURL(string:myIcon)
                        {
                            lblLikeCount.text = "\(dataModel!["likes_count"] as? Int ?? 0)"
                            btnLike.isHidden = true
                            imgLike.isHidden = false
                            btnLike2.isHidden = false
                            imgLike.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                            })
                        }
                    }
                }
                else {
                    btnLike.isHidden = false
                    btnLike2.isHidden = true
                    imgLike.isHidden = true
                    btnLike.setImage(UIImage(named: "icons_Like")!.maskWithColor(color: navColor), for: .normal)
                }
            }
            else
            {
                btnLike.isHidden = false
                btnLike2.isHidden = true
                imgLike.isHidden = true
                btnLike.setImage(UIImage(named: "icons_Like")!.maskWithColor(color: .white), for: .normal)
                
            }
        }
        else
        {
            btnLike.isHidden = false
            btnLike2.isHidden = true
            imgLike.isHidden = true
            btnLike.setImage(UIImage(named: "icons_Like")!.maskWithColor(color: .white), for: .normal)
        }
        
    }
    
    func feedMenuLike()
    {
        isViewWillAppearCallContent = 0
        if dataModel!["is_like"] as! Bool == true{
            btnLike.isHidden = false
            btnLike2.isHidden = true
            imgLike.isHidden = true
            btnLike.setImage(UIImage(named: "icons_Like")!.maskWithColor(color: .white), for: .normal)
            if ReactionPlugin == false {
                animationEffectOnButton(btnLike)
            }
            if let count = Int(lblLikeCount.text ?? "0")
            {
                lblLikeCount.text = "\(count - 1)"
            }
        }
        else{
            btnLike.isHidden = false
            btnLike2.isHidden = true
            imgLike.isHidden = true
            btnLike.setImage(UIImage(named: "icons_Like")!.maskWithColor(color: navColor), for: .normal)
            if ReactionPlugin == false {
                animationEffectOnButton(btnLike)
                
            }
            if let count = Int(lblLikeCount.text ?? "0")
            {
                lblLikeCount.text = "\(count + 1)"
            }
        }
        self.isUserInteractionEnabled = false
       // btnLike2.isUserInteractionEnabled = false
        DispatchQueue.main.async(execute:  {
            soundEffect("Like")
        })
        
        if dataModel!["is_like"] as! Bool == false{
            if (ReactionPlugin == true){
                let action_id = dataModel!["action_id"] as! Int
                var reaction = ""
                for (k,v) in reactionsDictionary
                {
                    let v = v as! NSDictionary
                    var updatedDictionary = Dictionary<String, AnyObject>()
                    if  (v["reactionicon_id"] as? Int) != nil
                    {
                        if k as! String == "like"
                        {
                            reaction = (v["reaction"] as? String)!
                            updatedDictionary["reactionicon_id"] = v["reactionicon_id"]  as AnyObject?
                            updatedDictionary["caption" ] = v["caption"]  as AnyObject?
                            
                            if let icon  = v["icon"] as? NSDictionary{
                                
                                updatedDictionary["reaction_image_icon"] = icon["reaction_image_icon"] as! String as AnyObject?
                                
                            }
                            var url = ""
                            url = "advancedactivity/like"
                            
                            DispatchQueue.main.async(execute:  {
                                soundEffect("Like")
                                self.updateReaction(url: url,reaction : reaction,action_id  : action_id, updateMyReaction : updatedDictionary as NSDictionary,feedIndex: self.index)
                            })
                            
                            
                        }
                    }
                }
                
            }
        }
        else
        {
            if (ReactionPlugin == true)
            {
                let action_id = dataModel!["action_id"] as! Int
                let reaction = ""
                var updatedDictionary = Dictionary<String, AnyObject>()
                updatedDictionary = [ : ]
                var url = ""
                url = "advancedactivity/unlike"
                DispatchQueue.main.async(execute:  {
                    soundEffect("Like")
                    self.deleteReaction(url: url,reaction : reaction,action_id  : action_id, updateMyReaction : updatedDictionary as NSDictionary,feedIndex: self.index)
                })
            }
        }
        
    }
    
    
    func updateReaction(url : String,reaction : String,action_id : Int,updateMyReaction : NSDictionary,feedIndex: Int){
        scrollViewEmoji.isHidden = true
        if Reachabable.isConnectedToNetwork() {
            var newDictionary:NSMutableDictionary = [:]
            newDictionary = self.getfeedDic(feed: dataModel!)
            let changedDictionary : NSMutableDictionary = [:]
            changedDictionary.removeAllObjects()
            let tempchangedDictionary : NSMutableDictionary = [:]
            tempchangedDictionary.removeAllObjects()
            var addDictionary : Bool! = false
            let tempLike = dataModel!["is_like"] as! Bool
            if(tempLike == true)
            {
                addDictionary = true
                newDictionary["my_feed_reaction"] = updateMyReaction
                if let myReaction = dataModel!["my_feed_reaction"] as? NSDictionary{
                    
                    if myReaction.count > 0{
                        let reactionId = myReaction["reactionicon_id"] as? Int
                        if let reactions =  dataModel!["feed_reactions"]  as? NSDictionary{
                            if reactions.count > 0{
                           
                                for(k,v) in reactions{
                                    let dicValue = v as! NSDictionary
                                    let currentId = Int((k as! String))
                                    if reactionId == currentId
                                    {
                                        if let countOfFeed = dicValue["reaction_count"] as? Int {
                                            if countOfFeed != 1 {
                                                if let dic = v as? NSDictionary{
                                                    var dict = Dictionary<String, AnyObject>()
                                                    for (key, value) in dic{
                                                        
                                                        if key as! String == "reaction_count"
                                                        {
                                                            dict["reaction_count"] = (value as! Int - 1) as AnyObject?
                                                        }
                                                        else{
                                                            dict["\(key)"] = value as AnyObject?
                                                            
                                                        }
                                                        
                                                    }
                                                    tempchangedDictionary["\(k)"] = dict
                                                    
                                                }
                                            }
                                        }
                                    }
                                    else{
                                        tempchangedDictionary["\(k)"] = v
                                    }
                                    
                                }
                                
                                // add reaction that you like in feed_reaction Dictionary
                                for(k,v) in tempchangedDictionary{
                                    let idReaction : Int = updateMyReaction["reactionicon_id"] as! Int
                                    let currentId = Int((k as! String))
                                    if currentId == idReaction {
                                        addDictionary = false
                                        var dict = Dictionary<String, AnyObject>()
                                        if let dic = v as? NSDictionary{
                                            for (key, value) in dic{
                                                if key as! String == "reaction_count" {
                                                    dict["reaction_count"] = ((value as! Int) + 1) as AnyObject
                                                }
                                                else{
                                                    dict["\(key)"] = value as AnyObject?
                                                }
                                            }
                                            changedDictionary["\(k)"] = dict
                                        }
                                    }
                                    else{
                                        changedDictionary["\(k)"] = v
                                    }
                                }
                                
                            }
                            
                            
                        }
                        
                    }
                }
                
                
            }
            else
            {
                addDictionary = true
                newDictionary["is_like"] = true
                newDictionary["likes_count"] = ((dataModel!["likes_count"] as? Int)!+1)
                newDictionary["my_feed_reaction"] = updateMyReaction
                
                if newDictionary["feed_Type"] as! String != "share"
                {
                    let temp = newDictionary["photo_attachment_count"] as? Int
                    
                    if temp == 1 {
                        
                        if newDictionary["attachment"] != nil
                        {
                            var dic:NSMutableDictionary = [:]
                            let array = newDictionary["attachment"] as! NSMutableArray
                            //print(array)
                            dic = array[0] as! NSMutableDictionary
                            if dic["is_like"] != nil
                            {
                                let temp = newDictionary["photo_attachment_count"] as? Int
                                
                                if temp == 1 {
                                    
                                    if newDictionary["attachment"] != nil
                                    {
                                        var dic:NSMutableDictionary = [:]
                                        let array = newDictionary["attachment"] as! NSMutableArray
                                        dic = array[0] as! NSMutableDictionary
                                        if dic["is_like"] != nil
                                        {
                                            dic["is_like"] = true
                                        }
                                        array.removeObject(at: 0)
                                        array.add(dic)
                                        newDictionary["attachment"] = array
                                        
                                    }
                                }
                            }
                            
                            if dic["likes_count"] != nil
                            {
                                
                                dic["likes_count"] = ((dataModel!["likes_count"] as? Int)!+1)
                            }
                            array.removeObject(at: 0)
                            array.add(dic)
                            newDictionary["attachment"] = array
                            //print(array)
                            
                        }
                    }
                }
                
                if let reactions =  dataModel!["feed_reactions"]  as? NSDictionary{
                    if reactions.count > 0{
                        
                        for(k,v) in reactions{
                            
                            let idReaction : Int = updateMyReaction["reactionicon_id"] as! Int
                            let currentId = Int((k as! String))
                            if currentId == idReaction {
                                addDictionary = false
                                var dict = Dictionary<String, AnyObject>()
                                if let dic = v as? NSDictionary{
                                    for (key, value) in dic{
                                        
                                        if key as! String == "reaction_count" {
                                            let reactioncount = ((value as! Int) + 1)
                                            dict["reaction_count"] = reactioncount as AnyObject?
                                            
                                        }
                                        else{
                                            dict["\(key)"] = value as AnyObject?
                                            
                                        }
                                        
                                    }
                                    
                                    changedDictionary["\(k)"] = dict
                                    
                                }
                            }
                            else{
                                changedDictionary["\(k)"] = v
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
            
            if addDictionary == true{
                var dict2 = Dictionary<String, AnyObject>()
                for (k,v) in updateMyReaction{
                    dict2["\(k)"] = v as AnyObject?
                    
                }
                dict2["reaction_count"] = 1 as AnyObject?
                changedDictionary["\(updateMyReaction["reactionicon_id"]!)"] = dict2
                
            }
            
            
            // Updating attachment array while liking or reacting any image feed
            if let arr = dataModel!["attachment"] as? NSMutableArray
            {
                // //print(arr)
                let  attachmentDic = arr[0] as! NSMutableDictionary
                attachmentDic["is_like"] = newDictionary["is_like"]
                attachmentDic["likes_count"] = newDictionary["likes_count"]
                //  total_Likes = newDictionary["likes_count"] as? Int ?? 0
                attachmentDic["comment_count"] = newDictionary["comment_count"]
                
                let reactionDic : NSMutableDictionary = [:]
                reactionDic["feed_reactions"] = changedDictionary
                reactionDic["my_feed_reaction"] = updateMyReaction
                attachmentDic["reactions"] = reactionDic
                arr[0] = attachmentDic
                newDictionary["attachment"] = arr
                ////print(arr)
            }
            newDictionary["feed_reactions"] = changedDictionary
            feedArrayTikTok[index] = newDictionary
            updateFeedArray(newDic: newDictionary)
            //   objParent?.tblTikTok.reloadData()
            dataModel = newDictionary
            likeUnlike()
            var dic = Dictionary<String, String>()
            dic["reaction"] = "\(reaction)"
            dic["action_id"] = "\(action_id)"
            dic["sendNotification"] = "\(0)"
            //  userInteractionOff = false
            // Send Server Request to Update Feed Gutter Menu
            post(dic, url: "\(url)", method: "POST") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    //  userInteractionOff = true
                    if msg{
                        // On Success Update Feed Gutter Menu
                        self.isUserInteractionEnabled = true
                        //self.btnLike2.isUserInteractionEnabled = true
                        var url = ""
                        url = "advancedactivity/send-like-notitfication"
                        var dict = Dictionary<String, String>()
                        dict["action_id"] = "\(action_id)"
                        // call notificatiom
                        if Reachabable.isConnectedToNetwork() {
                            removeAlert()
                            post(dic, url: "\(url)", method: "POST") { (succeeded, msg) -> () in
                                //                                DispatchQueue.main.async(execute:{
                                //                                    userInteractionOff = true
                                //
                                //                                })
                            }
                        }
                        
                    }
                    
                })
                
            }
            
        }
    }
    func deleteReaction(url : String,reaction : String,action_id : Int,updateMyReaction : NSDictionary,feedIndex: Int)
    {
        scrollViewEmoji.isHidden = true
        if Reachabable.isConnectedToNetwork()
        {
            removeAlert()
            
            var dic = Dictionary<String, String>()
            dic["reaction"] = "\(reaction)"
            dic["action_id"] = "\(action_id)"
            var newDictionary:NSMutableDictionary = [:]
            newDictionary = self.getfeedDic(feed: dataModel!)
            
            let changedDictionary : NSMutableDictionary = [:]
            let tempLike = dataModel!["is_like"] as! Bool
            if(tempLike == true)
            {
                
                newDictionary["is_like"] = false
                newDictionary["likes_count"] = ((dataModel!["likes_count"] as? Int)!-1)
                newDictionary["my_feed_reaction"] = updateMyReaction
                if newDictionary["feed_Type"] as! String != "share"
                {
                    let temp = newDictionary["photo_attachment_count"] as? Int
                    
                    if temp == 1 {
                        
                        if newDictionary["attachment"] != nil
                        {
                            var dic:NSMutableDictionary = [:]
                            let array = newDictionary["attachment"] as! NSMutableArray
                            //print(array)
                            
                            dic = array[0] as! NSMutableDictionary
                            if dic["is_like"] != nil
                            {
                                dic["is_like"] = false
                            }
                            if dic["likes_count"] != nil
                            {
                                
                                dic["likes_count"] = ((dataModel!["likes_count"] as? Int)!-1)
                            }
                            if dic["like_count"] != nil
                            {
                                
                                dic["like_count"] = ((dataModel!["likes_count"] as? Int)!-1)
                            }
                            
                            dic["comment_count"] = newDictionary["comment_count"]
                            
                            array.removeObject(at: 0)
                            array.add(dic)
                            newDictionary["attachment"] = array
                            //print(array)
                        }
                    }
                }
                if let reactions =  dataModel!["feed_reactions"]  as? NSDictionary
                {
                    for(k,v) in reactions
                    {
                        let dicValue = v as! NSDictionary
                        let currentId = Int((k as! String))
                        if let myReaction = dataModel!["my_feed_reaction"] as? NSDictionary{
                            if myReaction.count > 0
                            {
                                if let reactionId = myReaction["reactionicon_id"] as? Int
                                {
                                    
                                    if reactionId == currentId
                                    {
                                        if let countOfFeed = dicValue["reaction_count"] as? Int {
                                            if countOfFeed != 1{
                                                
                                                var dict = Dictionary<String, AnyObject>()
                                                if let dic = v as? NSDictionary{
                                                    
                                                    for (key, value) in dic
                                                    {
                                                        
                                                        if key as! String == "reaction_count"
                                                        {
                                                            dict["reaction_count"] = (value as! Int - 1) as AnyObject?
                                                        }
                                                        else
                                                        {
                                                            dict["\(key)"] = value as AnyObject?
                                                            
                                                        }
                                                        
                                                    }
                                                    changedDictionary["\(k)"] = dict
                                                }
                                                
                                            }
                                        }
                                        
                                    }
                                    else{
                                        changedDictionary["\(k)"] = v
                                    }
                                }
                                else
                                {
                                    changedDictionary["\(k)"] = v
                                    
                                }
                            }
                            else
                            {
                                changedDictionary["\(k)"] = v
                                
                            }
                        }
                    }
                    
                }
            }
            newDictionary["feed_reactions"] = changedDictionary
            newDictionary["my_feed_reaction"] = updateMyReaction
            if let arr = newDictionary["attachment"] as? NSMutableArray
            {
                
                let  attachmentDic = arr[0] as! NSMutableDictionary
                var reactionDic : NSMutableDictionary = [:]
                if attachmentDic["reactions"] != nil {
                    reactionDic = attachmentDic["reactions"] as! NSMutableDictionary
                    reactionDic["feed_reactions"] = changedDictionary
                    reactionDic["my_feed_reaction"] = updateMyReaction
                    attachmentDic["reactions"] = reactionDic
                    arr[0] = attachmentDic
                    newDictionary["attachment"] = arr
                }
                
            }
            feedArrayTikTok[index] = newDictionary
            updateFeedArray(newDic: newDictionary)
            //objParent?.tblTikTok.reloadData()
            dataModel = newDictionary
            likeUnlike()
            post(dic, url: "\(url)", method: "POST") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    //   userInteractionOff = true
                    self.isUserInteractionEnabled = true
                    //self.btnLike2.isUserInteractionEnabled = true
                    if msg
                    {
                        
                        // On Success Update Feed Gutter Menu
                        
                    }
                    
                })
                
            }
            
        }
    }
    
    func updateFeedArray(newDic : NSMutableDictionary)
    {
        if feedShowingFrom == "ActivityFeed"
        {
            for (index, dic) in feedArray.enumerated()
            {
                if dic["action_id"] as! Int == newDic["action_id"] as! Int
                {
                    feedArray[index] = newDic
                }
            }
        }
        else if feedShowingFrom == "UserFeed"
        {
            contentfeedArrUpdate = true
            for (index, dic) in userFeedArray.enumerated()
            {
                if dic["action_id"] as! Int == newDic["action_id"] as! Int
                {
                    userFeedArray[index] = newDic
                }
            }
        }
        else
        {
            if contentFeedArray.count > 0
            {
                for (index, dic) in contentFeedArray.enumerated()
                {
                    if dic["action_id"] as! Int == newDic["action_id"] as! Int
                    {
                        contentFeedArray[index] = newDic
                    }
                }
            }
            else
            {
                for (index, dic) in userFeedArray.enumerated()
                {
                    if dic["action_id"] as! Int == newDic["action_id"] as! Int
                    {
                        userFeedArray[index] = newDic
                    }
                }
            }
        }
    }
    @objc func longPressed(sender: UILongPressGestureRecognizer)
    {
        let tapLocation = stackViewButtons.frame.origin//sender.location(in: stackViewButtons)
        // scrollViewEmoji.frame.size.width = self.contentView.bounds.width-50
        if sender.state == .began {
            soundEffect("reactions_popup")
            scrollViewEmoji.frame.origin.x = tapLocation.x - scrollViewEmoji.frame.size.width + 10
            scrollViewEmoji.frame.origin.y = tapLocation.y - 10

            if tableViewFrameType == "CommentsViewController"
            {
                UIApplication.shared.keyWindow?.removeGestureRecognizer(sender)

            }
            else
            {
                self.contentView.removeGestureRecognizer(sender)
            }
            //Do Whatever You want on Began of Gesture
            scrollViewEmoji.alpha = 0
            scrollViewEmoji.isHidden = false
            scrollViewEmoji.tag =  index
            if tableViewFrameType == "CommentsViewController"
            {
                let tapLocation1 = sender.location(in: UIApplication.shared.keyWindow)
                scrollViewEmoji.frame.origin.y = tapLocation1.y - 90
                UIApplication.shared.keyWindow?.addSubview(scrollViewEmoji)
            }
            else
            {
                self.contentView.addSubview(scrollViewEmoji)
            }
            UIView.animate(withDuration: 0.5, delay: 0.4, options: .curveEaseOut, animations: {
                scrollViewEmoji.alpha = 1
            }, completion: nil)

        }


    }
    
//    @objc func longPressed(sender: UILongPressGestureRecognizer)
//    {
//        arrowView.layer.shadowColor = UIColor.black.cgColor
//        arrowView.layer.borderColor = UIColor.black.cgColor
//        //scrollviewEmojiLikeView.backgroundColor = UIColor.black.withAlphaComponent(0.85)//UIColor.clear
//        arrowView.backgroundColor = UIColor.black.withAlphaComponent(0.85)
//        arrowView.transform = .identity
//        let  Currentcell = (sender.view?.tag)!
//        let tapLocation = sender.location(in: self)
//        if sender.state == .began {
//            soundEffect("reactions_popup")
//            scrollViewEmoji.center = (parentViewController()?.view.center)!
//            scrollViewEmoji.frame.origin.y = (parentViewController()?.view.bounds.height )! - (tabBarHeight + self.frame.size.height + scrollViewEmoji.frame.size.height + 10)
//            arrowView.alpha = 0
//            arrowView.frame.origin = CGPoint(x: scrollViewEmoji.frame.origin.x + 30, y: getBottomEdgeY(inputView: scrollViewEmoji) - 2)
//            arrowView.alpha = 0
//            arrowView.tag = Currentcell
//            scrollViewEmoji.alpha = 0
//            scrollViewEmoji.isHidden = false
//            scrollViewEmoji.tag =  Currentcell
//            parentViewController()?.view.removeGestureRecognizer(sender)
//            parentViewController()?.view.addSubview(scrollViewEmoji)
//            parentViewController()?.view.addSubview(arrowView)
//
//            let stackView = scrollViewEmoji.subviews.reversed()
//            stackView.forEach({ (emoji) in
//                emoji.alpha = 0
//                emoji.transform = CGAffineTransform(translationX: -100, y: emoji.frame.origin.y)
//            })
//
//            scrollViewEmoji.transform = CGAffineTransform(translationX: 0, y: tapLocation.y)
//            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
//                scrollViewEmoji.alpha = 1
//                scrollViewEmoji.transform = .identity
//
//            }, completion: { (_) in
//                arrowView.alpha = 1
//                arrowView.isHidden = false
//            }
//            )
//
//
//            UIView.animate(withDuration:0.3, animations: {
//                let stackView = scrollViewEmoji.subviews.reversed()
//                stackView.forEach({ (emoji) in
//
//                    emoji.alpha = 1
//                    emoji.transform = .identity
//                })
//            }) { (_) in
//                //
//            }
//
//
//
//        }
//
//    }
    
    
//    func browseEmoji()
//    {
//        if let allReactionsValueDic = sortedReactionDictionary(dic: reactionsDictionary) as? Dictionary<String, AnyObject>
//        {
//            var width   = reactionsDictionary.count
//            width =  (6 * width) +  (40 * width)
//            let  width1 = CGFloat(width)
//            scrollViewEmoji.frame = CGRect(x:0,y: TOPPADING,width: width1,height: 50)
//            scrollViewEmoji.backgroundColor = UIColor.white //UIColor.clear
//            scrollViewEmoji.layer.borderWidth = 2.0
//            scrollViewEmoji.layer.borderColor = aafBgColor.cgColor  //UIColor.red.cgColor //tableViewBgColor.cgColor
//            scrollViewEmoji.layer.cornerRadius = 20.0 //5.0
//            var menuWidth = CGFloat()
//            var origin_x:CGFloat = 5.0
//            var i : Int = 0
//            for key in allReactionsValueDic.keys.sorted(by: <) {
//                if let   v = allReactionsValueDic[key]
//                {
//                    if let icon = v["icon"] as? NSDictionary{
//
//                        menuWidth = 40
//                        let   emoji = createButton(CGRect(x: origin_x,y: 5,width: menuWidth,height: 40), title: "", border: false, bgColor: false, textColor: textColorLight)
//                        emoji.addTarget(self, action: #selector(feedMenuReactionLike(sender:)), for: .touchUpInside)
//                        emoji.tag = v["reactionicon_id"] as? Int ?? 0
//                        if let imageUrl = icon["reaction_image_icon"] as? String
//                        {
//                            let url = NSURL(string:imageUrl)
//                            if url != nil
//                            {
//                                emoji.kf.setImage(with: url as URL?, for: .normal, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
//                                })
//                            }
//                        }
//                        scrollViewEmoji.addSubview(emoji)
//                        origin_x = origin_x + menuWidth  + 5
//                        i = i + 1
//                    }
//
//                }
//
//
//            }
//            //
//            scrollViewEmoji.contentSize = CGSize(width: origin_x + 5, height: 30)
//            scrollViewEmoji.bounces = false
//            scrollViewEmoji.isUserInteractionEnabled = true
//            scrollViewEmoji.showsVerticalScrollIndicator = false
//            scrollViewEmoji.showsHorizontalScrollIndicator = false
//            scrollViewEmoji.alwaysBounceHorizontal = true
//            scrollViewEmoji.alwaysBounceVertical = false
//            scrollViewEmoji.isDirectionalLockEnabled = true;
//            scrollViewEmoji.isHidden = true
//        }
//    }
//
    
    func browseEmoji()
    {
        scrollViewEmoji.backgroundColor = .clear
        arrowView.backgroundColor = .clear
        for ob in scrollViewEmoji.subviews{
            ob.removeFromSuperview()
            arrowView.removeFromSuperview()
        }
        scrollViewEmoji.backgroundColor = .clear
        arrowView.backgroundColor = .clear
         if let allReactionsValueDic = sortedReactionDictionary(dic: reactionsDictionary) as? Dictionary<String, AnyObject>
        {
            let space:CGFloat = 15
            let vSpace:CGFloat = 9
            let viewWidth = UIScreen.main.bounds.width - btnLike.frame.width - 5
            let iconHeight = (viewWidth/6) - (space*7)/6
            let viewHeight = iconHeight + (2*vSpace)
            scrollViewEmoji.frame = CGRect(x:0,y: 0,width: viewWidth,height: viewHeight)
            arrowView.frame = CGRect(x: 0, y: 0, width: 14, height: 10)
            scrollViewEmoji.backgroundColor = UIColor.white//UIColor.clear
            arrowView.backgroundColor = UIColor.white
            scrollViewEmoji.layer.cornerRadius = CGFloat(viewHeight/2)
            var menuWidth = CGFloat()
            var origin_x:CGFloat = 15
            var i : Int = 0
            for key in allReactionsValueDic.keys.sorted(by: <) {
                if let   v = allReactionsValueDic[key]
                {
                    
                    if let icon = v["icon"] as? NSDictionary{
                        
                        menuWidth = iconHeight
                        let   emoji = createButton(CGRect(x: origin_x,y: vSpace,width: iconHeight,height: iconHeight), title: "", border: false, bgColor: false, textColor: textColorLight)
                        emoji.addTarget(self, action: #selector(AdvanceActivityFeedViewController.feedMenuReactionLike(sender:)), for: .touchUpInside)
                        emoji.tag = v["reactionicon_id"] as? Int ?? 0
                        if let imageUrl = icon["reaction_image_large_icon"] as? String
                        {
                            let url = NSURL(string:imageUrl)
                            if url != nil
                            {
                                emoji.kf.setImage(with: url as URL?, for: .normal, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                                })
                            }
                        }
                        else if let imageUrl = icon["reaction_image_large_icon"] as? String
                        {
                            let url = NSURL(string:imageUrl)
                            if url != nil
                            {
                                emoji.kf.setImage(with: url as URL?, for: .normal, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                                })
                            }
                        }
                        
                        emoji.imageView?.contentMode = .scaleAspectFit
                        scrollViewEmoji.addSubview(emoji)
                        origin_x = origin_x + menuWidth + CGFloat(space)
                        i = i + 1
                    }
                    
                }
            }
            scrollViewEmoji.contentSize = CGSize(width: origin_x, height: CGFloat(viewHeight))
            scrollViewEmoji.bounces = false
            scrollViewEmoji.isUserInteractionEnabled = true
            scrollViewEmoji.showsVerticalScrollIndicator = false
            scrollViewEmoji.showsHorizontalScrollIndicator = true
            scrollViewEmoji.alwaysBounceHorizontal = true
            scrollViewEmoji.alwaysBounceVertical = false
            scrollViewEmoji.isDirectionalLockEnabled = true;
            scrollViewEmoji.isHidden = true
            arrowView.isHidden = true
        }
    }
    
    @objc func feedMenuReactionLike(sender:UIButton){
        
        if  let feed = feedArrayTikTok[scrollViewEmoji.tag] as? NSDictionary
        {
            let action_id = feed["action_id"] as? Int ?? 0
            var reaction = ""
            for (_,v) in reactionsDictionary
            {
                var updatedDictionary = Dictionary<String, AnyObject>()
                if let v = v as? NSDictionary
                {
                    if  let reactionId = v["reactionicon_id"] as? Int
                    {
                        if reactionId == sender.tag
                        {
                            
                            reaction = (v["reaction"] as? String ?? "")
                            updatedDictionary["reactionicon_id"] = v["reactionicon_id"]  as AnyObject?
                            updatedDictionary["caption" ] = v["caption"]  as AnyObject?
                            if let icon  = v["icon"] as? NSDictionary{
                                
                                updatedDictionary["reaction_image_icon"] = icon["reaction_image_icon"]  as AnyObject?
                                
                            }
                            var url = ""
                            url = "advancedactivity/like"
                            DispatchQueue.main.async(execute: {
                                soundEffect("Like")
                            })
                            
                            self.updateReaction(url: url, reaction: reaction, action_id: action_id, updateMyReaction: updatedDictionary as NSDictionary, feedIndex: scrollViewEmoji.tag)
                            
                        }
                    }
                }
            }
        }
    }
    
    
    func getfeedDic(feed:NSDictionary) -> NSMutableDictionary
    {
        
        let newDictionary:NSMutableDictionary = [:]
        
        if feed["subject_image"]  != nil{
            newDictionary["subject_image"] = feed["subject_image"]
        }
        if feed["feed_title"]  != nil{
            newDictionary["feed_title"] = feed["feed_title"]
        }
        if feed["feed_createdAt"]  != nil{
            newDictionary["feed_createdAt"] = feed["feed_createdAt"]
        }
        if feed["comment_count"]  != nil{
            newDictionary["comment_count"] = feed["comment_count"]
        }
        if feed["likes_count"]  != nil{
            newDictionary["likes_count"] = feed["likes_count"]
        }
        if feed["attachment"]  != nil{
            newDictionary["attachment"] = feed["attachment"]
            
        }
        if feed["attactment_Count"]  != nil{
            newDictionary["attactment_Count"] = feed["attactment_Count"]
        }
        if feed["attachment_content_type"]  != nil{
            newDictionary["attachment_content_type"] = feed["attachment_content_type"]
        }
        if feed["action_id"]  != nil{
            newDictionary["action_id"] = feed["action_id"]
        }
        if feed["subject_id"]  != nil{
            newDictionary["subject_id"] = feed["subject_id"]
        }
        if feed["share_params_type"]  != nil{
            newDictionary["share_params_type"] = feed["share_params_type"]
        }
        if feed["share_params_id"]  != nil{
            newDictionary["share_params_id"] = feed["share_params_id"]
        }
        if feed["feed_Type"]  != nil{
            newDictionary["feed_Type"] = feed["feed_Type"]
        }
        if feed["feed_menus"]  != nil{
            newDictionary["feed_menus"] = feed["feed_menus"]
        }
        if feed["feed_footer_menus"]  != nil{
            newDictionary["feed_footer_menus"] = feed["feed_footer_menus"]
        }
        if feed["feed_reactions"]  != nil{
            newDictionary["feed_reactions"] = feed["feed_reactions"]
        }
        if feed["my_feed_reaction"]  != nil{
            newDictionary["my_feed_reaction"] = feed["my_feed_reaction"]
        }
        if feed["comment"]  != nil{
            newDictionary["comment"] = feed["comment"]
        }
        if feed["like"]  != nil{
            newDictionary["like"] = feed["like"]
        }
        if feed["delete"]  != nil{
            newDictionary["delete"] = feed["delete"]
        }
        if feed["share"]  != nil{
            newDictionary["share"] = feed["share"]
        }
        if feed["photo_attachment_count"] != nil{
            newDictionary["photo_attachment_count"] = feed["photo_attachment_count"]
        }
        if feed["object_id"] != nil{
            newDictionary["object_id"] = feed["object_id"]
        }
        if feed["object_type"] != nil{
            newDictionary["object_type"] = feed["object_type"]
        }
        if feed["params"] != nil{
            newDictionary["params"] = feed["params"]
        }
        if feed["tags"] != nil{
            newDictionary["tags"] = feed["tags"]
        }
        if feed["action_type_body_params"] != nil{
            newDictionary["action_type_body_params"] = feed["action_type_body_params"]
        }
        if feed["action_type_body"] != nil{
            newDictionary["action_type_body"] = feed["action_type_body"]
        }
        if feed["object"] != nil{
            newDictionary["object"] = feed["object"]
        }
        if feed["is_like"] != nil{
            newDictionary["is_like"] = feed["is_like"]
        }
        if feed["hashtags"]  != nil{
            newDictionary["hashtags"] = feed["hashtags"]
        }
        
        if feed["decoration"] != nil{
            newDictionary["decoration"] = feed["decoration"]
        }
        if feed["wordStyle"] != nil{
            newDictionary["wordStyle"] = feed["wordStyle"]
        }
        if feed["privacy"] != nil{
            newDictionary["privacy"] = feed["privacy"]
        }
        if feed["privacy_icon"] != nil{
            newDictionary["privacy_icon"] = feed["privacy_icon"]
        }
        if feed["isNotificationTurnedOn"]  != nil{
            newDictionary["isNotificationTurnedOn"] = feed["isNotificationTurnedOn"]
        }
        if feed["pin_post_duration"] != nil{
            newDictionary["pin_post_duration"] = feed["pin_post_duration"]
        }
        if feed["isPinned"] != nil{
            newDictionary["isPinned"] = feed["isPinned"]
        }
        if feed["publish_date"] != nil{
            newDictionary["publish_date"] =  feed["publish_date"]
        }
        
        return newDictionary
    }
    
    // MARK:  TTTAttributedLabelDelegate
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWithTransitInformation components: [AnyHashable : Any]!)
    {
        isViewWillAppearCallContent = 0
        
        let components = components as NSDictionary
        var activityfeed = NSDictionary()
        
        if (components["feed"] as? NSDictionary) != nil
        {
            activityfeed = components["feed"] as! NSDictionary
        }
        else
        {
            activityfeed = components
        }
        
        let original = activityfeed["hashtagString"] as! String
        let singleString = String(original.dropFirst())
        let presentedVC = HashTagFeedViewController()
        presentedVC.hashtagString = singleString
        objParent?.navigationController?.pushViewController(presentedVC, animated: true)
        
    }
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        //UIApplication.shared.openURL(url!)
        let presentedVC = ExternalWebViewController()
        presentedVC.url = url.absoluteString
        presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        let navigationController = UINavigationController(rootViewController: presentedVC)
        objParent?.present(navigationController, animated: true, completion: nil)
    }
    //MARK:- Share Option
    func feedMenuShare(){
        isViewWillAppearCallContent = 0
        // Open ShareContentView to Share Feed
        let feed = feedArrayTikTok[index] as! NSDictionary
        if let feed_menu = feed["feed_footer_menus"] as? NSDictionary{
            if let share  = feed_menu["share"] as? NSDictionary{
                
                var shareTitle = feed["feed_title"] as? String ?? ""
                if shareTitle.length > 130{
                    shareTitle = (shareTitle as NSString).substring(to: 130-3)
                    shareTitle  = shareTitle + "..."
                }
                
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
                alertController.addAction(UIAlertAction(title:  String(format: NSLocalizedString("Share on %@", comment: ""),app_title), style: .default) { action -> Void in
                    
                    
                    if let attachmentCount = feed["attactment_Count"] as? Int{
                        if attachmentCount > 0
                        {
                            if attachmentCount == 1{
                                if let attachment = feed["attachment"] as? NSArray{
                                    if (attachment[0] as! NSDictionary)["attachment_type"] as! String != "album_photo"{
                                        let presentedVC = AdvanceShareViewController()
                                        presentedVC.delegateAdvanceVShareVideoResume = self.objParent
                                        presentedVC.param = (share["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                        presentedVC.url = share["url"] as! String
                                        let photoDictionary = (attachment[0] as! NSDictionary)
                                        if let photoMainDictionary = photoDictionary["image_main"] as? NSDictionary {
                                            if let url =  photoMainDictionary["src"] as? String
                                            {
                                                presentedVC.imageString = url
                                            }
                                            
                                        }
                                        if let attachment_title = photoDictionary["title"] as? String{
                                            presentedVC.Sharetitle = attachment_title
                                        }
                                        if let attachment_description = photoDictionary["body"] as? String{
                                            presentedVC.ShareDescription = attachment_description
                                        }
                                        presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                        let nativationController = UINavigationController(rootViewController: presentedVC)
                                        self.objParent?.present(nativationController, animated:true, completion: nil)
                                        
                                    }
                                    else{
                                        let presentedVC = AdvanceShareViewController()
                                        presentedVC.delegateAdvanceVShareVideoResume = self.objParent
                                        presentedVC.param = (share["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                        presentedVC.url = share["url"] as! String
                                        let photoDictionary = (attachment[0] as! NSDictionary)
                                        if let photoMainDictionary = photoDictionary["image_main"] as? NSDictionary
                                        {
                                            if let url =  photoMainDictionary["src"] as? String
                                            {
                                                presentedVC.imageString = url
                                            }
                                            
                                        }
                                        
                                        if let attachment_title = photoDictionary["title"] as? String{
                                            presentedVC.Sharetitle = attachment_title
                                        }
                                        if let attachment_description = photoDictionary["body"] as? String{
                                            presentedVC.ShareDescription = attachment_description
                                        }
                                        presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                        let nativationController = UINavigationController(rootViewController: presentedVC)
                                        self.objParent?.present(nativationController, animated:true, completion: nil)
                                        
                                    }
                                    
                                }
                                else{
                                    let presentedVC = AdvanceShareViewController()
                                    presentedVC.delegateAdvanceVShareVideoResume = self.objParent
                                    presentedVC.param = share["urlParams"] as! NSDictionary
                                    presentedVC.url = share["url"] as! String
                                    presentedVC.Sharetitle = feed["feed_title"] as? String
                                    presentedVC.ShareDescription = feed["body"] as? String
                                    presentedVC.imageString = ""
                                    presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                    let nativationController = UINavigationController(rootViewController: presentedVC)
                                    self.objParent?.present(nativationController, animated:true, completion: nil)
                                    
                                }
                            }
                        }
                        else
                        {
                            let presentedVC = AdvanceShareViewController()
                            presentedVC.delegateAdvanceVShareVideoResume = self.objParent
                            presentedVC.param = (share["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                            presentedVC.url = share["url"] as! String
                            presentedVC.Sharetitle = feed["feed_title"] as? String
                            presentedVC.ShareDescription = feed["body"] as? String
                            presentedVC.imageString = ""
                            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                            let nativationController = UINavigationController(rootViewController: presentedVC)
                            self.objParent?.present(nativationController, animated:true, completion: nil)
                            
                        }
                        
                        
                    }else{
                        let presentedVC = AdvanceShareViewController()
                        presentedVC.delegateAdvanceVShareVideoResume = self.objParent
                        presentedVC.param = share["urlParams"] as! NSDictionary
                        presentedVC.url = share["url"] as! String
                        presentedVC.Sharetitle = feed["feed_title"] as? String
                        presentedVC.ShareDescription = feed["body"] as? String
                        presentedVC.imageString = ""
                        presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                        let nativationController = UINavigationController(rootViewController: presentedVC)
                        self.objParent?.present(nativationController, animated:true, completion: nil)
                        
                    }
                })
                
                alertController.addAction(UIAlertAction(title:  NSLocalizedString("Share Outside",comment: ""), style: UIAlertAction.Style.default) { action -> Void in
                    
                    var sharingItems = [AnyObject]()
                    
                    if shareTitle.length != 0 {
                        sharingItems.append(shareTitle as AnyObject)
                    }
                    if let attachment = feed["attachment"] as? NSArray,attachment.count > 0{
                        if let attachmentDic = attachment[0] as? NSDictionary {
                            if let url = attachmentDic["content_url"] as? String {
                                let finalUrl = NSURL(string: url)!
                                sharingItems.append(finalUrl)
                            }
                            else if let url = attachmentDic["uri"] as? String {
                                let finalUrl = NSURL(string: url)!
                                sharingItems.append(finalUrl)
                            }
                        }
                    }
                    
                    let activityViewController = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
                    activityViewController.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
                    
                    if (UIDevice.current.userInterfaceIdiom == .phone){
                        
                        if(activityViewController.popoverPresentationController != nil) {
                            activityViewController.popoverPresentationController?.sourceView = self.contentView;
                            let frame = UIScreen.main.bounds
                            activityViewController.popoverPresentationController?.sourceRect = frame;
                        }
                        
                    }
                    else
                    {
                        
                        let presentationController = activityViewController.popoverPresentationController
                        presentationController?.sourceView = self.contentView
                        presentationController?.sourceRect = CGRect(x: self.contentView.bounds.width/2 ,y: self.contentView.bounds.width/2,width: 0,height: 0)
                        presentationController?.permittedArrowDirections = UIPopoverArrowDirection()
                        
                    }
                    self.objParent?.present(activityViewController, animated: true, completion: nil)
                    
                })
                
                if  (UIDevice.current.userInterfaceIdiom == .phone){
                    alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .cancel){ action -> Void in
                        self.player?.play()
                        self.imgVideoPause.isHidden = true
                    })
                }
                else
                {
                    // Present Alert as! Popover for iPad
                    alertController.modalPresentationStyle = UIModalPresentationStyle.popover
                    let popover = alertController.popoverPresentationController
                    popover?.sourceView = self.contentView
                    popover?.sourceRect = CGRect(x: self.contentView.bounds.width/2,y: self.contentView.bounds.height/2 ,width: 1,height: 1)
                    popover?.permittedArrowDirections = UIPopoverArrowDirection()
                }
                self.objParent?.present(alertController, animated:true, completion: nil)
                
            }
        }
        
    }
}

extension Date {
    static func dateComponentFrom(second: Double) -> DateComponents {
        let interval = TimeInterval(second)
        let date1 = Date()
        let date2 = Date(timeInterval: interval, since: date1)
        let c = NSCalendar.current
        
        var components = c.dateComponents([.year,.month,.day,.hour,.minute,.second,.weekday], from: date1, to: date2)
        components.calendar = c
        return components
    }
}
