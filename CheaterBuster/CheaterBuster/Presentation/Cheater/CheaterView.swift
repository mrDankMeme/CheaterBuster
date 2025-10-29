//
//  CheaterView.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct CheaterView: View {
    @ObservedObject var vm: CheaterViewModel
    @EnvironmentObject private var router: AppRouter

    // PhotosPicker
    @State private var photoItem: PhotosPickerItem?
    @State private var showPhotoPicker = false

    // Document picker
    @State private var showFilePicker = false

    // (опционально) сопроводительный текст переписки
    @State private var conversationText: String = ""

    // E8: алерт после сохранения
    @State private var showSavedAlert = false

    init(vm: CheaterViewModel) {
        self.vm = vm
    }

    var body: some View {
        VStack(spacing: Tokens.Spacing.x16) {
            content
        }
        .padding(.horizontal, Tokens.Spacing.x16)
        .padding(.top, Tokens.Spacing.x24)
        .background(Tokens.Color.backgroundMain.ignoresSafeArea())
        .navigationTitle("Cheater")

        // ---- Pickers ----
        .photosPicker(isPresented: $showPhotoPicker, selection: $photoItem, matching: .images)

        .fileImporter(
            isPresented: $showFilePicker,
            allowedContentTypes: [.pdf, .png, .jpeg, .plainText],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                // Важно: security-scoped доступ
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

        // ---- E8: алерт и переход на History после сохранения ----
        .onChange(of: vm.didSave) { _, saved in
            guard saved else { return }
            showSavedAlert = true
        }
        .alert("Saved to History", isPresented: $showSavedAlert) {
            Button("Open History") { router.tab = .history }
            Button("OK", role: .cancel) { }
        }
    }

    // MARK: - Секции по состояниям

    @ViewBuilder
    private var content: some View {
        switch vm.state {
        case .idle:
            idleView

        case .previewImage(let img):
            imagePreview(img)

        case .previewFile(let name, _):
            filePreview(name: name)

        case .uploading(let p):
            uploadingView(progress: p)

        case .result(let r):
            resultView(r)

        case .error(let msg):
            errorView(msg)
        }
    }

    // Idle
    private var idleView: some View {
        VStack(spacing: Tokens.Spacing.x24) {
            VStack(spacing: Tokens.Spacing.x8) {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 56))
                    .foregroundColor(Tokens.Color.textSecondary)
                Text("Select photo or file to analyse")
                    .font(Tokens.Font.body)
                    .foregroundColor(Tokens.Color.textPrimary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, Tokens.Spacing.x16)

            PrimaryButton("Pick photo") { showPhotoPicker = true }
            PrimaryButton("Pick file")  { showFilePicker  = true }

            Spacer(minLength: 0)
        }
    }

    // Image preview
    private func imagePreview(_ img: UIImage) -> some View {
        VStack(spacing: Tokens.Spacing.x16) {
            ScrollView {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(Tokens.Radius.medium)
                    .overlay(
                        RoundedRectangle(cornerRadius: Tokens.Radius.medium, style: .continuous)
                            .stroke(Tokens.Color.borderNeutral, lineWidth: 1)
                    )
            }

            PrimaryButton("Analyse") {
                vm.analyseCurrent(conversation: conversationText, apphudId: "debug-apphud-id")
            }

            Button("Choose another…") { showSourceActionSheet() }
                .font(Tokens.Font.body)
                .foregroundColor(Tokens.Color.textSecondary)
        }
    }

    // File preview
    private func filePreview(name: String) -> some View {
        VStack(spacing: Tokens.Spacing.x16) {
            VStack(spacing: Tokens.Spacing.x12) {
                Image(systemName: "doc.richtext")
                    .font(.system(size: 56))
                    .foregroundColor(Tokens.Color.textSecondary)
                Text(name)
                    .font(Tokens.Font.body)
                    .foregroundColor(Tokens.Color.textPrimary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, Tokens.Spacing.x16)

            PrimaryButton("Analyse") {
                vm.analyseCurrent(conversation: conversationText, apphudId: "debug-apphud-id")
            }

            Button("Choose another…") { showSourceActionSheet() }
                .font(Tokens.Font.body)
                .foregroundColor(Tokens.Color.textSecondary)
            Spacer(minLength: 0)
        }
    }

    // Uploading
    private func uploadingView(progress p: Int) -> some View {
        VStack(spacing: Tokens.Spacing.x16) {
            ProgressView(value: Double(p), total: 100)
                .padding(.horizontal, Tokens.Spacing.x16)
            Text("\(p)%")
                .font(Tokens.Font.body)
                .foregroundColor(Tokens.Color.textSecondary)
            Spacer(minLength: 0)
        }
    }

    // Result (E8: кнопки Save / Share)
    private func resultView(_ r: TaskResult) -> some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.x16) {
            Text("Risk analysis complete ✅")
                .font(Tokens.Font.title)
                .foregroundColor(Tokens.Color.textPrimary)

            Text("\(r.risk_score)%")
                .font(Tokens.Font.h1)
                .foregroundColor(Tokens.Color.textPrimary)

            Text(riskLevelText(r.risk_score))
                .font(Tokens.Font.body)
                .foregroundColor(Tokens.Color.textSecondary)

            Divider()

            Text("Red flags").font(Tokens.Font.subtitle)
            ForEach(r.red_flags, id: \.self) { Text("• \($0)") }

            Divider()

            Text("Recommendations").font(Tokens.Font.subtitle)
            ForEach(r.recommendations, id: \.self) { Text("• \($0)") }

            // --- E8 CTA ---
            PrimaryButton("Save to History") {
                vm.saveToHistory()
            }

            ShareLink(item: shareText(for: r)) {
                Text("Share")
                    .font(Tokens.Font.caption)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        Tokens.Color.accent,
                        in: RoundedRectangle(cornerRadius: Tokens.Radius.pill, style: .continuous)
                    )
            }
            // ---------------

            Button("Select another") { showSourceActionSheet() }
                .font(Tokens.Font.body)
                .foregroundColor(Tokens.Color.textSecondary)
                .padding(.top, Tokens.Spacing.x8)

            Spacer(minLength: 0)
        }
    }

    // Error
    private func errorView(_ msg: String) -> some View {
        VStack(spacing: Tokens.Spacing.x16) {
            Text(msg)
                .font(Tokens.Font.body)
                .foregroundColor(.red)
                .multilineTextAlignment(.center)

            PrimaryButton("Try again") { showSourceActionSheet() }

            Spacer(minLength: 0)
        }
    }

    // MARK: - Helpers

    private func riskLevelText(_ score: Int) -> String {
        switch score {
        case 0..<34:  return "Low risk level"
        case 34..<67: return "Medium risk level"
        default:      return "High risk level"
        }
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
        // пока просто повторно открываем фотопикер
        showPhotoPicker = true
    }
}
