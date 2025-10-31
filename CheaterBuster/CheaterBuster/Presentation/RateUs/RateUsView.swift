//
//  RateUsView.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/31/25.
//



import SwiftUI
import StoreKit

struct RateUsView: View {
    /// Имя PDF-ассета: "rateus_hand" или "rateus_stars"
    let imageName: String

    /// Колбэк закрытия (например, "Rate later")
    let onLater: () -> Void
    /// Колбэк после "Rate now" (покажем системный рейтинг и закроем)
    let onRated: () -> Void

    init(
        imageName: String = "rateus_hand",
        onLater: @escaping () -> Void,
        onRated: @escaping () -> Void
    ) {
        self.imageName = imageName
        self.onLater = onLater
        self.onRated = onRated
    }

    var body: some View {
        ZStack {
            Tokens.Color.backgroundMain.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: 24)

                // Иллюстрация — PDF, адаптивно
                GeometryReader { geo in
                    let side = min(geo.size.width * 0.6, 260)
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: side, height: side)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(height: 300)

                Spacer(minLength: 0)

                VStack(spacing: 14) {
                    Text("Love using Cheater Booster?")
                        .font(Tokens.Font.h2)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Tokens.Color.textPrimary)
                        .padding(.horizontal, 24)

                    Text("Leave a quick rating to help others discover it — your support means a lot!")
                        .font(Tokens.Font.body)
                        .foregroundStyle(Tokens.Color.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                .padding(.bottom, 24)

                // Кнопка "Rate later" — outline
                Button(action: { onLater() }) {
                    Text("Rate later")
                        .font(Tokens.Font.subtitle)
                        .foregroundStyle(Tokens.Color.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: Tokens.Radius.pill, style: .continuous)
                                .fill(Tokens.Color.surfaceCard)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: Tokens.Radius.pill, style: .continuous)
                                .stroke(Tokens.Color.accent, lineWidth: 1.5)
                        )
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 24)

                // Кнопка "Rate now" — primary (на твоём PrimaryButton)
                PrimaryButton("Rate now") {
                    SKStoreReviewController.requestReview()
                    onRated()
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)

                Spacer(minLength: 24)
            }
        }
        .accessibilityIdentifier("rateus.screen")
    }
}
