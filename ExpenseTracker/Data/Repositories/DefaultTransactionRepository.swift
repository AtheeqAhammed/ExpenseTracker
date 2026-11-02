//
//  DefaultTransactionRepository.swift
//  ExpenseTracker
//
//  Created by Ateeq Ahmed on 29/10/26.
//  Coordinates data sources between the remote REST API and local SwiftData store.
//

import Foundation

/// Concrete repository coordinating remote REST networking and local SwiftData persistence.
///
/// Implements offline-first pattern:
/// - Fast reading directly from local storage.
/// - Synchronization with remote REST API.
/// - Transparent local caching to guarantee offline accessibility.
final class DefaultTransactionRepository: TransactionRepositoryProtocol, @unchecked Sendable {

    private let apiClient: TransactionAPIClient
    private let localStore: (any TransactionLocalStoreProtocol)?

    /// Initializes repository with an API client and optional local SwiftData store.
    ///
    /// - Parameters:
    ///   - apiClient: The remote REST API client.
    ///   - localStore: The local SwiftData persistence store.
    init(
        apiClient: TransactionAPIClient,
        localStore: (any TransactionLocalStoreProtocol)? = nil
    ) {
        self.apiClient = apiClient
        self.localStore = localStore
    }

    // MARK: - Transaction Operations

    /// Fetches transactions, prioritizing local persistence.
    /// If local store is empty, attempts initial sync from remote API.
    func fetchTransactions() async throws -> [Transaction] {
        if let localStore = localStore {
            let localItems = try await localStore.fetchTransactions()
            if !localItems.isEmpty {
                return localItems
            }

            // Local cache is empty, attempt initial seed from API
            do {
                let remoteItems = try await apiClient.fetchTransactions()
                try await localStore.saveTransactions(remoteItems)
                return remoteItems
            } catch {
                // If remote fails (e.g. offline on first run), return whatever was local (empty)
                return localItems
            }
        }

        // Fallback directly to API client if no local store configured
        return try await apiClient.fetchTransactions()
    }

    /// Adds a transaction to local storage.
    func addTransaction(_ transaction: Transaction) async throws {
        if let localStore = localStore {
            try await localStore.saveTransaction(transaction)
        }
    }

    /// Updates an existing transaction in local storage.
    func updateTransaction(_ transaction: Transaction) async throws {
        if let localStore = localStore {
            try await localStore.saveTransaction(transaction)
        }
    }

    /// Deletes a transaction from local storage.
    func deleteTransaction(id: String) async throws {
        if let localStore = localStore {
            try await localStore.deleteTransaction(id: id)
        }
    }

    /// Forces a refresh from the remote API and updates local SwiftData cache.
    func syncRemoteTransactions() async throws -> [Transaction] {
        let remoteItems = try await apiClient.fetchTransactions()
        if let localStore = localStore {
            try await localStore.saveTransactions(remoteItems)
            return try await localStore.fetchTransactions()
        }
        return remoteItems
    }

    // MARK: - Budgets

    func fetchBudgets() async throws -> [MonthlyBudget] {
        guard let localStore = localStore else { return [] }
        return try await localStore.fetchBudgets()
    }

    func saveBudget(_ budget: MonthlyBudget) async throws {
        guard let localStore = localStore else { return }
        try await localStore.saveBudget(budget)
    }

    func deleteBudget(category: String) async throws {
        guard let localStore = localStore else { return }
        try await localStore.deleteBudget(category: category)
    }
}
