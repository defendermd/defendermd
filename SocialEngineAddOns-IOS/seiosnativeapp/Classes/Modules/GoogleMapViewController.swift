//
//  GoogleMapViewController.swift
//  seiosnativeapp
//
//  Created by Bigstep IOS on 7/3/18.
//  Copyright © 2018 bigstep. All rights reserved.
//

import CoreLocation
import GoogleMaps
import UIKit
var showGoogleMapView : Bool = false

class GoogleMapViewController: UIViewController,GMUClusterManagerDelegate, GMSMapViewDelegate, GMUClusterRendererDelegate,GoogleMapMarkerDelegate,CLLocationManagerDelegate {
    
    let mainView = UIView()
    var mapView = GMSMapView()
    var clusterManager: GMUClusterManager!
    var showSpinner = true
    var nextButton = UIButton()
    var kCameraLatitude : Double = 0.0
    var kCameraLongitude : Double = 0.0
    let defaults = UserDefaults.standard
    var pageNumber:Int = 1
    var customLimit : Int = 50
    var allMapMembers = [AnyObject]()
    var mapTotalMemberCount : Int = 0
    
    var scrollView = UIScrollView()
    //Listings
    var listingTypeId:Int!
    var viewType : Int!
    var listingName : String!
    var listingOption:UIButton!
    var listingBrowseType:Int!
    var browseOrMyListings = true
    var listingSeeAllFilter: UIButton!
    var showOnlyMyContent:Bool!
    var dashboardMenuDic = NSDictionary()
    var packagesEnabled:Int! = 0
    var user_id : Int!
    var showListingType: String! = ""
    var firstTime :Bool = false
    
    var floatyImageView = UIImageView()
    var btnFloaty = UIButton()
    //Category
    var categoryId : Int = 0
    var fromCategory : Bool = false
    
    var contentIcon = UILabel()
    var info = UILabel()
    
    private var infoWindow = GoogleMapMarkerWindowView()
    fileprivate var locationMarker : GMSMarker? = GMSMarker()
    
    var locationManager = CLLocationManager()
    var didFindLocation = false
    var count : Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,selector:#selector(GoogleMapViewController.applicationWillEnterForeground),name: UIApplication.willEnterForegroundNotification,object: nil)
        
