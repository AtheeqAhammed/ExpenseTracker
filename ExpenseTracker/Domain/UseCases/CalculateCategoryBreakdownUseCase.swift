//
//  CalculateCategoryBreakdownUseCase.swift
//  ExpenseTracker
//
//  Created by Ateeq Ahmed on 29/10/26.
//  Use Case: Groups expenses by category and computes percentages and totals.
//

import Foundation

/// Business rule for category-wise expense breakdown and distributions.
struct CalculateCategoryBreakdownUseCase: Sendable {

    /// Executes category breakdown calculation.
    ///
    /// - Parameters:
    ///   - transactions: List of transactions.
    ///   - type: Filter for type (.expense or .income). Defaults to .expense.
    /// - Returns: Sorted category breakdowns in descending order of monetary amount.
    func execute(
        transactions: [Transaction],
        for type: TransactionType = .expense
    ) -> [CategoryBreakdown] {
        let filtered = transactions.filter { $0.type == type }
        guard !filtered.isEmpty else { return [] }

        var categoryTotals: [String: (amount: Decimal, count: Int)] = [:]
        var overallTotal: Decimal = 0

        for txn in filtered {
            overallTotal += txn.amount
            let current = categoryTotals[txn.category] ?? (amount: 0, count: 0)
            categoryTotals[txn.category] = (amount: current.amount + txn.amount, count: current.count + 1)
        }

        guard overallTotal > 0 else { return [] }
        let overallDouble = NSDecimalNumber(decimal: overallTotal).doubleValue

        let breakdowns = categoryTotals.map { (category, data) -> CategoryBreakdown in
            let amountDouble = NSDecimalNumber(decimal: data.amount).doubleValue
            let percentage = amountDouble / overallDouble
            return CategoryBreakdown(
                category: category,
                totalAmount: data.amount,
                percentage: percentage,
                transactionCount: data.count
            )
        }

        // Sort descending by total spent
        return breakdowns.sorted { $0.totalAmount > $1.totalAmount }
    }
}
