//
//  CategorySpending.swift
//  MoneySense
//
//  Created by Jing Kang Ng on 13/4/26.
//

import SwiftUI

struct CategorySpending: Identifiable {
    let id = UUID()
    let category: String
    let amount: Double
}

extension CategorySpending {
    var color: Color {
        switch category {
        case "Food": return .orange
        case "Transport": return .blue
        case "Shopping": return .yellow
        case "Others": return .purple
        default: return .gray
        }
    }
}
