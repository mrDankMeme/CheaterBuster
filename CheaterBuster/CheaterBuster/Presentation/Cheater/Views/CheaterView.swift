//
//  CheaterView.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers
import Swinject // MARK: - Added

struct CheaterView: View {
    @ObservedObject var vm: CheaterViewModel
    @EnvironmentObject private var router: AppRouter
    @Environment(\.resolver) private var resolver // MARK: - Added

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

    // Bottom sheet
    @State private var showSourceSheet = false

    init(vm: CheaterViewModel) { self.vm = vm }

    var body: some View {
        VStack(spacing: Tokens.Spacing.x16) { content }
            .padding(.horizontal, Tokens.Spacing.x16)
            .padding(.top, Tokens.Spacing.x24)
            .background(Tokens.Color.backgroundMain.ignoresSafeArea())
            .navigationTitle(navigationTitle)

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

            .onChange(of: photoItem) { item in
                guard let item else { return }
                Task {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let img  = UIImage(data: data) {
                        await MainActor.run { vm.showImage(img) }
                    } else {
                        await MainActor.run { vm.presentError("Failed to load photo") }
                    }
                    await MainActor.run { photoItem = nil }
                }
            }

            .onChange(of: vm.didSave) { _, saved in
                guard saved else { return }
                showSavedAlert = true
            }
            .alert("Saved to History", isPresented: $showSavedAlert) {
                Button("Open History") { router.openHistoryCheater() }
                Button("OK", role: .cancel) { }
            }

            .fullScreenCover(isPresented: $showPaywall) {
                let paywallVM = resolver.resolve(PaywallViewModel.self)!
                PaywallView(vm: paywallVM).presentationDetents([.large])
            }

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
        case .result(let r): resultView(r)
        case .error(let msg): errorView(msg)
        }
    }

    // MARK: - Idle
    private var idleView: some View {
        VStack(spacing: Tokens.Spacing.x24) {
            Spacer(minLength: 0)
            Text("Analysis of the fraudster's correspondence")
                .font(Tokens.Font.title)     // 22 Medium
                .tracking(-0.22)             // -1%
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
        VStack(spacing: Tokens.Spacing.x16) {
            ScrollView {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(Tokens.Radius.medium.scale)
                    .overlay(
                        RoundedRectangle(cornerRadius: Tokens.Radius.medium.scale, style: .continuous)
                            .stroke(Tokens.Color.borderNeutral, lineWidth: 1)
                    )
            }
            PrimaryButton("Analyse") {
                let isPremium = (resolver.resolve(PremiumStore.self)?.isPremium ?? false)
                guard isPremium else { showPaywall = true; return }
                vm.analyseCurrent(conversation: conversationText, apphudId: "debug-apphud-id")
            }
            Button("Choose another…") { showSourceActionSheet() }
                .font(Tokens.Font.body)
                .foregroundColor(Tokens.Color.textSecondary)
        }
        .navigationTitle("Image analysis")
    }

    // MARK: - File preview
    private func filePreview(name: String) -> some View {
        VStack(spacing: Tokens.Spacing.x16) {
            VStack(spacing: Tokens.Spacing.x12) {
                Image(systemName: "folder")
                    .resizable().scaledToFit()
                    .frame(width: 112.scale, height: 112.scale) // 112.scale x 112.scale
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
            Button("Choose another…") { showSourceActionSheet() }
                .font(Tokens.Font.body)
                .foregroundColor(Tokens.Color.textSecondary)
            Spacer(minLength: 0)
        }
        .navigationTitle("Image analysis")
    }

    private func uploadingView(progress p: Int) -> some View {
        VStack(spacing: Tokens.Spacing.x16) {
            ScrollView { EmptyView() }
            Text("\(p)%").font(Tokens.Font.body).foregroundColor(Tokens.Color.textSecondary)
            Spacer(minLength: 0)
        }
        .navigationTitle("Image analysis")
    }

    private func resultView(_ r: TaskResult) -> some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.x16) {
            Text("Risk analysis complete ✅").font(Tokens.Font.title)
            Text("\(r.risk_score)%").font(Tokens.Font.h1)
            Text(riskLevelText(r.risk_score)).font(Tokens.Font.body).foregroundColor(Tokens.Color.textSecondary)
            Divider()
            Text("Red flags").font(Tokens.Font.subtitle)
            ForEach(r.red_flags, id: \.self) { Text("• \($0)") }
            Divider()
            Text("Recommendations").font(Tokens.Font.subtitle)
            ForEach(r.recommendations, id: \.self) { Text("• \($0)") }
            PrimaryButton("Save to History") { vm.saveToHistory() }
            ShareLink(item: shareText(for: r)) {
                Text("Share")
                    .font(Tokens.Font.caption)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12.scale)
                    .background(
                        Tokens.Color.accent,
                        in: RoundedRectangle(cornerRadius: Tokens.Radius.pill.scale, style: .continuous)
                    )
            }
            Button("Select another") { showSourceActionSheet() }
                .font(Tokens.Font.body)
                .foregroundColor(Tokens.Color.textSecondary)
                .padding(.top, Tokens.Spacing.x8)
            Spacer(minLength: 0)
        }
        .navigationTitle("Image analysis")
    }

    private func errorView(_ msg: String) -> some View {
        VStack(spacing: Tokens.Spacing.x16) {
            Text(msg).font(Tokens.Font.body).foregroundColor(.red).multilineTextAlignment(.center)
            PrimaryButton("Try again") { showSourceActionSheet() }
            Spacer(minLength: 0)
        }
        .navigationTitle("Image analysis")
    }

    private func riskLevelText(_ score: Int) -> String {
        switch score { case 0..<34: return "Low risk level"
        case 34..<67: return "Medium risk level"
        default: return "High risk level" }
    }

    private func shareText(for r: TaskResult) -> String {
        """
        CheaterBuster — analysis result:
        Risk: \(r.risk_score)%
        Red flags: \(r.red_flags.joined(separator: "; "))
        Recommendations: \(r.recommendations.joined(separator: "; "))
        """
    }

    private func showSourceActionSheet() {
        withAnimation(.easeOut(duration: 0.2)) { showSourceSheet = true }
    }

    private var navigationTitle: String {
        switch vm.state {
        case .idle: return "Cheater"
        case .previewImage, .previewFile, .uploading, .result, .error: return "Image analysis"
        }
    }
}

