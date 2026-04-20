//
//  LoadingOverlayView.swift
//  MoneySense
//
//  Created by Jing Kang Ng on 20/4/26.
//

import SwiftUI

struct LoadingOverlayView: View {
    var message: String = "Saving..."

    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                ProgressView()
                    .scaleEffect(1.2)
                    .tint(.white)
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.white)
            }
        }
        .transition(.opacity)
    }
}
