//
//  TransactionRowview.swift
//  MoneySense
//
//  Created by Jing Kang Ng on 16/4/26.
//

import SwiftUI

struct TransactionRowView: View {
    let transaction: Transaction
    let currencyCode: String
    
    private var categoryColor: Color {
        guard let hex = transaction.category?.color else { return .gray }
        return Color(hex: hex)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(categoryColor.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: transaction.category?.icon ?? "tag")
                    .foregroundColor(categoryColor)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.description ?? "Unnamed")
                Text(transaction.date, style: .date)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if let formattedUpdatedAt = transaction.formattedUpdatedAt {
                    Text("Edited \(formattedUpdatedAt)")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            
            Spacer()
            
            Text(transaction.amount, format: .currency(code: currencyCode))
                .foregroundStyle(.red)
        }
        .padding()
    }
}
