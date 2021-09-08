//
//  ExportPlaces.swift
//  ToddlerTown
//
//  Created by Daniel Pitts on 9/7/21.
//

import SwiftUI

class ExportPlaces {
//    let persistenceController = PersistenceController.shared
    let viewContext = PersistenceController.shared.container.viewContext
    
    @FetchRequest(
        sortDescriptors: [],
        animation: .default) private var places: FetchedResults<PlaceAnnotation>
    
    static let shared = ExportPlaces()
    
    static let fileExtension = "ttplaces"
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    func convertToCodable(_ placeAnnotation: PlaceAnnotation) -> CodablePlaceAnnotation? {
        if let fullAddress = placeAnnotation.fullAddress,
           let images = placeAnnotation.images {
            let codableAddress = CodableFullAddress(
            city: fullAddress.city ?? "",
            country: fullAddress.country ?? "",
            id: fullAddress.id ?? UUID(),
            isoCountryCode: fullAddress.isoCountryCode ?? "",
            postalCode: fullAddress.postalCode ?? "",
            state: fullAddress.state ?? "",
            street: fullAddress.street ?? "",
            subAdministrativeArea: fullAddress.subAdministrativeArea ?? "",
            subLocality: fullAddress.subLocality ?? "")
            
            let codablePlaceAnnotation = CodablePlaceAnnotation(
                id: placeAnnotation.id ?? UUID(),
                images: images,
                address: placeAnnotation.address ?? "",
                fullAddress: codableAddress,
                isFavorite: placeAnnotation.isFavorite,
                latitude: placeAnnotation.latitude,
                longitude: placeAnnotation.longitude,
                notes: placeAnnotation.notes ?? "",
                phoneNumber: placeAnnotation.phoneNumber ?? "",
                title: placeAnnotation.title ?? "",
                type: placeAnnotation.type ?? "",
                url: placeAnnotation.url ?? "")
            
            return codablePlaceAnnotation
        }
        return nil
    }
        
    func getPlacesURL() -> URL {
        return URL(fileURLWithPath: "placesFile", relativeTo: documentsDirectory).appendingPathExtension(ExportPlaces.fileExtension)
    }
    
    func savePlacesToDisk(places: [PlaceAnnotation]) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        if !places.isEmpty {
            let codablePlaces = places.filter( { $0.type != "Friends & Family" } ).compactMap(convertToCodable)
            let encodedPlaces = try? encoder.encode(codablePlaces)
            try? encodedPlaces?.write(to: getPlacesURL())
            print(codablePlaces.count)
            print(getPlacesURL())
        }
    }
    
    
    func loadPlacesFromDisk() -> [PlaceAnnotation] {
        
        return []
    }
    
    func importPlaces(from url: URL) -> [CodablePlaceAnnotation] {
        
        let decoder = JSONDecoder()
        
        if let data = try? Data(contentsOf: url) {
            if let decodedPlaces = try? decoder.decode([CodablePlaceAnnotation].self, from: data) {
                return decodedPlaces
            }
        }
        return []
    }
    
    func convertToPlaceAnnotation(_ annotation: CodablePlaceAnnotation) {
        print(annotation.title)
        if let matchingPlace = places.first(where: { $0.title == annotation.title } ) {
            if matchingPlace.latitude == annotation.latitude && matchingPlace.longitude == annotation.longitude {
                return
            }
        }
        
        let newPlace = PlaceAnnotation(context: viewContext)
        newPlace.id = annotation.id
        newPlace.title = annotation.title
        newPlace.type = annotation.type
        newPlace.notes = annotation.notes
        newPlace.isFavorite = false
        newPlace.phoneNumber = annotation.phoneNumber
        newPlace.url = annotation.url
        newPlace.latitude = annotation.latitude
        newPlace.longitude = annotation.longitude
        newPlace.address = annotation.address // unneeded
//            newPlace.imageURLs = annotation.imageURLs // add back in later for remote URLs
        
        newPlace.images = annotation.images
        
        let fullAddress = annotation.fullAddress
        
        let newAddress = FullAddress(context: viewContext)
        newAddress.id = fullAddress.id
        newAddress.street = fullAddress.street
        newAddress.city = fullAddress.city
        newAddress.state = fullAddress.state
        newAddress.postalCode = fullAddress.postalCode
        newAddress.country = fullAddress.country
        newAddress.isoCountryCode = fullAddress.isoCountryCode
        newAddress.subLocality = fullAddress.subLocality
        newAddress.subAdministrativeArea = fullAddress.subAdministrativeArea
        
        newPlace.fullAddress = newAddress
        newAddress.placeAnnotation = newPlace
        
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

struct CodablePlaceAnnotation: Codable {
    let id: UUID
    let images: Data
    let address: String
    let fullAddress: CodableFullAddress
    let isFavorite: Bool
    let latitude: Double
    let longitude: Double
    let notes: String
    let phoneNumber: String
    let title: String
    let type: String
    let url: String
}

struct CodableFullAddress: Codable {
    let city: String
    let country: String
    let id: UUID
    let isoCountryCode: String
    let postalCode: String
    let state: String
    let street: String
    let subAdministrativeArea: String
    let subLocality: String
}
