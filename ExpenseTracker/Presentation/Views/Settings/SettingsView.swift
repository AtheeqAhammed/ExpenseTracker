//
//  SettingsView.swift
//  ExpenseTracker
//
//  Production-grade settings and preferences interface for finance management.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: TransactionsViewModel
    @ObservedObject private var settings = AppSettings.shared

    @State private var showingClearConfirmation = false
    @State private var exportURL: URL? = nil
    @State private var showingShareSheet = false
    @State private var shareSheetTitle: String = ""

    var body: some View {
        NavigationStack {
            List {
                // Section 1: User / Account Overview
                accountHeaderSection

                // Section 2: General & Currency Preferences
                generalPreferencesSection

                // Section 3: Budgets & Alert Thresholds
                budgetsAndAlertsSection

                // Section 4: Data Management & Backups
                dataManagementSection

                // Section 5: Cloud Synchronization
                cloudSyncSection

                // Section 6: Security & Privacy
                securityAndPrivacySection
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
                Text("This action cannot be undone. All locally stored transactions and database records will be permanently removed.")
            }
            .sheet(isPresented: $showingShareSheet) {
                if let url = exportURL {
                    ShareSheet(activityItems: [url])
                }
            }
        }
    }

    // MARK: - Sections

    private var accountHeaderSection: some View {
        Section {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.brandPrimary, Color.brandSecondary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 54, height: 54)

                    Image(systemName: "wallet.pass.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Personal Finances")
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text("\(viewModel.allTransactions.count) transactions recorded")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    HStack(spacing: 4) {
                        Text(settings.selectedCurrency.flag)
                        Text("\(settings.selectedCurrency.code) (\(settings.selectedCurrency.symbol))")
                            .font(.caption2)
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.brandPrimary.opacity(0.12))
                    .cornerRadius(8)
                    .foregroundColor(.brandPrimary)
                }
            }
            .padding(.vertical, 4)
        }
    }

    private var generalPreferencesSection: some View {
        Section {
            // Currency Selector
            NavigationLink {
                CurrencySelectorView()
            } label: {
                HStack {
                    Label {
                        Text("Default Currency")
                    } icon: {
                        Image(systemName: "coloncurrencysign.circle.fill")
                            .foregroundColor(.brandPrimary)
                    }

                    Spacer()

                    HStack(spacing: 6) {
                        Text(settings.selectedCurrency.flag)
                        Text("\(settings.selectedCurrency.code) (\(settings.selectedCurrency.symbol))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }

            // Default Transaction Type
            Picker(selection: $settings.defaultTransactionType) {
                Text("Expense").tag(TransactionType.expense)
                Text("Income").tag(TransactionType.income)
            } label: {
                Label {
                    Text("Default Add Mode")
                } icon: {
                    Image(systemName: "plus.forwardslash.minus")
                        .foregroundColor(.orange)
                }
            }

            // Appearance Theme
            Picker(selection: $settings.appearanceMode) {
                ForEach(AppearanceMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            } label: {
                Label {
                    Text("Appearance")
                } icon: {
                    Image(systemName: "paintpalette.fill")
                        .foregroundColor(.purple)
                }
            }
        } header: {
            Text("Preferences")
        } footer: {
            Text("Currency choice applies to all dashboard statistics, charts, forms, and budget calculations.")
        }
    }

    private var budgetsAndAlertsSection: some View {
        Section {
            HStack {
                Label {
                    Text("Budget Warning Threshold")
                } icon: {
                    Image(systemName: "bell.badge.fill")
                        .foregroundColor(.yellow)
                }

                Spacer()

                Text(String(format: "%.0f%%", settings.budgetWarningThreshold * 100))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.brandPrimary)
            }

            Slider(
                value: $settings.budgetWarningThreshold,
                in: 0.50...1.00,
                step: 0.05
            )
            .tint(Color.brandPrimary)
        } header: {
            Text("Budgets & Warnings")
        } footer: {
            Text("Displays an alert warning on budget cards when monthly spending reaches this percentage.")
        }
    }

    private var dataManagementSection: some View {
        Section {
            // Export CSV
            Button {
                if let url = viewModel.generateCSVExportURL() {
                    exportURL = url
                    shareSheetTitle = "Export CSV"
                    showingShareSheet = true
                }
            } label: {
                HStack {
                    Label {
                        Text("Export Transactions (CSV)")
                            .foregroundColor(.primary)
                    } icon: {
                        Image(systemName: "tablecells.fill")
                            .foregroundColor(.green)
                    }
                    Spacer()
                    Image(systemName: "square.and.arrow.up")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // Export JSON Backup
            Button {
                if let url = viewModel.generateJSONExportURL() {
                    exportURL = url
                    shareSheetTitle = "Export Backup"
                    showingShareSheet = true
                }
            } label: {
                HStack {
                    Label {
                        Text("Export JSON Backup")
                            .foregroundColor(.primary)
                    } icon: {
                        Image(systemName: "arrow.down.doc.fill")
                            .foregroundColor(.blue)
                    }
                    Spacer()
                    Image(systemName: "square.and.arrow.up")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // Seed Sample Data
            Button {
                Task {
                    await viewModel.seedDemoData()
                }
            } label: {
                Label {
                    Text("Load Sample Dataset")
                        .foregroundColor(.brandPrimary)
                } icon: {
                    Image(systemName: "sparkles")
                        .foregroundColor(.brandPrimary)
                }
            }

            // Clear All Data
            Button(role: .destructive) {
                showingClearConfirmation = true
            } label: {
                Label {
                    Text("Clear All Data")
                        .foregroundColor(.expenseRed)
                } icon: {
                    Image(systemName: "trash.fill")
                        .foregroundColor(.expenseRed)
                }
            }
        } header: {
            Text("Data Management & Backups")
        }
    }

    private var cloudSyncSection: some View {
        Section {
            Button {
                Task {
                    await viewModel.syncRemote()
                    settings.lastSyncDate = Date()
                }
            } label: {
                HStack {
                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Sync with Remote API")
                                .foregroundColor(.primary)

                            if let lastSync = settings.lastSyncDate {
                                Text("Last synced: \(lastSync.relativeHeaderString) at \(lastSync.timeString)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            } else {
                                Text("Not synced yet")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    } icon: {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .foregroundColor(.brandPrimary)
                    }

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
            Text("Synchronizes with the remote REST backend via TransactionAPIClient and merges updates into local SwiftData storage.")
        }
    }

    private var securityAndPrivacySection: some View {
        Section {
            Toggle(isOn: $settings.isBiometricsEnabled) {
                Label {
                    Text("Require Face ID / Passcode")
                } icon: {
                    Image(systemName: "faceid")
                        .foregroundColor(.indigo)
                }
            }

            Toggle(isOn: $settings.hideBalancesInSwitcher) {
                Label {
                    Text("Privacy Mode")
                } icon: {
                    Image(systemName: "eye.slash.fill")
                        .foregroundColor(.cyan)
                }
            }
        } header: {
            Text("Security & Privacy")
        } footer: {
            Text("Privacy mode obscures sensitive account balances when the application is viewed in the iOS App Switcher.")
        }
    }
}

/// Simple UIKit UIActivityViewController wrapper for CSV and JSON sharing.
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
