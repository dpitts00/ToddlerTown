//
//  PlaceAnnotationExtension.swift
//  ToddlerTown
//
//  Created by Daniel Pitts on 7/28/21.
//

//import SwiftUI
import MapKit
import Contacts

//extension PlaceAnnotation {
//    func returnAnnotation() -> MKPlaceAnnotation {
//        let place = self
//        let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(place.latitude), longitude: CLLocationDegrees(place.longitude))
//        let annotation = MKPlaceAnnotation(id: place.id ?? UUID(), title: place.title, subtitle: "", coordinate: coordinate, type: PlaceType(rawValue: place.type ?? "park") ?? .park)
//        return annotation
//    }
//}

extension PlaceAnnotation: MKAnnotation {
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
}

// cannot ref an internal type in a public var 
//extension PlaceAnnotation {
//    public var unwrappedType: PlaceType {
//        return PlaceType(rawValue: self.type ?? "All") ?? PlaceType.all
//    }
//}

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

