//
//  RecentTransactionView.swift
//  MoneySense
//
//  Created by Jing Kang Ng on 14/4/26.
//

import SwiftUI

struct RecentTransactionView: View {
    @StateObject private var viewModel = RecentTransactionViewModel()
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
            
            Card(spacing: 0, padding: 0) {
                ForEach(viewModel.transactions.indices, id: \.self) { index in
                    TransactionRowView(transaction: viewModel.transactions[index], currencyCode: currencyCode)
        
                    if index != viewModel.transactions.count - 1 {
                        Divider().padding(.leading, 60)
                    }
                }
            }
            
        }
        .task {
            await viewModel.load()
        }
    }
}
