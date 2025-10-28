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
    let cancelAction: (() -> Void)?

    var body: some View {
        ZStack {
            Tokens.Color.backgroundMain
                .ignoresSafeArea()

            VStack(spacing: Tokens.Spacing.x24) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Tokens.Color.accent))
                    .scaleEffect(1.6)

                VStack(spacing: Tokens.Spacing.x8) {
                    Text(titleText)
                        .font(Tokens.Font.title)
                        .foregroundStyle(Tokens.Color.textPrimary)
                    Text(subtitleText)
                        .font(Tokens.Font.captionRegular)
                        .foregroundStyle(Tokens.Color.textSecondary)
                }

                if let cancelAction {
                    Button("Cancel") {
                        cancelAction()
                    }
                    .font(Tokens.Font.bodyMedium18)
                    .foregroundStyle(Tokens.Color.textSecondary)
                    .padding(.top, Tokens.Spacing.x16)
                }
            }
            .padding(.horizontal, Tokens.Spacing.x32)
        }
    }

    private var titleText: String {
        switch mode {
        case .name: return "Searching..."
        case .face: return "Analyzing photo..."
        }
    }

    private var subtitleText: String {
        switch mode {
        case .name: return "Looking for matches across sources"
        case .face: return "Comparing with open profiles"
        }
    }
}
