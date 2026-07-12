//
//  AppNavigationHeader.swift
//  MoneySense
//

import SwiftUI

private struct AppNavigationHeaderModifier: ViewModifier {
    let title: String

    func body(content: Content) -> some View {
        content
            .navigationTitle(title)
            .toolbarTitleDisplayMode(.inlineLarge)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    AvatarView()
                }
            }
    }
}

extension View {
    func appNavigationHeader(_ title: String) -> some View {
        modifier(AppNavigationHeaderModifier(title: title))
    }
}
