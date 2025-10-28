//
//  SettingsViewModel.swift
//  CheaterBuster
//

import Foundation
import Combine

final class SettingsViewModel: ObservableObject {
    @Published var isHistoryEnabled: Bool {
        didSet { store.isHistoryEnabled = isHistoryEnabled }
    }

    private var store: SettingsStore

    init(store: SettingsStore) {
        self.store = store
        self.isHistoryEnabled = store.isHistoryEnabled
    }
}
