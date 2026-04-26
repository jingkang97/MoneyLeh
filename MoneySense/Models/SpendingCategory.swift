//
//  SpendingCategory.swift
//  MoneySense
//
//  Created by Jing Kang Ng on 25/4/26.
//

import SwiftUI

struct SpendingCategory: Identifiable, Codable, Hashable {
    let id: UUID
    let userId: UUID?
    let name: String
    let color: String
    let icon: String
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case color
        case icon
        case createdAt = "created_at"
    }
}
