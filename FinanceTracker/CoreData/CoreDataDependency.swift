//
//  CoreDataDependency.swift
//  FinanceTracker
//
//  Created by Anton Kuznetsov on 28/04/2025.
//

import ComposableArchitecture
import CoreData

// MARK: - CoreData Dependency Wrapper for TCA

// This struct defines a dependency for common CoreData operations.
struct CoreDataDependency {
    var insert: (SpendingModel) -> Void
    var delete: (SpendingModel) -> Void
    var save: () throws -> Void
    var fetch: (NSFetchRequest<SpendingModel>) throws -> [SpendingModel]
    var createSpending: (_ title: String) -> SpendingModel
}

// This key allows TCA to resolve CoreDataDependency through DependencyValues
private enum CoreDataDependencyKey: DependencyKey {
    static var liveValue: CoreDataDependency {
        @Dependency(\.managedObjectContext) var context
        return CoreDataDependency(
            insert: { model in
                context.insert(model)
            },
            delete: { model in
                context.delete(model)
            },
            save: {
                if context.hasChanges {
                    try context.save()
                }
            },
            fetch: { request in
                try context.fetch(request)
            },
            createSpending: { title in
                SpendingModel(context: context, title: title, isCompleted: false, createdAt: Date())
            }
        )
    }
}


// Expose the CoreDataDependency through TCA DependencyValues
extension DependencyValues {
    var coreDataDependency: CoreDataDependency {
        get { self[CoreDataDependencyKey.self] }
        set { self[CoreDataDependencyKey.self] = newValue }
    }
}
