//
//  PlaceType.swift
//  ToddlerTown
//
//  Created by Daniel Pitts on 7/28/21.
//

import SwiftUI

enum PlaceType: String, CaseIterable {
    case all = "All"
    case parksAndNature = "Parks & Nature"
    case stores = "Stores"
    case restaurantsAndCafes = "Restaurants & Cafés"
    case attractions = "Attractions"
    case librariesAndMuseums = "Libraries & Museums"
    case friendsAndFamily = "Friends & Family"
    case favorites = "Favorites"
    
    func color() -> Color {
        switch self {
        case .all:
            return .ttRed
        case .parksAndNature:
            return .ttBlueGreen
        case .stores:
            return .ttGold
        case .restaurantsAndCafes:
            return .ttGold
        case .librariesAndMuseums:
            return .ttBlue
        case .attractions:
            return .ttRed
        case .friendsAndFamily:
            return .ttBlueGreen
        case .favorites:
            return .ttBlue
        }
        
    }
    
    func imageForType() -> Image {
        switch self {
        case .all:
            return Image(systemName: "mappin")
        case .parksAndNature:
            return Image(systemName: "leaf")
        case .stores:
            return Image(systemName: "cart")
        case .restaurantsAndCafes:
            return Image("coffee.cup")
        case .librariesAndMuseums:
            return Image(systemName: "text.book.closed")
        case .attractions:
            return Image(systemName: "ticket")
        case .friendsAndFamily:
            return Image(systemName: "person")
        case .favorites:
            return Image(systemName: "heart.fill")
        }
        

    }
    
}
