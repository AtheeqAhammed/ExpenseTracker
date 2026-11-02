//
//  Transaction.swift
//  ExpenseTracker
//
//  Created by Ateeq Ahmed on 29/10/26.
//  Created for Clean Architecture Expense Tracker.
//

import Foundation

/// Defines whether a financial transaction is an outflow (expense) or inflow (income).
enum TransactionType: String, Equatable, Codable, CaseIterable, Sendable {
    case expense
    case income

    /// Capitalized display name for UI presentation
    var displayName: String {
        switch self {
        case .expense: return "Expense"
        case .income: return "Income"
        }
    }
}

/// The core domain entity representing a financial transaction.
///
/// Clean Architecture principles dictate that this model remains pure
/// and independent of external frameworks (e.g. SwiftData or URLSession DTOs).
struct Transaction: Identifiable, Equatable, Hashable, Sendable {
    /// Unique identifier for the transaction.
    /// Uses String to accommodate both backend-generated IDs (e.g., "txn-101")
    /// and client-generated UUIDs.
    let id: String

    /// Short human-readable title describing the transaction (e.g. "Groceries", "Salary").
    let title: String

    /// Monetary amount of the transaction.
    /// `Decimal` is chosen instead of `Double` or `Float` to prevent precision errors
    /// inherent in IEEE-754 floating-point financial computations.
    let amount: Decimal

    /// Category name classifying the transaction (e.g. "Food & Dining", "Shopping").
    let category: String

    /// Date and time when the transaction took place.
    let date: Date

    /// Outflow (expense) or Inflow (income).
    let type: TransactionType

    /// Optional extra details, merchant notes, or remarks.
    let notes: String?

    /// Initializes a new domain Transaction instance.
    ///
    /// - Parameters:
    ///   - id: Unique transaction ID. Defaults to a new UUID string.
    ///   - title: Title or description of the transaction.
    ///   - amount: Currency amount represented as `Decimal`.
    ///   - category: Category classification.
    ///   - date: Timestamp of the transaction.
    ///   - type: Type of transaction (.expense or .income).
    ///   - notes: Optional additional context or notes.
    init(
        id: String = UUID().uuidString,
        title: String,
        amount: Decimal,
        category: String,
        date: Date = Date(),
        type: TransactionType,
        notes: String? = nil
    ) {
        self.id = id
        self.title = title
        self.amount = amount
        self.category = category
        self.date = date
        self.type = type
        self.notes = notes
    }
}
