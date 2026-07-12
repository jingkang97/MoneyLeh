//
//  MainView.swift
//  MoneySense
//
//  Created by Jing Kang Ng on 13/4/26.
//
import SwiftUI

struct MainView: View {
    enum Tabs { case home, stats, budget, more, add }
    @State private var showAddSheet = false
    @State var selectedTab: Tabs = .home
    @State var transactionViewModel = RecentTransactionViewModel()
    @State var summaryViewModel = SummaryViewModel()
    @StateObject private var categoryStore = CategoryStore()
    @StateObject private var sourceStore = SourceStore()

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "house.fill", value: .home) {
                ContentView(
                    transactionViewModel: transactionViewModel,
                    summaryViewModel: summaryViewModel,
                    isAddSheetPresented: $showAddSheet
                )
                .environmentObject(categoryStore)
                .environmentObject(sourceStore)
            }
            Tab("Stats", systemImage: "chart.pie.fill", value: .stats) {
                StatisticsView()
            }
            Tab("Budget", systemImage: "wallet.pass.fill", value: .budget) {
                NavigationStack {
                    ScrollView { }
                        .appNavigationHeader("Budget")
                }
            }
            Tab("More", systemImage: "ellipsis.circle.fill", value: .more) {
                NavigationStack {
                    ScrollView { }
                        .appNavigationHeader("More")
                }
            }
            Tab("Add", systemImage: "plus", value: .add, role: .search) {}
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            if newValue == .add {
                showAddSheet = true
                selectedTab = oldValue
            }
        }
        .sheet(isPresented: $showAddSheet, onDismiss: {
            UIApplication.shared.endEditing()
        }) {
            AddTransactionView {
                Task {
                    async let t1 = transactionViewModel.load()
                    async let t2 = summaryViewModel.load()

                    _ = await (t1, t2)
                }
            }
            .environmentObject(categoryStore)
            .environmentObject(sourceStore)
        }
        .task {
            print("🔵 task fired")
            await categoryStore.load()
            print("✅ categories loaded:", categoryStore.categories.count)
            await sourceStore.load()
            print("✅ sources loaded:", sourceStore.sources.count)

        }
    }
}

#Preview {
    MainView().accessibilityHidden(true)
}
