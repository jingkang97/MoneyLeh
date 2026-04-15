//
//  RecentTransactionView.swift
//  MoneySense
//
//  Created by Jing Kang Ng on 14/4/26.
//

import SwiftUI

struct RecentTransactionView: View {
    let transactions: [Transaction]
    let currencyCode: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Transactions")
                    .font(.headline)
                
                Spacer()
                
                Button {} label: {
                    HStack(spacing: 4) {
                        Text("See All")
                        Image(systemName: "chevron.right")
                    }
                    .font(.subheadline)
                }
            }
            .padding(.horizontal, 16)
            
            // Card
            VStack(spacing: 0) {
                ForEach(transactions.indices, id: \.self) { index in
                    let t = transactions[index]
                    
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(t.color.opacity(0.2))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: t.icon)
                                .foregroundColor(t.color)
                        }
                        
                        VStack(alignment: .leading) {
                            Text(t.title)
                            Text(t.date)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Text(t.amount, format: .currency(code: currencyCode))
                            .foregroundStyle(.red)
                    }
                    .padding()
                    
                    if index != transactions.count - 1 {
                        Divider().padding(.leading, 60)
                    }
                }
            }
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .shadow(color: .black.opacity(0.06), radius: 12, y: 4)
        }
    }
}
