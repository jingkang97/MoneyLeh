//
//  BreakdownCardView.swift
//  MoneySense
//
//  Created by Jing Kang Ng on 13/4/26.
//

import SwiftUI
import Charts
import Shimmer

struct BreakdownCardView: View {
    let data: [CategorySpending]
    let mockData: [CategorySpending] = MockData.cateogrySpending
    let total: Double
    let currencyCode: String
    let isLoading: Bool
    var body: some View {
        Card {
            Text("Monthly Breakdown")
                .font(.headline)
            
            HStack(spacing: 20) {

                // LEFT: Chart / Skeleton
                ZStack {
                    if isLoading {
                        Circle()
                            .strokeBorder(Color.secondary.opacity(0.2), lineWidth: 30)
                            .frame(width: 160, height: 160)
                    } else {
                        Chart(data) { item in
                            SectorMark(
                                angle: .value("Amount", item.amount),
                                innerRadius: .ratio(0.65),
                                angularInset: 3
                            )
                            .cornerRadius(6)
                            .foregroundStyle(item.color)
                        }
                    }

                    VStack {
                        Text(total.walletFormatted(currencyCode: currencyCode))
                            .font(.title2.bold())
                            .monospacedDigit()
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .frame(maxWidth: 120)
                            .redacted(reason: isLoading ? .placeholder : [])
                        Text("spent")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .redacted(reason: isLoading ? .placeholder : [])
                    }
                }
                .frame(height: 200)
 
                Spacer()
                
                // RIGHT: categories
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(isLoading ? mockData : data) { item in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(isLoading ? Color.secondary.opacity(0.2) : item.color)
                                .frame(width: 10, height: 10)

                            VStack(alignment: .leading) {
                                Text(item.category)
                                    .redacted(reason: isLoading ? .placeholder : [])
                                Text(item.amount, format: .currency(code: currencyCode))
                                    .foregroundStyle(.secondary)
                                    .redacted(reason: isLoading ? .placeholder : [])
                            }
                        }
                    }
                }
            }
            .shimmering(active: isLoading)
        }
    }
}
