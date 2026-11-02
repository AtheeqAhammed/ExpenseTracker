//
//  CalculateSpendingSummaryUseCase.swift
//  ExpenseTracker
//
//  Created by Ateeq Ahmed on 29/10/26.
//  Use Case: Calculates high-level metrics (income, expenses, balance, daily average).
//

import Foundation

/// Encapsulates the business rule for computing financial summaries across transactions.
struct CalculateSpendingSummaryUseCase: Sendable {

    /// Executes the calculation over a list of transactions for a specific date range.
    ///
    /// - Parameters:
    ///   - transactions: List of domain transactions.
    ///   - calendar: Calendar used for date component math. Defaults to `.current`.
    /// - Returns: A calculated `SpendingSummary`.
    func execute(
        transactions: [Transaction],
        calendar: Calendar = .current
    ) -> SpendingSummary {
        guard !transactions.isEmpty else {
            return .empty
        }

        var totalIncome: Decimal = 0
        var totalExpense: Decimal = 0
        var categoryExpenseMap: [String: Decimal] = [:]

        var earliestExpenseDate: Date?
        var latestExpenseDate: Date?

        for txn in transactions {
            switch txn.type {
            case .income:
                totalIncome += txn.amount
            case .expense:
                totalExpense += txn.amount
                categoryExpenseMap[txn.category, default: 0] += txn.amount

                if let currentEarliest = earliestExpenseDate {
                    if txn.date < currentEarliest { earliestExpenseDate = txn.date }
                } else {
                    earliestExpenseDate = txn.date
                }

                if let currentLatest = latestExpenseDate {
                    if txn.date > currentLatest { latestExpenseDate = txn.date }
                } else {
                    latestExpenseDate = txn.date
                }
            }
        }

        // Determine top spending category
        let topCategory = categoryExpenseMap.max(by: { $0.value < $1.value })?.key

        // Calculate average daily spending
        let daysCount: Int
        if let earliest = earliestExpenseDate, let latest = latestExpenseDate {
            let startOfEarliest = calendar.startOfDay(for: earliest)
            let startOfLatest = calendar.startOfDay(for: latest)
            let components = calendar.dateComponents([.day], from: startOfEarliest, to: startOfLatest)
            daysCount = max((components.day ?? 0) + 1, 1)
        } else {
            daysCount = 1
        }

        let avgDaily: Decimal = totalExpense / Decimal(daysCount)

        return SpendingSummary(
            totalIncome: totalIncome,
            totalExpense: totalExpense,
            averageDailySpending: avgDaily,
            topSpendingCategory: topCategory,
            transactionCount: transactions.count
        )
    }
}
