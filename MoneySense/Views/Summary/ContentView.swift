//
//  ContentView.swift
//  MoneySense
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = SummaryViewModel()
    private var currencyCode = Locale.current.currencyCode
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    SpendingCardView(
                        spending: viewModel.spending,
                        selectedPeriod: $viewModel.selectedPeriod,
                        formattedDate: viewModel.formattedDate,
                        currencyCode: currencyCode,
                        onPeriodChange: { viewModel.selectedPeriod = $0 }
                    )
                    
                    BreakdownCardView(
                        data: viewModel.sortedBreakdownData,
                        total: viewModel.breakdownTotal,
                        currencyCode: currencyCode
                    )
                    
                    RecentTransactionView(
                        transactions: MockData.transactions,
                        currencyCode: currencyCode
                    )
                    .padding(.top, 8)
                }
                .padding()
            }
            .navigationTitle("Summary")
            .toolbarTitleDisplayMode(.inlineLarge)
            .toolbar {
                AvatarView()
            }
        }
    }
}
