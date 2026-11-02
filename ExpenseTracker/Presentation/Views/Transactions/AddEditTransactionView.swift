//
//  AddEditTransactionView.swift
//  ExpenseTracker
//
//  Form sheet for creating or editing income and expense transactions.
//

import SwiftUI

struct AddEditTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var settings = AppSettings.shared

    var existingTransaction: Transaction? = nil
    var onSave: (Transaction) -> Void

    @State private var title: String = ""
    @State private var amountString: String = ""
    @State private var type: TransactionType = .expense
    @State private var category: String = "Food & Dining"
    @State private var date: Date = Date()
    @State private var notes: String = ""

    private var isEditing: Bool {
        existingTransaction != nil
    }

    private var parsedAmount: Decimal? {
        Decimal(string: amountString.replacingOccurrences(of: ",", with: "."))
    }

    private var isValid: Bool {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        guard let amount = parsedAmount, amount > 0 else { return false }
        return true
    }

    var body: some View {
        NavigationStack {
            Form {
                // Section 1: Type Selection
                Section {
                    Picker("Transaction Type", selection: $type) {
                        ForEach(TransactionType.allCases, id: \.self) { t in
                            Text(t.displayName).tag(t)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: type) { _, newType in
                        let available = TransactionCategory.categories(for: newType)
                        if !available.contains(where: { $0.name == category }) {
                            category = available.first?.name ?? "Other"
                        }
                    }
                } header: {
                    Text("Type")
                }

                // Section 2: Details
                Section {
                    TextField("Title (e.g. Groceries)", text: $title)

                    HStack {
                        Text(settings.selectedCurrency.symbol)
                            .font(.headline)
                            .foregroundColor(.secondary)
                        TextField("0.00", text: $amountString)
                            .keyboardType(.decimalPad)
                            .font(.headline)
                    }

                    DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                } header: {
                    Text("Transaction Details")
                }

                // Section 3: Category Picker
                Section {
                    CategoryPickerView(type: type, selectedCategory: $category)
                } header: {
                    Text("Category")
                }

                // Section 4: Optional Notes
                Section {
                    TextField("Add notes or description...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                } header: {
                    Text("Notes (Optional)")
                }
            }
            .navigationTitle(isEditing ? "Edit Transaction" : "New Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Update" : "Save") {
                        guard let amount = parsedAmount else { return }
                        let saved = Transaction(
                            id: existingTransaction?.id ?? UUID().uuidString,
                            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                            amount: amount,
                            category: category,
                            date: date,
                            type: type,
                            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : notes
                        )
                        onSave(saved)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isValid)
                }
            }
            .onAppear {
                if let txn = existingTransaction {
                    title = txn.title
                    amountString = "\(txn.amount)"
                    type = txn.type
                    category = txn.category
                    date = txn.date
                    notes = txn.notes ?? ""
                } else {
                    type = settings.defaultTransactionType
                    category = TransactionCategory.categories(for: settings.defaultTransactionType).first?.name ?? "Food & Dining"
                }
            }
        }
    }
}
