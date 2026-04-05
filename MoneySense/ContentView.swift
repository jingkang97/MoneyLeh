//
//  ContentView.swift
//  MoneySense
//
//  Created by Jing Kang Ng on 8/3/26.
//

import SwiftUI
import Charts

struct Chip : View {
    let label: String
    let color: Color
    let systemImage: String
    
    var body : some View {
        HStack{
            Text(label).fontWeight(.semibold)
            Image(systemName: systemImage)
                            .font(.caption)
        }.font(.subheadline)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color.opacity(0.15))
            .foregroundColor(color)
            .clipShape(Capsule())
    }
}

struct CategorySpending: Identifiable {
    let id = UUID()
    let category: String
    let amount: Double
}

let data: [CategorySpending] = [
    .init(category: "Food", amount: 200)
    , .init(category: "Transport", amount: 150)
    , .init(category: "Shopping", amount: 300)
    , .init(category: "Others", amount: 120)
]

struct ContentView: View {
    
    var weekRange: String {
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // Monday start
        
        if let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: Date())?.start,
           let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek) {
            return "\(startOfWeek.formatted(.dateTime.day().month())) - \(endOfWeek.formatted(.dateTime.day().month()))"
        }
        
        return ""
    }
    
    var formattedDate: String {
        let now = Date()
        switch selectedPeriod {
        case "Daily":
            return now.formatted(.dateTime.day().month().year())
        case "Weekly":
            return weekRange
        case "Monthly":
            return now.formatted(.dateTime.month().year())
        default:
            fatalError("Unhandled period")
        }
    }
    
    private var currencyCode: String {
        Locale.current.currency?.identifier ?? "SGD"
    }

    /// Menu rows must not use `systemImage: ""` — empty names trigger "No symbol named ''" in the console.
    @ViewBuilder
    private func periodMenuRow(title: String, isSelected: Bool) -> some View {
        HStack {
            Text(title)
            if isSelected {
                Image(systemName: "checkmark")
            }
        }
    }
        
    @State private var spending: Double = 140.10
    @State private var selectedPeriod: String = "Daily"

    private var sortedBreakdownData: [CategorySpending] {
        data.sorted { $0.amount > $1.amount }
    }

    private var breakdownTotal: Double {
        data.reduce(0) { $0 + $1.amount }
    }

    private func categoryColor(_ name: String) -> Color {
        switch name {
            case "Food": return Color(red: 1.0, green: 0.58, blue: 0.0)
            case "Transport": return Color(red: 0.2, green: 0.55, blue: 0.95)
            case "Shopping": return Color(red: 1.0, green: 0.8, blue: 0.0)
            case "Others": return Color(red: 0.55, green: 0.38, blue: 0.92)
            default: return .gray
        }
    }
    
    var spendingCard: some View {
        VStack (alignment: .leading, spacing: 12){
            HStack {
                Text("\(selectedPeriod) Spending")
                    .font(.headline)
                Spacer()
                Menu {
                    Button { selectedPeriod = "Daily" } label: {
                        periodMenuRow(title: "Daily", isSelected: selectedPeriod == "Daily")
                    }
                    Button { selectedPeriod = "Weekly" } label: {
                        periodMenuRow(title: "Weekly", isSelected: selectedPeriod == "Weekly")
                    }
                    Button { selectedPeriod = "Monthly" } label: {
                        periodMenuRow(title: "Monthly", isSelected: selectedPeriod == "Monthly")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.gray)
                        .foregroundStyle(.secondary)
                }
            }
            
            Text(formattedDate)
                .font(.body)
                .fontWeight(.regular)
                .foregroundColor(.secondary)
            
            HStack (alignment: .bottom) {
                Text(spending, format: .currency(code: currencyCode))
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                Spacer()
                Chip(label: "15%", color: Color.green, systemImage: "arrowtriangle.down.fill")
            }
            
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 12, y: 4)
    }
    
    var monthlyBreakdownCard : some View {
        // TODO: add a multiselect drop down to chooose up to 3 categories, the rest is others
        VStack(alignment: .leading, spacing: 12) {
            Text("Monthly Breakdown").font(.headline)

            HStack(alignment: .center, spacing: 20) {
                ZStack {
                    Chart(sortedBreakdownData) { item in
                        SectorMark(
                            angle: .value("Amount", item.amount),
                            innerRadius: .ratio(0.65),
                            angularInset: 3
                        )
                        .cornerRadius(6)
                        .foregroundStyle(categoryColor(item.category))
                    }
                    .chartLegend(.hidden)

                    VStack(spacing: 2) {
                        Text(breakdownTotal, format: .currency(code: currencyCode))
                            .font(.system(.title2, design: .rounded))
                            .fontWeight(.bold)
                        Text("spent")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }.frame(maxWidth: .infinity)

                
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(sortedBreakdownData) { item in
                        HStack(alignment: .center, spacing: 10) {
                            RoundedRectangle(cornerRadius: 3, style: .continuous)
                                .fill(categoryColor(item.category))
                                .frame(width: 10, height: 10)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.category)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                                
                                Text(item.amount, format: .currency(code: currencyCode))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }.frame(alignment: .leading)
                .padding(.trailing, 16)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 12, y: 4)
    }
    
    struct Transaction: Identifiable {
        let id = UUID()
        let title: String
        let date: String
        let amount: Double
        let icon: String
        let color: Color
    }
    
    let transactions = [
        Transaction(title: "luckin", date: "9 Mar 2026", amount: -32.01, icon: "fork.knife", color: .orange),
        Transaction(title: "mrt", date: "9 Mar 2026", amount: -15.05, icon: "tram.fill", color: .blue),
        Transaction(title: "kirby", date: "8 Mar 2026", amount: -20.00, icon: "gift.fill", color: .yellow),
    ]
    
    var recentTransactions: some View {
        
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Transaction")
                    .font(.headline)
                Spacer()
                Button(action: {
                    
                }) {
                    HStack(spacing: 4) {
                        Text("See All")
                        Image(systemName: "chevron.right")
                    }
                    .font(.subheadline)
                }
            }
            
            
            VStack(spacing: 0) {
                ForEach(transactions.indices, id: \.self) { index in
                    
                    let transaction = transactions[index]
                    
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(transaction.color.opacity(0.2))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: transaction.icon)
                                .foregroundColor(transaction.color)
                                .font(.system(size: 16, weight: .semibold))
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(transaction.title)
                            Text(transaction.date)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Text(String(format: "%.2f", transaction.amount))
                            .foregroundStyle(.red)
                    }
                    .padding()
                    
                    // Divider (not after last item)
                    if index != transactions.count - 1 {
                        Divider()
                            .padding(.leading, 60)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 12, y: 4)
        }
    }
        
    
    var header: some View {
        HStack(alignment: .center) {
            Text("Summary")
                .font(.title)
                .fontWeight(.bold)
            Spacer()
            ZStack {
                Circle().fill(Color.blue)
                Image(systemName: "person.fill")
                    .foregroundColor(.white)
            }
            .frame(width: 40, height: 40)
        }
        .padding()
        .background(Color.white)

    }
    
    var body: some View {
        header
        ScrollView {
            VStack {
                spendingCard
                monthlyBreakdownCard
                recentTransactions
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
        }.background(Color(red: 0.95, green: 0.95, blue: 0.97).ignoresSafeArea())
    }
}

#Preview {
    ContentView()
}
