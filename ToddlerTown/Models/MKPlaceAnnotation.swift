//
//  MKPlaceAnnotation.swift
//  CoreDataTest
//
//  Created by Daniel Pitts on 7/18/21.
//

import SwiftUI
import MapKit

class MKPlaceAnnotation: NSObject, Identifiable, MKAnnotation {
    var id: UUID
    var title: String?
    var subtitle: String?
//    var nickname: String = ""
    var coordinate: CLLocationCoordinate2D
    var type: PlaceType
    
    init(id: UUID, title: String?, subtitle: String?, coordinate: CLLocationCoordinate2D, type: PlaceType) {
        self.id = id
        self.title = title ?? ""
        self.subtitle = subtitle ?? ""
        self.type = type
        self.coordinate = coordinate
    }
    
    static var example: MKPlaceAnnotation {
        let place = MKPlaceAnnotation(id: UUID(), title: "Olbrich Botanical Gardens", subtitle: "Park", coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(43.092639), longitude: CLLocationDegrees(-89.335542)), type: .parksAndNature)
        return place
    }
    
    static var exampleRegion: MKCoordinateRegion {
        return MKCoordinateRegion(center: MKPlaceAnnotation.example.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.25, longitudeDelta: 0.25))
    }
}

extension MKPlaceAnnotation {
    func getPlace(from places: [PlaceAnnotation]) -> PlaceAnnotation? {
        return places.first(where: { $0.title == self.title && $0.type == self.type.rawValue && $0.latitude == self.coordinate.latitude && $0.longitude == self.coordinate.longitude } )
    }
}

extension MKPlaceAnnotation {
    func getRegionWithUser(and selectedPlace: MKPlaceAnnotation?) -> MKCoordinateRegion {
        var delta = 0.25
        if let selectedPlace = selectedPlace,
           let userLocation = CLLocationManager().location {
            let newCenter = selectedPlace.coordinate
            let latitudeRange = abs(selectedPlace.coordinate.latitude - userLocation.coordinate.latitude) + 0.05
            let longitudeRange = abs(selectedPlace.coordinate.longitude - userLocation.coordinate.longitude) + 0.05
            delta = [latitudeRange, longitudeRange].max() ?? 0.25
            let newSpan = MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta)
            return MKCoordinateRegion(center: newCenter, span: newSpan)
        } else if let selectedPlace = selectedPlace {
            let newCenter = selectedPlace.coordinate
            let newSpan = MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta)
            return MKCoordinateRegion(center: newCenter, span: newSpan)
        }
        return MKCoordinateRegion(center: MKPlaceAnnotation.example.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.25, longitudeDelta: 0.25))
    }
    
    func getRegion() -> MKCoordinateRegion {
        let delta = 0.25
        let newCenter = self.coordinate
        let newSpan = MKCoordinateSpan(latitudeDelta: CLLocationDegrees(delta), longitudeDelta: CLLocationDegrees(delta))
        return MKCoordinateRegion(center: newCenter, span: newSpan)
    }
}



