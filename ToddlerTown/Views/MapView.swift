//
//  MapView.swift
//  CoreDataTest
//
//  Created by Daniel Pitts on 7/14/21.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @Binding var selectedPlace: MKPlaceAnnotation?
    @Binding var showingPlaceDetails: Bool
    @Binding var region: MKCoordinateRegion
    @Binding var userLocationShown: Bool
    
    // will it work?
    @Binding var userLocation: CLLocationCoordinate2D?
    
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \PlaceAnnotation.title, ascending: true)],
//        animation: .default) private var places: FetchedResults<PlaceAnnotation>
    
    var places: FetchedResults<PlaceAnnotation>
   
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        let annotations = places.map { $0.returnAnnotation() }
        mapView.addAnnotations(annotations) // changed
        mapView.region = region
        mapView.showsUserLocation = true
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {

    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate, CLLocationManagerDelegate {
        var parent: MapView
        var locationManager: CLLocationManager?
        
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        // MARK: User Location
        
        func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
            getUserLocation()
        }
        
        func getUserLocation() {
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager?.requestWhenInUseAuthorization()
            
        }
        
        func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            if manager.authorizationStatus == .authorizedWhenInUse {
                parent.userLocationShown = true
            }
        }
        
        func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
            // moved it here
            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotations(parent.places.map { $0.returnAnnotation() })
            
            parent.region = mapView.region
        }
        
        // MARK: Annotations
            func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard !annotation.isKind(of: MKUserLocation.self) else { return nil }
            
            var annotationView: MKMarkerAnnotationView?
            var identifier = ""
            var color = UIColor.systemRed
            var image: UIImage?
            
            annotationView?.animatesWhenAdded = true
            
            if let annotation = annotation as? MKPlaceAnnotation {
                /*
                switch annotation.type {
                case .park, .beach, .trail:
                    identifier = "NatureAnnotation"
                    color = .systemGreen
                    image = UIImage(systemName: "leaf")
                case .attraction, .museum, .library:
                    identifier = "AttractionAnnotation"
                    color = .systemOrange
                    image = UIImage(systemName: "building")
                case .store:
                    identifier = "StoreAnnotation"
                    color = .systemYellow
                    image = UIImage(systemName: "cart")
                case .restaurant, .cafe:
                    identifier = "FoodAnnotation"
                    color = .systemBlue
                    image = UIImage(systemName: "rectangle.roundedbottom")
                }
                */
                
                switch annotation.type {
                case .park, .beach, .trail:
                    identifier = "NatureAnnotation"
                    color = .systemGreen
                    image = UIImage(systemName: "leaf")
                case .attraction:
                    identifier = "AttractionAnnotation"
                    color = .systemPurple
                    image = UIImage(systemName: "building")
                case .library:
                    identifier = "LibraryAnnotation"
                    color = .systemOrange
                    image = UIImage(systemName: "text.book.closed")
                case .store:
                    identifier = "StoreAnnotation"
                    color = .systemYellow
                    image = UIImage(systemName: "cart")
                case .restaurant, .cafe:
                    identifier = "FoodAnnotation"
                    color = .systemBlue
                    image = UIImage(named: "coffee.cup")
                case .friends, .family:
                    identifier = "PeopleAnnotation"
                    color = .systemRed
                    image = UIImage(systemName: "person")
                default:
                    identifier = "OtherAnnotation"
                    color = .systemTeal
                }
                
                if let reusedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
                    annotationView = reusedView
                } else {
                    annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                    annotationView?.canShowCallout = true
                    annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
                }
                annotationView?.markerTintColor = color
                annotationView?.glyphImage = image
                annotationView?.clusteringIdentifier = identifier
                return annotationView
            }
            
            return nil
        }
        
        // cluster Annotations
        
        // CHANGED: these last 2 functions
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let annotation = view.annotation as? MKPlaceAnnotation else { return }
            parent.selectedPlace = annotation
        }
        
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//            guard let annotation = view.annotation as? MKPointAnnotation else { return }
//            parent.selectedPlace = annotation
            parent.showingPlaceDetails = true
            
        }
    }
    
}

extension MapView {
    func placeForAnnotation(annotation: MKPlaceAnnotation) -> PlaceAnnotation? {
        return places.first(where: { $0.id == annotation.id })
    }

}
/*
struct MapView_Previews: PreviewProvider {
    
    
    static var previews: some View {
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: CLLocationDegrees(43.16), longitude: CLLocationDegrees(-89.37)), span: MKCoordinateSpan(latitudeDelta: CLLocationDegrees(0.1), longitudeDelta: CLLocationDegrees(0.1)))
        
        MapView(type: "park", selectedPlace: .constant(MKPlaceAnnotation.example), showingPlaceDetails: .constant(false), region: .constant(region), userLocationShown: .constant(true), userLocation: .constant(MKPlaceAnnotation.example.coordinate))
    }
}
*/
