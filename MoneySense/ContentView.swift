//
//  ContentView.swift
//  MoneySense
//
//  Created by Jing Kang Ng on 8/3/26.
//

import SwiftUI

struct ContentView: View {
    private var currencyCode: String {
        Locale.current.currency?.identifier ?? "SGD"
    }
    
    private var dailySpending: Double = 140.00
    
    var spendingCard: some View {
        VStack (alignment: .leading, spacing: 12){
            HStack {
                Text("Daily Spending")
                    .font(.headline)
                Spacer()
                Image(systemName: "ellipsis")
                    .foregroundStyle(.secondary)
            }
            
            Text(Date.now, format: .dateTime.day().month().year())
                .font(.body)
                .fontWeight(.regular)
                .foregroundColor(.secondary)
            
            Text(dailySpending, format: .currency(code: currencyCode))
                .font(.system(size: 40, weight: .bold, design: .rounded))
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(16)
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
