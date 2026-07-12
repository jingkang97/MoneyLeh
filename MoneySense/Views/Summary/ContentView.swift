//
//  ContentView.swift
//  MoneySense
//

import SwiftUI

struct ContentView: View {
    @Binding var isAddSheetPresented: Bool
    @State var summaryViewModel: SummaryViewModel
    @State var transactionViewModel: RecentTransactionViewModel
    @State private var navigationPath = NavigationPath()
    @State private var tabBarVisibility: Visibility = .visible
    /// Recreated after the add sheet closes so large-title / list insets reset (fixes See All layout after X dismiss).
    @State private var navigationStackID = UUID()
    private var currencyCode = Locale.current.currencyCode
    
    init(
        transactionViewModel: RecentTransactionViewModel,
        summaryViewModel: SummaryViewModel,
        isAddSheetPresented: Binding<Bool>
    ) {
        self._isAddSheetPresented = isAddSheetPresented
        self.transactionViewModel = transactionViewModel
        self.summaryViewModel = summaryViewModel
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            Group {
                if summaryViewModel.loading || summaryViewModel.hasData {
                    loadedView
                } else {
                    EmptyStateView()
                }
            }
            .task {
                guard !summaryViewModel.hasData && !summaryViewModel.loading else { return }
                await summaryViewModel.load()
            }
            .appNavigationHeader("Summary")
            .toolbarVisibility(tabBarVisibility, for: .tabBar)
            .navigationDestination(for: SummaryRoute.self) { route in
                switch route {
                case .allTransactions:
                    AllTransactionsView(
                        currencyCode: currencyCode,
                        onPop: showTabBar,
                        onDataChanged: refreshHomeData
                    )
                }
            }
        }
        .id(navigationStackID)
        .onChange(of: navigationPath.count) { _, count in
            if count == 0 {
                showTabBar()
            } else {
                tabBarVisibility = .hidden
            }
        }
        .onChange(of: isAddSheetPresented) { _, isPresented in
            if isPresented {
                navigationPath = NavigationPath()
                UIApplication.shared.endEditing()
            } else {
                // Sheet closed (X or submit): reset stack so the next See All push lays out correctly.
                navigationPath = NavigationPath()
                navigationStackID = UUID()
            }
            tabBarVisibility = .visible
        }
    }

    private func showTabBar() {
        withAnimation(.smooth(duration: 0.35)) {
            tabBarVisibility = .visible
        }
    }

    private func refreshHomeData() {
        Task {
            async let t1 = transactionViewModel.load()
            async let t2 = summaryViewModel.load()
            _ = await (t1, t2)
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
                    currencyCode: currencyCode,
                    isSeeAllDisabled: isAddSheetPresented || transactionViewModel.isLoading
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
