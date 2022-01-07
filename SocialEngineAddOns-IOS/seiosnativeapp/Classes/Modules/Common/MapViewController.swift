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
//  MapViewController.swift
//  seiosnativeapp


import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate,UISearchBarDelegate {
    
    var mapView: MKMapView!
    var location: String!
    var place_id : String!
    var latitude : CLLocationDegrees!
    var longitude : CLLocationDegrees!
    var popAfterDelay : Bool!
    var rightBarButton : UIBarButtonItem!
    var leftBarButtonItem : UIBarButtonItem!
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = false
        view.backgroundColor = bgColor
        
        setNavigationImage(controller: self)
        
//        let searchBar = UISearchBar()
//        searchBar.searchBarStyle = UISearchBar.Style.minimal
//        searchBar.barTintColor = UIColor.clear
//        searchBar.tintColor = textColorLight
//        searchBar.backgroundColor = navColor
//        searchBar.setPlaceholderWithColor("Search")
//        searchBar.delegate = self
//        searchBar.layer.borderWidth = 0;
//        searchBar.layer.shadowOpacity = 0;
//        navigationItem.titleView = searchBar
//        searchBar.setTextColor(textColorLight)
        
        let searchBar = UISearchBar()
        _ = SearchBarContainerView(self, customSearchBar:searchBar, isKeyboardAppear:false)
        searchBar.setPlaceholderWithColor(NSLocalizedString("Search",  comment: ""))
        searchBar.delegate = self
        
        popAfterDelay = false
        
        let navBarTitle = createLabel(CGRect(x: 0,y: 0,width: view.bounds.width,height: TOPPADING), text: "", alignment: .center, textColor: textColorLight)
        navBarTitle.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        view.addSubview(navBarTitle)
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(MapViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem

        
        mapView = MKMapView(frame: CGRect(x: 0, y: 0 , width: view.bounds.width, height: view.bounds.height - tabBarHeight))
        mapView.mapType = MKMapType.standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.showsBuildings = true
        
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Check for Location Services
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        }
        
        //Zoom to user location
        if let userLocation = locationManager.location?.coordinate {
            let viewRegion = MKCoordinateRegion(center: userLocation, latitudinalMeters: 200, longitudinalMeters: 200)
            mapView.setRegion(viewRegion, animated: false)
        }
        
        self.locationManager = locationManager
        
        DispatchQueue.main.async {
            self.locationManager.startUpdatingLocation()
        }
        
        view.addSubview(mapView)
        
        rightBarButton = UIBarButtonItem(image: UIImage(named: "upload") , style: UIBarButtonItem.Style.plain , target: self, action: #selector(MapViewController.openMapSettings))
        rightBarButton.isEnabled = false
        self.navigationItem.rightBarButtonItem = rightBarButton

        let location = self.location
        let geocoder:CLGeocoder = CLGeocoder()
        
        if place_id != ""{
            self.getLocationDetail(place_id)
        }
        else
        {
            geocoder.geocodeAddressString(location!, completionHandler: {(placemarks, error) -> Void in
            
            if((error) != nil){
                //print(error as Any)
            }
            else
            {
                
                let tempPlacemark = (placemarks![0])
                
                let placemark:CLPlacemark = tempPlacemark
                let coordinates:CLLocationCoordinate2D = placemark.location!.coordinate
                
                let pointAnnotation:MKPointAnnotation = MKPointAnnotation()
                pointAnnotation.coordinate = coordinates
                pointAnnotation.title = self.location
                
                self.mapView.showsUserLocation = true
                self.mapView.showsBuildings = true
                self.mapView?.addAnnotation(pointAnnotation)
                self.mapView?.centerCoordinate = coordinates
                self.mapView?.selectAnnotation(pointAnnotation, animated: true)
            }
            
        })
        }
    }
    
    @objc func stopTimer() {
        stop()
        if popAfterDelay == true{
            _ = navigationController?.popViewController(animated: true)
        }
    }

    
    func mapView (_ mapView: MKMapView,
        viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let pinView:MKPinAnnotationView = MKPinAnnotationView()
            pinView.annotation = annotation
            pinView.pinColor = MKPinAnnotationColor.red
            pinView.animatesDrop = true
            pinView.canShowCallout = true
            return pinView
    }
    
    func getLocationDetail(_ place_id : String){
        let urlString = "https://maps.googleapis.com/maps/api/place/details/json?placeid=" + String(self.place_id) + "&key=\(apiServerKey)"
        let urlNew:String = urlString.addingPercentEncoding( withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let endpoint = URL(string: urlNew)
        let data = try? Data(contentsOf: endpoint!)
        do {
            if data != nil {
            let anyObj = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:AnyObject]
            //
            
            if let resultErrorMessage = anyObj["error_message"] as? String{
                showToast(message: resultErrorMessage, controller: self)
                self.popAfterDelay = true
               self.createTimer(self)
                return
                
            }else if let resultArray = anyObj["result"] as? NSDictionary {
                
                if let geometory = resultArray["geometry"] as? NSDictionary{
                    if let location = geometory["location"] as? NSDictionary{
                        self.latitude = location["lat"] as! CLLocationDegrees
                        self.longitude = location["lng"] as! CLLocationDegrees
                        self.loadMap()
                        
                    }
                }
                
                
            }
            
        }
        }catch {
            //print("json error: \(error)")
        }
    }
    func createTimer(_ target: AnyObject){
        timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  #selector(stopTimer), userInfo: nil, repeats: false)
    }
    func loadMap(){
        
        rightBarButton.isEnabled = true
        let locationCoordinate = CLLocationCoordinate2D(
            latitude: self.latitude,
            longitude: self.longitude
        )
        
        _ = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: locationCoordinate, latitudinalMeters: 1500, longitudinalMeters: 1500);  // MKCoordinateRegion(center: locationCoordinate, span: span)
        mapView.setRegion(region, animated: true)
        self.mapView.showsBuildings = true
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = locationCoordinate
        annotation.title = location
        mapView.addAnnotation(annotation)
        self.mapView?.selectAnnotation(annotation, animated: true)
      
    }
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool{
        DispatchQueue.main.async {
            let pv = CoreAdvancedSearchViewController()
            searchDic.removeAll(keepingCapacity: false)
            self.navigationController?.pushViewController(pv, animated: false)
        }
   
        return true
    }
    
    @objc func goBack(){
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNavigationImage(controller: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        setNavigationImage(controller: self)
        filterSearchFormArray.removeAll(keepingCapacity: false)
        
    }
    
    @objc func openMapSettings(){
        //print("browser settings")
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
         alertController.addAction(UIAlertAction(title: NSLocalizedString("Open in Maps", comment: ""), style: .default, handler: { (UIAlertAction) -> Void in
                self.openInMap()
         }))
        
        if  (UIDevice.current.userInterfaceIdiom == .phone){
            alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .cancel, handler:nil))
        }else{
            // Present Alert as! Popover for iPad
            // Present Alert as! Popover for iPad
            alertController.modalPresentationStyle = UIModalPresentationStyle.popover
            let popover = alertController.popoverPresentationController
            popover?.sourceView = UIButton()
            popover?.sourceRect = CGRect(x: view.bounds.width/2, y: view.bounds.height/2 , width: 1, height: 1)
            popover?.permittedArrowDirections = UIPopoverArrowDirection()
        }
        self.present(alertController, animated:true, completion: nil)
        
    }
    
    func openInMap(){
        let url = NSString(string: "http://maps.apple.com/maps?ll=\(self.latitude),\(self.latitude)&q=\(location)")
        let urlStr : NSString = url.addingPercentEscapes(using: String.Encoding.utf8.rawValue)! as NSString
        let urlRedirection = URL(string:urlStr as String)
        if urlRedirection != nil {
            if UIApplication.shared.canOpenURL(urlRedirection!) {
                UIApplication.shared.openURL(urlRedirection!)
            } else {
                //print("error")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

class CustomPointAnnotation: MKPointAnnotation {
    var imageName: String!
}
