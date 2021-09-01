//
//  MapSearchTest.swift
//  CoreDataTest
//
//  Created by Daniel Pitts on 7/20/21.
//
/*
import SwiftUI
import MapKit
//import CoreLocation

class MapSimpleAnnotation: NSObject, MKAnnotation, Identifiable {
    var id: UUID
    var coordinate: CLLocationCoordinate2D
    
    init(id: UUID, coordinate: CLLocationCoordinate2D) {
        self.id = id
        self.coordinate = coordinate
    }
}

struct MapSearchTest: View {
//    @Environment(\.isFocused) private var isFocused
    @Environment(\.managedObjectContext) private var viewContext
    
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var text = ""
    @State private var startRegion = MKCoordinateRegion(center: CLLocationManager().location?.coordinate ?? MKPlaceAnnotation.example.coordinate, span: MKCoordinateSpan(latitudeDelta: CLLocationDegrees(0.02), longitudeDelta: CLLocationDegrees(0.02)))
    
    @State private var places: [MKMapItem] = []
    @State private var isEditViewShowing = false
    @State private var exitMapSearch: Bool? = false
    
    var request = MKLocalSearch.Request()
    @State private var selectedPlace: MKPlaceAnnotation?
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \PlaceAnnotation.title, ascending: true)],
        animation: .default) private var myPlaces: FetchedResults<PlaceAnnotation>
    
    @State private var annotations: [MKPlaceAnnotation] = []
    
    @State private var location = CLLocationManager().location?.coordinate
    var myLocation = CLLocationManager().location
    
    @State private var alertShowing = false
    
    var body: some View {
        let region = Binding<MKCoordinateRegion>(
            get: {
                self.startRegion
            },
            set: {
                self.startRegion = $0
            }
        )
        
        // for selectedPlace
        // check if that works with List already
        
            VStack {
                
                
                Form {
                    
                    HStack {
                        Text("Search Nearby Places")
                        
                        Spacer()
                        
                        Image(systemName: "location.fill")
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .cornerRadius(12.0)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundColor(.white)
                    .font(.headline)
                    .background(Color.blue.cornerRadius(12))
                    .padding(4)
                    .onTapGesture {
                        searchNearby()
                    }


                    
                    HStack {
                        // .onCommit has been deprecated already for iOS 15 only
                        // replaced with .onSubmit
                        TextField("Search for a location", text: $text,
                          onCommit: {
                            if !text.isEmpty {
                                request.naturalLanguageQuery = text
                                search(using: request)
                            }
                        })
                            .keyboardType(.webSearch)
                        Button(action: {
                            request.naturalLanguageQuery = text
                            search(using: request)
                        }, label: {
                            Image(systemName: "magnifyingglass")
                        })
                        .disabled(text.isEmpty)
                    }
                    .padding(.vertical, 2)
                    .padding(8)
                    .background(Color(white: 0.95).cornerRadius(12.0))
                    .padding(4)
//                    .padding([.top, .leading, .trailing])
//                    .padding(.bottom, 6)
//                    .padding(.top, 16)
                    
                    
                    
                    VStack {
                        Map(coordinateRegion: region, showsUserLocation: true, userTrackingMode: .constant(.none), annotationItems: annotations) {
                        annotation in
                            MapAnnotation(coordinate: annotation.coordinate) {
                                ZStack(alignment: Alignment(horizontal: .center, vertical: .center)) {
                                    Image(systemName: "mappin")
                                        .font(.headline)
                                        .padding(4)
                                        .background(
                                            PlacemarkAnnotationView(selected: selectedPlace?.address == annotation.address, size: selectedPlace?.address == annotation.address ? 36 : 30)
                                        )
                                        .foregroundColor(.white)
                                    VStack {
                                        ZStack {
//                                            Text(annotation.title ?? "")
//                                                .foregroundColor(.white)
//                                                .offset(x: 1, y: 0)
//                                            Text(annotation.title ?? "")
//                                                .foregroundColor(.white)
//                                                .offset(x: -1, y: 0)
//                                            Text(annotation.title ?? "")
//                                                .foregroundColor(.white)
//                                                .offset(x: 0, y: 1)
//                                            Text(annotation.title ?? "")
//                                                .foregroundColor(.white)
//                                                .offset(x: 0, y: -1)
                                            Text(annotation.title ?? "")
                                                .shadow(color: .white, radius: 1, x: 0, y: 0)
                                                .shadow(color: .white, radius: 1, x: 0, y: 0)
                                                .shadow(color: .white, radius: 1, x: 0, y: 0)

                                                
                                        }
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                        .frame(width: 100)
                                        .font(.caption)
                                        
                                        

//                                        Text(annotation.address ?? "")
//                                            .lineLimit(2)
//                                            .font(.caption2)
                                            
                                    }
                                    .offset(x: 0, y: 32)
//                                    .shadow(color: .white, radius: 2, x: 0, y: 0)
//                                    .shadow(color: .gray, radius: 8, x: 0, y: 0)
                                }
                                .onTapGesture {
//                                    print("annotation: \(annotation.title ?? "")")
                                    selectedPlace = annotation
//                                    print("selectedPlace: \(selectedPlace?.title ?? "")")ß
                                    
                                }
                            }
                        }
                        .frame(height: 300)
                    } // End Map
                    
                
                
                
//                SimpleMapView(selectedPlace: $selectedPlace, region: region, userLocationShown: .constant(false), userLocation: $location, annotations: annotations)
//                    .frame(height: 300)
                                
                ForEach(places, id: \.self) { place in
                        
                    HStack {
                        VStack(alignment: .leading) {
                            Text(place.name ?? "Unknown place")
                                .font(.headline)
                                .foregroundColor(.red)
                            Text("Unknown title")
                        }
                        .onTapGesture {
                            selectedPlace = MKPlaceAnnotation(id: UUID(), title: place.name, subtitle: "", coordinate: place.placemark.coordinate, type: .all)
                            // experiment
//                            print("selectedPlace: \(selectedPlace?.title ?? "")")
//                            print("address: \(selectedPlace?.address ?? "")")
                            
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            selectedPlace = MKPlaceAnnotation(id: UUID(), title: place.name, subtitle: "", coordinate: place.placemark.coordinate, type: .attraction)
                            
                            isEditViewShowing = true
                        }, label: {
                            Image(systemName: "plus")
                                .font(.title)
                                .foregroundColor(.red)
                        })
                    }
//                    MKMapItem().openInMaps(launchOptions: <#T##[String : Any]?#>)
                }
            }
        }
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }, label: {
                Text(Image(systemName: "chevron.backward"))
                    .fontWeight(.semibold)
                    .padding([.top, .trailing, .bottom])
                    .foregroundColor(MyColors.blue)
            }))
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Add Places")
                        .fontWeight(.semibold)
                        .foregroundColor(MyColors.blue)
                        .font(.custom("Avenir Next", size: 18))
                }
            }
            .onAppear {
                if let exitMapSearch = exitMapSearch {
                    if exitMapSearch {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .alert(isPresented: $alertShowing) {
                Alert(title: Text("No places found nearby."), message: nil, dismissButton: .default(Text("OK")))
            }
        
        NavigationLink(
            destination: EditView(selectedPlace: $selectedPlace, exitMapSearch: $exitMapSearch, fromAddressSearch: true),
            isActive: $isEditViewShowing) { EmptyView() }

                
    }
    
    private func searchNearby() {
        let region = MKCoordinateRegion(center: self.startRegion.center, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        let allPointsRequest = MKLocalPointsOfInterestRequest(coordinateRegion: region)
        let localSearch = MKLocalSearch(request: allPointsRequest)
        localSearch.start { [self] (response, error) in
            guard error == nil else {
                print(error?.localizedDescription ?? "Unknown error")
                alertShowing = true
                return
            }
            
            if let response = response {
                if response.mapItems.count == 0 {
                    alertShowing = true
                    return
                } else if response.mapItems.count > 1 {
                    self.startRegion = response.boundingRegion
                    
                    if response.mapItems.count > 10 {
                        self.places = Array(response.mapItems[0...9])

                    } else {
                        self.places = response.mapItems
                    }
                }
                

                
                self.annotations = self.places.map({ MKPlaceAnnotation(id: UUID(), title: $0.name, subtitle: "", coordinate: $0.placemark.coordinate, type: .all) })
                
            }
            
            
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
        
    private func search(using searchRequest: MKLocalSearch.Request) {
        searchRequest.region = startRegion
        searchRequest.resultTypes = [.pointOfInterest, .address]
        // .pointOfInterest and .address are mutually exclusive, and I need both
        
        let localSearch = MKLocalSearch(request: searchRequest)
        localSearch.start { [self] (response, error) in
            guard error == nil else {
                print(error?.localizedDescription ?? "Unknown error")
                return
            }
            
            if let response = response {
                if response.mapItems.count <= 5 {
                    self.places = response.mapItems
                } else {
                    if let location = self.myLocation {
                        self.places = Array(response.mapItems.sorted(by: {$0.placemark.location?.distance(from: location) ?? 0 < $1.placemark.location?.distance(from: location) ?? 1})[0...9])
                        // maybe change to limit to map region?
                    } else {
                        self.places = Array(response.mapItems[0...9])
                    }
                }
                
                self.annotations = self.places.map({ MKPlaceAnnotation(id: UUID(), title: $0.name, subtitle: "", coordinate: $0.placemark.coordinate, type: .all) })
                
                self.startRegion = response.boundingRegion
            }
            
            
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
    
}

struct MapSearchTest_Previews: PreviewProvider {
    static var previews: some View {
        MapSearchTest()
    }
}

extension String {
    func addressFormatter() -> String {
        let components = self.split(separator: ",")
        
        guard components.count == 4 else { return "" }
        
        let street = components[0]
        let city = components[1].dropFirst()
        let state = components[2].dropFirst().dropLast(6)
        var postalCode = components[2].dropFirst(4)
        if postalCode.count != 5 { postalCode = postalCode.dropFirst() }
        let formattedAddress = "\(street)\n\(city), \(state)"
        return formattedAddress
    }
    
    func addressFormatterWithPostalCode() -> String {
        let components = self.split(separator: ",")
//        print(components, components.count)
        guard components.count == 4 else { return "" }
        let street = components[0]
        let city = components[1].dropFirst()
        let state = components[2].dropFirst().dropLast(6)
        var postalCode = components[2].dropFirst(4)
        if postalCode.count != 5 { postalCode = postalCode.dropFirst() }
//        print(street)
//        print(city)
//        print(state)
//        print(postalCode)
        let formattedAddress = "\(street)\n\(city), \(state) \(postalCode)"
        return formattedAddress
    }
}
*/
