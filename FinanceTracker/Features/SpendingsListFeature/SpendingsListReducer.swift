//
//  SpendingsListReducer.swift
//  FinanceTracker
//
//  Created by Anton Kuznetsov on 27/04/2025.
//

import ComposableArchitecture
import CoreData

// MARK: - Reducer: Handles Spendings list business logic

struct SpendingsListReducer: Reducer {
    
    @ObservableState
    struct State: Equatable {
        var spendings: [Spending] = []
        var showAlert: Bool = false
        var errorMessage: String?
        var isPresentingAddSpending = false
    }
    
    enum Action: Equatable {
        case loadSpendings // action to load data
        case spendingsLoaded([Spending]) // action when data have been received
        case addSpending(Decimal)
        case presentAddSpendingSheet
        case dismissAddSpendingSheet
        case deleteSpending(Spending)
        case errorOccurred(Error)
        
        static func == (lhs: Action, rhs: Action) -> Bool {
            switch (lhs, rhs) {
            case (.loadSpendings, .loadSpendings):
                return true
            case let (.spendingsLoaded(lhsSpendings), .spendingsLoaded(rhsSpendings)):
                return lhsSpendings == rhsSpendings
            case let (.addSpending(lhsSpending), .addSpending(rhsSpending)):
                return lhsSpending == rhsSpending
            case let (.deleteSpending(lhs), .deleteSpending(rhs)):
                return lhs == rhs
            case let (.errorOccurred(lhs), .errorOccurred(rhs)):
                return lhs.localizedDescription == rhs.localizedDescription
            default:
                return false
            }
        }
    }
    
    @Dependency(\.coreDataDependency) var coreDataDependency
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
                // Fetch all spendings from CoreData
            case .loadSpendings:
                return .run { send in
                    let request = NSFetchRequest<SpendingModel>(entityName: "SpendingModel")
                    do {
                        let fetchedModels = try coreDataDependency.fetch(request)
                        let spendings = fetchedModels.map { Spending(from: $0) }
                        await send(.spendingsLoaded(spendings))
                    } catch {
                        print("Fetch failed: \(error.localizedDescription)")
                        await send(.errorOccurred(error))
                    }
                }
                
                // Update state with fetched spendings
            case let .spendingsLoaded(spendings):
                state.spendings = spendings
                return .none
                
                // Add new spending
            case let .addSpending(amount):
                return .run { send in
                    _ = coreDataDependency.createSpending(amount)
                    try coreDataDependency.save()
                    await send(.loadSpendings)
                }
                
                // Handle new spending sheet
            case .presentAddSpendingSheet:
                state.isPresentingAddSpending = true
                return .none
                
            case .dismissAddSpendingSheet:
                state.isPresentingAddSpending = false
                return .none
                
                // Delete spending by ID if it exists in CoreData
            case let .deleteSpending(spending):
                return .run { send in
                    let request = NSFetchRequest<SpendingModel>(entityName: "SpendingModel")
                    request.predicate = NSPredicate(format: "id == %@", spending.id as CVarArg)
                    if let model = try coreDataDependency.fetch(request).first {
                        coreDataDependency.delete(model)
                        try coreDataDependency.save()
                    }
                    await send(.loadSpendings)
                }
                
            case let .errorOccurred(error):
                state.errorMessage = error.localizedDescription
                state.showAlert = true
                return .none
            }
        }
    }
}
