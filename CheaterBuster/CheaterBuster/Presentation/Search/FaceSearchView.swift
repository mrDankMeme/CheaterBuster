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

    @State private var item: PhotosPickerItem?
    @State private var image: UIImage?
    @State private var goResults = false
    @State private var didAnalyze = false

    var body: some View {
        VStack(spacing: Tokens.Spacing.x16) {

            // 🖼 Превью или заглушка
            Group {
                if let img = image {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFit()
                        .cornerRadiusContinuous(Tokens.Radius.medium)
                        .overlay(
                            RoundedRectangle(cornerRadius: Tokens.Radius.medium, style: .continuous)
                                .stroke(Tokens.Color.borderNeutral, lineWidth: 1)
                        )
                        .frame(maxHeight: 320)
                } else {
                    ContentUnavailableView(
                        "Select a photo",
                        systemImage: "photo",
                        description: Text("Pick one image to search by face.")
                    )
                    .frame(maxHeight: 320)
                }
            }

            // 🗂 PhotosPicker (свой вид кнопки)
            PhotosPicker(selection: $item, matching: .images, photoLibrary: .shared()) {
                Text("Choose from Library")
                    .font(Tokens.Font.subtitle)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        Tokens.Color.accent,
                        in: RoundedRectangle(cornerRadius: Tokens.Radius.pill, style: .continuous)
                    )
            }
            .buttonStyle(.plain)
            .onChange(of: item) { _, newValue in
                Task { @MainActor in
                    guard let data = try? await newValue?.loadTransferable(type: Data.self),
                          let img = UIImage(data: data) else { return }
                    image = img
                }
            }

            // ⚙️ Кнопка анализа
            PrimaryButton(
                "Analyze",
                isLoading: vm.isLoading,
                isDisabled: image == nil || vm.isLoading
            ) {
                guard let img = image,
                      let jpeg = img.jpegData(compressionQuality: 0.85) else { return }
                didAnalyze = true
                vm.runImageSearch(jpegData: jpeg)
            }

            // ❗ Ошибка, если есть
            if let err = vm.errorText {
                Text(err)
                    .foregroundStyle(.red)
                    .font(Tokens.Font.captionRegular)
            }

            Spacer()
        }
        .padding(.horizontal, Tokens.Spacing.x16)
        .padding(.top, Tokens.Spacing.x24)
        .background(Tokens.Color.backgroundMain.ignoresSafeArea())
        .navigationTitle("Face search")
        .navigationBarTitleDisplayMode(.inline)

        // 👇 Навигация к результатам по окончанию загрузки
        .onChange(of: vm.isLoading) { was, isNow in
            if didAnalyze && was == true && isNow == false {
                didAnalyze = false
                goResults = true
            }
        }

        // переход на экран результатов
        .navigationDestination(isPresented: $goResults) {
            SearchResultsView(results: vm.results)
        }
    }
}
