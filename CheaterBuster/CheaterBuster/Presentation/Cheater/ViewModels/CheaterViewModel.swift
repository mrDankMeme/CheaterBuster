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

    enum State: Equatable {
        case idle
        case previewImage(UIImage)
        case previewFile(name: String, data: Data)
        case uploading(progress: Int)
        case result(TaskResult)
        case error(String)

        static func == (lhs: State, rhs: State) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle):
                return true
            case let (.previewImage(lImg), .previewImage(rImg)):
                // ⚠️ UIImage не поддерживает Equatable — сравним по data.
                return lImg.pngData() == rImg.pngData()
            case let (.previewFile(lName, lData), .previewFile(rName, rData)):
                return lName == rName && lData == rData
            case let (.uploading(l), .uploading(r)):
                return l == r
            case let (.result(l), .result(r)):
                return l == r
            case let (.error(l), .error(r)):
                return l == r
            default:
                return false
            }
        }
    }

    @Published var state: State = .idle

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

    // MARK: - Added: управление текущим анализом
    private var currentAnalysisTask: Task<Void, Never>? = nil

    init(auth: AuthRepository, api: CheaterAPI, poller: TaskPoller, store: CheaterStore, cfg: APIConfig) {
        self.auth = auth; self.api = api; self.poller = poller; self.store = store; self.cfg = cfg
    }

    func showImage(_ image: UIImage) { state = .previewImage(image) }
    func showFile(name: String, data: Data) { state = .previewFile(name: name, data: data) }

    /// Публичный метод, чтобы экран мог показать ошибку, не трогая `state` напрямую.
    func presentError(_ message: String) { state = .error(message) }

    // MARK: - Added: отмена/сброс анализа
    func cancelCurrentAnalysis() {
        currentAnalysisTask?.cancel()
        currentAnalysisTask = nil
    }

    // MARK: - Changed: старт анализа теперь хранит Task и уважает отмену
    func analyseCurrent(conversation: String? = nil, apphudId: String) {
        // На всякий случай убьём предыдущий анализ, если был
        cancelCurrentAnalysis()

        currentAnalysisTask = Task { [weak self] in
            guard let self else { return }
            do {
                try await self.auth.ensureAuthorized(apphudId: apphudId)

                switch self.state {
                case .previewImage(let img):
                    guard let data = img.jpegData(compressionQuality: 0.9) else { throw APIError.noData }
                    try await self.runTask(
                        files: [.init(name: "files", filename: "image.jpg", mimeType: "image/jpeg", data: data)],
                        conversation: conversation,
                        kind: .image
                    )

                case .previewFile(let name, let data):
                    try await self.runTask(
                        files: [.init(name: "files", filename: name, mimeType: self.mime(for: name), data: data)],
                        conversation: conversation,
                        kind: .file
                    )

                default:
                    break
                }
            } catch {
                if Task.isCancelled { return } // MARK: - Added: уважение отмены
                self.presentError((error as? LocalizedError)?.errorDescription ?? error.localizedDescription)
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

    private func mime(for filename: String) -> String {
        let ext = (filename as NSString).pathExtension.lowercased()
        switch ext {
        case "jpg", "jpeg": return "image/jpeg"
        case "png": return "image/png"
        case "pdf": return "application/pdf"
        case "txt": return "text/plain"
        default: return "application/octet-stream"
        }
    }

    private func runTask(files: [MultipartFormData.FilePart], conversation: String?, kind: CheaterRecord.Kind) async throws {
        if Task.isCancelled { return }                    // MARK: - Added
        state = .uploading(progress: 10)

        let created = try await api.createAnalyzeTask(files: files, conversation: conversation)
        if Task.isCancelled { return }                    // MARK: - Added
        state = .uploading(progress: 35)

        // Ожидание результата, с уважением отмены
        let final: TaskReadDTO
        switch created.status {
        case .finished, .failed:
            final = created
        default:
            final = try await poller.waitForAnalyzeResult(taskId: created.id, interval: 1.0)
        }
        if Task.isCancelled { return }                    // MARK: - Added

        switch final.status {
        case .finished:
            if case .details(let r)? = final.result {
                lastKind = kind
                lastResult = r
                state = .result(r)
            } else if case .message(let msg)? = final.result {
                presentError(msg)
            } else {
                presentError("Empty result")
            }

        case .failed:
            presentError(final.error ?? "Analysis failed")

        default:
            presentError("Unexpected status: \(final.status)")
        }
    }
}
