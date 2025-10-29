//
//  RootTabView.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//



import SwiftUI
import Swinject

struct RootTabView: View {
    @Environment(\.resolver) private var resolver

    var body: some View {
        TabView {
            SearchScreen(vm: resolver.resolve(SearchViewModel.self)!)
                .tabItem { Label("Search", systemImage: "magnifyingglass") }

            // Был CheaterScreen(), но реальный тип — CheaterView
            CheaterView(vm: resolver.resolve(CheaterViewModel.self)!)
                .tabItem { Label("Cheater", systemImage: "person.crop.circle.badge.exclamationmark") }

            HistoryView(vm: resolver.resolve(HistoryViewModel.self)!)
                .tabItem { Label("History", systemImage: "clock") }

            SettingsScreen()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
    }
}
