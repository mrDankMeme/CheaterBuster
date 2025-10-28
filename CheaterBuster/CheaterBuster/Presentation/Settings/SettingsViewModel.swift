//
//  SettingsViewModel.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//

import Foundation
import Combine

final class SettingsViewModel: ObservableObject {
    @Published var isHistoryEndabled: Bool
    private let store: SettingsStore
    
    init(store: SettingsStore) {
        self.store = store
        self.isHistoryEndabled = store.isHistoryEnabled
    }
}
