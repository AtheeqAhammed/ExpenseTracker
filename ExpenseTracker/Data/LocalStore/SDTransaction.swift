//
//  SDTransaction.swift
//  ExpenseTracker
//
//  Created by Ateeq Ahmed on 29/10/26.
//  SwiftData persistent model representing a transaction stored in the local SQLite database.
//

import Foundation
import SwiftData

/// SwiftData persistent entity for transactions.
///
/// Keeps persistence annotations isolated to the Data layer
/// without polluting the pure Domain `Transaction` entity.
@Model
final class SDTransaction {
    /// Unique identifier matching domain and backend IDs.
    @Attribute(.unique) var id: String

    /// Title of the transaction.
    var title: String

    /// Monetary amount stored as Decimal for exact precision.
    var amount: Decimal

    /// Category name.
    var category: String

    /// Transaction timestamp.
    var date: Date

    /// Raw string for `TransactionType` ("expense" or "income").
    var typeRaw: String

    /// Optional notes.
    var notes: String?

    /// Local creation/import timestamp for ordering.
    var createdAt: Date

    init(
        id: String,
        title: String,
        amount: Decimal,
        category: String,
        date: Date,
        typeRaw: String,
        notes: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.amount = amount
        self.category = category
        self.date = date
        self.typeRaw = typeRaw
        self.notes = notes
        self.createdAt = createdAt
    }

    /// Converts this persistent model to an immutable domain `Transaction`.
    func toDomain() -> Transaction {
        Transaction(
            id: id,
            title: title,
            amount: amount,
            category: category,
            date: date,
            type: TransactionType(rawValue: typeRaw) ?? .expense,
            notes: notes
        )
    }

    /// Convenience initializer mapping from domain entity.
    convenience init(from domain: Transaction) {
        self.init(
            id: domain.id,
            title: domain.title,
            amount: domain.amount,
            category: domain.category,
            date: domain.date,
            typeRaw: domain.type.rawValue,
            notes: domain.notes
        )
    }
}
