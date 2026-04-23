//
//  Untitled.swift
//  MoneySense
//
//  Created by Jing Kang Ng on 21/4/26.
//

import Foundation
import Combine

@MainActor
class RecentTransactionViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let service = TransactionService()
    
    func load() async {
        isLoading = true
        print("🟡 isLoading:", isLoading)
        print("🟡 displayTransactions count should be 5")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        do {
            transactions = try await service.fetchRecent()
            transactions.forEach { print("→ \($0.description ?? "nil") \($0.category?.name ?? "no category")") }

        } catch {
            self.error = error
            print("❌ LOAD ERROR:", error)
        }
        isLoading = false
        print("🟢 isLoading:", isLoading)

    }
}
