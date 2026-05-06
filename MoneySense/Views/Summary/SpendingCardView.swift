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
    let percentageChange: Double
    let onPeriodChange: (String) -> Void
    
    private var chipColor: Color {
        percentageChange <= 0 ? .green : .red
    }

    private var chipIcon: String {
        percentageChange <= 0 ? "arrowtriangle.down.fill" : "arrowtriangle.up.fill"
    }
    
    private var chipLabel: String {
        String(format: "%.0f%%", abs(percentageChange))
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
                            Chip(label: "00%", color: .green, systemImage: "arrowtriangle.down.fill")
                        }
                        .redacted(reason: .placeholder)
                    }
                .shimmering(active: isLoading)
            } else {
                Text(formattedDate)
                    .foregroundStyle(.secondary)
                
                HStack(alignment: .bottom) {
                    Text(spending, format: .currency(code: currencyCode))
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                    Spacer()
                    Chip(label: chipLabel, color: .green, systemImage: "arrowtriangle.down.fill")
                }
            }
        }
    }
}
