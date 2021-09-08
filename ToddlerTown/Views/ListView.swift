//
//  ListView.swift
//  ToddlerTown
//
//  Created by Daniel Pitts on 9/7/21.
//

import SwiftUI
import CoreLocation

struct ListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var places: [PlaceAnnotation]
    @Binding var redrawMap: Bool
    
    var body: some View {
        List {
            ForEach(places.sorted(by: { distanceFrom(place: $0) < distanceFrom(place: $1) } )) { place in
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
//                                        .lineLimit(0)
                            
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
            .onDelete { indexSet in
                deletePlaces(offsets: indexSet)
            }
        } // end List
    }
    
    func getLocation() -> CLLocation? {
        return CLLocationManager.shared.location
    }
    
    func distanceFrom(place: PlaceAnnotation) -> Double {
        if getLocation() != nil && getSelectedPlaceLocation(for: place) != nil {
            return (getLocation()!.distance(from: getSelectedPlaceLocation(for: place)!) / 1600)
        }
        return 0
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
        let placeTypeColors: [String: Color] = ["all": Color.ttRed, "favorites": Color.ttBlue, "parks": Color.ttRed, "cafe": Color.ttGold, "attraction": Color.ttBlueGreen, "friends": Color.ttGold, "libraries": Color.ttBlueGreen, "store": Color.ttBlue]
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
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView(places: .constant([]), redrawMap: .constant(true))
    }
}
