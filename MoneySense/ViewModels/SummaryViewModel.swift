//
//  SummaryViewModel.swift
//  MoneySense
//
//  Created by Jing Kang Ng on 13/4/26.
//
import SwiftUI
import Observation

@Observable
class SummaryViewModel {
    var transactions: [Transaction] = []
    var selectedPeriod: String = "Daily"
    var loading = false
    var error: (any Error)?
    
    private let service = TransactionService()
    
    var hasData: Bool {
        !transactions.isEmpty
    }
    
    var weekRange: String {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        
        if let start = calendar.dateInterval(of: .weekOfYear, for: Date())?.start,
           let end = calendar.date(byAdding: .day, value: 6, to: start) {
            return "\(start.formatted(.dateTime.day().month())) - \(end.formatted(.dateTime.day().month()))"
        }
        return ""
    }
    
    var formattedDate: String {
        let now = Date()
        switch selectedPeriod {
        case "Daily": return now.formatted(.dateTime.day().month().year())
        case "Weekly": return weekRange
        case "Monthly": return now.formatted(.dateTime.month().year())
        default: return ""
        }
    }
    
    var spending: Double {
        switch selectedPeriod {
        case "Daily":
            return transactions
                .filter { Calendar.current.isDateInToday($0.date) }
                .reduce(0) { $0 + $1.amount }
        case "Weekly":
            return transactions
                .filter { Calendar.current.isDate($0.date, equalTo: Date(), toGranularity: .weekOfYear) }
                .reduce(0) { $0 + $1.amount }
        
        case "Monthly":
            return transactions
                .filter { Calendar.current.isDate($0.date, equalTo: Date(), toGranularity: .month) }
                .reduce(0) { $0 + $1.amount }
        default: return 0
        }
    }
    
    var percentageChange: Double? {
        let current = spending        
        switch selectedPeriod {
        case "Daily":
            for daysBack in 1...7 {
                guard let pastDate = Calendar.current.date(byAdding: .day, value: -daysBack, to: Date()) else { continue }
                let previous = transactions
                    .filter { Calendar.current.isDate($0.date, inSameDayAs: pastDate) }
                    .reduce(0) { $0 + $1.amount }
                if previous > 0 {
                    return ((current - previous) / previous) * 100
                }
            }
            return nil
        case "Weekly":
            let lastWeekStart = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date())!
            let previous = transactions
                .filter {
                    let cal = Calendar.current
                    return cal.isDate($0.date, equalTo: lastWeekStart, toGranularity: .weekOfYear)
                }
                .reduce(0) { $0 + $1.amount }
            guard previous > 0 else { return nil }
            return ((current - previous) / previous) * 100
        case "Monthly":
            let lastMonth = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
            let previous = transactions
                .filter {
                    Calendar.current.isDate($0.date, equalTo: lastMonth, toGranularity: .weekOfMonth)
                }
                .reduce(0) { $0 + $1.amount }
                guard previous > 0 else { return 0 }
                return ((current - previous) / previous) * 100
        default:
            return nil
        }
    }
    
    var breakdownTransactions: [Transaction] {
        transactions.filter { Calendar.current.isDate($0.date, equalTo: Date(), toGranularity: .month) }
    }
    
    var sortedBreakdownData: [CategorySpending] {
        let grouped = Dictionary(grouping: breakdownTransactions) { $0.category?.name ?? "Other" }
        
        let mapped = grouped.map { name, txns -> CategorySpending in
            let total = txns.reduce(0) { $0 + $1.amount }
            let colorHex = txns.first?.category?.color ?? "#888888"
            return CategorySpending(category: name, amount: total, color: Color(hex: colorHex))
        }
        return mapped.sorted { $0.amount > $1.amount }
    }
    
    var breakdownTotal: Double {
        breakdownTransactions.reduce(0) { $0 + $1.amount }
    }
    
    func load() async {
        guard !loading else { return }
        loading = true
        // try? await Task.sleep(nanoseconds: 1_000_000_000)
        do {
            transactions = try await service.fetchLastTwoMonths()
        } catch {
            self.error = error
        }
        loading = false
    }
}
