//
//  RecentTransactionModel.swift
//  MoneySense
//
//  Created by Jing Kang Ng on 19/4/26.
//
import SwiftUI

struct RecentTransaction: Identifiable {
    let id = UUID()
    let title: String
    let date: String
    let amount: Double
    let icon: String
    let color: Color
}
