//
//  Item.swift
//  ToDo
//
//  Created by Anton Kuznetsov on 24/04/2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
