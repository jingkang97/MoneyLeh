//
//  ContentView.swift
//  MoneySense
//

import SwiftUI
import Charts

// MARK: - Chip
struct Chip: View {
    let label: String
    let color: Color
    let systemImage: String
    
    var body: some View {
        HStack {
            Text(label).fontWeight(.semibold)
            Image(systemName: systemImage)
                .font(.caption)
        }
        .font(.subheadline)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(color.opacity(0.15))
        .foregroundColor(color)
        .clipShape(Capsule())
    }
}

// MARK: - Model
struct CategorySpending: Identifiable {
    let id = UUID()
    let category: String
    let amount: Double
}

let data: [CategorySpending] = [
    .init(category: "Food", amount: 200),
    .init(category: "Transport", amount: 150),
    .init(category: "Shopping", amount: 300),
    .init(category: "Others", amount: 120)
]

// MARK: - ContentView
struct ContentView: View {
    
    @State private var spending: Double = 140.10
    @State private var selectedPeriod: String = "Daily"
    
    private var currencyCode: String {
        Locale.current.currency?.identifier ?? "SGD"
    }
    
    var weekRange: String {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        
        if let start = calendar.dateInterval(of: .weekOfYear, for: Date())?.start,
           let end = calendar.date(byAdding: .day, value: 6, to: start) {
            return "\(start.formatted(.dateTime.day().month())) - \(end.formatted(.dateTime.day().month()))"
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
            return ""
        }
    }
    
    private var sortedBreakdownData: [CategorySpending] {
        data.sorted { $0.amount > $1.amount }
    }
    
    private var breakdownTotal: Double {
        data.reduce(0) { $0 + $1.amount }
    }
    
    private func categoryColor(_ name: String) -> Color {
        switch name {
        case "Food": return .orange
        case "Transport": return .blue
        case "Shopping": return .yellow
        case "Others": return .purple
        default: return .gray
        }
    }
    
    // MARK: - Spending Card
    var spendingCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("\(selectedPeriod) Spending")
                    .font(.headline)
                
                Spacer()
                
                Menu {
                    Button("Daily") { selectedPeriod = "Daily" }
                    Button("Weekly") { selectedPeriod = "Weekly" }
                    Button("Monthly") { selectedPeriod = "Monthly" }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundStyle(.secondary)
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
        .padding(20)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: .black.opacity(0.06), radius: 12, y: 4)
    }
    
    // MARK: - Breakdown Card
    var monthlyBreakdownCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Monthly Breakdown")
                .font(.headline)
            
            HStack(spacing: 20) {
                ZStack {
                    Chart(sortedBreakdownData) { item in
                        SectorMark(
                            angle: .value("Amount", item.amount),
                            innerRadius: .ratio(0.65)
                        )
                        .foregroundStyle(categoryColor(item.category))
                    }
                    
                    VStack {
                        Text(breakdownTotal, format: .currency(code: currencyCode))
                            .font(.title2.bold())
                        Text("spent")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(sortedBreakdownData) { item in
                        HStack {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(categoryColor(item.category))
                                .frame(width: 10, height: 10)
                            
                            VStack(alignment: .leading) {
                                Text(item.category)
                                Text(item.amount, format: .currency(code: currencyCode))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: .black.opacity(0.06), radius: 12, y: 4)
    }
    
    // MARK: - Transactions
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
        Transaction(title: "kirby", date: "8 Mar 2026", amount: -20.00, icon: "gift.fill", color: .yellow)
    ]
    
    var recentTransactions: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // Header
            HStack {
                Text("Recent Transactions")
                    .font(.headline)
                
                Spacer()
                
                Button {} label: {
                    HStack(spacing: 4) {
                        Text("See All")
                        Image(systemName: "chevron.right")
                    }
                    .font(.subheadline)
                }
            }
            .padding(.horizontal, 16)
            
            // Card
            VStack(spacing: 0) {
                ForEach(transactions.indices, id: \.self) { index in
                    let t = transactions[index]
                    
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(t.color.opacity(0.2))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: t.icon)
                                .foregroundColor(t.color)
                        }
                        
                        VStack(alignment: .leading) {
                            Text(t.title)
                            Text(t.date)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Text(t.amount, format: .currency(code: currencyCode))
                            .foregroundStyle(.red)
                    }
                    .padding()
                    
                    if index != transactions.count - 1 {
                        Divider().padding(.leading, 60)
                    }
                }
            }
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .shadow(color: .black.opacity(0.06), radius: 12, y: 4)
        }
    }
    
    // MARK: - Header
    var header: some View {
        HStack {
            Text("Summary")
                .font(.title.bold())
            
            Spacer()
            
            ZStack {
                Circle().fill(.blue)
                Image(systemName: "person.fill")
                    .foregroundColor(.white)
            }
            .frame(width: 40, height: 40)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.white)
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            header
            
            ScrollView {
                VStack(spacing: 20) {
                    spendingCard
                    monthlyBreakdownCard
                    recentTransactions
                        .padding(.top, 8)
                }
                .padding()
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

// MARK: - TabView
struct MainView: View {
    var body: some View {
        TabView {
            
            ContentView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            Text("Stats")
                .tabItem {
                    Image(systemName: "chart.pie.fill")
                    Text("Stats")
                }
            
            Text("Budget")
                .tabItem {
                    Image(systemName: "wallet.pass.fill")
                    Text("Budget")
                }
            
            Text("More")
                .tabItem {
                    Image(systemName: "ellipsis.circle.fill")
                    Text("More")
                }
        }
    }
}

// MARK: - Preview
#Preview {
    MainView()
}
