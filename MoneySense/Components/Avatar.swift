//
//  Avatar.swift
//  MoneySense
//
//  Created by Jing Kang Ng on 16/4/26.
//

import SwiftUI

struct AvatarView: View {
    var size: CGFloat = 34
    var background: Color = .blue
    var icon: String = "person.fill"
    var iconColor: Color = .white
    
    private var iconSize: CGFloat { size * 0.47}
    
    var body: some View {
        ZStack {
            Circle()
                .fill(background)
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .font(.system(size: iconSize))
        }
        .frame(width: size, height: size)
    }
    
}
