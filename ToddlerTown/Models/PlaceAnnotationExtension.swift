//
//  PlaceAnnotationExtension.swift
//  ToddlerTown
//
//  Created by Daniel Pitts on 7/28/21.
//

import MapKit
import Contacts

extension PlaceAnnotation: MKAnnotation {
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
}

extension PlaceAnnotation {
    public var example: PlaceAnnotation {
        let placeAnnotation = PlaceAnnotation()
        placeAnnotation.id = UUID()
        placeAnnotation.latitude = 43
        placeAnnotation.longitude = -89.5
        placeAnnotation.title = "Example title"
        placeAnnotation.address = "Example address"
        placeAnnotation.type = PlaceType.parksAndNature.rawValue
        return placeAnnotation
    }
}

