//
//  MainTabView.swift
//  ExpenseTracker
//
//  Created by Ateeq Ahmed on 29/10/26.
//  Root navigation coordinator presenting the tabbed application interface.
//

import SwiftUI

enum AppTab: Hashable {
    case dashboard
    case transactions
    case analytics
    case budgets
    case settings
}

struct MainTabView: View {
    @ObservedObject var viewModel: TransactionsViewModel
    @ObservedObject var dashboardViewModel: DashboardViewModel

    @State private var selectedTab: AppTab = .dashboard

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView(
                viewModel: viewModel,
                dashboardViewModel: dashboardViewModel,
                onSeeAllTapped: {
                    selectedTab = .transactions
                }
            )
            .tabItem {
                Label("Dashboard", systemImage: "house.fill")
            }
            .tag(AppTab.dashboard)

            TransactionsListView(viewModel: viewModel)
                .tabItem {
                    Label("Transactions", systemImage: "list.bullet.rectangle.fill")
                }
                .tag(AppTab.transactions)

            AnalyticsView(
                viewModel: viewModel,
                dashboardViewModel: dashboardViewModel
            )
            .tabItem {
                Label("Analytics", systemImage: "chart.pie.fill")
            }
            .tag(AppTab.analytics)

            BudgetsView(
                viewModel: viewModel,
                dashboardViewModel: dashboardViewModel
            )
            .tabItem {
                Label("Budgets", systemImage: "chart.bar.xaxis")
            }
            .tag(AppTab.budgets)

            SettingsView(viewModel: viewModel)
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(AppTab.settings)
        }
        .tint(Color.brandPrimary)
    }
}
