//
//  MLTGoogleMapSearchPageViewController.swift
//  seiosnativeapp
//
//  Created by Bigstep IOS on 7/31/18.
//  Copyright © 2018 bigstep. All rights reserved.
//

import UIKit
import GoogleMaps

class MLTGoogleMapSearchPageViewController: UIViewController,UISearchBarDelegate,GMUClusterManagerDelegate, GMSMapViewDelegate, GMUClusterRendererDelegate,GoogleMapMarkerDelegate,UIGestureRecognizerDelegate {

    var searchBar = UISearchBar()
    var listingTypeId:Int!
    var viewSearchType : Int!
    var listingSearchName = ""
    
    var mapView = GMSMapView()
    var mainView = UIView()
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
    
    var categ_id : Int!
    var tapGesture = UITapGestureRecognizer()
    
    private var infoWindow = GoogleMapMarkerWindowView()
    fileprivate var locationMarker : GMSMarker? = GMSMarker()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        
        super.viewDidLoad()
        
        _ = SearchBarContainerView(self, customSearchBar:searchBar)
        searchBar.setPlaceholderWithColor(NSLocalizedString("Search \(listingSearchName)",  comment: ""))
        searchBar.delegate = self
        
        mainView.frame = view.frame
        mainView.backgroundColor = bgColor
        view.addSubview(mainView)
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(MLTGoogleMapSearchPageViewController.cancel))
        leftNavView.addGestureRecognizer(tapView)
        
        let backIconImageView = createImageView(CGRect(x: 0,y: 12,width: 22,height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")
        leftNavView.addSubview(backIconImageView)
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        let filter = UIBarButtonItem( title: fiterIcon , style: UIBarButtonItem.Style.plain , target:self , action: #selector(MLTGoogleMapSearchPageViewController.filter))
        filter.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "FontAwesome", size: FONTSIZEExtraLarge)!],for: UIControl.State())
        self.navigationItem.rightBarButtonItem = filter
        
        automaticallyAdjustsScrollViewInsets = false
        definesPresentationContext = true
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(MLTGoogleMapSearchPageViewController.resignKeyboard))
        tapGesture.delegate = self
        tapGesture.cancelsTouchesInView = false;
        view.addGestureRecognizer(tapGesture)
        
        googleMap()
    }
    
    @objc func resignKeyboard(){
        searchBar.resignFirstResponder()
    }
    
    @objc func filter(){
        
        if filterSearchFormArray.count > 0 {
            let presentedVC = FilterSearchViewController()
            presentedVC.formController.form = CreateNewForm()
            
            presentedVC.filterArray = filterSearchFormArray
            presentedVC.serachFor = "listing"
            presentedVC.url = "listings/search-form"
            presentedVC.contentType = "listings"
            presentedVC.listingTypeId = listingTypeId
            presentedVC.stringFilter = searchBar.text!
            
            isCreateOrEdit = false
            navigationController?.pushViewController(presentedVC, animated: false)
        }
        else{
            let presentedVC = FilterSearchViewController()
            
            presentedVC.searchUrl = "listings/search-form"
            presentedVC.serachFor = "listing"
            presentedVC.url = "listings/search-form"
            presentedVC.contentType = "listings"
            presentedVC.listingTypeId = listingTypeId
            presentedVC.stringFilter = searchBar.text!
            isCreateOrEdit = true
            navigationController?.pushViewController(presentedVC, animated: false)
        }
        
    }
    
    // We frame the map
    func googleMap()
    {
        let camera = GMSCameraPosition.camera(withLatitude: kCameraLatitude,
                                              longitude: kCameraLongitude, zoom: 10)
        mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: TOPPADING, width: view.bounds.width, height: view.bounds.height-(TOPPADING)  - tabBarHeight), camera: camera)
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        //        mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: mapView.bounds.height-(100), right: 0)
//        mapView.mapType =  .terrain
        mainView.addSubview(mapView)
        mapView.delegate = self
        
        nextButton = createButton(CGRect(x: view.bounds.width/2 - 35, y: view.bounds.height  - tabBarHeight - 40, width: 100, height: 30), title: "View More", border: false, bgColor: true, textColor: UIColor.white)
        nextButton.backgroundColor = textColorDark.withAlphaComponent(0.9)
        nextButton.addTarget(self, action: #selector(MLTGoogleMapSearchPageViewController.nextMember), for: .touchUpInside)
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
            infoWindow.lblTag.text = locationIcon+"   "+address//\u{f3c5}
            infoWindow.lblTag.font = UIFont(name: "FontAwesome", size:FONTSIZENormal)
            
            // Offset the info window to be directly above the tapped marker
            //infoWindow.center = mapView.projection.point(for: location)
            //infoWindow.center.y = infoWindow.center.y - 15
            
            
            
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
//            //infoWindow.center = mapView.projection.point(for: location)
//            //infoWindow.center.y = infoWindow.center.y - 15
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
            SiteMltObject().redirectToMltProfilePage(self ,subjectType : "sitereview_listing" , listingTypeIdValue : listingTypeId , listingIdValue : "\(photoInfo["listing_id"]!)" , viewTypeValue : viewSearchType)
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
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        
        if searchBar.text?.length != 0
        {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.reload(_:)), object: searchBar)
            perform(#selector(self.reload(_:)), with: searchBar, afterDelay: 0.5)
        }
        else
        {
            activityIndicatorView.stopAnimating()
//            if arrRecentSearchOptions.count != 0
//            {
//                tblAutoSearchSuggestions.reloadData()
//                tblAutoSearchSuggestions.isHidden = false
//                self.listingsTableView.isHidden = true
//            }
//            else
//            {
//                tblAutoSearchSuggestions.isHidden = true
//            }
        }
        
    }
    @objc func reload(_ searchBar: UISearchBar) {
        if searchBar.text?.length != 0
        {
//            searchQueryInAutoSearch()
        }
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        searchBar.resignFirstResponder()
    }
    
