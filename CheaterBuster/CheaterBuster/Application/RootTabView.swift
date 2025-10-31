//
//  RootTabView.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//

import SwiftUI
import Swinject
import StoreKit // для Rate Us
// MARK: - Added
import AppTrackingTransparency
import UserNotifications

struct RootTabView: View {
    @Environment(\.resolver) private var resolver
    @EnvironmentObject private var router: AppRouter

    @State private var didCheckFirstRun = false
    @State private var showInitialPaywall = false

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

            SettingsScreen(
                vm: SettingsViewModel(
                    store: resolver.resolve(SettingsStore.self)!
                )
            )
            .tabItem { Label("Settings", systemImage: "gearshape") }
            .tag(AppRouter.Tab.settings)
        }
        .task {
            guard !didCheckFirstRun else { return }
            didCheckFirstRun = true

            // показываем Rate Us -> Paywall (уже было реализовано на P0)
            let flagKey = "cb.didShowRateThenPaywall.v1"
            let alreadyShown = UserDefaults.standard.bool(forKey: flagKey)
            if alreadyShown == false {
                SKStoreReviewController.requestReview()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    showInitialPaywall = true
                    UserDefaults.standard.set(true, forKey: flagKey)
                }
            }

            // MARK: - Added: «отложенные» запросы разрешений после онбординг-флоу
            // 1) ATT (tracking)
            let permissions = resolver.resolve(PermissionsManager.self)!
            _ = await permissions.request(.tracking)

            // 2) Notifications
            _ = await permissions.request(.notifications)
        }
        .sheet(isPresented: $showInitialPaywall) {
            let vm = resolver.resolve(PaywallViewModel.self)!
            PaywallView(vm: vm)
                .presentationDetents([.large])
        }
    }
}
