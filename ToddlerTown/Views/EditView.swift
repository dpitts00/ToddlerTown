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
//    @State private var nickname = ""
    @State private var address = ""
    @State private var notes = ""
    
    @State private var region = MKCoordinateRegion(center: CLLocationManager().location?.coordinate ?? MKPlaceAnnotation.example.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    @State private var userTrackingMode: MapUserTrackingMode = .none
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \PlaceAnnotation.title, ascending: true)],
        animation: .default) private var places: FetchedResults<PlaceAnnotation>
    
    @Binding var selectedPlace: MKPlaceAnnotation?
    @State private var place: PlaceAnnotation?
    
    @Binding var exitMapSearch: Bool?
    
    var fromAddressSearch = false
    
    var selectedPlaceTypeCases: [PlaceType] = [] + PlaceType.allCases.drop(while: {$0 == .all})
    
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
//            Text("Please write some info about this place!")
            TextField("Place name", text: $title)
                .autocapitalization(.words)
//            TextField("Nickname", text: $nickname)
//                .autocapitalization(.words)
            TextField("Address", text: $address)
                .textContentType(.fullStreetAddress)
            // verify address with Maps location (query?), returns CLPlacemark
            // "Unable to verify address"?
            // maybe an Alert to notify that address exists after verifying
            // save it as a string, with location coordinates
            // replace location coordinates in Place with those returned from address lookup
            // re-center the map at the location coordinates
            
            Picker("Place type", selection: $type) {
                ForEach(selectedPlaceTypeCases, id: \.self) { type in
                    Text(type.rawValue.localizedCapitalized)
                }
            }
            .onChange(of: type, perform: { _ in
                selectedPlace?.type = type
            })
            
//            TextField("Write a description of this place...", text: $notes)
//                .frame(height: 300)
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
                address = selectedPlace.address ?? ""
                if type == .all {
                    type = selectedPlace.type // FIX THIS
                }
                
                region = MKCoordinateRegion(center: selectedPlace.coordinate, span: MKCoordinateSpan(latitudeDelta: CLLocationDegrees(0.05), longitudeDelta: CLLocationDegrees(0.05)))
             
                if let place = places.first(where: { $0.title == title && $0.type == selectedPlace.type.rawValue && $0.latitude == selectedPlace.coordinate.latitude && $0.longitude == selectedPlace.coordinate.longitude } ) {
                    self.place = place
                    
                    notes = place.notes ?? ""
                    
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
                    
                    print(self.place?.title ?? "PlaceAnnotation.title == nil")
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
//            newPlace.nickname = nickname
            newPlace.address = address
            newPlace.type = type.rawValue
            newPlace.notes = notes
            
//            if !images.isEmpty {
//                let data = images[0].jpegData(compressionQuality: 0.8)
//                newPlace.images = data
//            }
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
            
            
            newPlace.isFavorite = false

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
//            place?.nickname = nickname
            place?.address = address
//            place?.latitude = region.center.latitude
//            place?.longitude = region.center.longitude
            place?.notes = notes
            
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
        EditView(selectedPlace: .constant(MKPlaceAnnotation.example), exitMapSearch: .constant(false))
    }
}
