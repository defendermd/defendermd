//
//  CheckInViewController.swift
//  seiosnativeapp
//
//  Created by bigstep on 31/03/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit
import CoreLocation
import Foundation
import MapKit
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


class CheckInViewController: UIViewController, UISearchBarDelegate,CLLocationManagerDelegate,UITableViewDataSource,UITableViewDelegate {
    var locationManager = CLLocationManager()
    var didFindLocation = false
    var locationResultResponse = [AnyObject]()
    var searchBar = UISearchBar()
    var searchResultTableView : UITableView!
    var fromActivityFeed = false
    var currentLatitude = 0.0
    var currentLongitude = 0.0
    var popAfterDelay:Bool!
    var searchController : UISearchController!
    var leftBarButtonItem : UIBarButtonItem!
    var headerView = UIView()
    var detectMyLocation = UIButton()
    var currenLocation :String = ""
    var gpsService : Bool = true
    var fromPostFeedVC = false

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,selector:#selector(CheckInViewController.applicationWillEnterForeground),name: UIApplication.willEnterForegroundNotification,object: nil)
        // Do any additional setup after loading the view.
        view.backgroundColor = bgColor
        self.title = NSLocalizedString("Where are you?",  comment: "")
        locationTag.removeAll(keepingCapacity: false)
        popAfterDelay = false
                
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(CheckInViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        searchResultTableView = UITableView(frame: CGRect(x: 0, y: TOPPADING, width: view.bounds.width, height: view.bounds.height), style: UITableView.Style.grouped)
        searchResultTableView.register(LocationTableViewCell.self, forCellReuseIdentifier: "Cell")
        searchResultTableView.dataSource = self
        searchResultTableView.delegate = self
        searchResultTableView.rowHeight = 50.0
        searchResultTableView.backgroundColor = tableViewBgColor
        searchResultTableView.separatorColor = TVSeparatorColor
        view.addSubview(searchResultTableView)
        configureSearchController()
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            searchResultTableView.estimatedSectionHeaderHeight = 0
        }
    }
    
    func configureSearchController() {
        headerView = UIView(frame: CGRect(x:0,y:0,width:view.bounds.width,height:100))
        view.addSubview(headerView)
        
        // Initialize and perform a minimum configuration to the search controller.
        searchController = UISearchController(searchResultsController: nil)
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search..."
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        searchController.hidesNavigationBarDuringPresentation = false
        self.definesPresentationContext = true
        // Place the search bar view to the tableview headerview.
//        searchResultTableView.tableHeaderView = searchController.searchBar
        
        headerView.addSubview(searchController.searchBar)

        detectMyLocation = createButton(CGRect(x: 0, y: getBottomEdgeY(inputView: searchController.searchBar), width: view.bounds.width, height: 40), title: NSLocalizedString(" Detect My Location", comment: ""), border: true, bgColor: false, textColor: buttonColor)
        detectMyLocation.addTarget(self, action: #selector(self.detectLocation), for: UIControl.Event.touchUpInside)
        detectMyLocation.layer.borderWidth = 0.5
        detectMyLocation.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        detectMyLocation.titleLabel?.font = UIFont(name: fontName, size: FONTSIZENormal)
        detectMyLocation.contentHorizontalAlignment = .left
        detectMyLocation.titleEdgeInsets = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 0)
        
        
        let locationLabel = UILabel(frame: CGRect(x: 5, y: 0, width: 40, height: 40))
        locationLabel.text = "  \u{f124}"
        locationLabel.textAlignment = .center
        locationLabel.textColor = buttonColor
        locationLabel.font = UIFont(name: "FontAwesome", size: FONTSIZELarge)
        
        detectMyLocation.addSubview(locationLabel)
//        view.addSubview(detectMyLocation)
        
        headerView.addSubview(detectMyLocation)
        searchResultTableView.tableHeaderView = headerView
        
        if (CLLocationManager.locationServicesEnabled())
        {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                print("No access")
                detectMyLocation.isHidden = false
//                searchResultTableView.isUserInteractionEnabled = false
            case .authorizedAlways, .authorizedWhenInUse:
                print("Access")
                detectMyLocation.isHidden = true
                 searchResultTableView.isUserInteractionEnabled = true
            }
            
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        else
        {
            gpsService = false
            detectMyLocation.isHidden = false
//            gpsLocation(controller: self)
        }
    }
    
    @objc func detectLocation()
    {
        print("click")
        if didFindLocation == false {
            if gpsService == false
            {
                gpsService = true
                gpsLocation(controller: self)
            }
            else
            {
                currentLocation(controller: self)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.fromPostFeedVC {
           self.fromPostFeedVC = false
        }
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc func applicationWillEnterForeground(_ application: UIApplication) {
        if (CLLocationManager.locationServicesEnabled())
        {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                print("No access")
            case .authorizedAlways, .authorizedWhenInUse:
                print("Access")
            }
            
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        else {
            gpsService = false
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        DispatchQueue.global(qos: .background).async {
            if self.searchController.searchBar.text?.length > 0
            {
                self.locationSearch(self.searchController.searchBar.text!)
            }
        }
    }
    // Handle Simple Search on Search Click
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        // Add search text to searchDic
        DispatchQueue.global(qos: .background).async {
            if self.searchController.searchBar.text?.length > 0
            {
                self.locationSearch(self.searchController.searchBar.text!)
            }
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        if didFindLocation == false
        {
            
            self.searchResultTableView.isUserInteractionEnabled = true
            detectMyLocation.isHidden = true
            searchResultTableView.tableHeaderView?.removeFromSuperview()
            searchResultTableView.tableHeaderView = searchController.searchBar
            
            let location = locations.last! as CLLocation
            self.currentLatitude = location.coordinate.latitude
            self.currentLongitude = location.coordinate.longitude
            self.fetchPlacesNearCoordinate(CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude) , radius: 500.0, name: "Near By")
            didFindLocation = true
        }
     }
    
    func fetchPlacesNearCoordinate(_ coordinate: CLLocationCoordinate2D, radius: Double, name : String)
    {
 
        activityIndicatorView.center = self.view.center
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        
        let urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=\(apiServerKey)&location=\(coordinate.latitude),\(coordinate.longitude)&radius=\(radius)&rankby=prominence&sensor=true"
        //print(urlString)
        
      let urlNew:String = urlString.addingPercentEncoding( withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let endpoint = URL(string: urlNew)
        let data = NSData(contentsOf: endpoint!)
        DispatchQueue.main.async(execute: {
            do
            {
                let anyObj = try JSONSerialization.jsonObject(with: data! as Data, options: []) as! [String:AnyObject]
                if let resultErrorMessage = anyObj["error_message"] as? String{
                    showToast(message: resultErrorMessage, controller: self)
                    return
                }
                else if let resultArray = anyObj["results"] as? NSArray
                {
                    self.locationResultResponse = resultArray as [AnyObject]
                    if resultArray.count > 0
                    {
                        activityIndicatorView.stopAnimating()
                        self.searchResultTableView.reloadData()
                    }
                }
            }
            catch
            {
                
            }
        })
    }
    
    func locationSearch(_ query:String){
        let radius = 2000.0
        let urlString = "https://maps.googleapis.com/maps/api/place/textsearch/json?key=\(apiServerKey)&query=\(query)&radius=\(radius)&rankby=prominence&sensor=true&location=\(self.currentLatitude),\(self.currentLongitude)&radius=50000"
        //print(urlString)
        let urlNew:String = urlString.addingPercentEncoding( withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        let endpoint = URL(string: urlNew)
        let data = try? Data(contentsOf: endpoint!)
       DispatchQueue.main.async(execute: {
        do {
            let anyObj = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:AnyObject]
            if let resultErrorMessage = anyObj["error_message"] as? String{
                showToast(message: resultErrorMessage, controller: self)
//                self.popAfterDelay = true
//               self.createTimer(self)
                return
            }
            else if let resultArray = anyObj["results"] as? NSArray
            {
                if resultArray.count > 0
                {
                    DispatchQueue.main.async {
                        self.locationResultResponse.removeAll(keepingCapacity: false)
                        self.locationResultResponse = resultArray as [AnyObject]
                        //print("========Hello===========")
                        activityIndicatorView.stopAnimating()
                        self.searchResultTableView.reloadData()
                    }
                }
            }

        }
        catch
        {
            //print("json error: \(error)")
        }
        })
    }
    
    @objc func stopTimer() {
        stop()
        if popAfterDelay == true{
            _ = navigationController?.popViewController(animated: true)

        }
    }

    
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
        return locationResultResponse.count
    }
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! LocationTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        var locationInfo:NSDictionary
        locationInfo = locationResultResponse[(indexPath as NSIndexPath).row] as! NSDictionary
        var vicinity = ""
        
        if let locationvicinity = locationInfo["vicinity"] as? String{
            vicinity = locationvicinity
        }else{
            if let locationvicinity = locationInfo["formatted_address"] as? String{
                vicinity = locationvicinity
            }
        }
        if searchController.searchBar.text?.length > 0{
            cell.subTitle.isHidden = false
            cell.subTitle.text = vicinity
            cell.title.numberOfLines = 1
         }else{
            cell.subTitle.isHidden = true
            cell.title.numberOfLines = 2
        }
        cell.title.text = locationInfo["name"] as? String
        
        let ownerImageUrl = URL(string: locationInfo["icon"] as! String)
        if  ownerImageUrl != nil {
            cell.imgUser.kf.indicatorType = .activity
            (cell.imgUser.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
            cell.imgUser.kf.setImage(with: ownerImageUrl as URL?, placeholder: UIImage(named : "default_blog_image.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                
            })
        }
        
      
        
        return cell
    }
    
    // Handle Blog Table Cell Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.searchController.isActive = false
        tableView.deselectRow(at: indexPath, animated: true)
        if let response = locationResultResponse[(indexPath as NSIndexPath).row] as? NSDictionary {
            var dic = Dictionary<String, String>()
           
            if let locationName = response["name"] as? String{
                dic["label"] = locationName
            }
            if let locationPlaceId = response["place_id"] as? String{
                dic["place_id"] = locationPlaceId
            }
            
            if let locationvicinity = response["vicinity"] as? String{
                dic["vicinity"] = locationvicinity
            }else if let locationvicinity = response["formatted_address"] as? String{
                dic["vicinity"] = locationvicinity
            }else{
                dic["vicinity"] = ""
            }
            
            if let locationGeometory = response["geometry"] as? NSDictionary{
                if let locationValues = locationGeometory["location"] as? NSDictionary{
                    dic["latitude"] =  String(describing: locationValues["lat"]!)
                    dic["longitude"] = String(describing: locationValues["lng"]!)
                }
            }
            
            if let locationIcon =  response["icon"] as? String{
                dic["icon"] = locationIcon
            }

            locationTag["location"] = dic as NSDictionary?
        }
        if self.fromPostFeedVC {
            _ = navigationController?.popViewController(animated: true)
        }
        else {
            if AgoraId != "" && enableLiveStreaming == true {
                self.dismiss(animated: true, completion: nil)
            }
        }
     
    }
    
    @objc func goBack()
    {
        if fromActivityFeed == true
        {
            self.dismiss(animated: true, completion: nil)
        }
        else
        {
            
            _ = self.navigationController?.popViewController(animated: true)
            if AgoraId != "" && enableLiveStreaming == true {
                self.dismiss(animated: true, completion: nil)
            }

        }
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
