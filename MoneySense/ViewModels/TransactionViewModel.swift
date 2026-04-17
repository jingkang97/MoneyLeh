//
//  TransactionViewModel.swift
//  MoneySense
//
//  Created by Jing Kang Ng on 16/4/26.
//

import SwiftUI
import PhotosUI

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
    
    var formattedAmount: String {
        let amount = Double(amountInCents) / 100.0
        return amount.formatted(.currency(code: Locale.current.currencyCode))
    }
    
    var hasNoAmountInput: Bool {
        amountInCents == 0
    }
    
    var hasNoDescriptionInput: Bool {
        description.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var hasNoInput: Bool {
        hasNoAmountInput || hasNoDescriptionInput
    }
    
    func handleInput(_ newValue: String) {
        let digits = newValue.filter { $0.isNumber }
        amountInCents = digits.isEmpty ? 0 : (Int(digits) ?? 0)
        rawInput = digits
    }
    
    func submit() {
        // save transaction logic goes here
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
