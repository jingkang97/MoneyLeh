//
//  ContentView.swift
//  MoneySense
//

import SwiftUI
import Charts
import PhotosUI
 
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
                            innerRadius: .ratio(0.65),
                            angularInset: 3
                        )
                        .cornerRadius(6)
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
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    spendingCard
                    monthlyBreakdownCard
                    recentTransactions
                        .padding(.top, 8)
                }
                .padding()
            }.navigationTitle("Summary")
                .toolbarTitleDisplayMode(.inlineLarge)
                .toolbar {
                    ZStack {
                        Circle().fill(.blue)
                        Image(systemName: "person.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 16))
                        }
                        .frame(width: 34, height: 34)
                }
        }
    }
}

// MARK: - TabView
struct MainView: View {
    @State private var showAddSheet = false
    @State private var addButtonScale: CGFloat = 1.0

    private let accentBlue = Color(red: 0.0, green: 0.48, blue: 1.0)
    enum Tabs {
        case home, stats, budget, more, add, search
    }
    @State var selectedTab: Tabs = .home
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                Tab("Home", systemImage: "house.fill", value: .home) {
                    ContentView()
                }
                
                Tab("Stats", systemImage: "chart.pie.fill", value: .stats) {
                    Text("Stats")
                }
                
                Tab("Budget", systemImage: "wallet.pass.fill", value: .budget) {
                    Text("Budget")
                }
                
                Tab("More", systemImage: "ellipsis.circle.fill", value: .more) {
                    Text("More")
                }
                
                Tab("Add", systemImage: "plus", value: .add, role: .search) {
                        
                }
            }
            .onChange(of: selectedTab) { oldValue, newValue in
                if newValue == .add {
                    showAddSheet = true
                    selectedTab = oldValue
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddTransactionView()
            }
        }
    }
}

struct ExpenseFormView: View {
    @Binding var description: String
    @Binding var date: Date
    @Binding var source: String
    @Binding var category: String
    @Binding var notes: String
    @Binding var receiptItem: PhotosPickerItem?
    
    let sources: [String]
    let categories: [String]
    
    var body: some View {
        Form {
            Section {
                LabeledContent("Description") {
                    TextField("", text: $description)
                        .multilineTextAlignment(.trailing)
                }
                DatePicker("Date", selection: $date,
                           displayedComponents: [.date])
                Picker("Source", selection: $source) {
                    ForEach(sources, id: \.self) {
                        Text($0).tag($0)
                    }
                    .pickerStyle(.navigationLink)
                }
                Picker("Category", selection: $category) {
                    ForEach(categories, id: \.self) {
                        Text($0).tag($0)
                    }
                    .pickerStyle(.navigationLink)
                }
                
                Section("Notes") {
                    TextField("Add details...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            
            Section {
                PhotosPicker(selection: $receiptItem, matching: .images) {
                    VStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.title3)
                        Text("Add Receipt")
                            .font(.subheadline)
                    }
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                            .foregroundStyle(.secondary)
                    )
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 2, leading: 8, bottom: 8, trailing: 8))
            }
        }
        .scrollDisabled(true)
    }
}



struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var amountInCents: Int = 0
    @State private var rawInput: String = ""
    @FocusState private var isFocused: Bool
    
    // Form state
    @State private var description: String = ""
    @State private var date: Date = Date()
    @State private var source: String = "CitiBank" // get from DB
    @State private var category: String = "Food & Drink"
    @State private var notes: String = ""
    @State private var receiptItem: PhotosPickerItem?
    
    let sources = ["CitiBank", "DBS", "Cash"] // can add more next time
    let categories = ["Food & Drink", "Transport", "Shopping"] // can add more next time

    private var hasNoInput: Bool {
        amountInCents == 0
    }
    
    var formattedAmount: String {
        let amount = Double(amountInCents) / 100.00
        return amount.formatted(.currency(code: Locale.current.currency?.identifier ?? "SGD"))
    }
    
    var header: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.gray)
                    .frame(width: 44, height: 44)
                    .background(Color(.systemGray5))
                    .clipShape(Circle())
            }
            Spacer()
            Text("Add Transaction")
                .font(.headline)
            Spacer()
            Button {
                dismiss()
            } label: {
                Image(systemName: "arrow.up")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(hasNoInput ? Color(.systemGray4) : Color(.systemBlue))
                    .clipShape(Circle())
                    
            }
            .disabled(hasNoInput)
        }.padding()
    }
    
    var amountInput: some View {
        ZStack {
            // Display
            Text(formattedAmount)
                .font(.system(size: 48, weight: .bold))
                .frame(maxWidth: .infinity)
                .foregroundStyle(hasNoInput ? .secondary : .primary)
                .contentShape(Rectangle())
                .onTapGesture {
                    isFocused = true
                }
            
            // Invisible Text field to summon keyboard
            TextField("", text: $rawInput)
                .keyboardType(.numberPad)
                .focused($isFocused)
                .opacity(0.01)
                .onChange(of: rawInput) { oldValue, newValue in
                    handleInput(newValue)
                }
        }
    }
    
    func handleInput(_ newValue: String) {
        let digits = newValue.filter { $0.isNumber }

        if digits.isEmpty {
            amountInCents = 0
        } else if let value = Int(digits) {
            amountInCents = value
        }

        // Normalise rawInput to just digits so future diffs are accurate
        rawInput = digits
    }
    
    var body: some View {
        NavigationStack {
//            ScrollView {
                VStack(spacing: 0) {
                    header
                    amountInput
                    Spacer()
                    // Expense form view
                    ExpenseFormView(
                        description: $description,
                        date: $date,
                        source: $source,
                        category: $category,
                        notes: $notes,
                        receiptItem: $receiptItem,
                        sources: sources,
                        categories: categories
                    )
                }
                .background(Color(.systemGray6).ignoresSafeArea())
                .task {
                    isFocused = true
                }
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        HStack {
                            Spacer()
                            Button("Done") {
                                isFocused = false
                            }
                            .foregroundStyle(.blue)
                            .font(.system(size: 17, weight: .semibold))
                        }
                        .padding(.horizontal)
                    }
                }
//            }
//        .scrollDismissesKeyboard(.immediately)
        }
    }
}

// MARK: - Preview
#Preview {
    MainView()
}
