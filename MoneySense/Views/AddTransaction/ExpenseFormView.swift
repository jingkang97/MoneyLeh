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
    @State private var isRemovingReceipt = false

    private var categorySelection: Binding<UUID?> {
        Binding(
            get: { category?.id },
            set: { id in
                category = id.flatMap { categoryId in
                    categories.first { $0.id == categoryId }
                }
            }
        )
    }

    private var sourceSelection: Binding<UUID?> {
        Binding(
            get: { source?.id },
            set: { id in
                source = id.flatMap { sourceId in
                    sources.first { $0.id == sourceId }
                }
            }
        )
    }

    var body: some View {
        Form {
            Section {
                LabeledContent("Description *") {
                    TextField("", text: $description)
                        .multilineTextAlignment(.trailing)
                        .focused(focusedField, equals: .description)
                }
                DatePicker("Date", selection: $date, displayedComponents: [.date])
                Picker("Source", selection: sourceSelection) {
                    Text("None").tag(Optional<UUID>(nil))
                    ForEach(sources) { src in
                        Text(src.name).tag(Optional(src.id))
                    }
                }
                Picker("Category", selection: categorySelection) {
                    Text("None").tag(Optional<UUID>(nil))
                    ForEach(categories) { cat in
                        Text(cat.name).tag(Optional(cat.id))
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
                                .scaleEffect(isRemovingReceipt ? 0.05 : 1.0, anchor: .topTrailing)
                                .opacity(isRemovingReceipt ? 0 : 1)
                                .blur(radius: isRemovingReceipt ? 6 : 0)
                                .animation(.spring(duration: 0.4, bounce: 0), value: isRemovingReceipt)

                            Color.clear
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    showingFullPreview = true
                                }
                        }
                        .overlay(alignment: .topTrailing) {
                            HStack(spacing: 8) {
                                PhotosPicker(selection: $replacementItem, matching: .images) {
                                    Image(systemName: "repeat")
                                        .font(.footnote.weight(.semibold))
                                        .padding(7)
                                        .contentShape(Circle())
                                        .glassEffect(.regular.tint(.clear), in: Circle())
                                        .clipShape(Circle())
                                }
                                .buttonStyle(.plain)
                                .allowsHitTesting(true)

                                Button {
                                    withAnimation(.spring(duration: 0.25, bounce: 0)) {
                                        isRemovingReceipt = true
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                        receiptItem = nil
                                        receiptImage = nil
                                        isRemovingReceipt = false
                                    }
                                } label: {
                                    Image(systemName: "trash")
                                        .font(.footnote.weight(.semibold))
                                        .foregroundStyle(.red)
                                        .padding(7)
                                        .contentShape(Circle())
                                        .glassEffect(.regular.tint(.clear), in: Circle())
                                        .clipShape(Circle())
                                }
                                .buttonStyle(.plain)
                                .allowsHitTesting(true)
                            }
                            .padding(10)
                        }
                    }
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.95, anchor: .top).combined(with: .opacity),
                        removal: .scale(scale: 0.85, anchor: .top).combined(with: .opacity)
                    ))
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
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.95, anchor: .top)
                            .combined(with: .opacity)
                            .animation(.spring(duration: 0.35, bounce: 0.1).delay(0.2)), // ← wait for image to finish removing
                        removal: .opacity
                    ))
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 2, leading: 1, bottom: 8, trailing: 4))
                }
            }
            .animation(.spring(duration: 0.45, bounce: 0.1), value: receiptImage == nil)
        }
        .listSectionSpacing(20)
        .onChange(of: receiptItem) { _, newItem in
            guard let newItem else { return }
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
        .sheet(isPresented: $showingFullPreview) {
            if let image = receiptImage {
                ReceiptPreviewSheet(image: image)
            }
        }
    }
}
