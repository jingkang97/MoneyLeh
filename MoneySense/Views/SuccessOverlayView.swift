//
//  SuccessOverlayView.swift
//  MoneySense
//
//  Created by Jing Kang Ng on 20/4/26.
//

import SwiftUI

struct SuccessOverlayView: View {
    var message: String = "Transaction Added"
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .transition(.opacity)
            
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(.green)
                        .frame(width: 72, height: 72)
                    Image(systemName: "checkmark")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(.white)
                }
                Text(message)
                    .font(.headline)
                    .foregroundStyle(.primary)
            }
            .padding(32)
            .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 24))
            .transition(.scale(scale: 0.7).combined(with: .opacity))
        }
    }
}
