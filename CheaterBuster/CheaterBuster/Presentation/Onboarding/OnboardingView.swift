//
//  OnboardingView.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/31/25.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("cb.hasOnboarded") private var hasOnboarded = false
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
                Image("onboarding_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160, height: 160)
                    .transition(.opacity)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            withAnimation(.easeInOut(duration: 0.25)) { index = 1 }
                        }
                    }
            } else {
                VStack(spacing: 0) {
                    StepProgress(current: index, total: slides.count)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                    Button("Skip") { finish() }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Tokens.Color.textSecondary)
                        .padding(.top, 20)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.trailing, 24)
                        .accessibilityIdentifier("onboarding.skip")

                    TabView(selection: $index) {
                        ForEach(Array(slides.enumerated()), id: \.offset) { offset, slide in
                            SlideScreen(
                                slide: slide,
                                onNext: {
                                    if offset == slides.count - 1 {
                                        finish()
                                    } else {
                                        withAnimation { index = offset + 2 }
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

    private func finish() { hasOnboarded = true }
}

// MARK: - StepProgress
private struct StepProgress: View {
    let current: Int
    let total: Int

    var body: some View {
        GeometryReader { geo in
            let spacing: CGFloat = 4
            let available = geo.size.width - spacing * CGFloat(total - 1)
            let segmentWidth = max(0, available / CGFloat(total))

            HStack(spacing: spacing) {
                ForEach(1...total, id: \.self) { step in
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(step <= current ? Tokens.Color.accent : Tokens.Color.borderNeutral.opacity(0.25))
                        .frame(width: segmentWidth, height: 4)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 4)
    }
}

// MARK: - SlideScreen
private struct SlideScreen: View {
    let slide: OnboardingView.Slide
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 12)

            Image(slide.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 354, height: 354)
                .padding(.top, 8)

            Spacer(minLength: 0)
        }
        .safeAreaInset(edge: .bottom) {
            BottomCard(height: 232) {
                VStack(spacing: 12) {
                    Text(slide.title)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(Tokens.Color.textPrimary)
                        .multilineTextAlignment(.center)
                        .lineSpacing((1.3 * 22) - 22)

                    Text(slide.subtitle)
                        .font(Tokens.Font.body)
                        .foregroundStyle(Tokens.Color.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(10_000)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 20)
                

                PrimaryButton("Continue") { onNext() }
                    .padding(.horizontal, 20)
                    .padding(.top, 16) // ← расстояние между текстом и кнопкой ровно 8pt
            }
            .padding(.horizontal, 0)
            .padding(.bottom, 0)
            .ignoresSafeArea(.container, edges: .bottom)
        }
    }
}

// MARK: - BottomCard (фикс. высота 232pt, скругление только сверху)
private struct BottomCard<Content: View>: View {
    let height: CGFloat
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 0) {
            content
                .frame(maxHeight: .infinity, alignment: .top)
        }
        .padding(.top, 42)
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .background(
            UnevenRoundedRectangle(
                topLeadingRadius: 32,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 32,
                style: .continuous
            )
            .fill(Tokens.Color.surfaceCard)
            .shadow(color: Color.black.opacity(0.07), radius: 10, y: -2)
        )
        .ignoresSafeArea(.container, edges: .bottom)
        .accessibilityIdentifier("onboarding.bottomCard")
    }
}
