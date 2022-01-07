//
//  PlayerViewController.swift
//  seiosnativeapp
/*
 * Copyright (c) 2016 BigStep Technologies Private Limited.
 *
 * You may not use this file except in compliance with the
 * SocialEngineAddOns License Agreement.
 * You may obtain a copy of the License at:
 * https://www.socialengineaddons.com/ios-app-license
 * The full copyright and license information is also mentioned
 * in the LICENSE file that was distributed with this
 * source code.
 */


import UIKit
import Foundation
import AVFoundation
import MediaPlayer
var player:AVPlayer = AVPlayer()
var musicPlaying = false
var musicRestart : Int!
var musicCheck = ""

class PlayerViewController: UIViewController, UIGestureRecognizerDelegate,UITabBarControllerDelegate {
    
    var sliderTimer = Timer()
    var cross : UIButton!
    var playListImage : UIImageView!
    var playPauseLabel : UILabel!
    var playPauseButton : UIButton!
    var nextButton : UIButton!
    var preButton : UIButton!
    // var playListResponse : NSArray!
    var prog : UIProgressView!
    var marqueeHeader : MarqueeLabel!
    
    var playOrPause = true
    var titleLabel : UILabel!
    var playCount : UILabel!
    
    var volumeSlider: UISlider!
    var playSlider: UISlider!
    var CurrentSongId: Int!
    var changeSong:Bool!
    var imageView : UIImageView!
    var imageProfile: String!
    var volumeView : UIView!
    var volumeView1:UILabel!
    var volumeView2 : UILabel!
    var startTime : UILabel!
    var endTime : UILabel!
    var leftBarButtonItem : UIBarButtonItem!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        navigationController?.navigationBar.isHidden = false
        self.tabBarController?.delegate = self
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(PlayerViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem

        if let tabBarObject = self.tabBarController?.tabBar {
            tabBarObject.isHidden = true
        }

        
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        
        playCount = createLabel(CGRect(x: 20,y: 85,width: view.bounds.width - 20,height: 50), text: "", alignment: .center, textColor: textColorDark)
        view.addSubview(playCount)
        
        playListImage  = UIImageView(frame:CGRect(x: 0 ,y: TOPPADING, width: view.bounds.width, height: view.bounds.height-225));
        self.playListImage.clipsToBounds = true;
        self.playListImage.layer.shadowColor = UIColor.black.cgColor
        let coverImageUrl = URL(string: imageProfile)
        if coverImageUrl != nil
        {
            self.playListImage.kf.indicatorType = .activity
            (self.playListImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
            self.playListImage.kf.setImage(with: coverImageUrl as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                
            })
        }
        
        view.addSubview(playListImage)
        titleLabel = createLabel(CGRect(x: 20,y: 100,width: view.bounds.width - 20,height: 50), text: "", alignment: .center, textColor: textColorLight)
        
        view.addSubview(titleLabel)
        
        let playlistSongDic = playlistResponse[songIndex] as! NSDictionary
        let clickedSongString = playlistSongDic["filePath"] as! String
        if (changeSong == true){
            musicCheck = "NotReload"
            self.setCurrentSoundTrack(clickedSongString)
            playOrPause = true
        }
        sliderTimer =  Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(PlayerViewController.configurePlayer), userInfo: nil, repeats: true)

