//
//  Card.swift
//  MoneySense
//
//  Created by Jing Kang Ng on 15/4/26.
//

import SwiftUI

struct Card<Content: View>: View {
    var spacing: CGFloat = 12
    var padding: CGFloat = 20
    var cornerRadius: CGFloat = 22
    var shadowOpacity: Double = 0.06
    var shadowRadius: CGFloat = 12
    var background: Color = .white
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            content()
        }
        .padding(padding)
        .background(background)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .shadow(color: .black.opacity(shadowOpacity), radius: shadowRadius, y: 4)
    }
}
