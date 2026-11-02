//
//  BudgetsView.swift
//  ExpenseTracker
//
//  Created by Ateeq Ahmed on 29/10/26.
//  Budget tracking interface monitoring limits, spending, and warning thresholds.
//

import SwiftUI

struct BudgetsView: View {
    @ObservedObject var viewModel: TransactionsViewModel
    @ObservedObject var dashboardViewModel: DashboardViewModel
    @ObservedObject private var settings = AppSettings.shared

    @State private var showingAddBudget = false
    @State private var selectedBudgetForEdit: MonthlyBudget? = nil

    private var progressList: [BudgetProgress] {
        dashboardViewModel.budgetProgressList(transactions: viewModel.allTransactions)
    }

    var body: some View {
        NavigationStack {
            Group {
                if dashboardViewModel.budgets.isEmpty {
                    emptyBudgetsView
                } else {
                    List {
                        ForEach(progressList) { item in
                            budgetCard(for: item)
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        Task {
                                            await dashboardViewModel.deleteBudget(category: item.category)
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                .swipeActions(edge: .leading) {
                                    Button {
                                        selectedBudgetForEdit = MonthlyBudget(
                                            category: item.category,
                                            monthlyLimit: item.budgetLimit
                                        )
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    .tint(.orange)
                                }
                        }
                    }
                    .listStyle(.plain)
                    .background(Color(UIColor.systemGroupedBackground))
                }
            }
            .navigationTitle("Budgets")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddBudget = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundColor(.brandPrimary)
                    }
                }
            }
            .sheet(isPresented: $showingAddBudget) {
                SetBudgetSheet(existingBudget: nil) { category, limit in
                    Task {
                        await dashboardViewModel.saveBudget(category: category, limit: limit)
                    }
                }
            }
            .sheet(item: $selectedBudgetForEdit) { budget in
                SetBudgetSheet(existingBudget: budget) { category, limit in
                    Task {
                        await dashboardViewModel.saveBudget(category: category, limit: limit)
                    }
                }
            }
            .task {
                await dashboardViewModel.loadBudgets()
            }
        }
    }

    // MARK: - Subviews

    private func budgetCard(for item: BudgetProgress) -> some View {
        let cat = TransactionCategory.category(named: item.category)
        let barColor: Color = item.isOverBudget ? .expenseRed : (item.isWarning ? .orange : Color(hex: cat.hexColor))

        return VStack(spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(Color(hex: cat.hexColor).opacity(0.15))
                        .frame(width: 40, height: 40)
                    Image(systemName: cat.iconName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: cat.hexColor))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.category)
                        .font(.headline)
                        .foregroundColor(.primary)

                    if item.isOverBudget {
                        Text("Over budget by \(CurrencyFormatter.format(item.currentSpent - item.budgetLimit))")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.expenseRed)
                    } else {
                        Text("\(CurrencyFormatter.format(item.remaining)) remaining")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(CurrencyFormatter.format(item.currentSpent))")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(item.isOverBudget ? .expenseRed : .primary)

                    Text("of \(CurrencyFormatter.format(item.budgetLimit))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            // Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.secondary.opacity(0.15))
                        .frame(height: 8)

                    Capsule()
                        .fill(barColor)
                        .frame(width: min(geo.size.width * CGFloat(item.percentageUsed), geo.size.width), height: 8)
                }
            }
            .frame(height: 8)

            HStack {
                Text(String(format: "%.0f%% used", item.percentageUsed * 100))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }

    private var emptyBudgetsView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 48))
                .foregroundColor(.secondary.opacity(0.4))

            Text("No Budgets Configured")
                .font(.headline)

            Text("Set spending limits for categories like Groceries, Dining, or Shopping to prevent overspending.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button {
                showingAddBudget = true
            } label: {
                Label("Create Budget", systemImage: "plus")
                    .fontWeight(.semibold)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.brandPrimary)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemGroupedBackground))
    }
}
