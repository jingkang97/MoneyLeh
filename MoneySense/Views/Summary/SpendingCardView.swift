//
//  SpendingCardView.swift
//  MoneySense
//
//  Created by Jing Kang Ng on 13/4/26.
//
import SwiftUI
import Shimmer

struct SpendingCardView: View {
    let spending: Double
    @Binding var selectedPeriod: String
    let formattedDate: String
    let currencyCode: String
    let isLoading: Bool
    let percentageChange: Double?
    let onPeriodChange: (String) -> Void
    
    private var chipColor: Color {
        guard let change = percentageChange, change != 0 else { return .blue }
        return change < 0 ? .green : .red
    }

    private var chipIcon: String {
        guard let change = percentageChange, change != 0 else { return "minus" }
        return change < 0 ? "arrowtriangle.down.fill" : "arrowtriangle.up.fill"
    }

    private var chipLabel: String {
        guard let change = percentageChange else { return "New" }
        return String(format: "%.0f%%", abs(change))
    }
    
    var body: some View {
        Card {
            HStack {
                Text("\(selectedPeriod) Spending")
                    .font(.headline)
                Spacer()
                PeriodPicker(selectedPeriod: $selectedPeriod)
            }
            
            if isLoading {
                VStack(alignment: .leading, spacing: 12) {
                        Text("5 May 2026")
                            .foregroundStyle(.secondary)
                            .redacted(reason: .placeholder)
                        
                        HStack(alignment: .bottom) {
                            Text("$000.00")
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                            Spacer()
                            Chip(label: "00%", color: .blue, systemImage: "minus")
                        }
                        .redacted(reason: .placeholder)
                    }
                .shimmering(active: isLoading)
            } else {
                Text(formattedDate)
                    .foregroundStyle(.secondary)
                
                HStack(alignment: .bottom) {
                    Text(spending.walletFormatted(currencyCode: currencyCode))
                        .monospacedDigit()
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    Spacer()
                    Chip(label: chipLabel, color: chipColor, systemImage: chipIcon)
                }
            }
        }
    }
}
