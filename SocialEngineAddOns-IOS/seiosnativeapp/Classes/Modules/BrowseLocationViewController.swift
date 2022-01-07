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

//  BrowseLocationViewController.swift
//  seiosnativeapp
//
import CoreLocation
import UIKit

protocol ReturnLocationToForm : class
{
    func sendLocation(location:String)
    func isReloadForm(reload : Bool)
    func sendLocationParam(locationParam:[String : Any])
}


class BrowseLocationViewController: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate, UITableViewDelegate,UITableViewDataSource,CLLocationManagerDelegate,UISearchBarDelegate
{
    weak var delegate : ReturnLocationToForm?
    var locationManager = CLLocationManager()
    var currentLatitude = 0.0
    var currentLongitude = 0.0
    var didFindLocation = false
    var fromFormGeneration = false
    var fromMainForm = false
    var fromSignUp = false
    //    var sendMsg:UIBarButtonItem!
    //    var locLabel: UITextField!
    //    var loc : String!
    //    var locationArray : NSArray!
    //    var locationTable: UITableView!
    //    var locDic : NSDictionary!
    var iscomingFrom:String = ""
    var popAfterDelay:Bool!
    //    var button : UIButton!
    //    var navView = UIView()
    //    var titleLabel = UILabel()
    var leftBarButtonItem : UIBarButtonItem!
    var detectMyLocation : UIButton!
    var currenLocation :String = ""
    
    var headerView = UIView()
    var locationResultResponse = [AnyObject]()
    var searchBar = UISearchBar()
    var searchResultTableView : UITableView!
    var fromActivityFeed = false
    var searchController : UISearchController!
    var gpsService : Bool = true
    //var button = UIButton()
    
    //location
    var subLocality : String = ""
    var locality : String = ""
    var administrativeArea : String = ""
    var country : String = ""
    var postalCode : String = ""
    
