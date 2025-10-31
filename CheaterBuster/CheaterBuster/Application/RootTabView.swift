//
//  RootTabView.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//

import SwiftUI
import Swinject
import StoreKit

struct RootTabView: View {
    @Environment(\.resolver) private var resolver
    @EnvironmentObject private var router: AppRouter

    @AppStorage("cb.hasOnboarded") private var hasOnboarded = false

    // раньше был отдельный стейт showOnboardingCover — больше не нужен
    @State private var didRunFirstFlow = false
    @State private var showRateUs = false
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
        // MARK: - Fix: онбординг привязан напрямую к hasOnboarded
        .fullScreenCover(
            isPresented: Binding(
                get: { hasOnboarded == false },
                set: { presented in
                    // Если пользователь смахнул экран — считаем онбординг пройденным
                    if presented == false { hasOnboarded = true }
                }
            )
        ) {
            OnboardingView()
        }
        // кастомный Rate Us
        .fullScreenCover(isPresented: $showRateUs) {
            RateUsView(
                imageName: "rateus_hand",
                onLater: {
                    showRateUs = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        showInitialPaywall = true
                    }
                },
                onRated: {
                    showRateUs = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        showInitialPaywall = true
                    }
                }
            )
            .presentationDetents([.large])
        }
        // paywall
        .fullScreenCover(isPresented: $showInitialPaywall) {
            let vm = resolver.resolve(PaywallViewModel.self)!
            PaywallView(vm: vm)
        }
        .onChange(of: hasOnboarded) { _, newValue in
            if newValue { triggerFirstRunFlowIfNeeded() }
        }
        .task {
            if hasOnboarded { triggerFirstRunFlowIfNeeded() }
        }
    }

    private func triggerFirstRunFlowIfNeeded() {
        guard didRunFirstFlow == false else { return }
        didRunFirstFlow = true

        let key = "cb.didShowRateThenPaywall.v1"
        guard UserDefaults.standard.bool(forKey: key) == false else { return }

        showRateUs = true
        UserDefaults.standard.set(true, forKey: key)
    }
}
