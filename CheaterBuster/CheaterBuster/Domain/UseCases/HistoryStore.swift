//
//  HistoryStore.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//

import Foundation
import Combine

public protocol HistoryStore {
    func load() -> [HistoryRecord]
    func add(_ record: HistoryRecord)
    func clearAll()
}
