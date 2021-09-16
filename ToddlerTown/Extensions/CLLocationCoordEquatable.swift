//
//  CLLocationCoordEquatable.swift
//  ToddlerTown
//
//  Created by Daniel Pitts on 9/6/21.
//

import Foundation
import CoreLocation

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
