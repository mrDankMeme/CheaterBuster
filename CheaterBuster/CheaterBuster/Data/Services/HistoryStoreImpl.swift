//
//  HistorySotreImpl.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//

import Foundation
import Combine

final class HistoryStoreImpl: HistoryStore {
    var maxItems: Int
    var subject: CurrentValueSubject<[String], Never> = .init([])
    
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
        arr.removeAll(where: { $0 == trimmed })
        if arr.count >= maxItems {
            arr.removeFirst()
        }
        arr.append(trimmed)
        subject.send(arr)
    }
    
    func get() -> [String] {
        return subject.value
    }
    
    func clear() {
        subject.send([])
    }
    
    
}
