//
//  PlaceType.swift
//  ToddlerTown
//
//  Created by Daniel Pitts on 7/28/21.
//

import SwiftUI

enum PlaceType: String, CaseIterable {
    case all, park, trail, beach, store, restaurant, cafe, attraction, library, museum, friends, family, other
    
    func color() -> UIColor {
        
        return .systemRed
    }
    
    func imageForType() -> Image {
        switch self {
        case .all:
            return Image(systemName: "mappin")
        case .park, .beach, .trail:
            return Image(systemName: "leaf")
        case .store:
            return Image(systemName: "cart")
        case .restaurant:
            return Image(systemName: "rectangle.roundedtop")
        case .cafe:
            return Image(systemName: "rectangle.roundedbottom")
        case .library:
            return Image(systemName: "text.book.closed")
        case .museum, .attraction:
            return Image(systemName: "ticket")
        case .friends, .family:
            return Image(systemName: "person")
        default:
            return Image(systemName: "mappin")
        }
    }
    
}
