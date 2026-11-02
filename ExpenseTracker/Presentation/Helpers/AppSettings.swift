//
//  AppSettings.swift
//  ExpenseTracker
//
//  Centralized application settings and user preferences manager.
//

import SwiftUI
import Combine

/// Supported visual appearance color schemes.
enum AppearanceMode: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"

    var id: String { rawValue }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

/// Manages app preferences, selected currency, security toggles, and appearance.
@MainActor
final class AppSettings: ObservableObject {
    static let shared = AppSettings()

    // MARK: - Published Preferences

    @Published var selectedCurrency: AppCurrency {
        didSet {
            UserDefaults.standard.set(selectedCurrency.rawValue, forKey: "app_selected_currency")
            CurrencyFormatter.updateCurrency(selectedCurrency)
        }
    }

    @Published var defaultTransactionType: TransactionType {
        didSet {
            UserDefaults.standard.set(defaultTransactionType.rawValue, forKey: "app_default_transaction_type")
        }
    }

    @Published var budgetWarningThreshold: Double {
        didSet {
            UserDefaults.standard.set(budgetWarningThreshold, forKey: "app_budget_warning_threshold")
        }
    }

    @Published var isBiometricsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isBiometricsEnabled, forKey: "app_biometrics_enabled")
        }
    }

    @Published var hideBalancesInSwitcher: Bool {
        didSet {
            UserDefaults.standard.set(hideBalancesInSwitcher, forKey: "app_hide_balances")
        }
    }

    @Published var appearanceMode: AppearanceMode {
        didSet {
            UserDefaults.standard.set(appearanceMode.rawValue, forKey: "app_appearance_mode")
        }
    }

    @Published var lastSyncDate: Date? {
        didSet {
            if let lastSyncDate {
                UserDefaults.standard.set(lastSyncDate.timeIntervalSince1970, forKey: "app_last_sync_timestamp")
            } else {
                UserDefaults.standard.removeObject(forKey: "app_last_sync_timestamp")
            }
        }
    }

    // MARK: - Initialization

    init() {
        // Resolve currency: saved preference > device locale detection > fallback USD
        if let savedCode = UserDefaults.standard.string(forKey: "app_selected_currency"),
           let currency = AppCurrency(rawValue: savedCode) {
            self.selectedCurrency = currency
        } else if Locale.current.region?.identifier == "IN" || Locale.current.currency?.identifier == "INR" {
            self.selectedCurrency = .inr
        } else {
            self.selectedCurrency = .usd
        }

        let savedTypeRaw = UserDefaults.standard.string(forKey: "app_default_transaction_type") ?? TransactionType.expense.rawValue
        self.defaultTransactionType = TransactionType(rawValue: savedTypeRaw) ?? .expense

        let savedThreshold = UserDefaults.standard.double(forKey: "app_budget_warning_threshold")
        self.budgetWarningThreshold = savedThreshold > 0 ? savedThreshold : 0.85

        self.isBiometricsEnabled = UserDefaults.standard.bool(forKey: "app_biometrics_enabled")
        self.hideBalancesInSwitcher = UserDefaults.standard.bool(forKey: "app_hide_balances")

        let savedAppearance = UserDefaults.standard.string(forKey: "app_appearance_mode") ?? AppearanceMode.system.rawValue
        self.appearanceMode = AppearanceMode(rawValue: savedAppearance) ?? .system

        let lastSyncTime = UserDefaults.standard.double(forKey: "app_last_sync_timestamp")
        self.lastSyncDate = lastSyncTime > 0 ? Date(timeIntervalSince1970: lastSyncTime) : nil

        // Initialize CurrencyFormatter with active currency
        CurrencyFormatter.updateCurrency(self.selectedCurrency)
    }
}
