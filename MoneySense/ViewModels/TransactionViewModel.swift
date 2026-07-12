//
//  TransactionViewModel.swift
//  MoneySense
//
//  Created by Jing Kang Ng on 16/4/26.
//

import SwiftUI
import PhotosUI
import Supabase

enum TransactionFormMode {
    case add
    case edit(Transaction)
}

@Observable
class AddTransactionViewModel {
    var amountInCents: Int = 0
    var rawInput: String = ""
    var description: String = ""
    var date: Date = Date()
    var source: SpendingSource? = nil
    var category: SpendingCategory? = nil
    var notes: String = ""
    var receiptItem: PhotosPickerItem?

    var isLoading = false
    var error: String?
    var didSubmitSuccessfully = false
    var showSuccess = false
    var showAmountWarning = false

    private var editingTransactionId: UUID?
    private let maxAmountInCents = 99_999_999
    private let service = TransactionService()

    var screenTitle: String {
        isEditing ? "Edit Transaction" : "Add Transaction"
    }

    var successMessage: String {
        isEditing ? "Updated Transaction" : "Transaction Added"
    }

    var isEditing: Bool { editingTransactionId != nil }
    
    var formattedAmount: String {
        let amount = Double(amountInCents) / 100.0
        return amount.formatted(.currency(code: Locale.current.currencyCode))
    }
    
    var hasNoAmountInput: Bool { amountInCents == 0 }
    var hasNoDescriptionInput: Bool { description.trimmingCharacters(in: .whitespaces).isEmpty }
    var hasNoInput: Bool { hasNoAmountInput || hasNoDescriptionInput }
    
    func configureForAdd(categories: [SpendingCategory], sources: [SpendingSource]) {
        reset()
        category = categories.first
        source = sources.first
    }

    func configureForEdit(
        _ transaction: Transaction,
        categories: [SpendingCategory],
        sources: [SpendingSource]
    ) {
        editingTransactionId = transaction.id
        amountInCents = transaction.amountInCents
        rawInput = String(transaction.amountInCents)
        description = transaction.description ?? ""
        date = transaction.date
        notes = transaction.notes ?? ""
        category = categories.first { $0.id == transaction.categoryId }
        source = sources.first { $0.id == transaction.sourceId }
        receiptItem = nil
        error = nil
        didSubmitSuccessfully = false
        showSuccess = false
        showAmountWarning = false
    }

    func handleInput(_ newValue: String) {
        let digits = newValue.filter { $0.isNumber }
        let value = digits.isEmpty ? 0 : (Int(digits) ?? 0)

        if value > maxAmountInCents {
            showAmountWarning = true
            let capped = String(amountInCents)
            if rawInput != capped {
                rawInput = capped
            }
            return
        }

        showAmountWarning = false
        amountInCents = value
        if rawInput != digits {
            rawInput = digits
        }
    }
    
    func submit() async {
        guard !hasNoInput else { return }
        
        isLoading = true
        error = nil
        
        let formatter = ISO8601DateFormatter()
        let dateString = formatter.string(from: date)

        // Temporary hardcoded userId until auth is built
        let userId = "7eae0967-14c2-4161-9039-748e7505efd5"

        do {
            if let id = editingTransactionId {
                let update = Transaction.Update(
                    amountInCents: amountInCents,
                    description: description,
                    date: dateString,
                    sourceId: source?.id.uuidString,
                    categoryId: category?.id.uuidString,
                    notes: notes.isEmpty ? nil : notes,
                    receiptUrl: nil,
                    updatedAt: formatter.string(from: Date())
                )
                try await service.update(id: id, update)
            } else {
                let new = Transaction.New(
                    userId: userId,
                    amountInCents: amountInCents,
                    description: description,
                    date: dateString,
                    sourceId: source?.id.uuidString,
                    categoryId: category?.id.uuidString,
                    notes: notes.isEmpty ? nil : notes,
                    receiptUrl: nil
                )
                try await service.insert(new)
            }
            isLoading = false
            
            withAnimation(.spring(duration: 0.4)) {
                showSuccess = true
            }
            try? await Task.sleep(for: .seconds(1.5))
            withAnimation(.easeOut(duration: 0.3)) {
                showSuccess = false
            }
            didSubmitSuccessfully = true
            reset()
            
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
    
    func reset() {
        editingTransactionId = nil
        amountInCents = 0
        rawInput = ""
        description = ""
        date = Date()
        source = nil
        category = nil
        notes = ""
        receiptItem = nil
    }
}
