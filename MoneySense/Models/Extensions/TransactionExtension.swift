//
//  TransactionExtension.swift
//  MoneySense
//
//  Created by Jing Kang Ng on 23/4/26.
//
import SwiftUI
extension Transaction {
    static var placeholder: Transaction {
        Transaction (
        id: UUID(),
        userId: "",
        amountInCents: 1299,
        description: "Placeholder Name",
        date: Date(),
        sourceId: nil,
        categoryId: nil,
        notes: nil,
        receiptUrl: nil,
        createdAt: Date(),
        category: SpendingCategory(
            id: UUID(),
            userId: nil,
            name: "Shopping",
            color: "#888888",
            icon: "tag",
            createdAt: nil
            )
        )
    }
}