    var state : String = ""
    var city : String = ""
    var countryCode : String = ""
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,selector:#selector(BrowseLocationViewController.applicationWillEnterForeground),name: UIApplication.willEnterForegroundNotification,object: nil)
        self.automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barTintColor = UIColor.white
        popAfterDelay = false
        
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
            //            gpsLocation(controller: self)
        }
        
        if iscomingFrom == "feed"
        {
            
            let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            leftNavView.backgroundColor = UIColor.clear
            let tapView = UITapGestureRecognizer(target: self, action: #selector(BrowseLocationViewController.cancel))
            leftNavView.addGestureRecognizer(tapView)
            let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
            backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
            leftNavView.addSubview(backIconImageView)
            
            let barButtonItem = UIBarButtonItem(customView: leftNavView)
            self.navigationItem.leftBarButtonItem = barButtonItem
            
        }
        else
        {
            let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            leftNavView.backgroundColor = UIColor.clear
            let tapView = UITapGestureRecognizer(target: self, action: #selector(BrowseLocationViewController.cancel))
            leftNavView.addGestureRecognizer(tapView)
            let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
            backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
            leftNavView.addSubview(backIconImageView)
            
            let barButtonItem = UIBarButtonItem(customView: leftNavView)
            self.navigationItem.leftBarButtonItem = barButtonItem
            
        }
        
        let button   = UIButton(type: UIButton.ButtonType.system) as UIButton
        button.frame = CGRect(x: self.view.bounds.size.width-100, y: 0, width: 20, height: 20)
        button.backgroundColor = UIColor.clear
        button.setImage(UIImage(named: "Checkmark.png")!.maskWithColor(color: textColorPrime), for: UIControl.State())
        button.addTarget(self, action: #selector(BrowseLocationViewController.send), for: UIControl.Event.touchUpInside)
        //        button.isHidden = true
        let sendButton = UIBarButtonItem()
        
        sendButton.customView = button
        
        if !fromFormGeneration
        {
            self.navigationItem.setRightBarButtonItems([sendButton], animated: true)
        }
        
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(BrowseLocationViewController.resignKeyboard))
        tap.delegate = self
        tap.cancelsTouchesInView = false;
        view.addGestureRecognizer(tap)
        searchResultTableView = UITableView(frame: CGRect(x: 0, y: TOPPADING, width: view.bounds.width, height: view.bounds.height), style: UITableView.Style.plain)
        searchResultTableView.register(LocationTableViewCell.self, forCellReuseIdentifier: "Cell")
        searchResultTableView.dataSource = self
        searchResultTableView.delegate = self
        searchResultTableView.rowHeight = 50.0
        searchResultTableView.backgroundColor = tableViewBgColor
        searchResultTableView.separatorColor = TVSeparatorColor
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            searchResultTableView.estimatedSectionHeaderHeight = 0
        }
        view.addSubview(searchResultTableView)
        configuration()
        
    }
    
    func configuration()
    {
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
        
        headerView.addSubview(searchController.searchBar)
        
        let defaults = UserDefaults.standard
        if let name = defaults.string(forKey: "Location")
        {
            if name == "" && defaultlocation != nil && defaultlocation != ""
            {
                self.searchController.searchBar.text = defaultlocation
            }
            else
            {
                self.searchController.searchBar.text = name
            }
        }
        else if defaultlocation != nil && defaultlocation != ""
        {
            self.searchController.searchBar.text = defaultlocation
        }
        
        detectMyLocation = createButton(CGRect(x: 0, y: getBottomEdgeY(inputView: searchController.searchBar), width: view.bounds.width, height: 40), title: NSLocalizedString(" Detect My Location", comment: ""), border: true, bgColor: false, textColor: buttonColor)
        detectMyLocation.addTarget(self, action: #selector(detectLocation), for: UIControl.Event.touchUpInside)
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
        
        headerView.addSubview(detectMyLocation)
        searchResultTableView.tableHeaderView = headerView
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        //  DispatchQueue.main.async(execute: {
        
        // DispatchQueue.main.async {   // if use it speed of searching get slow
        DispatchQueue.global(qos: .userInteractive).async {
            if let length : Int = self.searchController.searchBar.text?.length
            {
                if length > 0{
                    self.locationSearch(self.searchController.searchBar.text!)
                }
            }
        }
    }
    // Handle Simple Search on Search Click
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        // Add search text to searchDic
        DispatchQueue.global(qos: .background).async {
            if let length : Int = self.searchController.searchBar.text?.length
            {
                if length > 0{
                    self.locationSearch(self.searchController.searchBar.text!)
                }
            }
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let userLocation :CLLocation = locations[0] as CLLocation
        if didFindLocation == false
        {
            let location = locations.last! as CLLocation
            self.currentLatitude = location.coordinate.latitude
            self.currentLongitude = location.coordinate.longitude
            self.didFindLocation = true
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(userLocation) { (placemarks, error) in
                if (error != nil){
                    print("error in reverseGeocode")
                }
                
                if placemarks != nil {
                    var place : String = ""
                    let placemark = placemarks! as [CLPlacemark]
                    
                    if placemark.count>0{
                        let placemark = placemarks![0]
                        print("\(placemarks!)")
                        
                        
                        if placemark.addressDictionary != nil
                        {
                            
                            if let State = placemark.addressDictionary!["State"] as? String
                            {
                                self.state = State
                            }
                            
                            if let City = placemark.addressDictionary!["City"] as? String
                            {
                                self.city = City
                            }
                            
                            if let cd = placemark.addressDictionary!["CountryCode"] as? String
                            {
                                self.countryCode = cd
                            }
                            
                            if let FormattedAddressLines = placemark.addressDictionary!["FormattedAddressLines"] as? NSArray
                            {
                                if let pla = FormattedAddressLines[0] as? String
                                {
                                    place = pla
                                }
                            }
                            
                        }
                        
                        if placemark.postalCode != nil
                        {
                            self.postalCode = placemark.postalCode!
                        }
                        
                        if placemark.subLocality != nil
                        {
                            self.subLocality = placemark.subLocality!
                            self.currenLocation = "\(self.subLocality),"
                        }
                        else if place != ""
                        {
                            self.currenLocation = "\(place),"
                        }
                        if placemark.locality != nil
                        {
                            self.locality = placemark.locality!
                            self.currenLocation.append(" \(self.locality)")
                        }
                        else if placemark.administrativeArea != nil
                        {
                            self.administrativeArea = placemark.administrativeArea!
                            self.currenLocation.append(" \(self.administrativeArea),")
                        }
                        else if placemark.country != nil
                        {
                            self.country = placemark.country!
                            self.currenLocation.append(" \(self.country)")
                        }
                        
                    }
                    self.fetchPlacesNearCoordinate(CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude) , radius: 500.0, name: "Near By")
                }
                
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //titleLabel.text = ""
        self.navigationController?.navigationBar.viewWithTag(1001)?.removeFromSuperview()
        
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    func fetchPlacesNearCoordinate(_ coordinate: CLLocationCoordinate2D, radius: Double, name : String)
    {
        
        activityIndicatorView.center = view.center
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        
        let urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=\(apiServerKey)&location=\(coordinate.latitude),\(coordinate.longitude)&radius=\(radius)&rankby=prominence&sensor=true"
        print(urlString)
        
        let urlNew:String = urlString.addingPercentEncoding( withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let endpoint = URL(string: urlNew)
        let data = NSData(contentsOf: endpoint!)
        if data != nil {
            DispatchQueue.main.async(execute: {
                do
                {
                    let anyObj = try JSONSerialization.jsonObject(with: data! as Data, options: []) as! [String:AnyObject]
                    if let resultErrorMessage = anyObj["error_message"] as? String{
                        showToast(message: resultErrorMessage, controller: self)
                        //                    self.popAfterDelay = true
                        //                    createTimer(self)
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
        //
        //       let endpoint = URL(string: urlNew)
        //       let data = try? Data(contentsOf: endpoint!)
        //        do {
        //            let anyObj = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:AnyObject]
        //            if let resultErrorMessage = anyObj["error_message"] as? String{
        //                self.view.makeToast(resultErrorMessage, duration: 5, position: "bottom")
        //                self.popAfterDelay = true
        //                createTimer(self)
        //                return
        //            }else if let resultArray = anyObj["results"] as? NSArray {
        //               self.locationResultResponse = resultArray as [AnyObject]
        //                if resultArray.count > 0 {
        //                    self.searchResultTableView.reloadData()
        //                }
        //            }
        //
        //        }
        //        catch
        //        {
        //            print("json error: \(error)")
        //        }
        
    }
    
    func locationSearch(_ query:String){
        let radius = 2000.0
        let urlString = "https://maps.googleapis.com/maps/api/place/textsearch/json?key=\(apiServerKey)&query=\(query)&radius=\(radius)&rankby=prominence&sensor=true&location=\(self.currentLatitude),\(self.currentLongitude)&radius=50000"
        print(urlString)
        let urlNew:String = urlString.addingPercentEncoding( withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        let endpoint = URL(string: urlNew)
        let data = try? Data(contentsOf: endpoint!)
        DispatchQueue.main.async(execute: {
            do {
                let anyObj = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:AnyObject]
                if let resultErrorMessage = anyObj["error_message"] as? String{
                    showToast(message: resultErrorMessage, controller: self)
                    //                self.popAfterDelay = true
                    //                createTimer(self)
                    return
                }
                else if let resultArray = anyObj["results"] as? NSArray
                {
                    if resultArray.count > 0
                    {
                        DispatchQueue.main.async {
                            self.locationResultResponse.removeAll(keepingCapacity: false)
                            self.locationResultResponse = resultArray as [AnyObject]
                            print("========Hello===========")
                            activityIndicatorView.stopAnimating()
                            self.searchResultTableView.reloadData()
                        }
                    }
                }
                
            }
            catch
            {
                print("json error: \(error)")
            }
        })
    }
    
    @objc func detectLocation()
    {
        if didFindLocation == true
        {
            if fromFormGeneration == true
            {
                
                if self.currenLocation == ""
                {
                    return
                }
                else
                {
                    var locParams = [String:Any]()
                    locParams["latitude"] = self.currentLatitude
                    locParams["longitude"] = self.currentLongitude
                    locParams["formatted_address"] = self.currenLocation
                    locParams["location"] = self.currenLocation
                    if fromMainForm == true
                    {
                        delegate?.sendLocation(location: self.currenLocation)
                        delegate?.isReloadForm(reload: true)
                        delegate?.sendLocationParam(locationParam: locParams)
                        //reloadForm = true
                    }
                    else
                    {
                        UserDefaults.standard.set(self.currenLocation, forKey: "Locationfilter")
                    }
                    _ = self.navigationController?.popViewController(animated: true)
                    return
                }
                
            }
            
            self.searchController.searchBar.text = self.currenLocation
            let defaults = UserDefaults.standard
            defaults.set(self.currentLatitude, forKey: "Latitude")
            defaults.set(self.currentLongitude, forKey: "Longitude")
            
            defaultlocation = self.currenLocation
            defaults.set(defaultlocation, forKey: "Location")
            self.view.endEditing(true)
            self.searchResultTableView.isHidden = true
            
            if defaultlocation == ""{
                //            setLocation = true
                defaults.set("", forKey: "Location")
                defaults.set("0", forKey: "postalCode")
                defaults.set(0.0, forKey: "Latitude")
                defaults.set(0.0, forKey: "Longitude")
            }
            
            if logoutUser == false {
                
                activityIndicatorView.center = view.center
                self.view.addSubview(activityIndicatorView)
                activityIndicatorView.startAnimating()
                
                var parameters = [String:AnyObject]()
                var loc = [String:AnyObject]()
                //{loc={
                loc =  ["country":self.country,"state":self.state,"zipcode":self.postalCode,"city":city,"countryCode":countryCode,"address":defaultlocation,"formatted_address":defaultlocation,"location":defaultlocation,"latitude":self.currentLatitude,"longitude":self.currentLongitude] as [String : AnyObject]
                
                //}}
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: loc, options:  [])
                    let  finalString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
                    
                    parameters["location"] = finalString as AnyObject?
                    parameters["resource_type"] = "user" as AnyObject
                    parameters["user_id"] = "\(currentUserId)" as AnyObject
                }
                catch _ {
                    // failure
                    //print("Fetch failed: \(error.localizedDescription)")
                }
                
                if Reachabable.isConnectedToNetwork() {
                    activityPostTag(parameters, url: "memberlocation/edit-address", method: "POST") { (succeeded, msg) -> () in
                        DispatchQueue.main.async(execute: {
                            activityIndicatorView.stopAnimating()
                            if msg{
                                print("true")
                                showToast(message: NSLocalizedString("Default location has been changed.", comment: ""), controller: self, onView: false, time: 3)
                                
                                _ = self.navigationController?.popViewController(animated: true)
                            }
                            else
                            {
                                print("false")
                                _ = self.navigationController?.popViewController(animated: true)
                            }
                        })
                    }
                }
                else
                {
                    print(network_status_msg)
                }
            }
            else
            {
                showToast(message: NSLocalizedString("Default location has been changed.", comment: ""), controller: self, onView: false, time: 3)
                
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
        else
        {
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
    
    // Stop Timer
    @objc func stopTimer() {
        stop()
        
        if popAfterDelay == true
        {
            _ = navigationController?.popViewController(animated: true)
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        let navView = UIView()
        let titleLabel = UILabel()
        navView.frame = CGRect(x: 60, y: 0, width: self.view.frame.size.width-120, height: 44)
        titleLabel.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width-120, height: self.navigationController!.navigationBar.frame.size.height)
        titleLabel.text = NSLocalizedString("Choose a Location",  comment: "")
        titleLabel.textColor = textColorPrime
        titleLabel.font = UIFont(name: fontName, size: 18)
        //titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.textAlignment = .center
        
        navView.tag = 1001
        navView.addSubview(titleLabel)
        self.navigationController?.navigationBar.addSubview(navView)
        
        
    }
    
    func openSlideMenu()
    {
        self.view.endEditing(true)
        let dashObj = DashboardViewController()
        dashObj.getDynamicDashboard()
        dashObj.dashboardTableView.reloadData()
        //
        openSideMenu = true
    }
    
    @objc func resignKeyboard()
    {
        self.view.endEditing(true)
    }
    
    @objc func cancel()
    {
        _ = self.navigationController?.popViewController(animated: true)
        
    }
    func createTimer(_ target: AnyObject){
        timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  #selector(stopTimer), userInfo: nil, repeats: false)
    }
    
    @objc func send()
    {
        
        if fromFormGeneration == true
        {
            let location = self.searchController.searchBar.text!
            if fromSignUp == true
            {
                UserDefaults.standard.set(location, forKey: "signUpLocation")
            }
            else if fromMainForm == true
            {
                delegate?.sendLocation(location: location)
                delegate?.isReloadForm(reload: true)
                //reloadForm = true
            }
            else
            {
                UserDefaults.standard.set(location, forKey: "Locationfilter")
            }
            _ = self.navigationController?.popViewController(animated: true)
            return
        }
        
        defaultlocation = self.searchController.searchBar.text!
        let defaults = UserDefaults.standard
        defaults.set(defaultlocation, forKey: "Location")
        self.view.endEditing(true)
        self.searchResultTableView.isHidden = true
        
        
        if defaultlocation == ""{
            //            setLocation = true
            defaults.set("0", forKey: "postalCode")
            defaults.set(0.0, forKey: "Latitude")
            defaults.set(0.0, forKey: "Longitude")
        }
        
        if logoutUser == false {
            
            activityIndicatorView.center = view.center
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.startAnimating()
            
            var parameters = [String:AnyObject]()
            var loc = [String:AnyObject]()
            
            loc =  ["country":self.country,"state":self.state,"zipcode":self.postalCode,"city":city,"countryCode":countryCode,"address":defaultlocation,"formatted_address":defaultlocation,"location":defaultlocation,"latitude":self.currentLatitude,"longitude":self.currentLongitude] as [String : AnyObject]
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: loc, options:  [])
                let  finalString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
                
                parameters["location"] = finalString as AnyObject?
                parameters["resource_type"] = "user" as AnyObject
                parameters["user_id"] = "\(currentUserId)" as AnyObject
            }
            catch _ {
                // failure
                //print("Fetch failed: \(error.localizedDescription)")
            }
            
            if Reachabable.isConnectedToNetwork() {
                activityPostTag(parameters, url: "memberlocation/edit-address", method: "POST") { (succeeded, msg) -> () in
                    DispatchQueue.main.async(execute: {
                        activityIndicatorView.stopAnimating()
                        if msg{
                            print("true")
                            showToast(message: NSLocalizedString("Default location has been changed.", comment: ""), controller: self, onView: false, time: 3)
                            _ = self.navigationController?.popViewController(animated: true)
                        }
                        else
                        {
                            print("false")
                            _ = self.navigationController?.popViewController(animated: true)
                        }
                    })
                }
            }
            else
            {
                print(network_status_msg)
            }
        }
        else
        {
            showToast(message: NSLocalizedString("Default location has been changed.", comment: ""), controller: self, onView: false, time: 3)
            _ = self.navigationController?.popViewController(animated: true)
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
        if let length : Int = searchController.searchBar.text?.length
        {
            if length > 0{
                cell.subTitle.isHidden = false
                cell.subTitle.text = vicinity
                cell.title.numberOfLines = 1
            }else{
                cell.subTitle.isHidden = true
                cell.title.numberOfLines = 2
            }
        }
        cell.title.text = locationInfo["name"] as? String
        
        let ownerImageUrl = URL(string: locationInfo["icon"] as! String)
        if  ownerImageUrl != nil {
            cell.imgUser.kf.setImage(with: ownerImageUrl)
        }
        return cell
    }
    
    // Handle Blog Table Cell Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.searchController.isActive = false
        tableView.deselectRow(at: indexPath, animated: true)
        if let response = locationResultResponse[(indexPath as NSIndexPath).row] as? NSDictionary {
            var dic = Dictionary<String, String>()
            var locationName = ""
            var locParam = [String:Any]()
            if let formattedLocation = response["formatted_address"] as? String
            {
                locationName = formattedLocation
                locParam["formatted_address"] = formattedLocation
                locParam["location"] = formattedLocation
            }
            else if let locName = response["name"] as? String
            {
                locationName = locName
                locParam["formatted_address"] = locName
                locParam["location"] = locName
            }
            else if let locName = response["vicinity"] as? String
            {
                locationName = locName
                locParam["formatted_address"] = locName
                locParam["location"] = locName
            }
            
            if let geometry = response["geometry"] as? NSDictionary
            {
                if let location = geometry["location"] as? NSDictionary
                {
                    locParam["latitude"] = location["lat"]
                    locParam["longitude"] = location["lng"]
                }
            }
            
            if locationName != ""
            {
                if fromFormGeneration == true
                {
                    if fromSignUp == true
                    {
                        UserDefaults.standard.set(locationName, forKey: "signUpLocation")
                    }
                    else if fromMainForm == true
                    {
                        delegate?.sendLocation(location: locationName)
                        delegate?.isReloadForm(reload: true)
                        delegate?.sendLocationParam(locationParam: locParam)
                        //reloadForm = true
                    }
                    else
                    {
                        UserDefaults.standard.set(locationName, forKey: "Locationfilter")
                    }
                    _ = self.navigationController?.popViewController(animated: true)
                    return
                }
                
                dic["label"] = locationName
                defaultlocation = locationName
                let defaults = UserDefaults.standard
                defaults.set(defaultlocation, forKey: "Location")
            }
            if let locationPlaceId = response["place_id"] as? String{
                dic["place_id"] = locationPlaceId
            }
            
            if let locationvicinity = response["vicinity"] as? String{
                dic["vicinity"] = locationvicinity
            }else if let locationvicinity = response["name"] as? String{
                dic["vicinity"] = locationvicinity
            }else{
                dic["vicinity"] = ""
            }
            
            if let locationGeometory = response["geometry"] as? NSDictionary{
                if let locationValues = locationGeometory["location"] as? NSDictionary{
                    dic["latitude"] =  String(describing: locationValues["lat"]!)
                    dic["longitude"] = String(describing: locationValues["lng"]!)
                    
                    self.currentLatitude = locationValues["lat"]! as! Double
                    self.currentLongitude = locationValues["lng"]! as! Double
                    
                    let defaults = UserDefaults.standard
                    defaults.set(locationValues["lat"]!, forKey: "Latitude")
                    defaults.set(locationValues["lng"]!, forKey: "Longitude")
                }
            }
            
            if let locationIcon =  response["icon"] as? String{
                dic["icon"] = locationIcon
            }
            
           // locationTag["location"] = dic as NSDictionary?
        }
        
        if logoutUser == false {
            
            activityIndicatorView.center = view.center
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.startAnimating()
            
            
            var parameters = [String:AnyObject]()
            var loc = [String:AnyObject]()
            
            loc =  ["country":"","state":"","zipcode":self.postalCode,"city":"","countryCode":"","address":defaultlocation,"formatted_address":defaultlocation,"location":defaultlocation,"latitude":self.currentLatitude,"longitude":self.currentLongitude] as [String : AnyObject]
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: loc, options:  [])
                let  finalString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
                
                parameters["location"] = finalString as AnyObject?
                parameters["resource_type"] = "user" as AnyObject
                parameters["user_id"] = "\(currentUserId)" as AnyObject
            }
            catch _ {
                // failure
                //print("Fetch failed: \(error.localizedDescription)")
            }
            
            if Reachabable.isConnectedToNetwork() {
                activityPostTag(parameters, url: "memberlocation/edit-address", method: "POST") { (succeeded, msg) -> () in
                    DispatchQueue.main.async(execute: {
                        activityIndicatorView.stopAnimating()
                        if msg{
                            print("true")
                            showToast(message: NSLocalizedString("Default location has been changed.", comment: ""), controller: self, onView: false, time: 3)
                            _ = self.navigationController?.popViewController(animated: true)
                        }
                        else
                        {
                            print("false")
                            _ = self.navigationController?.popViewController(animated: true)
                        }
                    })
                }
            }
            else
            {
                print(network_status_msg)
            }
        }
        else
        {
            showToast(message: NSLocalizedString("Default location has been changed.", comment: ""), controller: self, onView: false, time: 3)
            _ = self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    func goBack()
    {
        if fromActivityFeed == true
        {
            self.dismiss(animated: true, completion: nil)
        }
        else
        {
            
            _ = self.navigationController?.popViewController(animated: true)
            
        }
    }
    
}
