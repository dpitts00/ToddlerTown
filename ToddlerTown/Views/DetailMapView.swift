//
//  DetailMapView.swift
//  CoreDataTest
//
//  Created by Daniel Pitts on 7/23/21.
//

import SwiftUI
import MapKit

struct DetailMapView: View {
    @Binding var startRegion: MKCoordinateRegion
    var selectedPlace: MKPlaceAnnotation?
    var userLocation = CLLocationManager().location
    
    var body: some View {
        let region = Binding<MKCoordinateRegion>(
            get: {
                self.startRegion
            },
            set: {
                self.startRegion = $0
            }
        )
        
        Map(coordinateRegion: region, interactionModes: [], showsUserLocation: true, userTrackingMode: .constant(.none), annotationItems: [selectedPlace!]) { annotation in
            MapMarker(coordinate: annotation.coordinate)
        }
        .onAppear {
            withAnimation {
                // thank God.
                
                if let userLocation = userLocation,
                   let selectedPlace = selectedPlace {
                    print("showing both userLocation and selectedPlace on Map")
                    self.startRegion = MKCoordinateRegion(center: selectedPlace.coordinate, span: MKCoordinateSpan(latitudeDelta: abs(selectedPlace.coordinate.latitude - userLocation.coordinate.latitude) * 2.5, longitudeDelta: abs(selectedPlace.coordinate.longitude - userLocation.coordinate.longitude) * 2.5))
                } else {
                    print("showing selectedPlace only on Map")
                    self.startRegion = MKCoordinateRegion(center: selectedPlace?.coordinate ?? MKPlaceAnnotation.example.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.25, longitudeDelta: 0.25))
                }
                
            }
        }
    }
}

struct DetailMapView_Previews: PreviewProvider {
    static var previews: some View {
        DetailMapView(startRegion: .constant(MKPlaceAnnotation.exampleRegion))
    }
}
