import SwiftUI
import Combine
import Supabase

@MainActor
class CategoryStore: ObservableObject {
    @Published var categories: [SpendingCategory] = []
    private let service = CategoryService()
    
    func load() async {
        do {
            categories = try await service.fetchAll()
        } catch {
            print("❌ Failed to load categories:", error)
        }
    }
}