        self.navigationItem.hidesBackButton = true
        searchDic.removeAll(keepingCapacity: false)
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        openMenu = false
        updateAfterAlert = true
        listingUpdate = true
        globFilterValue = ""
        category_filterId = nil
        setNavigationImage(controller: self) // Set navigation
        mainView.frame = view.frame
        mainView.backgroundColor = bgColor
        view.addSubview(mainView)
        if fromCategory == false
        {
            createScrollableListingMenu()
        }
        else
        {
            let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            leftNavView.backgroundColor = UIColor.clear
            let tapView = UITapGestureRecognizer(target: self, action: #selector(GoogleMapViewController.goBack))
            leftNavView.addGestureRecognizer(tapView)
            
            let backIconImageView = createImageView(CGRect(x: 0,y: 12,width: 22,height: 22), border: false)
            backIconImageView.image = UIImage(named: "back_icon")
            leftNavView.addSubview(backIconImageView)
            let barButtonItem = UIBarButtonItem(customView: leftNavView)
            self.navigationItem.leftBarButtonItem = barButtonItem
        }
        self.infoWindow = loadNiB()
        
        kCameraLatitude = self.defaults.double(forKey:"Latitude")
        kCameraLongitude = self.defaults.double(forKey:"Longitude")

        googleMap()
        view.backgroundColor = bgColor
        
        self.btnFloaty = UIButton(frame:CGRect(x:self.view.bounds.width-62, y:view.bounds.height-(tabBarHeight+70+70), width:50, height:50))
        self.btnFloaty.layer.masksToBounds = false
        self.btnFloaty.shadowColors = UIColor.gray
        self.btnFloaty.shadowOffsets = CGSize(width:0.1,height:0.1)
        self.btnFloaty.shadowOpacitys = 1.0
        self.btnFloaty.layer.borderWidth = 1
        self.btnFloaty.layer.borderColor = buttonColor.cgColor
        self.btnFloaty.layer.cornerRadius = self.btnFloaty.frame.height/2
        self.btnFloaty.setTitle("\u{f279}", for: UIControl.State.normal)
        let anotherViewBrowseType = sitereviewMenuDictionary["anotherViewBrowseType"] as? Int ?? 0
        if anotherViewBrowseType != 0 {
            var browseType = sitereviewMenuDictionary["viewBrowseType"] as? Int ?? 0
            
            if browseType == 4
            {
                browseType = anotherViewBrowseType
            }
            
            if browseType == 1
            {
                self.btnFloaty.setTitle("\u{f0ca}", for: UIControl.State.normal)
            }
            else if browseType == 2
            {
                self.btnFloaty.setTitle("\u{f00a}", for: UIControl.State.normal)
            }
            else if browseType == 3
            {
                self.btnFloaty.setTitle("\u{f0db}", for: UIControl.State.normal)
            }
            else
            {
                self.btnFloaty.setTitle("\u{f279}", for: UIControl.State.normal)
            }
        }
        self.btnFloaty.titleLabel?.font = UIFont(name: "FontAwesome", size:FONTSIZELarge)
        self.btnFloaty.backgroundColor = buttonColor
        self.btnFloaty.clipsToBounds = true
        self.btnFloaty.addTarget(self, action: #selector(GoogleMapViewController.toggleView), for: UIControl.Event.touchUpInside)
        if fromCategory == false{
            self.view.addSubview(self.btnFloaty)
        }
        firstTime = true
        findAllMembers() // Get response from api
    }
    
    // MARK: Create Scrollable Menu
    func createScrollableListingMenu()
    {
        openMenu = false
        scrollView.frame = CGRect(x: 0, y: TOPPADING, width: view.bounds.width, height: ButtonHeight)
        scrollView.tag = 2;
        var menuWidth = CGFloat()
        
        if self.tabBarController?.selectedIndex == 1 {
            listingTypeId = globalListingTypeId
            listingName = globalListingName
            viewType = globalViewType
        }
        
        if self.tabBarController?.selectedIndex == 2 {
            listingTypeId = globalListingTypeId1
            listingName = globalListingName1
            viewType = globalViewType1
        }
        
        if self.tabBarController?.selectedIndex == 3 {
            listingTypeId = globalListingTypeId2
            listingName = globalListingName2
            viewType = globalViewType2
        }
        
        if logoutUser == false
        {
            var listingMenu = ["%@", "Categories", "My %@"]
            var origin_x:CGFloat = 0.0
            menuWidth = CGFloat((view.bounds.width)/3)
            for i in 100 ..< 103
            {
                listingOption =  createNavigationButton(CGRect(x: origin_x, y: ScrollframeY, width: menuWidth, height: ButtonHeight), title:String(format: NSLocalizedString("\(listingMenu[(i-100)])", comment: ""), listingName), border: true, selected: false)
                if i == 100
                {
                    listingOption.setSelectedButton()
                    scrollView.contentOffset = CGPoint(x: 0, y: 0)
                    
                }
                listingOption.tag = i
                listingOption.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                listingOption.addTarget(self, action: #selector(GoogleMapViewController.listingSelectOptions(_:)), for: .touchUpInside)
                listingOption.backgroundColor = UIColor.clear//textColorLight
                listingOption.alpha = 1.0
                scrollView.addSubview(listingOption)
                origin_x += menuWidth
            }
        }
        else
        {
            var listingMenu = ["Browse %@", "Categories"]
            var origin_x:CGFloat = 0.0
            menuWidth = CGFloat((view.bounds.width)/2)
            for i in 100 ..< 102
            {
                if i == 100
                {   listingOption =  createNavigationButton(CGRect(x: origin_x, y: -ScrollframeY, width: menuWidth, height: ButtonHeight), title: String(format: NSLocalizedString("\(listingMenu[(i-100)])", comment: ""), listingName), border: false, selected: true)
                }else{
                    listingOption =  createNavigationButton(CGRect(x: origin_x, y: -ScrollframeY, width: menuWidth, height: ButtonHeight), title: String(format: NSLocalizedString("\(listingMenu[(i-100)])", comment: ""), listingName), border: false, selected: false)
                }
                listingOption.tag = i
                listingOption.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                listingOption.addTarget(self, action: #selector(GoogleMapViewController.listingSelectOptions(_:)), for: .touchUpInside)
                listingOption.backgroundColor =  UIColor.clear//textColorLight
                listingOption.alpha = 1.0
                scrollView.addSubview(listingOption)
                origin_x += menuWidth
            }
        }
        scrollView.contentSize = CGSize(width:menuWidth * 3,height:ScrollframeY)
        scrollView.bounces = false
        scrollView.isUserInteractionEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = UIColor.clear
        self.scrollView.alwaysBounceHorizontal = false
        self.scrollView.alwaysBounceVertical = false
        scrollView.isDirectionalLockEnabled = true;
        mainView.addSubview(scrollView)
    }
    
    // MARK: - Listing Selection Action
    @objc func listingSelectOptions(_ sender: UIButton)
    {
        
        listingBrowseType = sender.tag - 100
        
        if listingBrowseType == 1 {
            browseOrMyListings = true
        }else if listingBrowseType == 0 {
            return
        }else if listingBrowseType == 2 {
            browseOrMyListings = false
        }
        
        for ob in scrollView.subviews{
            if ob .isKind(of: UIButton.self){
                if ob.tag >= 100 && ob.tag <= 104
                {
                    (ob as! UIButton).setUnSelectedButton()
                    
                    if ob.tag == sender.tag
                    {
                        (ob as! UIButton).setSelectedButton()
                    }
                }
                
            }
        }
        
        searchDic.removeAll(keepingCapacity: false)
        pageNumber = 1
        showSpinner = true
        
        showGoogleMapView = true
        if listingBrowseType == 1 {
            browseOrMyListings = false
            showOnlyMyContent = false
            let presentedVC = CategoryBrowseViewController()
            presentedVC.listingName = listingName
            presentedVC.listingTypeId = self.listingTypeId
            presentedVC.dashboardMenuDic = dashboardMenuDic
            navigationController?.pushViewController(presentedVC, animated: false)
            
        }else{
            var viewType : Int = 0
            var tempListingBrowseType : Int = 0
                
            var tempBrowseViewTypeDic = listingBrowseViewTypeArr[listingTypeId]!
            viewType = tempBrowseViewTypeDic["viewType"]!
            tempListingBrowseType = tempBrowseViewTypeDic["browseType"]!
            
            switch(tempListingBrowseType){
            case 1:
                let presentedVC = MLTBrowseListViewController()
                presentedVC.title = listingName
                presentedVC.showOnlyMyContent = false
                presentedVC.listingTypeId = self.listingTypeId
                presentedVC.viewType = viewType //sitereviewMenuDictionary["viewType"] as! Int
                presentedVC.listingName = listingName
                presentedVC.browseOrMyListings = browseOrMyListings
                presentedVC.dashboardMenuDic = dashboardMenuDic
                navigationController?.pushViewController(presentedVC, animated: false)
            case 2:
                
                let presentedVC = MLTBrowseGridViewController()
                presentedVC.title = listingName
                presentedVC.showOnlyMyContent = false
                presentedVC.listingTypeId = self.listingTypeId
                presentedVC.viewType = viewType
                presentedVC.listingName = listingName
                presentedVC.browseOrMyListings = browseOrMyListings
                presentedVC.dashboardMenuDic = dashboardMenuDic
                navigationController?.pushViewController(presentedVC, animated: false)
                
                break
            case 3:
                
                let presentedVC = MLTBrowseMatrixViewController()
                presentedVC.title = listingName
                presentedVC.showOnlyMyContent = false
                presentedVC.listingTypeId = self.listingTypeId
                presentedVC.viewType = viewType //sitereviewMenuDictionary["viewType"] as! Int
                presentedVC.listingName = listingName
                presentedVC.browseOrMyListings = browseOrMyListings
                presentedVC.dashboardMenuDic = dashboardMenuDic
                navigationController?.pushViewController(presentedVC, animated: false)
                
                break
            default:
                print("Wrong Selection")
                break
            }
        }
    }
    

    @objc func toggleView()

    {
        showGoogleMapView = false
        listingNameToShow = sitereviewMenuDictionary["headerLabel"] as! String
        sitereviewMenuDictionary = dashboardMenuDic
        
        let anotherViewBrowseType = sitereviewMenuDictionary["anotherViewBrowseType"] as? Int ?? 0
        if anotherViewBrowseType != 0 {
            var browseType = sitereviewMenuDictionary["viewBrowseType"] as? Int ?? 0
            let viewType = sitereviewMenuDictionary["viewProfileType"] as? Int ?? 0
            
            if browseType == 0 || viewType == 0 {
                return
            }
            
            if browseType == 4
            {
                browseType = anotherViewBrowseType
            }
            
            if MLTbrowseOrMyListings == nil{
                MLTbrowseOrMyListings = true
            }
            SiteMltObject().redirectToMltBrowsePage(self, showOnlyMyContent: false, listingTypeIdValue : sitereviewMenuDictionary["listingtype_id"] as! Int , listingNameValue : sitereviewMenuDictionary["headerLabel"] as! String , MLTbrowseorMyListingsValue : MLTbrowseOrMyListings! , browseTypeValue : browseType , viewTypeValue : viewType,dashboardMenuDic:dashboardMenuDic)
        }
        else
        {
            return
        }
    }


    // We frame the map
    func googleMap()
    {
        let CameraLatitude = self.defaults.double(forKey:"Latitude")
        let CameraLongitude = self.defaults.double(forKey:"Longitude")
        
        let camera = GMSCameraPosition.camera(withLatitude: kCameraLatitude,
                                              longitude: kCameraLongitude, zoom: 10)
        let location = self.defaults.string(forKey: "Location")
        if fromCategory == false
        {
            mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: TOPPADING + ButtonHeight, width: view.bounds.width, height: view.bounds.height-(TOPPADING)  - tabBarHeight - ButtonHeight), camera: camera)
        }
        else
        {
            mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: TOPPADING, width: view.bounds.width, height: view.bounds.height-(TOPPADING)  - tabBarHeight), camera: camera)
        }
        self.mapView.alpha = 1
        if CameraLatitude == 0.0 && CameraLongitude == 0.0 && locationOnhome == 1 && isChangeManually == 1 && autodetectLocation == 1 && setLocation == true{
            if (CLLocationManager.locationServicesEnabled())
            {
                let defaults = UserDefaults.standard
                switch CLLocationManager.authorizationStatus() {
                case .notDetermined, .restricted, .denied:
                    print("No access")
                    if AppLauchForMLT == true && locationOnhome == 1 && isChangeManually == 1 && autodetectLocation == 1{
                        AppLauchForMLT = false
                        // At the time of app installation , user also login at time ios default pop up show , so first time we don't show our custom pop-up
                        if defaults.bool(forKey: "showMsg")
                        {
                            currentLocation(controller: self)
                        }
                        defaults.set(true, forKey: "showMsg")
                    }
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
            else
            {
                if AppLauchForMLTGPS == true {
                    AppLauchForMLTGPS = false
                    gpsLocation(controller: self)
                }
            }
        }
        
        if setLocation == false
        {
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
//        mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: mapView.bounds.height-(100), right: 0)
//        mapView.mapType =  .terrain
        if CameraLatitude != 0.0 && CameraLongitude != 0.0 {
            let position = CLLocationCoordinate2D(latitude: CameraLatitude, longitude: CameraLongitude)
            let marker = GMSMarker(position: position)
            marker.title = location
            marker.tracksViewChanges = true
            marker.map = mapView
        }
        
        mainView.addSubview(mapView)
        mapView.delegate = self
        
        nextButton = createButton(CGRect(x: view.bounds.width/2 - 35, y: view.bounds.height  - tabBarHeight - 40, width: 100, height: 30), title: "View More", border: false, bgColor: true, textColor: UIColor.white)
        nextButton.backgroundColor = textColorDark.withAlphaComponent(0.9)
        nextButton.addTarget(self, action: #selector(GoogleMapViewController.nextMember), for: .touchUpInside)
        nextButton.alpha = 0.7
        view.addSubview(nextButton)
        
        // Set up the cluster manager with default icon generator and renderer.
        let iconGenerator = GMUDefaultClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: mapView, clusterIconGenerator: iconGenerator)
        renderer.delegate = self
        clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm, renderer: renderer)
    }
    
    func loadNiB() -> GoogleMapMarkerWindowView {
        let infoWindow = GoogleMapMarkerWindowView.instanceFromNib() as! GoogleMapMarkerWindowView
        var frame = infoWindow.frame
        frame.size.width = self.view.frame.size.width
        frame.origin.y = self.view.frame.size.height - frame.size.height - tabBarHeight
        infoWindow.frame = frame
        return infoWindow
    }
    
    // MARK: - GMUClusterManagerDelegate
    func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) -> Bool {
        let newCamera = GMSCameraPosition.camera(withTarget: cluster.position,
                                                 zoom: mapView.camera.zoom + 1)
        let update = GMSCameraUpdate.setCamera(newCamera)
        mapView.moveCamera(update)
        return false
    }
    
