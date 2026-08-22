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
    var animateFrom: Double? = nil
    var isAnimationPaused: Bool = false
    var onConsumedAnimation: () -> Void = {}
    @State private var displayedSpending: Double = 0
    
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
        return change.cappedPercentLabel()
    }
    
    var body: some View {
        Card {
            HStack {
                Text("\(selectedPeriod) Spending")
                    .font(.headline)
                Spacer()
                PeriodPicker(selectedPeriod: animatedPeriod)
            }
            
            if isLoading {
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
            } else {
                Text(formattedDate)
                    .foregroundStyle(.secondary)
                
                HStack(alignment: .bottom) {
                    Text(displayedSpending.walletFormatted(currencyCode: currencyCode))
                        .monospacedDigit()
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .contentTransition(.numericText())
                    Spacer()
                    Chip(label: chipLabel, color: chipColor, systemImage: chipIcon)
                }
            }
        }
        .shimmering(active: isLoading)
        .onAppear {
            revealSpending(forceAnimate: false)
        }
        .onChange(of: isLoading) { wasLoading, loading in
            if loading {
                displayedSpending = 0
            } else if wasLoading {
                withAnimation(.easeInOut(duration: 0.45)) {
                    displayedSpending = spending
                }
            }
        }
        .onChange(of: spending) { oldValue, newValue in
            guard !isLoading, !isAnimationPaused else { return }
            displayedSpending = oldValue
            withAnimation(.easeInOut(duration: 0.45)) {
                displayedSpending = newValue
            }
            onConsumedAnimation()
        }
        .onChange(of: animateFrom) { _, _ in
            revealSpending(forceAnimate: true)
        }
        .onChange(of: isAnimationPaused) { _, paused in
            if !paused {
                revealSpending(forceAnimate: true)
            }
        }
    }

    private func revealSpending(forceAnimate: Bool) {
        guard !isLoading, !isAnimationPaused else { return }
        if let from = animateFrom, from != spending {
            displayedSpending = from
            withAnimation(.easeInOut(duration: 0.45)) {
                displayedSpending = spending
            }
            onConsumedAnimation()
        } else if !forceAnimate {
            displayedSpending = spending
        }
    }

    private var animatedPeriod: Binding<String> {
        Binding(
            get: { selectedPeriod },
            set: { newValue in
                withAnimation(.easeInOut(duration: 0.45)) {
                    selectedPeriod = newValue
                }
            }
        )
    }
}
