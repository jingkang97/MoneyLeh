//
//  MockData.swift
//  MoneySense
//
//  Created by Jing Kang Ng on 13/4/26.
//

import SwiftUI

enum MockData {
    static let cateogrySpending: [CategorySpending] = [
        .init(category: "Food & Drink", amount: 200, color: .gray),
        .init(category: "Transport", amount: 150, color: .gray),
        .init(category: "Shopping", amount: 300, color: .gray),
    ]
    
    static let transactions: [RecentTransaction] = [
        RecentTransaction(title: "luckin", date: "9 Mar 2026", amount: -32.01, icon: "fork.knife", color: .orange),
        RecentTransaction(title: "mrt", date: "9 Mar 2026", amount: -15.05, icon: "tram.fill", color: .blue),
        RecentTransaction(title: "kirby", date: "8 Mar 2026", amount: -20.00, icon: "gift.fill", color: .yellow),
    ]
    
    static let sources = ["CitiBank", "DBS", "Cash"]
    
    static let categories = ["Food & Drink", "Transport", "Shopping"]
}
