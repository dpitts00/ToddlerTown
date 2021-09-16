//
//  PlaceDistances.swift
//  ToddlerTown
//
//  Created by Daniel Pitts on 9/16/21.
//

import Foundation

class PlaceDistances: ObservableObject {
    @Published var distances: [PlaceAnnotation: Int] = [:]
}
