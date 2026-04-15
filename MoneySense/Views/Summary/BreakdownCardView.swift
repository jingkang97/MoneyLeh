//
//  BreakdownCardView.swift
//  MoneySense
//
//  Created by Jing Kang Ng on 13/4/26.
//

import SwiftUI
import Charts

struct BreakdownCardView: View {
    let data: [CategorySpending]
    let total: Double
    let currencyCode: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Monthly Breakdown")
                .font(.headline)
            
            HStack(spacing: 20) {
                ZStack {
                    Chart(data) {
                        item in
                        SectorMark (
                            angle: .value("Amount", item.amount),
                            innerRadius: .ratio(0.65),
                            angularInset: 3
                        )
                        .cornerRadius(6)
                        .foregroundStyle(item.color)
                    }
                    
                    VStack {
                        Text(total, format: .currency(code: currencyCode))
                            .font(.title2.bold())
                        Text("spent")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(data) {
                        item in
                        HStack {
                            RoundedRectangle(cornerRadius: 3, style: .continuous)
                                .fill(item.color)
                                .frame(width: 10, height: 10)
                            
                            VStack(alignment: .leading) {
                                Text(item.category)
                                Text(item.amount, format: .currency(code: currencyCode))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: .black.opacity(0.06), radius: 12, y: 4)
    }
}
