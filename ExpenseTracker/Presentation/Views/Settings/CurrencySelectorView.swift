//
//  CurrencySelectorView.swift
//  ExpenseTracker
//
//  Searchable currency picker allowing users to configure their preferred currency.
//

import SwiftUI

struct CurrencySelectorView: View {
    @ObservedObject private var settings = AppSettings.shared
    @Environment(\.dismiss) private var dismiss
    @State private var searchQuery: String = ""

    private var filteredCurrencies: [AppCurrency] {
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if query.isEmpty {
            return AppCurrency.allCases
        }
        return AppCurrency.allCases.filter {
            $0.displayName.lowercased().contains(query) ||
            $0.code.lowercased().contains(query) ||
            $0.symbol.lowercased().contains(query)
        }
    }

    var body: some View {
        List {
            Section {
                ForEach(filteredCurrencies) { currency in
                    Button {
                        settings.selectedCurrency = currency
                        dismiss()
                    } label: {
                        HStack(spacing: 12) {
                            Text(currency.flag)
                                .font(.title2)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(currency.displayName)
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)

                                Text("\(currency.code) • \(currency.symbol)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            if settings.selectedCurrency == currency {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.brandPrimary)
                                    .font(.title3)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            } header: {
                Text("Select Default Currency")
            } footer: {
                Text("Currency updates immediately across all dashboard statistics, transaction records, charts, and budget limits.")
            }
        }
        .navigationTitle("Currency")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchQuery, prompt: "Search currency name, code, or symbol...")
    }
}
