//
//  ContentView.swift
//  MoneySense
//

import SwiftUI

struct ContentView: View {
    @State var summaryViewModel: SummaryViewModel
    @State var transactionViewModel: RecentTransactionViewModel
    private var currencyCode = Locale.current.currencyCode
    
    init(transactionViewModel: RecentTransactionViewModel, summaryViewModel: SummaryViewModel) {
            self.transactionViewModel = transactionViewModel
            self.summaryViewModel = summaryViewModel
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    SpendingCardView(
                        spending: summaryViewModel.spending,
                        selectedPeriod: $summaryViewModel.selectedPeriod,
                        formattedDate: summaryViewModel.formattedDate,
                        currencyCode: currencyCode,
                        isLoading: summaryViewModel.loading,
                        percentageChange: summaryViewModel.percentageChange,
                        onPeriodChange: { summaryViewModel.selectedPeriod = $0 }
                    )
                    
                    BreakdownCardView(
                        data: summaryViewModel.sortedBreakdownData,
                        total: summaryViewModel.breakdownTotal,
                        currencyCode: currencyCode,
                        isLoading: summaryViewModel.loading
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
                await summaryViewModel.load()
            }
            .refreshable {
                print("🔄 refreshing transactionViewModel:", ObjectIdentifier(transactionViewModel))
                await Task {
                        await summaryViewModel.load()
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
