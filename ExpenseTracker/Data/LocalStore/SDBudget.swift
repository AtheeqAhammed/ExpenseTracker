//
//  SDBudget.swift
//  ExpenseTracker
//
//  Created by Ateeq Ahmed on 29/10/26.
//  SwiftData persistent model representing category budgets.
//

import Foundation
import SwiftData

/// SwiftData persistent entity for monthly category budgets.
@Model
final class SDBudget {
    /// Unique category identifier.
    @Attribute(.unique) var category: String

    /// Maximum allocated monthly limit.
    var monthlyLimit: Decimal

    /// Last update timestamp.
    var updatedAt: Date

    init(category: String, monthlyLimit: Decimal, updatedAt: Date = Date()) {
        self.category = category
        self.monthlyLimit = monthlyLimit
        self.updatedAt = updatedAt
    }

    /// Converts to domain `MonthlyBudget` model.
    func toDomain() -> MonthlyBudget {
        MonthlyBudget(category: category, monthlyLimit: monthlyLimit)
    }

    convenience init(from domain: MonthlyBudget) {
        self.init(category: domain.category, monthlyLimit: domain.monthlyLimit)
    }
}
