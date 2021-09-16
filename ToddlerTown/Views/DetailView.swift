//
//  DetailView.swift
//  CoreDataTest
//
//  Created by Daniel Pitts on 7/15/21.
//

import SwiftUI
import MapKit
import Contacts
import LinkPresentation

//class MapViewModel: ObservableObject {
//    @Published var coordinateRegion: MKCoordinateRegion = MKPlaceAnnotation.exampleRegion
//}

struct DetailView: View {
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    @GestureState private var dragOffset = CGSize.zero
    
    @Binding var selectedPlace: PlaceAnnotation?
    @Binding var redrawMap: Bool
    
//    @ObservedObject var mapViewModel: MapViewModel
    
//    init(_ mapViewModel: MapViewModel, selectedPlace: MKPlaceAnnotation?) {
//        self.mapViewModel = mapViewModel
//    }
    
    @State private var region: MKCoordinateRegion = MKCoordinateRegion(center: CLLocationManager.shared.location?.coordinate ?? MKPlaceAnnotation.example.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.25, longitudeDelta: 0.25))
    
    @State private var userTrackingMode: MapUserTrackingMode = .none
    
    @State private var actionSheetShowing = false
    
    @State private var alertShowing = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var alertPrimaryButton = ""

    
    @State private var showingEditView = false
    
    var locationManager = CLLocationManager.shared
    @State private var address = CNMutablePostalAddress()
    
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \PlaceAnnotation.title, ascending: true)],
//        animation: .default) private var places: FetchedResults<PlaceAnnotation>
    
    @State private var images: [UIImage] = []
    
    // for ActivityViewController
    @State private var metadata: LPLinkMetadata?
    @State private var shareSheetShowing = false
    
    @Binding var showingDetailView: Bool

    var body: some View {

        let userLocation = getLocation()
        
        return ScrollView {
            VStack(alignment: .leading) {
                
                if metadata != nil {
                    ActivityViewController(metadata: metadata) {
                        self.metadata = nil
                    }
                    .frame(width: 0, height: 0)
                } else {
                    EmptyView()
                }
                
                NavigationLink(
                    destination: EditView(selectedPlace: $selectedPlace, mapItem: nil, exitMapSearch: .constant(false), showingDetailView: $showingDetailView),
                    isActive: $showingEditView) { EmptyView() }
                
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text(selectedPlace?.title ?? "Unknown place")
                            .font(.headline)
                        
                        Text(CNPostalAddressFormatter.shared.string(from: address))
                        
                        if let phoneNumber = selectedPlace?.phoneNumber,
                           !phoneNumber.isEmpty {
                            Button (action: {
                                if let phoneURL = URL(string: ("tel://\(phoneNumber)")) {
                                    if UIApplication.shared.canOpenURL(phoneURL) {
                                        UIApplication.shared.open(phoneURL)
                                    }
                                }
                            }) {
                                HStack {
                                    Image(systemName: "phone.fill")
                                    Text(phoneNumber)
                                }
                                .padding(1)
                            }
                        }
                        
                        if let urlString = selectedPlace?.url,
                           !urlString.isEmpty,
                           let url = URLComponents(string: urlString) {
                            Button (action: {
                                alertShowing = true
                                alertTitle = "Visit this website?"
                                alertMessage = urlString
                                alertPrimaryButton = "Go"
                            }) {
                                HStack {
                                    Image(systemName: "network")
                                    Text(url.host ?? urlString)
                                }
                                .padding(1)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    VStack {
                        Button(action: {
                            let name = selectedPlace?.title ?? ""
                            let address = selectedPlace?.address ?? ""
                            let urlString = "https://maps.apple.com/?address=\(name),\(address)"
                            let urlStringFormatted = urlString.split(separator: " ").joined(separator: "+").replacingOccurrences(of: "+", with: "%20").replacingOccurrences(of: ",", with: "%2C")
                            
                            // metadata being added here
                            MapLinkView.getMetadata(urlStringFormatted) { result in
                                if self.metadata != nil {
                                    self.metadata = nil
                                }
                                self.handleMetadataResult(result)
        //                        shareSheetShowing = true
                            }
                        }, label: {
                            Image(systemName: "square.and.arrow.up")
                                .font(.title)
                        })
                    }
                }
                .padding(.horizontal)
                
                VStack(alignment: .center) {
                    Button(action: {
                        actionSheetShowing = true
                    }) {
                        VStack {
                            Text("Get Directions")
                                .font(.headline)
                            Text(userLocation != nil ? "\(getDistance()) mi away" : "Distance unknown")
                                .font(.subheadline)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(1.0))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12.0))
                        .padding(.vertical)
                    }
                }
                
                VStack(alignment: .leading) {
                    if let notes = selectedPlace?.notes {
                        if !notes.isEmpty {
                            Text(notes)
                                .padding(.vertical)
                        }
                    }
                    
                    ForEach(images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(12.0)
                    }
                } // end VStack
            } // end VStack
            .padding([.bottom, .leading, .trailing])

            .actionSheet(isPresented: $actionSheetShowing) {
                ActionSheet(title: Text("Get Directions"), message: nil, buttons: [
                    .default(Text("Apple Maps")) {
                        // open in Apple Maps
                        if let coordinate = selectedPlace?.coordinate {
                            let placemark = MKPlacemark(coordinate: coordinate, postalAddress: self.address)
                            let mapItem = MKMapItem(placemark: placemark)
                            mapItem.name = selectedPlace?.title ?? ""
                            mapItem.openInMaps(launchOptions: nil)
                        }
                    },
                    .default(Text("Google Maps")) {
                        // open in Google Maps
                        let name = selectedPlace?.title ?? ""
                        let address = selectedPlace?.address ?? ""
                        var urlString = "https://www.google.com/maps/search/?api=1&query=\(name),\(address)"
                        urlString = urlString.replacingOccurrences(of: " ", with: "%20").replacingOccurrences(of: ",", with: "&2C")
                        print(urlString)
                        if let url = URL(string: urlString) {
                            UIApplication.shared.open(url)
                        }
                    },
                    .cancel()
                ])
            }
            .alert(isPresented: $alertShowing) {
                Alert(title: Text(alertTitle), message: Text(alertMessage),
                      primaryButton: .default(Text(alertPrimaryButton)) {
                        if let urlString = selectedPlace?.url,
                           let url = URL(string: urlString) {
                            UIApplication.shared.open(url)
                        }
                      },
                      secondaryButton: .cancel())
            }

    //        .navigationBarItems(trailing: NavigationLink(destination: EditView(selectedPlace: selectedPlace)) {
    //            Text("Edit")
    //        })
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }, label: {
                Text(Image(systemName: "chevron.backward"))
                    .fontWeight(.semibold)
                    .padding([.top, .trailing, .bottom])
                    .foregroundColor(Color.ttBlue)
            }), trailing: Button(action: { showingEditView = true }) {
                Text("Edit")
                    .foregroundColor(Color.ttBlue)
                    .padding()
            })
            .toolbar {
                ToolbarItem(placement: .principal) {
//                    selectedPlace?.title ?? 
                    Text("Place Info")
                        .font(.custom("Avenir Next", size: 18))
                        .fontWeight(.semibold)
                        .foregroundColor(Color.ttBlue)
                        
                        
                }
            }
            
