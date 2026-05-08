//
//  EmptyStateView.swift
//  MoneySense
//
//  Created by Jing Kang Ng on 8/5/26.
//

import SwiftUI

struct EmptyStateView: View {
    let onAddTransaction: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Illustration
            ZStack {
                // Background circles
                Circle()
                    .fill(Color.blue.opacity(0.08))
                    .frame(width: 220, height: 220)
                
                Circle()
                    .fill(Color.blue.opacity(0.12))
                    .frame(width: 160, height: 160)
                
                // Wallet illustration
                Image(systemName: "creditcard.circle.fill")
                        .font(.system(size: 100))
                        .foregroundStyle(Color.blue)
            }
            .padding(.bottom, 32)
            
            // Text
            Text("No transactions yet")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
            
            Text("Add your first transaction\nto start tracking your spending")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
                .padding(.horizontal, 40)
            
            // CTA Button
            Button(action: onAddTransaction) {
                Label("Add Transaction", systemImage: "plus")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.blue, in: RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 40)
            .padding(.top, 32)
            
            Spacer()
        }
    }
}
