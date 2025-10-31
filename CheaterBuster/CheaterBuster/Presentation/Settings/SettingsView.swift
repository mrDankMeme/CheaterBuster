//
//  SettingsScreen.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//

import SwiftUI
import Swinject
import StoreKit // MARK: - Added

struct SettingsScreen: View {
    @StateObject private var vm: SettingsViewModel

    @Environment(\.resolver) private var resolver
    @State private var showPaywall = false

    // MARK: - Added (константы)
    private let supportEmail = "support@cheaterbuster.app"
    private let termsURL = URL(string: "https://cheaterbuster.app/terms")!
    private let privacyURL = URL(string: "https://cheaterbuster.app/privacy")!
    private let shareText = "Cheater Buster — check profiles and chats: https://cheaterbuster.app"

    // MARK: - Added (share sheet)
    @State private var showShareSheet = false

    init(vm: SettingsViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Tokens.Spacing.x24) {

                    // Блок Premium
                    groupCard {
                        navRow(
                            system: "chart.bar.doc.horizontal.fill",
                            tint: Tokens.Color.accent,
                            title: "Get a premium"
                        ) {
                            showPaywall = true
                        }

                        Divider().padding(.leading, 52)

                        navRow(
                            system: "arrow.clockwise.circle.fill",
                            tint: Tokens.Color.accent,
                            title: "Restore purchases"
                        ) {
                            // Восстановление доступно на Paywall — оставляем текущий поток (не меняем контракты)
                            showPaywall = true
                        }
                    }

                    // Блок Info
                    groupCard {
                        navRow(system: "bubble.left.and.bubble.right.fill",
                               tint: Tokens.Color.accent,
                               title: "Support") {
                            openSupport()
                        }

                        Divider().padding(.leading, 52)

                        navRow(system: "doc.text.fill",
                               tint: Tokens.Color.accent,
                               title: "Terms of Use") {
                            openURL(termsURL)
                        }

                        Divider().padding(.leading, 52)

                        navRow(system: "shield.fill",
                               tint: Tokens.Color.accent,
                               title: "Privacy Policy") {
                            openURL(privacyURL)
                        }
                    }

                    // Блок Rate/Share
                    groupCard {
                        navRow(system: "star.fill",
                               tint: Tokens.Color.accent,
                               title: "Rate Us") {
                            SKStoreReviewController.requestReview()
                        }

                        Divider().padding(.leading, 52)

                        navRow(system: "square.and.arrow.up.fill",
                               tint: Tokens.Color.accent,
                               title: "Share with friends") {
                            showShareSheet = true
                        }
                    }

                    // Опция «Save history»
                    groupCard {
                        HStack(spacing: Tokens.Spacing.x12) {
                            Image(systemName: "clock.arrow.circlepath")
                                .foregroundStyle(Tokens.Color.accent)
                                .frame(width: 28, height: 28)
                            Toggle("Save history", isOn: $vm.isHistoryEnabled)
                                .tint(Tokens.Color.accent)
                        }
                        .padding(.horizontal, Tokens.Spacing.x12)
                        .padding(.vertical, Tokens.Spacing.x12)
                    }
                }
                .padding(.horizontal, Tokens.Spacing.x16)
                .padding(.top, Tokens.Spacing.x16)
            }
            .background(Tokens.Color.backgroundMain.ignoresSafeArea())
            .navigationTitle("Settings")
        }
        .sheet(isPresented: $showPaywall) {
            // Resolve VM из DI при показе
            let paywallVM = resolver.resolve(PaywallViewModel.self)!
            PaywallView(vm: paywallVM)
                .presentationDetents([.large])
        }
        // MARK: - Added: Share sheet
        .sheet(isPresented: $showShareSheet) {
            ActivityView(activityItems: [shareText])
        }
    }

    // MARK: - UI helpers

    @ViewBuilder
    private func groupCard<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        VStack(spacing: 0) {
            content()
        }
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Tokens.Color.surfaceCard)
        )
        .apply(Tokens.Shadow.card)
    }

    private func navRow(system: String, tint: Color, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: Tokens.Spacing.x12) {
                Image(systemName: system)
                    .foregroundStyle(tint)
                    .frame(width: 28, height: 28)

                Text(title)
                    .font(Tokens.Font.body)
                    .foregroundStyle(Tokens.Color.textPrimary)

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(Tokens.Color.textSecondary.opacity(0.8))
            }
            .padding(.horizontal, Tokens.Spacing.x12)
            .padding(.vertical, Tokens.Spacing.x12)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Added: helpers

    private func openURL(_ url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    private func openSupport() {
        // Пытаемся mailto:, при неудаче — откроем сайт поддержки
        let mailto = URL(string: "mailto:\(supportEmail)")!
        if UIApplication.shared.canOpenURL(mailto) {
            UIApplication.shared.open(mailto, options: [:], completionHandler: nil)
        } else {
            openURL(URL(string: "https://cheaterbuster.app/support")!)
        }
    }
}

// MARK: - Added: UIKit activity wrapper (внутри файла, чтобы не плодить слоёв)
private struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}
