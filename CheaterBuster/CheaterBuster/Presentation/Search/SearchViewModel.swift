//
//  SearchViewModel.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//

import Foundation
import Combine

final class SearchViewModel: ObservableObject {
    //input
    @Published var query: String = ""
    //Output
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var results: [ImageHit] = []
    @Published private(set) var errorText: String?
    
    private let search: SearchService
    private let history: HistoryStore
    private let settings: SettingsStore
    private var bag = Set<AnyCancellable>()
    
    init(search: SearchService, history: HistoryStore, settings: SettingsStore) {
        self.search = search
        self.history = history
        self.settings = settings
        // логику подпишем на шаге E
    }
}
