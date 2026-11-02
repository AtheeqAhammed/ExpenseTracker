//
//  TransactionRowView.swift
//  ExpenseTracker
//
//  Displays a single transaction row with category badge, title, date, and signed amount.
//

import SwiftUI

struct TransactionRowView: View {
    let transaction: Transaction

    private var categoryInfo: TransactionCategory {
        TransactionCategory.category(named: transaction.category)
    }

    var body: some View {
        HStack(spacing: 14) {
            // Category Icon Badge
            ZStack {
                Circle()
                    .fill(Color(hex: categoryInfo.hexColor).opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: categoryInfo.iconName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(hex: categoryInfo.hexColor))
            }

            // Title & Category / Notes
            VStack(alignment: .leading, spacing: 3) {
                Text(transaction.title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Text(transaction.category)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if let notes = transaction.notes, !notes.isEmpty {
                        Text("•")
                            .font(.caption2)
                            .foregroundColor(.secondary.opacity(0.5))

                        Text(notes)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
            }

            Spacer()

            // Date & Amount
            VStack(alignment: .trailing, spacing: 3) {
                Text(CurrencyFormatter.formatSigned(transaction.amount, type: transaction.type))
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(transaction.type == .income ? Color.incomeGreen : Color.expenseRed)

                Text(transaction.date.timeString)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
    }
}
