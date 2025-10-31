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
import UserNotifications

struct RootTabView: View {
    @Environment(\.resolver) private var resolver
    @EnvironmentObject private var router: AppRouter

    // MARK: - Added
    @AppStorage("cb.hasOnboarded") private var hasOnboarded = false
    @State private var didRunFirstFlow = false
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
        // MARK: - Added: показываем онбординг, если ещё не пройден
        .fullScreenCover(isPresented: .constant(hasOnboarded == false)) {
            OnboardingView()
        }
        // MARK: - Added: как только онбординг завершён — запускаем RateUs→Paywall один раз
        .onChange(of: hasOnboarded) { _, newValue in
            if newValue { triggerFirstRunFlowIfNeeded() }
        }
        .task {
            // если онбординг уже пройден на прошлых запусках
            if hasOnboarded { triggerFirstRunFlowIfNeeded() }
        }
        .sheet(isPresented: $showInitialPaywall) {
            let vm = resolver.resolve(PaywallViewModel.self)!
            PaywallView(vm: vm)
                .presentationDetents([.large])
        }
    }

    // MARK: - Added
    private func triggerFirstRunFlowIfNeeded() {
        guard didRunFirstFlow == false else { return }
        didRunFirstFlow = true

        let key = "cb.didShowRateThenPaywall.v1"
        let already = UserDefaults.standard.bool(forKey: key)
        guard already == false else { return }

        // 1) системный Rate Us
        SKStoreReviewController.requestReview()

        // 2) затем Paywall (не сразу, чтобы не столкнулось два модальных окна)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            showInitialPaywall = true
            UserDefaults.standard.set(true, forKey: key)
        }
    }
}
