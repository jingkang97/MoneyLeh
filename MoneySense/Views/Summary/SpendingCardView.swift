//
//  SpendingCardView.swift
//  MoneySense
//
//  Created by Jing Kang Ng on 13/4/26.
//
import SwiftUI

struct SpendingCardView: View {
    let spending: Double
    @Binding var selectedPeriod: String
    let formattedDate: String
    let currencyCode: String
    let onPeriodChange: (String) -> Void
    
    var body: some View {
        Card {
            HStack {
                Text("\(selectedPeriod) Spending")
                    .font(.headline)
                Spacer()
                PeriodPicker(selectedPeriod: $selectedPeriod)
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
