//
//  SearchViewModel.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//

//
//  SearchViewModel.swift
//  CheaterBuster
//

import Foundation
import Combine
import UIKit

final class SearchViewModel: ObservableObject {

    // MARK: - Input
    @Published var query: String = ""

    // MARK: - Output
    @Published private(set) var results: [ImageHit] = []
    @Published private(set) var isLoading: Bool = false            // мелкие индикаторы (в кнопках)
    @Published private(set) var isBlockingLoading: Bool = false     // full-screen загрузка
    @Published private(set) var errorText: String?

    // MARK: - Deps
    private let search: SearchService
    private let history: HistoryStore
    // settings можно использовать позже (флаги, лимиты, т.п.)
    private let settings: SettingsStore?

    private var bag = Set<AnyCancellable>()

    // MARK: - Init
    init(search: SearchService,
         history: HistoryStore,
         settings: SettingsStore? = nil)
    {
        self.search = search
        self.history = history
        self.settings = settings
        bindQueryDebounce()
    }

    // MARK: - Debounce по вводу (без блокирующей загрузки)
    private func bindQueryDebounce() {
        $query
            .removeDuplicates()
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .flatMap { [weak self] q -> AnyPublisher<[ImageHit], Never> in
                guard let self, !q.isEmpty else { return Just([]).eraseToAnyPublisher() }
                
                return self.search.searchByName(q)
                    .map { $0 }
                    .catch { [weak self] err -> AnyPublisher<[ImageHit], Never> in
                        self?.errorText = err.localizedDescription
                        return Just([]).eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$results)
    }

    // MARK: - Явный запуск по кнопке «Find»
    func runNameSearch() {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return }

        isLoading = true
        isBlockingLoading = true
        errorText = nil

        search.searchByName(q)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isLoading = false
                self.isBlockingLoading = false
                if case .failure(let err) = completion {
                    self.errorText = err.localizedDescription
                    self.results = []
                }
            } receiveValue: { [weak self] hits in
                guard let self else { return }
                self.results = hits

                
                let previewTitle  = hits.first?.title
                let previewSource = hits.first?.source
                let rec = HistoryRecord(
                    kind: .name,
                    query: q,
                    imageJPEG: nil,
                    titlePreview: previewTitle,
                    sourcePreview: previewSource
                )
                self.history.add(rec)
            }
            .store(in: &bag)
    }

    // MARK: - Запуск по кнопке «Analyze» (по фото)
    func runImageSearch(jpegData: Data) {
        isLoading = true
        isBlockingLoading = true
        errorText = nil

        search.searchByImage(jpegData)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isLoading = false
                self.isBlockingLoading = false
                if case .failure(let err) = completion {
                    self.errorText = err.localizedDescription
                    self.results = []
                }
            } receiveValue: { [weak self] hits in
                guard let self else { return }
                self.results = hits

                
                let thumbData = (UIImage(data: jpegData)?
                    .jpegData(compressionQuality: 0.5)) ?? jpegData

                let rec = HistoryRecord(
                    kind: .face,
                    query: nil,
                    imageJPEG: thumbData,
                    titlePreview: hits.first?.title,
                    sourcePreview: hits.first?.source
                )
                self.history.add(rec)
            }
            .store(in: &bag)
    }

    // MARK: - Прочее (если нужно использовать)
    func resetResults() {
        results = []
        errorText = nil
    }
}
