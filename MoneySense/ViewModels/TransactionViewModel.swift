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
    var category: String = MockData.categories.first ?? ""
    var notes: String = ""
    var receiptItem: PhotosPickerItem?
    
    var isLoading = false
    var error: String?
    var didSubmitSuccessfully = false
    
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
        amountInCents = digits.isEmpty ? 0 : (Int(digits) ?? 0)
        rawInput = digits
    }
    
    func submit() async {
        guard !hasNoInput else { return }
        
        isLoading = true
        error = nil
        
        let formatter = ISO8601DateFormatter()
        let dateString = formatter.string(from: date)
        
        // Temporary hardcoded userId until auth is built
        let userId = "00000000-0000-0000-0000-000000000000"
        
        do {
//            let userId  = try await SupabaseManager.shared.client.auth.session.user.id.uuidString
            
            let new = Transaction.New(
                userId: userId,
                amountInCents: amountInCents,
                description: description,
                date: dateString,
                sourceId: nil,
                categoryId: nil,
                notes: notes.isEmpty ? nil : notes,
                receiptUrl: nil
            )
            
            try await service.insert(new)
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
        category = MockData.categories.first ?? ""
        notes = ""
        receiptItem = nil
    }
}
