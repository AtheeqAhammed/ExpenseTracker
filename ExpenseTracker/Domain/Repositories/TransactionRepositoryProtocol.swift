//
//  TransactionRepositoryProtocol.swift
//  ExpenseTracker
//
//  Clean Architecture Domain Boundary:
//  The repository provides a stable interface to the rest of the application.
//  The ViewModel asks for transactions; the repository decides where to get them.
//

import Foundation

/// Repository contract abstracting remote API synchronization and local caching.
///
/// This protocol belongs in the Domain layer because it describes what the app needs,
/// not how the data is retrieved.
protocol TransactionRepositoryProtocol: Sendable {

    /// Fetches all available transactions, preferring local cache for offline reliability.
    func fetchTransactions() async throws -> [Transaction]

    /// Adds a new transaction into local storage and synchronizes it.
    func addTransaction(_ transaction: Transaction) async throws

    /// Updates an existing transaction.
    func updateTransaction(_ transaction: Transaction) async throws

    /// Deletes a transaction by its unique identifier.
    func deleteTransaction(id: String) async throws

    /// Synchronizes with the remote REST API, caching fresh remote transactions locally.
    func syncRemoteTransactions() async throws -> [Transaction]

    // MARK: - Budgets

    /// Fetches stored monthly category budgets.
    func fetchBudgets() async throws -> [MonthlyBudget]

    /// Saves or updates a category budget.
    func saveBudget(_ budget: MonthlyBudget) async throws

    /// Deletes a budget configuration.
    func deleteBudget(category: String) async throws
}
