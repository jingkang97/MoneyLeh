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
    @State private var viewModel = AddTransactionViewModel()
    @FocusState private var isFocused: Bool
    
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
                    .background(viewModel.hasNoInput ? Color(.systemGray4) : Color(.systemBlue))
                    .clipShape(Circle())
            }
            .disabled(viewModel.hasNoInput)
        }
        .padding()
    }
    
    var amountInput: some View {
        ZStack {
            Text(viewModel.formattedAmount)
                .font(.system(size: 48, weight: .bold))
                .frame(maxWidth: .infinity)
                .foregroundStyle(viewModel.hasNoAmountInput ? .secondary : .primary)
                .contentShape(Rectangle())
                .onTapGesture {
                    isFocused = true
                }
            
            TextField("", text: $viewModel.rawInput)
                .keyboardType(.numberPad)
                .focused($isFocused)
                .opacity(0.01)
                .onChange(of: viewModel.rawInput) { _, newValue in viewModel.handleInput(newValue)}
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                header
                amountInput
                ExpenseFormView(
                    description: $viewModel.description,
                    date: $viewModel.date,
                    source: $viewModel.source,
                    category: $viewModel.category,
                    notes: $viewModel.notes,
                    receiptItem: $viewModel.receiptItem,
                    sources: MockData.sources,
                    categories: MockData.categories
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
