//
//  Transaction.swift
//  MoneySense
//
//  Created by Jing Kang Ng on 13/4/26.
//
import Foundation

struct Transaction: Identifiable, Codable {
    let id: UUID
    let userId: String
    let amountInCents: Int
    let description: String?
    let date: Date
    let sourceId: UUID?
    let categoryId: UUID?
    let notes: String?
    let receiptUrl: String?
    let createdAt: Date
    let updatedAt: Date?
    let category: SpendingCategory?
    
//    struct Category: Codable {
//        let name: String
//        let color: String
//        let icon: String
//    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case amountInCents = "amount_in_cents"
        case description
        case date
        case sourceId = "source_id"
        case categoryId = "category_id"
        case notes
        case receiptUrl = "receipt_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case category
    }
    
    var amount: Double {
        Double(amountInCents) / 100.0
    }

    var wasEdited: Bool {
        updatedAt != nil
    }

    var formattedUpdatedAt: String? {
        updatedAt?.formatted(date: .abbreviated, time: .shortened)
    }
    
    struct New: Codable {
        let userId: String
        let amountInCents: Int
        let description: String?
        let date: String
        let sourceId: String?
        let categoryId: String?
        let notes: String?
        let receiptUrl: String?
        
        enum CodingKeys: String, CodingKey {
            case userId = "user_id"
            case amountInCents = "amount_in_cents"
            case description
            case date
            case sourceId = "source_id"
            case categoryId = "category_id"
            case notes
            case receiptUrl = "receipt_url"
        }
    }

    struct Update: Encodable {
        let amountInCents: Int
        let description: String?
        let date: String
        let sourceId: String?
        let categoryId: String?
        let notes: String?
        let receiptUrl: String?
        let updatedAt: String

        enum CodingKeys: String, CodingKey {
            case amountInCents = "amount_in_cents"
            case description
            case date
            case sourceId = "source_id"
            case categoryId = "category_id"
            case notes
            case receiptUrl = "receipt_url"
            case updatedAt = "updated_at"
        }
    }
}
