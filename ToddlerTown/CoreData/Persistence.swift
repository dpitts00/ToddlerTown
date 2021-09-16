//
//  Persistence.swift
//  CoreDataTest
//
//  Created by Daniel Pitts on 7/14/21.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for i in 0..<10 {
            let place = PlaceAnnotation(context: viewContext)
            place.id = UUID()
            place.title = "Place \(i)"
            place.type = "Place Type"
            place.latitude = 43.16 + Double.random(in: -0.1...0.1)
            place.longitude = -89.37 + Double.random(in: -0.1...0.1)
            place.isFavorite = false
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            // incomplete
            print("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {

        container = NSPersistentCloudKitContainer(name: "ToddlerTown")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // incomplete
                print("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            }
        })
    }
    
    // MARK: save()
    
    func save() {
//        DispatchQueue.global().async {
//            
//        }
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
