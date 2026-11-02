//
//  DashboardView.swift
//  ExpenseTracker
//
//  Created by Ateeq Ahmed on 29/10/26.
//  Primary dashboard overview displaying financial cards, spending trends, and recent records.
//

import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: TransactionsViewModel
    @ObservedObject var dashboardViewModel: DashboardViewModel
    @ObservedObject private var settings = AppSettings.shared
    var onSeeAllTapped: () -> Void

    @State private var showingAddSheet = false

    private var summary: SpendingSummary {
        dashboardViewModel.summary(for: viewModel.allTransactions)
    }

    private var trendData: [DailySpendingPoint] {
        dashboardViewModel.spendingTrends(for: viewModel.allTransactions)
    }

    private var recentItems: [Transaction] {
        dashboardViewModel.recentTransactions(from: viewModel.allTransactions, count: 5)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Net Balance Hero Card
                    balanceHeroCard

                    // Key Metrics Grid
                    metricsGrid

                    // Spending Trend Chart
                    SpendingTrendChartView(
                        dataPoints: trendData,
                        selectedDays: $dashboardViewModel.selectedTrendDays,
                        currencySymbol: settings.selectedCurrency.symbol
                    )

                    // Recent Transactions Section
                    recentTransactionsSection
                }
                .padding()
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundColor(.brandPrimary)
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddEditTransactionView { newTxn in
                    Task {
                        await viewModel.addTransaction(
                            title: newTxn.title,
                            amount: newTxn.amount,
                            category: newTxn.category,
                            date: newTxn.date,
                            type: newTxn.type,
                            notes: newTxn.notes
                        )
                    }
                }
            }
            .refreshable {
                await viewModel.syncRemote()
            }
        }
    }

    // MARK: - Components

    private var balanceHeroCard: some View {
        VStack(spacing: 8) {
            Text("Total Net Balance")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))

            Text(CurrencyFormatter.format(summary.netBalance))
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.down.left")
                    Text("Income: \(CurrencyFormatter.format(summary.totalIncome))")
                }
                .font(.caption)
                .foregroundColor(.white.opacity(0.9))

                HStack(spacing: 4) {
                    Image(systemName: "arrow.up.right")
                    Text("Spent: \(CurrencyFormatter.format(summary.totalExpense))")
                }
                .font(.caption)
                .foregroundColor(.white.opacity(0.9))
            }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .padding(.horizontal, 20)
        .background(
            LinearGradient(
                colors: [Color.brandPrimary, Color.brandSecondary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(22)
        .shadow(color: Color.brandPrimary.opacity(0.3), radius: 10, x: 0, y: 5)
    }

    private var metricsGrid: some View {
        HStack(spacing: 12) {
            MetricCardView(
                title: "Total Spent",
                amount: summary.totalExpense,
                icon: "arrow.up.forward.circle.fill",
                accentColor: .expenseRed
            )

            MetricCardView(
                title: "Daily Average",
                amount: summary.averageDailySpending,
                icon: "calendar.badge.clock",
                accentColor: .orange
            )
        }
    }

    private var recentTransactionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Transactions")
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                Button("See All", action: onSeeAllTapped)
                    .font(.subheadline)
                    .foregroundColor(.brandPrimary)
            }

            if recentItems.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "tray")
                        .font(.largeTitle)
                        .foregroundColor(.secondary.opacity(0.4))
                    Text("No transactions yet")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(Color.cardBackground)
                .cornerRadius(16)
            } else {
                VStack(spacing: 0) {
                    ForEach(recentItems) { item in
                        TransactionRowView(transaction: item)
                            .padding(.horizontal, 16)

                        if item.id != recentItems.last?.id {
                            Divider()
                                .padding(.leading, 70)
                        }
                    }
                }
                .background(Color.cardBackground)
                .cornerRadius(18)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
            }
        }
    }
}
