//
//  SearchViewModel.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//

import Foundation
import Combine

final class SearchViewModel: ObservableObject {
    // Input
    @Published var query: String = ""

    // Output
    @Published private(set) var results: [ImageHit] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorText: String?

    private let search: SearchService
    private let history: HistoryStore
    private let settings: SettingsStore
    private var bag = Set<AnyCancellable>()

    init(search: SearchService, history: HistoryStore, settings: SettingsStore) {
        self.search = search
        self.history = history
        self.settings = settings
        bindQueryDebounce()
    }

    // Автопоиск при наборе (по макету можно отключить; оставим мягко)
    private func bindQueryDebounce() {
        $query
            .removeDuplicates()
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .flatMap { [weak self] q -> AnyPublisher<[ImageHit], Never> in
                guard let self, !q.isEmpty else { return Just([]).eraseToAnyPublisher() }
                self.isLoading = true
                self.errorText = nil
                return self.search.searchByName(q)
                    .handleEvents(receiveCompletion: { _ in self.isLoading = false })
                    .catch { [weak self] err -> AnyPublisher<[ImageHit], Never> in
                        self?.errorText = err.localizedDescription
                        return Just([]).eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$results)
    }

    func runNameSearch() {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return }

        isLoading = true
        errorText = nil

        search.searchByName(q)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let err) = completion {
                    self?.errorText = err.localizedDescription
                    self?.results = []
                }
            } receiveValue: { [weak self] hits in
                self?.results = hits     
            }
            .store(in: &bag)
    }

    func onSubmit() {
        if settings.isHistoryEnabled {
            history.add(query)
        }
    }
}

extension SearchViewModel {
    func runImageSearch(jpegData: Data) {
        isLoading = true
        errorText = nil
        search.searchByImage(jpegData)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let err) = completion {
                    self?.errorText = err.localizedDescription
                    self?.results = []
                }
            } receiveValue: { [weak self] hits in
                self?.results = hits
            }
            .store(in: &bag)
    }
}
