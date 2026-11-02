//
//  CalculateSpendingTrendsUseCase.swift
//  ExpenseTracker
//
//  Created by Ateeq Ahmed on 29/10/26.
//  Use Case: Aggregates daily spending for interactive charts over a selected window.
//

import Foundation

/// Business rule that aggregates expenses into daily buckets for trend visualization.
struct CalculateSpendingTrendsUseCase: Sendable {

    /// Generates daily spending data points for the last `days` days up to reference date.
    ///
    /// - Parameters:
    ///   - transactions: Full or filtered transaction list.
    ///   - days: Number of consecutive days to display (e.g. 7, 14, 30).
    ///   - referenceDate: Anchor date (defaults to current date).
    ///   - calendar: User's calendar instance.
    /// - Returns: An ordered array of `DailySpendingPoint` objects, one for each day.
    func execute(
        transactions: [Transaction],
        days: Int = 7,
        referenceDate: Date = Date(),
        calendar: Calendar = .current
    ) -> [DailySpendingPoint] {
        let expenseTransactions = transactions.filter { $0.type == .expense }

        let today = calendar.startOfDay(for: referenceDate)
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = days <= 7 ? "EEE" : "MMM d"

        // Map existing expenses to start of their corresponding day
        var dailyTotals: [Date: Decimal] = [:]
        for txn in expenseTransactions {
            let startOfDay = calendar.startOfDay(for: txn.date)
            dailyTotals[startOfDay, default: 0] += txn.amount
        }

        // Generate full continuous range of days including zeroes
        var points: [DailySpendingPoint] = []
        for dayOffset in (0..<days).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            let amount = dailyTotals[date] ?? 0
            let label = dayFormatter.string(from: date)
            points.append(DailySpendingPoint(date: date, amount: amount, label: label))
        }

        return points
    }
}
