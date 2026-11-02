//
//  TransactionDTO.swift
//  ExpenseTracker
//
//  Created by Ateeq Ahmed on 29/10/26.
//  Data Transfer Object representing remote JSON contracts.
//

import Foundation

/// DTO mapping external JSON representation to internal domain structures.
///
/// External schema example:
/// ```json
/// {
///   "id": "txn-101",
///   "title": "Groceries",
///   "amount": 95.00,
///   "category": "Food & Dining",
///   "date": "2026-10-29T12:30:00Z",
///   "type": "expense",
///   "notes": null
/// }
/// ```
struct TransactionDTO: Codable, Sendable {
    let id: String
    let title: String
    let amount: Decimal
    let category: String
    let date: Date
    let type: TransactionType
    let notes: String?

    /// Converts the DTO into the clean domain entity.
    func toDomain() -> Transaction {
        Transaction(
            id: id,
            title: title,
            amount: amount,
            category: category,
            date: date,
            type: type,
            notes: notes
        )
    }

    /// Memberwise initializer for testing or construction.
    init(
        id: String,
        title: String,
        amount: Decimal,
        category: String,
        date: Date,
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

    /// Converts a domain entity to a DTO for network transport.
    init(from domain: Transaction) {
        self.id = domain.id
        self.title = domain.title
        self.amount = domain.amount
        self.category = domain.category
        self.date = domain.date
        self.type = domain.type
        self.notes = domain.notes
    }
}
