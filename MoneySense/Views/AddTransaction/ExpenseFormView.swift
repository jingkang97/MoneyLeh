//
//  ExpenseFormView.swift
//  MoneySense
//
//  Created by Jing Kang Ng on 14/4/26.
//

import SwiftUI
import PhotosUI

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
                LabeledContent("Description *") {
                    TextField("", text: $description)
                        .multilineTextAlignment(.trailing)
                }
                DatePicker("Date", selection: $date, displayedComponents: [.date])
                Picker("Source", selection: $source) {
                    ForEach(sources, id: \.self) {
                        Text($0).tag($0)
                    }
                }
                Picker("Category", selection: $category) {
                    ForEach(categories, id: \.self) {
                        Text($0).tag($0)
                    }
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
    }
}
