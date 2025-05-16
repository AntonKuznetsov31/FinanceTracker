//
//  ToDoApp.swift
//  ToDo
//
//  Created by Anton Kuznetsov on 24/04/2025.
//

import SwiftUI
import ComposableArchitecture

@main
struct MyApp: App {
    
    let context = PersistenceController.shared.container.viewContext
    
    var body: some Scene {
        WindowGroup {
            withDependencies {
                $0.managedObjectContext = context
            } operation: {
                ReminderListView(
                    store: Store(
                        initialState: ReminderListReducer.State(),
                        reducer: { ReminderListReducer() }
                    )
                )
            }
            .environment(\.managedObjectContext, context) // keep it for possible SwiftUI needs
        }
    }
}
