//
//  VideoPlayerController.swift
//  seiosnativeapp
//
//  Created by BigStep on 29/10/18.
//  Copyright © 2018 bigstep. All rights reserved.
//

import UIKit
import AVFoundation

/**
 Protocol that needs to be adopted by subclass of any UIView
 that wants to play video.
 */
protocol AutoPlayVideoLayerContainer {
    var videoURL: String? { get set }
    var videoLayer: AVPlayerLayer { get set }
    func visibleVideoHeight() -> CGFloat
}

// Mute unmute video
var muteVideo = true

class VideoPlayerController: NSObject, NSCacheDelegate {
    var minimumLayerHeightToPlay: CGFloat = 60
    
    var preferredPeakBitRate: Double = 1000000
    static private var playerViewControllerKVOContext = 0
    //static var sharedVideoPlayer = VideoPlayerController()
    //video url for currently playing video
    var videoURL: String?
    /**
     Stores video url as key and true as value when player item associated to the url
     is being observed for its status change.
     Helps in removing observers for player items that are not being played.
     */
    private var observingURLs = Dictionary<String, Bool>()
    // Cache of player and player item
    var videoCache = NSCache<NSString, VideoContainer>()
    // Current AVPlapyerLayer that is playing video
    private var currentLayer: AVPlayerLayer?
    
    override init() {
        super.init()
        videoCache.delegate = self
    }
    
    /**
     Download of an asset of url if corresponding videocontainer
     is not present.
     Uses the asset to create new playeritem.
     */
    func setupVideoFor(url: String) {
        if self.videoCache.object(forKey: url as NSString) != nil {
            return
        }
        guard let URL = URL(string: url) else {
            return
        }
        let asset = AVURLAsset(url: URL)
        let requestedKeys = ["playable"]
        asset.loadValuesAsynchronously(forKeys: requestedKeys) { [weak self] in
            guard let strongSelf = self else {
                return
            }
            /**
             Need to check whether asset loaded successfully, if not successful then don't create
             AVPlayer and AVPlayerItem and return without caching the videocontainer,
             so that, the assets can be tried to be downloaded again when need be.
             */
            var error: NSError? = nil
            let status = asset.statusOfValue(forKey: "playable", error: &error)
            switch status {
                case .loaded:
                    print("ready==1=")
                    break
                case .failed, .cancelled:
                    print("Failed to load asset successfully")
                    return
                case .unknown:
                print("buffering1===")
                default:
                    print("Unkown state of asset")
                    return
            }
            //strongSelf.removeObserverFor(url: url)
            let player = AVPlayer()
            let item = AVPlayerItem(asset: asset)
            DispatchQueue.main.async {
                let videoContainer = VideoContainer(player: player, item: item, url: url, sharedVideoPlayer: strongSelf)
                strongSelf.videoCache.setObject(videoContainer, forKey: url as NSString)
                videoContainer.player.replaceCurrentItem(with: videoContainer.playerItem)
                /**
                 Try to play video again in case when playvideo method was called and
                 asset was not obtained, so, earlier video must have not run
                 */
                if strongSelf.videoURL == url, let layer = strongSelf.currentLayer {
                    strongSelf.playVideo(withLayer: layer, url: url)
                }
            }
        }
    }
    // Play video with the AVPlayerLayer provided
    func playVideo(withLayer layer: AVPlayerLayer, url: String) {
        videoURL = url
        currentLayer = layer
        if let videoContainer = self.videoCache.object(forKey: url as NSString) {
            layer.player = videoContainer.player
            videoContainer.playOn = true
            addObservers(url: url, videoContainer: videoContainer)
        }
        // Give chance for current video player to be ready to play
        //DispatchQueue.main.async {
            if let videoContainer = self.videoCache.object(forKey: url as NSString),
                videoContainer.player.currentItem?.status == .readyToPlay  {
                videoContainer.playOn = true
            }
        //}
    }
    
    private func pauseVideo(forLayer layer: AVPlayerLayer, url: String) {
        videoURL = nil
        currentLayer = nil
      //  DispatchQueue.main.async {
            if let videoContainer = self.videoCache.object(forKey: url as NSString) {
                videoContainer.playOn = false
                self.removeObserverFor(url: url)
            }
        //}
    }
    
    func removeLayerFor(cell: AutoPlayVideoLayerContainer) {
        if let url = cell.videoURL {
            removeFromSuperLayer(layer: cell.videoLayer, url: url)
        }
    }
    
    private func removeFromSuperLayer(layer: AVPlayerLayer, url: String) {
        videoURL = nil
        currentLayer = nil
        if let videoContainer = self.videoCache.object(forKey: url as NSString) {
            videoContainer.playOn = false
            removeObserverFor(url: url)
        }
        layer.player = nil
    }
    
    private func pauseRemoveLayer(layer: AVPlayerLayer,url: String, layerHeight: CGFloat) {
        pauseVideo(forLayer: layer, url: url)
    }
    
    // Play video again in case the current player has finished playing
    @objc func playerDidFinishPlaying(note: NSNotification) {
        guard let playerItem = note.object as? AVPlayerItem,
            let currentPlayer = currentVideoContainer()?.player else {
                return
        }
        if let currentItem = currentPlayer.currentItem, currentItem == playerItem {
            currentPlayer.seek(to: CMTime.zero)
            NotificationCenter.default.post(name: Notification.Name("NotificationVideoCompletion"), object: nil)

            
           // currentPlayer.play()
        }
    }
    
    func currentVideoContainer() -> VideoContainer? {
        if let currentVideoUrl = videoURL {
            if let videoContainer = videoCache.object(forKey: currentVideoUrl as NSString) {
                return videoContainer
            }
        }
        return nil
    }
    
