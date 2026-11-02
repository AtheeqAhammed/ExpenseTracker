//
//  SwiftDataTransactionStore.swift
//  ExpenseTracker
//
//  Created by Ateeq Ahmed on 29/10/26.
//  Encapsulates local database persistence using SwiftData ModelContext.
//

import Foundation
import SwiftData

/// Protocol defining local storage CRUD operations.
@MainActor
protocol TransactionLocalStoreProtocol: Sendable {
    func fetchTransactions() throws -> [Transaction]
    func saveTransaction(_ transaction: Transaction) throws
    func saveTransactions(_ transactions: [Transaction]) throws
    func deleteTransaction(id: String) throws
    func deleteAllTransactions() throws

    // Budgets
    func fetchBudgets() throws -> [MonthlyBudget]
    func saveBudget(_ budget: MonthlyBudget) throws
    func deleteBudget(category: String) throws
}

/// SwiftData implementation of `TransactionLocalStoreProtocol`.
@MainActor
final class SwiftDataTransactionStore: TransactionLocalStoreProtocol {

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Transactions CRUD

    func fetchTransactions() throws -> [Transaction] {
        let descriptor = FetchDescriptor<SDTransaction>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        let persistentModels = try modelContext.fetch(descriptor)
        return persistentModels.map { $0.toDomain() }
    }

    func saveTransaction(_ transaction: Transaction) throws {
        let targetId = transaction.id
        var descriptor = FetchDescriptor<SDTransaction>(
            predicate: #Predicate<SDTransaction> { $0.id == targetId }
        )
        descriptor.fetchLimit = 1

        let existing = try modelContext.fetch(descriptor).first
        if let existing = existing {
            // Update existing
            existing.title = transaction.title
            existing.amount = transaction.amount
            existing.category = transaction.category
            existing.date = transaction.date
            existing.typeRaw = transaction.type.rawValue
            existing.notes = transaction.notes
        } else {
            // Insert new
            let newModel = SDTransaction(from: transaction)
            modelContext.insert(newModel)
        }

        try modelContext.save()
    }

    func saveTransactions(_ transactions: [Transaction]) throws {
        for transaction in transactions {
            let targetId = transaction.id
            var descriptor = FetchDescriptor<SDTransaction>(
                predicate: #Predicate<SDTransaction> { $0.id == targetId }
            )
            descriptor.fetchLimit = 1

            if let existing = try modelContext.fetch(descriptor).first {
                existing.title = transaction.title
                existing.amount = transaction.amount
                existing.category = transaction.category
                existing.date = transaction.date
                existing.typeRaw = transaction.type.rawValue
                existing.notes = transaction.notes
            } else {
                let newModel = SDTransaction(from: transaction)
                modelContext.insert(newModel)
            }
        }
        try modelContext.save()
    }

    func deleteTransaction(id: String) throws {
        var descriptor = FetchDescriptor<SDTransaction>(
            predicate: #Predicate<SDTransaction> { $0.id == id }
        )
        descriptor.fetchLimit = 1

        if let existing = try modelContext.fetch(descriptor).first {
            modelContext.delete(existing)
            try modelContext.save()
        }
    }

    func deleteAllTransactions() throws {
        let descriptor = FetchDescriptor<SDTransaction>()
        let items = try modelContext.fetch(descriptor)
        for item in items {
            modelContext.delete(item)
        }
        try modelContext.save()
    }

    // MARK: - Budgets CRUD

    func fetchBudgets() throws -> [MonthlyBudget] {
        let descriptor = FetchDescriptor<SDBudget>(
            sortBy: [SortDescriptor(\.category, order: .forward)]
        )
        let items = try modelContext.fetch(descriptor)
        return items.map { $0.toDomain() }
    }

    func saveBudget(_ budget: MonthlyBudget) throws {
        let category = budget.category
        var descriptor = FetchDescriptor<SDBudget>(
            predicate: #Predicate<SDBudget> { $0.category == category }
        )
        descriptor.fetchLimit = 1

        if let existing = try modelContext.fetch(descriptor).first {
            existing.monthlyLimit = budget.monthlyLimit
            existing.updatedAt = Date()
        } else {
            let newBudget = SDBudget(from: budget)
            modelContext.insert(newBudget)
        }
        try modelContext.save()
    }

    func deleteBudget(category: String) throws {
        var descriptor = FetchDescriptor<SDBudget>(
            predicate: #Predicate<SDBudget> { $0.category == category }
        )
        descriptor.fetchLimit = 1

        if let existing = try modelContext.fetch(descriptor).first {
            modelContext.delete(existing)
            try modelContext.save()
        }
    }
}
