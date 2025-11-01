//  RootTabView.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//


import SwiftUI
import Swinject
import StoreKit
import UIKit // MARK: - Added

struct RootTabView: View {
    @Environment(\.resolver) private var resolver
    @EnvironmentObject private var router: AppRouter
    
    @AppStorage("cb.hasOnboarded") private var hasOnboarded = false
    
    @State private var didRunFirstFlow = false
    @State private var showRateUs = false
    @State private var showInitialPaywall = false
    
    var body: some View {
        TabView(selection: $router.tab) {
            SearchScreen(vm: resolver.resolve(SearchViewModel.self)!)
                .tabItem {
                    // MARK: - Changed: Label с иконкой из 20×20 template UIImage
                    Label {
                        Text("Search")
                    } icon: {
                        tabIcon("search")
                    }
                }
                .tag(AppRouter.Tab.search)

            CheaterView(vm: resolver.resolve(CheaterViewModel.self)!)
                .tabItem {
                    Label { Text("Cheater") } icon: { tabIcon("cheater") }
                }
                .tag(AppRouter.Tab.cheater)

            HistoryView(vm: resolver.resolve(HistoryViewModel.self)!)
                .tabItem {
                    Label { Text("History") } icon: { tabIcon("history") }
                }
                .tag(AppRouter.Tab.history)

            SettingsScreen(vm: SettingsViewModel(store: resolver.resolve(SettingsStore.self)!))
                .tabItem {
                    Label { Text("Settings") } icon: { tabIcon("settings") }
                }
                .tag(AppRouter.Tab.settings)
        }
        .tint(Tokens.Color.accent)
        .onAppear {
            UITabBar.appearance().tintColor = UIColor(Tokens.Color.accent)
            UITabBar.appearance().unselectedItemTintColor = UIColor(Tokens.Color.shadowBlack7)
        }
        // остальное без изменений ↓
        .fullScreenCover(
            isPresented: Binding(
                get: { hasOnboarded == false },
                set: { presented in if presented == false { hasOnboarded = true } }
            )
        ) { OnboardingView() }
        .fullScreenCover(isPresented: $showRateUs) {
            RateUsView(
                imageName: "rateus_hand",
                onLater: {
                    showRateUs = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { showInitialPaywall = true }
                },
                onRated: {
                    showRateUs = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { showInitialPaywall = true }
                }
            )
            .presentationDetents([.large])
        }
        .fullScreenCover(isPresented: $showInitialPaywall) {
            let vm = resolver.resolve(PaywallViewModel.self)!
            PaywallView(vm: vm).presentationDetents([.large])
        }
        .onChange(of: hasOnboarded) { _, newValue in
            if newValue { triggerFirstRunFlowIfNeeded(); requestTrackingIfNeeded() }
        }
        .task {
            if hasOnboarded { triggerFirstRunFlowIfNeeded(); requestTrackingIfNeeded() }
        }
    }
    


    // MARK: - Added: создаём 20×20 template UIImage и отдаём как Image
    
    private func tabIcon(_ name: String) -> Image {
        let target = CGSize(width: 20, height: 20)
        guard let src = UIImage(named: name) else {
            return Image(name) // fallback
        }

        // 1) Принудительно заливаем исходник чёрным, чтобы шаблон не стал прозрачным
        let tinted = src.withTintColor(.black, renderingMode: .alwaysOriginal)

        // 2) Рисуем в 20×20 с корректным scale экрана
        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = false
        format.scale = UIScreen.main.scale

        let renderer = UIGraphicsImageRenderer(size: target, format: format)
        let img = renderer.image { _ in
            UIColor.clear.setFill()
            UIRectFill(CGRect(origin: .zero, size: target))
            tinted.draw(in: CGRect(origin: .zero, size: target))
        }.withRenderingMode(.alwaysTemplate) // 3) Возвращаем как template — TabBar сам перекрасит

        return Image(uiImage: img)
    }


    
    private func triggerFirstRunFlowIfNeeded() {
        guard didRunFirstFlow == false else { return }
        didRunFirstFlow = true
        
        let key = "cb.didShowRateThenPaywall.v1"
        guard UserDefaults.standard.bool(forKey: key) == false else { return }
        
        showRateUs = true
        UserDefaults.standard.set(true, forKey: key)
    }
    
    private func requestTrackingIfNeeded() {
        let key = "cb.didAskATT.v1"
        guard UserDefaults.standard.bool(forKey: key) == false else { return }
        
        Task { @MainActor in
            if let pm = resolver.resolve(PermissionsManager.self) {
                _ = await pm.request(.tracking)
            }
            UserDefaults.standard.set(true, forKey: key)
        }
    }
}
