//
//  MusicDetailViewController.swift
//  seiosnativeapp
//
//  Created by bigstep on 29/04/15.
//  Copyright (c) 2015 bigstep. All rights reserved.
//

import UIKit

import Foundation
import AVFoundation

class MusicDetailViewController: UIViewController , UITableViewDelegate , UITableViewDataSource,  UIWebViewDelegate , TTTAttributedLabelDelegate{
//    var receivedEvent = UIEvent()
    var sliderTimer = NSTimer()
    var songPlayCount: Int!
    var musicIcon : UIButton!
    var musicName:String!
    var playListId:Int!
    var playlistSongsArray:NSArray!
    var playCount:Int!
    var playViews:Int!
    var ownerTitle:String!
    var playListTableView:UITableView!
    var bgImage: UIImageView!
    var imagePath:String!
    var playSlider: UISlider!
    var CurrentSongId: Int!
    var currentPlayingSong: String!
    var songIndex: Int!
    var pausePlay : UIButton!
    var previous : UIButton!
    var next : UIButton!
    var player:AVPlayer = AVPlayer()
    var musicTitle : TTTAttributedLabel!
    var deleteBlogEntry:Bool!
    var pauseFlag:Bool! ;
    var totalPlayingTime:Float!
    
    var beginTime:UILabel!
    var endTime:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        deleteBlogEntry = false;
        // Do any additional setup after loading the view, typically from a nib.
        
        view.backgroundColor = bgColor
        self.title = musicName
          songIndex = 0
         musicTitle = TTTAttributedLabel(frame:CGRectMake(PADING, TOPPADING, CGRectGetWidth(view.bounds), 80) )
        musicTitle.numberOfLines = 0
        musicTitle.delegate = self
        view.addSubview(musicTitle)
        
        
        setCurrentSoundTrack(playlistSongsArray[0]["filePath"]! as String)
        CurrentSongId = playlistSongsArray[0]["song_id"]! as Int
    
        let url = NSURL(string: imagePath)!
     
        let data = NSData(contentsOfURL: url) //make sure your image in this url does exist, otherwise unwrap in a if let check
        if(data != nil){
        var image: UIImage =  UIImage(data: data!)!
        bgImage = UIImageView(image: image)
        }
        bgImage!.frame = CGRectMake(PADING,TOPPADING+80,CGRectGetWidth(view.bounds),200)
       self.view.addSubview(bgImage!)
        
