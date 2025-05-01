//
//  CoreDataDependency.swift
//  ToDo
//
//  Created by Anton Kuznetsov on 28/04/2025.
//

import ComposableArchitecture
import CoreData

// MARK: - CoreData Dependency Wrapper for TCA

// This struct defines a dependency for common CoreData operations.
struct CoreDataDependency {
    var insert: (ReminderModel) -> Void
    var delete: (ReminderModel) -> Void
    var save: () throws -> Void
    var fetch: (NSFetchRequest<ReminderModel>) throws -> [ReminderModel]
    var createReminder: (_ title: String, _ createdAt: Date) -> ReminderModel
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
            createReminder: { title, createdAt in
                let model = ReminderModel(context: context)
                model.id = UUID()
                model.title = title
                model.createdAt = createdAt
                model.isCompleted = false
                return model
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
