//
//  Untitled.swift
//  MoneySense
//
//  Created by Jing Kang Ng on 21/4/26.
//

import Foundation
import SwiftUI

@MainActor
@Observable
class RecentTransactionViewModel {
    var transactions: [Transaction] = []
    var isLoading = false
    var error: Error?
    
    private let service = TransactionService()
    
    func load(showSkeleton: Bool = false) async {
        if showSkeleton || transactions.isEmpty {
            isLoading = true
        }
        do {
            let result = try await service.fetchRecent()
            withAnimation(.easeInOut(duration: 0.45)) {
                transactions = result
                isLoading = false
            }
        } catch {
            self.error = error
            isLoading = false
        }
    }
}