        pausePlay = createButton(CGRectMake(PADING+(CGRectGetWidth(view.bounds))/3, TOPPADING+285 , (CGRectGetWidth(view.bounds))/3, 50), "\u{f04b}", true,false, textColorLight)
        pausePlay.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZENormal)
        pausePlay.layer.cornerRadius = cornerRadiusNormal
        pausePlay.backgroundColor = navColor//UIColor.redColor()
        pausePlay.layer.masksToBounds = true
        pausePlay.addTarget(self, action: "pausePlayAction:", forControlEvents: .TouchUpInside)

        // pausePlay.addTarget(self, action: <#Selector#>, forControlEvents: .Normal)
        view.addSubview(pausePlay)
        
        if(player.error == nil){
        sliderTimer =  NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("updateTimer"), userInfo: nil, repeats: true)
        }
        
        previous = createButton(CGRectMake(PADING, TOPPADING+285 , (CGRectGetWidth(view.bounds))/3, 50), "\u{f04a}", true,false, textColorLight)
        previous.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZENormal)
        previous.layer.cornerRadius = cornerRadiusNormal
        previous.backgroundColor =  navColor //UIColor.redColor()
        previous.layer.masksToBounds = true
        
        previous.addTarget(self, action: "previousButton:", forControlEvents: .TouchUpInside)
        
        view.addSubview(previous)
        
        
        next = createButton(CGRectMake(PADING+2*((CGRectGetWidth(view.bounds))/3), TOPPADING+285 , (CGRectGetWidth(view.bounds))/3, 50), "\u{f04e}", true,false, textColorLight)
        next.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZENormal)
        next.layer.cornerRadius = cornerRadiusNormal
        next.backgroundColor = navColor //UIColor.redColor()
        next.layer.masksToBounds = true
        next.addTarget(self, action: "nextButton:", forControlEvents: .TouchUpInside)
        view.addSubview(next)
        
        playSlider = UISlider(frame:CGRectMake(PADING + 65, TOPPADING+350, CGRectGetWidth(view.bounds) - 150, 20))
        playSlider.minimumValue = 0.0
        
        var duration = self.player.currentItem.asset.duration as CMTime;
        var tempPlayingTime = CMTimeGetSeconds(duration) as Float64;
        totalPlayingTime = Float(tempPlayingTime)
    
        refreshPlayer();
        playSlider.continuous = true
        playSlider.tintColor = navColor //UIColor.redColor()
        playSlider.value = 0
        playSlider.addTarget(self, action: "sliderValueDidChange:", forControlEvents: .ValueChanged)
        self.view.addSubview(playSlider)
        playSlider.backgroundColor = UIColor.redColor()
        
        
        
        beginTime = createLabel(CGRectMake(PADING + 10, TOPPADING+350, 50, 20), "", .Left, textColorLight)
        //        groupTitle.layer.shadowColor = UIColor.lightGrayColor().CGColor
        //        groupTitle.numberOfLines = 0
        //        groupTitle.layer.shadowOpacity = 1.0
        //        groupTitle.layer.shadowRadius = 4.0
                 beginTime.numberOfLines = 0
                beginTime.layer.shadowColor = shadowColor.CGColor
                beginTime.layer.shadowOpacity = shadowOpacity
                beginTime.layer.shadowRadius = shadowRadius
                beginTime.layer.shadowOffset = shadowOffset
                self.view.addSubview(beginTime)
        
        
        endTime = createLabel(CGRectMake(CGRectGetWidth(view.bounds) - 150 + PADING + 65, TOPPADING+350, 50, 20), "", .Left, textColorLight)
        //        groupTitle.layer.shadowColor = UIColor.lightGrayColor().CGColor
        //        groupTitle.numberOfLines = 0
        //        groupTitle.layer.shadowOpacity = 1.0
        //        groupTitle.layer.shadowRadius = 4.0
        endTime.numberOfLines = 0
        endTime.layer.shadowColor = shadowColor.CGColor
        endTime.layer.shadowOpacity = shadowOpacity
        endTime.layer.shadowRadius = shadowRadius
        endTime.layer.shadowOffset = shadowOffset
        self.view.addSubview(endTime)
//         self.endTime.text = "srijan"
        
        
        
//          blogTableView = UITableView(frame: CGRectMake(0, CGRectGetHeight(filter.bounds) + 2 * contentPADING + filter.frame.origin.y  , CGRectGetWidth(view.bounds), CGRectGetHeight(view.bounds)-(CGRectGetHeight(filter.bounds) + 2 * contentPADING + filter.frame.origin.y)), style: .Grouped)
        
        playListTableView = UITableView(frame: CGRectMake(PADING, TOPPADING + 370  , CGRectGetWidth(view.bounds), CGRectGetHeight(view.bounds)-370 ), style: .Grouped)
        playListTableView.registerClass(CustomTableViewCell.self, forCellReuseIdentifier: "Cell")
        playListTableView.dataSource = self
        playListTableView.delegate = self
        playListTableView.estimatedRowHeight = 50.0
        playListTableView.rowHeight = UITableViewAutomaticDimension
        playListTableView.backgroundColor = tableViewBgColor
        playListTableView.separatorColor = TVSeparatorColor
        view.addSubview(playListTableView)
        
        
        
        likeCommentContent_id = playListId
        likeCommentContentType = "music_playlist"
        like_CommentStyle = 1
        var like_comment = Like_CommentView()
        //        like_comment.layer.shadowColor = UIColor.grayColor().CGColor
        //        like_comment.layer.shadowOffset = CGSizeMake(2, -2)
        //        like_comment.layer.shadowRadius = 2.0
        //        like_comment.layer.shadowOpacity = 0.5
        like_comment.layer.shadowColor = shadowColor.CGColor
        like_comment.layer.shadowOffset = shadowOffset
        like_comment.layer.shadowRadius = shadowRadius
        like_comment.layer.shadowOpacity = shadowOpacity
        view.addSubview(like_comment)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        var a = convertIntoSecondString(totalPlayingTime)
        self.endTime.text = a
        
