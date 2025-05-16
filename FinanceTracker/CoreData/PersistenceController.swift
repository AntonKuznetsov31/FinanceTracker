//
//  PersistenceController.swift
//  FinanceTracker
//
//  Created by Anton Kuznetsov on 28/04/2025.
//

import CoreData

// MARK: - CoreData Persistence Layer

// Sets up Core Data stack with NSPersistentContainer
struct PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unresolved error \(error.localizedDescription)")
            }
        }
    }
}
