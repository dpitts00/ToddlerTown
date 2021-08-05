//
//  PlaceAnnotationExtension.swift
//  ToddlerTown
//
//  Created by Daniel Pitts on 7/28/21.
//

import SwiftUI
import MapKit

extension PlaceAnnotation {
    func returnAnnotation() -> MKPlaceAnnotation {
        let place = self
        let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(place.latitude), longitude: CLLocationDegrees(place.longitude))
        let annotation = MKPlaceAnnotation(id: place.id ?? UUID(), title: place.title, subtitle: "", address: place.address, coordinate: coordinate, type: PlaceType(rawValue: place.type ?? "park") ?? .park)
        return annotation
    }
}
