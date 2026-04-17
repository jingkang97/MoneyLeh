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
    var spending: Double = 140.10
    var selectedPeriod: String = "Daily"
    
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
    
    var sortedBreakdownData: [CategorySpending] {
        MockData.cateogrySpending.sorted {$0.amount > $1.amount}
    }
    
    var breakdownTotal: Double {
        MockData.cateogrySpending.reduce(0) { $0 + $1.amount }
    }
}
