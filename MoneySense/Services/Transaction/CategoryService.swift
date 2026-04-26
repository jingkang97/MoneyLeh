//
//  CategoryService.swift
//  MoneySense
//
//  Created by Jing Kang Ng on 25/4/26.
//
import Supabase

class CategoryService {
    func fetchAll() async throws -> [SpendingCategory] {
        let userId = "7eae0967-14c2-4161-9039-748e7505efd5" // same hardcoded userId as TransactionService
        print("🔵 fetching categories for user:", userId)
        let result: [SpendingCategory] = try await SupabaseManager.shared.client
            .from("categories")
            .select()
            .eq("user_id", value: userId)
            .execute()
            .value
        print("🔵 fetched:", result.count, "categories")
        return result
    }
}
