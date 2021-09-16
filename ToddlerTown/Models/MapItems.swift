//
//  MapItems.swift
//  ToddlerTown
//
//  Created by Daniel Pitts on 9/16/21.
//

import MapKit

class MapItems: ObservableObject {
    @Published var mapItems: [MKMapItem] = []
    @Published var selectedItem = MKMapItem()
    static var example: [MKMapItem] = []
}
