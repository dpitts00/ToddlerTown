//
//  ContentView.swift
//  CoreDataTest
//
//  Created by Daniel Pitts on 7/14/21.
//

import SwiftUI
import CoreData
import MapKit

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    // only need Environment property for saving, deleting, etc.; NOT for FetchRequest
    @Environment(\.presentationMode) private var presentationMode
    @State private var startRegion: MKCoordinateRegion = MKCoordinateRegion(center: CLLocationManager().location?.coordinate ?? MKPlaceAnnotation.example.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    
    @State private var annotations: [MKPlaceAnnotation] = []
    @State private var showingPlaceDetails = false
    @State private var selectedPlace: MKPlaceAnnotation?
    @State private var userLocationShown = false
    
    @State private var userLocation: CLLocationCoordinate2D? = CLLocationManager().location?.coordinate
    
    let locationManager = CLLocationManager()
    
    
    var fetchRequest: FetchRequest<PlaceAnnotation>
    
//    let placeTypeCategories = ["All", "Attractions", "Restaurants & Cafés", "Parks & Nature", "Stores", "Libraries", "Friends & Family", "Other"]
    
    init(type: String) {
        switch type {
//        case "All":
//            fetchRequest = FetchRequest<PlaceAnnotation>(entity: PlaceAnnotation.entity(), sortDescriptors: [])
        case "Attractions":
            fetchRequest = FetchRequest<PlaceAnnotation>(entity: PlaceAnnotation.entity(), sortDescriptors: [], predicate: NSPredicate(format: "type == %@", "attraction"))
        case "Restaurants & Cafés":
            fetchRequest = FetchRequest<PlaceAnnotation>(entity: PlaceAnnotation.entity(), sortDescriptors: [], predicate: NSPredicate(format: "type == %@", "restaurant", "cafe"))
        case "Parks & Nature":
            fetchRequest = FetchRequest<PlaceAnnotation>(entity: PlaceAnnotation.entity(), sortDescriptors: [], predicate: NSPredicate(format: "type == %@", "park", "trail", "beach"))
        case "Stores":
            fetchRequest = FetchRequest<PlaceAnnotation>(entity: PlaceAnnotation.entity(), sortDescriptors: [], predicate: NSPredicate(format: "type == %@", "store"))
        case "Libraries":
            fetchRequest = FetchRequest<PlaceAnnotation>(entity: PlaceAnnotation.entity(), sortDescriptors: [], predicate: NSPredicate(format: "type == %@", "library"))
        case "Friends & Family":
            fetchRequest = FetchRequest<PlaceAnnotation>(entity: PlaceAnnotation.entity(), sortDescriptors: [], predicate: NSPredicate(format: "type == %@", "friends", "family"))
        case "Favorites":
            fetchRequest = FetchRequest<PlaceAnnotation>(entity: PlaceAnnotation.entity(), sortDescriptors: [], predicate: NSPredicate(format: "isFavorite == true"))
        default:
            fetchRequest = FetchRequest<PlaceAnnotation>(entity: PlaceAnnotation.entity(), sortDescriptors: [])
        }
        
//        if type == "all" {
//            fetchRequest = FetchRequest<PlaceAnnotation>(entity: PlaceAnnotation.entity(), sortDescriptors: [])
//        } else {
//            fetchRequest = FetchRequest<PlaceAnnotation>(entity: PlaceAnnotation.entity(), sortDescriptors: [], predicate: NSPredicate(format: "type == %@", type))
//        }
    }
    
    var places: FetchedResults<PlaceAnnotation> { fetchRequest.wrappedValue }
        
    var body: some View {
        
        let region = Binding<MKCoordinateRegion>(
            get: {
                self.startRegion
            },
            set: {
                self.startRegion = $0
            }
        )
        
//        NavigationView {
            TabView {
                                
                ZStack {
                    MapView(selectedPlace: $selectedPlace, showingPlaceDetails: $showingPlaceDetails, region: region, userLocationShown: $userLocationShown, userLocation: $userLocation, places: places)

                    NavigationLink(
                        destination: DetailView(selectedPlace: $selectedPlace),
                        isActive: $showingPlaceDetails) { EmptyView() }
                    
//                    HStack {
//                        VStack {
//                            Spacer()
//                            UserLocationIndicatorView(showingUserLocation: $userLocationShown)
//                        }
//                        Spacer()
//                    }
//                    .padding([.bottom, .leading])
                        
                }
                .tabItem {
                    Image(systemName: "map")
                    Text("Map")
                }


                
                List {
                    ForEach(places) { place in
                        // change DetailView below to place, not annotation
                        NavigationLink(destination: DetailView(selectedPlace: .constant(place.returnAnnotation()))) {
                            HStack {
                                VStack(alignment: .leading) {
                                    
//                                    if place.nickname != nil {
//                                        Text("\(place.nickname ?? "")")
//                                    }
                                    
                                    Text("\(place.title ?? "")")
                                        .font(.headline)
                                        .lineLimit(1)
                                    
                                    Text(place.address?.split(separator: ",")[0] ?? "")
                                        .lineLimit(1)
                                        .font(.subheadline)
                                    Text(place.address?.split(separator: ",").dropFirst().joined(separator: ",").dropFirst() ?? "")
                                        .lineLimit(1)
                                        .font(.subheadline)
                                    
                                    Text("\(place.type?.capitalized ?? ""), ") + Text("\(getDistance(place: place)) mi")
                                        .font(.subheadline)
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
                .tabItem {
                    Text("List")
                    Image(systemName: "list.bullet")
                }
                .onAppear {
//                    print(annotations.count)
//                    annotations = places.map { $0.returnAnnotation() }

                } // end .onAppear


            } // end TabView
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text(Image(systemName: "chevron.backward"))
                        .fontWeight(.semibold)
                        .padding([.top, .trailing, .bottom])
                        .foregroundColor(MyColors.blue)
                }),
                trailing: Image(systemName: CLLocationManager().location != nil ? "location.fill" : "location.slash.fill")
                .foregroundColor(CLLocationManager().location != nil ? MyColors.blue : .gray)
            )
//            .navigationBarTitle("ToddlerTown", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Map + List")
                        .fontWeight(.semibold)
                        .foregroundColor(MyColors.blue)
                        .font(.custom("Avenir Next", size: 18))
                }
            }

            // does this work now?? NO.
            .onAppear {
                
                // trying it here
                annotations = places.map { $0.returnAnnotation() }

                withAnimation {
                    guard !places.isEmpty else { return }
                    let maxLatitude = places.map( { $0.latitude } ).max() ?? 0.1
                    let minLatitude = places.map( { $0.latitude } ).min() ?? 0
                    let maxLongitude = places.map( { $0.longitude } ).max() ?? 0.1
                    let minLongitude = places.map( { $0.longitude } ).min() ?? 0
                    let latitudeDelta = maxLatitude - minLatitude
                    let longitudeDelta = maxLongitude - minLongitude
                    
                    let span = MKCoordinateSpan(latitudeDelta: latitudeDelta * 3, longitudeDelta: longitudeDelta * 3)
                    
                    if places.count == 1 {
                        let center = CLLocationCoordinate2D(latitude: places[0].latitude, longitude: places[0].longitude)
                        self.startRegion = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
                    } else {
                        let avgLatitude = (places.map( { $0.latitude } ).reduce(0.0, +)) / Double(places.count)
                        let avgLongitude = (places.map( { $0.longitude } ).reduce(0.0, +)) / Double(places.count)
                        let center = CLLocationCoordinate2D(latitude: avgLatitude, longitude: avgLongitude)
                        self.startRegion = MKCoordinateRegion(center: center, span: span)
                    }
                }
            }
            // on TabView now, which is supposed to be OUTSIDE the navigationView
//        } // end NavigationView
        
    } // end body
    
    // MARK: getLocation()
    // Works????
    func getLocation() -> CLLocation? {
        return locationManager.location
    }
    
    func getSelectedPlaceLocation(for place: PlaceAnnotation) -> CLLocation? {
        // unsafe force unwrap?
        return CLLocation(latitude: place.latitude, longitude: place.longitude)
    }
    
    func getDistance(place: PlaceAnnotation) -> String {
        if getLocation() != nil && getSelectedPlaceLocation(for: place) != nil {
            let distance = (getLocation()!.distance(from: getSelectedPlaceLocation(for: place)!) / 1600)
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            numberFormatter.maximumFractionDigits = 2
            return numberFormatter.string(from: NSNumber(value: distance)) ?? "0.00"
        }
        return "0.0"
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
        ContentView(type: "park").environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
