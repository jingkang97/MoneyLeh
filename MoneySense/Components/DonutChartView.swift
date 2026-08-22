//
//  DonutChartView.swift
//  MoneySense
//

import SwiftUI
import Charts

struct DonutChartView: View {
    let data: [CategorySpending]
    var isLoading: Bool = false
    var size: CGFloat = 240
    var innerRadius: Double = 0.68

    private var showPlaceholder: Bool {
        isLoading || data.isEmpty || data.allSatisfy { $0.amount == 0 }
    }

    var body: some View {
        Chart(data) { item in
            SectorMark(
                angle: .value("Amount", item.amount),
                innerRadius: .ratio(innerRadius),
                angularInset: 3
            )
            .cornerRadius(6)
            .foregroundStyle(item.color)
        }
        .opacity(showPlaceholder ? 0 : 1)
        .overlay {
            if showPlaceholder {
                Circle()
                    .strokeBorder(
                        Color(.systemGray4).opacity(0.45),
                        lineWidth: size * 0.16
                    )
                    .frame(width: size * 0.84, height: size * 0.84)
            }
        }
        .frame(width: size, height: size)
        .animation(.easeInOut(duration: 0.45), value: data.map(\.amount))
    }
}
