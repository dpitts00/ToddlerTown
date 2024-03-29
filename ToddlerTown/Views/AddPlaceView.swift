//
//  AddView.swift
//  ToddlerTown
//
//  Created by Daniel Pitts on 9/2/21.
//

import SwiftUI
import MapKit

// TASKS
// 1. Possible change in annotation format?
// 2. Break out subviews
// 3. Break out methods (Looooong)

struct AddPlaceView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode
    @GestureState private var dragOffset = CGSize.zero
    
    @StateObject var mapRegion = MapRegion()
    
    @StateObject var mapItems = MapItems()
    @State private var mapSearchType = ""
    @State private var mapSearch = ""
    @State private var selectedType = PlaceType.favorites
    
    @State private var pickerPlaceTypes: [PlaceType] = []
    
    @State private var searchShowing = true
    @State private var placesSectionShowing = false
    @State private var searchError = false
    
    @State private var isEditViewShowing = false
    @State private var alertShowing = false
    
    @FetchRequest(
        sortDescriptors: [],
        animation: .default) private var places: FetchedResults<PlaceAnnotation>
    
    var body: some View {
        
        NavigationLink(
            destination: EditView(selectedPlace: .constant(nil), mapItem: mapItems.selectedItem, exitMapSearch: .constant(false), showingDetailView: .constant(false)),
            isActive: $isEditViewShowing) { EmptyView() }
        
        
        ScrollViewReader { reader in

            VStack {
                
//                ZStack {
                Map(coordinateRegion: $mapRegion.region, annotationItems: mapItems.mapItems) { annotation in
                        MapAnnotation(coordinate: annotation.placemark.coordinate) {
        //                    VStack {
                                ZStack {
        //                        MapMarker(coordinate: annotation.placemark.coordinate, tint: .red)
                                    Circle()
                                        .fill(annotation == mapItems.selectedItem ? Color.blue : Color.red)
                                    Circle()
                                        .strokeBorder(Color.white, lineWidth: 2)
                                    Image(systemName: "mappin")
                                        .font(.headline)
                                        .padding(8)
                                        .foregroundColor(.white)
                                }
//                                .zIndex(annotation == mapItems.selectedItem ? 100 : 0)
                                
                                .onTapGesture {
                                    mapItems.selectedItem = annotation
                                    withAnimation {
                                        reader.scrollTo(annotation.id, anchor: .top)
                                    }
                                }
                                
        //                        if annotation == mapItems.selectedItem {
        //                            Text(annotation.name ?? "")
        //                                .foregroundColor(.black)
        //                        }

        //                    }
                        }
                    }
                    .frame(height: 300)
                    .cornerRadius(12.0)
                    .padding(.horizontal, 8)
                    .padding(.top, 8)
//                } // end ZStack (testing only)
                
                
                
                List {
                    Section(header: HStack {
                        Image(systemName: "magnifyingglass")
                        Text("Search by keyword or category")
                        Spacer()
                        Image(systemName: searchShowing ? "chevron.down" : "chevron.forward")
                    }
                    .onTapGesture {
                        withAnimation {
                            searchShowing.toggle()
                        }
                    }
                    .foregroundColor(.ttBlue)
                    ) {
                        if searchShowing {
                            TextField("Search by keyword...", text: $mapSearch, onCommit: searchForMapItems)
                            
                            Picker("Select category", selection: $selectedType) {
                                ForEach(pickerPlaceTypes, id: \.self) { type in
                                    Text(type.rawValue.localizedCapitalized)
                                }
                            }
                            .pickerStyle(DefaultPickerStyle())
                            .onChange(of: selectedType) { type in
                                mapSearchType = "byType"
                                searchForMapItems()
                            }
                        }
                    }
                    
                    Section(header: HStack {
                        Image(systemName: "map")
                        Text("Places found")
                        Spacer()
                        Image(systemName: placesSectionShowing ? "chevron.down" : "chevron.forward")

                    }
                    .onTapGesture {
                        withAnimation {
                            placesSectionShowing.toggle()
                        }
                    }
                    .foregroundColor(.ttBlue)
                    ) {
                        if placesSectionShowing {
                            if !searchError {
                                    ForEach(mapItems.mapItems) { mapItem in
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(mapItem.name?.localizedCapitalized ?? "Unknown place")
                                                    .font(.headline)
                                                    .foregroundColor(mapItem == mapItems.selectedItem ? .blue : .primary)
                                                Text(mapItem.pointOfInterestCategory?.rawValue.dropFirst(13) ?? "Unknown place type")
                                                    .font(.subheadline)
                                                Text(mapItem.url?.absoluteString ?? "Unknown URL")
                                                    .font(.caption)
                                            }
                                            .onTapGesture {
                                                mapItems.selectedItem = mapItem
                                            }

                                            Spacer()
                                            Button(action: {
                                                mapItems.selectedItem = mapItem
                                                if !places.contains(where: { $0.title == mapItem.name && $0.coordinate == mapItem.placemark.coordinate } ) {
                                                    isEditViewShowing = true
                                                } else {
                                                    alertShowing = true
                                                }
                                            }) {
                                                Image(systemName: "plus")
                                                    .foregroundColor(mapItem == mapItems.selectedItem ? .blue : .ttRed)
                                                    .font(.headline)
                                            }
                                        }
                                        .id(mapItem.id)
                                    }
                            } else {
                                Text("No places found. Please search again.")
                                    .italic()
                            }
                        }
                    } // end Section
                } // end List?
                .listStyle(InsetGroupedListStyle())
                .onAppear {
                    pickerPlaceTypes = PlaceType.allCases
                    pickerPlaceTypes.removeAll(where: { $0 == .friendsAndFamily || $0 == .favorites } )
                }
                
            } // end VStack
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }, label: {
                Text(Image(systemName: "chevron.backward"))
                    .fontWeight(.semibold)
                    .padding([.top, .trailing, .bottom])
                    .foregroundColor(Color.ttBlue)
            }))
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Add Places")
                        .fontWeight(.semibold)
                        .foregroundColor(Color.ttBlue)
                        .font(.custom("Avenir Next", size: 18))
                }
            }
            .gesture(DragGesture().updating($dragOffset, body: {
                (value, state, transaction) in
                if (value.startLocation.x < 20 && value.translation.width > 100) {
                    self.presentationMode.wrappedValue.dismiss()
                }
            }))
            .alert(isPresented: $alertShowing) {
                Alert(title: Text("Place already added"),
                      message: Text("Do you want to overwrite the info for \(mapItems.selectedItem.name ?? "")?"),
                      primaryButton: .cancel(),
                      secondaryButton: .destructive(Text("Overwrite")) {
                        isEditViewShowing = true
                      })
            }
            .onAppear {
                mapItems.selectedItem = MKMapItem()
                placesSectionShowing = mapItems.mapItems.isEmpty ? false : true
                searchShowing = true
                
//                selectedType = .all
//                mapSearchType = "byType"
//                searchForMapItems()
            }
        } // end ScrollViewReader
        
    }
    
    func toPlaceAnnotation(mapItem: MKMapItem) -> PlaceAnnotation {
        let name = mapItem.name
        let postalAddress = mapItem.placemark.postalAddress
        let location = mapItem.placemark.location
        let phoneNumber = mapItem.phoneNumber
        let url = mapItem.url
        
        let fullAddress = FullAddress(context: viewContext)
        fullAddress.id = UUID()
        fullAddress.street = postalAddress?.street
        fullAddress.city = postalAddress?.city
        fullAddress.state = postalAddress?.state
        fullAddress.postalCode = postalAddress?.postalCode
        fullAddress.country = postalAddress?.country
        fullAddress.isoCountryCode = postalAddress?.isoCountryCode
        fullAddress.subAdministrativeArea = postalAddress?.subAdministrativeArea
        fullAddress.subLocality = postalAddress?.subLocality
        
        let placeAnnotation = PlaceAnnotation(context: viewContext)
        placeAnnotation.id = UUID()
        placeAnnotation.title = name
        placeAnnotation.fullAddress = fullAddress
        placeAnnotation.latitude = location?.coordinate.latitude ?? 43
        placeAnnotation.longitude = location?.coordinate.longitude ?? -89.5
        placeAnnotation.phoneNumber = phoneNumber ?? ""
        placeAnnotation.url = url?.absoluteString ?? ""
        placeAnnotation.isFavorite = false
        
       if let category = mapItem.pointOfInterestCategory {
            switch category {
            case .beach, .nationalPark, .park:
                placeAnnotation.type = PlaceType.parksAndNature.rawValue
            case .store:
                placeAnnotation.type = PlaceType.stores.rawValue
            case .bakery, .cafe, .restaurant:
                placeAnnotation.type = PlaceType.restaurantsAndCafes.rawValue
            case .library, .museum:
                placeAnnotation.type = PlaceType.librariesAndMuseums.rawValue
            case .amusementPark, .aquarium, .zoo:
                placeAnnotation.type = PlaceType.attractions.rawValue
            default:
                placeAnnotation.type = PlaceType.all.rawValue
            }
        }
        
        return placeAnnotation
    }
    
    func searchForMapItems() {
        if mapSearch.isEmpty && mapSearchType != "byType" { return }
        
        searchError = false
        mapItems.mapItems.removeAll()
        searchShowing = false
        placesSectionShowing = true
        
        switch mapSearchType {
        
//        case "byType":
//            let searchRequest = MKLocalPointsOfInterestRequest(coordinateRegion: mapRegion.region)
//            searchRequest.pointOfInterestFilter = MKPointOfInterestFilter(including: selectedType.casesByCategory())
//            print(searchRequest.region)
//
//            let search = MKLocalSearch(request: searchRequest)
//            mapSearchType = ""
//            startMapSearch(search: search)
        
        case "byType":
            let searchRequest = MKLocalSearch.Request()
            searchRequest.region = MKCoordinateRegion(center: mapRegion.region.center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
//            searchRequest.pointOfInterestFilter = MKPointOfInterestFilter(including: selectedType.casesByCategory())
            
            for category in selectedType.casesByCategoryString() {
                searchRequest.naturalLanguageQuery = category
                print(category)
                let search = MKLocalSearch(request: searchRequest)
                mapSearchType = ""
                startMapSearch(search: search)
            }
            
//            let search = MKLocalSearch(request: searchRequest)
//            mapSearchType = ""
//            startMapSearch(search: search)

        default:
//            mapSearchType = "" // redundant?
            let searchRequest = MKLocalSearch.Request()
            searchRequest.region = mapRegion.region
            searchRequest.naturalLanguageQuery = mapSearch
//            searchRequest.resultTypes = [.address, .pointOfInterest] // redundant?
            let search = MKLocalSearch(request: searchRequest)
            startMapSearch(search: search)
        }
        
        
        
        
    }
    
    func startMapSearch(search: MKLocalSearch) {
        search.start { (response, error) in
            guard let response = response else {
                print(error?.localizedDescription ?? "Error unknown.")
                searchError = true
                searchShowing = true
                return
            }
            
            
            withAnimation {
                                
//                mapItems.mapItems += response.mapItems.filter( { abs($0.placemark.coordinate.latitude - latitude) <= 0.05 && abs($0.placemark.coordinate.longitude - longitude) <= 0.05  } )
                
//                print(response.mapItems.count)
//                print(response.mapItems[0].name ?? "", response.mapItems[0].placemark.title ?? "")
                if !mapSearchType.isEmpty && (selectedType != .stores || selectedType != .attractions) {
                    print(response.mapItems.count)
                    let latitude = mapRegion.region.center.latitude
                    let longitude = mapRegion.region.center.longitude
                    
                    mapItems.mapItems += response.mapItems.filter( {
                        guard let category = $0.pointOfInterestCategory else { return false }
                        return selectedType.casesByCategory().contains(category) && abs($0.placemark.coordinate.latitude - latitude) <= 0.05 && abs($0.placemark.coordinate.longitude - longitude) <= 0.05
                        
                    } )
//                    print(mapItems.mapItems)
                } else {
                    mapItems.mapItems += response.mapItems
//                        .filter( { abs($0.placemark.coordinate.latitude - latitude) <= 0.05 && abs($0.placemark.coordinate.longitude - longitude) <= 0.05
//
//                    } )
                }
                
//                mapItems.mapItems = response.mapItems
//                assert(mapItems.mapItems == response.mapItems, "Map Items are not equal.")
                
                // REMOVING THIS KEEPS IT CENTERED ON USER LOCATION
//                if response.mapItems.count >= 2 {
//                    mapRegion.region = response.boundingRegion
//                } else if response.mapItems.count == 1 {
//                    mapRegion.region.center = response.mapItems[0].placemark.coordinate
//                }
                
                
            }
            // keep or toss?
            /*
            withAnimation {
                if mapItems.mapItems.count == 1 {
                    var span = MKCoordinateSpan(latitudeDelta: abs(mapItems.mapItems[0].placemark.coordinate.latitude - mapRegion.region.center.latitude), longitudeDelta: abs(mapItems.mapItems[0].placemark.coordinate.longitude - mapRegion.region.center.longitude))
                    span = span * 2.5
                    mapRegion.region.span = span
                    
                } else {
                    mapRegion.region.span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                }

            }
            */

        }
    }
    
}


struct AddPlaceView_Previews: PreviewProvider {
    static var previews: some View {
        AddPlaceView()
    }
}
