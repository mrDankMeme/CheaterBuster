//
//  PrimaryButton.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/27/25.
//

import SwiftUI

public struct PrimaryButton: View {
    public enum Size { case large, medium }

    let title: String
    let size: Size
    let isLoading: Bool
    let isDisabled: Bool
    let action: () -> Void

    public init(_ title: String,
                size: Size = .large,
                isLoading: Bool = false,
                isDisabled: Bool = false,
                action: @escaping () -> Void) {
        self.title = title
        self.size = size
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            ZStack {
                if isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text(title)
                        .font(Tokens.Font.subtitle)
                        .foregroundColor(.white)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, size == .large ? 16 : 12)
            // iOS-style corner smoothing (.continuous)
            .background(
                (isDisabled ? Tokens.Color.accentPressed : Tokens.Color.accent),
                in: RoundedRectangle(cornerRadius: Tokens.Radius.pill, style: .continuous)
            )
        }
        .buttonStyle(.plain)
        .disabled(isDisabled || isLoading)
        .accessibilityAddTraits(.isButton)
    }
}
