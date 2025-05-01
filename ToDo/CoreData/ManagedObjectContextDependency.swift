//
//  ManagedObjectContextDependency.swift
//  ToDo
//
//  Created by Anton Kuznetsov on 28/04/2025.
//

import ComposableArchitecture
import CoreData

// MARK: - ManagedObjectContext as a dependency

private enum ManagedObjectContextKey: DependencyKey {
    static var liveValue: NSManagedObjectContext {
        PersistenceController.shared.container.viewContext
    }
}

extension DependencyValues {
    var managedObjectContext: NSManagedObjectContext {
        get { self[ManagedObjectContextKey.self] }
        set { self[ManagedObjectContextKey.self] = newValue }
    }
}
