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
    
    var body: some View {
        HStack {
            Text(label).fontWeight(.semibold)
            Image(systemName: systemImage)
                .font(.caption)
        }
        .font(.subheadline)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(color.opacity(0.15))
        .foregroundColor(color)
        .clipShape(Capsule())
    }
}
