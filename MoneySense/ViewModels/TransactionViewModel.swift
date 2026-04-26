//
//  TransactionViewModel.swift
//  MoneySense
//
//  Created by Jing Kang Ng on 16/4/26.
//

import SwiftUI
import PhotosUI
import Supabase

@Observable
class AddTransactionViewModel {
    var amountInCents: Int = 0
    var rawInput: String = ""
    var description: String = ""
    var date: Date = Date()
    var source: String = MockData.sources.first ?? ""
    var category: SpendingCategory? = nil
    var notes: String = ""
    var receiptItem: PhotosPickerItem?
    
    var isLoading = false
    var error: String?
    var didSubmitSuccessfully = false
    var showSuccess = false
    var showAmountWarning = false
    
    private let maxAmountInCents = 99_999_999
    private let service = TransactionService()
    
    var formattedAmount: String {
        let amount = Double(amountInCents) / 100.0
        return amount.formatted(.currency(code: Locale.current.currencyCode))
    }
    
    var hasNoAmountInput: Bool { amountInCents == 0 }
    var hasNoDescriptionInput: Bool { description.trimmingCharacters(in: .whitespaces).isEmpty }
    var hasNoInput: Bool { hasNoAmountInput || hasNoDescriptionInput }
    
    func handleInput(_ newValue: String) {
        let digits = newValue.filter { $0.isNumber }
        let value = digits.isEmpty ? 0 : (Int(digits) ?? 0)
        
        if value > maxAmountInCents {
            showAmountWarning = true
            // Don't update — keep previous value
            rawInput = String(amountInCents)
        } else {
            showAmountWarning = false
            amountInCents = value
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
//            let userId  = try await SupabaseManager.shared.client.auth.session.user.id.uuidString
            
            let new = Transaction.New(
                userId: userId,
                amountInCents: amountInCents,
                description: description,
                date: dateString,
                sourceId: nil,
                categoryId: category?.id.uuidString,
                notes: notes.isEmpty ? nil : notes,
                receiptUrl: nil
            )
            
            try await service.insert(new)
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
        amountInCents = 0
        rawInput = ""
        description = ""
        date = Date()
        source = MockData.sources.first ?? ""
        category = nil
        notes = ""
        receiptItem = nil
    }
}
