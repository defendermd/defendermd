//
//  ContentDetailViewController.swift
//  seiosnativeapp
//
//  Created by bigstep on 19/10/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit

class ContentDetailViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    var url = String()
    var trackOrderTableView:UITableView!
    var trackArr = NSMutableArray()
    var info:UILabel!
    var dynamicHeight:CGFloat = 120
    
    // MARK:Load view
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupView()

        
        BrowseDetail()
    }
    override func viewWillAppear(_ animated: Bool)
    {
        navigationSetUp()
    }
    
    @objc func goBack()
    {
         _ = self.navigationController?.popViewController(animated: false)
    }
    func navigationSetUp()
    {
        self.navigationController?.navigationBar.isHidden = false
        self.title = NSLocalizedString("Track Order", comment: "")
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        let tapView = UITapGestureRecognizer(target: self, action: #selector(ContentDetailViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")
        leftNavView.addSubview(backIconImageView)
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
    }
    // MARK: Define view elements
    func setupView()
    {
        view.backgroundColor = bgColor
        if tabBarHeight > 0{
            trackOrderTableView = UITableView(frame: CGRect(x:0, y:0, width:view.bounds.width, height:view.bounds.height-tabBarHeight), style: .grouped)
        }else{
            trackOrderTableView = UITableView(frame: CGRect(x:0, y:0, width:view.bounds.width, height:view.bounds.height), style:.grouped)
        }
        trackOrderTableView.register(ContentDetailTableViewCell.self, forCellReuseIdentifier: "Cell")
        trackOrderTableView.rowHeight = 120
        trackOrderTableView.dataSource = self
        trackOrderTableView.delegate = self
        trackOrderTableView.isOpaque = false
        trackOrderTableView.backgroundColor = UIColor.white//tableViewBgColor
        trackOrderTableView.separatorColor = TVSeparatorColorClear
        self.view.addSubview(trackOrderTableView)
        
        // Message when records not available
        self.info = createLabel(CGRect(x:10,y:UIScreen.main.bounds.height/2,width:self.view.bounds.width-20 , height:30), text: NSLocalizedString("You do not have any product in order.",  comment: "") , alignment: .center, textColor: textColorMedium)
        self.info.numberOfLines = 0
        self.info.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.info.backgroundColor = bgColor
        self.info.tag = 1000
        self.info.isHidden = true
        self.view.addSubview(self.info)
    }
    
    // MARK: Tableview Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.trackArr.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        
        return dynamicHeight
        
    }
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell = trackOrderTableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)as! ContentDetailTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.backgroundColor = UIColor.white
        
        let dic = trackArr[indexPath.row] as! NSDictionary
        
        if let trackingid = dic["tracking_number"] as? Int
        {
         cell.labId.text = String(format: NSLocalizedString("ID %@", comment: ""),"\(trackingid)")
        }
        else if let trackingid = dic["tracking_number"] as? String
        {
          
          cell.labId.text = String(format: NSLocalizedString("ID %@", comment: ""),"\(trackingid)")
        }
        
        if let title = dic["title"] as? String
        {
            
            cell.labTitle.text = "\(title)"
        }
        
       
        if let date = dic["date"] as? String
        {
            
            let date = dateDifferenceWithEventTime(date)
            var DateC = date.components(separatedBy: "'")
            var tempInfo = "\(DateC[1]) \(DateC[0]) \(DateC[2])"
            if DateC.count > 3{
                tempInfo += " at \(DateC[3])"
                let value = NSLocalizedString("Date: ", comment: "")+"\(tempInfo)"
                cell.labdate.text = "\(value)"
            }
        }
        else
        {
            cell.labdate.text = NSLocalizedString("Date: ", comment: "")
        }
        

        
        if let status = dic["status"] as? String
        {
            let value = NSLocalizedString("Status: ", comment: "")+"\(status)"
            cell.labstatus.text = "\(value)"
        }
        else
        {
            cell.labstatus.text = NSLocalizedString("Status: ", comment: "")
        }
        
        if let service = dic["service"] as? String
        {
            let value = NSLocalizedString("Service: ", comment: "")+"\(service)"
            cell.labService.text = "\(value)"
        }
        else
        {
          cell.labService.text = NSLocalizedString("Service: ", comment: "")
        }
        
        if let note = dic["note"] as? String
        {
            let value = NSLocalizedString("Note: ", comment: "")+"\(note)"
            cell.labNotes.text = "\(value)"
        }
        else
        {
          cell.labNotes.text = NSLocalizedString("Note: ", comment: "")
        }
        cell.labNotes.sizeToFit()
        cell.lineView.frame.origin.y =  cell.labNotes.frame.size.height + cell.labNotes.frame.origin.y+10
        
        dynamicHeight = 120
        if dynamicHeight < (cell.lineView.frame.origin.y + cell.lineView.bounds.height)
        {
            dynamicHeight = cell.lineView.frame.origin.y + cell.lineView.bounds.height
  
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 0.0001
        
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 0.0001
    }
    // MARK: - Server call
    func BrowseDetail()
    {
        if Reachabable.isConnectedToNetwork()
        {
//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()

            self.trackArr.removeAllObjects()
            self.info.isHidden = true
            //Set Parameters & path for Sign Up Form
            let parameters = [String:String]()
            // Send Server Request for Sign Up Form
            post(parameters, url: url, method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg
                    {
                        if let dic = succeeded["body"] as? NSMutableDictionary
                        {
                            if let arr = dic["shipment_tracking"] as? NSMutableArray
                            {
                                self.trackArr = arr
                                
                            }

                        }
                        if self.trackArr.count == 0
                        {
                          self.info.isHidden = false
                            
                        }
                        self.trackOrderTableView.reloadData()
                    }
                    else
                    {
                        if succeeded["message"] != nil
                        {
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                    }
                })
            }
            
        }
        
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        
    }
    

}
