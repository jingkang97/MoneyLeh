//
//  MoneySenseApp.swift
//  MoneySense
//
//  Created by Jing Kang Ng on 8/3/26.
//

import SwiftUI

@main
struct MoneySenseApp: App {
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        appearance.backgroundColor = .clear
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
                
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    windowScene.windows.first?.rootViewController?.tabBarController?.tabBar.standardAppearance = appearance
                }
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
