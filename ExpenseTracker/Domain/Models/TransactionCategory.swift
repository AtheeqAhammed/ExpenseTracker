//
//  TransactionCategory.swift
//  ExpenseTracker
//
//  Created by Ateeq Ahmed on 29/10/26.
//  Domain model representing transaction categories with presentation metadata.
//

import SwiftUI

/// Predefined category definitions providing standard classifications, SF Symbols, and colors.
struct TransactionCategory: Identifiable, Equatable, Hashable, Sendable {
    var id: String { name }
    let name: String
    let iconName: String
    let hexColor: String
    let defaultType: TransactionType

    // MARK: - Predefined Categories

    static let allCategories: [TransactionCategory] = [
        // Expense categories
        TransactionCategory(name: "Food & Dining", iconName: "fork.knife", hexColor: "#FF5722", defaultType: .expense),
        TransactionCategory(name: "Groceries", iconName: "cart.fill", hexColor: "#4CAF50", defaultType: .expense),
        TransactionCategory(name: "Shopping", iconName: "bag.fill", hexColor: "#E91E63", defaultType: .expense),
        TransactionCategory(name: "Transportation", iconName: "car.fill", hexColor: "#2196F3", defaultType: .expense),
        TransactionCategory(name: "Housing & Rent", iconName: "house.fill", hexColor: "#795548", defaultType: .expense),
        TransactionCategory(name: "Utilities & Bills", iconName: "bolt.fill", hexColor: "#FF9800", defaultType: .expense),
        TransactionCategory(name: "Entertainment", iconName: "tv.fill", hexColor: "#9C27B0", defaultType: .expense),
        TransactionCategory(name: "Health & Medical", iconName: "cross.fill", hexColor: "#F44336", defaultType: .expense),
        TransactionCategory(name: "Education", iconName: "book.fill", hexColor: "#3F51B5", defaultType: .expense),
        TransactionCategory(name: "Travel", iconName: "airplane", hexColor: "#00BCD4", defaultType: .expense),
        
        // Income categories
        TransactionCategory(name: "Salary", iconName: "banknote.fill", hexColor: "#10B981", defaultType: .income),
        TransactionCategory(name: "Freelance", iconName: "laptopcomputer", hexColor: "#06B6D4", defaultType: .income),
        TransactionCategory(name: "Investments", iconName: "chart.line.uptrend.xyaxis", hexColor: "#8B5CF6", defaultType: .income),
        TransactionCategory(name: "Gift & Bonus", iconName: "gift.fill", hexColor: "#F59E0B", defaultType: .income),
        
        // Generic / Fallback
        TransactionCategory(name: "Other", iconName: "ellipsis.circle.fill", hexColor: "#9E9E9E", defaultType: .expense)
    ]

    /// Finds a predefined category by name, or returns a default fallback.
    static func category(named name: String) -> TransactionCategory {
        allCategories.first { $0.name.caseInsensitiveCompare(name) == .orderedSame }
            ?? TransactionCategory(name: name, iconName: "tag.fill", hexColor: "#9E9E9E", defaultType: .expense)
    }

    /// Filters categories matching a given transaction type.
    static func categories(for type: TransactionType) -> [TransactionCategory] {
        allCategories.filter { $0.defaultType == type }
    }
}
