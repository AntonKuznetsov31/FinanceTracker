//
//  ReminderModel.swift
//  ToDo
//
//  Created by Anton Kuznetsov on 24/04/2025.
//

import CoreData

// MARK: - Reminder Value Type (used in UI)

struct Reminder: Identifiable, Equatable {
    let id: UUID
    let title: String
    let isCompleted: Bool
    let createdAt: Date

    init(from model: ReminderModel) {
        self.id = model.id
        self.title = model.title
        self.isCompleted = model.isCompleted
        self.createdAt = model.createdAt
    }
}

// MARK: - CoreData Entity

public class ReminderModel: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var isCompleted: Bool
    @NSManaged public var createdAt: Date
    
    // Convenience init for manual creation (not used in reducer)
    convenience init(context: NSManagedObjectContext, title: String, isCompleted: Bool, createdAt: Date) {
        self.init(context: context)
        self.id = UUID()
        self.title = title
        self.isCompleted = isCompleted
        self.createdAt = createdAt
    }
}
