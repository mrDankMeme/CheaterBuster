//
//  TaskPollerImpl.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/29/25.
//


import Foundation

final class TaskPollerImpl: TaskPoller {
    private let api: CheaterAPI
    init(api: CheaterAPI) { self.api = api }

    func waitForAnalyzeResult(taskId: UUID, interval: TimeInterval = 1.0) async throws -> TaskReadDTO {
        while true {
            let state = try await api.getAnalyzeTask(id: taskId)
            switch state.status {
            case .finished, .failed: return state
            case .queued, .started, .other:
                try await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
            }
        }
    }

    func waitForReverseResult(taskId: UUID, interval: TimeInterval = 1.0) async throws -> ReverseSearchGetResponse {
        while true {
            let r = try await api.getReverseSearch(id: taskId)
            // готово, когда все "completed"; любые другие (например "pending") — продолжаем
            let done = [r.status.google, r.status.yandex, r.status.bing]
                .allSatisfy { $0.lowercased() == "completed" }
            if done { return r }
            try await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
        }
    }
}
