//
//  videoListTableViewController.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 19/06/17.
//  Copyright © 2017 bigstep. All rights reserved.
//

import UIKit

protocol VideoChangeDelegate{
    func didNewVideoClicked(dict : [String : Any])
    
}

var selectIndex: Int = 0
class videoListTableViewController: UITableViewController {
    var globalvideoList = [AnyObject]()
    var headerheight : CGFloat = 0.0001
    var iscomingFrom = String()
    var isplaylist:Bool = false
    var delegateVideoChange:VideoChangeDelegate?
    var isAdvanceVideoProfileParent = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
            tableView = UITableView(frame: CGRect(x: 0, y: tableframeY, width: view.bounds.width, height: UIScreen.main.bounds.height - (tableframeY)), style: UITableView.Style.grouped)
        tableView.register(videoListTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = textColorLight
        tableView.separatorColor = TVSeparatorColorClear
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            self.tableView.contentInsetAdjustmentBehavior = .never
            self.tableView.estimatedRowHeight = 0
            self.tableView.estimatedSectionHeaderHeight = 0
            self.tableView.estimatedSectionFooterHeight = 0
        }
        
  

    }
    @objc func stopTimer() {
        stop()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerheight
    }

    // Set Tabel Footer Height
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 0.00001

    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75.0
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return globalvideoList.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"cell", for: indexPath) as! videoListTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.backgroundColor = UIColor.clear
        // Configure cell
        configureCell(cell: cell, indexPath:indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        let row = indexPath.row
        if row == self.globalvideoList.count-2
        {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "checkMoreVideos"), object: nil, userInfo: nil)
        }
        print("Row number is \(row)")
    }
    
    func configureCell(cell:videoListTableViewCell,indexPath:IndexPath)
    {
        let row = indexPath.row as Int
        if iscomingFrom != "AdvPlaylist"
        {
           cell.btncross.isHidden = true
        }
        else
        {
            if isplaylist == true{
                cell.btncross.addTarget(self, action: #selector(videoListTableViewController.deletevideo(_:)), for: .touchUpInside)
                cell.btncross.tag = row
                cell.btncross.isHidden = true
            }
            else{
                cell.btncross.addTarget(self, action: #selector(videoListTableViewController.deletevideo(_:)), for: .touchUpInside)
                cell.btncross.tag = row
                cell.btncross.isHidden = false
            }
        }

        let videosInfo = globalvideoList[row] as! NSDictionary
        if let urlString = videosInfo["image_normal"] as? String
        {
            let url = URL(string: urlString)
             cell.contentImage.kf.indicatorType = .activity
            (cell.contentImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                cell.contentImage.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                })
            //Select Video Action
            cell.contentSelection.addTarget(self, action: #selector(videoListTableViewController.showVideo(_:)), for: .touchUpInside)
            cell.contentSelection.tag = indexPath.row
        }
        if let duration = videosInfo["duration"] as? Int
        {
            let durationString = timeFormatted(duration) as String
            cell.videoDuration.text = durationString
        }
        if let title = videosInfo["title"] as? String
        {
            
            cell.contentName.text = title
        }
        if let ownerName = videosInfo["owner_title"] as? String
        {
            
            cell.ownerName.text = "by \(ownerName)"
        }
        
    }
    //Scrollview Delegate
    override func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        scrollopoint = scrollView.contentOffset
        switch tableViewFrameType {
        case "AdvanceVideoProfileViewController":
            let obj = NotificationCenter.default
            obj.post(name: Foundation.Notification.Name(rawValue: "ScrollingactionAdvVideo"), object: nil)
            break
            
        case "ChannelProfileViewController":
            let obj = NotificationCenter.default
            obj.post(name: Foundation.Notification.Name(rawValue: "ScrollingactionAdvVideoChannel"), object: nil)
            break
            
        default:
            break
        }
    }
    @objc func showVideo(_ sender: UIButton)
    {
        var videoInfo:NSDictionary!
        videoInfo = globalvideoList[sender.tag] as! NSDictionary
        if comingFromPlaylist == true
        {
            selectIndex = sender.tag
            let obj = NotificationCenter.default
            obj.post(name: Foundation.Notification.Name(rawValue: "didselctplaylist"), object: nil)
            
        }
        else   
        {
            if(videoInfo["allow_to_view"] as! Int == 1)
            {
                if isAdvanceVideoProfileParent == false
                {
                    let presentedVC = AdvanceVideoProfileViewController()
                    presentedVC.videoProfileTypeCheck = ""
                    presentedVC.videoId = videoInfo["video_id"] as! Int
                    presentedVC.videoType = videoInfo["type"] as? Int
                    if  videoInfo["type"] as! Int == 3 || videoInfo["type"] as! Int == 2 || videoInfo["type"] as! Int == 1 || videoInfo["type"] as! Int == 4 ||  videoInfo["type"] as! Int == 5 || videoInfo["type"] as! Int == 6
                    {
                        if let url = videoInfo["video_url"] as? String
                        {
                            presentedVC.videoUrl = url
                        }
                    }
                    else
                    {
                        presentedVC.videoUrl = videoInfo["content_url"] as! String
                    }
                    let nativationController = UINavigationController(rootViewController: presentedVC)
                    nativationController.modalPresentationStyle = .fullScreen
                    self.parent?.present(nativationController, animated:true, completion: nil)
                }
                else
                {
                    var dic = [String : Any]()
                    dic["video_id"] = videoInfo["video_id"] as! Int
                    dic["type"] = videoInfo["type"] as! Int
                    var urlT = ""
                    if  videoInfo["type"] as! Int == 3 || videoInfo["type"] as! Int == 2 || videoInfo["type"] as! Int == 1 || videoInfo["type"] as! Int == 4 ||  videoInfo["type"] as! Int == 5 || videoInfo["type"] as! Int == 6
                    {
                        if let url = videoInfo["video_url"] as? String
                        {
                            urlT = url
                        }
                    }
                    else
                    {
                        urlT = videoInfo["content_url"] as! String
                    }
                    dic["video_url"] = urlT
                    
                    tableView.setContentOffset(.zero, animated: true)
                    delegateVideoChange?.didNewVideoClicked(dict: dic)
                }
                
            }
            else
            {
                showToast(message:NSLocalizedString("You do not have permission to view this private page.", comment: ""), controller: self, onView: false, time: 5)
            }
        }
        
    }
    @objc func deletevideo(_ sender: UIButton)
    {
        let videosInfo = globalvideoList[sender.tag] as! NSDictionary
        let videoid = videosInfo["video_id"] as! Int
        let playlist_id = videosInfo["playlist_id"] as! Int
        if videosInfo["is_remove"] as? Int  == 1
        {
            // Check Internet Connection
            if Reachabable.isConnectedToNetwork() {
                removeAlert()
//                spinner.center = view.center
//                spinner.hidesWhenStopped = true
//                spinner.style = UIstyle.gray
//                view.addSubview(spinner)
                self.view.addSubview(activityIndicatorView)
                activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()

                var dic = Dictionary<String, String>()
                dic["playlist_id"] = "\(playlist_id)"
                dic["video_id"] = "\(videoid)"
                let url = "advancedvideo/playlist/remove-from-playlist/\(playlist_id)"
                // Send Server Request to Explore Video Contents with Video_ID
                post(dic, url: "\(url)", method: "POST") { (succeeded, msg) -> () in
                    DispatchQueue.main.async(execute: {
                        activityIndicatorView.stopAnimating()
                        if msg{
                            
                            if succeeded["message"] != nil{
                                showToast(message: succeeded["message"] as! String, controller: self)
                                self.globalvideoList.remove(at: sender.tag)
                                self.tableView.reloadData()
                            }
                        }
                        else
                        {
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
                showToast(message: network_status_msg, controller: self)
            }
        }
        else
        {
            showToast(message:"You dont have access to delete this video", controller: self)
        }
    }
}
