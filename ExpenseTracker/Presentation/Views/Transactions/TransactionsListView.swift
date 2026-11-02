//
//  TransactionsListView.swift
//  ExpenseTracker
//
//  Full transactions browser with live search, filters, sorting, and swipe actions.
//

import SwiftUI

struct TransactionsListView: View {
    @ObservedObject var viewModel: TransactionsViewModel
    @ObservedObject private var settings = AppSettings.shared

    @State private var showingAddSheet = false
    @State private var transactionToEdit: Transaction? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter Bar
                filterHeaderView
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color(UIColor.systemBackground))

                Divider()

                // Content
                if viewModel.isLoading && viewModel.allTransactions.isEmpty {
                    Spacer()
                    ProgressView("Loading transactions...")
                    Spacer()
                } else if viewModel.filteredTransactions.isEmpty {
                    emptyStateView
                } else {
                    transactionsList
                }
            }
            .navigationTitle("Transactions")
            .searchable(text: $viewModel.searchQuery, prompt: "Search title, category, notes...")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Picker("Sort By", selection: $viewModel.sortOption) {
                            ForEach(TransactionSortOption.allCases) { opt in
                                Text(opt.rawValue).tag(opt)
                            }
                        }
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                    }
                }

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
            .sheet(item: $transactionToEdit) { txn in
                AddEditTransactionView(existingTransaction: txn) { updatedTxn in
                    Task {
                        await viewModel.updateTransaction(updatedTxn)
                    }
                }
            }
            .refreshable {
                await viewModel.syncRemote()
            }
        }
    }

    // MARK: - Subviews

    private var filterHeaderView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // All Pill
                filterPill(title: "All", isSelected: viewModel.selectedType == nil) {
                    viewModel.selectedType = nil
                }

                // Expenses Pill
                filterPill(title: "Expenses", isSelected: viewModel.selectedType == .expense) {
                    viewModel.selectedType = .expense
                }

                // Income Pill
                filterPill(title: "Income", isSelected: viewModel.selectedType == .income) {
                    viewModel.selectedType = .income
                }

                // Category Filter Menu
                Menu {
                    Button("All Categories") {
                        viewModel.selectedCategory = nil
                    }
                    Divider()
                    ForEach(TransactionCategory.allCategories) { cat in
                        Button {
                            viewModel.selectedCategory = cat.name
                        } label: {
                            Label(cat.name, systemImage: cat.iconName)
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(viewModel.selectedCategory ?? "Category")
                            .font(.subheadline)
                            .fontWeight(viewModel.selectedCategory != nil ? .semibold : .regular)
                        Image(systemName: "chevron.down")
                            .font(.caption2)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(viewModel.selectedCategory != nil ? Color.brandPrimary.opacity(0.15) : Color.secondary.opacity(0.1))
                    .foregroundColor(viewModel.selectedCategory != nil ? .brandPrimary : .secondary)
                    .cornerRadius(20)
                }
            }
        }
    }

    private func filterPill(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(isSelected ? Color.brandPrimary : Color.secondary.opacity(0.1))
                .foregroundColor(isSelected ? .white : .secondary)
                .cornerRadius(20)
        }
    }

    private var transactionsList: some View {
        List {
            ForEach(viewModel.groupedTransactions, id: \.header) { group in
                Section {
                    ForEach(group.items) { txn in
                        TransactionRowView(transaction: txn)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                transactionToEdit = txn
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    Task {
                                        await viewModel.deleteTransaction(id: txn.id)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    transactionToEdit = txn
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(.orange)
                            }
                    }
                } header: {
                    Text(group.header)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "creditcard.and.123")
                .font(.system(size: 48))
                .foregroundColor(.secondary.opacity(0.4))

            Text("No Transactions Found")
                .font(.headline)
                .foregroundColor(.primary)

            Text("Try modifying your filter, or add a new transaction.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button {
                showingAddSheet = true
            } label: {
                Label("Add Transaction", systemImage: "plus")
                    .fontWeight(.semibold)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.brandPrimary)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            Spacer()
        }
    }
}
