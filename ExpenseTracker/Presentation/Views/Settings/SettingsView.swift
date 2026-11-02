//
//  SettingsView.swift
//  ExpenseTracker
//
//  Created by Ateeq Ahmed on 29/10/26.
//  Settings and diagnostics interface for remote sync, CSV export, and demo seeding.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: TransactionsViewModel

    @State private var showingClearConfirmation = false
    @State private var exportURL: URL? = nil
    @State private var showingShareSheet = false

    var body: some View {
        NavigationStack {
            List {
                // Section 1: Remote Synchronization
                Section {
                    Button {
                        Task {
                            await viewModel.syncRemote()
                        }
                    } label: {
                        HStack {
                            Label("Sync Remote API", systemImage: "arrow.triangle.2.circlepath")
                                .foregroundColor(.primary)

                            Spacer()

                            if viewModel.isSyncing {
                                ProgressView()
                            }
                        }
                    }
                    .disabled(viewModel.isSyncing)

                    if let success = viewModel.syncSuccessMessage {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.incomeGreen)
                            Text(success)
                                .font(.caption)
                                .foregroundColor(.incomeGreen)
                        }
                    }

                    if let error = viewModel.errorMessage {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.expenseRed)
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.expenseRed)
                        }
                    }
                } header: {
                    Text("Cloud Synchronization")
                } footer: {
                    Text("Contacts the remote REST API endpoint (/transactions) via TransactionAPIClient and merges new items into SwiftData.")
                }

                // Section 2: Data Management
                Section {
                    Button {
                        Task {
                            await viewModel.seedDemoData()
                        }
                    } label: {
                        Label("Seed Sample Transactions", systemImage: "sparkles")
                            .foregroundColor(.brandPrimary)
                    }

                    Button {
                        if let url = viewModel.generateCSVExportURL() {
                            exportURL = url
                            showingShareSheet = true
                        }
                    } label: {
                        Label("Export Transactions (CSV)", systemImage: "square.and.arrow.up")
                            .foregroundColor(.primary)
                    }

                    Button(role: .destructive) {
                        showingClearConfirmation = true
                    } label: {
                        Label("Clear All Transactions", systemImage: "trash")
                            .foregroundColor(.expenseRed)
                    }
                } header: {
                    Text("Data Management")
                }

                // Section 3: Architecture Overview
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "square.3.layers.3d.top.filled")
                                .foregroundColor(.brandPrimary)
                            Text("Clean Architecture + MVVM")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }

                        Text("• Presentation: SwiftUI Views & ViewModels\n• Domain: Pure Entities (Decimal for currency), Use Cases, Repository Protocol\n• Data: APIClient (URLSession), DTOs, Typed APIError, SwiftData LocalStore")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineSpacing(3)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Architecture")
                }
            }
            .navigationTitle("Settings")
            .confirmationDialog(
                "Delete All Transactions?",
                isPresented: $showingClearConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete Everything", role: .destructive) {
                    Task {
                        for txn in viewModel.allTransactions {
                            await viewModel.deleteTransaction(id: txn.id)
                        }
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This action cannot be undone. All locally stored transactions will be removed.")
            }
            .sheet(isPresented: $showingShareSheet) {
                if let url = exportURL {
                    ShareSheet(activityItems: [url])
                }
            }
        }
    }
}

/// Simple UIKit UIActivityViewController wrapper for CSV sharing.
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
