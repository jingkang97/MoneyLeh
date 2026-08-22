//
//  StatisticsViewModel.swift
//  MoneySense
//

import SwiftUI
import Observation

@MainActor
@Observable
class StatisticsViewModel {
    var transactions: [Transaction] = []
    var selectedPeriod: String = "Weekly"
    var loading = false
    var error: (any Error)?

    let periods = ["Weekly", "Monthly", "Yearly"]

    private let service = TransactionService()

    var hasData: Bool {
        !transactions.isEmpty
    }

    var periodTransactions: [Transaction] {
        transactions.filter { isInSelectedPeriod($0.date) }
    }

    var spending: Double {
        periodTransactions.reduce(0) { $0 + $1.amount }
    }

    var spentInLabel: String {
        let now = Date()
        switch selectedPeriod {
        case "Weekly":
            return "spent this week"
        case "Monthly":
            return "spent in \(now.formatted(.dateTime.month(.abbreviated)))"
        case "Yearly":
            return "spent in \(now.formatted(.dateTime.year()))"
        default:
            return "spent"
        }
    }

    var percentageChange: Double? {
        let current = spending
        let calendar = Calendar.current

        switch selectedPeriod {
        case "Weekly":
            guard let lastWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: Date()) else { return nil }
            let previous = transactions
                .filter { calendar.isDate($0.date, equalTo: lastWeek, toGranularity: .weekOfYear) }
                .reduce(0) { $0 + $1.amount }
            guard previous > 0 else { return nil }
            return ((current - previous) / previous) * 100
        case "Monthly":
            guard let lastMonth = calendar.date(byAdding: .month, value: -1, to: Date()) else { return nil }
            let previous = transactions
                .filter { calendar.isDate($0.date, equalTo: lastMonth, toGranularity: .month) }
                .reduce(0) { $0 + $1.amount }
            guard previous > 0 else { return nil }
            return ((current - previous) / previous) * 100
        case "Yearly":
            guard let lastYear = calendar.date(byAdding: .year, value: -1, to: Date()) else { return nil }
            let previous = transactions
                .filter { calendar.isDate($0.date, equalTo: lastYear, toGranularity: .year) }
                .reduce(0) { $0 + $1.amount }
            guard previous > 0 else { return nil }
            return ((current - previous) / previous) * 100
        default:
            return nil
        }
    }

    var chipColor: Color {
        guard let change = percentageChange, change != 0 else { return .blue }
        return change < 0 ? .green : .red
    }

    var chipIcon: String {
        guard let change = percentageChange, change != 0 else { return "minus" }
        return change < 0 ? "arrowtriangle.down.fill" : "arrowtriangle.up.fill"
    }

    var chipLabel: String {
        guard let change = percentageChange else { return "New" }
        return change.cappedPercentLabel()
    }

    var categoryBreakdown: [CategorySpending] {
        let grouped = Dictionary(grouping: periodTransactions) { $0.category?.name ?? "Other" }
        let allNames = Set(transactions.map { $0.category?.name ?? "Other" })

        return allNames.map { name -> CategorySpending in
            let txns = grouped[name] ?? []
            let total = txns.reduce(0) { $0 + $1.amount }
            let colorHex = transactions.first { ($0.category?.name ?? "Other") == name }?.category?.color ?? "#888888"
            return CategorySpending(category: name, amount: total, color: Color(hex: colorHex))
        }
        .sorted { $0.amount > $1.amount }
    }

    var visibleCategoryBreakdown: [CategorySpending] {
        categoryBreakdown.filter { $0.amount > 0 }
    }

    func load(showSkeleton: Bool = false) async {
        guard !loading else { return }
        if showSkeleton || transactions.isEmpty {
            loading = true
        }
        do {
            let startOfLastYear = Calendar.current.date(
                byAdding: .year,
                value: -1,
                to: Date().startOfYear
            ) ?? Date()
            transactions = try await service.fetchSince(startOfLastYear)
        } catch {
            self.error = error
        }
        loading = false
    }

    private func isInSelectedPeriod(_ date: Date) -> Bool {
        let calendar = Calendar.current
        switch selectedPeriod {
        case "Weekly":
            return calendar.isDate(date, equalTo: Date(), toGranularity: .weekOfYear)
        case "Monthly":
            return calendar.isDate(date, equalTo: Date(), toGranularity: .month)
        case "Yearly":
            return calendar.isDate(date, equalTo: Date(), toGranularity: .year)
        default:
            return false
        }
    }
}
