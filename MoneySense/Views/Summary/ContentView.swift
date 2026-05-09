//
//  ContentView.swift
//  MoneySense
//

import SwiftUI

struct ContentView: View {
    @State var summaryViewModel: SummaryViewModel
    @State var transactionViewModel: RecentTransactionViewModel
    var onAddTransaction: () -> Void
    private var currencyCode = Locale.current.currencyCode
    
    init(transactionViewModel: RecentTransactionViewModel, summaryViewModel: SummaryViewModel, onAddTransaction: @escaping() -> Void) {
        self.transactionViewModel = transactionViewModel
        self.summaryViewModel = summaryViewModel
        self.onAddTransaction = onAddTransaction
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if summaryViewModel.loading || summaryViewModel.hasData {
                    loadedView
                } else {
                    EmptyStateView(onAddTransaction: onAddTransaction)
                }
            }
            .task {
                guard !summaryViewModel.hasData && !summaryViewModel.loading else { return }
                await summaryViewModel.load()
            }
            .navigationTitle("Summary")
            .toolbarTitleDisplayMode(.inlineLarge)
            .toolbar {
                AvatarView()
            }
        }
    }
    
    private var loadedView: some View {
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
        .refreshable {
            print("🔄 refreshing transactionViewModel:", ObjectIdentifier(transactionViewModel))
            await Task {
                async let t1 = transactionViewModel.load()
                async let t2 = summaryViewModel.load()
                
                _ = await (t1, t2)
                
            }.value
        }
    }
}
