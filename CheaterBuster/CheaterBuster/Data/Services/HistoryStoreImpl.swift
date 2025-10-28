//
//  HistoryStoreImpl.swift
//  CheaterBuster
//

import Foundation
import Combine

/// MRU-хранилище последних запросов (в памяти).
final class HistoryStoreImpl: HistoryStore {
    private let maxItems: Int
    private let subject: CurrentValueSubject<[String], Never> = .init([])

    init(maxItems: Int = 10) {
        self.maxItems = maxItems
    }

    var itemsPublisher: AnyPublisher<[String], Never> {
        subject.eraseToAnyPublisher()
    }

    func add(_ item: String) {
        var arr = subject.value
        let trimmed = item.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        // Удаляем существующий (если был), вставляем в начало.
        arr.removeAll { $0 == trimmed }
        arr.insert(trimmed, at: 0)

        // Усекаем хвост, если превысили лимит.
        if arr.count > maxItems {
            arr = Array(arr.prefix(maxItems))
        }
        subject.send(arr)
    }

    func get() -> [String] { subject.value }

    func clear() { subject.send([]) }
}
