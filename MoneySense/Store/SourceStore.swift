//
//  SourceStore.swift
//  MoneySense
//
//  Created by Jing Kang Ng on 30/4/26.
//
import SwiftUI
import Combine
import Supabase

class SourceStore: ObservableObject {
    @Published var sources: [SpendingSource] = []
    private let service = SourceService()
    
    func load() async {
        do {
            sources = try await service.fetchAll()
        } catch {
            print("failed to load sources", error)
        }
    }
    
}