//    func updateAutoSearchArray(str : String) {
//        if !arrRecentSearchOptions.contains(str)
//        {
//            arrRecentSearchOptions.insert(str, at: 0)
//            if arrRecentSearchOptions.count > 6 {
//                arrRecentSearchOptions.remove(at: 6)
//            }
//            UserDefaults.standard.set(arrRecentSearchOptions, forKey: "arrRecentSearchOptions")
//        }
//    }
//    func searchQueryInAutoSearch(){
//        searchDic.removeAll(keepingCapacity: false)
//        searchDic["search"] = searchBar.text
//        if categ_id != nil{
//            searchDic["category"] = "\(categ_id)"
//        }
//        filterSearchString = searchBar.text!
//        pageNumber = 1
//        showSpinner = true
//
//        findAllMembers()
//    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchDic.removeAll(keepingCapacity: false)
        searchDic["search"] = searchBar.text
        if categ_id != nil{
            searchDic["category"] = "\(categ_id)"
        }
        filterSearchString = searchBar.text!
        pageNumber = 1
        showSpinner = true
        
        findAllMembers()
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
            
            parameter = ["limit":"\(customLimit)", "page":"\(pageNumber)","restapilocation":"\(loc)","viewType":"1", "listingtype_id": String(listingTypeId)]
            url = "listings"
            
            
            // Set Parameters for Search
            if searchDic.count > 0 {
                parameter.merge(searchDic)
            }
            searchDic.removeAll(keepingCapacity: false)
            // Send Server Request to Share Content
            post(parameter , url: url, method: "GET") { (succeeded, msg) -> () in
                
                // Remove Spinner
                DispatchQueue.main.async(execute: {
                    if self.showSpinner{
                        activityIndicatorView.stopAnimating()
                    }
                    self.showSpinner = false
                    self.searchBar.resignFirstResponder()
                    if msg{
                        if let body = succeeded["body"] as? NSDictionary{
                            if let members = body["response"] as? NSArray{
                                self.mapView.removeFromSuperview()
                                self.allMapMembers.removeAll(keepingCapacity: false)
                                self.googleMap()
                                self.allMapMembers = self.allMapMembers + (members as [AnyObject])
                                for i in 0 ..< (members.count) {
                                    if let listingMain = members[i] as? NSDictionary{
                                        if var lat: Double = listingMain["latitude"] as? Double{
                                            if var lang: Double = listingMain["longitude"] as? Double{
                                                //                                                lat = lat as! Double
                                                //                                                lang = lang as! Double
                                                if (self.kCameraLatitude == 0.0 && self.kCameraLongitude == 0.0)
                                                {
                                                    self.kCameraLatitude = lat
                                                    self.kCameraLongitude = lang
                                                    
                                                    let camera = GMSCameraPosition.camera(withLatitude: self.kCameraLatitude,
                                                                                          longitude: self.kCameraLongitude, zoom: 10)
                                                    self.mapView.camera = camera
                                                }
                                                
                                                let extent = 0.2
                                                lat = lat + extent * self.randomScale()
                                                lang = lang + extent * self.randomScale()
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

    @objc func cancel(){
        searchDic.removeAll()
        self.searchBar.resignFirstResponder()
        _ = self.navigationController?.popViewController(animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if searchDic.count > 0 {
            if globFilterValue != ""{
                searchBar.text = globFilterValue
                // searchBar.endEditing(true)
            }
            searchBar.endEditing(true)
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        searchBar.resignFirstResponder()
        
        if (self.isMovingFromParent){
            if fromGlobSearch{
                loadFilter("search")
                globSearchString = searchBar.text!
                backToGlobalSearch(self)
            }
        }
        
    }
    
    // Check for Blog Update Every Time when View Appears
    override func viewDidAppear(_ animated: Bool) {
        if searchDic.count > 0 {
            if globFilterValue != ""{
                searchBar.text = globFilterValue
            }
            pageNumber = 1
            self.findAllMembers()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
