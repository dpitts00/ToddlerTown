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
    
    @State private var region = MKCoordinateRegion(center: CLLocationManager().location?.coordinate ?? MKPlaceAnnotation.example.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    @State private var userTrackingMode: MapUserTrackingMode = .none
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \PlaceAnnotation.title, ascending: true)],
        animation: .default) private var places: FetchedResults<PlaceAnnotation>
    
    @Binding var selectedPlace: PlaceAnnotation?
    @State private var place: PlaceAnnotation?
    
    @Binding var exitMapSearch: Bool?
    
    var fromAddressSearch = false
    
    var selectedPlaceTypeCases: [PlaceType] = [] + PlaceType.allCases.drop(while: {$0 == .all || $0 == .favorites})
    
    @State private var image: UIImage?
    @State private var images: [UIImage] = []
    @State private var imagePickerShowing = false
    
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
//                TextField("Address", text: $address)
//                    .textContentType(.fullStreetAddress)
                TextField("Website", text: $url)
                    .textContentType(.URL)
                TextField("Phone number", text: $phoneNumber)
                    .textContentType(.telephoneNumber)
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
            
        }
        .onAppear {
            if let selectedPlace = selectedPlace {
                title = selectedPlace.title ?? ""
                
                //
//                if type == .all {
//                   if let type = PlaceType(rawValue: selectedPlace.type ?? "All") {
//                    self.type = type
//                   }
//                }
                
                if let type = PlaceType(rawValue: selectedPlace.type ?? "All") {
                 self.type = type
                }
                
                // region unused without little map here
                region = MKCoordinateRegion(center: selectedPlace.coordinate, span: MKCoordinateSpan(latitudeDelta: CLLocationDegrees(0.05), longitudeDelta: CLLocationDegrees(0.05)))
             
                self.place = selectedPlace
                address = selectedPlace.address ?? ""
                
                let addressComponents = address.trimmingCharacters(in: .whitespacesAndNewlines).split(separator: ",")
                street = selectedPlace.fullAddress?.street ?? String(addressComponents[0])
                city = selectedPlace.fullAddress?.city ?? String(addressComponents[1])
                state = selectedPlace.fullAddress?.state ?? String(addressComponents[2].dropLast(6).count == 2 ? addressComponents[2].dropLast(6) : addressComponents[2].dropLast(7))
                postalCode = selectedPlace.fullAddress?.postalCode ?? String(addressComponents[2].dropFirst(4))
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
        .onDisappear {
            selectedPlace?.title = title
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Edit Place")
                    .fontWeight(.semibold)
                    .font(.custom("Avenir Next", size: 18))
                    .foregroundColor(MyColors.blue)
            }
        }
        .navigationBarItems(leading: Button(action: {
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Text("Cancel")
                .fontWeight(.semibold)
                .font(.custom("Avenir Next", size: 18))
                .foregroundColor(MyColors.blue)
                .padding([.top, .trailing, .bottom])
        }), trailing: Button(action: {
            selectedPlace == nil || fromAddressSearch == true ? addPlace() : editPlace()
            exitMapSearch = true // experiment
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Text("Save")
                .fontWeight(.semibold)
                .font(.custom("Avenir Next", size: 18))
                .foregroundColor(MyColors.blue)
                .padding([.leading, .top, .bottom])
        }))
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $imagePickerShowing, onDismiss: updateImages) {
            ImagePickerView(image: $image)
        }
        
        
    } // end body
    
    func updateImages() {
        guard let image = image else { return }
        images.append(image)
    }
    
    func deleteImages(at offsets: IndexSet) {
        images.remove(atOffsets: offsets)
    }
    
    private func addPlace() {
        withAnimation {
            let newPlace = PlaceAnnotation(context: viewContext)
            newPlace.id = UUID()
            newPlace.title = title
            newPlace.type = type.rawValue
            newPlace.notes = notes
            newPlace.isFavorite = false
            
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
            newAddress.country = countryCode
            place?.fullAddress = newAddress
            
            do {
                let imageData = images.map { $0.jpegData(compressionQuality: 0.8) }
                newPlace.images = try NSKeyedArchiver.archivedData(withRootObject: imageData, requiringSecureCoding: true)
            } catch {
                print("Images not serialized. Error: \(error.localizedDescription)")
            }
            
            
            if let selectedPlace = selectedPlace {
                newPlace.latitude = selectedPlace.coordinate.latitude
                newPlace.longitude = selectedPlace.coordinate.longitude
            } else {
                newPlace.latitude = region.center.latitude
                newPlace.longitude = region.center.longitude
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
        withAnimation {
//            need FetchedResults to edit? set this in .onAppear
//            Does it work?? YES
//            Does it crash?? NO
//            **Need to deselect row after clicking on in List View
            place?.title = title
            place?.type = type.rawValue
            place?.url = url
            place?.phoneNumber = phoneNumber
//            place?.latitude = region.center.latitude
//            place?.longitude = region.center.longitude
            place?.notes = notes
            
            let newAddress = FullAddress(context: viewContext)
            
            if let existingAddress = place?.fullAddress {
                newAddress.id = existingAddress.id
            }

            newAddress.street = street
            newAddress.city = city
            newAddress.state = state
            newAddress.postalCode = postalCode
            newAddress.country = countryCode
            place?.fullAddress = newAddress
            
//            if !images.isEmpty {
//                let data = images[0].jpegData(compressionQuality: 0.8)
//                place?.images = data
//            }
            
            do {
                let imageData = images.map { $0.jpegData(compressionQuality: 0.8) }
                place?.images = try NSKeyedArchiver.archivedData(withRootObject: imageData, requiringSecureCoding: true)
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
}

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        EditView(selectedPlace: .constant(PlaceAnnotation().example), exitMapSearch: .constant(false))
    }
}
