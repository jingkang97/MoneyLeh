//
//  Transaction.swift
//  MoneySense
//
//  Created by Jing Kang Ng on 13/4/26.
//

import SwiftUI

struct Transaction: Identifiable {
    let id = UUID()
    let title: String
    let date: String
    let amount: Double
    let icon: String
    let color: Color
}