        preButton = createButton(CGRect(x: PADING, y: view.bounds.height-70  , width: (view.bounds.width)/3, height: 50), title: "\u{f04a}", border: true,bgColor: false, textColor: textColorLight)
        preButton.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZELarge)
        preButton.addTarget(self, action: #selector(PlayerViewController.preButton(_:)), for: .touchUpInside)
        preButton.layer.borderWidth = 0.0
        view.addSubview(preButton)
        
        
        let lowVolumeImageView = createImageView(CGRect(x: (view.bounds.width)/4 - 30,y: view.bounds.height-160 , width: 20, height: 20), border: false)
        lowVolumeImageView.image = UIImage(named: "lowVolumes.png")
        view.addSubview(lowVolumeImageView)
        
        
        let highVolumeImageView = createImageView(CGRect(x: (view.bounds.width)/4 + (view.bounds.width)/2 + 10,y: view.bounds.height-160 , width: 20, height: 20), border: false)
        highVolumeImageView.image = UIImage(named: "highVolumes.png")
        view.addSubview(highVolumeImageView)
        
        
        
        volumeView1 = createLabel(CGRect(x: (view.bounds.width)/4 - 30,y: view.bounds.height-165 , width: 20, height: 30), text: "\u{f026}", alignment: .center, textColor: textColorLight)
        volumeView1.font = UIFont(name: "FontAwesome", size: FONTSIZEExtraLarge)
        volumeView1.isHidden = true
        view.addSubview(volumeView1)
        
        // let volumeView1 = createImageView(CGRect(x:(view.bounds.width)/4 + (view.bounds.width)/2 + 10,view.bounds.height-160 , 20, 20), border: false)
        
        let jeremyGif = UIImage.gifWithName("progress bar")
        
        // Use the UIImage in your UIImageView
        imageView = UIImageView(image: jeremyGif)
        imageView.frame = CGRect(x: 0,y: view.bounds.height-160 ,width: (view.bounds.width), height: 10)
        view.addSubview(imageView)
        volumeView = MPVolumeView(frame:CGRect(x: (view.bounds.width)/4,y: view.bounds.height-160 , width: (view.bounds.width)/2, height: 20))
        view.addSubview(volumeView)
        
        volumeView2 = createLabel(CGRect(x: (view.bounds.width)/4 + (view.bounds.width)/2 + 10,y: view.bounds.height-160 , width: 25, height: 20), text: "\u{f028}", alignment: .center, textColor: textColorLight)
        volumeView2.font = UIFont(name: "FontAwesome", size: FONTSIZEExtraLarge)
        volumeView2.isHidden = true
        view.addSubview(volumeView2)
        
        startTime = createLabel(CGRect(x: PADING + 10,y: view.bounds.height-100 , width: 60, height: 15), text: "", alignment: .center, textColor: textColorLight)
        startTime.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium)
        startTime.isHidden = true
        view.addSubview(startTime)
        
        
        endTime = createLabel(CGRect(x: (view.bounds.width)/4 + (view.bounds.width)/2 + 10,y: view.bounds.height-100 , width: 60, height: 15), text: "", alignment: .center, textColor: textColorLight)
        endTime.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium)
        endTime.isHidden = true
        
        view.addSubview(endTime)
        
        
        playSlider = UISlider(frame:CGRect(x: (view.bounds.width)/4,y: view.bounds.height-100 , width: (view.bounds.width)/2, height: 20))
        playSlider.minimumValue = 0.0
        
        playSlider.isContinuous = true
        playSlider.tintColor = navColor //UIColor.red
        playSlider.value = 0
        playSlider.addTarget(self, action: #selector(PlayerViewController.sliderValueDidChange(_:)), for: .valueChanged)
        self.view.addSubview(playSlider)
        nextButton = createButton(CGRect(x: PADING+2*((view.bounds.width)/3), y: view.bounds.height-70 , width: (view.bounds.width)/3, height: 50), title: "\u{f04e}", border: true,bgColor: false, textColor: textColorLight)
        nextButton.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZELarge)
        nextButton.addTarget(self, action: #selector(PlayerViewController.nextButton(_:)), for: .touchUpInside)
        nextButton.layer.borderWidth = 0.0
        view.addSubview(nextButton)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let navigationBar = self.navigationController?.navigationBar {
            let firstFrame = CGRect(x: 30, y: 0, width: navigationBar.frame.width - 60, height: navigationBar.frame.height)
            marqueeHeader = MarqueeLabel(frame: firstFrame)
            marqueeHeader.tag = 101
            marqueeHeader.setDefault()
            navigationBar.addSubview(marqueeHeader)
        }
        
        if let tabBarObject = self.tabBarController?.tabBar {
            tabBarObject.isHidden = true
        }
        removeNavigationImage(controller: self)
    }

    override func viewWillDisappear(_ animated: Bool) {
    self.marqueeHeader.text = ""
    removeMarqueFroMNavigaTion(controller: self)

        if let tabBarObject = self.tabBarController?.tabBar {
            tabBarObject.isHidden = false
        }
        setNavigationImage(controller: self)
        
    }
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        self.marqueeHeader.text = ""
        removeMarqueFroMNavigaTion(controller: self)
        return true
    }
    
    override  func viewDidAppear(_ animated: Bool) {
        let coverImageUrl = URL(string: imageProfile)
        if coverImageUrl != nil
        {
            self.playListImage.kf.indicatorType = .activity
            (self.playListImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
            self.playListImage.kf.setImage(with: coverImageUrl as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                
            })
        }
        if pausingRemain == "" {
            playPauseButton = createButton(CGRect(x: PADING+(view.bounds.width)/3, y: view.bounds.height-70 , width: (view.bounds.width)/3, height: 50), title: "\u{f04c}", border: true,bgColor: false, textColor: textColorLight)
            playPauseButton.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZELarge)
            playPauseButton.layer.borderWidth = 0.0
            playPauseButton.addTarget(self, action: #selector(PlayerViewController.playPause(_:)), for: .touchUpInside)
            
            view.addSubview(playPauseButton)
        }
        else{
            playPauseButton = createButton(CGRect(x: PADING+(view.bounds.width)/3, y: view.bounds.height-70 , width: (view.bounds.width)/3, height: 50), title: "\u{f04b}", border: true,bgColor: false, textColor: textColorLight)
            playPauseButton.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZELarge)
            playPauseButton.layer.borderWidth = 0.0
            playPauseButton.addTarget(self, action: #selector(PlayerViewController.playPause(_:)), for: .touchUpInside)
            
            view.addSubview(playPauseButton)
        }
        
        
        
        let playlistSongDic = playlistResponse[songIndex] as! NSDictionary
        self.marqueeHeader.text = playlistSongDic["title"]! as? String
    }
    
    func cancel(){
        
        dismiss(animated: true, completion: nil)
    }
    

    @objc func playPause(_ sender:UIButton){
        playPauseSong()
    }
    
    func playPauseSong(){
        if (player.rate > 0 && player.error == nil) {
            playOrPause = false
            musicPlaying = false
            player.pause()
            pausingRemain = "pause"
            self.playPauseButton.setTitle("\u{f04b}", for: UIControl.State())
        }else{
            playOrPause = true
            musicPlaying = true
            player.play()
            pausingRemain = ""
            
            self.playPauseButton.setTitle("\u{f04c}", for: UIControl.State())
        }
        
    }
    
    func setCurrentSoundTrack(_ currentSoundTrack: String){
        
        
        let steamingURL:URL! = URL(string:currentSoundTrack)
        player = AVPlayer(url: steamingURL)
        
        if(playOrPause){
            player.play()
            musicPlaying = true
            DispatchQueue.main.async(execute: {

                let playlistSongDic = playlistResponse[songIndex] as! NSDictionary
                let titleSong = String(describing: playlistSongDic["title"]!)
                
                //self.titleLabel.text = titleSong as String
                let playCount = playlistSongDic["play_count"]! as! Int
                
                self.CurrentSongId = playlistSongDic["song_id"]! as! Int
                
                self.playCount.text = String("\(playCount) plays")
                
                self.updatePlayCount()
                
                do {
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.duckOthers)
                    do {
                        try AVAudioSession.sharedInstance().setActive(true)
                    } catch _ {
                    }
                } catch _ {
                }
                
                
                let image:UIImage = UIImage(named: "music.png")!
                let albumArt = MPMediaItemArtwork(image: image)
                
                
                let mpic = MPNowPlayingInfoCenter.default()
                mpic.nowPlayingInfo = [
                    MPMediaItemPropertyTitle: titleSong,
                    MPMediaItemPropertyArtist:"SEAO",
                    MPMediaItemPropertyPlaybackDuration : CMTimeGetSeconds(player.currentItem!.asset.duration),
                    MPNowPlayingInfoPropertyPlaybackRate : 1,
                    MPMediaItemPropertyArtwork: albumArt
                ]
                
            })
            
        }else{
            musicPlaying = false
            self.pause()
        }
        
        
    }
    
    func pause(){
        player.pause()
        playOrPause = false
        musicPlaying = false
    }
    
    func play(){
        
        player.play()
        playOrPause = true
        musicPlaying = true
    }
    
    @objc func nextButton(_ sender:UIButton){
        playNextSong()
    }
    
    func playNextSong(){
        
        volumeView.isHidden = true
        volumeView1.isHidden = true
        volumeView2.isHidden = true
        
        let jeremyGif = UIImage.gifWithName("progress bar")
        imageView = UIImageView(image: jeremyGif)
        imageView.frame = CGRect(x: 0,y: view.bounds.height-160 ,width: (view.bounds.width), height: 10)
        view.addSubview(imageView)
        
        imageView.isHidden = false
        if(songIndex == playlistResponse.count-1){
            songIndex = 0
        }else{
            songIndex = songIndex + 1
        }
        let playlistSongDic = playlistResponse[songIndex] as! NSDictionary
        let clickedSongString = playlistSongDic["filePath"] as! String
        self.setCurrentSoundTrack(clickedSongString)
        self.marqueeHeader.text = playlistSongDic["title"]! as? String
    }
    
    @objc func preButton(_ sender:UIButton){
        playPreSong()
    }
    
    func playPreSong(){
        
        volumeView.isHidden = true
        volumeView1.isHidden = true
        volumeView2.isHidden = true
        
        let jeremyGif = UIImage.gifWithName("progress bar")
        imageView = UIImageView(image: jeremyGif)
        imageView.frame = CGRect(x: 0,y: view.bounds.height-160 ,width: (view.bounds.width), height: 10)
        view.addSubview(imageView)
        imageView.isHidden = false
        
        if(songIndex == 0){
            songIndex = playlistResponse.count-1
        }else{
            songIndex = songIndex - 1
        }
        
        let playlistSongDic = playlistResponse[songIndex] as! NSDictionary
        let clickedSongString = playlistSongDic["filePath"] as! String
        self.setCurrentSoundTrack(clickedSongString)
        self.marqueeHeader.text = playlistSongDic["title"]! as? String
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func remoteControlReceived(with event: UIEvent?) {
        let rc = event!.subtype
        
        switch rc.rawValue {
        case 105:  //Previous
            self.playPreSong()
        case 101: //Pause
            player.pause()
            break
        case 100: //Play
            player.play()
        case 104: //Next
            self.playNextSong()
        default:
            break
        }
        
    }
    
    override var canBecomeFirstResponder: Bool
    {
        get { return true }
    }
    
    @objc func configurePlayer(){
        self.imageView.isHidden = true
        volumeView.isHidden = false
        volumeView1.isHidden = false
        volumeView2.isHidden = false
        if(player.currentItem != nil){
            let totaltime =  CMTimeGetSeconds(player.currentItem!.asset.duration)
            
            let minute : Int!
            let second : Int!
            minute = Int(totaltime.truncatingRemainder(dividingBy: 3600)/60)
            second = Int((totaltime.truncatingRemainder(dividingBy: 3600)).truncatingRemainder(dividingBy: 60))

            
            self.endTime.text = "\(String(format: "%02d:%02d", minute,second))"
            
            if(player.currentItem != nil){
                let currentItems:AVPlayerItem = player.currentItem!
                let tempCurrentTime:Float64 = CMTimeGetSeconds(currentItems.currentTime())
                let currentTime = Float(tempCurrentTime)
                self.playSlider.minimumValue = 0.0
                self.playSlider.maximumValue = Float(totaltime)
                playSlider.value = currentTime
                let min : Int!
                let sec : Int!
                min = Int(currentTime.truncatingRemainder(dividingBy: 3600)/60)
                sec = Int((currentTime.truncatingRemainder(dividingBy: 3600)).truncatingRemainder(dividingBy: 60))

                
                if (player.rate == 0 && CMTimeGetSeconds(player.currentItem!.asset.duration) != CMTimeGetSeconds(currentItems.currentTime()) && musicPlaying )
                {
                    player.play()
                }
                
                self.startTime.text = "\(String(format: "%02d:%02d", min,sec))"
                self.startTime.isHidden = false
                self.endTime.isHidden = false

                if (startTime.text == endTime.text){
                    if (startTime.text == "00:00" && endTime.text == "00:00"){
                        showToast(message: "Loading...", controller: self)
                        let playlistSongDic = playlistResponse[songIndex] as! NSDictionary
                        let clickedSongString = playlistSongDic["filePath"] as! String
                        self.setCurrentSoundTrack(clickedSongString)
                        
                    }
                    else{
                        playNextSong()
                    }
                }
            }
        }
    }
    
    func updatePlayCount(){
        post(["song_id":"\(self.CurrentSongId!)"], url: "music/song/tally", method: "POST") {
            (succeeded, msg) -> () in
            
            DispatchQueue.main.async(execute: {
                activityIndicatorView.stopAnimating()
                if msg{
                    
                    if succeeded["message"] != nil{
                    }
                }else{
                    // Handle Server Side Error
                    if succeeded["message"] != nil{
                        
                    }
                }
            })
        }
    }
    
    @objc func goBack()
    {
        if player != nil
        {
            player.pause()
            player.replaceCurrentItem(with: nil)
        }
        _ = self.navigationController?.popViewController(animated: true)
    }

    @objc func sliderValueDidChange(_ sender:UISlider){
        
        let seconds = Float64(playSlider.value)
        let targetTime = CMTimeMakeWithSeconds(seconds, preferredTimescale: 1)
        
        player.seek(to: targetTime)
        player.play()
    }
}
