//
//  GoogleMapMarkerViewController.swift
//  seiosnativeapp
//
//  Created by Bigstep IOS on 8/2/18.
//  Copyright © 2018 bigstep. All rights reserved.
//

import UIKit
import GoogleMaps

class GoogleMapMarkerViewController: UIViewController {

    var mapView = GMSMapView()
    
    var mytitle : String = ""
    var location : String = ""
    var kCameraLatitude : Double = 0.0
    var kCameraLongitude : Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = bgColor
        
        //Navigation Bar
        navigationController?.navigationBar.isHidden = false
        setNavigationImage(controller: self) //Set navigation image on navigation bar
        self.navigationItem.setHidesBackButton(true, animated: false)//Hide back button
        self.title = NSLocalizedString(mytitle, comment: "")
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(GoogleMapMarkerViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        
        let backIconImageView = createImageView(CGRect(x: 0,y: 12,width: 22,height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")
        leftNavView.addSubview(backIconImageView)
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        let camera = GMSCameraPosition.camera(withLatitude: kCameraLatitude,
                                              longitude: kCameraLongitude, zoom: 10)
        mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: TOPPADING, width: view.bounds.width, height: view.bounds.height-(TOPPADING)  - tabBarHeight), camera: camera)
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        
        let position = CLLocationCoordinate2D(latitude: kCameraLatitude, longitude: kCameraLongitude)
        let marker = GMSMarker(position: position)
        marker.title = location
        marker.tracksViewChanges = true
        marker.map = mapView
        view.addSubview(mapView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @objc func goBack(){
        _ = self.navigationController?.popViewController(animated: false)
    }

}
