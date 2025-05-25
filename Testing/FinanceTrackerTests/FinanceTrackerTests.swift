//
//  FinanceTrackerTests.swift
//  FinanceTrackerTests
//
//  Created by Anton Kuznetsov on 24/04/2025.
//

@testable import FinanceTracker
import XCTest
import ComposableArchitecture
import Testing
import CoreData

final class SpendingsListReducerTests: XCTestCase {
    
    func makeInMemoryPersistentContainer() -> NSPersistentContainer {
        let container = NSPersistentContainer(name: "DataModel")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType // temp data model will be deleted immediately after test is done
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { (desc, error) in
            if let error = error {
                fatalError("Failed to load in-memory store: \(error)")
            }
        }
        return container
    }
    
    func testFetchSpendingsSuccess() async {
        let spending = Spending(amount: 1.0)
        
        let container = makeInMemoryPersistentContainer()
        let context = container.viewContext
        
        let store = await TestStore(initialState: SpendingsListReducer.State(), reducer: { SpendingsListReducer() }) {
            $0.coreDataDependency.fetch = { _ in
                [SpendingModelMock(from: spending, context: context)]
            }
        }

        await store.send(SpendingsListReducer.Action.loadSpendings)
        await store.receive(SpendingsListReducer.Action.spendingsLoaded([spending])) {
            $0.spendings = [spending]
        }
    }

    func testSaveSpendingSuccess() async {
        let container = makeInMemoryPersistentContainer()
        let context = container.viewContext

        let store = await TestStore(initialState: SpendingsListReducer.State(), reducer: { SpendingsListReducer() }) {
            $0.coreDataDependency.createSpending = { _ in
                SpendingModelMock(from: Spending(amount: 1.0), context: context)
            }
            $0.coreDataDependency.save = {}
            $0.coreDataDependency.fetch = { _ in [] }
        }

        await store.send(SpendingsListReducer.Action.addSpending(1.0))
        await store.receive(SpendingsListReducer.Action.loadSpendings)
        await store.receive(SpendingsListReducer.Action.spendingsLoaded([]))
        
        let request = NSFetchRequest<SpendingModel>(entityName: "SpendingModel")
        let saved = try! context.fetch(request)
        XCTAssertEqual(saved.count, 1)
    }
}

final class SpendingModelMock: SpendingModel {
    init(from spending: Spending, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "SpendingModel", in: context)!
        super.init(entity: entity, insertInto: context)
        self.setValue(spending.id, forKey: "id")
        self.setValue(spending.amount, forKey: "amount")
        self.setValue(spending.createdAt, forKey: "createdAt")
    }

    required override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
}
