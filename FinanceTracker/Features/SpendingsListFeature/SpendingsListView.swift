//
//  SpendingsListView.swift
//  FinanceTracker
//
//  Created by Anton Kuznetsov on 24/04/2025.
//

import ComposableArchitecture
import SwiftUI

// MARK: - Spendings List UI

struct SpendingsListView: View {
    
    @Bindable private var viewStore: StoreOf<SpendingsListReducer>
    
    init(viewStore: StoreOf<SpendingsListReducer>) {
        self.viewStore = viewStore
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewStore.state.spendings) { spending in
                    NavigationLink {
                        Text("Spending at \(spending.createdAt, format: Date.FormatStyle(date: .numeric, time: .standard))")
                    } label: {
                        Text(spending.createdAt, format: Date.FormatStyle(date: .numeric, time: .standard))
                    }
                }
                .onDelete { indexSet in
                    indexSet.forEach { index in
                        let spending = viewStore.state.spendings[index]
                        viewStore.send(.deleteSpending(spending))
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: {
                        viewStore.send(.saveSpending)
                    }) {
                        Label("Add spending", systemImage: "plus")
                    }
                }
            }
        }
        .onAppear {
            viewStore.send(.fetchSpendings)
        }
    }
}
