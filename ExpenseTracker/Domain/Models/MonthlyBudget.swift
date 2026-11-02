//
//  MonthlyBudget.swift
//  ExpenseTracker
//
//  Created by Ateeq Ahmed on 29/10/26.
//  Domain model representing monthly spending budget targets.
//

import Foundation

/// Represents a monthly spending limit assigned to a category.
struct MonthlyBudget: Identifiable, Equatable, Hashable, Sendable {
    var id: String { category }

    /// Target category name.
    let category: String

    /// Maximum intended spend per calendar month.
    let monthlyLimit: Decimal

    init(category: String, monthlyLimit: Decimal) {
        self.category = category
        self.monthlyLimit = monthlyLimit
    }
}

/// Budget status calculation result for presentation.
struct BudgetProgress: Identifiable, Equatable, Sendable {
    var id: String { category }

    let category: String
    let budgetLimit: Decimal
    let currentSpent: Decimal

    /// Fraction of budget consumed (0.0 to 1.0 or higher when over budget).
    var percentageUsed: Double {
        guard budgetLimit > 0 else { return 0 }
        let spentDouble = NSDecimalNumber(decimal: currentSpent).doubleValue
        let limitDouble = NSDecimalNumber(decimal: budgetLimit).doubleValue
        return min(max(spentDouble / limitDouble, 0.0), 2.0)
    }

    /// Remaining spending allowance for the period.
    var remaining: Decimal {
        budgetLimit - currentSpent
    }

    /// Whether the user has exceeded their configured budget.
    var isOverBudget: Bool {
        currentSpent > budgetLimit
    }

    /// Warning threshold reached (e.g. >= 85%).
    var isWarning: Bool {
        percentageUsed >= 0.85 && !isOverBudget
    }
}
