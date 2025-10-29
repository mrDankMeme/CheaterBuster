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
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        TabView(selection: $router.tab) {
            SearchScreen(vm: resolver.resolve(SearchViewModel.self)!)
                .tabItem { Label("Search", systemImage: "magnifyingglass") }
                .tag(AppRouter.Tab.search)

            CheaterView(vm: resolver.resolve(CheaterViewModel.self)!)
                .tabItem { Label("Cheater", systemImage: "person.crop.circle.badge.exclamationmark") }
                .tag(AppRouter.Tab.cheater)

            HistoryView(vm: resolver.resolve(HistoryViewModel.self)!)
                .tabItem { Label("History", systemImage: "clock") }
                .tag(AppRouter.Tab.history)

            SettingsScreen()
                .tabItem { Label("Settings", systemImage: "gearshape") }
                .tag(AppRouter.Tab.settings)
        }
    }
}
