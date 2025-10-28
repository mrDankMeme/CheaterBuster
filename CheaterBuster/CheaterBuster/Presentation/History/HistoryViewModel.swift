//
//  HistoryViewModel.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//

import Foundation
import Combine

final class HistoryViewModel: ObservableObject {
    @Published private(set) var items: [String] = []
    private let store: HistoryStore
    private var bag = Set<AnyCancellable>()
    init(store: HistoryStore) {
        self.store = store
    }
}