//        self.endTime.text = "srijan"
        
        exploreMusic()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        if (limit*pageNumber < totalItems){
//            return 80
//            
//        }else{
//            return 0.00001
//        }
//    }
//    
//    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 0.00001
//    }
//    
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return dynamicHeight
//    }
//    
//    // Set music Section
//    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return 1
//    }
//
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return self.playlistSongsArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
    
        var songTitle = playlistSongsArray[indexPath.row]["title"] as String;
       
        songPlayCount = playlistSongsArray[indexPath.row]["play_count"] as Int;
        cell.textLabel?.text = songTitle
        
        if songPlayCount > 1{
            cell.detailTextLabel?.text =  String(format: NSLocalizedString("%d plays", comment: ""), songPlayCount!)
        }else{
            cell.detailTextLabel?.text = String(format: NSLocalizedString("%d play", comment: ""), songPlayCount!)
        }
        
        return cell
        
    }
    
     func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
       
        songIndex = indexPath.row
        
        var song = playlistSongsArray[indexPath.row]["filePath"]! as String
        setCurrentSoundTrack(song as String)
        refreshPlayer()
       
        CurrentSongId = playlistSongsArray[indexPath.row]["song_id"]! as Int
        updatePlayCount()
        playListTableView.reloadData()
        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)
        AVAudioSession.sharedInstance().setActive(true, error: nil)
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        player.play()
        pausePlay.setTitle("\u{f04c}", forState: UIControlState.Normal)
        
    }
    
    func pausePlayAction(sender:UIButton){
        
       
        if (player.rate > 0 && player.error == nil) {
           pauseFlag = true
            pausePlay.setTitle("\u{f04b}", forState: UIControlState.Normal)
            player.pause();
            playListTableView.reloadData()
        }else{
            
           pausePlay.setTitle("\u{f04c}", forState: UIControlState.Normal)
            updatePlayCount();
            AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)
            AVAudioSession.sharedInstance().setActive(true, error: nil)
            UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
            player.play()
            playListTableView.reloadData()
        }
      }
    func nextButton(sender:UIButton){
       if (songIndex == self.playlistSongsArray.count - 1){
            return;
        }
        
        var song = playlistSongsArray[songIndex+1]["filePath"]! as String
        songIndex = songIndex + 1
        setCurrentSoundTrack(song as String)
        
        updatePlayCount();
        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)
        AVAudioSession.sharedInstance().setActive(true, error: nil)
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        player.play()
        playListTableView.reloadData()
        pausePlay.setTitle("\u{f04c}", forState: UIControlState.Normal)
        playListTableView.reloadData()
        
    }
    func previousButton(sender:UIButton){
        
        if (songIndex == 0){
        return;
        }
        
        var song = playlistSongsArray[songIndex-1]["filePath"]! as String
        songIndex = songIndex - 1
        setCurrentSoundTrack(song as String)
        
        updatePlayCount();
        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)
        AVAudioSession.sharedInstance().setActive(true, error: nil)
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        player.play()
        pausePlay.setTitle("\u{f04c}", forState: UIControlState.Normal)
        playListTableView.reloadData()

    }
    
    func sliderValueDidChange(sender:UISlider){
        
//        let currentItems:AVPlayerItem = self.player.currentItem
//        let tempCurrentTime:Float64 = CMTimeGetSeconds(currentItems.currentTime())
//        let currentTime = Float(tempCurrentTime)
////        playSlider.value = currentTime
//
//        self.player.pause()
//        println(playSlider.value)
        println(playSlider.value)
        
        
        var seconds = Float64(playSlider.value)
        var targetTime = CMTimeMakeWithSeconds(seconds, 1)
        
        self.player.seekToTime(targetTime)
//        [self.player seekToTime:targetTime
//            toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        
        self.player.pause()
//        
    }
    
    func updateMusic(parameter: NSDictionary, url : String){
        // Check Internet Connection
        if reachability.isReachable() {
            removeAlert()
            spinner.center = view.center
            spinner.hidesWhenStopped = true
            spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            view.addSubview(spinner)
            spinner.startAnimating()
            
            var dic = Dictionary<String, String>()
            for (key, value) in parameter{
                
                if let id = value as? NSNumber {
                    dic["\(key)"] = String(id as Int)
                }
                
                if let receiver = value as? NSString {
                    dic["\(key)"] = receiver
                }
            }
            dic["token"] = "\(auth_token)"
            
            
            // Send Server Request to Explore Blog Contents with Blog_ID
            post(dic, "\(url)", "POST") { (succeeded, msg) -> () in
                dispatch_async(dispatch_get_main_queue(), {
                    spinner.stopAnimating()
                    if msg{
                        // On Success Update Blog Detail
                        // Update Blog Detail
                        if succeeded["message"] != nil{
                            self.showAlertMessage(self.view.center,msg: succeeded["message"] as String )
                        }
                        if self.deleteBlogEntry == true{
                            musicUpdate = true
//                            self.popAfterDelay = true
                            return
                        }
                        self.exploreMusic()
                        
                    }
                        
                    else{
                        // Handle Server Side Error
                        if succeeded["message"] != nil{
                            self.showAlertMessage(self.view.center,msg: succeeded["message"] as String)
                        }
                    }
                })
            }
            
        }else{
            // No Internet Connection Message
            showAlertMessage(view.center , msg: network_status_msg)
        }
        
    }

    
    
    func exploreMusic(){
        // Check Internet Connection
        if reachability.isReachable() {
            removeAlert()
            spinner.center = view.center
            spinner.hidesWhenStopped = true
            spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            view.addSubview(spinner)
            spinner.startAnimating()
            
            // Send Server Request to Explore music Contents with music_ID
            post(["token":"\(auth_token)","playlist_id":"\(playListId)", "gutter_menu": "1"], "music/playlist/view", "GET") { (succeeded, msg) -> () in
                
                    dispatch_async(dispatch_get_main_queue(),{
                    spinner.stopAnimating()
                    if msg{
                      
                    if let music = succeeded["body"] as? NSDictionary{
//                        println(music)
                        // Update Gutter Menu
                        if let menu = music["gutterMenu"] as? NSArray{
                            gutterMenu  = menu
//                            println("srijan")
                            let menu = UIBarButtonItem(image: UIImage(named:"icon-option.png"), style: UIBarButtonItemStyle.Plain , target:self , action: "showMenu")
                            self.navigationItem.rightBarButtonItem = menu
                        }
                    
                      
                         self.title = music["title"] as? String
//                                 let url = NSURL(string: response["owner_image"] as NSString)
//                                                            if  url != "" {
//                                                                downloadData(url!, { (downloadedData, msg) -> () in
//                                                                    if msg{
//                                                                        dispatch_async(dispatch_get_main_queue(), {
//                                                                            self.musicIcon.frame.origin.y = self.musicInfo.frame.origin.y
//                                                                            self.musicIcon.hidden = false
//                                                                            self.musicIcon.setImage(UIImage(data: downloadedData), forState: .Normal)
//                                                                        })
//                                                                    }
//                                                                })
//                                                            }else{
//                                                                self.musicInfo.frame.origin.x = PADING
//                                                                self.musicInfo.frame.size.width = CGRectGetWidth(self.view.bounds) - 2 * PADING
//                                                            }

                            
                            
                                                    var description = ""
                                                    var ownerName = music["owner_title"] as? String
                                                    if ownerName != ""{
                                                        description = "\(ownerName!)\n"
                                                    }
                                                    var postedDate = music["creation_date"] as? String
                                                    if postedDate != ""{
                                                        var postedOn = dateDifference(postedDate!)
                                                        description += postedOn
                                                    }
                        
                                                    description += "\n"

                                                    let viewCount = music["view_count"] as? Int
                                                    var viewInfo = ""
                                                    if viewCount > 1{
                                                        viewInfo =  String(format: NSLocalizedString("%d views", comment: ""), viewCount!)
                                                    }else{
                                                        viewInfo = String(format: NSLocalizedString("%d view", comment: ""), viewCount!)
                                                    }
                        
                                                     description += "\(viewInfo) , "
                        
                                                    self.playCount = music["play_count"] as? Int
                                                    var playInfo = ""
                                                    if self.playCount > 1{
                                                        playInfo =  String(format: NSLocalizedString("%d plays", comment: ""), self.playCount!)
                                                    }else{
                                                        playInfo = String(format: NSLocalizedString("%d plays", comment: ""), self.playCount!)
                                                    }
                                                    description += "\(playInfo)"
                                                    self.musicTitle.textColor = textColorMedium
                                                    self.musicTitle.font = UIFont(name: fontName, size: FONTSIZESmall)
//
                                                    self.musicTitle.setText(description, afterInheritingLabelAttributesAndConfiguringWithBlock: { (mutableAttributedString: NSMutableAttributedString!) -> NSMutableAttributedString! in
//                                                        var boldFont = CTFontCreateWithName( fontBold, FONTSIZESmall, nil)
//                            
//                                                        let range = (description as NSString).rangeOfString(categoryTitle!)
//                                                        mutableAttributedString.addAttribute(kCTFontAttributeName as NSString, value: boldFont, range: range)
//                                                        mutableAttributedString.addAttribute(kCTForegroundColorAttributeName as NSString, value:textColorDark , range: range)
                                                        
                                                        
                                                       var boldFont =  CTFontCreateWithName( fontBold, FONTSIZENormal, nil)
                                                        
                                                        let range1 = (description as NSString).rangeOfString(ownerName!)
                                                        mutableAttributedString.addAttribute(kCTFontAttributeName as NSString, value: boldFont, range: range1)
                                                        mutableAttributedString.addAttribute(kCTForegroundColorAttributeName as NSString, value:textColorDark , range: range1)
                                                 
                                                        return mutableAttributedString
                                                    })
 
                        }
                        
                    }
                   
                })
                
                
            }
        }else{
            // No Internet Connection Message
//            showAlertMessage(view.center , msg: network_status_msg , timer: false)
        }
        
    }
    
    func showMenu(){
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        searchDic.removeAll(keepCapacity: false)
        
        var title = ""
        
        alertController.addAction(UIAlertAction(title: title, style: .Default, handler:{ (UIAlertAction) -> Void in

        }))
        
        for menu in gutterMenu{
            if let dic = menu as? NSDictionary{
             
                alertController.addAction(UIAlertAction(title: (dic["label"] as String), style: .Default, handler:{ (UIAlertAction) -> Void in
                    // Write For Edit Album Entry
                    var condition = dic["name"] as String
                    
                    println(condition)
                  
                    switch(condition){
                    
                    case "share":
                        var presentedVC = ShareContentViewController()
                        presentedVC.param = dic["urlParams"] as NSDictionary
                        presentedVC.url = dic["url"] as String
                        presentedVC.shareContentTitle = self.title
                        presentedVC.shareContentSubTitle = "" //self.contentDescription
                        self.navigationController?.pushViewController(presentedVC, animated: true)
                      
                    case "report":
                        var presentedVC = ReportContentViewController()
                        presentedVC.param = dic["urlParams"] as NSDictionary
                        presentedVC.url = dic["url"] as String
                        self.navigationController?.pushViewController(presentedVC, animated: true)
                        
                    case "delete_playlist":
                        
                        displayAlertWithOtherButton(NSLocalizedString("Delete Entry", comment: ""),NSLocalizedString("Are you sure you want to delete this playlist?",comment: "") , NSLocalizedString("Delete Entry", comment: "")) { () -> () in
                            self.deleteBlogEntry = true
                            self.updateMusic(dic["urlParams"] as NSDictionary ,url: dic["url"] as String)
                        }
                        self.presentViewController(alert, animated: true, completion: nil)
                        
                    default:
                        fatalError("init(coder:) has not been implemented")
                    }
                    
                    
                }))
            }
        }
        if  (UIDevice.currentDevice().userInterfaceIdiom == .Phone){
            alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .Cancel, handler:nil))
        }else{
            // Present Alert as Popover for iPad
            alertController.modalPresentationStyle = UIModalPresentationStyle.Popover
            let popover = alertController.popoverPresentationController
            popover?.sourceView = UIButton()
            popover?.sourceRect = CGRectMake(view.bounds.height-50, view.bounds.width, 0, 0)
            popover?.permittedArrowDirections = UIPopoverArrowDirection.Up
        }
        self.presentViewController(alertController, animated:true, completion: nil)
        
    }
    
