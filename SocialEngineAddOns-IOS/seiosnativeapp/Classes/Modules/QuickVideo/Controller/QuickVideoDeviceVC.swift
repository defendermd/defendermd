//
//  QuickVideoDeviceVC.swift
//  seiosnativeapp
//
//  Created by BigStep on 29/10/18.
//  Copyright © 2018 bigstep. All rights reserved.
//

import UIKit
import AVKit
import Kingfisher
import NVActivityIndicatorView

protocol DelegateCommentUI{
    func countLikeandComments(data : NSMutableDictionary) //To update like and comment from CommentsViewController class
}

protocol DelegateAdvanceVideoUI{
    func updateTikTokTable(videoId : Int) //To update tableview when come back from AdvanceVideoProfileViewController
}

protocol DelegateAdvanceVShareVideoResume{
    func resumeVideoInTikTokTable() //To update tableview when come back from AdvanceVideoProfileViewController
}

var maxidTikTok:Int = 0
var defaultFeedCountTikTok : Int = 20
var isReadTextViewClicked = false

class QuickVideoDeviceVC: UIViewController, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate, UITableViewDelegate, UITableViewDataSource, DelegateCommentUI, UIGestureRecognizerDelegate, DelegateAdvanceVideoUI, DelegateAdvanceVShareVideoResume {
    
    //MARK:- Properties
    @IBOutlet weak var tblTikTok: UITableView!
    @IBOutlet weak var imgViewSwipe: UIImageView!
    @IBOutlet weak var viewSwipeAnimation: UIView!
    
