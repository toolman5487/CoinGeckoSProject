//
//  MainTabBarView.swift
//  CoinGeckoSProject
//
//  Created by Willy Hsu on 2025/10/15.
//

import SwiftUI

struct MainTabBarView: View {
    @State private var selection: Tab = .home

    enum Tab: Hashable {
        case home
        case crypto
        case mypage
    }

    var body: some View {
        TabView(selection: $selection) {
            NavigationStack {
                MainHomeView()
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
            .tag(Tab.home)
            
            NavigationStack {
                CryptoDetailView(id: "bitcoin")
            }
            .tabItem {
                Label("Coin", systemImage: "bitcoinsign")
            }
            .tag(Tab.crypto)

            NavigationStack {
                MainMyView()
            }
            .tabItem {
                Label("My", systemImage: "person")
            }
            .tag(Tab.mypage)
        }
        .labelStyle(.iconOnly)
    }
}

#Preview {
    MainTabBarView()
}
