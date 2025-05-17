//
//  DateFormatter+Extension.swift
//  FinanceTracker
//
//  Created by Anton Kuznetsov on 17.05.2025.
//

import Foundation

public extension Date {
    func localized(in localized: String) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale.current
        let dateString = formatter.string(from: self)
        let message = String(format: NSLocalizedString(localized, comment: ""), dateString)
        return message
    }
}
