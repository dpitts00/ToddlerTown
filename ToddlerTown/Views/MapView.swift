//
//  MapView.swift
//  CoreDataTest
//
//  Created by Daniel Pitts on 7/14/21.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @Binding var selectedPlace: PlaceAnnotation?
    @Binding var showingPlaceDetails: Bool
    @Binding var region: MKCoordinateRegion
    @Binding var userLocationShown: Bool
    @Binding var annotations: [PlaceAnnotation]
    
    // will it work?
    @Binding var userLocation: CLLocationCoordinate2D?
    @Binding var redrawMap: Bool
    @Binding var repositionMap: Bool
    
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \PlaceAnnotation.title, ascending: true)],
//        animation: .default) private var places: FetchedResults<PlaceAnnotation>
    
//    var places: FetchedResults<PlaceAnnotation>
   
    
//    let placeTypeCategories = ["All", "Attractions", "Restaurants & Cafés", "Parks & Nature", "Stores", "Libraries", "Friends & Family", "Other"]
    
    func makeUIView(context: Context) -> MKMapView {
        print("makeUIView")
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.addAnnotations(annotations)
        mapView.region = region
        mapView.showsUserLocation = true
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        if redrawMap {
            mapView.removeAnnotations(annotations)
            mapView.addAnnotations(annotations)
            redrawMap = false // possibly unnecessary
//            print("redrew the map?")
        }
        
        if repositionMap {
            mapView.region = region
            repositionMap = false
        }
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
            
            if let annotation = annotation as? PlaceAnnotation {
                switch annotation.type {
                case "Parks & Nature":
                    identifier = "NatureAnnotation"
                    color = UIColor.ttBlueGreen
                    image = UIImage(systemName: "leaf")
                case "Attractions":
                    identifier = "AttractionAnnotation"
                    color = UIColor.ttRed
                    image = UIImage(systemName: "ticket")
                case "Libraries & Museums":
                    identifier = "LibraryAnnotation"
                    color = UIColor.ttBlue
                    image = UIImage(systemName: "text.book.closed")
                case "Stores":
                    identifier = "StoreAnnotation"
                    color = UIColor.ttGold
                    image = UIImage(systemName: "cart")
                case "Restaurants & Cafés":
                    identifier = "FoodAnnotation"
                    color = UIColor.ttGold
                    image = UIImage(named: "coffee.cup")
                case "Friends & Family":
                    identifier = "PeopleAnnotation"
                    color = UIColor.ttBlueGreen
                    image = UIImage(systemName: "person")
                default:
                    identifier = "DefaultAnnotation"
                    color = UIColor.ttRed
                    image = UIImage(systemName: "mappin")
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
            guard let annotation = view.annotation as? PlaceAnnotation else { return }
            parent.selectedPlace = annotation
        }
        
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//            guard let annotation = view.annotation as? MKPointAnnotation else { return }
//            parent.selectedPlace = annotation
            parent.showingPlaceDetails = true
//            parent.redrawMap = false
            
        }
    }
    
}

/*
extension MapView {
    func placeForAnnotation(annotation: MKPlaceAnnotation) -> PlaceAnnotation? {
        return places.first(where: { $0.id == annotation.id })
    }

}
*/
 
/*
struct MapView_Previews: PreviewProvider {
    
    
    static var previews: some View {
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: CLLocationDegrees(43.16), longitude: CLLocationDegrees(-89.37)), span: MKCoordinateSpan(latitudeDelta: CLLocationDegrees(0.1), longitudeDelta: CLLocationDegrees(0.1)))
        
        MapView(type: "park", selectedPlace: .constant(MKPlaceAnnotation.example), showingPlaceDetails: .constant(false), region: .constant(region), userLocationShown: .constant(true), userLocation: .constant(MKPlaceAnnotation.example.coordinate))
    }
}
*/
