//
//  CurrencyFormatter.swift
//  ExpenseTracker
//
//  Utilities for formatting financial amounts using exact Decimal precision and user-selected currency.
//

import Foundation

/// Formats decimal values into standardized localized currency strings.
enum CurrencyFormatter {
    private static var activeCurrency: AppCurrency = .inr

    /// Updates the global currency formatting preference.
    static func updateCurrency(_ currency: AppCurrency) {
        activeCurrency = currency
    }

    /// Current active currency symbol.
    static var currentSymbol: String {
        activeCurrency.symbol
    }

    /// Formats a Decimal value as currency according to the selected currency.
    ///
    /// - Parameters:
    ///   - amount: Decimal amount to format.
    ///   - currency: Optional override currency; if nil, uses the active `AppCurrency`.
    /// - Returns: Formatted currency string (e.g. "₹125.50" or "$125.50").
    static func format(_ amount: Decimal, currency: AppCurrency? = nil) -> String {
        let selected = currency ?? activeCurrency
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: selected.localeIdentifier)
        formatter.currencyCode = selected.code
        formatter.currencySymbol = selected.symbol
        formatter.maximumFractionDigits = selected == .jpy ? 0 : 2
        formatter.minimumFractionDigits = selected == .jpy ? 0 : 2

        let nsDecimal = NSDecimalNumber(decimal: amount)
        if let formatted = formatter.string(from: nsDecimal) {
            return formatted
        }
        return "\(selected.symbol)\(amount)"
    }

    /// Formats an amount with an explicit sign prefix (+ for income, - for expense).
    static func formatSigned(_ amount: Decimal, type: TransactionType, currency: AppCurrency? = nil) -> String {
        let formatted = format(amount, currency: currency)
        switch type {
        case .income:
            return "+\(formatted)"
        case .expense:
            return "-\(formatted)"
        }
    }
}
