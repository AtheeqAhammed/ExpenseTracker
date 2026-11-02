//
//  DashboardViewModel.swift
//  ExpenseTracker
//
//  Created by Ateeq Ahmed on 29/10/26.
//  ViewModel managing dashboard metrics, chart trends, and category distribution.
//

import SwiftUI
import Combine

/// State provider for the Dashboard and Analytics interfaces.
@MainActor
final class DashboardViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var selectedTrendDays: Int = 7
    @Published var budgets: [MonthlyBudget] = []
    @Published var isLoadingBudgets: Bool = false

    // MARK: - Use Cases & Repository

    private let repository: TransactionRepositoryProtocol
    private let summaryUseCase: CalculateSpendingSummaryUseCase
    private let trendsUseCase: CalculateSpendingTrendsUseCase
    private let categoryBreakdownUseCase: CalculateCategoryBreakdownUseCase

    // MARK: - Initialization

    init(
        repository: TransactionRepositoryProtocol,
        summaryUseCase: CalculateSpendingSummaryUseCase = CalculateSpendingSummaryUseCase(),
        trendsUseCase: CalculateSpendingTrendsUseCase = CalculateSpendingTrendsUseCase(),
        categoryBreakdownUseCase: CalculateCategoryBreakdownUseCase = CalculateCategoryBreakdownUseCase()
    ) {
        self.repository = repository
        self.summaryUseCase = summaryUseCase
        self.trendsUseCase = trendsUseCase
        self.categoryBreakdownUseCase = categoryBreakdownUseCase
    }

    // MARK: - Computed Analytics

    /// Computes high-level summary metrics from current transactions.
    func summary(for transactions: [Transaction]) -> SpendingSummary {
        summaryUseCase.execute(transactions: transactions)
    }

    /// Computes daily spending points for Swift Charts trend graphs.
    func spendingTrends(for transactions: [Transaction]) -> [DailySpendingPoint] {
        trendsUseCase.execute(
            transactions: transactions,
            days: selectedTrendDays,
            referenceDate: Date()
        )
    }

    /// Category breakdown list sorted by largest expense amount.
    func categoryBreakdown(for transactions: [Transaction], type: TransactionType = .expense) -> [CategoryBreakdown] {
        categoryBreakdownUseCase.execute(transactions: transactions, for: type)
    }

    /// Recent transactions (up to 5 most recent items).
    func recentTransactions(from transactions: [Transaction], count: Int = 5) -> [Transaction] {
        Array(transactions.sorted(by: { $0.date > $1.date }).prefix(count))
    }

    // MARK: - Budgets Coordination

    func loadBudgets() async {
        isLoadingBudgets = true
        do {
            budgets = try await repository.fetchBudgets()
        } catch {
            budgets = []
        }
        isLoadingBudgets = false
    }

    func saveBudget(category: String, limit: Decimal) async {
        let budget = MonthlyBudget(category: category, monthlyLimit: limit)
        do {
            try await repository.saveBudget(budget)
            await loadBudgets()
        } catch {
            print("Failed to save budget: \(error)")
        }
    }

    func deleteBudget(category: String) async {
        do {
            try await repository.deleteBudget(category: category)
            await loadBudgets()
        } catch {
            print("Failed to delete budget: \(error)")
        }
    }

    /// Computes budget progress for each configured category against the current month's expenses.
    func budgetProgressList(transactions: [Transaction]) -> [BudgetProgress] {
        let calendar = Calendar.current
        let currentMonthComponents = calendar.dateComponents([.year, .month], from: Date())

        // Filter transactions in current month & expenses
        let currentMonthExpenses = transactions.filter { txn in
            guard txn.type == .expense else { return false }
            let components = calendar.dateComponents([.year, .month], from: txn.date)
            return components.year == currentMonthComponents.year && components.month == currentMonthComponents.month
        }

        var spentByCategory: [String: Decimal] = [:]
        for txn in currentMonthExpenses {
            spentByCategory[txn.category, default: 0] += txn.amount
        }

        return budgets.map { budget in
            let spent = spentByCategory[budget.category] ?? 0
            return BudgetProgress(
                category: budget.category,
                budgetLimit: budget.monthlyLimit,
                currentSpent: spent
            )
        }
    }
}