//            .navigationBarTitle(selectedPlace?.title ?? "No title given.", displayMode: .inline)
            .onAppear {
                
                if !showingDetailView {
                    presentationMode.wrappedValue.dismiss()
                }
                
                if let place = selectedPlace {
                    
                    // this updates the type from v1.0 -> 1.1
                    switch place.type {
                    case "store":
                        selectedPlace?.type = "Stores"
                    case "beach", "park", "trail":
                        selectedPlace?.type = "Parks & Nature"
                    case "attraction":
                        selectedPlace?.type = "Attractions"
                    case "restaurant", "cafe":
                        selectedPlace?.type = "Restaurants & Cafés"
                    case "library", "museum":
                        selectedPlace?.type = "Libraries & Museums"
                    case "friends", "family":
                        selectedPlace?.type = "Friends & Family"
                    default:
                        print("don't change the type")
                    }
                    
                    // this pulls out the address for Sharing
                    if let address = place.fullAddress {
                        
                        let newAddress = CNMutablePostalAddress()
                        newAddress.street = address.street ?? ""
                        newAddress.subLocality = address.subLocality ?? ""
                        newAddress.city = address.city ?? ""
                        newAddress.subAdministrativeArea = address.subAdministrativeArea ?? ""
                        newAddress.state = address.state ?? ""
                        newAddress.postalCode = address.postalCode ?? ""
                        newAddress.country = address.country ?? ""
                        newAddress.isoCountryCode = address.isoCountryCode ?? ""
                        self.address = newAddress
                    } else {
                        // this pulls the address info (CDv1.0) into fullAddress (CDv1.1)
                        if let shortAddress = place.address {
                            if !shortAddress.isEmpty {
                                let addressComponents = shortAddress.trimmingCharacters(in: .whitespacesAndNewlines).split(separator: ",")
                                if addressComponents.count >= 3 {
                                    selectedPlace?.fullAddress?.street = String(addressComponents[0])
                                    selectedPlace?.fullAddress?.city = String(addressComponents[1].dropFirst())
                                    selectedPlace?.fullAddress?.state = String(addressComponents[2].dropLast(6).count == 2 ? addressComponents[2].dropLast(6) : addressComponents[2].dropLast(7))
                                    selectedPlace?.fullAddress?.postalCode = String(addressComponents[2].dropFirst(4))
                                }
                            }
                        }
                    }
                    
                    // this should populate the other fields for migration -- seems to be okay
                    
                    
                    if let data = place.images {
                        do {
                            if let imageData = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: data) as? [Data] {
                                images = imageData.compactMap( { UIImage(data: $0) } )
                                print("Images: \(images.count)")
                                self.images = images
                            }
                        } catch {
                            print("Image data could not be retrieved or deserialized from CoreData entity. Error: \(error.localizedDescription)")
                        }
                    }
                }
                
                // and saves it without the Edit View
                try? viewContext.save()

            }
            .onDisappear {
                redrawMap = false
            }
        }
        .padding(.top)
        .gesture(DragGesture().updating($dragOffset, body: {
            (value, state, transaction) in
            if (value.startLocation.x < 20 && value.translation.width > 100) {
                self.presentationMode.wrappedValue.dismiss()
            }
        }))

    }
    
    // MARK: getPlace()
    /*
    func getPlace(for annotation: MKPlaceAnnotation?) -> PlaceAnnotation? {
        if let annotation = annotation {
            return self.places.first(where: { $0.title == annotation.title && $0.type == annotation.type.rawValue && $0.latitude == annotation.coordinate.latitude && $0.longitude == annotation.coordinate.longitude } )
        }
        return nil
    }
    */
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
    func getLocation() -> CLLocation? {
        return locationManager.location
    }
    
    func getSelectedPlaceLocation() -> CLLocation? {
        return CLLocation(latitude: selectedPlace!.coordinate.latitude, longitude: selectedPlace!.coordinate.longitude)
    }
    
    func getDistance() -> String {
        if getLocation() != nil && getSelectedPlaceLocation() != nil {
            let distance = (getLocation()!.distance(from: getSelectedPlaceLocation()!) / 1600)
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
    
    // MARK: send URL to Maps
    func returnURLForLocation() -> URL? {
        guard let location = selectedPlace else { return nil }
        
//        if location.address != nil {
//            return URL(string: "https://maps.apple.com/?daddr=\(location.address ?? "")")
//        }
        
//        print("location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        return URL(string: "https://maps.apple.com/?daddr=\(location.coordinate.latitude),\(location.coordinate.longitude)")!
    }
/*
    func openLocationInMaps() {
        if let selectedPlace = selectedPlace {
            let address = CNMutablePostalAddress()
//            address.street = selectedPlace.address ?? ""
            let placemark = MKPlacemark(coordinate: selectedPlace.coordinate, postalAddress: address)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = selectedPlace.title
            mapItem.openInMaps()
        }
    }

    func openLocationAsURL() {
        if let mapsURL = returnURLForLocation() {
//            if UIApplication.shared.canOpenURL(mapsURL) {
                UIApplication.shared.open(mapsURL)
//            }
        }
    }
*/
}

struct DetailView_Previews: PreviewProvider {
    
    static var previews: some View {
//        let region = MKCoordinateRegion(center: MKPlaceAnnotation.example.coordinate, span: MKCoordinateSpan(latitudeDelta: CLLocationDegrees(0.25), longitudeDelta: CLLocationDegrees(0.25)))
        DetailView(selectedPlace: .constant(PlaceAnnotation().example), redrawMap: .constant(false), showingDetailView: .constant(true))
            .onAppear {
                
            }
    }
}
