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

    private var isEmpty: Bool {
        !isLoading && (data.isEmpty || total == 0)
    }

    var body: some View {
        Card {
            Text("Monthly Breakdown")
                .font(.headline)

            if isEmpty {
                emptyState
            } else {
                chartContent
                    .shimmering(active: isLoading)
            }
        }
    }

    // MARK: - Filled / loading

    private var chartContent: some View {
        HStack(spacing: 20) {
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

                centerTotalLabel
            }
            .frame(height: 200)

            Spacer()

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
    }

    // MARK: - Empty (Apple-style)

    private var emptyState: some View {
        HStack(alignment: .center, spacing: 20) {
            ZStack {
                Circle()
                    .strokeBorder(
                        Color(.systemGray4).opacity(0.45),
                        lineWidth: 26
                    )
                    .frame(width: 150, height: 150)

                centerTotalLabel
            }
            .frame(height: 200)

            Spacer()

            Text("No spending this month")
                .font(.body.weight(.semibold))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("No spending this month.")
    }

    private var centerTotalLabel: some View {
        VStack(spacing: 2) {
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
}