    var visibleIndexPath: Int = 0
    var refresher:UIRefreshControl!
    var currentCell : QuickVideoCell?
    var currentPlayer: AVPlayer?
    var loadingData = false
    var feedShowingFrom:String = ""
    var indexSelectedVideo = 0
    var delegateTikTokVidyoPlayer : DelegateTikTokVidyoPlayer?
    var videoIdT = 0
    var isViewOffTheScreen = false
    var pipButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "pip_Icon")
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.isHidden = false
        return button
    }()
    var pipView: PIPViews?
    
    @IBOutlet weak var imgCross: UIImageView!
    //MARK:- ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        isViewWillAppearCallContent = 4
        if UserDefaults.standard.bool(forKey: "TikTokDemo") == false
        {
            imgUpDownAnimation()
        }
        else
        {
            viewSwipeAnimation.isHidden = true
            imgViewSwipe.isHidden = true
        }
        tblTikTok.isPagingEnabled = true
        imgCross.image = UIImage(named: "close_tikTok")!.maskWithColor(color: textColorPrime)
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        refresher.tintColor = .white
        tblTikTok.addSubview(refresher)
        
        delay(0.1)
        {
            self.tblTikTok.reloadData()
            let indexPath = IndexPath(item: self.indexSelectedVideo, section: 0)
            if self.tblTikTok.numberOfSections > indexPath.section && self.tblTikTok.numberOfRows(inSection: 0) > indexPath.row
            {
                //   DispatchQueue.main.async {
                self.tblTikTok.scrollToRow(at: indexPath, at: .top, animated: false)
                //   }
            }
        }
        if showPipOption() == "yes" {
            self.pipButton.frame = CGRect(x: 10, y: UIApplication.shared.statusBarFrame.height, width: 30, height: 30)
            view.addSubview(self.pipButton)
            self.pipButton.addTarget(self, action: #selector(QuickVideoDeviceVC.openPipVideo), for: .touchUpInside)
        }
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //        isViewOffTheScreen = true
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.isNavigationBarHidden = false
        NotificationCenter.default.removeObserver(self)
        if currentCell?.imgVideoPause.isHidden == true {
            //            delay(0.0)
            //            {
            let indexPath = IndexPath(item: self.visibleIndexPath, section: 0)
            if self.tblTikTok.numberOfSections > indexPath.section && self.tblTikTok.numberOfRows(inSection: 0) > indexPath.row
            {
                self.tblTikTok.scrollToRow(at: indexPath, at: .top, animated: false)
                if let player = self.currentCell?.player
                {
                    player.isMuted = true
                    player.pause()
                }
                for cellT in self.tblTikTok.visibleCells
                {
                    if let cell = cellT as? QuickVideoCell
                    {
                        if let player = cell.player
                        {
                            player.isMuted = true
                            player.pause()
                        }
                    }
                }
            }
            
            //    }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isVideoPlayingInPIP = false
        for view in (keywindows?.subviews)! {
            if view.tag == 9999 {
                view.removeFromSuperview()
            }
        }
        
        isViewOffTheScreen = false
        if feedArrayTikTok.count == 0
        {
            self.navigationController?.popViewController(animated: false)
            return
        }
        
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.isNavigationBarHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        if currentCell?.imgVideoPause.isHidden == true {
            let indexPath = IndexPath(item: self.visibleIndexPath, section: 0)
            if self.tblTikTok.numberOfSections > indexPath.section && self.tblTikTok.numberOfRows(inSection: 0) > indexPath.row
            {
                self.tblTikTok.scrollToRow(at: indexPath, at: .top, animated: false)
                if let player = self.currentCell?.player
                {
                    player.isMuted = false
                    player.play()
                }
                for cellT in self.tblTikTok.visibleCells
                {
                    if let cell = cellT as? QuickVideoCell
                    {
                        if let player = cell.player
                        {
                            player.isMuted = false
                            player.play()
                        }
                    }
                }
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //  videoPause()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Methods
    @objc func appMovedToBackground() {
        if UserDefaults.standard.bool(forKey: "TikTokDemo") == true
        {
            if currentCell?.imgVideoPause.isHidden == true {
                pauseVideo()
            }
        }
    }
    @objc func applicationDidBecomeActive() {
        if UserDefaults.standard.bool(forKey: "TikTokDemo") == true
        {
            if currentCell?.imgVideoPause.isHidden == true {
                playVideo()
            }
        }
        
    }
    
    func pauseVideo()
    {
        if currentCell != nil
        {
            currentCell?.player?.isMuted = true
            currentCell?.player?.pause()
        }
    }
    func playVideo()
    {
        if currentCell != nil
        {
            currentCell?.player?.isMuted = false
            currentCell?.player?.play()
        }
    }
    func nextPlay()
    {
        let topVisibleIndexPath:IndexPath = tblTikTok.indexPathsForVisibleRows![0]
        if topVisibleIndexPath.row < feedArrayTikTok.count - 1
        {
            visibleIndexPath = topVisibleIndexPath.row + 1
            let indexPath = IndexPath(item: visibleIndexPath, section: 0)
            tblTikTok.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
    
    func imgUpDownAnimation()
    {
        viewSwipeAnimation.isHidden = false
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
        swipeUp.direction = .up
        swipeUp.delegate = self
        viewSwipeAnimation.addGestureRecognizer(swipeUp)
        imgViewSwipe.isHidden = false
        let imgGif = UIImage.gifWithName("Swipe-up-GIF_400pxNew")
        imgViewSwipe.image = imgGif
        
    }
    @objc func handleSwipeGesture(gesture: UISwipeGestureRecognizer){
        UserDefaults.standard.set(true, forKey: "TikTokDemo")
        viewSwipeAnimation.isHidden = true
        currentCell?.player?.play()
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    //MARK:- Delegate Methods
    func countLikeandComments(data: NSMutableDictionary) {
        feedArrayTikTok[visibleIndexPath] = data
        currentCell?.lblLikeCount.text = "\(data["likes_count"] as? Int ?? 0)"
        currentCell?.lblCommetCount.text = "\(data["comment_count"] as? Int ?? 0)"
        currentCell?.dataModel = data
        currentCell?.likeUnlike()
    }
    
    //MARK:- IBActions
    @IBAction func btnCrossAction(_ sender: Any) {
        isViewOffTheScreen = true
        delay(0.0) {
            self.videoPause()
        }
    }
    
    func videoPause()
    {
        let indexPath = IndexPath(item: self.indexSelectedVideo, section: 0)
        if self.tblTikTok.numberOfSections > indexPath.section && self.tblTikTok.numberOfRows(inSection: 0) > indexPath.row
        {
            self.tblTikTok.scrollToRow(at: indexPath, at: .top, animated: false)
            if videoIdT != 0
            {
                self.delegateTikTokVidyoPlayer?.updateTableAfterVideoRemoval(videoId : videoIdT)
            }
            else
            {
                if indexSelectedVideo == visibleIndexPath
                {
                    if let player = self.currentCell?.player
                    {
                        let videoURL = (player.currentItem?.asset as? AVURLAsset)?.url.absoluteString
                        let currentTime:Double = (player.currentTime().seconds)
                        let timeScale = player.currentItem?.asset.duration.timescale
                        self.delegateTikTokVidyoPlayer?.updateTikTokPlayer(videoURL: videoURL!, currentTime: currentTime, timeScale: timeScale!)
                    }
                }
                
            }
            self.visibleIndexPath = self.indexSelectedVideo
            videoPausePersist()
        }
    }
    func videoPausePersist()
    {
        for cellT in self.tblTikTok.visibleCells
        {
            if let cell = cellT as? QuickVideoCell
            {
                cell.videoStop()
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    //MARK:- TableView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedArrayTikTok.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! QuickVideoCell
        currentCell = cell
        cell.selectionStyle = .none
        if let objData = feedArrayTikTok[indexPath.row] as? NSMutableDictionary
        {
            visibleIndexPath = indexPath.row
            cell.index = indexPath.row
            cell.objParent = self
            cell.feedShowingFrom = feedShowingFrom
            if currentPlayer != nil
            {
                // cell.player = currentPlayer
                if let attachement = objData["attachment"] as? [AnyObject]
                {
                    if attachement.count != 0
                    {
                        if let dicAttachement = attachement[0] as? [String : AnyObject], let videoURL = dicAttachement["attachment_video_url"] as? String
                        {
                            cell.playSpecificTimeVideo(strURL: videoURL)
                        }
                    }
                }
            }
            
            cell.configureData(dataModel: objData)
            if let attachement = objData["attachment"] as? [AnyObject]
            {
                if attachement.count != 0
                {
                    if let dicAttachement = attachement[0] as? [String : AnyObject], let videoURL = dicAttachement["attachment_video_url"] as? String
                    {
                        if let imgeMain = dicAttachement["video_overlay_image"] as? [String : AnyObject], let url = URL(string: imgeMain["url"] as? String ?? "")
                        {
                            cell.imgVideoOverLay.isHidden = false
                            cell.imgVideoOverLay.kf.indicatorType = .activity
                            (cell.imgVideoOverLay.kf.indicator?.view as? UIActivityIndicatorView)?.color = navColor
                            cell.imgVideoOverLay.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                
                            })
                        }
                        else
                        {
                            cell.imgVideoOverLay.isHidden = true
                        }
                        if let imgeMain = dicAttachement["image_main"] as? [String : AnyObject], let url = URL(string: imgeMain["src"] as? String ?? "")
                        {
                            cell.imgViewStory.kf.indicatorType = .activity
                            (cell.imgViewStory.kf.indicator?.view as? UIActivityIndicatorView)?.color = navColor
                            cell.imgViewStory.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                
                            })
                        }
                    }
                }
                
            }
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = feedArrayTikTok.count - 2
        if !loadingData && indexPath.row == lastElement {
            tblTikTok.tableFooterView?.isHidden = false
            loadingData = true
            API_getAAFList()
        }
    }
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cellT = cell as? QuickVideoCell
        {
            cellT.videoStop()
        }
    }
    //    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //        if let cell = tableView.cellForRow(at: indexPath) as? QuickVideoCell
    //        {
    //            if cell.player?.timeControlStatus == .paused {
    //                cell.txtDescReadMore.shouldTrim = true
    //                cell.player?.play()
    //                cell.imgVideoPause.isHidden = true
    //            }
    //            else
    //            {
    //                cell.player?.pause()
    //                cell.imgVideoPause.isHidden = false
    //            }
    //        }
    //    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return tableView.bounds.height
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isReadTextViewClicked
        {
            tblTikTok.reloadData()
            isReadTextViewClicked = false
        }
    }
    
    
    //MARK:- Pull to Request Action
    @objc func refresh(){
        DispatchQueue.main.async(execute:{
            soundEffect("Activity")
        })
        if Reachabable.isConnectedToNetwork()
        {
            if let player = self.currentCell?.player
            {
                player.isMuted = true
                player.pause()
            }
            for cellT in self.tblTikTok.visibleCells
            {
                if let cell = cellT as? QuickVideoCell
                {
                    if let player = cell.player
                    {
                        player.isMuted = true
                        player.pause()
                    }
                }
            }
            currentCell?.viewSlider.isHidden = true
            isViewWillAppearCall = 8
            maxidTikTok = 0
            API_getAAFList()
        }
        else
        {
            // No Internet Connection Message
            refresher.endRefreshing()
            showToast(message: network_status_msg, controller: self)
        }
        
    }
    //MARK:- TikTok API
    func API_getAAFList()
    {
        //self.view.fadeIn()
        if Reachabable.isConnectedToNetwork()
        {
            var parameters = [String:String]()
            parameters = ["maxid": String(maxidTikTok),"feed_filter": "1","post_elements": "1","post_menus":"1","object_info":"1","getAttachedImageDimention":"0","filter_type":"video","onlyMyDeviceVideo":"1"]
            if defaultFeedCountTikTok > 0 {
                parameters["limit"] = "\(defaultFeedCountTikTok)"
            }
            if subjectIdTikTok != ""{
                parameters["subject_id"] = String(subjectIdTikTok)
            }
            if subjectTypeTikTok != ""{
                parameters["subject_type"] = subjectTypeTikTok
            }
            //  print(parameters)
            // Send Server Request for Activity Feed
            post(parameters, url: "advancedactivity/feeds", method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    self.loadingData = false
                    self.refresher.endRefreshing()
                    self.tblTikTok.tableFooterView?.isHidden = true
                    if msg {
                        
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self, onView: false, time: 2.0)
                            
                        }
                        // print(succeeded)
                        if maxidTikTok == 0
                        {
                            feedArrayTikTok.removeAll()
                        }
                        if let dicTemp = succeeded["body"] as? [String : AnyObject], let activity_feed = dicTemp["data"] as? NSArray
                        {
                            // Set MaxId for Feeds Result
                            if let maxid = dicTemp["maxid"] as? Int{
                                maxidTikTok = maxid
                            }
                            let activityFeeds:[ActivityFeed] = ActivityFeed.loadActivityFeedInfo(activity_feed)
                            self.updateFeedsArrayTikTok(feeds: activityFeeds)
                            self.tblTikTok.reloadData()
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
            activityIndicatorView.stopAnimating()
            self.loadingData = false
            self.refresher.endRefreshing()
            self.tblTikTok.tableFooterView?.isHidden = true
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self, onView: false, time: 2.0)
        }
    }
    
    
    // Update/ Sink feedArray from [ActivityFeed] to show updates in ActivityFeed Table
    func updateFeedsArrayTikTok(feeds:[ActivityFeed]){
        var existingFeedIntegerArray = [Int]()
        for tempFeedArrays in feedArrayTikTok {
            existingFeedIntegerArray.append(tempFeedArrays["action_id"] as? Int ?? 0)
        }
        for feed in feeds{
            let newDictionary:NSMutableDictionary = [:]
            if feed.action_id != nil{
                newDictionary["action_id"] = feed.action_id
            }
            if feed.feed_privacy != nil{
                newDictionary["privacy"] = feed.feed_privacy
            }
            if feed.feed_privacyIcon != nil{
                newDictionary["privacy_icon"] = feed.feed_privacyIcon
            }
            
            if feed.subject_id != nil{
                newDictionary["subject_id"] = feed.subject_id
            }
            if feed.share_params_type != nil{
                newDictionary["share_params_type"] = feed.share_params_type
            }
            if feed.share_params_id != nil{
                newDictionary["share_params_id"] = feed.share_params_id
            }
            if feed.attachment != nil{
                newDictionary["attachment"] = feed.attachment
            }
            if feed.attactment_Count != nil{
                newDictionary["attactment_Count"] = feed.attactment_Count
            }
            if feed.comment != nil{
                newDictionary["comment"] = feed.comment
            }
            if feed.delete != nil{
                newDictionary["delete"] = feed.delete
            }
            if feed.share != nil{
                newDictionary["share"] = feed.share
            }
            if feed.comment_count != nil{
                newDictionary["comment_count"] = feed.comment_count
            }
            if feed.feed_createdAt != nil{
                newDictionary["feed_createdAt"] = feed.feed_createdAt
            }
            if feed.feed_menus != nil{
                newDictionary["feed_menus"] = feed.feed_menus
            }
            if feed.feed_footer_menus != nil{
                newDictionary["feed_footer_menus"] = feed.feed_footer_menus
            }
            if feed.feed_reactions != nil{
                newDictionary["feed_reactions"] = feed.feed_reactions
            }
            if feed.my_feed_reaction != nil{
                newDictionary["my_feed_reaction"] = feed.my_feed_reaction
            }
            if feed.feed_title != nil{
                newDictionary["feed_title"] = feed.feed_title
            }
            if feed.feed_Type != nil{
                newDictionary["feed_Type"] = feed.feed_Type
            }
            if feed.is_like != nil{
                newDictionary["is_like"] = feed.is_like
            }
            if feed.likes_count != nil{
                newDictionary["likes_count"] = feed.likes_count
            }
            if feed.subject_image != nil{
                newDictionary["subject_image"] = feed.subject_image
            }
            if feed.photo_attachment_count != nil{
                newDictionary["photo_attachment_count"] = feed.photo_attachment_count
            }
            if feed.object_id != nil{
                newDictionary["object_id"] = feed.object_id
            }
            if feed.object_type != nil{
                newDictionary["object_type"] = feed.object_type
            }
            if feed.params != nil{
                newDictionary["params"] = feed.params
            }
            if feed.tags != nil{
                newDictionary["tags"] = feed.tags
            }
            if feed.action_type_body_params != nil{
                newDictionary["action_type_body_params"] = feed.action_type_body_params
            }
            if feed.action_type_body != nil{
                newDictionary["action_type_body"] = feed.action_type_body
            }
            if feed.object != nil{
                newDictionary["object"] = feed.object
            }
            if feed.hashtags != nil{
                newDictionary["hashtags"] = feed.hashtags
            }
            if feed.userTag != nil{
                newDictionary["userTag"] = feed.userTag
            }
            if feed.decoration != nil{
                newDictionary["decoration"] = feed.decoration
            }
            if feed.wordStyle != nil{
                newDictionary["wordStyle"] = feed.wordStyle
            }
            if feed.publish_date != nil{
                newDictionary["publish_date"] = feed.publish_date
            }
            if feed.isNotificationTurnedOn != nil{
                newDictionary["isNotificationTurnedOn"] = feed.isNotificationTurnedOn
            }
            if feed.attachment_content_type != nil{
                newDictionary["attachment_content_type"] = feed.attachment_content_type
            }
            if feed.pin_post_duration != nil{
                newDictionary["pin_post_duration"] = feed.pin_post_duration
            }
            if feed.isPinned != nil{
                newDictionary["isPinned"] = feed.isPinned
            }
            let actionId  = newDictionary["action_id"] as! Int
            if !existingFeedIntegerArray.contains(actionId){
                feedArrayTikTok.append(newDictionary)
            }
        }
        existingFeedIntegerArray.removeAll(keepingCapacity: true)
    }
    
    func updateTikTokTable(videoId : Int) {
        isViewWillAppearCall = 8
        videoIdT = videoId
        self.tblTikTok.reloadData()
    }
    
    func resumeVideoInTikTokTable() {
        if let player = currentCell?.player
        {
            player.play()
        }
    }
    
}

extension UIRefreshControl {
    func refreshManually() {
        if let scrollView = superview as? UIScrollView {
            scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentOffset.y - frame.height), animated: false)
        }
        beginRefreshing()
        sendActions(for: .valueChanged)
    }
}

extension QuickVideoDeviceVC {
    @objc func openPipVideo() {
        isVideoPlayingInPIP = true
        if let player = currentCell?.player {
            pipView = PIPViews(frame: CGRect(x: 10, y: getBottomEdgeY(inputView: self.pipButton), width: 30, height: 30), videoPlayer: player, parentViewController: self, currentTimeStamp: player.currentTime())
            keywindows!.addSubview(pipView!)
            pipView?.openPIPWithAnimation()
            self.dismiss(animated: true, completion: nil)
        }
        
    }
}
