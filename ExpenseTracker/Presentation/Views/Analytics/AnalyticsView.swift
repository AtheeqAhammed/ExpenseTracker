//
//  AnalyticsView.swift
//  ExpenseTracker
//
//  Created by Ateeq Ahmed on 29/10/26.
//  Visual analytics showing category breakdowns, distribution charts, and spending proportions.
//

import SwiftUI
import Charts

struct AnalyticsView: View {
    @ObservedObject var viewModel: TransactionsViewModel
    @ObservedObject var dashboardViewModel: DashboardViewModel
    @ObservedObject private var settings = AppSettings.shared

    @State private var selectedType: TransactionType = .expense

    private var breakdowns: [CategoryBreakdown] {
        dashboardViewModel.categoryBreakdown(for: viewModel.allTransactions, type: selectedType)
    }

    private var totalAmount: Decimal {
        breakdowns.reduce(Decimal(0)) { $0 + $1.totalAmount }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Type Selector
                    Picker("Type", selection: $selectedType) {
                        Text("Expenses").tag(TransactionType.expense)
                        Text("Income").tag(TransactionType.income)
                    }
                    .pickerStyle(.segmented)

                    if breakdowns.isEmpty {
                        emptyAnalyticsView
                    } else {
                        // Category Pie/Donut Chart
                        donutChartView

                        // Category List Breakdown
                        breakdownListView
                    }
                }
                .padding()
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Analytics")
        }
    }

    // MARK: - Components

    private var donutChartView: some View {
        VStack(spacing: 12) {
            Text(selectedType == .expense ? "Expense Distribution" : "Income Sources")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            Chart(breakdowns) { item in
                let cat = TransactionCategory.category(named: item.category)
                SectorMark(
                    angle: .value("Amount", NSDecimalNumber(decimal: item.totalAmount).doubleValue),
                    innerRadius: .ratio(0.60),
                    angularInset: 1.5
                )
                .cornerRadius(5)
                .foregroundStyle(Color(hex: cat.hexColor))
            }
            .frame(height: 220)
            .chartBackground { chartProxy in
                GeometryReader { _ in
                    VStack(spacing: 2) {
                        Text("Total")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(CurrencyFormatter.format(totalAmount))
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
    }

    private var breakdownListView: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Category Breakdown")
                .font(.headline)

            VStack(spacing: 14) {
                ForEach(breakdowns) { item in
                    let cat = TransactionCategory.category(named: item.category)
                    VStack(spacing: 6) {
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: cat.hexColor).opacity(0.15))
                                    .frame(width: 32, height: 32)
                                Image(systemName: cat.iconName)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color(hex: cat.hexColor))
                            }

                            Text(item.category)
                                .font(.body)
                                .fontWeight(.medium)

                            Spacer()

                            VStack(alignment: .trailing, spacing: 2) {
                                Text(CurrencyFormatter.format(item.totalAmount))
                                    .font(.subheadline)
                                    .fontWeight(.semibold)

                                Text(String(format: "%.1f%% (%d)", item.percentage * 100, item.transactionCount))
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }

                        // Progress Bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.secondary.opacity(0.15))
                                    .frame(height: 6)

                                Capsule()
                                    .fill(Color(hex: cat.hexColor))
                                    .frame(width: geometry.size.width * CGFloat(item.percentage), height: 6)
                            }
                        }
                        .frame(height: 6)
                    }
                    if item.id != breakdowns.last?.id {
                        Divider()
                            .padding(.vertical, 2)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
    }

    private var emptyAnalyticsView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "chart.pie")
                .font(.system(size: 48))
                .foregroundColor(.secondary.opacity(0.4))

            Text("No Data Available")
                .font(.headline)

            Text("Add some \(selectedType == .expense ? "expenses" : "income") to view insights and category distribution.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
        }
        .frame(minHeight: 300)
    }
}
