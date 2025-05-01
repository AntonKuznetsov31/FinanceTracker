//
//  ReminderListView.swift
//  ToDo
//
//  Created by Anton Kuznetsov on 24/04/2025.
//

import ComposableArchitecture
import SwiftUI

// MARK: - Reminder List UI

struct ReminderListView: View {
    
    @Bindable private var store: StoreOf<ReminderListReducer>
    
    init(store: StoreOf<ReminderListReducer>) {
        self.store = store
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(store.state.reminders) { reminder in
                    NavigationLink {
                        Text("Reminder at \(reminder.createdAt, format: Date.FormatStyle(date: .numeric, time: .standard))")
                    } label: {
                        Text(reminder.createdAt, format: Date.FormatStyle(date: .numeric, time: .standard))
                    }
                }
                .onDelete { indexSet in
                    indexSet.forEach { index in
                        let reminder = store.state.reminders[index]
                        store.send(.deleteReminder(reminder))
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: {
                        store.send(.saveReminder)
                    }) {
                        Label("Add Reminder", systemImage: "plus")
                    }
                }
            }
        }
        .onAppear {
            store.send(.fetchReminders)
        }
    }
}
