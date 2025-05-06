//
//  ReminderListReducer.swift
//  ToDo
//
//  Created by Anton Kuznetsov on 27/04/2025.
//

import ComposableArchitecture
import CoreData

// MARK: - Reducer: Handles Reminder list business logic

@Reducer
struct ReminderListReducer {

    @ObservableState
    struct State: Equatable {
        var reminders: [Reminder] = []
    }

    enum Action {
        case fetchReminders
        case fetchResponse([Reminder])
        case saveReminder
        case deleteReminder(Reminder)
        case errorOccurred(Error)
    }

    @Dependency(\.coreDataDependency) var coreDataDependency

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            // Fetch all reminders from CoreData
            case .fetchReminders:
                return .run { send in
                    let request = NSFetchRequest<ReminderModel>(entityName: "ReminderModel")
                    do {
                        let fetchedModels = try coreDataDependency.fetch(request)
                        let reminders = fetchedModels.map { Reminder(from: $0) }
                        await send(.fetchResponse(reminders))
                    } catch {
                        print("Fetch failed: \(error.localizedDescription)")
                        await send(.errorOccurred(error))
                    }
                }
                
            // Update state with fetched reminders
            case let .fetchResponse(reminders):
                state.reminders = reminders
                return .none

            // Create and save a new reminder
            case .saveReminder:
                return .run { send in
                    let model = coreDataDependency.createReminder("\(Date())")
                    coreDataDependency.insert(model)
                    
                    try coreDataDependency.save()
                    await send(.fetchReminders)
                }

            // Delete reminder by ID if it exists in CoreData
            case let .deleteReminder(reminder):
                return .run { send in
                    let request = NSFetchRequest<ReminderModel>(entityName: "ReminderModel")
                    request.predicate = NSPredicate(format: "id == %@", reminder.id as CVarArg)
                    if let model = try coreDataDependency.fetch(request).first {
                        coreDataDependency.delete(model)
                        try coreDataDependency.save()
                    }
                    await send(.fetchReminders)
                }

            case .errorOccurred:
                return .none
            }
        }
    }
}
