//
//  ReminderDatabase.swift
//  ToDo
//
//  Created by Anton Kuznetsov on 29/04/2025.
//

import ComposableArchitecture
import CoreData

public struct ReminderDatabase: DependencyKey {
    
    enum ReminderError: Error {
        case add
        case delete
        case save
    }
    
    public var fetchAll: @Sendable (NSFetchRequest<ReminderModel>) throws -> [ReminderModel]
    public var add: @Sendable (ReminderModel) throws -> Void
    public var delete: @Sendable (ReminderModel) throws -> Void
    public var save: @Sendable () throws -> Void
    
    public static var liveValue: Self {
        @Dependency(\.managedObjectContext) var context
        return Self(
            fetchAll: { request in
                try context.fetch(request)
            },
            add: { model in
                context.insert(model)
            },
            delete: { model in
                context.delete(model)
            },
            save: {
                if context.hasChanges {
                    try context.save()
                }
            }
        )
    }
}
