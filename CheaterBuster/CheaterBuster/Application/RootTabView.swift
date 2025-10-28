//
//  RootTabView.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//

import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            SearchScreen()
                .tabItem { Label("Search", systemImage: "magnifyingglass") }

            CheaterScreen()
                .tabItem { Label("Cheater", systemImage: "person.crop.circle.badge.exclamationmark") }

            HistoryScreen()
                .tabItem { Label("History", systemImage: "clock") }

            SettingsScreen()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
    }
}
