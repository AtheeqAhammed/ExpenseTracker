//
//  CategoryPickerView.swift
//  ExpenseTracker
//
//  Interactive grid selector for transaction categories.
//

import SwiftUI

struct CategoryPickerView: View {
    let type: TransactionType
    @Binding var selectedCategory: String

    private var availableCategories: [TransactionCategory] {
        TransactionCategory.categories(for: type)
    }

    private let columns = [
        GridItem(.adaptive(minimum: 80, maximum: 100), spacing: 12)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(availableCategories) { cat in
                let isSelected = selectedCategory.caseInsensitiveCompare(cat.name) == .orderedSame

                Button {
                    selectedCategory = cat.name
                } label: {
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(isSelected ? Color(hex: cat.hexColor) : Color(hex: cat.hexColor).opacity(0.15))
                                .frame(width: 44, height: 44)

                            Image(systemName: cat.iconName)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(isSelected ? .white : Color(hex: cat.hexColor))
                        }

                        Text(cat.name)
                            .font(.caption2)
                            .fontWeight(isSelected ? .bold : .regular)
                            .foregroundColor(isSelected ? .primary : .secondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isSelected ? Color(hex: cat.hexColor).opacity(0.1) : Color.clear)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color(hex: cat.hexColor) : Color.clear, lineWidth: 1.5)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
    }
}
