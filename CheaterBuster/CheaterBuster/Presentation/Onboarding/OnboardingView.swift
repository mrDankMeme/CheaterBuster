//
//  OnboardingView.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/31/25.
//

import SwiftUI

struct OnboardingView: View {
    // Один раз показываем онбординг
    @AppStorage("cb.hasOnboarded") private var hasOnboarded = false

    /// index: 0 = splash, 1..slides.count = реальный слайд
    @State private var index: Int = 0

    struct Slide: Identifiable, Hashable {
        let id = UUID()
        let imageName: String
        let title: String
        let subtitle: String
    }

    private let slides: [Slide] = [
        .init(
            imageName: "onboarding_face",
            title: "Find anyone by photo or name",
            subtitle: "Upload a photo or enter a name — AI will match profiles across the web."
        ),
        .init(
            imageName: "onboarding_phone",
            title: "Stay safe from scammers",
            subtitle: "AI protects you from fake profiles and scam chats."
        ),
        .init(
            imageName: "onboarding_couple",
            title: "Find out the truth in relationships",
            subtitle: "AI helps you check if your partner’s photos or profiles appear elsewhere."
        )
    ]

    var body: some View {
        ZStack {
            Tokens.Color.backgroundMain.ignoresSafeArea()

            if index == 0 {
                // SPLASH (логотип по центру)
                Image("onboarding_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160, height: 160)
                    .transition(.opacity)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                index = 1
                            }
                        }
                    }
            } else {
                VStack(spacing: 0) {
                    // MARK: Progress (верхние капсулы как в макете)
                    StepProgress(current: index, total: slides.count)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                    // MARK: Контент слайдов
                    TabView(selection: $index) {
                        ForEach(Array(slides.enumerated()), id: \.offset) { offset, slide in
                            SlideScreen(
                                slide: slide,
                                isLast: offset == slides.count - 1,
                                onSkip: finish,
                                onNext: {
                                    if offset == slides.count - 1 {
                                        finish()
                                    } else {
                                        withAnimation { index = offset + 2 } // следующий tag
                                    }
                                }
                            )
                            .tag(offset + 1)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
                .animation(.easeInOut(duration: 0.25), value: index)
            }
        }
    }

    private func finish() {
        hasOnboarded = true
    }
}

// MARK: - StepProgress (капсулы 3 шт., активная — цвет Accent)
private struct StepProgress: View {
    let current: Int   // 1..total
    let total: Int

    var body: some View {
        HStack(spacing: 16) {
            ForEach(1...total, id: \.self) { step in
                Capsule()
                    .fill(step <= current ? Tokens.Color.accent : Tokens.Color.borderNeutral.opacity(0.25))
                    .frame(height: 6)
                    .overlay(
                        Capsule().stroke(Tokens.Color.borderNeutral.opacity(0.0001), lineWidth: 1)
                    )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Слайд (верх: Skip; середина: иконка; низ: карточный блок с тенью)
private struct SlideScreen: View {
    let slide: OnboardingView.Slide
    let isLast: Bool
    let onSkip: () -> Void
    let onNext: () -> Void

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .topTrailing) {
                // Кнопка Skip справа сверху
                Button("Skip") { onSkip() }
                    .font(Tokens.Font.caption)
                    .foregroundStyle(Tokens.Color.textSecondary)
                    .padding(.trailing, 20)
                    .padding(.top, 4)
                    .accessibilityIdentifier("onboarding.skip")

                VStack(spacing: 0) {
                    Spacer(minLength: 12)

                    // Иллюстрация: максимум 354pt, иначе 75% ширины
                    let maxSide = min(geo.size.width * 0.75, 354)
                    Image(slide.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: maxSide, height: maxSide)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 8)

                    Spacer()

                    // Нижний карточный блок — как в макете
                    BottomCard {
                        VStack(spacing: 12) {
                            Text(slide.title)
                                .font(Tokens.Font.h2)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(Tokens.Color.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)

                            Text(slide.subtitle)
                                .font(Tokens.Font.body)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(Tokens.Color.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)

                        PrimaryButton("Continue") {
                            onNext()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 8)
                    }
                    .padding(.horizontal, 8) // чтобы тень красиво читалась на краях
                    .padding(.bottom, 8)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .ignoresSafeArea(.keyboard)
    }
}

// MARK: - Карточный нижний блок (скругление сверху, тень как в макете)
private struct BottomCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .padding(.top, 16)
        .padding(.bottom, 20)
        .background(
            Tokens.Color.surfaceCard,
            in: UnevenRoundedRectangle(
                topLeadingRadius: 28,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 28,
                style: .continuous
            )
        )
        .shadow(color: Tokens.Color.shadowBlack7, radius: 24, y: -2) // соответствует твоему ShadowBlack7 в палитре
        .overlay(
            UnevenRoundedRectangle(
                topLeadingRadius: 28,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 28,
                style: .continuous
            )
            .stroke(Tokens.Color.borderNeutral, lineWidth: 1)
        )
    }
}
