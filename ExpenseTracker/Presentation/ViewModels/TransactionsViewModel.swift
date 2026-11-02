//
//  TransactionsViewModel.swift
//  ExpenseTracker
//
//  Created by Ateeq Ahmed on 29/10/26.
//  ViewModel managing transaction listing, filtering, search, and CRUD workflows.
//

import SwiftUI
import Combine

/// State and logic coordinator for transaction operations.
///
/// Follows MVVM architecture:
/// - Interacts strictly with `TransactionRepositoryProtocol`.
/// - Does not make raw HTTP calls or touch persistent contexts directly.
/// - Exposes published state for reactive SwiftUI binding.
@MainActor
final class TransactionsViewModel: ObservableObject {

    // MARK: - Published State

    @Published private(set) var allTransactions: [Transaction] = []
    @Published var isLoading: Bool = false
    @Published var isSyncing: Bool = false
    @Published var errorMessage: String? = nil
    @Published var syncSuccessMessage: String? = nil

    // Filter & Search
    @Published var searchQuery: String = ""
    @Published var selectedType: TransactionType? = nil
    @Published var selectedCategory: String? = nil
    @Published var sortOption: TransactionSortOption = .newestFirst

    // MARK: - Dependencies

    private let repository: TransactionRepositoryProtocol
    private let filterUseCase: FilterTransactionsUseCase

    // MARK: - Initialization

    init(
        repository: TransactionRepositoryProtocol,
        filterUseCase: FilterTransactionsUseCase = FilterTransactionsUseCase()
    ) {
        self.repository = repository
        self.filterUseCase = filterUseCase
    }

    // MARK: - Computed Properties

    /// Filtered and sorted transactions matching the current user criteria.
    var filteredTransactions: [Transaction] {
        let criteria = TransactionFilterCriteria(
            searchText: searchQuery,
            type: selectedType,
            category: selectedCategory,
            startDate: nil,
            endDate: nil
        )
        return filterUseCase.execute(
            transactions: allTransactions,
            criteria: criteria,
            sortOption: sortOption
        )
    }

    /// Transactions grouped by human-readable date headers (e.g. "Today", "Yesterday").
    var groupedTransactions: [(header: String, items: [Transaction])] {
        let sorted = filteredTransactions
        var groups: [String: [Transaction]] = [:]
        var orderedHeaders: [String] = []

        for item in sorted {
            let header = item.date.relativeHeaderString
            if groups[header] == nil {
                orderedHeaders.append(header)
                groups[header] = []
            }
            groups[header]?.append(item)
        }

        return orderedHeaders.compactMap { header in
            guard let items = groups[header] else { return nil }
            return (header: header, items: items)
        }
    }

    // MARK: - Operations

