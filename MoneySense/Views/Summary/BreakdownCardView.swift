//
//  BreakdownCardView.swift
//  MoneySense
//
//  Created by Jing Kang Ng on 13/4/26.
//

import SwiftUI
import Shimmer

struct BreakdownCardView: View {
    let data: [CategorySpending]
    let mockData: [CategorySpending] = MockData.cateogrySpending
    let total: Double
    let currencyCode: String
    let isLoading: Bool
    var animateFrom: Double? = nil
    var isAnimationPaused: Bool = false
    var onConsumedAnimation: () -> Void = {}
    @State private var displayedTotal: Double = 0

    private let donutSize: CGFloat = 160

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
        .onAppear {
            revealTotal(forceAnimate: false)
        }
        .onChange(of: isLoading) { wasLoading, loading in
            if loading {
                displayedTotal = 0
            } else if wasLoading {
                withAnimation(.easeInOut(duration: 0.45)) {
                    displayedTotal = total
                }
            }
        }
        .onChange(of: total) { oldValue, newValue in
            guard !isLoading, !isAnimationPaused else { return }
            displayedTotal = oldValue
            withAnimation(.easeInOut(duration: 0.45)) {
                displayedTotal = newValue
            }
            onConsumedAnimation()
        }
        .onChange(of: animateFrom) { _, _ in
            revealTotal(forceAnimate: true)
        }
        .onChange(of: isAnimationPaused) { _, paused in
            if !paused {
                revealTotal(forceAnimate: true)
            }
        }
    }

    private func revealTotal(forceAnimate: Bool) {
        guard !isLoading, !isAnimationPaused else { return }
        if let from = animateFrom, from != total {
            displayedTotal = from
            withAnimation(.easeInOut(duration: 0.45)) {
                displayedTotal = total
            }
            onConsumedAnimation()
        } else if !forceAnimate {
            displayedTotal = total
        }
    }

    // MARK: - Filled / loading

    private var chartContent: some View {
        HStack(spacing: 20) {
            ZStack {
                DonutChartView(
                    data: data,
                    isLoading: isLoading,
                    size: donutSize,
                    innerRadius: 0.65
                )

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

    // MARK: - Empty

    private var emptyState: some View {
        HStack(alignment: .center, spacing: 20) {
            ZStack {
                DonutChartView(
                    data: [],
                    size: donutSize,
                    innerRadius: 0.65
                )

                centerTotalLabel
            }
            .frame(height: 200)

            Spacer()

            Text("No spending this month")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("No spending this month.")
    }

    private var centerTotalLabel: some View {
        VStack(spacing: 2) {
            Text(displayedTotal.walletFormatted(currencyCode: currencyCode))
                .font(.title2.bold())
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .frame(maxWidth: 120)
                .contentTransition(.numericText())
                .redacted(reason: isLoading ? .placeholder : [])
            Text("spent")
                .font(.caption)
                .foregroundStyle(.secondary)
                .redacted(reason: isLoading ? .placeholder : [])
        }
    }
}
