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
    @Binding var source: SpendingSource?
    @Binding var category: SpendingCategory?
    @Binding var notes: String
    @Binding var receiptItem: PhotosPickerItem?
    var focusedField: FocusState<Field?>.Binding
    
    let sources: [SpendingSource]
    let categories: [SpendingCategory]
    
    @State private var receiptImage: UIImage? = nil
    @State private var showingFullPreview: Bool = false
    @State private var replacementItem: PhotosPickerItem?

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
                    Text("None").tag(Optional<SpendingSource>(nil))
                    ForEach(sources) { src in
                        Text(src.name).tag(Optional(src))
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
                if let image = receiptImage {
                    ZStack(alignment: .topTrailing) {
                        ZStack {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                                .cornerRadius(10)

                            Color.clear
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    showingFullPreview = true
                                }
                        }.overlay(alignment: .topTrailing) {
                            HStack(spacing: 8) {

                                PhotosPicker(selection: $replacementItem, matching: .images) {
                                    Image(systemName: "repeat")
                                        .font(.footnote.weight(.semibold))
                                        .padding(7)
//                                        .background(.ultraThinMaterial)
                                        .contentShape(Circle())  // ← defines tap area without a visible background
                                        .glassEffect(.regular.tint(.clear), in: Circle())
                                        .clipShape(Circle())
                                }
                                .buttonStyle(.plain)
                                .allowsHitTesting(true)

                                Button {
                                    receiptItem = nil
                                    receiptImage = nil
                                } label: {
                                    Image(systemName: "trash")
                                        .font(.footnote.weight(.semibold))
                                        .foregroundStyle(.red)
                                        .padding(7)
                                        .contentShape(Circle())  // ← defines tap area without a visible background
                                        .glassEffect(.regular.tint(.clear), in: Circle())
                                        .clipShape(Circle())
                                }
                                .buttonStyle(.plain)
                                .allowsHitTesting(true)
                            }
                            .padding(10)
                        }
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 2, leading: 0, bottom: 8, trailing: 0))
                } else {
                    PhotosPicker(selection: $receiptItem, matching: .images) {
                        VStack(spacing: 6) {
                            Image(systemName: "plus")
                                .font(.title3)
                            Text("Add Receipt")
                                .font(.subheadline)
                        }
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                                .foregroundStyle(.primary)
                                .padding(4)
                        )
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 2, leading: 1, bottom: 8, trailing: 4))
                }
            }
        }
        .listSectionSpacing(20)
        .onChange(of: receiptItem) { _, newItem in
            guard let newItem else {
                return
            }

            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    await MainActor.run {
                        receiptImage = uiImage
                    }
                }
            }
        }
        .onChange(of: replacementItem) { _, newItem in
            guard let newItem else { return }

            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {

                    await MainActor.run {
                        receiptImage = uiImage
                        receiptItem = newItem
                    }
                }
            }
        }
        .sheet (isPresented: $showingFullPreview) {
            if let image = receiptImage {
                ReceiptPreviewSheet(image: image)
            }
        }
    }
}
