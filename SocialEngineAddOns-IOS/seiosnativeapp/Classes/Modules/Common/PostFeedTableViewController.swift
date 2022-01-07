//
//  videoListTableViewController.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 19/06/17.
//  Copyright © 2017 bigstep. All rights reserved.
//

import UIKit

class PostFeedTableViewCell: UITableViewController {
    var globalvideoList = [AnyObject]()
    var headerheight : CGFloat = 0.0001
    var iscomingFrom = String()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        tableView = UITableView(frame: CGRect(x: 0, y: tableframeY, width: view.bounds.width, height: view.bounds.height - tabBarHeight + 20 - tableframeY), style: UITableViewStyle.grouped)
        tableView.register(videoListTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = textColorLight
        tableView.separatorColor = TVSeparatorColorClear
        
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
        return 10//globalvideoList.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"cell", for: indexPath) as! videoListTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.backgroundColor = UIColor.clear
         cell.textLabel?.text = "cell"//ShareOption[(indexPath as NSIndexPath).row]
        // Configure cell
       // configureCell(cell: cell, indexPath:indexPath)
        return cell
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

    
}
