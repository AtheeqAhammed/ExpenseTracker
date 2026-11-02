//
//  SetBudgetSheet.swift
//  ExpenseTracker
//
//  Created by Ateeq Ahmed on 29/10/26.
//  Sheet to configure monthly spending limit for a specific category.
//

import SwiftUI

struct SetBudgetSheet: View {
    @Environment(\.dismiss) private var dismiss
    let existingBudget: MonthlyBudget?
    var onSave: (String, Decimal) -> Void

    @State private var selectedCategory: String = "Food & Dining"
    @State private var limitString: String = ""

    private var parsedLimit: Decimal? {
        Decimal(string: limitString.replacingOccurrences(of: ",", with: "."))
    }

    private var isValid: Bool {
        guard let limit = parsedLimit, limit > 0 else { return false }
        return true
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(TransactionCategory.categories(for: .expense)) { cat in
                            Text(cat.name).tag(cat.name)
                        }
                    }
                    .disabled(existingBudget != nil)

                    HStack {
                        Text("$")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        TextField("Monthly Limit (e.g. 500)", text: $limitString)
                            .keyboardType(.decimalPad)
                            .font(.headline)
                    }
                } header: {
                    Text("Budget Configuration")
                } footer: {
                    Text("Track monthly spending and receive visual warnings when nearing this threshold.")
                }
            }
            .navigationTitle(existingBudget != nil ? "Edit Budget" : "New Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard let limit = parsedLimit else { return }
                        onSave(selectedCategory, limit)
                        dismiss()
                    }
                    .disabled(!isValid)
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                if let budget = existingBudget {
                    selectedCategory = budget.category
                    limitString = "\(budget.monthlyLimit)"
                }
            }
        }
    }
}
