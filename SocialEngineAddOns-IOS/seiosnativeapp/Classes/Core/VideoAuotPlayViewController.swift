//
//  VideoAuotPlayViewController.swift
//  seiosnativeapp
//
//  Created by bigstep on 11/01/19.
//  Copyright © 2019 bigstep. All rights reserved.
//

import UIKit

class VideoAuotPlayViewController: UIViewController , UITableViewDelegate ,UITableViewDataSource {
    
    var leftBarButtonItem : UIBarButtonItem!
    var multiDic: NSDictionary = [:]
    var videoResponse = [String]()
    var desc = ""
    var mainView = UIView()
    var connectionTableView = UITableView()
    var headerView = UIView()
    var headerLabel = UILabel()
    var selectedIndex : Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("Video Auto-play", comment: "")
            if  UserDefaults.standard.object(forKey: "AutoPlayStatus") == nil
            {
                UserDefaults.standard.set("always", forKey: "AutoPlayStatus")
            }
        
        view.backgroundColor = bgColor
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(VideoAuotPlayViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        mainView.frame = view.frame
        mainView.backgroundColor = bgColor
        view.addSubview(mainView)
        
        headerView = createView((CGRect(x: 5, y: TOPPADING, width: view.frame.width - 10, height: 100)), borderColor: textColorDark, shadow: false)
        headerView.backgroundColor = bgColor
        headerView.layer.borderWidth = 0.0
        mainView.addSubview(headerView)
        
        headerLabel = createLabel(CGRect(x: 5, y: 5, width: view.frame.width - 10, height: 0), text: "", alignment: .left, textColor: textColorDark)
        headerLabel.font = UIFont(name: fontName, size: FONTSIZELarge)
        headerView.addSubview(headerLabel)
        
        connectionTableView = UITableView(frame: CGRect(x: 0, y: TOPPADING , width: view.bounds.width, height: view.bounds.height-(TOPPADING  + tabBarHeight)), style: .plain)
        connectionTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        connectionTableView.rowHeight = 45
        connectionTableView.dataSource = self
        connectionTableView.delegate = self
        connectionTableView.isOpaque = false
        connectionTableView.backgroundColor = textColorLight
        connectionTableView.separatorColor = UIColor.gray
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            connectionTableView.estimatedRowHeight = 0
            connectionTableView.estimatedSectionHeaderHeight = 0
            connectionTableView.estimatedSectionFooterHeight = 0
        }
        mainView.addSubview(connectionTableView)
        
        self.desc = NSLocalizedString("Videos start to Auto-play as you scroll through Activity Feeds.\n\nVideos use more data compared to the other content in the app.\n\nDecide when you want to auto-play the videos.\n\nVideos won't auto-play when phone battery is low.\n\n\nChoose when to Auto-play the Videos :\n", comment: "")
        self.headerLabel.numberOfLines = 0
        self.headerLabel.text = self.desc
        self.headerView.frame.size.height = heightForView(self.desc, font: UIFont(name: fontNormal, size: FONTSIZELarge)!,width : self.view.bounds.width - 10) + 15
        self.headerLabel.frame.size.height = self.headerView.frame.size.height
        self.connectionTableView.tableHeaderView = self.headerView
        videoResponse = [NSLocalizedString("On Mobile Data and Wi-Fi", comment: ""),NSLocalizedString("On Wi-Fi only", comment: ""),NSLocalizedString("Never Auto-Play the Videos", comment: "")]
        self.connectionTableView.reloadData()
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        return 45.0
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.videoResponse.count
    }
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        cell.textLabel!.text = self.videoResponse[indexPath.row] as? String
        cell.accessoryType = .none
        if let name = UserDefaults.standard.object(forKey: "AutoPlayStatus")
        {
            if  UserDefaults.standard.object(forKey: "AutoPlayStatus") != nil
            {
                if name as! String == "always" && indexPath.row == 0 {
                    cell.accessoryType = .checkmark
                }
                if name as! String == "wifi" && indexPath.row == 1 {
                    cell.accessoryType = .checkmark
                }
                if name as! String == "never" && indexPath.row == 2 {
                    cell.accessoryType = .checkmark
                }
                
                
            }
        }
        
        cell.textLabel!.font = UIFont(name: fontName, size: 16.0)
        cell.accessoryView = nil
        
        
        return cell
        
    }
    
//    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        if let cell = tableView.cellForRow(at: indexPath) {
//            cell.accessoryType = .none
//        }
//    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if let cell = tableView.cellForRow(at: indexPath) {
            
            if cell.accessoryType == .checkmark{
                cell.accessoryType = .none
                
            }
            else{
                cell.accessoryType = .checkmark
                print(self.videoResponse[indexPath.row] as? String)
               
                if indexPath.row == 0 {
                    UserDefaults.standard.set("always", forKey: "AutoPlayStatus")
                }
                if indexPath.row == 1 {
                    UserDefaults.standard.set("wifi", forKey: "AutoPlayStatus")
                }
                if indexPath.row == 2 {
                    UserDefaults.standard.set("never", forKey: "AutoPlayStatus")
                }
                
                showToast(message: "Video Auo-Play Settings have been Saved.", controller: self)
            }
            
        }
        tableView.reloadData()
    }
    
    @objc func goBack(){
        _ = self.navigationController?.popViewController(animated: true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
