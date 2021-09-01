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
    
    @State private var annotations: [PlaceAnnotation] = []
    @State private var showingPlaceDetails = false
    @State private var selectedPlace: PlaceAnnotation?
    @State private var userLocationShown = false
    
    @State private var userLocation: CLLocationCoordinate2D? = CLLocationManager().location?.coordinate
    @State private var redrawMap: Bool = false
    
    let locationManager = CLLocationManager()
    
    
    var fetchRequest: FetchRequest<PlaceAnnotation>
    
//    let placeTypeCategories = ["All", "Attractions", "Restaurants & Cafés", "Parks & Nature", "Stores", "Libraries", "Friends & Family", "Other"]
    
    init(type: PlaceType) {
        switch type {
        case .all:
            fetchRequest = FetchRequest<PlaceAnnotation>(entity: PlaceAnnotation.entity(), sortDescriptors: [])
        case .attractions:
            fetchRequest = FetchRequest<PlaceAnnotation>(entity: PlaceAnnotation.entity(), sortDescriptors: [], predicate: NSPredicate(format: "type == %@", "Attractions"))
        case .restaurantsAndCafes:
            fetchRequest = FetchRequest<PlaceAnnotation>(entity: PlaceAnnotation.entity(), sortDescriptors: [], predicate: NSPredicate(format: "type == %@", "Restaurants & Cafés"))
        case .parksAndNature:
            fetchRequest = FetchRequest<PlaceAnnotation>(entity: PlaceAnnotation.entity(), sortDescriptors: [], predicate: NSPredicate(format: "type == %@", "Parks & Nature"))
        case .stores:
            fetchRequest = FetchRequest<PlaceAnnotation>(entity: PlaceAnnotation.entity(), sortDescriptors: [], predicate: NSPredicate(format: "type == %@", "Stores"))
        case .librariesAndMuseums:
            fetchRequest = FetchRequest<PlaceAnnotation>(entity: PlaceAnnotation.entity(), sortDescriptors: [], predicate: NSPredicate(format: "type == %@", "Libraries & Museums"))
        case .friendsAndFamily:
            fetchRequest = FetchRequest<PlaceAnnotation>(entity: PlaceAnnotation.entity(), sortDescriptors: [], predicate: NSPredicate(format: "type == %@", "Friends & Family"))
        case .favorites:
            fetchRequest = FetchRequest<PlaceAnnotation>(entity: PlaceAnnotation.entity(), sortDescriptors: [], predicate: NSPredicate(format: "isFavorite == true"))
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
                    MapView(selectedPlace: $selectedPlace, showingPlaceDetails: $showingPlaceDetails, region: region, userLocationShown: $userLocationShown, annotations: $annotations, userLocation: $userLocation, redrawMap: $redrawMap)
                        .onAppear {
//                            print("map showed up again")
                            redrawMap = true
                        }

                    NavigationLink(
                        destination: DetailView(selectedPlace: $selectedPlace, redrawMap: $redrawMap),
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
                        NavigationLink(destination: DetailView(selectedPlace: .constant(place), redrawMap: $redrawMap)) {
                            HStack {
//                                imageForTypeFromString(place.type ?? "")
                                PlaceType(rawValue: place.type ?? "All")?.imageForType()
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Circle().foregroundColor(PlaceType(rawValue: place.type ?? "All")?.color() ?? .ttRed))

                                VStack(alignment: .leading) {
                                    Text("\(place.title ?? "Placeholder title")")
                                        .font(.headline)
                                        .lineLimit(1)
                                    
                                    Text("\(getDistance(place: place)) mi away")
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
                annotations += places

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
            if distance < 1 && distance >= 0 {
                return "< 1"
            }
            let numberFormatter = NumberFormatter.shared
            if let distance = numberFormatter.string(from: NSNumber(value: distance)) {
                return distance
            }
        }
        return "0"
    }
    
    func imageForTypeFromString(_ type: String) -> Image {
        switch type {
        case "All":
            return Image(systemName: "mappin")
        case "Parks & Nature":
            return Image(systemName: "leaf")
        case "Stores":
            return Image(systemName: "cart")
        case "Restaurants & Cafés":
            return Image("coffee.cup")
        case "Libraries & Museums":
            return Image(systemName: "text.book.closed")
        case "Attractions":
            return Image(systemName: "ticket")
        case "Friends & Family":
            return Image(systemName: "person")
        case "Favorites":
            return Image(systemName: "heart.fill")
        default:
            return Image(systemName: "mappin")
        }
    }
    
    func colorForType(_ string: String?) -> Color {
        let placeTypeColors: [String: Color] = ["all": MyColors.red, "favorites": MyColors.blue, "parks": MyColors.red, "cafe": MyColors.gold, "attraction": MyColors.blueGreen, "friends": MyColors.gold, "libraries": MyColors.blueGreen, "store": MyColors.blue]
        if let string = string {
            return placeTypeColors[string] ?? Color.red
        }
        return Color.red
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
        ContentView(type: .parksAndNature).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
