//
//  SpendingModel.swift
//  FinanceTracker
//
//  Created by Anton Kuznetsov on 24/04/2025.
//

import CoreData

// MARK: - Spending Value Type (used in UI)

struct Spending: Identifiable, Equatable {
    let id: UUID
    let amount: Decimal
    let createdAt: Date
    
    init(from model: SpendingModel) {
        self.id = model.id
        self.amount = model.amount.decimalValue
        self.createdAt = model.createdAt
    }
    
    init(amount: Decimal) {
        self.id = UUID()
        self.amount = amount
        self.createdAt = Date()
    }
}

// MARK: - CoreData Entity

@objc(SpendingModel)
public class SpendingModel: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var amount: NSDecimalNumber
    @NSManaged public var createdAt: Date
    
    // Convenience init for manual creation (not used in reducer)
    convenience init(context: NSManagedObjectContext, amount: Decimal, createdAt: Date) {
        self.init(context: context)
        self.id = UUID()
        self.amount = NSDecimalNumber(decimal: amount)
        self.createdAt = createdAt
    }
}
