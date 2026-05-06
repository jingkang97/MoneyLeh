//
//  Source.swift
//  MoneySense
//
//  Created by Jing Kang Ng on 30/4/26.
//

import SwiftUI

struct SpendingSource: Identifiable, Codable, Hashable {
    let id: UUID
    let userId: UUID?
    let name: String
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case createdAt = "created_at"
    }
}
