//
//  SpendingsListReducer.swift
//  FinanceTracker
//
//  Created by Anton Kuznetsov on 27/04/2025.
//

import ComposableArchitecture
import CoreData

// MARK: - Reducer: Handles Spendings list business logic

@Reducer
struct SpendingsListReducer {

    @ObservableState
    struct State: Equatable {
        var spendings: [Spending] = []
    }

    enum Action {
        case fetchSpendings
        case fetchResponse([Spending])
        case saveSpending
        case deleteSpending(Spending)
        case errorOccurred(Error)
    }

    @Dependency(\.coreDataDependency) var coreDataDependency

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            // Fetch all spendings from CoreData
            case .fetchSpendings:
                return .run { send in
                    let request = NSFetchRequest<SpendingModel>(entityName: "SpendingModel")
                    do {
                        let fetchedModels = try coreDataDependency.fetch(request)
                        let spendings = fetchedModels.map { Spending(from: $0) }
                        await send(.fetchResponse(spendings))
                    } catch {
                        print("Fetch failed: \(error.localizedDescription)")
                        await send(.errorOccurred(error))
                    }
                }
                
            // Update state with fetched spendings
            case let .fetchResponse(spendings):
                state.spendings = spendings
                return .none

            // Create and save a new spending
            case .saveSpending:
                return .run { send in
                    let model = coreDataDependency.createSpending("\(Date())")
                    coreDataDependency.insert(model)
                    
                    try coreDataDependency.save()
                    await send(.fetchSpendings)
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
                    await send(.fetchSpendings)
                }

            case .errorOccurred:
                return .none
            }
        }
    }
}
