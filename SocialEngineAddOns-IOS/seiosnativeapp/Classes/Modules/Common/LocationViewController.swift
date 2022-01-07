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


//
//  LocationViewController.swift
//  seiosnativeapp
//

import UIKit
import CoreLocation

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}


class LocationViewController: UIViewController, UISearchBarDelegate,CLLocationManagerDelegate,UITableViewDataSource,UITableViewDelegate {
    var searchBar = UISearchBar()
    let locationManager = CLLocationManager()
    var searchResultTableView : UITableView!
    var searchResult = [AnyObject]()
    var latitude:Double = 0.0
    var longitude:Double = 0.0
    var fromActivityFeed = false
    var leftBarButtonItem : UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = bgColor
        self.title = NSLocalizedString("Where are you?",  comment: "")
        locationTag.removeAll(keepingCapacity: false)
        
        searchBar.frame = CGRect(x: 0, y: TOPPADING-3, width: view.bounds.width, height: ButtonHeight - PADING)
        searchBar.delegate = self
        searchBar.placeholder = NSLocalizedString("Search...",  comment: "")
        searchBar.layer.borderWidth = 3
        searchBar.layer.borderColor = UIColor.white.cgColor
        searchBar.backgroundColor = UIColor.clear
        view.addSubview(searchBar)
        
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(LocationViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem

        
        
        for subView in searchBar.subviews  {
            for subsubView in subView.subviews  {
                if let textField = subsubView as? UITextField {
                    textField.textColor = textColorDark
                    textField.font = UIFont(name: fontBold, size: FONTSIZENormal)
                }
            }
        }
        
        //let locationManager = CLLocationManager()
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // locationManager.requestWhenInUseAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
        activityIndicatorView.center = CGPoint(x: view.center.x, y: 140)
//        spinner.hidesWhenStopped = true
//        spinner.style = UIstyle.gray
//        view.addSubview(spinner)
        self.view.addSubview(activityIndicatorView)
       // activityIndicatorView.center = self.view.center
        activityIndicatorView.startAnimating()
        
        
        searchResultTableView = UITableView(frame: CGRect(x: 0, y: 120, width: view.bounds.width, height: view.bounds.height-120), style: UITableView.Style.grouped)
        searchResultTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        searchResultTableView.dataSource = self
        searchResultTableView.delegate = self
        searchResultTableView.rowHeight = 50.0
        searchResultTableView.backgroundColor = tableViewBgColor
        searchResultTableView.separatorColor = TVSeparatorColor
        view.addSubview(searchResultTableView)
 
        
        self.edgesForExtendedLayout = UIRectEdge.all;
        self.automaticallyAdjustsScrollViewInsets = false
        
    }
    
    // MARK:  UISearchBarDelegates
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.length > 0{
            locationSearch(searchBar.text!)
        }
        self.searchResult.removeAll(keepingCapacity: false)
        self.searchResultTableView.reloadData()
    }
    
    // Handle Simple Search on Search Click
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Add search text to searchDic
        if searchBar.text?.length > 0{
            locationSearch(searchBar.text!)
        }
        self.searchResult.removeAll(keepingCapacity: false)
        self.searchResultTableView.reloadData()
    }
    
    // MARK:  Make server Request
    func locationSearch(_ searchText:String){
        
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
            activityIndicatorView.center = CGPoint(x: view.center.x, y: 140)
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
       //     activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            userInteractionOff = false
            
            var parameters = [String:String]()
            if latitude != 0{
                parameters = ["latitude":"\(latitude)" ,"longitude" :"\(longitude)", "location_detected" :"\(searchText)",]
                latitude = 0
            }else{
                parameters = ["suggest":"\(searchText)", "limit": "10"]
            }
            
            
            
            // Send Server Request to Share Content
            post(parameters, url: "/sitetagcheckin/suggest", method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    userInteractionOff = true
                    activityIndicatorView.stopAnimating()
                    if msg{
                        // On Success Update
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            //   self.popAfterDelay = true
                        }
                        
                        if succeeded["body"] != nil{
                            
                            //                            if let response = succeeded["body"] as? NSDictionary{
                            if let suggestion = succeeded["body"] as? NSArray{
                                
                                self.searchResult = suggestion as [AnyObject]
                            }
                            //                            }
                            self.searchResultTableView.reloadData()
                        }
                    }else{
                        // Handle Server Side Error
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                    }
                })
            }
        }else{
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self)
        }
        
    }
    
    // Generate Custom Alert Messages
    func showAlertMessage( _ centerPoint: CGPoint, msg: String, timer: Bool){
        self.view .addSubview(validationMsg)
        showCustomAlert(centerPoint, msg: msg)
        if timer {
            // Initialization of Timer
           self.createTimer(self)
        }
    }
    func createTimer(_ target: AnyObject){
        timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  #selector(stopTimer), userInfo: nil, repeats: false)
    }
    // Stop Timer
    @objc func stopTimer() {
        stop()
    }
    
    // MARK:  UITableViewDelegate & UITableViewDataSource
    
    // Set Blog Tabel Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    // Set Blog Tabel Header Height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    // Set Blog Section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return searchResult.count
    }
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        
        if let response = searchResult[(indexPath as NSIndexPath).row] as? NSDictionary {
            
            cell.textLabel?.text = response["label"] as? String
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.font = UIFont(name: fontName, size: FONTSIZENormal)
            cell.textLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
            cell.textLabel?.sizeToFit()
            
        }
        
        return cell
    }
    
    // Handle Blog Table Cell Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        if let response = searchResult[(indexPath as NSIndexPath).row] as? NSDictionary {
            var dic = Dictionary<String, String>()
            for (key, value) in response{
                
                if let id = value as? NSNumber {
                    dic["\(key)"] = String(id as! Int)
                }
                
                if let receiver = value as? NSString {
                    dic["\(key)"] = receiver as String
                }
            }
            
            locationTag["location"] = response
        }
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    // MARK: - CoreLocation Delegates
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        self.locationManager.stopUpdatingLocation()
        
        let userLocation:CLLocation = locations[0] as CLLocation
        longitude = userLocation.coordinate.longitude
        latitude =  userLocation.coordinate.latitude
        
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error)->Void in
            
            if (error != nil) {
                
                //print("Reverse geocoder failed with error" + error!.localizedDescription)
                
                return
                
            }
            
            if placemarks!.count > 0 {
                
                let pm = placemarks![0] as CLPlacemark
                if pm.subLocality != ""{
                    self.locationSearch("\(String(describing: pm.subLocality))")
                }
                
            } else {
                
                //print("Problem with the data received from geocoder")
                
            }
            
        })
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        //print("Error while updating location " + error.localizedDescription)
        
    }
    
    @objc func goBack()
    {
        if fromActivityFeed == true {
            let pv = AdvanceActivityFeedViewController()
            self.navigationController?.pushViewController(pv, animated: true)
        }else{
            _ = self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
