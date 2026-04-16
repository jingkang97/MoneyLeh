//
//  SpendingCardView.swift
//  MoneySense
//
//  Created by Jing Kang Ng on 13/4/26.
//
import SwiftUI

struct SpendingCardView: View {
    let spending: Double
    let selectedPeriod: String
    let formattedDate: String
    let currencyCode: String
    let onPeriodChange: (String) -> Void
    
    var body: some View {
        Card {
            HStack {
                Text("\(selectedPeriod) Spending")
                    .font(.headline)
                Spacer()
                Menu {
                    Button("Daily") { onPeriodChange("Daily") }
                    Button("Weekly") { onPeriodChange("Weekly") }
                    Button("Monthly") { onPeriodChange("Monthly") }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.secondary)
                }
            }
            Text(formattedDate)
                .foregroundStyle(.secondary)
            
            HStack(alignment: .bottom) {
                Text(spending, format: .currency(code: currencyCode))
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                Spacer()
                Chip(label: "15%", color: .green, systemImage: "arrowtriangle.down.fill")
            }
        }
    }
}
