//
//  SourceService.swift
//  MoneySense
//
//  Created by Jing Kang Ng on 30/4/26.
//

import Supabase

class SourceService {
    func fetchAll() async throws -> [SpendingSource] {
        let userId = "7eae0967-14c2-4161-9039-748e7505efd5" // same hardcoded userId as TransactionService
        let result: [SpendingSource] = try await SupabaseManager.shared.client
            .from("sources")
            .select()
            .eq("user_id", value: userId)
            .execute()
            .value
        print("fetch:", result.count, "sources")
        return result
    }
}
