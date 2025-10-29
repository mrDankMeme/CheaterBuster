//
//  CheaterViewModel.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//

import Foundation
import UIKit
import Combine

@MainActor
final class CheaterViewModel: ObservableObject {

    enum State {
        case idle
        case previewImage(UIImage)
        case previewFile(name: String, data: Data)
        case uploading(progress: Int)
        case result(TaskResult)
        case error(String)
    }

    @Published private(set) var state: State = .idle

    // E8: храним последний результат (для Save/Share)
    private var lastKind: CheaterRecord.Kind?
    private var lastResult: TaskResult?

    // Сигнал «сохранено» для экрана (для перехода на History)
    @Published private(set) var didSave: Bool = false

    private let auth: AuthRepository
    private let api: CheaterAPI
    private let poller: TaskPoller
    private let store: CheaterStore
    private let cfg: APIConfig

    init(auth: AuthRepository, api: CheaterAPI, poller: TaskPoller, store: CheaterStore, cfg: APIConfig) {
        self.auth = auth; self.api = api; self.poller = poller; self.store = store; self.cfg = cfg
    }

    func showImage(_ image: UIImage) { state = .previewImage(image) }
    func showFile(name: String, data: Data) { state = .previewFile(name: name, data: data) }

    /// Старт анализа, теперь **не** сохраняем авто в историю — ждём явного Save.
    func analyseCurrent(conversation: String? = nil, apphudId: String) {
        Task {
            do {
                try await auth.ensureAuthorized(apphudId: apphudId)

                switch state {
                case .previewImage(let img):
                    guard let data = img.jpegData(compressionQuality: 0.9) else { throw APIError.noData }
                    try await runTask(files: [
                        .init(name: "files", filename: "image.jpg", mimeType: "image/jpeg", data: data)
                    ], conversation: conversation, kind: .image)

                case .previewFile(let name, let data):
                    try await runTask(files: [
                        .init(name: "files", filename: name, mimeType: mime(for: name), data: data)
                    ], conversation: conversation, kind: .file)

                default:
                    break
                }
            } catch {
                state = .error((error as? LocalizedError)?.errorDescription ?? error.localizedDescription)
            }
        }
    }

    /// Явное сохранение результата анализа в историю.
    func saveToHistory(note: String? = "AI risk analysis") {
        guard let kind = lastKind, let r = lastResult else { return }
        store.add(.init(
            date: Date(),
            kind: kind,
            riskScore: r.risk_score,
            note: note,
            redFlags: r.red_flags,
            recommendations: r.recommendations
        ))
        didSave = true
    }

    // MARK: - Private

    private func runTask(files: [MultipartFormData.FilePart], conversation: String?, kind: CheaterRecord.Kind) async throws {
        state = .uploading(progress: 10)

        let created = try await api.createAnalyzeTask(files: files, conversation: conversation)
        state = .uploading(progress: 35)

        let final: TaskReadDTO
        switch created.status {
        case .finished, .failed:
            final = created
        default:
            final = try await poller.waitForAnalyzeResult(taskId: created.id, interval: 1.0)
        }

        switch final.status {
        case .finished:
            if case .details(let r)? = final.result {
                // E8: не сохраняем автоматически — показываем пользователю, а затем Save.
                lastKind = kind
                lastResult = r
                state = .result(r)
            } else if case .message(let msg)? = final.result {
                state = .error(msg)
            } else {
                state = .error("Empty result")
            }

        case .failed:
            state = .error(final.error ?? "Analysis failed")

        default:
            state = .error("Unexpected status: \(final.status)")
        }
    }

    private func mime(for filename: String) -> String {
        let ext = (filename as NSString).pathExtension.lowercased()
        switch ext {
        case "jpg","jpeg": return "image/jpeg"
        case "png":        return "image/png"
        case "pdf":        return "application/pdf"
        case "txt":        return "text/plain"
        default:           return "application/octet-stream"
        }
    }
}
