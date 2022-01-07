//
//  ArtWork.swift
//  seiosnativeapp
//
//  Created by bigstep on 01/11/17.
//  Copyright © 2017 bigstep. All rights reserved.
//

import MapKit

class ArtWork: NSObject, MKAnnotation {
    
    
    var coordinate: CLLocationCoordinate2D
    var userId: Int!
    var title: String?
    var subtitle: String?
    var image: UIImage!
    
    
    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D ) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        super.init()
    }
    
}
