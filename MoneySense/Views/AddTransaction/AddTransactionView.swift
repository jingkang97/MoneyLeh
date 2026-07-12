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
    @EnvironmentObject var categoryStore: CategoryStore
    @EnvironmentObject var sourceStore: SourceStore
    @State private var viewModel = AddTransactionViewModel()
    @FocusState private var focusedField: Field?

    let mode: TransactionFormMode
    var onSuccess: (() -> Void)? = nil

    init(mode: TransactionFormMode = .add, onSuccess: (() -> Void)? = nil) {
        self.mode = mode
        self.onSuccess = onSuccess
    }

    /// Dismiss keyboard first, then close sheet — avoids corrupting the home nav bar when using X.
    private func closeSheet() {
        focusedField = nil
        UIApplication.shared.endEditing()
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(200))
            dismiss()
        }
    }
    
    var header: some View {
        HStack {
            Button {
                closeSheet()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.black)
                    .frame(width: 44, height: 44)
            }
            .glassEffect(.regular.interactive(), in: Circle())
            Spacer()
            Text(viewModel.screenTitle)
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
            }
            .glassEffect(.regular.tint(viewModel.hasNoInput ? .gray : .blue).interactive(), in: Circle())
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
                    .contentShape(Rectangle())
                    .onTapGesture {
                        focusedField = .amount
                    }
                
                TextField("", text: $viewModel.rawInput)
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: .amount)
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
                    sources: sourceStore.sources,
                    categories: categoryStore.categories,
                )
            }
            .background(Color(.systemGray6).ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
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
                    SuccessOverlayView(message: viewModel.successMessage)
                }
            }
            .overlay {
                if viewModel.isLoading {
                    LoadingOverlayView()
                }
            }
            .onChange(of: viewModel.didSubmitSuccessfully) { _, success in
                if success {
                    onSuccess?()
                    closeSheet()
                }
            }
            .onDisappear {
                UIApplication.shared.endEditing()
            }
            .task {
                switch mode {
                case .add:
                    viewModel.configureForAdd(
                        categories: categoryStore.categories,
                        sources: sourceStore.sources
                    )
                    focusedField = .amount
                case .edit(let transaction):
                    viewModel.configureForEdit(
                        transaction,
                        categories: categoryStore.categories,
                        sources: sourceStore.sources
                    )
                }
            }
        }
    }
}
