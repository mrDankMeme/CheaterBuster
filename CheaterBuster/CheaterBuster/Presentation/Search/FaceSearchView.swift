//
//  FaceSearchView.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 11/01/25.
//

import SwiftUI
import PhotosUI
import Swinject
import UIKit

struct FaceSearchView: View {
    @ObservedObject var vm: SearchViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.resolver) private var resolver

    @State private var item: PhotosPickerItem?
    @State private var image: UIImage?

    // Поворот/масштаб
    @State private var rotationAngle: Angle = .zero
    @State private var userZoom: CGFloat = 1.0

    @State private var didAnalyze = false
    @State private var showPaywall = false

    let onFinished: () -> Void

    init(vm: SearchViewModel, onFinished: @escaping () -> Void) {
        self.vm = vm
        self.onFinished = onFinished
    }

    var body: some View {
        ZStack {
            Tokens.Color.backgroundMain.ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: Header (как в Cheater)
                HStack {
                    Button { dismiss() } label: {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 44.scale, height: 44.scale)
                                .shadow(color: Tokens.Color.shadowBlack7, radius: 12.scale, x: 0, y: 0)

                            Image("backArrow")
                                .resizable()
                                .renderingMode(.template)
                                .scaledToFit()
                                .frame(width: 20.scale, height: 20.scale)
                                .foregroundStyle(Color(hex: "#141414"))
                        }
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Text("Face search")
                        .font(.system(size: 18.scale, weight: .medium))
                        .foregroundStyle(Color(hex: "#141414"))

                    Spacer()
                    Color.clear.frame(width: 44.scale, height: 44.scale)
                }
                .padding(.horizontal, 16.scale)
                .padding(.top, 16.scale)

                // MARK: Preview — идеальный AspectFit с учётом поворота
                GeometryReader { geo in
                    ZStack {
                        if let uiImage = image {
                            let baseW = uiImage.size.width
                            let baseH = uiImage.size.height
                            let deg = abs(Int(rotationAngle.degrees)) % 360
                            let swap = (deg == 90 || deg == 270)
                            let iw = swap ? baseH : baseW
                            let ih = swap ? baseW : baseH
                            let s = min(geo.size.width / iw, geo.size.height / ih)

                            Image(uiImage: uiImage)
                                .resizable()
                                .frame(width: baseW, height: baseH)   // рисуем в исходном размере
                                .rotationEffect(rotationAngle)
                                .scaleEffect(s * userZoom)            // вписываем + пользовательский zoom
                                .frame(width: geo.size.width, height: geo.size.height)
                                .contentShape(Rectangle())
                                .animation(.easeInOut(duration: 0.22), value: rotationAngle)
                                .animation(.easeInOut(duration: 0.22), value: userZoom)
                        } else {
                            ContentUnavailableView(
                                "Select a photo",
                                systemImage: "photo",
                                description: Text("Pick one image to search by face.")
                            )
                        }
                    }
                }

                // MARK: Bottom controls — 4 кнопки в одном ряду, равные интервалы 24.scale
                HStack(spacing: 24.scale) {
                    ControlButton(asset: "rotateLeft") {
                        withAnimation { rotationAngle -= .degrees(90) }
                    }

                    ControlButton(asset: "rotateRight") {
                        withAnimation { rotationAngle += .degrees(90) }
                    }

                    ControlButton(asset: "resize") {
                        withAnimation { userZoom = (abs(userZoom - 1.0) < 0.001) ? 1.2 : 1.0 }
                    }

                    NextButton {
                        guard let img = image,
                              let jpeg = img.jpegData(compressionQuality: 0.85) else { return }

                        let isPremium = (resolver.resolve(PremiumStore.self)?.isPremium ?? false)
                        guard isPremium else { showPaywall = true; return }

                        didAnalyze = true
                        vm.runImageSearch(jpegData: jpeg)
                    }
                    .disabled(image == nil || vm.isLoading)
                }
                .frame(maxWidth: .infinity, alignment: .center) // ✅ вся группа по центру
                .padding(.horizontal, 24.scale)
                .padding(.vertical, 20.scale)
                .background(
                    Tokens.Color.surfaceCard,
                    ignoresSafeAreaEdges: .bottom
                )
            }
        }
        .navigationBarBackButtonHidden(true)

        // Photos picker
        .photosPicker(isPresented: Binding(get: { image == nil && item == nil }, set: { _ in }),
                      selection: $item, matching: .images)
        .onChange(of: item) { _, newValue in
            Task { @MainActor in
                guard let data = try? await newValue?.loadTransferable(type: Data.self),
                      let img = UIImage(data: data) else { return }
                image = img
                rotationAngle = .zero
                userZoom = 1.0
            }
        }

        // Завершение анализа → пушим результаты
        .onChange(of: vm.isLoading) { was, isNow in
            if didAnalyze && was == true && isNow == false {
                didAnalyze = false
                onFinished()
            }
        }

        // Full-screen loading
        .fullScreenCover(isPresented: Binding(get: { vm.isBlockingLoading }, set: { _ in })) {
            LoadingView(mode: .face, previewImage: image, cancelAction: nil)
                .interactiveDismissDisabled(true)
        }

        // Paywall
        .fullScreenCover(isPresented: $showPaywall) {
            let paywallVM = resolver.resolve(PaywallViewModel.self)!
            PaywallView(vm: paywallVM).presentationDetents([.large])
        }
    }
}

// MARK: - Универсальная кружковая кнопка 48×48 с белым фоном и тенью
private struct ControlButton: View {
    let asset: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 48.scale, height: 48.scale)
                    // две мягкие тени, чтобы фон был виден на белом баре
                    .shadow(color: Tokens.Color.shadowBlack7, radius: 12.scale, x: 0, y: 0)
                    .shadow(color: Tokens.Color.shadowBlack7.opacity(0.6), radius: 4.scale, x: 0, y: 0)

                Image(asset)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 20.scale, height: 20.scale)
                    .foregroundStyle(Color(hex: "#141414"))
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Accent next button 48×48 с тенью, иконка 20×20
private struct NextButton: View {
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Tokens.Color.accent)
                    .frame(width: 48.scale, height: 48.scale)
                    .shadow(color: Tokens.Color.shadowBlack7, radius: 12.scale, x: 0, y: 0)
                    .shadow(color: Tokens.Color.shadowBlack7.opacity(0.6), radius: 4.scale, x: 0, y: 0)

                Image("nextArrow")
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 20.scale, height: 20.scale)
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(.plain)
    }
}
