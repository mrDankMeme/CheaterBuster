//  SearchScreen.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//

import SwiftUI

struct SearchScreen: View {
    // MARK: - Removed: goName (больше не нужен)
    @State private var goPhoto = false
    private let vm: SearchViewModel

    init(vm: SearchViewModel) { self.vm = vm }

    var body: some View {
        NavigationStack {
            VStack(spacing: Tokens.Spacing.x16) {
                Text("Find your partner")
                    .font(Tokens.Font.h2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, Tokens.Spacing.x8)

                VStack(spacing: Tokens.Spacing.x12) {
                    // MARK: - Removed: карточка текстового поиска
                    // CardRow(icon: "text.magnifyingglass",
                    //         title: "Search for a partner by name") { goName = true }

                    // Оставляем только поиск по фото
                    CardRow(
                        icon: "face.smiling",
                        title: "Finding a partner by face"
                    ) { goPhoto = true }
                }

                Spacer()
            }
            .padding(.horizontal, Tokens.Spacing.x16)
            .background(Tokens.Color.backgroundMain.ignoresSafeArea())

            // MARK: - Removed: navigationDestination для NameSearchView
            .navigationDestination(isPresented: $goPhoto) {
                FaceSearchView(vm: vm)
            }
        }
    }
}

private struct CardRow: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Tokens.Spacing.x12) {
                Image(systemName: icon)
                    .frame(width: 28, height: 28)
                    .foregroundStyle(Tokens.Color.accent)
                    .background(
                        Tokens.Color.accent.opacity(0.1),
                        in: RoundedRectangle(cornerRadius: 8, style: .continuous)
                    )
                Text(title)
                    .foregroundStyle(Tokens.Color.textPrimary)
                Spacer()
            }
            .padding(.vertical, Tokens.Spacing.x12)
            .padding(.horizontal, Tokens.Spacing.x12)
            .background(
                Tokens.Color.surfaceCard,
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
            .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
        }
        .buttonStyle(.plain)
    }
}
