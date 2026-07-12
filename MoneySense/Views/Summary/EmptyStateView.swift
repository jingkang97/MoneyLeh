//
//  EmptyStateView.swift
//  MoneySense
//
//  Created by Jing Kang Ng on 8/5/26.
//

import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 12) {
            Spacer()
            
            Image(systemName: "creditcard")
                .font(.system(size: 36, weight: .regular))
                .foregroundStyle(.secondary)
            
            Text("No transactions yet")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
            
            Text("Tap the “+” button to add your first transaction")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
}
