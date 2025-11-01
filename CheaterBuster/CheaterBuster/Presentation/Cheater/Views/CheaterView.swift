//
//  CheaterView.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers
import Swinject
import UIKit // для TabBarAnimator

struct CheaterView: View {
    @ObservedObject var vm: CheaterViewModel
    @EnvironmentObject private var router: AppRouter
    @Environment(\.resolver) private var resolver

    // PhotosPicker
    @State private var photoItem: PhotosPickerItem?
    @State private var showPhotoPicker = false

    // Document picker
    @State private var showFilePicker = false

    // Optional text conversation
    @State private var conversationText: String = ""

    // Alert after saving
    @State private var showSavedAlert = false

    // Paywall
    @State private var showPaywall = false

    // Bottom sheet (overlay)
    @State private var showSourceSheet = false

    // Кеши выбора
    @State private var lastPreviewImage: UIImage? = nil
    @State private var lastFileName: String? = nil
    @State private var lastFileData: Data? = nil

    private enum CheaterRoute: Hashable {
        case imagePreview
        case filePreview
        case uploading
        case result
    }

    @State private var path: [CheaterRoute] = []
    @State private var routedResult: TaskResult? = nil

    init(vm: CheaterViewModel) { self.vm = vm }

    // MARK: - Helpers
    private var isFileContext: Bool { lastPreviewImage == nil && lastFileName != nil }

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: Tokens.Spacing.x16) {
                content
            }
            .padding(.horizontal, Tokens.Spacing.x16)
            .padding(.top, Tokens.Spacing.x24)
            .background(Tokens.Color.backgroundMain.ignoresSafeArea())
            .navigationTitle(navigationTitle)
            .toolbar(.hidden, for: .navigationBar)

            // Pickers
            .photosPicker(isPresented: $showPhotoPicker, selection: $photoItem, matching: .images)
            .fileImporter(isPresented: $showFilePicker,
                          allowedContentTypes: [.pdf, .png, .jpeg, .plainText],
                          allowsMultipleSelection: false) { result in
                switch result {
                case .success(let urls):
                    guard let url = urls.first else { return }
                    let secured = url.startAccessingSecurityScopedResource()
                    defer { if secured { url.stopAccessingSecurityScopedResource() } }
                    do {
                        let data = try Data(contentsOf: url)
                        vm.showFile(name: url.lastPathComponent, data: data)
                        lastFileName = url.lastPathComponent
                        lastFileData = data
                        if path.last != .filePreview { path.append(.filePreview) }
                    } catch {
                        vm.presentError("Failed to read file: \(error.localizedDescription)")
                    }
                case .failure(let error):
                    vm.presentError(error.localizedDescription)
                }
            }

            // Фото -> UIImage
            .onChange(of: photoItem) { item in
                guard let item else { return }
                Task {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let img  = UIImage(data: data) {
                        await MainActor.run {
                            vm.showImage(img)
                            lastPreviewImage = img
                            lastFileName = nil
                            lastFileData = nil
                            path.append(.imagePreview)
                        }
                    } else {
                        await MainActor.run { vm.presentError("Failed to load photo") }
                    }
                    await MainActor.run { photoItem = nil }
                }
            }

            // Saved alert
            .onChange(of: vm.didSave) { _, saved in
                guard saved else { return }
                showSavedAlert = true
            }
            .alert("Saved to History", isPresented: $showSavedAlert) {
                Button("Open History") { router.openHistoryCheater() }
                Button("OK", role: .cancel) { }
            }

            // Paywall
            .fullScreenCover(isPresented: $showPaywall) {
                let paywallVM = resolver.resolve(PaywallViewModel.self)!
                PaywallView(vm: paywallVM).presentationDetents([.large])
            }

            // Навигация по состояниям VM
            .onChange(of: vm.state) { _, newState in
                switch newState {
                case .previewFile(let name, let data):
                    lastPreviewImage = nil
                    lastFileName = name; lastFileData = data
                    if path.last != .filePreview { path.append(.filePreview) }
                case .uploading:
                    if path.last != .uploading { path.append(.uploading) }
                case .result(let r):
                    routedResult = r // откроем по кнопке
                default: break
                }
            }

            // Сброс VM при возврате на корень
            .onChange(of: path) { _, newPath in
                if newPath.isEmpty, vm.state != .idle { vm.goBackToIdle() }
            }

            // Экраны
            .navigationDestination(for: CheaterRoute.self) { route in
                switch route {
                case .imagePreview:
                    Group {
                        if let img = lastPreviewImage {
                            imagePreview(img)
                        } else {
                            VStack { Text("No image").foregroundColor(.red); Spacer() }
                        }
                    }
                    .navigationBarBackButtonHidden(true)
                    .edgeSwipeToPop(isEnabled: true) { _ = path.popLast() }

                case .filePreview:
                    Group {
                        if let name = lastFileName, let data = lastFileData {
                            filePreview(name: name, data: data)
                        } else {
                            VStack { Text("No file").foregroundColor(.red); Spacer() }
                        }
                    }
                    .navigationBarBackButtonHidden(true)
                    .edgeSwipeToPop(isEnabled: true) { _ = path.popLast() }

                case .uploading:
                    uploadingScreen()

                case .result:
                    if let r = routedResult {
                        CheaterResultView(
                            result: r,
                            onBack: { path.removeLast() },
                            onSelectMessage: { withAnimation(.easeOut(duration: 0.2)) { showSourceSheet = true } },
                            // MARK: - Added: корректный заголовок отчёта
                            analysisTitle: (lastPreviewImage == nil && lastFileName != nil) ? "Files analysis" : "Image analysis"
                        )
                        .navigationBarBackButtonHidden(true)
                        .edgeSwipeToPop(isEnabled: true) { _ = path.popLast() }
                    } else {
                        VStack { Text("No result").foregroundColor(.red); Spacer() }
                            .navigationBarBackButtonHidden(true)
                            .edgeSwipeToPop(isEnabled: true) { _ = path.popLast() }
                    }
                }
            }
        }
        // overlay выбора источника
        .overlay(alignment: .bottom) {
            if showSourceSheet {
                SourcePickerOverlay(
                    onFiles:  { showSourceSheet = false; showFilePicker  = true },
                    onLibrary:{ showSourceSheet = false; showPhotoPicker = true },
                    onDismiss:{ showSourceSheet = false }
                )
                .zIndex(1000)
                .ignoresSafeArea()
                .onAppear { TabBarAnimator.set(slidDown: true) }
                .onDisappear { TabBarAnimator.set(slidDown: false) }
            }
        }
        .onChange(of: showSourceSheet) { _, isShown in TabBarAnimator.set(slidDown: isShown) }
        .onDisappear { TabBarAnimator.set(slidDown: false) }
        .enableInteractivePop()
    }

    // MARK: - Root content
    @ViewBuilder
    private var content: some View {
        switch vm.state {
        case .idle: idleView
        default: EmptyView()
        }
    }

    private var idleView: some View {
        VStack(spacing: Tokens.Spacing.x24) {
            Spacer(minLength: 0)
            Text("Analysis of the fraudster's correspondence")
                .font(Tokens.Font.title)
                .tracking(-0.22)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16.scale)
            Spacer()
            PrimaryButton("Select message") {
                withAnimation(.easeInOut(duration: 0.25)) { showSourceSheet = true }
            }
        }
        .padding(.bottom, 24.scale)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }

    // MARK: - Image preview
    private func imagePreview(_ img: UIImage) -> some View {
        VStack(spacing: 0) {
            header(title: "Image analysis")
            ScrollView {
                VStack(spacing: 20.scale) {
                    imageCard(image: img).onAppear { lastPreviewImage = img }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 8.scale)
            }
            VStack(spacing: 12.scale) {
                PrimaryButton("Analyse") {
                    let isPremium = (resolver.resolve(PremiumStore.self)?.isPremium ?? false)
                    guard isPremium else { showPaywall = true; return }
                    if let img = lastPreviewImage { vm.showImage(img) }
                    vm.analyseCurrent(conversation: conversationText, apphudId: "debug-apphud-id")
                }
            }
            .padding(.horizontal, 16.scale)
            .padding(.top, 16.scale)
            .padding(.bottom, 24.scale)
        }
        .background(Tokens.Color.backgroundMain.ignoresSafeArea())
    }

    // MARK: - Files preview (центрирование)  // MARK: - Changed
    private func filePreview(name: String, data: Data) -> some View {
        VStack(spacing: 0) {
            header(title: "Files analysis")
            VStack(spacing: 16.scale) {
                Spacer(minLength: 0)

                ZStack {
                    RoundedRectangle(cornerRadius: 22.scale, style: .continuous)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.06), radius: 8.scale, x: 0, y: 0)

                    Image("ic_file_analysis_placeholder")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 64.scale, height: 64.scale)
                        .accessibilityHidden(true)
                }
                .frame(width: 112.scale, height: 112.scale)

                Text(name)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(Color(hex: "#141414"))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal, 16.scale)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 8.scale)

            VStack(spacing: 12.scale) {
                PrimaryButton("Analyse") {
                    let isPremium = (resolver.resolve(PremiumStore.self)?.isPremium ?? false)
                    guard isPremium else { showPaywall = true; return }
                    vm.showFile(name: name, data: data) // держим контекст файла
                    vm.analyseCurrent(conversation: conversationText, apphudId: "debug-apphud-id")
                }
            }
            .padding(.horizontal, 16.scale)
            .padding(.top, 16.scale)
            .padding(.bottom, 24.scale)
        }
        .background(Tokens.Color.backgroundMain.ignoresSafeArea())
    }

    // MARK: - Uploading screen с карточкой и нижней зоной  // MARK: - Changed
    @ViewBuilder
    private func uploadingScreen() -> some View {
        let p: Int = {
            if case let .uploading(val) = vm.state { return val }
            if case .result = vm.state { return 100 }
            return 0
        }()

        VStack(spacing: 0) {
            header(title: isFileContext ? "Files analysis" : "Image analysis") // меняем заголовок

            // Центр: показываем карточку как на экране анализа
            VStack(spacing: 16.scale) {
                Spacer(minLength: 0)

                if let img = lastPreviewImage {
                    imageCard(image: img)
                        .padding(.horizontal, 8.scale)
                } else if let name = lastFileName {
                    ZStack {
                        RoundedRectangle(cornerRadius: 22.scale, style: .continuous)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.06), radius: 8.scale, x: 0, y: 0)

                        Image("ic_file_analysis_placeholder")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 64.scale, height: 64.scale)
                    }
                    .frame(width: 112.scale, height: 112.scale)

                    Text(name)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(Color(hex: "#141414"))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .padding(.horizontal, 16.scale)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 8.scale)

            // Низ: проценты + ProgressBar + кнопка
            VStack(spacing: 12.scale) {
                Text("\(p)%")
                    .font(.system(size: 20, weight: .bold))
                    .tracking(-0.20)
                    .foregroundColor(Tokens.Color.textPrimary)
                    .multilineTextAlignment(.center)

                ProgressBar(progress: max(0, min(1, Double(p) / 100.0)))
                    .frame(width: 260.scale, height: 8.scale)

                PrimaryButton("View analysis report") {
                    if path.last != .result { path.append(.result) }
                }
                .disabled(p < 100)
                .opacity(p < 100 ? 0.6 : 1)
            }
            .padding(.horizontal, 16.scale)
            .padding(.top, 16.scale)
            .padding(.bottom, 24.scale)
        }
        .background(Tokens.Color.backgroundMain.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .edgeSwipeToPop(isEnabled: true) { _ = path.popLast() }
    }

    // MARK: - Общий заголовок
    private func header(title: String) -> some View {
        HStack {
            BackButton(size: 44.scale) {
                if !path.isEmpty { _ = path.popLast() } else { vm.goBackToIdle() }
            }
            Spacer()
            Text(title)
                .font(.system(size: 18, weight: .medium))
                .tracking(-0.18)
                .foregroundColor(Tokens.Color.textPrimary)
            Spacer()
            Color.clear.frame(width: 44.scale, height: 44.scale)
        }
        .padding(.horizontal, 16.scale)
        .padding(.bottom, 12.scale)
    }

    // MARK: - Вспомогательные
    private func imageCard(image: UIImage) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: Tokens.Radius.medium.scale, style: .continuous)
                .fill(Tokens.Color.surfaceCard)
                .overlay(
                    RoundedRectangle(cornerRadius: Tokens.Radius.medium.scale, style: .continuous)
                        .stroke(Tokens.Color.borderNeutral, lineWidth: 1)
                )
                .apply(Tokens.Shadow.card)

            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 200.scale, maxHeight: 400.scale)
                .clipped()
                .cornerRadius(Tokens.Radius.small.scale)
                .padding(16.scale)
        }
        .padding(.horizontal, 8.scale)
    }

    private func errorView(_ msg: String) -> some View {
        VStack(spacing: Tokens.Spacing.x16) {
            Text(msg).font(Tokens.Font.body).foregroundColor(.red).multilineTextAlignment(.center)
            PrimaryButton("Try again") { withAnimation(.easeOut(duration: 0.2)) { showSourceSheet = true } }
            Spacer(minLength: 0)
        }
        .navigationTitle("Image analysis")
    }

    private var navigationTitle: String {
        switch vm.state {
        case .idle: return "Cheater"
        case .previewImage, .previewFile, .uploading, .result, .error:
            return isFileContext ? "Files analysis" : "Image analysis" // MARK: - Changed
        }
    }
}
