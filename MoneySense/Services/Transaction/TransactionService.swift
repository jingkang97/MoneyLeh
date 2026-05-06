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
    
    func fetchRecent(limit: Int = 5) async throws -> [Transaction] {
        try await db
            .from("transactions")
            .select("*, category: categories(id, name, color, icon)")
            .order("date", ascending: false)
            .limit(limit)
            .execute()
            .value
    }
    
    func fetchLastTwoMonths() async throws -> [Transaction] {
        let now = Date()
        let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: now)!

        return try await db
            .from("transactions")
            .select("*, category: categories(id, name, color, icon)")
            .gte("date", value: oneMonthAgo.isoString)
            .lte("date", value: now.isoString)
            .order("date", ascending: false)
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
