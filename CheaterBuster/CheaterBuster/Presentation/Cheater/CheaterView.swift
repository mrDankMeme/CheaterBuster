//
//  CheaterScreen.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//



import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct CheaterView: View {
    @ObservedObject var vm: CheaterViewModel

    // PhotosPicker
    @State private var photoItem: PhotosPickerItem?
    @State private var showPhotoPicker = false

    // Document picker
    @State private var showFilePicker = false

    // (опционально) сопроводительный текст переписки
    @State private var conversationText: String = ""

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

        // 🔹 Нормальный способ показать PhotosPicker
        .photosPicker(
            isPresented: $showPhotoPicker,
            selection: $photoItem,
            matching: .images
        )

        // 🔹 Встроенный файловый импортер
        .fileImporter(
            isPresented: $showFilePicker,
            allowedContentTypes: [.pdf, .png, .jpeg, .plainText],
            allowsMultipleSelection: false
        ) { result in
            if case .success(let urls) = result,
               let url = urls.first,
               let data = try? Data(contentsOf: url) {
                vm.showFile(name: url.lastPathComponent, data: data)
            }
        }

        // Когда пользователь выбрал фото — грузим его и шлём во VM
        .onChange(of: photoItem) { item in
            guard let item else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let img = UIImage(data: data) {
                    await MainActor.run { vm.showImage(img) }
                }
                // Сброс, чтобы можно было выбрать тот же файл снова
                await MainActor.run { photoItem = nil }
            }
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

    // Result
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

            PrimaryButton("Select another") { showSourceActionSheet() }
                .padding(.top, Tokens.Spacing.x16)

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

    private func showSourceActionSheet() {
        // Просто показываем оба пикера как отдельные действия
        // (если хочешь actionSheet — можно собрать через .confirmationDialog)
        showPhotoPicker = true
        // или, если нужно меню выбора — раскомментируй confirmationDialog ниже
    }
}
