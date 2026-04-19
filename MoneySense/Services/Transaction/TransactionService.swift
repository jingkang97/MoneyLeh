//
//  TransactionService.swift
//  MoneySense
//
//  Created by Jing Kang Ng on 19/4/26.
//

import Foundation
import Supabase

class TransactionService {
    private let db = SupabaseManager.shared.client
    
    func fetchAll() async throws -> [Transaction] {
        try await db
            .from("transactions")
            .select()
            .order("created_at", ascending: false)
            .execute()
            .value
    }
    
    func insert(_ transaction: Transaction.New) async throws {
        try await db
            .from("transactions")
            .insert(transaction)
            .execute()
    }
}
