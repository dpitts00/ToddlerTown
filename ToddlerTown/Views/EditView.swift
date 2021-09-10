//
//  EditView.swift
//  CoreDataTest
//
//  Created by Daniel Pitts on 7/16/21.
//

import SwiftUI
import MapKit

struct EditView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    @GestureState private var dragOffset = CGSize.zero
    
    @State private var title = ""
    @State private var type: PlaceType = .all
    @State private var address = ""
    @State private var url = ""
    @State private var phoneNumber = ""
    @State private var street = ""
    @State private var city = ""
    @State private var state = ""
    @State private var postalCode = ""
    @State private var countryCode = ""
    @State private var notes = ""
    
    @State private var editAddress = false
    
    @State private var region = MKCoordinateRegion(center: CLLocationManager.shared.location?.coordinate ?? MKPlaceAnnotation.example.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    @State private var userTrackingMode: MapUserTrackingMode = .none
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \PlaceAnnotation.title, ascending: true)],
        animation: .default) private var places: FetchedResults<PlaceAnnotation>
    
    @Binding var selectedPlace: PlaceAnnotation?
    let mapItem: MKMapItem?
    
    @Binding var exitMapSearch: Bool?
    
    var fromAddressSearch = false
    
    @State private var selectedPlaceTypeCases: [PlaceType] = []
    
    @State private var image: UIImage?
    @State private var images: [UIImage] = []
    @State private var imagePickerShowing = false
    
    @State private var alertShowing = false
    
    @Binding var showingDetailView: Bool
    
    var body: some View {
        /*
        let updatedRegion = Binding<MKCoordinateRegion>(
            get: {
                self.region
            },
            set: {
                self.region = $0
                print("New region is \(self.region).")
            }
        )
         */
        
        Form {
            Group {
                TextField("Place name", text: $title)
                    .autocapitalization(.words)
                    .lineLimit(0)
//                TextField("Address", text: $address)
//                    .textContentType(.fullStreetAddress)
                TextField("Website", text: $url)
                    .textContentType(.URL)
                TextField("Phone number", text: $phoneNumber)
                    .textContentType(.telephoneNumber)
                
                if !editAddress {
//                    VStack(alignment: .leading) {
//                        if selectedPlace?.fullAddress?.street != "" {
//                            Text(selectedPlace?.fullAddress?.street ?? "")
//                        }
//                        Text("\(selectedPlace?.fullAddress?.city ?? "") \(selectedPlace?.fullAddress?.state ?? "") \(selectedPlace?.fullAddress?.postalCode ?? "")")
//                    }
                    VStack(alignment: .leading) {
                        if street != "" {
                            Text(street)
                        }
                        Text("\(city) \(state) \(postalCode)")
                    }
                } else {
                    TextField("Street address", text: $street)
                        .textContentType(.fullStreetAddress)
                    TextField("City", text: $city)
                        .textContentType(.addressCity)
                    TextField("State", text: $state)
                        .textContentType(.addressState)
                    TextField("Postal code", text: $postalCode)
                        .textContentType(.postalCode)
                    TextField("Country", text: $countryCode)
                        .textContentType(.countryName)
                }
                                
                Button(action: {
                    withAnimation {
                        editAddress.toggle()

                    }
                }) {
                    HStack {
                        Image(systemName: editAddress ? "checkmark" : "pencil")
                        Text(editAddress ? "Done editing" : "Edit address")
                    }
                    .foregroundColor(.blue)
                }
            }
            
            Picker("Place type", selection: $type) {
                ForEach(selectedPlaceTypeCases, id: \.self) { type in
                    Text(type.rawValue.localizedCapitalized)
                }
            }
            .onChange(of: type, perform: { _ in
                selectedPlace?.type = type.rawValue
                
            })
            
            ZStack(alignment: .topLeading) {
                
                if notes.isEmpty {
                    Text("Description...")
                        .foregroundColor(Color(UIColor.placeholderText))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 12)
                }
                
                TextEditor(text: $notes)
                    .padding(4)
            }
            .frame(height: 300)
            
            List {
                ForEach(images, id: \.self) { image in
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .onDelete(perform: deleteImages)

                
                Button(action: {
                    imagePickerShowing = true
                }, label: {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add Image")
                    }
                    .padding()
                })
            }
            
            Section {
                Button(action: {
                    alertShowing = true
                }) {
                    HStack {
                        Spacer()
                        Image(systemName: "trash")
                        Text("Delete Place")
                        Spacer()
                    }
                    .padding(8)
                    .foregroundColor(.ttRed)
                }
            }
            
        } // end Form?
        .onAppear {
            selectedPlaceTypeCases = PlaceType.allCases
            selectedPlaceTypeCases.removeAll(where: { $0 == .all || $0 == .favorites })
            
            if let mapItem = mapItem {
                
                if let place = places.first(where: { $0.title == mapItem.name && $0.coordinate == mapItem.placemark.coordinate }) {
                    selectedPlace = place
                    loadSelectedPlace()
                    
//                    let name = mapItem.name
                    let postalAddress = mapItem.placemark.postalAddress
    //                let location = mapItem.placemark.location
                    let phoneNumber = mapItem.phoneNumber
                    let url = mapItem.url
                    
                    street = postalAddress?.street ?? ""
                    city = postalAddress?.city ?? ""
                    state = postalAddress?.state ?? ""
                    postalCode = postalAddress?.postalCode ?? ""
                    countryCode = postalAddress?.country ?? postalAddress?.isoCountryCode ?? ""
//                    country = postalAddress?.country ?? ""
//                    isoCountryCode = postalAddress?.isoCountryCode ?? ""
//                    subAdministrativeArea = postalAddress?.subAdministrativeArea ?? ""
//                    subLocality = postalAddress?.subLocality ?? "
                    
//                    title = name ?? ""
                    self.phoneNumber = phoneNumber ?? ""
                    self.url = url?.absoluteString ?? ""
                }
                
                let name = mapItem.name
                let postalAddress = mapItem.placemark.postalAddress
//                let location = mapItem.placemark.location
                let phoneNumber = mapItem.phoneNumber
                let url = mapItem.url
                
                street = postalAddress?.street ?? ""
                city = postalAddress?.city ?? ""
                state = postalAddress?.state ?? ""
                postalCode = postalAddress?.postalCode ?? ""
                countryCode = postalAddress?.country ?? postalAddress?.isoCountryCode ?? ""
//                country = postalAddress?.country ?? ""
//                isoCountryCode = postalAddress?.isoCountryCode ?? ""
//                subAdministrativeArea = postalAddress?.subAdministrativeArea ?? ""
//                subLocality = postalAddress?.subLocality ?? "
                
                title = name ?? ""
                self.phoneNumber = phoneNumber ?? ""
                self.url = url?.absoluteString ?? ""
                
               if let category = mapItem.pointOfInterestCategory {
                    switch category {
                    case .beach, .nationalPark, .park:
                        type = PlaceType.parksAndNature
                    case .store:
                        type = PlaceType.stores
                    case .bakery, .cafe, .restaurant:
                        type = PlaceType.restaurantsAndCafes
                    case .library, .museum:
                        type = PlaceType.librariesAndMuseums
                    case .amusementPark, .aquarium, .zoo:
                        type = PlaceType.attractions
                    default:
                        type = PlaceType.all
                    }
                }
            } else {
                loadSelectedPlace()
            }
            
        }
        .onDisappear {
            selectedPlace?.title = title
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Edit Place")
                    .fontWeight(.semibold)
                    .font(.custom("Avenir Next", size: 18))
                    .foregroundColor(Color.ttBlue)
            }
        }
        .navigationBarItems(leading: Button(action: {
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Text("Cancel")
                .fontWeight(.semibold)
                .font(.custom("Avenir Next", size: 18))
                .foregroundColor(Color.ttBlue)
//                .padding([.top, .trailing, .bottom])
        }), trailing: Button(action: {
            selectedPlace == nil ? addPlace() : editPlace()
            exitMapSearch = true // experiment
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Text("Save")
                .fontWeight(.semibold)
                .font(.custom("Avenir Next", size: 18))
                .foregroundColor(Color.ttBlue)
                .padding([.leading, .top, .bottom])
        }))
        .navigationBarBackButtonHidden(true)
        .gesture(DragGesture().updating($dragOffset, body: {
            (value, state, transaction) in
            if (value.startLocation.x < 20 && value.translation.width > 100) {
                self.presentationMode.wrappedValue.dismiss()
            }
        }))
        .sheet(isPresented: $imagePickerShowing, onDismiss: updateImages) {
            ImagePickerView(image: $image)
        }
        .alert(isPresented: $alertShowing) {
            Alert(title: Text("Delete Place?"),
                  primaryButton: .destructive(Text("Delete"), action: {
                    deletePlace()
                  }),
                  secondaryButton: .cancel())
        }
        
        
    } // end body
    
    func loadSelectedPlace() {
        if let selectedPlace = selectedPlace {
            title = selectedPlace.title ?? ""
            
            if type == .all {
               if let type = PlaceType(rawValue: selectedPlace.type ?? "All") {
                self.type = type
               }
            }
            
//                if let type = PlaceType(rawValue: selectedPlace.type ?? "All") {
//                    self.type = type
//                }
            
            // region unused without little map here
            /*
            region = MKCoordinateRegion(center: selectedPlace.coordinate, span: MKCoordinateSpan(latitudeDelta: CLLocationDegrees(0.05), longitudeDelta: CLLocationDegrees(0.05)))
            */
            if let selectedAddress = selectedPlace.address {
                if !selectedAddress.isEmpty {
                    address = selectedAddress
                    let addressComponents = address.trimmingCharacters(in: .whitespacesAndNewlines).split(separator: ",")
                    if addressComponents.count >= 3 {
                        street = String(addressComponents[0])
                        city = String(addressComponents[1])
                        state = String(addressComponents[2].dropLast(6).count == 2 ? addressComponents[2].dropLast(6) : addressComponents[2].dropLast(7))
                        postalCode = String(addressComponents[2].dropFirst(4))
                    }
                }
            }
            
            street = selectedPlace.fullAddress?.street ?? ""
            city = selectedPlace.fullAddress?.city ?? ""
            state = selectedPlace.fullAddress?.state ?? ""
            postalCode = selectedPlace.fullAddress?.postalCode ?? ""
            countryCode = selectedPlace.fullAddress?.country ?? "US"
            
            phoneNumber = selectedPlace.phoneNumber ?? ""
            url = selectedPlace.url ?? ""
            notes = selectedPlace.notes ?? ""
            
            if let data = selectedPlace.images {
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
    
    func updateImages() {
        guard let image = image else { return }
        images.append(image)
    }
    
    func deleteImages(at offsets: IndexSet) {
        images.remove(atOffsets: offsets)
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
    
    private func addPlace() {
        withAnimation {
                        
            
            if let mapItem = mapItem,
               let place = places.first(where: { $0.title == mapItem.name && $0.coordinate == mapItem.placemark.coordinate }),
               let address = place.fullAddress {
                place.title = title
                place.type = type.rawValue
                place.notes = notes
//                place.isFavorite = false
                place.phoneNumber = phoneNumber
                place.url = url
                
                address.street = street
                address.city = city
                address.state = state
                address.postalCode = postalCode
                address.country = countryCode
                address.country = mapItem.placemark.country ?? ""
                address.isoCountryCode = mapItem.placemark.isoCountryCode ?? ""
                address.subLocality = mapItem.placemark.subLocality ?? ""
                address.subAdministrativeArea = mapItem.placemark.subAdministrativeArea ?? ""
                
//                do {
//                    let imageData = images.map { $0.jpegData(compressionQuality: 0.8) }
//                    place.images = try NSKeyedArchiver.archivedData(withRootObject: imageData, requiringSecureCoding: true)
//                } catch {
//                    print("Images not serialized. Error: \(error.localizedDescription)")
//                }
                
                place.latitude = mapItem.placemark.coordinate.latitude
                place.longitude = mapItem.placemark.coordinate.longitude
                
            } else {
            
                let newPlace = PlaceAnnotation(context: viewContext)
                newPlace.id = UUID()
                newPlace.title = title
                newPlace.type = type.rawValue
                newPlace.notes = notes
                newPlace.isFavorite = false
                newPlace.phoneNumber = mapItem?.phoneNumber ?? ""
                newPlace.url = mapItem?.url?.absoluteString ?? ""
                
                // *** DO I NEED THIS?
                
    //            if !images.isEmpty {
    //                let data = images[0].jpegData(compressionQuality: 0.8)
    //                newPlace.images = data
    //            }
                
                let newAddress = FullAddress(context: viewContext)
                newAddress.id = UUID()
                newAddress.street = street
                newAddress.city = city
                newAddress.state = state
                newAddress.postalCode = postalCode
                newAddress.country = mapItem?.placemark.country ?? ""
                newAddress.isoCountryCode = mapItem?.placemark.isoCountryCode ?? ""
                newAddress.subLocality = mapItem?.placemark.subLocality ?? ""
                newAddress.subAdministrativeArea = mapItem?.placemark.subAdministrativeArea ?? ""
                
                newPlace.fullAddress = newAddress
                newAddress.placeAnnotation = newPlace
                
                do {
                    let imageData = images.map { $0.jpegData(compressionQuality: 0.8) }
                    newPlace.images = try NSKeyedArchiver.archivedData(withRootObject: imageData, requiringSecureCoding: true)
                } catch {
                    print("Images not serialized. Error: \(error.localizedDescription)")
                }
                
                newPlace.latitude = mapItem?.placemark.coordinate.latitude ?? 43
                newPlace.longitude = mapItem?.placemark.coordinate.longitude ?? -89
            }
            
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
    
    private func editPlace() {
        // *** THIS MAY NEED EDITING FOR ADDRESS AND IMAGES
        withAnimation {
//            need FetchedResults to edit? set this in .onAppear
//            Does it work?? YES
//            Does it crash?? NO
//            **Need to deselect row after clicking on in List View
            selectedPlace?.title = title
            selectedPlace?.type = type.rawValue
            selectedPlace?.url = url
            selectedPlace?.phoneNumber = phoneNumber
//            place?.latitude = region.center.latitude
//            place?.longitude = region.center.longitude
            selectedPlace?.notes = notes
            
            let newAddress = FullAddress(context: viewContext)
            
            if let existingAddress = selectedPlace?.fullAddress {
                newAddress.id = existingAddress.id
            }

            newAddress.street = street
            newAddress.city = city
            newAddress.state = state
            newAddress.postalCode = postalCode
            newAddress.country = countryCode
            selectedPlace?.fullAddress = newAddress
            
//            if !images.isEmpty {
//                let data = images[0].jpegData(compressionQuality: 0.8)
//                place?.images = data
//            }
            
            do {
                let imageData = images.map { $0.jpegData(compressionQuality: 0.8) }
                selectedPlace?.images = try NSKeyedArchiver.archivedData(withRootObject: imageData, requiringSecureCoding: true)
            } catch {
                print("Images not serialized. Error: \(error.localizedDescription)")
            }
            
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
    
    func deletePlace() {
        if let selectedPlace = selectedPlace {
            viewContext.delete(selectedPlace)
            showingDetailView = false
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print("Places not saved. Error: \(nsError)")
        }
        
        presentationMode.wrappedValue.dismiss()
    }
}

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
//        EditView(selectedPlace: .constant(PlaceAnnotation().example), exitMapSearch: .constant(false))
        EditView(selectedPlace: .constant(nil), mapItem: nil, exitMapSearch: .constant(false), showingDetailView: .constant(true))
    }
}
