//
//  ContentView.swift
//  CoreDataTest
//
//  Created by Daniel Pitts on 7/14/21.
//

// TASKS
// 1. Break out functions

import SwiftUI
import CoreData
import MapKit
import LinkPresentation

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    // only need Environment property for saving, deleting, etc.; NOT for FetchRequest
    @Environment(\.presentationMode) private var presentationMode
//    @State private var startRegion: MKCoordinateRegion = MKCoordinateRegion(center: CLLocationManager().location?.coordinate ?? MKPlaceAnnotation.example.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    
    @ObservedObject var mapRegion = MapRegion()
    @StateObject var distances = PlaceDistances()
    
    @State private var annotations: [PlaceAnnotation] = []
    @State private var showingPlaceDetails = false
    @State private var selectedPlace: PlaceAnnotation?
    @State private var userLocationShown = false
    
    @State private var userLocation: CLLocationCoordinate2D? = CLLocationManager.shared.location?.coordinate
    @State private var redrawMap = false
    @State private var repositionMap = false
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var alertShowing = false
    @State private var indexSet: IndexSet?
    
    @State private var actionSheetShowing = false
    @State private var showingDetailView = true
    @State private var showingAddView = false
    
    let locationManager = CLLocationManager.shared
    
    
    var fetchRequest: FetchRequest<PlaceAnnotation>
    
    init(type: PlaceType) {
        switch type {
        case .all:
            fetchRequest = FetchRequest<PlaceAnnotation>(entity: PlaceAnnotation.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \PlaceAnnotation.title, ascending: true)])
        case .attractions:
            fetchRequest = FetchRequest<PlaceAnnotation>(entity: PlaceAnnotation.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \PlaceAnnotation.title, ascending: true)], predicate: NSPredicate(format: "type == %@", "Attractions"))
        case .restaurantsAndCafes:
            fetchRequest = FetchRequest<PlaceAnnotation>(entity: PlaceAnnotation.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \PlaceAnnotation.title, ascending: true)], predicate: NSPredicate(format: "type == %@", "Restaurants & Cafés"))
        case .parksAndNature:
            fetchRequest = FetchRequest<PlaceAnnotation>(entity: PlaceAnnotation.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \PlaceAnnotation.title, ascending: true)], predicate: NSPredicate(format: "type == %@", "Parks & Nature"))
        case .stores:
            fetchRequest = FetchRequest<PlaceAnnotation>(entity: PlaceAnnotation.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \PlaceAnnotation.title, ascending: true)], predicate: NSPredicate(format: "type == %@", "Stores"))
        case .librariesAndMuseums:
            fetchRequest = FetchRequest<PlaceAnnotation>(entity: PlaceAnnotation.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \PlaceAnnotation.title, ascending: true)], predicate: NSPredicate(format: "type == %@", "Libraries & Museums"))
        case .friendsAndFamily:
            fetchRequest = FetchRequest<PlaceAnnotation>(entity: PlaceAnnotation.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \PlaceAnnotation.title, ascending: true)], predicate: NSPredicate(format: "type == %@", "Friends & Family"))
        case .favorites:
            fetchRequest = FetchRequest<PlaceAnnotation>(entity: PlaceAnnotation.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \PlaceAnnotation.title, ascending: true)], predicate: NSPredicate(format: "isFavorite == true"))
        }
        
