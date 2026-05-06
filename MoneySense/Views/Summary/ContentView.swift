//
//  ContentView.swift
//  MoneySense
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = SummaryViewModel()
    @State var transactionViewModel: RecentTransactionViewModel
    private var currencyCode = Locale.current.currencyCode
    
    init(transactionViewModel: RecentTransactionViewModel) {
            self.transactionViewModel = transactionViewModel
        }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    SpendingCardView(
                        spending: viewModel.spending,
                        selectedPeriod: $viewModel.selectedPeriod,
                        formattedDate: viewModel.formattedDate,
                        currencyCode: currencyCode,
                        isLoading: viewModel.loading,
                        percentageChange: viewModel.percentageChange,
                        onPeriodChange: { viewModel.selectedPeriod = $0 }
                    )
                    
                    BreakdownCardView(
                        data: viewModel.sortedBreakdownData,
                        total: viewModel.breakdownTotal,
                        currencyCode: currencyCode,
                        isLoading: viewModel.loading
                    )
                    
                    RecentTransactionView(
                        viewModel: transactionViewModel,
                        currencyCode: currencyCode
                    )
                    .padding(.top, 8)
                }
                .padding()
            }
            .task {
                await viewModel.load()
            }
            .refreshable {
                print("🔄 refreshing transactionViewModel:", ObjectIdentifier(transactionViewModel))
                await Task {
                        await viewModel.load()
                        await transactionViewModel.load()
                    
                    }.value            }
            .navigationTitle("Summary")
            .toolbarTitleDisplayMode(.inlineLarge)
            .toolbar {
                AvatarView()
            }
        }
    }
}
