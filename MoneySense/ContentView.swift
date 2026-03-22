//
//  ContentView.swift
//  MoneySense
//
//  Created by Jing Kang Ng on 8/3/26.
//

import SwiftUI

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
        let calendar = Calendar.current
        
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
        
    @State private var spending: Double = 140.10
    @State private var selectedPeriod: String = "Daily"
    
    var spendingCard: some View {
        VStack (alignment: .leading, spacing: 12){
            HStack {
                Text("\(selectedPeriod) Spending")
                    .font(.headline)
                Spacer()
                Menu {
                    Button(action: {selectedPeriod = "Daily"}) {Label("Daily", systemImage: selectedPeriod == "Daily" ? "checkmark" : "")
                    }
                    Button(action: {selectedPeriod = "Weekly"}) {Label("Weekly", systemImage: selectedPeriod == "Weekly" ? "checkmark" : "")
                    }
                    Button(action: {selectedPeriod = "Monthly"}) {Label("Monthly", systemImage: selectedPeriod == "Monthly" ? "checkmark" : "")
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
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 12, y: 4)
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
                Spacer()
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
        }.background(Color(red: 0.95, green: 0.95, blue: 0.97).ignoresSafeArea())
        
    }
}

#Preview {
    ContentView()
}
