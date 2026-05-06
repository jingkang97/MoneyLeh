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
    
    var percentageChange: Double {
        let current = spending
        let previous: Double
        
        switch selectedPeriod {
        case "Daily":
            previous = transactions
                .filter { Calendar.current.isDateInYesterday($0.date) }
                .reduce(0) { $0 + $1.amount }
        case "Weekly":
            let lastWeekStart = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date())!
            previous = transactions
                .filter {
                    let cal = Calendar.current
                    return cal.isDate($0.date, equalTo: lastWeekStart, toGranularity: .weekOfYear)
                }
                .reduce(0) { $0 + $1.amount }
        case "Monthly":
            let lastMonth = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
            previous = transactions
                .filter {
                    Calendar.current.isDate($0.date, equalTo: lastMonth, toGranularity: .weekOfMonth)
                }
                .reduce(0) { $0 + $1.amount }
        default:
            return 0
        }
        
        guard previous > 0 else { return 0 }
        return ((current - previous) / previous) * 100
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
        loading = true
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        do {
            transactions = try await service.fetchLastTwoMonths()
        } catch {
            self.error = error
        }
        loading = false
    }
}
