//
//  ContentView.swift
//  ExpenseTracker
//
//  Created by Ateeq Ahmed on 29/10/26.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: TransactionsViewModel
    @ObservedObject var dashboardViewModel: DashboardViewModel

    var body: some View {
        MainTabView(
            viewModel: viewModel,
            dashboardViewModel: dashboardViewModel
        )
    }
}
