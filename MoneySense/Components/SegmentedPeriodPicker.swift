//
//  SegmentedPeriodPicker.swift
//  MoneySense
//

import SwiftUI

struct SegmentedPeriodPicker: View {
    @Binding var selectedPeriod: String
    var options: [String] = ["Weekly", "Monthly", "Yearly"]

    var body: some View {
        Picker("Period", selection: $selectedPeriod) {
            ForEach(options, id: \.self) { option in
                Text(option).tag(option)
            }
        }
        .labelsHidden()
        .pickerStyle(.segmented)
    }
}
