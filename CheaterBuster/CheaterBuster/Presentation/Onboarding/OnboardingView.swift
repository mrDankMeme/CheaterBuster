//
//  OnboardingView.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/31/25.
//


import SwiftUI

struct OnboardingView: View {
    // Храним флаг — чтобы больше не показывать онбординг
    @AppStorage("cb.hasOnboarded") private var hasOnboarded = false

    // index: 0 = splash (лого), 1...N = слайды
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
            title: "Find anyone by photo",
            subtitle: "Upload a photo — AI will match profiles across the web."
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
                // Splash с логотипом
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

                    // Прогресс-бар из капсул (как в макете)
                    HStack(spacing: 6) {
                        ForEach(1...(slides.count), id: \.self) { i in
                            Capsule()
                                .fill(i <= (index) ? Tokens.Color.accent
                                                   : Tokens.Color.borderNeutral.opacity(0.2))
                                .frame(height: 4)
                                .animation(.easeInOut(duration: 0.25), value: index)
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 8)

                    TabView(selection: $index) {
                        ForEach(Array(slides.enumerated()), id: \.offset) { offset, slide in
                            SlideView(
                                slide: slide,
                                onNext: {
                                    if offset == slides.count - 1 {
                                        finish()
                                    } else {
                                        withAnimation { index += 1 }
                                    }
                                },
                                onSkip: { finish() }
                            )
                            .tag(offset + 1)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(.easeInOut, value: index)
                }
            }
        }
    }

    private func finish() {
        hasOnboarded = true
    }
}

private struct SlideView: View {
    let slide: OnboardingView.Slide
    let onNext: () -> Void
    let onSkip: () -> Void

    var body: some View {
        VStack(spacing: 0) {

            HStack {
                Spacer()
                Button("Skip") { onSkip() }
                    .font(Tokens.Font.caption)
                    .foregroundStyle(Tokens.Color.textSecondary)
                    .padding(.trailing, 20)
            }
            .padding(.top, 8)

            Spacer(minLength: 32)

            // Адаптивная картинка: максимум 354pt или 75% ширины — что меньше
            GeometryReader { geo in
                VStack {
                    Spacer()
                    Image(slide.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width: min(geo.size.width * 0.75, 354),
                            height: min(geo.size.width * 0.75, 354)
                        )
                        .frame(maxWidth: .infinity)
                    Spacer()
                }
            }
            .frame(height: UIScreen.main.bounds.height * 0.45)

            VStack(spacing: 12) {
                Text(slide.title)
                    .font(Tokens.Font.h2)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Tokens.Color.textPrimary)
                    .padding(.horizontal, 24)

                Text(slide.subtitle)
                    .font(Tokens.Font.bodyMedium)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Tokens.Color.textSecondary)
                    .frame(maxWidth: 320)
                    .padding(.horizontal, 24)
            }
            .padding(.bottom, 24)

            Button(action: onNext) {
                Text("Continue")
                    .font(Tokens.Font.h2)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Tokens.Color.accent)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                    .padding(.horizontal, 24)
            }

            Spacer(minLength: 24)
        }
    }
}
