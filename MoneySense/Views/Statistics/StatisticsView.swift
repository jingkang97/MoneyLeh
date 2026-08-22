//
//  StatisticsView.swift
//  MoneySense
//
//  Created by Jing Kang Ng on 4/7/26.
//
import SwiftUI
import Shimmer

struct StatisticsView: View {
    var reloadToken: Int = 0
    @State private var viewModel = StatisticsViewModel()
    private var currencyCode: String { Locale.current.currencyCode }

    init(reloadToken: Int = 0) {
        self.reloadToken = reloadToken
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.loading || viewModel.hasData {
                    loadedView
                } else {
                    EmptyStateView()
                }
            }
            .appNavigationHeader("Stats")
            .task(id: reloadToken) {
                await viewModel.load()
            }
        }
    }

    private var loadedView: some View {
        ScrollView {
            VStack(spacing: 28) {
                SegmentedPeriodPicker(
                    selectedPeriod: Binding(
                        get: { viewModel.selectedPeriod },
                        set: { newValue in
                            withAnimation(.easeInOut(duration: 0.45)) {
                                viewModel.selectedPeriod = newValue
                            }
                        }
                    ),
                    options: viewModel.periods
                )
                .padding(.horizontal, 24)
                .padding(.top, 8)

                chartSection
                    .shimmering(active: viewModel.loading)

                categoryList
            }
            .padding(.bottom, 24)
        }
        .refreshable {
            await viewModel.load(showSkeleton: false)
        }
    }

    private var chartSection: some View {
        VStack(spacing: 16) {
            ZStack {
                DonutChartView(
                    data: viewModel.categoryBreakdown,
                    isLoading: viewModel.loading,
                    size: 240
                )

                VStack(spacing: 6) {
                    Text(viewModel.spending.walletFormatted(currencyCode: currencyCode))
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .contentTransition(.numericText())
                        .redacted(reason: viewModel.loading ? .placeholder : [])

                    Text(viewModel.spentInLabel)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .redacted(reason: viewModel.loading ? .placeholder : [])

                    Chip(
                        label: viewModel.chipLabel,
                        color: viewModel.chipColor,
                        systemImage: viewModel.chipIcon,
                        compact: true
                    )
                    .redacted(reason: viewModel.loading ? .placeholder : [])
                }
                .offset(y: 8)
            }

            if viewModel.visibleCategoryBreakdown.isEmpty && !viewModel.loading {
                Text("No spending \(periodEmptySuffix)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder
    private var categoryList: some View {
        let items = viewModel.loading ? MockData.cateogrySpending : viewModel.visibleCategoryBreakdown
        let total = viewModel.loading ? items.reduce(0) { $0 + $1.amount } : viewModel.spending

        if viewModel.loading || !items.isEmpty {
            Card(spacing: 0, padding: 0) {
                ForEach(Array(items.enumerated()), id: \.element.category) { index, item in
                    categoryRow(item, total: total)

                    if index != items.count - 1 {
                        Divider()
                            .padding(.leading, 60)
                    }
                }
            }
            .padding(.horizontal)
            .redacted(reason: viewModel.loading ? .placeholder : [])
            .shimmering(active: viewModel.loading)
        }
    }

    private func categoryRow(_ item: CategorySpending, total: Double) -> some View {
        let percent = total > 0 ? (item.amount / total) * 100 : 0

        return HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(item.color)
                .frame(width: 36, height: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.category)
                    .font(.body.weight(.medium))
                Text(String(format: "%.0f%%", percent))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(item.amount.walletFormatted(currencyCode: currencyCode))
                .font(.body.weight(.medium))
                .monospacedDigit()

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
    }

    private var periodEmptySuffix: String {
        switch viewModel.selectedPeriod {
        case "Weekly": return "this week"
        case "Monthly": return "this month"
        case "Yearly": return "this year"
        default: return "this period"
        }
    }
}
