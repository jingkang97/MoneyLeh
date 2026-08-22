//
//  CategorySpending.swift
//  MoneySense
//
//  Created by Jing Kang Ng on 13/4/26.
//

import SwiftUI

struct CategorySpending: Identifiable {
    var id: String { category }
    let category: String
    let amount: Double
    let color: Color
}
