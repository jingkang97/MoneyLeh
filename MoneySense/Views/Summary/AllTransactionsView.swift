//
//  AllTransactionsView.swift
//  MoneySense
//
//  Created by Jing Kang Ng on 29/5/26.
//

import SwiftUI

private struct TransactionMonthSection: Identifiable {
    let id: Date
    let month: Date
    let transactions: [Transaction]
}

private struct TransactionFilters {
    enum SortOrder: String, CaseIterable, Identifiable {
        case newestFirst = "Newest First"
        case oldestFirst = "Oldest First"

        var id: String { rawValue }
    }

    var sortOrder: SortOrder = .newestFirst
    var selectedMonths: Set<Date> = []

    var isActive: Bool {
        sortOrder != .newestFirst || !selectedMonths.isEmpty
    }

    mutating func selectAllMonths() {
        selectedMonths.removeAll()
    }

    mutating func toggleMonth(_ month: Date) {
        if selectedMonths.contains(month) {
            selectedMonths.remove(month)
        } else {
            selectedMonths.insert(month)
        }
    }

    func includes(transactionDate: Date, calendar: Calendar = .current) -> Bool {
        guard !selectedMonths.isEmpty else { return true }
        let monthStart = calendar.dateInterval(of: .month, for: transactionDate)!.start
        return selectedMonths.contains(monthStart)
    }
}

struct AllTransactionsView: View {
    @EnvironmentObject private var categoryStore: CategoryStore
    @EnvironmentObject private var sourceStore: SourceStore

    private static let searchBottomInset: CGFloat = 100
    /// Distance from the physical bottom edge (tab bar row; home indicator ignored).
    private static let searchBarBottomPadding: CGFloat = 10

    let currencyCode: String
    var onPop: () -> Void = {}
    var onDataChanged: () -> Void = {}

    @State private var transactions: [Transaction] = []
    @State private var editingTransaction: Transaction?
    @State private var isLoading = false
    @State private var searchText = ""
    @State private var isSearchExpanded = false
    @FocusState private var isSearchFocused: Bool
    @Namespace private var searchAnimation
    @State private var filters = TransactionFilters()
    @State private var showFilterSheet = false
    @State private var shareURL: URL?
    @State private var showPDFPreview = false
    @State private var isExporting = false
    @State private var exportError: String?

    private let collapsedSearchSize: CGFloat = 56

    private let service = TransactionService()

