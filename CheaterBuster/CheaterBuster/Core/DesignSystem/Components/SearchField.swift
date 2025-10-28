//
//  SearchField.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/27/25.
//


import SwiftUI

public struct SearchField: View {
    @Binding var text: String
    var placeholder: String
    var onCommit: (() -> Void)?
    var onCancel: (() -> Void)?

    @FocusState private var focused: Bool

    public init(_ placeholder: String,
                text: Binding<String>,
                onCommit: (() -> Void)? = nil,
                onCancel: (() -> Void)? = nil) {
        self.placeholder = placeholder
        self._text = text
        self.onCommit = onCommit
        self.onCancel = onCancel
    }

    public var body: some View {
        HStack(spacing: Tokens.Spacing.x12) {
            HStack(spacing: Tokens.Spacing.x12) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Tokens.Color.textSecondary)

                TextField(placeholder, text: $text)
                    .font(Tokens.Font.body)
                    .foregroundColor(Tokens.Color.textPrimary)
                    .focused($focused)
                    .submitLabel(.search)
                    .onSubmit { onCommit?() }

                if !text.isEmpty {
                    Button {
                        text = ""
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(Tokens.Color.textSecondary)
                    }
                }
            }
            .padding(.horizontal, Tokens.Spacing.x16)
            .padding(.vertical, 12)
            .background(Tokens.Color.surfaceCard)
            .cornerRadius(Tokens.Radius.pill)
            .overlay(
                RoundedRectangle(cornerRadius: Tokens.Radius.pill)
                    .stroke(Tokens.Color.borderNeutral, lineWidth: 1)
            )
            .apply(Tokens.Shadow.card)

            if focused {
                Button("Cancel") {
                    text = ""
                    focused = false
                    onCancel?()
                }
                .font(Tokens.Font.body)
                .foregroundColor(Tokens.Color.textSecondary)
                .transition(.opacity.combined(with: .move(edge: .trailing)))
            }
        }
        .animation(.easeOut(duration: 0.25), value: focused)
    }
}
