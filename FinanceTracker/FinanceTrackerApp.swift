//
//  FinanceTrackerApp.swift
//  FinanceTracker
//
//  Created by Anton Kuznetsov on 24/04/2025.
//

import SwiftUI
import ComposableArchitecture

@main
struct FinanceTrackerApp: App {
    
    let context = PersistenceController.shared.container.viewContext
    
    var body: some Scene {
        WindowGroup {
            withDependencies {
                $0.managedObjectContext = context
            } operation: {
                SpendingsListView(
                    viewStore: Store(
                        initialState: SpendingsListReducer.State(),
                        reducer: { SpendingsListReducer() }
                    )
                )
            }
            .environment(\.managedObjectContext, context) // keep it for possible SwiftUI needs
        }
    }
}