    private func addObservers(url: String, videoContainer: VideoContainer) {
        if self.observingURLs[url] == false || self.observingURLs[url] == nil {
            videoContainer.player.currentItem?.addObserver(self,
                                                           forKeyPath: "status",
                                                           options: [.new, .initial],
                                                           context: &VideoPlayerController.playerViewControllerKVOContext)
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(self.playerDidFinishPlaying(note:)),
                                                   name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                   object: videoContainer.player.currentItem)
            self.observingURLs[url] = true
        }
    }
    
    private func removeObserverFor(url: String) {
        if let videoContainer = self.videoCache.object(forKey: url as NSString) {
            if let currentItem = videoContainer.player.currentItem, observingURLs[url] == true {
                currentItem.removeObserver(self,
                                           forKeyPath: "status",
                                           context: &VideoPlayerController.playerViewControllerKVOContext)
                NotificationCenter.default.removeObserver(self,
                                                          name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                          object: currentItem)
                observingURLs[url] = false
            }
        }
    }
    
    /**
     Play UITableViewCell's videoplayer that has max visible video layer height
     when the scroll stops.
     */
    func pauseVideosFor(tableView: UITableView, appEnteredFromBackground: Bool = false) {
        let visisbleCells = tableView.visibleCells
        var maxHeight: CGFloat = 0.0
        for cellView in visisbleCells {
            guard let containerCell = cellView as? AutoPlayVideoLayerContainer,
                let videoCellURL = containerCell.videoURL else {
                    continue
            }
            let height = containerCell.visibleVideoHeight()
            if maxHeight < height {
                maxHeight = height
            }
            pauseRemoveLayer(layer: containerCell.videoLayer, url: videoCellURL, layerHeight: height)
        }
    }
    
    func muteVideosFor(tableView: UITableView) {
        let visisbleCells = tableView.visibleCells
        for cellView in visisbleCells {
            guard let containerCell = cellView as? AutoPlayVideoLayerContainer,
                let videoCellURL = containerCell.videoURL else {
                    continue
            }
            if let videoContainer = self.videoCache.object(forKey: videoCellURL as NSString) {
                videoContainer.player.isMuted = muteVideo
            }
        }
    }
    
    func pausePlayeVideosFor(tableView: UITableView, appEnteredFromBackground: Bool = false) {
        let visisbleCells = tableView.visibleCells
        var videoCellContainer: AutoPlayVideoLayerContainer?
        var maxHeight: CGFloat = 0.0
        for cellView in visisbleCells {
            guard let containerCell = cellView as? AutoPlayVideoLayerContainer,
                let videoCellURL = containerCell.videoURL else {
                    continue
            }
            let height = containerCell.visibleVideoHeight()
            if maxHeight < height {
                maxHeight = height
                videoCellContainer = containerCell
            }
            pauseRemoveLayer(layer: containerCell.videoLayer, url: videoCellURL, layerHeight: height)
        }
        guard let videoCell = videoCellContainer,
            let videoCellURL = videoCell.videoURL else {
                return
        }
        let minCellLayerHeight = videoCell.videoLayer.bounds.size.height * 0.5
        /**
         Visible video layer height should be at least more than max of predefined minimum height and
         cell's videolayer's 50% height to play video.
         */
        let minimumVideoLayerVisibleHeight = max(minCellLayerHeight, minimumLayerHeightToPlay)
        if maxHeight > minimumVideoLayerVisibleHeight {
            if appEnteredFromBackground {
                setupVideoFor(url: videoCellURL)
            }
            playVideo(withLayer: videoCell.videoLayer, url: videoCellURL)
        }
    }
    
    // Set observing urls false when objects are removed from cache
    func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject obj: Any) {
        if let videoObject = obj as? VideoContainer {
            if !observingURLs.isEmpty
            {
              observingURLs[videoObject.url] = false
            }
        }
    }
    
    // Play video only when current videourl's player is ready to play
    override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        // Make sure the this KVO callback was intended for this view controller.
        guard context == &VideoPlayerController.playerViewControllerKVOContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        if keyPath == "status" {
            /**
             Handle `NSNull` value for `NSKeyValueChangeNewKey`, i.e. when
             `player.currentItem` is nil.
             */
            let newStatus: AVPlayerItem.Status
            if let newStatusAsNumber = change?[NSKeyValueChangeKey.newKey] as? NSNumber {
                newStatus = AVPlayerItem.Status(rawValue: newStatusAsNumber.intValue)!
                UIApplication.shared.keyWindow?.addSubview(activityIndicatorView)
                activityIndicatorView.center.x = UIScreen.main.bounds.width/2 - 5
                activityIndicatorView.center.y = UIScreen.main.bounds.height/2 - 5
                activityIndicatorView.startAnimating()
                if newStatus == .readyToPlay {
                     print("ready==2=")
                    activityIndicatorView.stopAnimating()
                    guard let item = object as? AVPlayerItem,
                        let currentItem = currentVideoContainer()?.player.currentItem else {
                            return
                    }
                    if item == currentItem && currentVideoContainer()?.playOn == true {
                        
                        currentVideoContainer()?.playOn = true
                    }
                }
                if newStatus == .unknown {
                    print("===buffering===")
                }
                if newStatus == .failed {
                    NSLog("Error: \(String(describing: currentVideoContainer()?.player.currentItem?.error?.localizedDescription)), error: \(String(describing: currentVideoContainer()?.player.currentItem?.error))")
                     UIApplication.shared.keyWindow?.makeToast("Error in video loading...", duration: 1, position: "bottom")
                    print("===failed===")
                }
            }
            else {
                newStatus = .unknown
                print("===buffering==1=")
            }
            if newStatus == .failed {
                print("===failed=1==")
            }
        }
    }
    
    deinit {
        
    }
}
