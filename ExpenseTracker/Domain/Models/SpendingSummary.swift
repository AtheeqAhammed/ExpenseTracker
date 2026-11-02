//
//  SpendingSummary.swift
//  ExpenseTracker
//
//  Created by Ateeq Ahmed on 29/10/26.
//  Domain model representing calculated analytics and financial summaries.
//

import Foundation

/// High-level financial balance and spending metrics for a specified period.
struct SpendingSummary: Equatable, Sendable {
    /// Total inflow during the period.
    let totalIncome: Decimal

    /// Total outflow during the period.
    let totalExpense: Decimal

    /// Inflow minus outflow.
    var netBalance: Decimal {
        totalIncome - totalExpense
    }

    /// Average spending per day within the period.
    let averageDailySpending: Decimal

    /// Most spent category name, or nil if no expenses recorded.
    let topSpendingCategory: String?

    /// Number of transactions recorded.
    let transactionCount: Int

    static let empty = SpendingSummary(
        totalIncome: 0,
        totalExpense: 0,
        averageDailySpending: 0,
        topSpendingCategory: nil,
        transactionCount: 0
    )
}

/// Aggregated spending breakdown for a specific category.
struct CategoryBreakdown: Identifiable, Equatable, Sendable {
    var id: String { category }

    let category: String
    let totalAmount: Decimal
    let percentage: Double // 0.0 - 1.0
    let transactionCount: Int
}

/// A single data point representing total spending for a specific day/date (for Swift Charts).
struct DailySpendingPoint: Identifiable, Equatable, Sendable {
    var id: Date { date }

    let date: Date
    let amount: Decimal
    let label: String
}
