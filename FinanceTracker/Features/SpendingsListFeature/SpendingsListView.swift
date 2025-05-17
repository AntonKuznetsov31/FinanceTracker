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
    @State private var isPresentedAddSheet = false
    @State private var spendingAmount: String = ""
    
    init(viewStore: StoreOf<SpendingsListReducer>) {
        self.viewStore = viewStore
    }
    
    var body: some View {
        mainView
        .onAppear {
            viewStore.send(.loadSpendings)
        }
    }
    
    var mainView: some View {
        NavigationView {
            List {
                ForEach(viewStore.state.spendings) { spending in
                    NavigationLink {
                        Text("\(spending.createdAt.localized(in: "spending_at_title"))")
                    } label: {
                        Text("$\(spending.amount) ")
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
                toolbarContent
            }
            .sheet(isPresented: Binding(
                get: { viewStore.isPresentingAddSpending },
                set: { isPresented in
                    viewStore.send(isPresented ? .presentAddSpendingSheet : .dismissAddSpendingSheet)
                }
            )) {
                addSpendingView
            }
        }
    }
    
    var addSpendingView: some View {
        VStack(spacing: 20) {
            Text("enter_amount_title")
                .font(.headline)
            
            TextField("amount_title", text: $spendingAmount)
                .keyboardType(.decimalPad)
                .padding()
                .cornerRadius(10)
                .padding(.horizontal)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.blue, lineWidth: 2)
                )
            
            HStack() {
                Button("cancel_button_title") {
                    viewStore.send(.dismissAddSpendingSheet)
                }
                .foregroundColor(.red)
                
                Spacer()
                
                Button("ok_button_title") {
                    if let amount = Decimal(string: spendingAmount.replacingOccurrences(of: ",", with: ".")) {
                        viewStore.send(.addSpending(amount))
                    }
                    viewStore.send(.dismissAddSpendingSheet)
                }
                .disabled(Decimal(string: spendingAmount.replacingOccurrences(of: ",", with: ".")) == nil)
            }
            .padding(.horizontal)
        }
        .padding()
    }
    
    var toolbarContent: some ToolbarContent {
        return Group {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
            ToolbarItem {
                Button(action: {
                    viewStore.send(.presentAddSpendingSheet)
                }) {
                    Label("add_spending_title", systemImage: "plus")
                }
            }
        }
    }
}
