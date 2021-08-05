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
    
    @Binding var selectedPlace: MKPlaceAnnotation?
    
//    @ObservedObject var mapViewModel: MapViewModel
    
//    init(_ mapViewModel: MapViewModel, selectedPlace: MKPlaceAnnotation?) {
//        self.mapViewModel = mapViewModel
//    }
    
    @State private var region: MKCoordinateRegion = MKCoordinateRegion(center: CLLocationManager().location?.coordinate ?? MKPlaceAnnotation.example.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.25, longitudeDelta: 0.25))
    
    @State private var userTrackingMode: MapUserTrackingMode = .none
    
    @State private var acShowing = false
    @State private var alertShowing = false
    
    @State private var showingEditView = false
    
    var locationManager = CLLocationManager()
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \PlaceAnnotation.title, ascending: true)],
        animation: .default) private var places: FetchedResults<PlaceAnnotation>
    
    @State private var images: [UIImage] = []

    var body: some View {

        let userLocation = getLocation()
        
        return ScrollView {
            VStack(alignment: .leading) {
                
                NavigationLink(
                    destination: EditView(selectedPlace: $selectedPlace, exitMapSearch: .constant(false)),
                    isActive: $showingEditView) { EmptyView() }
                
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text(selectedPlace?.title ?? "Unknown place")
                            .font(.headline)
                        Text(selectedPlace?.address?.addressFormatterWithPostalCode() ?? "Unknown title")
                            .font(.subheadline)
                        
                        
                        if let notes = getPlace(for: selectedPlace)?.notes {
                            if !notes.isEmpty {
                                Text(notes)
                                    .padding(.vertical)
                            }
                        }
                        
                    }
                    
                    Spacer()
                    
                    VStack {
                        Button(action: {
                            acShowing = true
                        }, label: {
                            Image(systemName: "square.and.arrow.up")
                                .font(.title)
                        })
                    }
                }
                .padding(.horizontal)
                
                VStack(alignment: .center) {
                    Button(action: {
                        alertShowing = true
                    }) {
                        VStack {
                            Text("Get Directions")
                                .font(.headline)
                            Text(userLocation != nil ? "Distance: \(getDistance()) mi" : "Distance unknown")
                                .font(.subheadline)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(1.0))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12.0))
                        .padding(.bottom)
                    }
                }
                
                
                VStack {
                    ForEach(images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(12.0)
                    }
                    /*
                    ZStack {
                        DetailMapView(startRegion: $region, selectedPlace: selectedPlace)
                        
                        HStack {
                            Spacer()
                            VStack {
                                Spacer()
                                // or a Button() for default animation, etc.
                                Button(action: {
                                    alertShowing = true
                                }) {
                                    VStack {
                                        Image(systemName: "arrowshape.turn.up.right.fill")
                                        Text("Go")
                                    }
                                    .font(.title3)
                                    .padding()
                                    .background(Color.blue.opacity(1.0))
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                                }
                            }
                        }
                        .padding([.bottom, .trailing])
                    } // end ZStack
                    .frame(height: 300)
                    .cornerRadius(12.0)
                    */
                } // end VStack
            } // end VStack
    //        .padding(8)
    //        .background(RoundedRectangle(cornerRadius: 12.0, style: .continuous)
    //                        .fill(Color(red: 1.0, green: 0.96, blue: 0.94))
    //        )
            .padding([.bottom, .leading, .trailing])
            .popover(isPresented: $acShowing, attachmentAnchor: PopoverAttachmentAnchor.point(.center), arrowEdge: Edge.top) {
                ActivityViewController(place: selectedPlace, url: returnURLForLocation())
            }

            .actionSheet(isPresented: $alertShowing) {
                ActionSheet(title: Text("Get Directions"), message: nil, buttons: [
                    .default(Text("Open in Maps")) { openLocationInMaps() },
                    .default(Text("Open as URL")) { openLocationAsURL() },
                    .cancel()
                ])
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
                    .foregroundColor(MyColors.blue)
            }), trailing: Button(action: { showingEditView = true }) {
                Text("Edit")
                    .foregroundColor(MyColors.blue)
                    .padding()
            })
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(selectedPlace?.title ?? "No title given.")
                        .fontWeight(.semibold)
                        .foregroundColor(MyColors.blue)
                        .font(.custom("Avenir Next", size: 18))
                }
            }
//            .navigationBarTitle(selectedPlace?.title ?? "No title given.", displayMode: .inline)
            .onAppear {
                if let place = getPlace(for: selectedPlace) {
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
            }
        }
        .padding(.top)

    }
    
    // MARK: getPlace()
    
    func getPlace(for annotation: MKPlaceAnnotation?) -> PlaceAnnotation? {
        if let annotation = annotation {
            return self.places.first(where: { $0.title == annotation.title && $0.type == annotation.type.rawValue && $0.latitude == annotation.coordinate.latitude && $0.longitude == annotation.coordinate.longitude } )
        }
        return nil
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
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            numberFormatter.maximumFractionDigits = 2
            return numberFormatter.string(from: NSNumber(value: distance)) ?? "0.00"
        }
        return "0.0"
    }
    
    // MARK: send URL to Maps
    func returnURLForLocation() -> URL? {
        guard let location = selectedPlace else { return nil }
        
        if location.address != nil {
//            print("address: \(location.address ?? "")")
            return URL(string: "https://maps.apple.com/?daddr=\(location.address ?? "")")
        }
        
//        print("location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        return URL(string: "https://maps.apple.com/?daddr=\(location.coordinate.latitude),\(location.coordinate.longitude)")!
    }
    
    func openLocationInMaps() {
        if let selectedPlace = selectedPlace {
            let address = CNMutablePostalAddress()
            address.street = selectedPlace.address ?? ""
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
}

struct DetailView_Previews: PreviewProvider {
    
    static var previews: some View {
//        let region = MKCoordinateRegion(center: MKPlaceAnnotation.example.coordinate, span: MKCoordinateSpan(latitudeDelta: CLLocationDegrees(0.25), longitudeDelta: CLLocationDegrees(0.25)))
        DetailView(selectedPlace: .constant(MKPlaceAnnotation.example))
    }
}