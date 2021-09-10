//
//  CoreDataTestApp.swift
//  CoreDataTest
//
//  Created by Daniel Pitts on 7/14/21.
//

import SwiftUI

@main
struct ToddlerTownApp: App {
    @Environment(\.scenePhase) var scenePhase
    
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            SearchView()
                .onOpenURL(perform: { url in
                    let codablePlaces = ExportPlaces.shared.importPlaces(from: url)
                    
                    for place in codablePlaces {
                        ExportPlaces.shared.convertToPlaceAnnotation(place)
                    }
                })
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .onChange(of: scenePhase) { _ in
            persistenceController.save()
        }
    }
    

    
}
