//
//  SimpleMapView.swift
//  CoreDataTest
//
//  Created by Daniel Pitts on 7/22/21.
//

/*
 
import SwiftUI
import MapKit

struct SimpleMapView: UIViewRepresentable {
    @Binding var selectedPlace: MKPlaceAnnotation?
    @Binding var region: MKCoordinateRegion
    @Binding var userLocationShown: Bool
    
    // will it work?
    @Binding var userLocation: CLLocationCoordinate2D?
    
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \PlaceAnnotation.title, ascending: true)],
//        animation: .default) private var places: FetchedResults<PlaceAnnotation>
    
    var annotations: [MKPlaceAnnotation]
   
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.addAnnotations(annotations)
        mapView.region = region
        mapView.showsUserLocation = true
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        // do I need to factor in userLocation as an annotation?
        // places.count + 1 ??
        
        if mapView.annotations.count != annotations.count && userLocationShown == false {
            print("!userLocationShown; reloaded annotations in updateUIView()")
            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotations(annotations)
        }  else {
            if mapView.annotations.count != annotations.count + 1 && userLocationShown == true {
                print("userLocationShown; reloaded annotations in updateUIView()")
                mapView.removeAnnotations(mapView.annotations)
                mapView.addAnnotations(annotations)
            }
         
        }
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate, CLLocationManagerDelegate {
        var parent: SimpleMapView
        var locationManager: CLLocationManager?
        
        
        init(_ parent: SimpleMapView) {
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
            
            if let annotation = annotation as? MKPlaceAnnotation {
                
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
        
    }
    
}
/*
struct SimpleMapView_Previews: PreviewProvider {
    static var previews: some View {
        SimpleMapView()
    }
}
 */
 
 */
