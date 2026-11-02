//
//  CurrencyFormatter.swift
//  ExpenseTracker
//
//  Created by Ateeq Ahmed on 29/10/26.
//  Utilities for formatting financial amounts using exact Decimal precision.
//

import Foundation

/// Formats decimal values into standardized localized currency strings.
enum CurrencyFormatter {
    private static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter
    }()

    /// Formats a Decimal value as currency (e.g. "$125.50").
    static func format(_ amount: Decimal) -> String {
        let nsDecimal = NSDecimalNumber(decimal: amount)
        return formatter.string(from: nsDecimal) ?? "$\(amount)"
    }

    /// Formats an amount with an explicit sign prefix (+ for income, - for expense).
    static func formatSigned(_ amount: Decimal, type: TransactionType) -> String {
        let formatted = format(amount)
        switch type {
        case .income:
            return "+\(formatted)"
        case .expense:
            return "-\(formatted)"
        }
    }
}
