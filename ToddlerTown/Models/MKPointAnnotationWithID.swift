//
//  MKPointAnnotationWithID.swift
//  CoreDataTest
//
//  Created by Daniel Pitts on 7/18/21.
//

import SwiftUI
import MapKit

class MKPointAnnotationWithID: MKPointAnnotation {
    let id: UUID
    let type: String
    
    init(id: UUID, type: String) {
        self.id = id
        self.type = type
    }
}


