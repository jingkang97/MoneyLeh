//
//  AddTransaction.swift
//  MoneySense
//
//  Created by Jing Kang Ng on 14/4/26.
//

import SwiftUI
import PhotosUI

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var amountInCents: Int = 0
    @State private var rawInput: String = ""
    @FocusState private var isFocused: Bool
    
    @State private var description: String = ""
    @State private var date: Date = Date()
    @State private var source: String = "CitiBank"
    @State private var category: String = "Food & Drink"
    @State private var notes: String = ""
    @State private var receiptItem: PhotosPickerItem?
    
    let sources = ["CitiBank", "DBS", "Cash"]
    let categories = ["Food & Drink", "Transport", "Shopping"]
    
    private var hasNoAmountInput: Bool { amountInCents == 0}
    private var hasNoDescriptionInput: Bool { description.trimmingCharacters(in: .whitespaces).isEmpty}
    private var hasNoInput: Bool { hasNoAmountInput || hasNoDescriptionInput }
    
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
            Button { dismiss() } label: {
                Image(systemName: "arrow.up")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(hasNoInput ? Color(.systemGray4) : Color(.systemBlue))
                    .clipShape(Circle())
            }
            .disabled(hasNoInput)
        }
        .padding()
    }
    
    var amountInput: some View {
        ZStack {
            Text(formattedAmount)
                .font(.system(size: 48, weight: .bold))
                .frame(maxWidth: .infinity)
                .foregroundStyle(hasNoAmountInput ? .secondary : .primary)
                .contentShape(Rectangle())
                .onTapGesture {
                    isFocused = true
                }
            
            TextField("", text: $rawInput)
                .keyboardType(.numberPad)
                .focused($isFocused)
                .frame(width: 1, height: 1)   // ✅ instead of height: 1
                .opacity(0.01)
                .onChange(of: rawInput) { _, newValue in handleInput(newValue)}
        }
    }
    
    func handleInput(_ newValue: String) {
        let digits = newValue.filter { $0.isNumber }
        amountInCents = digits.isEmpty ? 0 : Int(digits) ?? 0
        rawInput = digits
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                header
                amountInput
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
            .task { isFocused = true }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("Done") { UIApplication.shared.endEditing() }
                            .foregroundStyle(.blue)
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .padding(.horizontal)
                }
            }
            
        }
    }
}
