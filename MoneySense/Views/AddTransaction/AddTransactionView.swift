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
    //    @FocusState private var isFocused: Bool
    @FocusState private var focusedField: Field?  // ← only one FocusState
    
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
            Button {
                focusedField = nil
                Task {
                    await viewModel.submit()
                }
            } label: {
                Image(systemName: "arrow.up")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(viewModel.hasNoInput ? Color(.systemGray4) : Color(.systemBlue))
                    .clipShape(Circle())
            }
            .disabled(viewModel.hasNoInput || viewModel.isLoading)
        }
        .padding()
    }
    
    var amountInput: some View {
        VStack(spacing: 4) {
            ZStack {
                Text(viewModel.formattedAmount)
                    .font(.system(size: 48, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(viewModel.hasNoAmountInput ? .secondary : .primary)
//                    .minimumScaleFactor(0.5)
//                    .lineLimit(2)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        //                    isFocused = true
                        focusedField = .amount  // ← changed
                    }
                
                TextField("", text: $viewModel.rawInput)
                    .keyboardType(.numberPad)
                //                .focused($isFocused)
                    .focused($focusedField, equals: .amount)  // ← changed
                    .opacity(0.01)
                    .onChange(of: viewModel.rawInput) { _, newValue in viewModel.handleInput(newValue)}
            }
            if viewModel.showAmountWarning {
                Text("Maximum amount reached")
                    .font(.caption)
                    .foregroundStyle(.red)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: viewModel.showAmountWarning)
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
                    focusedField: $focusedField,  // ← fixed capitalisation
                    sources: MockData.sources,
                    categories: MockData.categories,
                )
            }
            .background(Color(.systemGray6).ignoresSafeArea())
//            .task { isFocused = true }
            .task {
                try? await Task.sleep(for: .milliseconds(300))
                focusedField = .amount
            }
            .alert("Error", isPresented: .constant(viewModel.error != nil)) {
                Button("OK") { viewModel.error = nil }
            } message: {
                Text(viewModel.error ?? "")
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Button {
                        switch focusedField {
                        case .description: focusedField = .amount
                        case .notes: focusedField = .description
                        default: break
                        }
                    } label: {
                        Image(systemName: "chevron.up")
                    }
                    
                    Button {
                        switch focusedField {
                        case .amount: focusedField = .description
                        case .description: focusedField = .notes
                        default: break
                        }
                    } label: {
                        Image(systemName: "chevron.down")
                    }
                    
                    Spacer()
                    
                    Button {
                        focusedField = nil
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundStyle(.blue)
                }
            }
            .overlay {
                if viewModel.showSuccess {
                    SuccessOverlayView()
                }
            }
            .overlay {
                if viewModel.isLoading {
                    LoadingOverlayView()
                }
            }
            .onChange(of: viewModel.didSubmitSuccessfully) { _, success in
                if success { dismiss() }
            }
        }
    }
}
