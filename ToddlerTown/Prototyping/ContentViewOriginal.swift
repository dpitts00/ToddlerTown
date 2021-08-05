//
//  ContentView.swift
//  CoreDataTest
//
//  Created by Daniel Pitts on 7/14/21.
//
/*

import SwiftUI
import CoreData
import MapKit

extension MKPointAnnotation: Identifiable {
    static var example: MKPointAnnotation {
        let example = MKPointAnnotation()
        example.title = "Title"
        example.subtitle = "Subtitle"
        example.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(43.16), longitude: CLLocationDegrees(-89.37))
        return example
    }
}

extension PlaceAnnotation {
    func annotation() -> MKPointAnnotation {
        let annotation = MKPointAnnotation()
        annotation.title = self.title
        annotation.subtitle = self.subtitle
        annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(self.latitude), longitude: CLLocationDegrees(self.longitude))
        return annotation
    }
}


struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    // only need Environment property for saving, deleting, etc.; NOT for FetchRequest
    
    @State private var region = MKCoordinateRegion(center: CLLocationManager().location?.coordinate ?? MKPointAnnotation.example.coordinate, span: MKCoordinateSpan(latitudeDelta: CLLocationDegrees(0.1), longitudeDelta: CLLocationDegrees(0.1)))
    
    @State private var annotations: [MKPointAnnotation] = []
    @State private var showingPlaceDetails = false
//    @State private var selectedPlace: MKPointAnnotation?
    @State private var selectedPlace: MKPointAnnotation?
    @State private var userLocationShown = false
    
    @State private var userLocation: CLLocationCoordinate2D?
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \PlaceAnnotation.title, ascending: true)],
        animation: .default) private var places: FetchedResults<PlaceAnnotation>

    var body: some View {
        
        NavigationView {
            VStack {
                
                /*
                Map(coordinateRegion: $region, annotationItems: annotations) {
                    annotation in
                    MapMarker(coordinate: annotation.coordinate, tint: .blue)
                }
                 */
                
                MapView(selectedPlace: $selectedPlace, showingPlaceDetails: $showingPlaceDetails, region: $region, userLocationShown: $userLocationShown, userLocation: $userLocation)
                
                List {
                    ForEach(places) { place in
                        NavigationLink(destination: DetailView(selectedPlace: place.annotation())) {
                            HStack {
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text("\(place.title!)")
                                            .font(.headline)
                                        Text("(\(place.subtitle!))")
                                            .font(.subheadline)
                                    }
                                    
                                    HStack {
                                        Text("Coordinate: (\(place.latitude), \(place.longitude))")
                                    }
                                }
                                
                                Spacer()
                                Image(systemName: place.isFavorite ? "heart.fill" : "heart")
                                    .foregroundColor(place.isFavorite ? .red : .gray)
                                    .font(.title2)
                                    .onTapGesture {
                                        place.isFavorite.toggle()
                                        do {
                                            try viewContext.save()
                                        } catch {
                                            print(error.localizedDescription)
                                        }
                                    }
                            }
                            .padding([.bottom, .top])
                        }
                    }
                    .onDelete(perform: deletePlaces)
                } // end List
                .navigationBarItems(
                    leading: EditButton(),
                    trailing: NavigationLink(destination: EditView()) {
                        Image(systemName: "plus")
                        Text("Add")
                    })
                .onAppear {
                    if places.isEmpty {
                        for i in 0..<10 {
                            let place = PlaceAnnotation(context: viewContext)
                            place.id = UUID()
                            place.title = "Place \(i)"
                            place.subtitle = "Place Type"
                            place.latitude = 43.16 + Double.random(in: -0.1...0.1)
                            place.longitude = -89.37 + Double.random(in: -0.1...0.1)
                            place.isFavorite = false
                            do {
                                try viewContext.save()
                            } catch {
                                fatalError("Error: \(error.localizedDescription)")
                            }
                        }
                    }
                    
                    annotations = places.map { $0.annotation() }
                    
                    selectedPlace = annotations[0]
                } // end .onAppear
            } // end VStack
            .sheet(isPresented: $showingPlaceDetails) {
                
                Text(selectedPlace?.title ?? "No title given.")
                Text(selectedPlace?.subtitle ?? "No subtitle given.")
                
                if selectedPlace != nil {
                    Text("Coordinate: (\(selectedPlace!.coordinate.latitude), \(selectedPlace!.coordinate.longitude))")
                }
                
            }
            .navigationTitle("ToddlerTown")
        } // end NavigationView
        
    } // end body
    

    private func addPlace() {
        withAnimation {
            let newPlace = PlaceAnnotation(context: viewContext)
            newPlace.title = "New Place"

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deletePlaces(offsets: IndexSet) {
        withAnimation {
            offsets.map { places[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    func save() {
        do {
            try viewContext.save()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
*/
