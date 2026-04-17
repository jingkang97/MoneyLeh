//
//  PeriodPicker.swift
//  MoneySense
//
//  Created by Jing Kang Ng on 16/4/26.
//

import SwiftUI

struct PeriodPicker: View {
    @Binding var selectedPeriod: String
    var options: [String] = ["Daily", "Weekly", "Monthly"]
    
    var body: some View {
        Menu {
            ForEach(options, id: \.self) {
                option in
                Button(option) { selectedPeriod = option }
            }
        } label: {
            Image(systemName: "ellipsis")
                .foregroundStyle(.secondary)
        }
    }
}
