//
//  SearchResultsView.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//



import SwiftUI

struct SearchResultsView: View {
    let results: [ImageHit]

    var body: some View {
        Group {
            if results.isEmpty {
                ContentUnavailableView(
                    "No results found",
                    systemImage: "face.dashed",
                    description: Text("No matches found. Please try a different photo or name.")
                )
                .padding(.top, Tokens.Spacing.x24)
            } else {
                List(results) { hit in
                    HStack(spacing: Tokens.Spacing.x12) {
                        AsyncImage(url: hit.thumbnailURL) { phase in
                            switch phase {
                            case .empty: ProgressView()
                            case .success(let img): img.resizable().scaledToFill()
                            case .failure: Color.gray.opacity(0.2)
                            @unknown default: Color.gray.opacity(0.2)
                            }
                        }
                        .frame(width: 64, height: 64)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                        VStack(alignment: .leading, spacing: 4) {
                            Text(hit.title).lineLimit(1)
                            Text(hit.source).font(.caption).foregroundStyle(.secondary)
                        }

                        Spacer()

                        if let url = hit.linkURL {
                            Link(destination: url) {
                                Image(systemName: "arrow.up.right.square")
                            }
                        }
                    }
                    .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle(results.isEmpty ? "No results" : "Name results")
        .navigationBarTitleDisplayMode(.inline)
    }
}
