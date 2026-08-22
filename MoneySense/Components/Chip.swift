//
//  Untitled.swift
//  MoneySense
//
//  Created by Jing Kang Ng on 13/4/26.
//

import SwiftUI

struct Chip: View {
    let label: String
    let color: Color
    let systemImage: String
    var compact: Bool = false
    
    var body: some View {
        HStack(spacing: compact ? 4 : 6) {
            Text(label).fontWeight(.semibold)
            Image(systemName: systemImage)
                .font(compact ? .system(size: 8) : .caption)
        }
        .font(compact ? .caption2 : .subheadline)
        .padding(.horizontal, compact ? 8 : 12)
        .padding(.vertical, compact ? 4 : 6)
        .background(color.opacity(0.15))
        .foregroundColor(color)
        .clipShape(Capsule())
    }
}
