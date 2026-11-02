//
//  ExpenseTrackerApp.swift
//  ExpenseTracker
//
//  Created by Ateeq Ahmed on 29/10/26.
//

import SwiftUI
import SwiftData

@main
struct ExpenseTrackerApp: App {

    // MARK: - SwiftData Container

    /// Retained single instance of ModelContainer for the entire app lifecycle.
    let container: ModelContainer

    // MARK: - Dependency Injection & State

    @StateObject private var transactionsViewModel: TransactionsViewModel
    @StateObject private var dashboardViewModel: DashboardViewModel

    init() {
        let schema = Schema([
            SDTransaction.self,
            SDBudget.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        let resolvedContainer: ModelContainer
        do {
            resolvedContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            print("⚠️ Incompatible or unmigrated store detected: \(error). Recreating store...")
            // If the schema changed from an older development version, wipe the old store or fallback cleanly
            if let storeURL = modelConfiguration.url as URL? {
                try? FileManager.default.removeItem(at: storeURL)
                let shmURL = storeURL.deletingPathExtension().appendingPathExtension("store-shm")
                let walURL = storeURL.deletingPathExtension().appendingPathExtension("store-wal")
                try? FileManager.default.removeItem(at: shmURL)
                try? FileManager.default.removeItem(at: walURL)
            }

            do {
                resolvedContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                print("⚠️ Falling back to in-memory container: \(error)")
                let memConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
                resolvedContainer = (try? ModelContainer(for: schema, configurations: [memConfig]))
                    ?? (try! ModelContainer(for: schema, configurations: [ModelConfiguration(isStoredInMemoryOnly: true)]))
            }
        }

        self.container = resolvedContainer

        // Initialize Data Layer components with the retained container
        let apiBaseURL = URL(string: "https://api.expensetracker.app/v1")!
        let transport = MockHTTPTransport()
        let apiClient = TransactionAPIClient(baseURL: apiBaseURL, transport: transport)
        let localStore = SwiftDataTransactionStore(modelContext: resolvedContainer.mainContext)
        let repository = DefaultTransactionRepository(apiClient: apiClient, localStore: localStore)

        // Initialize Presentation ViewModels
        _transactionsViewModel = StateObject(wrappedValue: TransactionsViewModel(repository: repository))
        _dashboardViewModel = StateObject(wrappedValue: DashboardViewModel(repository: repository))
    }

    var body: some Scene {
        WindowGroup {
            ContentView(
                viewModel: transactionsViewModel,
                dashboardViewModel: dashboardViewModel
            )
            .task {
                await transactionsViewModel.loadTransactions()
                await dashboardViewModel.loadBudgets()
            }
        }
        .modelContainer(container)
    }
}
