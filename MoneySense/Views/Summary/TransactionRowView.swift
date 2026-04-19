//
//  TransactionRowview.swift
//  MoneySense
//
//  Created by Jing Kang Ng on 16/4/26.
//

import SwiftUI

struct TransactionRowView: View {
    let transaction: RecentTransaction
    let currencyCode: String
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(transaction.color.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: transaction.icon)
                    .foregroundColor(transaction.color)
            }
            
            VStack(alignment: .leading) {
                Text(transaction.title)
                Text(transaction.date)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text(transaction.amount, format: .currency(code: currencyCode))
                .foregroundStyle(.red)
        }
        .padding()
    }
}
