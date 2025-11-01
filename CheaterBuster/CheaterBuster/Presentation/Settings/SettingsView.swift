//
//  SettingsScreen.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//

import SwiftUI
import Swinject
import StoreKit
import UIKit

struct SettingsScreen: View {
    @StateObject private var vm: SettingsViewModel

    @Environment(\.resolver) private var resolver
    @State private var showPaywall = false

    // MARK: - Константы
    private let supportEmail = "support@cheaterbuster.app"
    private let termsURL = URL(string: "https://cheaterbuster.app/terms")!
    private let privacyURL = URL(string: "https://cheaterbuster.app/privacy")!
    private let shareText = "Cheater Buster — check profiles and chats: https://cheaterbuster.app"

    // Share sheet
    @State private var showShareSheet = false

    init(vm: SettingsViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Tokens.Spacing.x24.scale) {

                    // MARK: - Premium
                    groupCard {
                        navRowAsset(
                            asset: "premium",
                            title: "Get a premium",
                            tint: Tokens.Color.accent
                        ) {
                            showPaywall = true
                        }

                        Divider().padding(.leading, 52.scale)

                        navRowAsset(
                            asset: "restore",
                            title: "Restore purchases",
                            tint: Tokens.Color.accent
                        ) {
                            showPaywall = true
                        }
                    }

                    // MARK: - Info
                    groupCard {
                        navRowAsset(
                            asset: "support",
                            title: "Support",
                            tint: Tokens.Color.accent
                        ) {
                            openSupport()
                        }

                        Divider().padding(.leading, 52.scale)

                        navRowAsset(
                            asset: "termsOfUse",
                            title: "Terms of Use",
                            tint: Tokens.Color.accent
                        ) {
                            openURL(termsURL)
                        }

                        Divider().padding(.leading, 52.scale)

                        navRowAsset(
                            asset: "privacyPolicy",
                            title: "Privacy Policy",
                            tint: Tokens.Color.accent
                        ) {
                            openURL(privacyURL)
                        }
                    }

                    // MARK: - Rate / Share
                    groupCard {
                        navRowAsset(
                            asset: "rateUs",
                            title: "Rate Us",
                            tint: Tokens.Color.accent
                        ) {
                            SKStoreReviewController.requestReview()
                        }

                        Divider().padding(.leading, 52.scale)

                        navRowAsset(
                            asset: "shareWithFriends",
                            title: "Share with friends",
                            tint: Tokens.Color.accent
                        ) {
                            showShareSheet = true
                        }
                    }

                    // MARK: - Save history (скрыто)
                    // (секция временно удалена по задаче)
                }
                .padding(.horizontal, Tokens.Spacing.x16.scale)
                .padding(.top,       Tokens.Spacing.x16.scale)
            }
            .background(Tokens.Color.backgroundMain.ignoresSafeArea())
            .navigationTitle("Settings")
        }
        // Все модальные — overFullScreen
        .fullScreenCover(isPresented: $showPaywall) {
            let paywallVM = resolver.resolve(PaywallViewModel.self)!
            PaywallView(vm: paywallVM)
                .ignoresSafeArea()
        }
        .fullScreenCover(isPresented: $showShareSheet) {
            ActivityView(activityItems: [shareText])
                .ignoresSafeArea()
        }
    }

    // MARK: - UI helpers

    @ViewBuilder
    private func groupCard<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        VStack(spacing: 0) {
            content()
        }
        .background(
            RoundedRectangle(cornerRadius: 16.scale, style: .continuous)
                .fill(Tokens.Color.surfaceCard)
        )
        .apply(Tokens.Shadow.card)
    }

    /// Ряд настроек с иконкой из ассетов (левая иконка 20×20, chevron — кастомный ассет)
    private func navRowAsset(asset: String, title: String, tint: SwiftUI.Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: Tokens.Spacing.x12.scale) {
                assetIcon(asset)
                    .foregroundStyle(tint)
                    .frame(width: 20.scale, height: 20.scale)

                Text(title)
                    .font(.system(size: 16.scale, weight: .regular))
                    .foregroundStyle(Color(hex: "#121212"))

                Spacer(minLength: 0)

                Image("chevronRight")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(Tokens.Color.textSecondary.opacity(0.8))
                    .frame(width: 20.scale, height: 20.scale)
                    .padding(.trailing, 4.scale) // ✅ Добавлен нужный отступ
            }
            .padding(.horizontal, Tokens.Spacing.x12.scale)
            .padding(.vertical,   Tokens.Spacing.x12.scale)
        }
        .buttonStyle(.plain)
    }

    private func assetIcon(_ name: String) -> some View {
        Image(name)
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
    }

    // MARK: - Helpers

    private func openURL(_ url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    private func openSupport() {
        let mailto = URL(string: "mailto:\(supportEmail)")!
        if UIApplication.shared.canOpenURL(mailto) {
            UIApplication.shared.open(mailto, options: [:], completionHandler: nil)
        } else {
            openURL(URL(string: "https://cheaterbuster.app/support")!)
        }
    }
}

// MARK: - UIKit activity wrapper
private struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}