    /// Loads transactions from the repository.
    func loadTransactions() async {
        isLoading = true
        errorMessage = nil
        do {
            let items = try await repository.fetchTransactions()
            allTransactions = items
        } catch let apiError as APIError {
            errorMessage = apiError.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    /// Adds a new transaction and refreshes state.
    func addTransaction(
        title: String,
        amount: Decimal,
        category: String,
        date: Date,
        type: TransactionType,
        notes: String?
    ) async {
        let newTxn = Transaction(
            title: title,
            amount: amount,
            category: category,
            date: date,
            type: type,
            notes: notes?.isEmpty == true ? nil : notes
        )

        do {
            try await repository.addTransaction(newTxn)
            allTransactions.insert(newTxn, at: 0)
        } catch {
            errorMessage = "Failed to add transaction: \(error.localizedDescription)"
        }
    }

    /// Updates an existing transaction.
    func updateTransaction(_ transaction: Transaction) async {
        do {
            try await repository.updateTransaction(transaction)
            if let index = allTransactions.firstIndex(where: { $0.id == transaction.id }) {
                allTransactions[index] = transaction
            }
        } catch {
            errorMessage = "Failed to update: \(error.localizedDescription)"
        }
    }

    /// Deletes a transaction by identifier.
    func deleteTransaction(id: String) async {
        do {
            try await repository.deleteTransaction(id: id)
            allTransactions.removeAll { $0.id == id }
        } catch {
            errorMessage = "Failed to delete: \(error.localizedDescription)"
        }
    }

    /// Manually triggers remote REST sync via repository.
    func syncRemote() async {
        isSyncing = true
        errorMessage = nil
        syncSuccessMessage = nil

        do {
            let refreshed = try await repository.syncRemoteTransactions()
            allTransactions = refreshed
            syncSuccessMessage = "Successfully synced \(refreshed.count) transactions!"
        } catch let apiError as APIError {
            errorMessage = apiError.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isSyncing = false
    }

    /// Seeds sample mock transactions for quick demonstration.
    func seedDemoData() async {
        let demoItems: [Transaction] = [
            Transaction(
                title: "Whole Foods Market",
                amount: 86.40,
                category: "Groceries",
                date: Date(),
                type: .expense,
                notes: "Weekly fruits and organics"
            ),
            Transaction(
                title: "Software Engineering Salary",
                amount: 4500.00,
                category: "Salary",
                date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
                type: .income,
                notes: "Bi-weekly direct deposit"
            ),
            Transaction(
                title: "Starbucks Coffee",
                amount: 6.75,
                category: "Food & Dining",
                date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
                type: .expense,
                notes: "Morning latte"
            ),
            Transaction(
                title: "Electric & Utility Bill",
                amount: 142.50,
                category: "Utilities & Bills",
                date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
                type: .expense,
                notes: "Summer cooling bill"
            ),
            Transaction(
                title: "Freelance iOS UI Design",
                amount: 750.00,
                category: "Freelance",
                date: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
                type: .income,
                notes: "Design sprint kickoff"
            ),
            Transaction(
                title: "Subway Pass Renewal",
                amount: 80.00,
                category: "Transportation",
                date: Calendar.current.date(byAdding: .day, value: -4, to: Date()) ?? Date(),
                type: .expense,
                notes: "Monthly MetroCard"
            ),
            Transaction(
                title: "Nordstrom Clothing",
                amount: 129.99,
                category: "Shopping",
                date: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
                type: .expense,
                notes: "Winter jacket"
            ),
            Transaction(
                title: "AMC Cinema Movie Night",
                amount: 34.00,
                category: "Entertainment",
                date: Calendar.current.date(byAdding: .day, value: -6, to: Date()) ?? Date(),
                type: .expense,
                notes: "Tickets & popcorn"
            )
        ]

        for item in demoItems {
            await addTransaction(
                title: item.title,
                amount: item.amount,
                category: item.category,
                date: item.date,
                type: item.type,
                notes: item.notes
            )
        }
    }

    /// Generates a CSV file containing transactions for export.
    func generateCSVExportURL() -> URL? {
        var csvString = "ID,Title,Amount,Type,Category,Date,Notes\n"
        for txn in allTransactions {
            let safeTitle = txn.title.replacingOccurrences(of: "\"", with: "\"\"")
            let safeNotes = (txn.notes ?? "").replacingOccurrences(of: "\"", with: "\"\"")
            let line = "\"\(txn.id)\",\"\(safeTitle)\",\(txn.amount),\"\(txn.type.rawValue)\",\"\(txn.category)\",\"\(txn.date.iso8601String)\",\"\(safeNotes)\"\n"
            csvString.append(line)
        }

        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("ExpenseTracker_Export_\(Date().timeIntervalSince1970).csv")
        do {
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            return nil
        }
    }

    /// Generates a JSON backup file containing all transactions.
    func generateJSONExportURL() -> URL? {
        let dtos = allTransactions.map { TransactionDTO(from: $0) }
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        do {
            let data = try encoder.encode(dtos)
            let tempDir = FileManager.default.temporaryDirectory
            let fileURL = tempDir.appendingPathComponent("ExpenseTracker_Backup_\(Int(Date().timeIntervalSince1970)).json")
            try data.write(to: fileURL)
            return fileURL
        } catch {
            return nil
        }
    }
}
