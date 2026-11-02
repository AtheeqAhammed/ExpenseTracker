//
//  Date+Extensions.swift
//  ExpenseTracker
//
//  Created by Ateeq Ahmed on 29/10/26.
//  Date formatting helpers for grouping transactions and user display.
//

import Foundation

extension Date {
    /// Formats as relative human header: "Today", "Yesterday", or "Oct 29, 2026".
    var relativeHeaderString: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(self) {
            return "Today"
        } else if calendar.isDateInYesterday(self) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: self)
        }
    }

    /// Formats as short time (e.g. "2:30 PM").
    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }

    /// Formats as standard ISO-8601 string.
    var iso8601String: String {
        ISO8601DateFormatter().string(from: self)
    }
}
