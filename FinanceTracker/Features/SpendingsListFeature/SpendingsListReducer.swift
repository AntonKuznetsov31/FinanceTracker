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
    }
    
    enum Action: Equatable {
        case loadSpendings // action to load data
        case spendingsLoaded([Spending]) // action when data have been received
        case saveSpending
        case deleteSpending(Spending)
        case errorOccurred(Error)
        
        static func == (lhs: Action, rhs: Action) -> Bool {
            switch (lhs, rhs) {
            case (.loadSpendings, .loadSpendings),
                (.saveSpending, .saveSpending):
                return true
            case let (.spendingsLoaded(lhsSpendings), .spendingsLoaded(rhsSpendings)):
                return lhsSpendings == rhsSpendings
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
                
                // Create and save a new spending
            case .saveSpending:
                return .run { send in
                    let model = coreDataDependency.createSpending(1.0)
                    coreDataDependency.insert(model)
                    
                    try coreDataDependency.save()
                    await send(.loadSpendings)
                }
                
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
