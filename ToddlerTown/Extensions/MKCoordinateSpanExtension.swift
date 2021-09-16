//
//  MKCoordinateSpanExtension.swift
//  ToddlerTown
//
//  Created by Daniel Pitts on 9/16/21.
//

import MapKit

extension MKCoordinateSpan {
    static func + (lhs: MKCoordinateSpan, rhs: MKCoordinateSpan) -> MKCoordinateSpan {
        return MKCoordinateSpan(latitudeDelta: lhs.latitudeDelta + rhs.latitudeDelta, longitudeDelta: lhs.longitudeDelta + rhs.longitudeDelta)
    }
    
    static func * (lhs: MKCoordinateSpan, rhs: Double) -> MKCoordinateSpan {
        return MKCoordinateSpan(latitudeDelta: Double(lhs.latitudeDelta) * rhs, longitudeDelta: Double(lhs.longitudeDelta) * rhs)
    }
    
    // is this right??
    static func += (lhs: inout MKCoordinateSpan, rhs: MKCoordinateSpan) {
        lhs = lhs + rhs
    }
}