    private var displayedTransactions: [Transaction] {
        var result = transactions

        if !filters.selectedMonths.isEmpty {
            let calendar = Calendar.current
            result = result.filter { filters.includes(transactionDate: $0.date, calendar: calendar) }
        }

        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return result }
        return result.filter { matchesSearch($0, query: query) }
    }

    private var availableMonths: [Date] {
        let calendar = Calendar.current
        let months = Set(transactions.map { calendar.dateInterval(of: .month, for: $0.date)!.start })
        return months.sorted(by: >)
    }

    private var transactionsByMonth: [TransactionMonthSection] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: displayedTransactions) { transaction in
            calendar.dateInterval(of: .month, for: transaction.date)!.start
        }

        let sectionSort: (TransactionMonthSection, TransactionMonthSection) -> Bool = {
            filters.sortOrder == .newestFirst ? $0.month > $1.month : $0.month < $1.month
        }
        let itemSort: (Transaction, Transaction) -> Bool = {
            filters.sortOrder == .newestFirst ? $0.date > $1.date : $0.date < $1.date
        }

        return grouped
            .map { month, items in
                TransactionMonthSection(
                    id: month,
                    month: month,
                    transactions: items.sorted(by: itemSort)
                )
            }
            .sorted(by: sectionSort)
    }

    private var isSearching: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var showsEmptyState: Bool {
        transactionsByMonth.isEmpty && (isSearching || filters.isActive)
    }

    private var canExport: Bool {
        !displayedTransactions.isEmpty
    }

    private var exportPeriodDescription: String {
        if !filters.selectedMonths.isEmpty {
            let sortedMonths = filters.selectedMonths.sorted(by: >)
            let labels = sortedMonths.map { $0.formatted(.dateTime.month(.wide).year()) }
            return labels.joined(separator: ", ")
        }
        if isSearching {
            return "Search results for \"\(searchText)\""
        }
        let dates = displayedTransactions.map(\.date)
        guard let earliest = dates.min(), let latest = dates.max() else {
            return "All Transactions"
        }
        if Calendar.current.isDate(earliest, equalTo: latest, toGranularity: .day) {
            return earliest.formatted(date: .long, time: .omitted)
        }
        return "\(earliest.formatted(date: .abbreviated, time: .omitted)) – \(latest.formatted(date: .abbreviated, time: .omitted))"
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            transactionList
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            searchBar
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Transactions")
        .navigationBarTitleDisplayMode(.large)
        .toolbarVisibility(.hidden, for: .tabBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onDisappear(perform: onPop)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    Button {
                        showFilterSheet = true
                    } label: {
                        Image(systemName: filters.isActive ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease")
                    }
                    .foregroundStyle(filters.isActive ? .blue : .primary)

                    Button {
                        exportStatement()
                    } label: {
                        Label {
                            Text("View")
                                .font(.subheadline.weight(.medium))
                        } icon: {
                            Image("FileEarmarkPDF")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                        }
                        .labelStyle(.titleAndIcon)
                    }
                    .accessibilityLabel("View statement")
                    .disabled(!canExport || isExporting)
                }
                .padding(.horizontal, 8)
            }
        }
        .task {
            await loadTransactions()
        }
        .sheet(item: $editingTransaction) { transaction in
            AddTransactionView(mode: .edit(transaction)) {
                Task {
                    await reloadData()
                }
            }
            .environmentObject(categoryStore)
            .environmentObject(sourceStore)
        }
        .sheet(isPresented: $showFilterSheet) {
            TransactionFilterSheet(
                filters: $filters,
                availableMonths: availableMonths
            )
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $showPDFPreview, onDismiss: cleanupExportedFile) {
            if let shareURL {
                TransactionStatementPreviewSheet(pdfURL: shareURL)
            }
        }
        .alert("Export Failed", isPresented: .constant(exportError != nil)) {
            Button("OK") { exportError = nil }
        } message: {
            Text(exportError ?? "")
        }
    }

    private var transactionList: some View {
        List {
            if showsEmptyState {
                Group {
                    if isSearching {
                        ContentUnavailableView.search(text: searchText)
                    } else {
                        ContentUnavailableView(
                            "No Transactions",
                            systemImage: "line.3.horizontal.decrease.circle",
                            description: Text("Try a different month or reset your filters.")
                        )
                    }
                }
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            } else {
                ForEach(transactionsByMonth) { section in
                    Section {
                        ForEach(section.transactions) { transaction in
                            transactionRow(transaction, isLastInSection: transaction.id == section.transactions.last?.id)
                        }
                    } header: {
                        HStack(alignment: .firstTextBaseline) {
                            Text(section.month, format: .dateTime.month(.wide).year())
                                .font(.headline)
                                .foregroundStyle(.primary)

                            Spacer()

                            Text(monthTotal(for: section.transactions), format: .currency(code: currencyCode))
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                        .textCase(nil)
                    }
                }
            }
        }
        .listStyle(.plain)
        .listRowSpacing(0)
        .scrollContentBackground(.visible)
        .scrollDismissesKeyboard(.interactively)
        .contentMargins(.bottom, Self.searchBottomInset, for: .scrollContent)
        .overlay {
            if isLoading && transactions.isEmpty {
                ProgressView()
            }
            if isExporting {
                ZStack {
                    Color.black.opacity(0.15).ignoresSafeArea()
                    ProgressView("Preparing PDF…")
                        .padding(20)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                }
            }
        }
    }

    @ViewBuilder
    private func transactionRow(_ transaction: Transaction, isLastInSection: Bool) -> some View {
        VStack(spacing: 0) {
            TransactionRowView(transaction: transaction, currencyCode: currencyCode)

            if !isLastInSection {
                Divider()
                    .padding(.leading, 60)
            }
        }
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                Task { await deleteTransaction(transaction) }
            } label: {
                Label("Delete", systemImage: "trash.fill")
            }

            Button {
                editingTransaction = transaction
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.orange)
        }
    }

    private func loadTransactions() async {
        isLoading = true
        defer { isLoading = false }

        do {
            transactions = try await service.fetchAll()
        } catch {
            print("❌ Failed to load all transactions:", error)
        }
    }

    private func deleteTransaction(_ transaction: Transaction) async {
        do {
            try await service.delete(id: transaction.id)
            withAnimation {
                transactions.removeAll { $0.id == transaction.id }
            }
            onDataChanged()
        } catch {
            print("❌ Failed to delete transaction:", error)
        }
    }

    private func reloadData() async {
        await loadTransactions()
        onDataChanged()
    }

    private func exportStatement() {
        guard canExport else { return }

        isExporting = true
        let sections = transactionsByMonth.map { (month: $0.month, transactions: $0.transactions) }
        let configuration = TransactionStatementPDFGenerator.Configuration(
            currencyCode: currencyCode,
            periodDescription: exportPeriodDescription,
            sortDescription: filters.sortOrder.rawValue,
            sources: sourceStore.sources,
            breakdown: exportBreakdownData()
        )

        Task {
            defer { isExporting = false }

            do {
                cleanupExportedFile()
                let url = try TransactionStatementPDFGenerator().generatePDF(
                    sections: sections,
                    configuration: configuration
                )
                shareURL = url
                showPDFPreview = true
            } catch {
                exportError = error.localizedDescription
            }
        }
    }

    private func cleanupExportedFile() {
        if let shareURL {
            try? FileManager.default.removeItem(at: shareURL)
        }
        shareURL = nil
    }

    private func exportBreakdownData() -> [TransactionStatementPDFGenerator.BreakdownItem] {
        let grouped = Dictionary(grouping: displayedTransactions) { $0.category?.name ?? "Other" }

        return grouped
            .map { name, items in
                TransactionStatementPDFGenerator.BreakdownItem(
                    category: name,
                    amount: items.reduce(0) { $0 + $1.amount },
                    hexColor: items.first?.category?.color ?? "#888888"
                )
            }
            .sorted { $0.amount > $1.amount }
    }

    private var searchBar: some View {
        HStack(spacing: 0) {
            if isSearchExpanded {
                expandedSearchField
                    .matchedGeometryEffect(id: "searchBar", in: searchAnimation)
            } else {
                Spacer(minLength: 0)
                collapsedSearchButton
                    .matchedGeometryEffect(id: "searchBar", in: searchAnimation)
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, Self.searchBarBottomPadding)
        .ignoresSafeArea(edges: .bottom)
    }

    private var collapsedSearchButton: some View {
        Button {
            expandSearch()
        } label: {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.black)
                .frame(width: collapsedSearchSize, height: collapsedSearchSize)
        }
        .glassEffect(.regular.interactive(), in: Circle())
    }

    private var expandedSearchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.black)

            TextField("Search transactions", text: $searchText)
                .textFieldStyle(.plain)
                .focused($isSearchFocused)
                .submitLabel(.search)

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.black)
                }
            }

            Button {
                collapseSearch()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.black)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity)
        .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: collapsedSearchSize / 2, style: .continuous))
    }

    private func expandSearch() {
        withAnimation(.spring(response: 0.42, dampingFraction: 0.86)) {
            isSearchExpanded = true
        }
        isSearchFocused = true
    }

    private func collapseSearch() {
        isSearchFocused = false
        withAnimation(.spring(response: 0.42, dampingFraction: 0.86)) {
            isSearchExpanded = false
            searchText = ""
        }
    }

    private func monthTotal(for transactions: [Transaction]) -> Double {
        transactions.reduce(0) { $0 + $1.amount }
    }

    private func matchesSearch(_ transaction: Transaction, query: String) -> Bool {
        let needle = query.lowercased()
        var haystack: [String] = [
            transaction.description ?? "",
            transaction.notes ?? "",
            transaction.category?.name ?? "",
            transaction.category?.icon ?? "",
            String(transaction.amount),
            String(transaction.amountInCents),
            transaction.amount.formatted(.currency(code: currencyCode)),
            transaction.date.formatted(date: .abbreviated, time: .omitted),
            transaction.date.formatted(date: .long, time: .omitted),
            transaction.date.formatted(.dateTime.month(.wide).year()),
            transaction.date.formatted(.dateTime.day().month().year())
        ]

        if let source = sourceStore.sources.first(where: { $0.id == transaction.sourceId }) {
            haystack.append(source.name)
        }

        return haystack.contains { $0.lowercased().contains(needle) }
    }
}

private struct TransactionFilterSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var filters: TransactionFilters
    let availableMonths: [Date]

    var body: some View {
        NavigationStack {
            Form {
                Section("Sort") {
                    Picker("Order", selection: $filters.sortOrder) {
                        ForEach(TransactionFilters.SortOrder.allCases) { order in
                            Text(order.rawValue).tag(order)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }

                Section("Month") {
                    Button {
                        filters.selectAllMonths()
                    } label: {
                        HStack {
                            Text("All Months")
                            Spacer()
                            if filters.selectedMonths.isEmpty {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.accentColor)
                            }
                        }
                    }
                    .foregroundStyle(.primary)

                    ForEach(availableMonths, id: \.self) { month in
                        Button {
                            filters.toggleMonth(month)
                        } label: {
                            HStack {
                                Text(month, format: .dateTime.month(.wide).year())
                                Spacer()
                                if filters.selectedMonths.contains(month) {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(Color.accentColor)
                                }
                            }
                        }
                        .foregroundStyle(.primary)
                    }
                }
            }
            .navigationTitle("Filter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if filters.isActive {
                        Button("Reset") {
                            filters = TransactionFilters()
                        }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