//        if type == "all" {
//            fetchRequest = FetchRequest<PlaceAnnotation>(entity: PlaceAnnotation.entity(), sortDescriptors: [])
//        } else {
//            fetchRequest = FetchRequest<PlaceAnnotation>(entity: PlaceAnnotation.entity(), sortDescriptors: [], predicate: NSPredicate(format: "type == %@", type))
//        }
    }
    
    var places: FetchedResults<PlaceAnnotation> { fetchRequest.wrappedValue }
    
    @State private var metadata: LPLinkMetadata?
    
    var body: some View {
        
        Group {
                    
            if metadata != nil {
                ActivityViewController(metadata: metadata) {
                    self.metadata = nil
                }
                .frame(width: 0, height: 0)
            } else {
                EmptyView()
            }
            
            TabView {
                                
                ZStack {
                    MapView(selectedPlace: $selectedPlace, showingPlaceDetails: $showingPlaceDetails, region: $mapRegion.region, userLocationShown: $userLocationShown, annotations: $annotations, userLocation: $userLocation, redrawMap: $redrawMap, repositionMap: $repositionMap)
                        .onAppear {
//                            print("map showed up again")
                            redrawMap = true
                        }

                    NavigationLink(
                        destination: DetailView(selectedPlace: $selectedPlace, redrawMap: $redrawMap, showingDetailView: $showingDetailView),
                        isActive: $showingPlaceDetails) { EmptyView() }
                    
                    NavigationLink(
                        destination: AddPlaceView(),
                        isActive: $showingAddView) { EmptyView() }
                    
                    
                    HStack {
                        Spacer()

                        VStack {
                            Spacer()
                            Button(action: {
                                showingAddView = true
                            }) {
                                Image(systemName: "plus")
                            }
                            .padding()
                            .font(.headline)
                            .foregroundColor(.white)
                            .background(
                                Circle()
                                    .foregroundColor(.blue)
                                    .shadow(color: .black.opacity(0.5), radius: 6, x: 2, y: 2)
                            )
                        }
                    }
                    .padding([.bottom, .trailing])
                        
                }
                .tabItem {
                    Image(systemName: "map")
                    Text("Map")
                }


                // .sorted(by: { distanceFrom(place: $0) < distanceFrom(place: $1) } )
                List {
                    ForEach(places) { place in
                        // change DetailView below to place, not annotation
                        NavigationLink(destination: DetailView(selectedPlace: .constant(place), redrawMap: $redrawMap, showingDetailView: $showingDetailView)) {
                            HStack {
//                                imageForTypeFromString(place.type ?? "")
                                PlaceType(rawValue: place.type ?? "All")?.imageForType()
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Circle().foregroundColor(PlaceType(rawValue: place.type ?? "All")?.color() ?? .ttRed))

                                VStack(alignment: .leading) {
                                    Text("\(place.title ?? "Placeholder title")")
                                        .font(.headline)
//                                        .lineLimit(0)
                                    
                                    if distances.distances[place] != nil {
                                        Text("\(distances.distances[place] ?? 0) mi away")
                                            .font(.subheadline)
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
                    .onDelete { indexSet in
                        deletePlaces(offsets: indexSet)
                    }
                } // end List
                
                // not sure if $annotations works here instead of places
//                ListView(places: $annotations, redrawMap: $redrawMap)
                .tabItem {
                    Text("List")
                    Image(systemName: "list.bullet")
                }

            } // end TabView
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text(Image(systemName: "chevron.backward"))
                        .fontWeight(.semibold)
                        .padding([.top, .trailing, .bottom])
                        .foregroundColor(Color.ttBlue)
                }
            )
            
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Places")
                        .fontWeight(.semibold)
                        .foregroundColor(Color.ttBlue)
                        .font(.custom("Avenir Next", size: 18))
                }
                
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        if CLLocationManager.shared.location == nil {
                            self.alertTitle = "Location Disabled"
                            self.alertMessage = "You can enable Location Services for this app under Settings >> Privacy."
                            alertShowing = true
                        }
                        if let coordinate = CLLocationManager.shared.location?.coordinate {
                            withAnimation {
                                self.mapRegion.region.center = coordinate
                                repositionMap = true
                            }
                        }
                    }) {
                        Image(systemName: CLLocationManager.shared.location != nil ? "location.fill" : "location.slash.fill")
                            .foregroundColor(CLLocationManager.shared.location != nil ? Color.ttBlue : .gray)
                    }
                    
                    Button(action: {
                        // share mapItems
                        actionSheetShowing = true
                    }) {
                        Image(systemName: "square.and.arrow.up")
                    }
                    
                }
            }
 
            .actionSheet(isPresented: $actionSheetShowing) {
                ActionSheet(title: Text("Share ToddlerTown Places"), message: nil,
                            buttons: [
                                .default(Text("Share \(places.count) Places")) {
                                    guard !places.isEmpty else { return }
                                    let exporter = ExportPlaces.shared
                                    exporter.savePlacesToDisk(places: annotations)
                                    
                                    MapLinkView.getMetadata(exporter.getPlacesURL().absoluteString) { result in
                                        if self.metadata != nil {
                                            self.metadata = nil
                                        }
                                        self.handleMetadataResult(result)
                //                        shareSheetShowing = true
                                    }
                                },
                                .cancel()
                            ]
                )
            }
            
            .onAppear {
                annotations += places
                getDistances()

                withAnimation {
                    setRegionForVisiblePlaces()
                }
            } // end onAppear
            
            .alert(isPresented: $alertShowing) {
                Alert(title: Text(alertTitle),
                      message: Text(alertMessage),
                      dismissButton: .default(Text("OK")))
            }
        } // end TabView
        
    } // end body
    
    // MARK: Metadata
    
    private func handleMetadataResult(_ result: Result<LPLinkMetadata, Error>) {
        DispatchQueue.main.async {
            switch result {
            case .success(let metadata): self.metadata = metadata
            case .failure(let error): print(error.localizedDescription)
            }
        }
    }
    
    // MARK: getLocation()
    // Works????
    
    func getLocation() -> CLLocation? {
        // testing performance difference with instance vs shared singleton
        return CLLocationManager.shared.location
    }
    
    func getSelectedPlaceLocation(for place: PlaceAnnotation) -> CLLocation? {
        return CLLocation(latitude: place.latitude, longitude: place.longitude)
    }
    
    func getDistance(place: PlaceAnnotation) -> String {
//        let distance = distances[place] ?? 0
//
//        if distance < 1 && distance >= 0 {
//            return "< 1"
//        }
//
//        return String(distance)
        
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
    
    func distanceFrom(place: PlaceAnnotation) -> Int {
        return distances.distances[place] ?? 0

    }
    
    func getDistances() {
        var distances = self.distances.distances
        DispatchQueue.global().async {
            if let location = locationManager.location {
                for place in places {
                    if distances[place] == nil {
                        if let placeLocation = getSelectedPlaceLocation(for: place) {
                            distances[place] = Int(location.distance(from: placeLocation) / 1600)
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    self.distances.distances = distances
                }
            }
        }
    }
    
    func setRegionForVisiblePlaces() {
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
            self.mapRegion.region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        } else {
            let avgLatitude = (places.map( { $0.latitude } ).reduce(0.0, +)) / Double(places.count)
            let avgLongitude = (places.map( { $0.longitude } ).reduce(0.0, +)) / Double(places.count)
            let center = CLLocationCoordinate2D(latitude: avgLatitude, longitude: avgLongitude)
            self.mapRegion.region = MKCoordinateRegion(center: center, span: span)
        }
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
        let placeTypeColors: [String: Color] = ["all": Color.ttRed, "favorites": Color.ttBlue, "parks": Color.ttRed, "cafe": Color.ttGold, "attraction": Color.ttBlueGreen, "friends": Color.ttGold, "libraries": Color.ttBlueGreen, "store": Color.ttBlue]
        if let string = string {
            return placeTypeColors[string] ?? Color.red
        }
        return Color.red
    }
    
    private func deletePlaces(offsets: IndexSet) {
        
        withAnimation {
            offsets.map { places[$0] }.forEach(viewContext.delete)
//            annotations.remove(atOffsets: offsets) // might work, prob not
//            offsets.map { places.sorted(by: { distanceFrom(place: $0) < distanceFrom(place: $1) } )[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                // *** THIS CRASHES after importing a .ttplaces file if nothing is edited first.
                // *** May need special handling in viewContext.save() method
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                print("Places not saved. Error: \(nsError)")
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
