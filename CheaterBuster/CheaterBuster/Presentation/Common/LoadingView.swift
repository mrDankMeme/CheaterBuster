//
//  LoadingView.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//


import SwiftUI

struct LoadingView: View {
    enum Mode { case name, face }

    let mode: Mode
    let previewImage: UIImage?
    let cancelAction: (() -> Void)?

    @State private var progress: CGFloat = 0.35 // моковый прогресс для визуала

    var body: some View {
        ZStack {
            Tokens.Color.backgroundMain.ignoresSafeArea()

            VStack(spacing: Tokens.Spacing.x24) {
                if mode == .face, let ui = previewImage {
                    Image(uiImage: ui)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(height: 260)
                        .padding(.horizontal, Tokens.Spacing.x16)
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(Tokens.Color.borderNeutral, lineWidth: 1)
                        )

                    Text("Photo analysis")
                        .font(Tokens.Font.bodyMedium18)
                        .foregroundStyle(Tokens.Color.textPrimary)

                    // Простой прогресс (визуальный)
                    ZStack(alignment: .leading) {
                        Capsule().fill(Tokens.Color.borderNeutral.opacity(0.4)).frame(height: 8)
                        Capsule().fill(Tokens.Color.accent).frame(width: progressWidth, height: 8)
                    }
                    .padding(.horizontal, Tokens.Spacing.x16)
                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Tokens.Color.accent))
                        .scaleEffect(1.6)

                    Text("Searching...")
                        .font(Tokens.Font.bodyMedium18)
                        .foregroundStyle(Tokens.Color.textPrimary)
                }

                if let cancelAction {
                    Button("Cancel") { cancelAction() }
                        .font(Tokens.Font.caption)
                        .foregroundStyle(Tokens.Color.textSecondary)
                        .padding(.top, Tokens.Spacing.x8)
                }

                Spacer(minLength: 0)
            }
            .padding(.top, Tokens.Spacing.x24)
        }
        .onAppear {
            // лёгкая псевдо-анимация прогресса
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                progress = 0.7
            }
        }
    }

    private var progressWidth: CGFloat {
        UIScreen.main.bounds.width * progress
    }
}
