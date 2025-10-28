//
//  FaceSearchView.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/27/25.
//

import SwiftUI
import PhotosUI
import UIKit

struct FaceSearchView: View {
    @ObservedObject var vm: SearchViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var item: PhotosPickerItem?
    @State private var image: UIImage?

    @State private var goResults = false
    @State private var didAnalyze = false

    var body: some View {
        ZStack {
            Tokens.Color.backgroundMain.ignoresSafeArea()

            VStack(spacing: Tokens.Spacing.x16) {
                // Header
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Tokens.Color.textPrimary)
                            .padding(12)
                            .background(
                                Tokens.Color.surfaceCard,
                                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                            )
                            .apply(Tokens.Shadow.card)
                    }

                    Spacer()

                    Text("Face search")
                        .font(Tokens.Font.title)
                        .foregroundStyle(Tokens.Color.textPrimary)

                    Spacer().frame(width: 44)
                }
                .padding(.horizontal, Tokens.Spacing.x16)
                .padding(.top, Tokens.Spacing.x16)

                // Preview
                Group {
                    if let img = image {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, Tokens.Spacing.x16)
                            .padding(.top, Tokens.Spacing.x12)
                            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .stroke(Tokens.Color.borderNeutral, lineWidth: 1)
                            )
                    } else {
                        ContentUnavailableView(
                            "Select a photo",
                            systemImage: "photo",
                            description: Text("Pick one image to search by face.")
                        )
                        .padding(.horizontal, Tokens.Spacing.x16)
                        .padding(.top, Tokens.Spacing.x32)
                    }
                }

                Spacer(minLength: 0)
            }
        }
        .navigationBarBackButtonHidden(true)

        // Bottom tools panel (как на макете)
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: Tokens.Spacing.x16) {
                CircleTool(system: "rotate.left")  { /* позже */ }
                CircleTool(system: "rotate.right") { /* позже */ }
                CircleTool(system: "crop")         { /* позже */ }

                Spacer()

                // Pink CTA →
                Button {
                    guard let img = image,
                          let jpeg = img.jpegData(compressionQuality: 0.85) else { return }
                    didAnalyze = true
                    vm.runImageSearch(jpegData: jpeg)
                } label: {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 52, height: 52)
                        .background(
                            Tokens.Color.accent,
                            in: Circle()
                        )
                        .shadow(color: .black.opacity(0.12), radius: 8, y: 4)
                }
                .buttonStyle(.plain)
                .disabled(image == nil || vm.isLoading)
            }
            .padding(.horizontal, Tokens.Spacing.x20)
            .padding(.vertical, Tokens.Spacing.x16)
            .background(
                Tokens.Color.surfaceCard,
                ignoresSafeAreaEdges: .bottom
            )
        }

        
        .photosPicker(isPresented: Binding(
            get: { image == nil && item == nil }, set: { _ in }
        ), selection: $item, matching: .images)

        .onChange(of: item) { _, newValue in
            Task { @MainActor in
                guard let data = try? await newValue?.loadTransferable(type: Data.self),
                      let img = UIImage(data: data) else { return }
                image = img
            }
        }

        
        .onChange(of: vm.isLoading) { was, isNow in
            if didAnalyze && was == true && isNow == false {
                didAnalyze = false
                goResults = true
            }
        }
        .navigationDestination(isPresented: $goResults) {
            SearchResultsView(results: vm.results, mode: .face)
        }

        
        .fullScreenCover(
            isPresented: Binding(
                get: { vm.isBlockingLoading },
                set: { _ in }
            )
        ) {
            LoadingView(mode: .face, previewImage: image, cancelAction: nil)
                .interactiveDismissDisabled(true)
        }
    }
}

private struct CircleTool: View {
    let system: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: system)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Tokens.Color.textPrimary)
                .frame(width: 48, height: 48)
                .background(
                    Tokens.Color.backgroundMain,
                    in: Circle()
                )
                .shadow(color: .black.opacity(0.08), radius: 10, y: 4)
        }
        .buttonStyle(.plain)
    }
}
