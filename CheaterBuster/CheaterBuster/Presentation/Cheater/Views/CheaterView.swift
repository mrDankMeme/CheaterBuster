// Presentation/Cheater/CheaterView.swift
// CheaterBuster

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers
import Swinject

struct CheaterView: View {
    @ObservedObject var vm: CheaterViewModel
    @EnvironmentObject private var router: AppRouter
    @Environment(\.resolver) private var resolver

    @State private var photoItem: PhotosPickerItem?
    @State private var showPhotoPicker = false
    @State private var showFilePicker = false
    @State private var conversationText: String = ""
    @State private var showSavedAlert = false
    @State private var showPaywall = false
    @State private var showSourceSheet = false

    // Показываем превью в .uploading
    @State private var lastPreviewImage: UIImage? = nil

    init(vm: CheaterViewModel) { self.vm = vm }

    var body: some View {
        VStack(spacing: Tokens.Spacing.x16) { content }
            .padding(.horizontal, Tokens.Spacing.x16)
            .padding(.top, Tokens.Spacing.x24)
            .background(Tokens.Color.backgroundMain.ignoresSafeArea())
            .navigationTitle(navigationTitle)
            .toolbar(.hidden, for: .navigationBar)

            // Pickers
            .photosPicker(isPresented: $showPhotoPicker,
                          selection: $photoItem,
                          matching: .images)
            .fileImporter(
                isPresented: $showFilePicker,
                allowedContentTypes: [.pdf, .png, .jpeg, .plainText],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    guard let url = urls.first else { return }
                    let secured = url.startAccessingSecurityScopedResource()
                    defer { if secured { url.stopAccessingSecurityScopedResource() } }
                    do {
                        let data = try Data(contentsOf: url)
                        vm.showFile(name: url.lastPathComponent, data: data)
                    } catch {
                        vm.presentError("Failed to read file: \(error.localizedDescription)")
                    }
                case .failure(let error):
                    vm.presentError(error.localizedDescription)
                }
            }

            // Photos -> UIImage
            .onChange(of: photoItem) { item in
                guard let item else { return }
                Task {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let img  = UIImage(data: data) {
                        await MainActor.run {
                            vm.showImage(img)
                            lastPreviewImage = img
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

            // Source picker overlay
            .overlay(alignment: .bottom) {
                if showSourceSheet {
                    SourcePickerOverlay(
                        onFiles:  { showFilePicker = true },
                        onLibrary:{ showPhotoPicker = true },
                        onDismiss:{ showSourceSheet = false }
                    )
                }
            }
    }

    // MARK: - Content
    @ViewBuilder
    private var content: some View {
        switch vm.state {
        case .idle: idleView
        case .previewImage(let img): imagePreview(img)
        case .previewFile(let name, _): filePreview(name: name)
        case .uploading(let p): uploadingView(progress: p)
        case .result(let r):
            // MARK: - Changed: вынесли в отдельный файл
            CheaterResultView(
                result: r,
                onBack: { vm.goBackToIdle() },
                onSelectMessage: { withAnimation(.easeOut(duration: 0.2)) { showSourceSheet = true } }
            )
        case .error(let msg): errorView(msg)
        }
    }

    // MARK: - Idle
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
                withAnimation(.easeOut(duration: 0.2)) { showSourceSheet = true }
            }
        }
        .padding(.bottom, 24.scale)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }

    // MARK: - Image preview
    private func imagePreview(_ img: UIImage) -> some View {
        VStack(spacing: 0) {
            header
            ScrollView {
                VStack(spacing: 20.scale) {
                    imageCard(image: img)
                        .onAppear { lastPreviewImage = img }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 8.scale)
            }
            VStack(spacing: 12.scale) {
                PrimaryButton("Analyse") {
                    let isPremium = (resolver.resolve(PremiumStore.self)?.isPremium ?? false)
                    guard isPremium else { showPaywall = true; return }
                    vm.analyseCurrent(conversation: conversationText, apphudId: "debug-apphud-id")
                }
            }
            .padding(.horizontal, 16.scale)
            .padding(.top, 16.scale)
            .padding(.bottom, 24.scale)
        }
        .background(Tokens.Color.backgroundMain.ignoresSafeArea())
    }

    // MARK: - Uploading
    private func uploadingView(progress p: Int) -> some View {
        VStack(spacing: 0) {
            header
            ScrollView {
                VStack(spacing: 20.scale) {
                    if let img = lastPreviewImage {
                        imageCard(image: img)
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: Tokens.Radius.medium.scale, style: .continuous)
                                .fill(Tokens.Color.surfaceCard)
                                .overlay(
                                    RoundedRectangle(cornerRadius: Tokens.Radius.medium.scale, style: .continuous)
                                        .stroke(Tokens.Color.borderNeutral, lineWidth: 1)
                                )
                                .apply(Tokens.Shadow.card)
                            Text("Preparing preview…")
                                .font(Tokens.Font.caption)
                                .foregroundColor(Tokens.Color.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 420.scale)
                        .padding(.horizontal, 8.scale)
                    }

                    Text("\(p)%")
                        .font(.system(size: 20, weight: .bold))
                        .tracking(-0.20)
                        .foregroundColor(Tokens.Color.textPrimary)
                        .multilineTextAlignment(.center)

                    // MARK: - Fixed progress fill (теперь не “полный красный”)
                    ProgressBar(progress: max(0, min(1, Double(p) / 100.0)))
                        .frame(width: 260.scale, height: 8.scale)
                        .padding(.top, 8.scale)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 8.scale)
            }

            // Кнопка становится активной только при 100%
            VStack(spacing: 12.scale) {
                PrimaryButton("View analysis report") { }
                    .disabled(p < 100)
                    .opacity(p < 100 ? 0.6 : 1)
            }
            .padding(.horizontal, 16.scale)
            .padding(.top, 16.scale)
            .padding(.bottom, 24.scale)
        }
        .background(Tokens.Color.backgroundMain.ignoresSafeArea())
    }

    // MARK: - Header (общий)
    private var header: some View {
        HStack {
            BackButton(size: 44.scale) { vm.goBackToIdle() }
            Spacer()
            Text("Image analysis")
                .font(.system(size: 18, weight: .medium))
                .tracking(-0.18)
                .foregroundColor(Tokens.Color.textPrimary)
            Spacer()
            Color.clear.frame(width: 44.scale, height: 44.scale)
        }
        .padding(.horizontal, 16.scale)
        .padding(.bottom, 12.scale)
    }

    // MARK: - Image card
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

    // MARK: - File preview (без изменений)
    private func filePreview(name: String) -> some View {
        VStack(spacing: Tokens.Spacing.x16) {
            VStack(spacing: Tokens.Spacing.x12) {
                Image(systemName: "folder")
                    .resizable().scaledToFit()
                    .frame(width: 112.scale, height: 112.scale)
                    .foregroundColor(Tokens.Color.textSecondary)
                Text(name)
                    .font(Tokens.Font.body)
                    .foregroundColor(Tokens.Color.textPrimary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, Tokens.Spacing.x16)

            PrimaryButton("Analyse") {
                let isPremium = (resolver.resolve(PremiumStore.self)?.isPremium ?? false)
                guard isPremium else { showPaywall = true; return }
                vm.analyseCurrent(conversation: conversationText, apphudId: "debug-apphud-id")
            }

            Spacer(minLength: 0)
        }
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
        case .previewImage, .previewFile, .uploading, .result, .error: return "Image analysis"
        }
    }
}
