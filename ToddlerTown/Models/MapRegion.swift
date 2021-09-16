//
//  MapRegion.swift
//  ToddlerTown
//
//  Created by Daniel Pitts on 9/16/21.
//

import MapKit

class MapRegion: ObservableObject {
    @Published var region =
        MKCoordinateRegion(center: CLLocationManager.shared.location?.coordinate ?? CLLocationCoordinate2D(latitude: 43.074701, longitude: -89.384119), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
}
