//
//  ContentView.swift
//  MoneySense
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = SummaryViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    SpendingCardView(
                        spending: viewModel.spending,
                        selectedPeriod: viewModel.selectedPeriod,
                        formattedDate: viewModel.formattedDate,
                        currencyCode: viewModel.currencyCode,
                        onPeriodChange: { viewModel.selectedPeriod = $0 }
                    )
                    
                    BreakdownCardView(
                        data: viewModel.sortedBreakdownData,
                        total: viewModel.breakdownTotal,
                        currencyCode: viewModel.currencyCode
                    )
                    
                    RecentTransactionView(
                        transactions: MockData.transactions,
                        currencyCode: viewModel.currencyCode
                    )
                    .padding(.top, 8)
                }
                .padding()
            }
            .navigationTitle("Summary")
            .toolbarTitleDisplayMode(.inlineLarge)
            .toolbar {
                ZStack {
                    Circle().fill(.blue)
                    Image(systemName: "person.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                }
                .frame(width: 34, height: 34)
            }
        }
    }
}
