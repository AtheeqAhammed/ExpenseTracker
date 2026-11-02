//
//  FilterTransactionsUseCase.swift
//  ExpenseTracker
//
//  Created by Ateeq Ahmed on 29/10/26.
//  Use Case: Encapsulates search query, category, and type filtering rules.
//

import Foundation

/// Filter criteria parameters.
struct TransactionFilterCriteria: Equatable, Sendable {
    var searchText: String = ""
    var type: TransactionType? = nil
    var category: String? = nil
    var startDate: Date? = nil
    var endDate: Date? = nil
}

/// Sort criteria for transactions list.
enum TransactionSortOption: String, CaseIterable, Identifiable, Sendable {
    case newestFirst = "Newest"
    case oldestFirst = "Oldest"
    case highestAmount = "Highest Amount"
    case lowestAmount = "Lowest Amount"

    var id: String { rawValue }
}

/// Business rule applying multi-attribute filtering and ordering on transactions.
struct FilterTransactionsUseCase: Sendable {

    /// Filters and sorts a collection of transactions.
    func execute(
        transactions: [Transaction],
        criteria: TransactionFilterCriteria,
        sortOption: TransactionSortOption = .newestFirst
    ) -> [Transaction] {
        var result = transactions

        // Search text matching title, category, or notes
        let trimmedQuery = criteria.searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !trimmedQuery.isEmpty {
            result = result.filter { txn in
                txn.title.lowercased().contains(trimmedQuery) ||
                txn.category.lowercased().contains(trimmedQuery) ||
                (txn.notes?.lowercased().contains(trimmedQuery) ?? false)
            }
        }

        // Filter by Transaction Type
        if let type = criteria.type {
            result = result.filter { $0.type == type }
        }

        // Filter by Category
        if let category = criteria.category, !category.isEmpty {
            result = result.filter { $0.category.caseInsensitiveCompare(category) == .orderedSame }
        }

        // Filter by Date range
        if let start = criteria.startDate {
            result = result.filter { $0.date >= start }
        }
        if let end = criteria.endDate {
            result = result.filter { $0.date <= end }
        }

        // Sorting
        switch sortOption {
        case .newestFirst:
            result.sort { $0.date > $1.date }
        case .oldestFirst:
            result.sort { $0.date < $1.date }
        case .highestAmount:
            result.sort { $0.amount > $1.amount }
        case .lowestAmount:
            result.sort { $0.amount < $1.amount }
        }

        return result
    }
}
