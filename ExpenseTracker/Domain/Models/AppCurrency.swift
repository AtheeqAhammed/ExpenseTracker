//
//  AppCurrency.swift
//  ExpenseTracker
//
//  Supported currencies with localized symbols, ISO codes, and formatting metadata.
//

import Foundation

/// Supported currency definitions for user-selectable monetary representation.
enum AppCurrency: String, CaseIterable, Identifiable, Codable, Sendable {
    case inr = "INR"
    case usd = "USD"
    case eur = "EUR"
    case gbp = "GBP"
    case aed = "AED"
    case sar = "SAR"
    case cad = "CAD"
    case aud = "AUD"
    case jpy = "JPY"
    case sgd = "SGD"
    case cny = "CNY"
    case chf = "CHF"

    var id: String { rawValue }
    var code: String { rawValue }

    /// Standard display symbol (e.g. ₹, $, €, £)
    var symbol: String {
        switch self {
        case .inr: return "₹"
        case .usd: return "$"
        case .eur: return "€"
        case .gbp: return "£"
        case .aed: return "AED "
        case .sar: return "SAR "
        case .cad: return "CA$"
        case .aud: return "A$"
        case .jpy: return "¥"
        case .sgd: return "S$"
        case .cny: return "¥"
        case .chf: return "CHF "
        }
    }

    /// Country/Region emoji flag for intuitive selection
    var flag: String {
        switch self {
        case .inr: return "🇮🇳"
        case .usd: return "🇺🇸"
        case .eur: return "🇪🇺"
        case .gbp: return "🇬🇧"
        case .aed: return "🇦🇪"
        case .sar: return "🇸🇦"
        case .cad: return "🇨🇦"
        case .aud: return "🇦🇺"
        case .jpy: return "🇯🇵"
        case .sgd: return "🇸🇬"
        case .cny: return "🇨🇳"
        case .chf: return "🇨🇭"
        }
    }

    /// Full descriptive title
    var displayName: String {
        switch self {
        case .inr: return "Indian Rupee"
        case .usd: return "US Dollar"
        case .eur: return "Euro"
        case .gbp: return "British Pound"
        case .aed: return "UAE Dirham"
        case .sar: return "Saudi Riyal"
        case .cad: return "Canadian Dollar"
        case .aud: return "Australian Dollar"
        case .jpy: return "Japanese Yen"
        case .sgd: return "Singapore Dollar"
        case .cny: return "Chinese Yuan"
        case .chf: return "Swiss Franc"
        }
    }

    /// Locale identifier for formatting numbers and groupings
    var localeIdentifier: String {
        switch self {
        case .inr: return "en_IN"
        case .usd: return "en_US"
        case .eur: return "de_DE"
        case .gbp: return "en_GB"
        case .aed: return "ar_AE"
        case .sar: return "ar_SA"
        case .cad: return "en_CA"
        case .aud: return "en_AU"
        case .jpy: return "ja_JP"
        case .sgd: return "en_SG"
        case .cny: return "zh_CN"
        case .chf: return "de_CH"
        }
    }
}