//    func sayHello(personName: String)
    func setCurrentSoundTrack(currentSoundTrack: String){
        println(currentSoundTrack)
        var steamingURL:NSURL! = NSURL(string:currentSoundTrack)
        self.player = AVPlayer(URL: steamingURL)
        
        let currentItem:AVPlayerItem = self.player.currentItem
        let currentTime:NSTimeInterval = CMTimeGetSeconds(currentItem.currentTime())
           }
    
    func showAlertMessage( centerPoint: CGPoint, msg: String){
                self.view .addSubview(validationMsg)
                showCustomAlert(centerPoint, msg)
                // Initialization of Timer
                createTimer(self)
            }
    
    
    func updatePlayCount(){
        
        
        post(["token":"\(auth_token)","song_id":"\(CurrentSongId!)"], "music/song/tally", "POST") {
            (succeeded, msg) -> () in
            
                            dispatch_async(dispatch_get_main_queue(), {
                                spinner.stopAnimating()
                                if msg{
            
//                                    println(succeeded)
            
                                    if succeeded["message"] != nil{
                                        self.showAlertMessage(self.view.center,msg: (succeeded["message"] as String) )
                                    }
                                }else{
                                    // Handle Server Side Error
                                    if succeeded["message"] != nil{
                                        self.showAlertMessage(self.view.center,msg: (succeeded["message"] as String) )
            
                                    }
                                }
                            })
                            self.exploreMusic()
                        }
              }

    
    func updateTimer(){
        
        if(self.player.currentItem != nil){
        let currentItems:AVPlayerItem = self.player.currentItem
        let tempCurrentTime:Float64 = CMTimeGetSeconds(currentItems.currentTime())
        let currentTime = Float(tempCurrentTime)
        playSlider.value = currentTime
        var a = convertIntoSecondString(currentTime)
        self.beginTime.text = a
        }
    }
   func convertIntoSecondString(timeInSecond: Float) -> String {
        var hours = (timeInSecond / 3600);
        var minutes = (timeInSecond / 60) ;
        
        
        var seconds = timeInSecond % 60;
        
//        if(minutes < 10)
//        {
//            minutes = "0\(Int(seconds))";
//        }
//        
//        if(seconds < 10)
//        {
//            seconds = "0"+seconds;
//        }
    
//        $milli = /* code to ret the remaining milliseconds */
            var stageTime = "\(Int(minutes)):\(Int(seconds))";
        return stageTime;
    }
    
    func refreshPlayer(){
        
        
        var duration = self.player.currentItem.asset.duration as CMTime;
        var tempPlayingTime = CMTimeGetSeconds(duration) as Float64;
        totalPlayingTime = Float(tempPlayingTime)
        var a = convertIntoSecondString(totalPlayingTime) as NSString
        self.playSlider.maximumValue = totalPlayingTime
        
    }
    
    
    override func remoteControlReceivedWithEvent(event: UIEvent) {
        let rc = event.subtype
        println("received remote control \(rc.rawValue)")
        
        let p = self.player
        switch rc {
        case .RemoteControlTogglePlayPause:
           println("1")
        case .RemoteControlPlay:
            println("12")
        case .RemoteControlPause:
             println("13")
        default:break
        }
        
    }
    
}