    /// Returns a random value between -1.0 and 1.0.
    private func randomScale() -> Double {
        return Double(arc4random()) / Double(UINT32_MAX) * 2.0 - 1.0
    }
    
    // MARK: - GMUMapViewDelegate
    // In this we pass the data for infowindow
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let poiItem = marker.userData as? POIItem {
            var markerData : NSDictionary!
            if let data = poiItem.userData1{
                markerData = data
            }
            
            locationMarker = marker
            infoWindow.removeFromSuperview()
            infoWindow = loadNiB()
            guard let location = locationMarker?.position else {
                print("locationMarker is nil")
                return false
            }
            // Pass the spot data to the info window, and set its delegate to self
            infoWindow.spotData = markerData
            infoWindow.delegate = self //as? GoogleMapMarkerDelegate
            // Configure UI properties of info window
            //infoWindow.alpha = 0.6
            //infoWindow.layer.cornerRadius = 12
            //infoWindow.layer.borderWidth = 2
            
            if let stringUrl = markerData?["image_normal"] as? String{
                let url = URL(string: stringUrl)
                infoWindow.btnProfileImage.kf.setImage(with: url, for: .normal, placeholder: UIImage(named : "user_profile_image.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                    
                })
            }
            
            let address = markerData?["location"] as? String ?? "Country"
            let title = markerData?["title"] as? String ?? "Unknown"
            let tag = markerData?["categoryTitle"] as? String ?? "Tags"
            
            infoWindow.lblAddress.text = "\u{f02c}  "+tag
            infoWindow.lblAddress.font = UIFont(name: "FontAwesome", size:FONTSIZENormal)
            infoWindow.lblTitle.text = title
            
            let iconFont = CTFontCreateWithName(("FontAwesome" as CFString?)!, FONTSIZENormal, nil)
            let textFont = CTFontCreateWithName((fontName as CFString?)!, FONTSIZENormal, nil)
            let iconPart = NSMutableAttributedString(string: "\(locationIcon)  ", attributes: [NSAttributedString.Key.font:iconFont ,  NSAttributedString.Key.foregroundColor : textColorLight])
            let paragraphStyle = NSMutableParagraphStyle()
            
            // *** set LineSpacing property in points ***
            paragraphStyle.lineSpacing = 1.5 // Whatever line spacing you want in points
            
            let textPart = NSMutableAttributedString(string: "  \(address)", attributes: [NSAttributedString.Key.font:textFont , NSAttributedString.Key.foregroundColor : textColorLight])
            
//            textPart.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, (textPart.length)))
            iconPart.append(textPart)
            
//            self.privacyButton.setAttributedTitle(iconPart, for: .normal)

            infoWindow.lblTag.attributedText = iconPart//locationIcon+"    "+address//\u{f3c5}
            
            // Offset the info window to be directly above the tapped marker
            //infoWindow.center = mapView.projection.point(for: location)
            //infoWindow.center.y = infoWindow.center.y - 15
            
            infoWindow.btnRedirectLocation.titleLabel?.text = locationIcon//"\u{f5eb}"
            infoWindow.btnRedirectLocation.titleLabel?.textColor = textColorLight
            infoWindow.btnRedirectLocation.titleLabel?.font = UIFont(name: "FontAwesome", size:FONTSIZENormal)
            
            
            self.view.addSubview(infoWindow)
        }
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
//        if (locationMarker != nil)
//        {
//            guard let location = locationMarker?.position else {
//                print("locationMarker is nil")
//                return
//            }
            //infoWindow.center = mapView.projection.point(for: location)
            //infoWindow.center.y = infoWindow.center.y - 15
//        }
    }
    // We remove the infowindow , when user click anywhere on the map
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        infoWindow.removeFromSuperview()
    }
    
    // We modify the google marker from user image
    func renderer(_ renderer: GMUClusterRenderer, willRenderMarker marker: GMSMarker) {
        if let poiItem = marker.userData as? POIItem {
            var markerData : NSDictionary!
            if let data = poiItem.userData1{
                markerData = data
            }
            let imageView = UIImageView()
            imageView.frame.size.width = 40
            imageView.frame.size.height = 40
            imageView.layer.borderWidth = 1
            imageView.layer.masksToBounds = false
            imageView.layer.borderColor = UIColor.black.cgColor
            imageView.layer.cornerRadius = imageView.frame.height/2
            imageView.clipsToBounds = true
            
            if let stringUrl = markerData?["image_normal"] as? String{
                let url = URL(string: stringUrl)
                imageView.kf.setImage(with: url)
                marker.iconView = imageView
            }
        }
    }
            
    func didTapInfoButton(data: NSDictionary) {
        if let photoInfo = data as? NSDictionary {
            SiteMltObject().redirectToMltProfilePage(self ,subjectType : "sitereview_listing" , listingTypeIdValue : listingTypeId , listingIdValue : "\(photoInfo["listing_id"]!)" , viewTypeValue : viewType)
        }
    }
    
    // Redirect user location into google map or browser
    func didTapRedirectLocButton(data: NSDictionary) {
        let lat = data["latitude"] as? Double ?? 0.0
        let lang = data["longitude"] as? Double ?? 0.0
        let newString = data["location"] as? String ?? ""
        let loc = newString.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
        print("https://maps.google.com/maps?f=d&daddr=\(String(describing: loc))=&sll=\(lat),\(lang)")
        
        if let url = URL(string: "https://maps.google.com/maps?f=d&daddr=\(String(describing: loc))=&sll=\(lat),\(lang)"){
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @objc func nextMember(){
        if self.allMapMembers.count < self.mapTotalMemberCount {
            pageNumber  = pageNumber + 1
            findAllMembers()
        }
        else{
            showToast(message: "No More Listings", controller: self)
        }
    }
    
    func findAllMembers(){
        
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
           
            if self.showSpinner{
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height-85 - (tabBarHeight / 4))
               
                if (self.pageNumber == 1){
                    activityIndicatorView.center = self.view.center
                }
                self.view.addSubview(activityIndicatorView)
                activityIndicatorView.startAnimating()
            }
            
            let defaults = UserDefaults.standard
            let loc = defaults.string(forKey: "Location") ?? ""
    
            var url : String = ""
            var parameter = [String:String]()
            if fromCategory == true
            {
//                url = "listings/categories"
                url = "listings"
                parameter = ["limit":"\(customLimit)", "page":"\(pageNumber)","restapilocation":"\(loc)", "listingtype_id": String(listingTypeId), "category_id":"\(self.categoryId)","viewType":"1"]
            }
            else
            {
                url = "listings"
                parameter = ["limit":"\(customLimit)", "page":"\(pageNumber)","restapilocation":"\(loc)","viewType":"1", "listingtype_id": String(listingTypeId), "listing_filter": showListingType]
                
            }
           
            // Set Parameters for Search
            if searchDic.count > 0 {
                parameter.merge(searchDic)
            }
            
            // Send Server Request to Share Content
            post(parameter , url: url, method: "GET") { (succeeded, msg) -> () in
                
                // Remove Spinner
                DispatchQueue.main.async(execute: {
                    if self.showSpinner{
                        activityIndicatorView.stopAnimating()
                    }
                    self.showSpinner = false
                    
                    if msg{
                        if let body = succeeded["body"] as? NSDictionary{
                            if let members = body["response"] as? NSArray{
                                if self.pageNumber == 1 {
                                    
                                    if self.firstTime == false {
                                        self.mapView.removeFromSuperview()
                                        self.allMapMembers.removeAll(keepingCapacity: false)
                                        self.googleMap()
                                    }
                                    else
                                    {
                                        self.firstTime = false
                                    }
                                }
                                self.allMapMembers = self.allMapMembers + (members as [AnyObject])
                                for i in 0 ..< (members.count) {
                                    if let listingMain = members[i] as? NSDictionary{
                                        if var lat: Double = listingMain["latitude"] as? Double{
                                            if var lang: Double = listingMain["longitude"] as? Double{
                                                if (self.kCameraLatitude == 0.0 && self.kCameraLongitude == 0.0)
                                                {
                                                    
                                                    self.kCameraLatitude = lat
                                                    self.kCameraLongitude = lang
                                                    
                                                    let camera = GMSCameraPosition.camera(withLatitude: self.kCameraLatitude,
                                                                                          longitude: self.kCameraLongitude, zoom: 10)
                                                    self.mapView.camera = camera
                                                }
                                                
                                                self.count = self.count + 1
                                                let extent = 0.00002
                                                lat = lat + extent * Double(i)//self.randomScale()
                                                lang = lang + extent * Double(i)//self.randomScale()
                                                let name = "Item"
                                                let item = POIItem(position: CLLocationCoordinate2DMake(lat, lang), name: name,userData1:listingMain)
                                                
                                                if self.mapView.isHidden == false {
                                                    self.clusterManager.add(item)
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                self.clusterManager.cluster()
                                self.clusterManager.setDelegate(self, mapDelegate: self)
                                
                            }
                            if let totalItemCount = body["totalItemCount"] as? Int
                            {
                                self.mapTotalMemberCount = totalItemCount
                                
                                if totalItemCount == 0 || self.count == 0{
                                    self.mapView.alpha = 0.5
                                    self.contentIcon = createLabel(CGRect(x: self.view.bounds.width/2 - 30,y: self.view.bounds.height/2-80,width: 60 , height: 60), text: NSLocalizedString("\(listingDefaultIcon)",  comment: "") , alignment: .center, textColor: navColor)
                                    self.contentIcon.font = UIFont(name: "FontAwesome", size: 50)
                                    self.mainView.addSubview(self.contentIcon)
                                    
                                    self.info = createLabel(CGRect(x: 0, y: 0,width: self.view.bounds.width * 0.8 , height: 50), text: NSLocalizedString("You do not have any listing entries.",  comment: "") , alignment: .center, textColor: navColor)
                                    self.info.sizeToFit()
                                    self.info.tag = 1000
                                    self.info.numberOfLines = 0
                                    self.info.center = self.view.center
                                    self.info.backgroundColor = bgColor
                                    self.mainView.addSubview(self.info)
                                }
                            }
                            
                            if let packagesEnabled = body["packagesEnabled"] as? Int
                            {
                                self.packagesEnabled = packagesEnabled
                            }
                            
                            if let canCreate = body["canCreate"] as? Bool{
                                if canCreate == true {
                                    var searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(GoogleMapViewController.searchItem))
                                    
                                    searchItem.imageInsets = UIEdgeInsets(top: 0,left: 0, bottom: 0, right: 0)
                                    
                                    var addBlog = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(GoogleMapViewController.addNewListing))
                                    
                                    addBlog.imageInsets = UIEdgeInsets(top: 0,left: 0, bottom: 0, right: 0)
                                    searchItem.tintColor = textColorPrime
                                    addBlog.tintColor = textColorPrime
                                    self.navigationItem.setRightBarButtonItems([addBlog,searchItem], animated: true)
                                }
                                else
                                {
                                    let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(GoogleMapViewController.searchItem))
                                    self.navigationItem.rightBarButtonItem = searchItem
                                    searchItem.tintColor = textColorPrime
                                }
                            }
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

    // Searching Items
    @objc func searchItem(){
        searchDic.removeAll()
        let presentedVC = MLTGoogleMapSearchPageViewController()
        presentedVC.listingTypeId = listingTypeId
        presentedVC.viewSearchType = viewType
        presentedVC.listingSearchName = listingName
        self.navigationController?.pushViewController(presentedVC, animated: false)
        globalCatg = ""
        listingGlobalTypeId = listingTypeId
        Formbackup.removeAllObjects()
        let url : String = "listings/search-form"
        loadFilter(url)
    }
    
    // Create Listing Form
    @objc func addNewListing(){
        
        if packagesEnabled == 1
        {
            isCreateOrEdit = true
            let presentedVC = PackageViewController()
            presentedVC.contentType = "listings"
            presentedVC.url = "listings/packages"
            presentedVC.listingTypeId = listingTypeId
            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            let nativationController = UINavigationController(rootViewController: presentedVC)
            self.present(nativationController, animated:false, completion: nil)
            
        }else{
            isCreateOrEdit = true
            let presentedVC = FormGenerationViewController()
            presentedVC.formTitle = NSLocalizedString("Post A New Listing", comment: "")
            presentedVC.contentType = "listings"
            presentedVC.param = [ : ]
            presentedVC.url = "listings/create"
            presentedVC.listingTypeId = listingTypeId!
            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            let nativationController = UINavigationController(rootViewController: presentedVC)
            self.present(nativationController, animated:false, completion: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    //Set Location
    
    @objc func applicationWillEnterForeground(_ application: UIApplication) {
        
        let CameraLatitude = self.defaults.double(forKey:"Latitude")
        let CameraLongitude = self.defaults.double(forKey:"Longitude")
        
        if CameraLatitude == 0.0 && CameraLongitude == 0.0 && locationOnhome == 1 && isChangeManually == 1 && autodetectLocation == 1 && setLocation == true{
            if (CLLocationManager.locationServicesEnabled())
            {
                let defaults = UserDefaults.standard
                switch CLLocationManager.authorizationStatus() {
                case .notDetermined, .restricted, .denied:
                    print("No access")
                    if AppLauchForMLT == true {
                        AppLauchForMLT = false
                        // At the time of app installation , user also login at time ios default pop up show , so first time we don't show our custom pop-up
                        if defaults.bool(forKey: "showMsg")
                        {
                            currentLocation(controller: self)
                        }
                        defaults.set(true, forKey: "showMsg")
                    }
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
            else
            {
                if AppLauchForMLTGPS == true {
                    AppLauchForMLTGPS = false
                    gpsLocation(controller: self)
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        
        let userLocation :CLLocation = locations[0] as CLLocation
        if didFindLocation == false
        {
            setLocation = false
            self.didFindLocation = true
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(userLocation) { (placemarks, error) in
                if (error != nil){
                    print("error in reverseGeocode")
                }
                
                if placemarks != nil {
                    let placemark = placemarks! as [CLPlacemark]
                    
                    if placemark.count>0{
                        let placemark = placemarks![0]
                        // print("\(placemarks!)")
                        var place : String = ""
                        var subLocality : String = ""
                        var locality : String = ""
                        var administrativeArea : String = ""
                        var country : String = ""
                        var postalCode : String = ""
                        
                        var state : String = ""
                        var city : String = ""
                        var countryCode : String = ""
                        
                        if placemark.addressDictionary != nil
                        {
                            
                            if let State = placemark.addressDictionary!["State"] as? String
                            {
                                state = State
                            }
                            
                            if let City = placemark.addressDictionary!["City"] as? String
                            {
                                city = City
                            }
                            
                            if let cd = placemark.addressDictionary!["CountryCode"] as? String
                            {
                                countryCode = cd
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
                            postalCode = placemark.postalCode!
                        }
                        
                        
                        let defaults = UserDefaults.standard
                        
                        // print(postalCode)
                        var prePostalCode = defaults.string(forKey:"postalCode")
                        if prePostalCode == nil
                        {
                            prePostalCode = "0"
                        }
                        //  print(prePostalCode!)
                        //                        postalCode != prePostalCode! && locationOnhome == 1
                        if locationOnhome == 1 && isChangeManually == 1 && autodetectLocation == 1
                        {
                            
                            if placemark.country != nil
                            {
                                country = placemark.country!
                            }
                            
                            if placemark.subLocality != nil
                            {
                                subLocality = placemark.subLocality!
                                defaultlocation = "\(subLocality),"
                            }
                            else if place != ""
                            {
                                defaultlocation = "\(place),"
                            }
                            if placemark.locality != nil
                            {
                                locality = placemark.locality!
                                defaultlocation.append(" \(locality)")
                            }
                            else if placemark.administrativeArea != nil
                            {
                                administrativeArea = placemark.administrativeArea!
                                defaultlocation.append(" \(administrativeArea)")
                            }
                            else if placemark.country != nil
                            {
                                country = placemark.country!
                                defaultlocation.append(" \(country)")
                            }
                            
                            defaults.set(postalCode, forKey: "postalCode")
                            
                            defaults.set(defaultlocation, forKey: "Location")
                            //self.view.makeToast("Your current location is set \(defaultlocation).", duration: 5, position: "bottom")
                            showToast(message: NSLocalizedString("Your current location is set to ",comment: "")+"\(defaultlocation).", controller: self)
                            let location = locations.last! as CLLocation
                            let currentLatitude = location.coordinate.latitude
                            let currentLongitude = location.coordinate.longitude
                            
                            defaults.set(currentLatitude, forKey: "Latitude")
                            defaults.set(currentLongitude, forKey: "Longitude")
                            
                            // print(currentLatitude)
                            // print(currentLongitude)
                            
                            self.kCameraLatitude = currentLatitude
                            self.kCameraLongitude = currentLongitude
                            
                            setDeviceLocation(location: defaultlocation, latitude: currentLatitude, longitude: currentLongitude, country: country, state: state, zipcode: postalCode, city: city, countryCode: countryCode)
                            
                            self.findAllMembers()
                        }
                    }
                }
           
            }
        }
    }

    
    @objc func goBack(){
        _ = self.navigationController?.popViewController(animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
