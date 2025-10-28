//
//  SearchResultsView.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//


import SwiftUI

struct SearchResultsView: View {
    enum Mode { case face, name }

    let results: [ImageHit]
    let mode: Mode

    private let columns = [
        GridItem(.flexible(), spacing: Tokens.Spacing.x16),
        GridItem(.flexible(), spacing: Tokens.Spacing.x16)
    ]

    @Namespace private var ns

    var body: some View {
        ScrollView {
            if results.isEmpty {
                ContentUnavailableView(
                    "No results found",
                    systemImage: "magnifyingglass.circle",
                    description: Text("No matches found. Please try a different photo or name.")
                )
                .padding(.top, Tokens.Spacing.x24)
            } else {
                LazyVGrid(columns: columns, spacing: Tokens.Spacing.x16) {
                    ForEach(results) { hit in
                        if mode == .face {
                            FaceResultCard(hit: hit)
                        } else {
                            NameResultCard(hit: hit)
                        }
                    }
                }
                .padding(.horizontal, Tokens.Spacing.x16)
                .padding(.vertical, Tokens.Spacing.x24)
                .animation(.easeInOut(duration: 0.25), value: results)
            }
        }
        .background(Tokens.Color.backgroundMain.ignoresSafeArea())
        .navigationTitle(mode == .face ? "Face results" : "Name results")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Cards

private struct FaceResultCard: View {
    let hit: ImageHit

    var body: some View {
        VStack(spacing: Tokens.Spacing.x8) {
            AsyncThumb(url: hit.thumbnailURL)
                .frame(height: 160)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Tokens.Color.surfaceCard,
            in: RoundedRectangle(cornerRadius: Tokens.Radius.medium, style: .continuous)
        )
        .apply(Tokens.Shadow.card)
    }
}

private struct NameResultCard: View {
    let hit: ImageHit

    var body: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.x8) {
            AsyncThumb(url: hit.thumbnailURL)
                .frame(height: 160)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(hit.title)
                    .font(Tokens.Font.caption)
                    .foregroundStyle(Tokens.Color.textPrimary)
                    .lineLimit(1)
                Text(hit.source)
                    .font(Tokens.Font.captionRegular)
                    .foregroundStyle(Tokens.Color.textSecondary)
                    .lineLimit(1)
            }

            if let url = hit.linkURL {
                Link(destination: url) {
                    HStack(spacing: 4) {
                        Text("Open")
                        Image(systemName: "arrow.up.right.square")
                    }
                    .font(Tokens.Font.caption)
                    .foregroundStyle(Tokens.Color.accent)
                }
                .padding(.top, Tokens.Spacing.x4)
            }
        }
        .padding(Tokens.Spacing.x12)
        .background(
            Tokens.Color.surfaceCard,
            in: RoundedRectangle(cornerRadius: Tokens.Radius.medium, style: .continuous)
        )
        .apply(Tokens.Shadow.card)
    }
}

private struct AsyncThumb: View {
    let url: URL?
    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                ZStack { Color.gray.opacity(0.1); ProgressView() }
            case .success(let image):
                image.resizable().scaledToFill().clipped()
            case .failure:
                ZStack {
                    Color.gray.opacity(0.2)
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundStyle(.gray)
                }
            @unknown default:
                EmptyView()
            }
        }
    }
}
