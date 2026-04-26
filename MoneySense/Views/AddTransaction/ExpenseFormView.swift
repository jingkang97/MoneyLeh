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
    @Binding var category: SpendingCategory?
    @Binding var notes: String
    @Binding var receiptItem: PhotosPickerItem?
    var focusedField: FocusState<Field?>.Binding
    
    let sources: [String]
    let categories: [SpendingCategory]

    var body: some View {
        Form {
            Section {
                LabeledContent("Description *") {
                    TextField("", text: $description)
                        .multilineTextAlignment(.trailing)
                        .focused(focusedField, equals: .description)
                }
                DatePicker("Date", selection: $date, displayedComponents: [.date])
                Picker("Source", selection: $source) {
                    ForEach(sources, id: \.self) {
                        Text($0).tag($0)
                    }
                }
                Picker("Category", selection: $category) {
                    Text("None").tag(Optional<SpendingCategory>(nil))
                    ForEach(categories) { cat in
                        Text(cat.name).tag(Optional(cat))
                    }
                }
                
                TextField("Add notes...", text: $notes, axis: .vertical)
                    .lineLimit(3...6)
                    .focused(focusedField, equals: .notes)
                
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