// MARK: - Bottom Sheet (SourcePickerOverlay) — плавный dismiss + drag-to-dismiss
private struct SourcePickerOverlay: View {
    let onFiles: () -> Void
    let onLibrary: () -> Void
    let onDismiss: () -> Void

    @State private var shown = false                  // карточка показана
    @GestureState private var dragY: CGFloat = 0      // текущий сдвиг пальцем (вниз >= 0)

    // MARK: - Added: устойчивый dismiss без "рывка"
    @State private var isDismissing = false           // сейчас закрываемся
    @State private var endDragY: CGFloat = 0          // финальный сдвиг в момент onEnded
    private var dismissThreshold: CGFloat { 140.scale }
    private var dismissTravel: CGFloat { 260.scale }  // сколько докатываем вниз при закрытии

    var body: some View {
        ZStack(alignment: .bottom) {
            // фон плавно гаснет при dismiss
            Color.black.opacity(backgroundOpacity)
                .ignoresSafeArea()
                .onTapGesture { dismissThen(from: 0) }
                .animation(.easeOut(duration: 0.22), value: backgroundOpacity)

            sheet
                .offset(y: sheetOffset) // ← непрерывный оффсет
                .animation(.interactiveSpring(response: 0.28, dampingFraction: 0.9), value: dragY)
                .animation(.easeOut(duration: 0.22), value: isDismissing)
                .animation(.easeOut(duration: 0.20), value: shown)
                .gesture(
                    DragGesture(minimumDistance: 3, coordinateSpace: .local)
                        .updating($dragY) { value, state, _ in
                            state = max(0, value.translation.height) // только вниз
                        }
                        .onEnded { value in
                            let dy = max(0, value.translation.height)
                            let predicted = max(0, value.predictedEndLocation.y - value.location.y)
                            if dy > dismissThreshold || predicted > dismissThreshold {
                                // закрываемся, начиная с ТЕКУЩЕЙ позиции dy — без рывка
                                dismissThen(from: dy)
                            } else {
                                // откат назад
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                    shown = true
                                    isDismissing = false
                                }
                            }
                        }
                )
        }
        .onAppear { shown = true }
    }

    // MARK: - Derived values
    private var sheetOffset: CGFloat {
        if isDismissing {
            // продолжаем движение вниз от зафиксированной позиции жеста
            return endDragY + dismissTravel
        } else {
            // обычный показ/перетаскивание
            return (shown ? 0 : 40.scale) + max(0, dragY)
        }
    }

    private var backgroundOpacity: Double {
        let base: Double = shown && !isDismissing ? 0.35 : 0.0
        // при перетаскивании фон слегка светлеет
        if !isDismissing {
            let progress = max(0, 1 - Double(dragY / (dismissThreshold * 1.5)))
            return base == 0 ? 0 : base * progress
        } else {
            return 0 // во время dismiss фейдим к 0
        }
    }

    // MARK: - Dismiss helper (без рывка)
    private func dismissThen(from currentDrag: CGFloat) {
        endDragY = currentDrag
        isDismissing = true
        shown = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.24) {
            onDismiss()
        }
    }

    // MARK: - Card content
    private var sheet: some View {
        VStack(spacing: 16.scale) {
            RoundedRectangle(cornerRadius: 3.scale)
                .fill(Tokens.Color.borderNeutral.opacity(0.6))
                .frame(width: 40.scale, height: 4.scale)
                .padding(.top, 8.scale)

            Text("Select a photo or file")
                .font(.system(size: 20, weight: .medium)) // 20 Medium
                .tracking(-0.20)
                .multilineTextAlignment(.center)
                .padding(.bottom, 8.scale)

            VStack(spacing: 12.scale) {
                SourceRow(systemImage: "folder", title: "Files") {
                    dismissThen(from: 0) // закрыть плавно, затем открыть пикер
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) { onFiles() }
                }
                SourceRow(systemImage: "photo.on.rectangle.angled", title: "Library") {
                    dismissThen(from: 0)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) { onLibrary() }
                }
            }
            .padding(.horizontal, 16.scale)
            .padding(.bottom, 16.scale)
        }
        .frame(maxWidth: .infinity)
        .background(
            Tokens.Color.surfaceCard,
            in: RoundedRectangle(cornerRadius: 28.scale, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28.scale, style: .continuous)
                .stroke(Tokens.Color.borderNeutral, lineWidth: 1)
        )
        .apply(Tokens.Shadow.card)
        .padding(.horizontal, 8.scale)
        .padding(.bottom, 8.scale)
    }
}

private struct SourceRow: View {
    let systemImage: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12.scale) {
                ZStack {
                    Tokens.Color.backgroundMain
                    Image(systemName: systemImage)
                        .font(.system(size: 18.scale, weight: .semibold))
                        .foregroundStyle(Tokens.Color.accent)
                }
                .frame(width: 44.scale, height: 44.scale)
                .clipShape(RoundedRectangle(cornerRadius: 14.scale, style: .continuous))

                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .tracking(-0.16)

                Spacer()
            }
            .padding(.vertical, 12.scale)
            .padding(.horizontal, 12.scale)
            .background(
                Tokens.Color.surfaceCard,
                in: RoundedRectangle(cornerRadius: Tokens.Radius.medium.scale, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Tokens.Radius.medium.scale, style: .continuous)
                    .stroke(Tokens.Color.borderNeutral, lineWidth: 1)
            )
            .apply(Tokens.Shadow.card)
        }
        .buttonStyle(.plain)
    }
}
