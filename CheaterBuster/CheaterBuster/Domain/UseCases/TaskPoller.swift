// Domain/Services/TaskPoller.swift
import Foundation

protocol TaskPoller {
    func waitForAnalyzeResult(taskId: UUID, interval: TimeInterval) async throws -> TaskReadDTO
    func waitForReverseResult(taskId: UUID, interval: TimeInterval) async throws -> ReverseSearchGetResponse
}

final class TaskPollerImpl: TaskPoller {
    private let api: CheaterAPI
    init(api: CheaterAPI) { self.api = api }

    func waitForAnalyzeResult(taskId: UUID, interval: TimeInterval = 1.0) async throws -> TaskReadDTO {
        while true {
            let state = try await api.getAnalyzeTask(id: taskId)
            switch state.status {
            case .completed, .failed: return state
            case .queued, .running:
                try await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
            }
        }
    }

    func waitForReverseResult(taskId: UUID, interval: TimeInterval = 1.0) async throws -> ReverseSearchGetResponse {
        while true {
            let r = try await api.getReverseSearch(id: taskId)
            // считаем «готово» как когда все движки != "queued"/"running"
            let done: Bool = {
                let s = r.status
                return !["queued","running"].contains(s.google.lowercased())
                && !["queued","running"].contains(s.yandex.lowercased())
                && !["queued","running"].contains(s.bing.lowercased())
            }()
            if done { return r }
            try await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
        }
    }
}
